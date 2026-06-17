// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The load balancer + missed-day catch-up (06 §7; PRD §7.9). Pure
// `package:glados`, no clock, no RNG. INV-2 (manzil never dropped at ANY budget)
// and INV-4 (determinism) were written FIRST: a "stop at budget" stub drops the
// tail of Far; a Random-shuffled stub fails determinism. Day counts/budgets are
// integers; rOf is a deterministic stub.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import 'support/fixtures.dart';

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());
  final today = day(130);

  Card far(int id, {int dueOn = 0}) => testCard(
        pageId: id,
        stabilityDays: 100, // far phase
        dueAt: day(dueOn),
      );
  Card near(int id) =>
      testCard(pageId: id, track: ReviewTrack.near, stabilityDays: 20);

  group('INV-2 — manzil never dropped, at ANY budget', () {
    // PRD §7.9/§7.12: manzil is un-skippable; overflow is signal, never a drop.
    double flatR(Card c) => 0.9;
    Glados2<List<int>, int>(
      any.listWithLengthInRange(0, 30, any.intInRange(1, 200)),
      any.intInRange(-10, 100),
    ).test('every Far item survives loadBalance for any budget', (ids, budget) {
      final cards = [for (var i = 0; i < ids.length; i++) far(i + 1)];
      final plan = engine.loadBalance(cards, budget, today, flatR);
      expect(plan.allPageIds, containsAll(cards.map((c) => c.pageId)));
    });
  });

  group('INV-4 — determinism (fuzz OFF)', () {
    double rOf(Card c) => 0.7 + c.pageId * 0.01;
    test('two loadBalance runs over identical inputs are fingerprint-equal',
        () {
      final day0 = [far(1), far(2), near(3), near(4)];
      final a = engine.loadBalance(day0, 5, today, rOf);
      final b = engine.loadBalance(day0, 5, today, rOf);
      expect(a.fingerprint(), b.fingerprint());
    });

    test('two catchUp runs over identical inputs are equal', () {
      final backlog = [far(1), far(2), far(3), far(4)];
      final a = engine.catchUp(backlog, 2, today, rOf);
      final b = engine.catchUp(backlog, 2, today, rOf);
      expect(a.map((p) => p.fingerprint()), b.map((p) => p.fingerprint()));
    });
  });

  group('overflow sets the flag, drops nothing', () {
    double flatR(Card c) => 0.9;
    test('mandatory manzil over budget → overflow true, all Far present', () {
      final cards = [far(1), far(2), far(3)]; // 3 × 2 = 6 min
      final plan = engine.loadBalance(cards, 4, today, flatR);
      expect(plan.budgetOverflow, isTrue);
      expect(plan.allPageIds, [1, 2, 3]);
    });

    test('a day that fits → overflow false', () {
      final cards = [far(1), far(2), far(3)];
      final plan = engine.loadBalance(cards, 10, today, flatR);
      expect(plan.budgetOverflow, isFalse);
    });
  });

  group('NEAR urgency, floor promotion vs safe slip', () {
    test('the more-urgent (lower-R) Near page is scheduled first under budget',
        () {
      double rOf(Card c) => c.pageId == 3 ? 0.90 : 0.95; // page 3 more urgent
      final plan = engine.loadBalance([near(3), near(4)], 2, today, rOf);
      expect(plan.allPageIds, [3]); // only the more-urgent one fits
    });

    test('above-floor → deferred; at/below-floor → promoted even over budget',
        () {
      double rOf(Card c) => c.pageId == 5 ? 0.90 : 0.80; // 6 is below floor
      final plan = engine.loadBalance([near(5), near(6)], 0, today, rOf);
      expect(plan.allPageIds, contains(6)); // below floor → promoted
      expect(plan.allPageIds, isNot(contains(5))); // above floor → deferred
    });

    test('a page exactly at the floor is promoted (strict >)', () {
      double rOf(Card c) => kHardFloorR; // == floor → promote
      final plan = engine.loadBalance([near(7)], 0, today, rOf);
      expect(plan.allPageIds, contains(7));
    });
  });

  group('NEW gated on remaining budget; manzil/Near never cut for NEW', () {
    double flatR(Card c) => 0.9;
    Card fresh(int id) =>
        testCard(pageId: id, track: ReviewTrack.newPage, stabilityDays: 5);

    test('NEW is held when manzil already overflowed the budget', () {
      final plan =
          engine.loadBalance([far(1), far(2), fresh(3)], 2, today, flatR);
      expect(plan.allPageIds, containsAll([1, 2])); // far mandatory
      expect(plan.allPageIds, isNot(contains(3))); // new held
    });

    test('NEW is taken when budget remains', () {
      final plan = engine.loadBalance([far(1), fresh(3)], 10, today, flatR);
      expect(plan.allPageIds, containsAll([1, 3]));
    });
  });

  group('catch-up re-spreads, never dumps or shames', () {
    double rOf(Card c) =>
        c.pageId * 0.05; // lower pageId = lower R = more urgent

    test('re-spreads the backlog across N budget-sized days; union == backlog',
        () {
      // 10 pages × 2 min = 20 min; budget 6 → spreadDays = ceil(20/6) = 4.
      final backlog = [for (var i = 1; i <= 10; i++) far(i)];
      final plans = engine.catchUp(backlog, 4, today, rOf);
      final union = [for (final p in plans) ...p.allPageIds];
      expect(union.toSet(), {for (var i = 1; i <= 10; i++) i});
      expect(union.length, 10); // nothing dropped, nothing duplicated
      for (final p in plans) {
        final minutes = p.items.fold(0, (m, c) => m + estMinutes(c));
        expect(minutes, lessThanOrEqualTo(6)); // each day fits the budget
        expect(p.budgetOverflow, isFalse); // no red/overdue state
      }
    });

    test('most-decayed and prayer-critical first', () {
      final critical = testCard(
        pageId: 99,
        stabilityDays: 100,
        isPrayerCritical: true,
      );
      double equalR(Card c) => 0.5; // force the tiebreak
      final plans = engine.catchUp([far(1), critical], 1, today, equalR);
      // prayer-critical leads at equal R.
      expect(plans.first.allPageIds.first, 99);
    });

    test('an empty backlog yields no plans', () {
      expect(engine.catchUp(const [], 3, today, rOf), isEmpty);
    });
  });
}
