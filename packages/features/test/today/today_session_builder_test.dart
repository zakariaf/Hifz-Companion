// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// buildTodaySession is the read model: it runs the real engine's pre-built day,
// groups it Far → Near → New by phaseOf (never re-sorting within a section),
// carries the budget flag, and surfaces the engine's catch-up re-spread when an
// overdue backlog indicates a missed gap. Pure: real engine, injected "today".

import 'package:engine/engine.dart'
    show Card, EngineConfig, ReviewTrack, SchedulingEngine;
import 'package:features/src/today/today_session.dart';
import 'package:features/src/today/today_session_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  final engine = SchedulingEngine(EngineConfig.defaults());
  TodaySession build(List<Card> cards) =>
      buildTodaySession(cards, kToday, engine);

  Card overdueFar(int pageId, {required int daysLate}) => Card(
        profileId: kTestProfile,
        pageId: pageId,
        track: ReviewTrack.far,
        difficulty: 5,
        stabilityDays: 200,
        lastReviewedDay: kToday.addDays(-daysLate - 10),
        dueAt: kToday.addDays(-daysLate),
      );

  test('groups the engine day into Far → Near → New by phase', () {
    final s = build([dueFar(10), dueNear(20), dueNew(30)]);
    expect(s.listState, TodayListState.populated);
    expect(s.far.map((c) => c.pageId), contains(10));
    expect(s.near.map((c) => c.pageId), contains(20));
    expect(s.newSabaq.map((c) => c.pageId), contains(30));
    // The phases are disjoint — a page never appears in two sections.
    expect(s.near, isNot(contains(s.far.first)));
  });

  test('an empty card set maps to the all-done state (total mapping)', () {
    final s = build(const <Card>[]);
    expect(s.listState, TodayListState.allDone);
    expect(s.isEmpty, isTrue);
    expect(s.catchUp, isNull);
    expect(s.budgetOverflow, isFalse);
  });

  test('a day within budget does not overflow', () {
    final s = build([dueFar(1), dueNear(2), dueNew(3)]);
    expect(s.budgetOverflow, isFalse);
  });

  test('a far day exceeding the time budget flags overflow, drops nothing', () {
    // 20 mandatory Far pages × 2 min = 40 min > the 30-min default budget.
    final far = [for (var p = 1; p <= 20; p++) dueFar(p)];
    final s = build(far);
    expect(s.budgetOverflow, isTrue);
    // FAR/manzil is never dropped to fit the budget.
    expect(s.far.length, 20);
  });

  test('an overdue backlog past the gap threshold yields a catch-up plan', () {
    final s = build([
      overdueFar(1, daysLate: 5),
      overdueFar(2, daysLate: 3),
      overdueFar(3, daysLate: 4),
    ]);
    expect(s.catchUp, isNotNull);
    expect(s.catchUp!.missedDays, 5); // the largest overdue gap
    expect(s.catchUp!.planDays, greaterThanOrEqualTo(1));
    expect(s.catchUp!.items, isNotEmpty);
  });

  test('a gap below the threshold is the ordinary day, no catch-up', () {
    // One page one day late — opening a day late is the normal day, not a gap.
    final s = build([overdueFar(1, daysLate: 1)]);
    expect(s.catchUp, isNull);
  });

  test('catch-up coexists with the populated day (does not hide it)', () {
    final s = build([
      overdueFar(1, daysLate: 6),
      overdueFar(2, daysLate: 6),
    ]);
    expect(s.catchUp, isNotNull);
    // The far section is still populated alongside the catch-up flag.
    expect(s.listState, TodayListState.populated);
  });
}
