// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E21-T09 — the new-memorization lifecycle, end-to-end through the pure engine:
// a page a beginner memorizes today (sabaqSeed) enters today's plan on the New
// (sabaq) track, is revised via onReview, and — with fluent teacher sign-off —
// graduates out of New toward the maintenance bulk. Pure package:test, no clock,
// no DB — the same engine the intake controller + write path persist for.

import 'package:engine/engine.dart';
import 'package:models/models.dart'
    show Card, GradeSource, ProfileId, ReviewGrade;
import 'package:test/test.dart';

import '../support/fixtures.dart';

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());
  const profile = ProfileId('p1');

  Card cardFromSeed(CardSeed seed) => Card(
        profileId: profile,
        pageId: seed.pageId,
        track: seed.track,
        difficulty: seed.difficulty,
        stabilityDays: seed.stabilityDays,
        lastReviewedDay: seed.lastReviewedDay,
        dueAt: seed.dueAt,
      );

  test('a freshly-memorized page enters today on the New (sabaq) track', () {
    final today = day(1000);
    final card = cardFromSeed(engine.sabaqSeed(3, today));

    expect(phaseOf(card), ReviewTrack.newPage);
    final plan = engine.buildToday([card], today);
    // The new page is in today's plan (its New band) — intake reached the day.
    expect(plan.items.map((c) => c.pageId), contains(3));
  });

  test('revised with fluent teacher sign-off, it graduates out of New', () {
    var day0 = day(1000);
    var card = cardFromSeed(engine.sabaqSeed(3, day0));
    expect(phaseOf(card), ReviewTrack.newPage);

    // Revise on each due day with a fluent teacher grade — the servant-to-the-
    // teacher graduation path. A bounded loop: it must leave New well within it.
    for (var i = 0; i < 12 && phaseOf(card) == ReviewTrack.newPage; i++) {
      day0 = card.dueAt ?? day0;
      card = engine.onReview(
        card,
        ReviewInput(grade: ReviewGrade.easy, source: GradeSource.teacher),
        day0,
        weakLineCount: 0,
      );
    }

    // It strengthened out of the New band into the maintenance tracks (Near/Far)
    // — never back to unmemorized, never stuck.
    expect(phaseOf(card), isNot(ReviewTrack.newPage));
    expect(
      trackStrength(phaseOf(card)),
      greaterThan(trackStrength(ReviewTrack.newPage)),
    );
    expect(card.dueAt, isNotNull);
  });

  test('a lapse keeps the page in active revision — never dropped', () {
    final today = day(1000);
    var card = cardFromSeed(engine.sabaqSeed(3, today));
    // An Again (stumble) on a new page: stability shrinks, the page stays on the
    // most-revised track and keeps a finite due day — nothing is ever "safe to
    // drop".
    card = engine.onReview(
      card,
      ReviewInput(grade: ReviewGrade.again, source: GradeSource.self),
      today,
      weakLineCount: 1,
    );
    expect(card.track, isNot(ReviewTrack.unmemorized));
    expect(card.dueAt, isNotNull);
    expect(phaseOf(card), ReviewTrack.newPage);
  });
}
