// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart'
    show
        CalendarDate,
        Card,
        RetentionBand,
        ReviewTrack,
        minLeaningBand,
        retentionBand,
        retrievability,
        sourceConfidenceOf;
import 'package:flutter/foundation.dart' show immutable, listEquals;

/// One page's read-only health for the Progress heat-map — computed **on read**
/// from the live card by the pure [buildProgressOverview], never stored (PRD
/// §10.3). The widget renders this; it re-derives no `R`, band, or aggregate.
@immutable
class PageHealth {
  /// Creates a page-health cell.
  const PageHealth({
    required this.pageId,
    required this.juz,
    required this.memorized,
    required this.retrievability,
    required this.band,
    required this.everReviewed,
    required this.sourceConfidence,
    this.dueAt,
  });

  /// The 1-based muṣḥaf page.
  final int pageId;

  /// The juz (1–30) this page belongs to.
  final int juz;

  /// Whether the page is part of the user's hifz (a tracked, enabled card).
  final bool memorized;

  /// The recall probability `R` on read (`1.0` for a not-yet-recited held page;
  /// `0` for a non-memorized page — meaningless there, never shown).
  final double retrievability;

  /// The calm decay band derived from [retrievability] (faded for non-memorized).
  final RetentionBand band;

  /// Whether the page has had a real review (`reps > 0`); drives VSUP muting of
  /// a cold-start prior.
  final bool everReviewed;

  /// The grade source confidence (teacher 1.0 / self ~0.5; `0` non-memorized).
  final double sourceConfidence;

  /// The page's next-due day (the detail sheet renders it via `CalendarPresenter`);
  /// null for a non-memorized page or one with no scheduled due yet.
  final CalendarDate? dueAt;

  @override
  bool operator ==(Object other) =>
      other is PageHealth &&
      other.pageId == pageId &&
      other.juz == juz &&
      other.memorized == memorized &&
      other.retrievability == retrievability &&
      other.band == band &&
      other.everReviewed == everReviewed &&
      other.sourceConfidence == sourceConfidence &&
      other.dueAt == dueAt;

  @override
  int get hashCode => Object.hash(
        pageId,
        juz,
        memorized,
        retrievability,
        band,
        everReviewed,
        sourceConfidence,
        dueAt,
      );
}

/// One juz's small-multiple summary: its **min-leaning** roll-up band (the
/// weakest memorized page, never a mean; PRD §10.3), the weakest page to flag,
/// and the per-page cells in muṣḥaf order.
@immutable
class JuzSummary {
  /// Creates a juz summary.
  const JuzSummary({
    required this.juz,
    required this.rollUp,
    required this.weakestPageId,
    required this.pages,
  });

  /// The juz (1–30).
  final int juz;

  /// The min-leaning roll-up band over the juz's memorized pages, or `null`
  /// when the juz holds no memorized page (untouched — rendered faded).
  final RetentionBand? rollUp;

  /// The weakest (lowest-`R`) memorized page in the juz, or `null` if none.
  final int? weakestPageId;

  /// The page cells, in ascending muṣḥaf order.
  final List<PageHealth> pages;

  @override
  bool operator ==(Object other) =>
      other is JuzSummary &&
      other.juz == juz &&
      other.rollUp == rollUp &&
      other.weakestPageId == weakestPageId &&
      listEquals(other.pages, pages);

  @override
  int get hashCode =>
      Object.hash(juz, rollUp, weakestPageId, Object.hashAll(pages));
}

/// The whole-Quran Progress read model: 30 juz summaries in order. Immutable,
/// streamed; derived health is never persisted.
@immutable
class ProgressOverview {
  /// Creates the overview.
  const ProgressOverview({required this.juzSummaries});

  /// The empty overview (no profile / reference not loaded yet).
  const ProgressOverview.empty() : juzSummaries = const [];

  /// The 30 juz summaries, ascending.
  final List<JuzSummary> juzSummaries;

  /// Whether any page is part of the user's hifz yet (drives the empty state).
  bool get hasMemorizedPages =>
      juzSummaries.any((j) => j.pages.any((p) => p.memorized));

  @override
  bool operator ==(Object other) =>
      other is ProgressOverview && listEquals(other.juzSummaries, juzSummaries);

  @override
  int get hashCode => Object.hashAll(juzSummaries);
}

/// Builds the [ProgressOverview] from the live [cards], the page→juz [pageJuz]
/// reference map, and the injected [today] — **pure**, no clock, no I/O. `R` is
/// computed on read via the engine curve; the juz roll-up is the engine's
/// min-leaning aggregate (never a mean). The widget renders the result and
/// re-derives nothing (PRD §10.3, §7.12).
ProgressOverview buildProgressOverview({
  required List<Card> cards,
  required Map<int, int> pageJuz,
  required CalendarDate today,
}) {
  final cardByPage = {for (final c in cards) c.pageId: c};

  final pagesByJuz = <int, List<int>>{};
  pageJuz.forEach((page, juz) => (pagesByJuz[juz] ??= <int>[]).add(page));

  final summaries = <JuzSummary>[];
  for (final juz in pagesByJuz.keys.toList()..sort()) {
    final pageIds = pagesByJuz[juz]!..sort();
    final pages = [
      for (final pageId in pageIds)
        _healthFor(pageId, juz, cardByPage[pageId], today),
    ];

    final memorized = pages.where((p) => p.memorized).toList();
    final rollUp = minLeaningBand(memorized.map((p) => p.band));
    int? weakestPageId;
    var weakestR = double.infinity;
    for (final p in memorized) {
      if (p.retrievability < weakestR) {
        weakestR = p.retrievability;
        weakestPageId = p.pageId;
      }
    }

    summaries.add(
      JuzSummary(
        juz: juz,
        rollUp: rollUp,
        weakestPageId: weakestPageId,
        pages: pages,
      ),
    );
  }

  return ProgressOverview(juzSummaries: summaries);
}

PageHealth _healthFor(int pageId, int juz, Card? card, CalendarDate today) {
  if (card == null ||
      !card.isEnabled ||
      card.track == ReviewTrack.unmemorized) {
    return PageHealth(
      pageId: pageId,
      juz: juz,
      memorized: false,
      retrievability: 0,
      band: RetentionBand.faded,
      everReviewed: false,
      sourceConfidence: 0,
    );
  }
  // A held-but-never-recited page sits on its optimistic cold-start prior
  // (R = 1.0); everReviewed = false mutes it (VSUP) so the prior never reads
  // as a confident strong page.
  final r = card.lastReviewedDay == null
      ? 1.0
      : retrievability(
          today.epochDay - card.lastReviewedDay!.epochDay,
          card.stabilityDays,
        );
  return PageHealth(
    pageId: pageId,
    juz: juz,
    memorized: true,
    retrievability: r,
    band: retentionBand(r),
    everReviewed: card.reps > 0,
    sourceConfidence: sourceConfidenceOf(card),
    dueAt: card.dueAt,
  );
}
