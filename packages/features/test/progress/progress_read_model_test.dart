// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E15-T01 — the Progress read model over a fake card set: R-on-read, the
// MIN-LEANING juz roll-up (one rotting page is never averaged into a green
// juz), VSUP muting inputs, and non-memorized pages reading faded. Pure builder,
// no widgets, no clock (today injected). The min-leaning assertion is the
// release-blocking honesty rule (PRD §10.3, §7.12).

import 'package:engine/engine.dart'
    show CalendarDate, Card, RetentionBand, ReviewTrack;
import 'package:features/src/progress/progress_overview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const today = CalendarDate.fromEpochDay(20000);
  const profile = ProfileId('p');

  Card memorized(
    int pageId, {
    required int reviewedDaysAgo,
    double stabilityDays = 200,
    int reps = 3,
    int signoffs = 0,
  }) =>
      Card(
        profileId: profile,
        pageId: pageId,
        track: ReviewTrack.far,
        difficulty: 5,
        stabilityDays: stabilityDays,
        lastReviewedDay: today.addDays(-reviewedDaysAgo),
        dueAt: today.addDays(30),
        reps: reps,
        signoffs: signoffs,
      );

  // Juz 1 = pages 1..3, Juz 2 = pages 4..6 (a tiny fake reference).
  const pageJuz = {1: 1, 2: 1, 3: 1, 4: 2, 5: 2, 6: 2};

  ProgressOverview build(List<Card> cards) =>
      buildProgressOverview(cards: cards, pageJuz: pageJuz, today: today);

  test('R is computed on read: a freshly-reviewed page is strong', () {
    final o = build([memorized(1, reviewedDaysAgo: 0)]);
    final page1 = o.juzSummaries.first.pages.firstWhere((p) => p.pageId == 1);
    expect(page1.memorized, isTrue);
    expect(page1.retrievability, closeTo(1.0, 1e-9));
    expect(page1.band, RetentionBand.strong);
  });

  test('a long-overdue page decays out of the strong band', () {
    // 200 days elapsed on S=200 → R well below 0.95.
    final o = build([memorized(1, reviewedDaysAgo: 200)]);
    final page1 = o.juzSummaries.first.pages.firstWhere((p) => p.pageId == 1);
    expect(page1.retrievability, lessThan(0.95));
    expect(page1.band.index, lessThan(RetentionBand.strong.index));
  });

  test('min-leaning: one weak page is never averaged into a green juz', () {
    // Juz 1: two fresh-strong pages + one badly decayed page.
    final o = build([
      memorized(1, reviewedDaysAgo: 0),
      memorized(2, reviewedDaysAgo: 0),
      memorized(3, reviewedDaysAgo: 2000, stabilityDays: 50), // rotting
    ]);
    final juz1 = o.juzSummaries.firstWhere((j) => j.juz == 1);
    expect(
      juz1.rollUp,
      isNot(RetentionBand.strong),
      reason: 'a mean would hide the rotting page; min-leaning must not',
    );
    expect(juz1.weakestPageId, 3);
  });

  test('non-memorized pages read faded and never count as memorized', () {
    final o = build([memorized(1, reviewedDaysAgo: 0)]); // only page 1 held
    final juz2 = o.juzSummaries.firstWhere((j) => j.juz == 2);
    expect(juz2.pages.every((p) => !p.memorized), isTrue);
    expect(juz2.pages.every((p) => p.band == RetentionBand.faded), isTrue);
    expect(juz2.rollUp, isNull); // untouched juz
    expect(juz2.weakestPageId, isNull);
  });

  test('VSUP inputs: never-recited mutes, teacher sign-off is vivid', () {
    final o = build([
      memorized(1, reviewedDaysAgo: 0, reps: 0), // held, never recited
      memorized(2, reviewedDaysAgo: 0, signoffs: 1), // teacher-confirmed
    ]);
    final pages = o.juzSummaries.first.pages;
    expect(pages.firstWhere((p) => p.pageId == 1).everReviewed, isFalse);
    expect(pages.firstWhere((p) => p.pageId == 2).sourceConfidence, 1.0);
  });

  test('empty card set has no memorized pages (drives the empty state)', () {
    final o = build(const []);
    expect(o.hasMemorizedPages, isFalse);
    expect(o.juzSummaries, isNotEmpty); // the grid still shows faded pages
  });
}
