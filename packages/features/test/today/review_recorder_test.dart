// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The grade-one-page single write path, tested by faking the repository (not the
// engine): the recorder reads the card, asks the real pure engine for the new
// state, assembles the ReviewOutcome, and hands it to commitReview exactly once.
// The transaction/rollback covenant itself is E03's commitReview (its own test);
// here we prove the orchestration around it — engine value persisted verbatim,
// injected today, source round-trip, no swallowed error, append-only.

import 'package:data/data.dart'
    show CardRepository, ReviewRepository, ReviewTransactionFailed;
import 'package:engine/engine.dart';
import 'package:features/features.dart' show ReviewRecorder;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId, ReviewLog, ReviewOutcome;

import '../test_setup.dart';

class _StubCards implements CardRepository {
  _StubCards(this._card);
  final Card? _card;

  @override
  Future<Card?> byId(ProfileId profile, int pageId) async => _card;
  @override
  Future<List<Card>> forProfile(ProfileId profile) async =>
      _card == null ? const [] : [_card];
  @override
  Stream<List<Card>> watchForProfile(ProfileId profile) =>
      Stream.value(_card == null ? const [] : [_card]);
}

class _RecordingReviews implements ReviewRepository {
  ReviewOutcome? committed;
  int commits = 0;

  @override
  Future<void> commitReview(ReviewOutcome outcome) async {
    committed = outcome;
    commits++;
  }
}

class _ThrowingReviews implements ReviewRepository {
  bool called = false;

  @override
  Future<void> commitReview(ReviewOutcome outcome) async {
    called = true;
    throw const ReviewTransactionFailed();
  }
}

void main() {
  useOfflineTestPolicy();

  final engine = SchedulingEngine(EngineConfig.defaults());
  const profile = ProfileId('p1');

  Card farCard() => const Card(
        profileId: profile,
        pageId: 42,
        track: ReviewTrack.far,
        difficulty: 5,
        stabilityDays: 30,
        lastReviewedDay: CalendarDate.fromEpochDay(20000),
        dueAt: CalendarDate.fromEpochDay(20030),
        reps: 4,
      );

  ReviewRecorder recorder(CardRepository cards, ReviewRepository reviews) =>
      ReviewRecorder(
        cards: cards,
        reviews: reviews,
        engine: engine,
        newId: () => 'fixed-log-id',
      );

  test('commits exactly one outcome with the engine state persisted verbatim',
      () async {
    final reviews = _RecordingReviews();
    final today = CalendarDate.ymd(2026, 6, 19);
    await recorder(_StubCards(farCard()), reviews).recordReview(
      profile: profile,
      pageId: 42,
      grade: ReviewGrade.good,
      today: today,
    );

    expect(reviews.commits, 1);
    final outcome = reviews.committed!;

    // The engine is the sole sink for D/S/dueAt — the recorder persists its
    // result verbatim, never re-derives the due date (C-016).
    final expected = engine.onReview(
      farCard(),
      ReviewInput(grade: ReviewGrade.good, source: GradeSource.self),
      today,
      weakLineCount: 0,
    );
    expect(outcome.cardUpdate.dueAt, expected.dueAt);
    expect(outcome.cardUpdate.difficulty, closeTo(expected.difficulty, 1e-9));
    expect(
      outcome.cardUpdate.stabilityDays,
      closeTo(expected.stabilityDays, 1e-9),
    );
    expect(outcome.cardUpdate.reps, expected.reps);
  });

  test('appends one review_log row capturing the audit fields (source self)',
      () async {
    final reviews = _RecordingReviews();
    final today = CalendarDate.ymd(2026, 6, 19);
    await recorder(_StubCards(farCard()), reviews).recordReview(
      profile: profile,
      pageId: 42,
      grade: ReviewGrade.good,
      today: today,
    );

    final ReviewLog log = reviews.committed!.logRow;
    expect(log.logId.value, 'fixed-log-id');
    expect(log.profileId, profile);
    expect(log.pageId, 42);
    expect(log.grade, ReviewGrade.good);
    expect(log.source, GradeSource.self);
    expect(log.trackAtReview, ReviewTrack.far);
    expect(log.errorLineIndices, isNull);
    // elapsed = today(2026-06-19) − lastReviewed(epochDay 20000).
    expect(log.elapsedDays, today.epochDay - 20000);
    expect(log.stabilityDaysBefore, closeTo(30, 1e-9));
    expect(log.difficultyBefore, closeTo(5, 1e-9));
    // The event instant is midnight UTC of the injected scheduling day.
    expect(log.reviewedAtInstant, DateTime.utc(2026, 6, 19));
    // No line-block list is created at zero error lines (E07 spine).
    expect(reviews.committed!.newLineBlocks, isEmpty);
  });

  test('today is injected: distinct days yield distinct schedules', () async {
    final earlyReviews = _RecordingReviews();
    final lateReviews = _RecordingReviews();
    await recorder(_StubCards(farCard()), earlyReviews).recordReview(
      profile: profile,
      pageId: 42,
      grade: ReviewGrade.good,
      today: CalendarDate.ymd(2026, 6, 19),
    );
    await recorder(_StubCards(farCard()), lateReviews).recordReview(
      profile: profile,
      pageId: 42,
      grade: ReviewGrade.good,
      today: CalendarDate.ymd(2026, 7, 19),
    );

    expect(
      earlyReviews.committed!.logRow.elapsedDays,
      isNot(lateReviews.committed!.logRow.elapsedDays),
    );
  });

  test('teacher source round-trips through the outcome', () async {
    final reviews = _RecordingReviews();
    await recorder(_StubCards(farCard()), reviews).recordReview(
      profile: profile,
      pageId: 42,
      grade: ReviewGrade.good,
      today: CalendarDate.ymd(2026, 6, 19),
      source: GradeSource.teacher,
    );
    expect(reviews.committed!.logRow.source, GradeSource.teacher);
  });

  test('a failed persist propagates untouched — never swallowed', () async {
    final reviews = _ThrowingReviews();
    await expectLater(
      recorder(_StubCards(farCard()), reviews).recordReview(
        profile: profile,
        pageId: 42,
        grade: ReviewGrade.good,
        today: CalendarDate.ymd(2026, 6, 19),
      ),
      throwsA(isA<ReviewTransactionFailed>()),
    );
    expect(reviews.called, isTrue);
  });

  test('throws when no card exists for the page (no silent no-op)', () async {
    final reviews = _RecordingReviews();
    await expectLater(
      recorder(_StubCards(null), reviews).recordReview(
        profile: profile,
        pageId: 42,
        grade: ReviewGrade.good,
        today: CalendarDate.ymd(2026, 6, 19),
      ),
      throwsA(isA<StateError>()),
    );
    expect(reviews.commits, 0);
  });
}
