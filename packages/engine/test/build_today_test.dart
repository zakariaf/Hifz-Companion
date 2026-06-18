// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// buildToday: tradition-shaped day, SR ordering, mutashābihāt massing (06 §7;
// PRD §7.8). Pure `package:glados`, no clock — `today` is a CalendarDate literal,
// R is recomputed by integer subtraction. INV-2 (manzil never dropped) and the
// massing rule were written FIRST: a stub that drops a due Far page, or spaces
// siblings apart, must fail. The day is opaque page ids, so cases assert with
// structural/integer equality.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import 'support/fixtures.dart';

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults()); // far 30, near 7
  final today = day(130);

  // A card whose stored track matches its S-band (so phaseOf == track), due by
  // default (dueAt = day(0)), last reviewed on [lastReview].
  Card pageCard(int id, double s, {int lastReview = 0, int? due}) => testCard(
        pageId: id,
        track: bandForStability(s),
        stabilityDays: s,
        lastReviewedDay: day(lastReview),
        dueAt: day(due ?? 0),
      );

  group('INV-2 — manzil never dropped', () {
    // PRD §7.12: FAR/manzil due items are never silently dropped.
    Glados<List<int>>(any.listWithLengthInRange(0, 40, any.intInRange(1, 200)))
        .test('every due Far page appears in the plan', (stabilities) {
      final cards = [
        for (var i = 0; i < stabilities.length; i++)
          pageCard(i + 1, stabilities[i].toDouble()),
      ];
      final plan = engine.buildToday(cards, today);
      final dueFar = cards.where(
        (c) => phaseOf(c) == ReviewTrack.far && c.dueAt!.epochDay <= 130,
      );
      expect(plan.allPageIds, containsAll(dueFar.map((c) => c.pageId)));
    });
  });

  group('mutashābihāt massing — siblings adjacent, never spaced apart', () {
    final p = pageCard(1, 100);
    final q = pageCard(2, 100);
    final r = pageCard(3, 100);

    test('a sibling is spliced immediately after its page', () {
      List<Card> sibs(Card c) => c.pageId == 1 ? [q] : const [];
      expect(expandMutashabihat([p], sibs).map((c) => c.pageId), [1, 2]);
    });

    test('a three-way group recites contiguously', () {
      List<Card> sibs(Card c) => c.pageId == 1 ? [q, r] : const [];
      expect(expandMutashabihat([p], sibs).map((c) => c.pageId), [1, 2, 3]);
    });

    test('an independently-present sibling is deduplicated (placed once)', () {
      List<Card> sibs(Card c) => c.pageId == 1 ? [q] : const [];
      // q is also in the input; it must appear once, in group order after p.
      expect(expandMutashabihat([p, q], sibs).map((c) => c.pageId), [1, 2]);
    });

    test('an empty lookup returns the input unchanged', () {
      List<Card> none(Card c) => const [];
      expect(expandMutashabihat([p, q], none), [p, q]);
    });
  });

  group('recitation order — manzil → near → new (structural)', () {
    test('the bands appear far, then near, then new', () {
      final far = pageCard(10, 100);
      final near = pageCard(20, 20);
      final fresh = pageCard(30, 5);
      // Input order shuffled; band order must not depend on it.
      final plan = engine.buildToday([fresh, near, far], today);
      final phases = plan.items.map(phaseOf).toList();
      expect(phases, [ReviewTrack.far, ReviewTrack.near, ReviewTrack.newPage]);
    });
  });

  group('weakest-R first within a band, stable + deterministic', () {
    test('the lower-R Far page is ordered first; equal-R breaks by page id',
        () {
      final weak = pageCard(2, 100); // lastReview 0 (default) → lower R
      final strong = pageCard(1, 100, lastReview: 125); // recent → higher R
      final plan = engine.buildToday([strong, weak], today);
      expect(plan.allPageIds, [2, 1]); // weakest (page 2) first
    });

    test('two builds over identical inputs are fingerprint-equal', () {
      final cards = [pageCard(1, 100), pageCard(2, 40), pageCard(3, 5)];
      final a = engine.buildToday(cards, today);
      final b = engine.buildToday(cards, today);
      expect(a.fingerprint(), b.fingerprint());
    });
  });

  group('pull-forward — weak not-due Far pages are pulled in', () {
    // Two not-due Far pages (dueAt in the future), neither in today's slice.
    final lowR = pageCard(1, 100, due: 200); // lastReview 0 → R ≈ 0.87 < 0.95
    final highR = pageCard(2, 100, lastReview: 125, due: 200); // R ≈ 0.99

    test('a low-R not-due page is pulled forward; a high-R one is not', () {
      final plan = engine.buildToday([lowR, highR], today);
      expect(plan.allPageIds, contains(1));
      expect(plan.allPageIds, isNot(contains(2)));
    });

    test('pure-cycle mode pulls neither (SR ordering / pull-forward off)', () {
      final pure = SchedulingEngine(const EngineConfig(pureCycleMode: true));
      final plan = pure.buildToday([lowR, highR], today);
      // Neither is due nor in today's slice, and pure-cycle adds no pull-forward.
      expect(plan.allPageIds, isEmpty);
    });
  });

  group('empty / finished-ḥāfiẓ edges', () {
    test('an empty card set yields an empty plan', () {
      expect(engine.buildToday(const [], today).items, isEmpty);
    });

    test('an all-Far set yields a Far-only day (no NEW band)', () {
      final cards = [pageCard(1, 100), pageCard(2, 90)];
      final plan = engine.buildToday(cards, today);
      expect(plan.items.map(phaseOf), everyElement(ReviewTrack.far));
    });

    test('unmemorized cards are never scheduled', () {
      final plan = engine.buildToday(
        [testCard(track: ReviewTrack.unmemorized)],
        today,
      );
      expect(plan.items, isEmpty);
    });
  });
}
