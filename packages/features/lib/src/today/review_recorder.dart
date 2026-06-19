// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show CardRepository, ReviewRepository;
import 'package:engine/engine.dart'
    show
        CalendarDate,
        Card,
        GradeSource,
        ReviewGrade,
        ReviewInput,
        ReviewUpdate,
        SchedulingEngine;
import 'package:models/models.dart'
    show LogId, ProfileId, ReviewLog, ReviewOutcome;

import '../ids/uuid_v4.dart';

/// The grade-one-page command — the orchestration that turns a user grade into
/// the durable single write path (04 §1.3, §4; 05 §3).
///
/// It reads the current immutable [Card], asks the pure [SchedulingEngine] for
/// the new state (the engine is the *only* sink for D/S/`dueAt` — the trust
/// clamp, C-016 — never re-derived here), assembles the [ReviewOutcome] (the
/// append-only `review_log` row + the updated card), and hands it to the merged
/// single write path [ReviewRepository.commitReview], which opens one
/// `db.transaction`, appends the log first, upserts the card, and commits
/// **before** any Drift stream re-emits. This command does no manual republish,
/// holds no second card cache, swallows no write error, and reads no wall clock
/// — "today" is injected as a [CalendarDate].
class ReviewRecorder {
  /// Creates the recorder over the read seam, the single write path, and the
  /// pure engine. [newId] supplies the `review_log` id (default a v4 UUID); a
  /// test injects a deterministic generator.
  ReviewRecorder({
    required CardRepository cards,
    required ReviewRepository reviews,
    required SchedulingEngine engine,
    String Function() newId = uuidV4,
  })  : _cards = cards,
        _reviews = reviews,
        _engine = engine,
        _newId = newId;

  final CardRepository _cards;
  final ReviewRepository _reviews;
  final SchedulingEngine _engine;
  final String Function() _newId;

  /// Records one graded review of `(profile, pageId)` on the injected [today].
  ///
  /// Throws a [StateError] if no card exists for the page, and lets the data
  /// layer's sealed write error propagate untouched (no `try`/`catch`) — a
  /// *sanad* act is never "saved later" or acknowledged before its commit.
  Future<void> recordReview({
    required ProfileId profile,
    required int pageId,
    required ReviewGrade grade,
    required CalendarDate today,
    List<int> errorLines = const <int>[],
    GradeSource source = GradeSource.self,
  }) async {
    final card = await _cards.byId(profile, pageId);
    if (card == null) {
      throw StateError('recordReview: no card for $profile page $pageId');
    }
    final review = ReviewInput(
      grade: grade,
      source: source,
      errorLines: errorLines,
    );
    // The engine produces the new (D, S, dueAt) via the trust clamp; the spine
    // reads no line_block rows yet, so the weak-line channel is 0 (E12 wires it).
    final updated = _engine.onReview(card, review, today, weakLineCount: 0);
    final outcome = ReviewOutcome(
      logRow: _logRow(card, updated, review, today),
      cardUpdate: updated,
    );
    // 05 §3 / 04 §4: the single write path — one db.transaction, append
    // review_log then upsert card, commit before any stream re-emits.
    await _reviews.commitReview(outcome);
  }

  ReviewLog _logRow(
    Card before,
    Card after,
    ReviewInput review,
    CalendarDate today,
  ) {
    final elapsedDays = before.lastReviewedDay == null
        ? 0
        : today.epochDay - before.lastReviewedDay!.epochDay;
    return ReviewLog(
      logId: LogId(_newId()),
      profileId: before.profileId,
      pageId: before.pageId,
      // The event instant. The spine has no precise-time clock (determinism:
      // no DateTime.now), so it records midnight UTC of the injected scheduling
      // day; the scheduling delta is elapsedDays. A precise event-instant clock
      // can be injected in E12 if the audit needs sub-day resolution.
      reviewedAtInstant: DateTime.utc(today.year, today.month, today.day),
      trackAtReview: before.track,
      grade: review.grade,
      errorLineIndices:
          review.errorLines.isEmpty ? null : List<int>.of(review.errorLines),
      elapsedDays: elapsedDays,
      source: review.source,
      stabilityDaysBefore: before.stabilityDays,
      stabilityDaysAfter: after.stabilityDays,
      difficultyBefore: before.difficulty,
      difficultyAfter: after.difficulty,
    );
  }
}
