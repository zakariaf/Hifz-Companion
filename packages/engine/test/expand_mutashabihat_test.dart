// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Sibling massing (E14-T05): seed expandMutashabihat with the bundled
// confusables projection so a due group member pulls ALL its siblings into the
// SAME buildToday session, adjacent, never spaced across days — additive
// contrast, never a dropped review, never a schedule mutation (PRD §9.2; science
// 05 §5; CLAIMS C-028; engineering 06 §7). Pure `package:glados` — no clock, no
// RNG; `today` is a CalendarDate literal. The core splice mechanics are pinned in
// build_today_test; this suite pins the projection, the not-due-sibling
// materialization, and the additive/no-mutation/determinism properties.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import 'support/fixtures.dart';

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults()); // far 30, near 7
  final today = day(130);

  Card pageCard(int id, double s, {int lastReview = 0, int? due}) => testCard(
        pageId: id,
        track: bandForStability(s),
        stabilityDays: s,
        lastReviewedDay: day(lastReview),
        dueAt: day(due ?? 0),
      );

  List<Card> cardsFor(List<int> pages) =>
      [for (final p in pages) pageCard(p, 100)];

  /// A symmetric one-group projection over [pages].
  MutashabihGroups groupOf(List<int> pages) => MutashabihGroups({
        for (final p in pages) p: pages.toSet().difference({p}),
      });

  group('MutashabihGroups projection', () {
    test('siblingsOf returns the group minus self; empty for an unknown page',
        () {
      final groups = groupOf([1, 2, 3]);
      expect(groups.siblingsOf(1), {2, 3});
      expect(groups.siblingsOf(99), isEmpty);
      expect(MutashabihGroups.empty.siblingsOf(1), isEmpty);
    });
  });

  group('confusionSiblingsFor materializes siblings from the full card set',
      () {
    test('a NOT-due sibling is still resolved (so it can be massed today)', () {
      final due = pageCard(1, 100); // due today
      final notDue = pageCard(2, 100, lastReview: 125, due: 200); // not due
      final lookup = confusionSiblingsFor(groupOf([1, 2]), [due, notDue]);
      expect(lookup(due).map((c) => c.pageId), [2]);
    });

    test('sibling order is deterministic (sorted by page id)', () {
      final cards = cardsFor([1, 5, 3]);
      final lookup = confusionSiblingsFor(groupOf([1, 3, 5]), cards);
      expect(lookup(cards.first).map((c) => c.pageId), [3, 5]);
    });

    test('a sibling absent from the card set contributes nothing', () {
      final due = pageCard(1, 100);
      final lookup = confusionSiblingsFor(groupOf([1, 2]), [due]);
      expect(lookup(due), isEmpty);
    });
  });

  group('massing through expandMutashabihat (the seam, seeded)', () {
    test(
        'a due member pulls its NOT-due sibling into the same session, '
        'adjacent — never left for a later day (C-028)', () {
      final due = pageCard(1, 100);
      final notDue = pageCard(2, 100, lastReview: 125, due: 200);
      final lookup = confusionSiblingsFor(groupOf([1, 2]), [due, notDue]);
      // The FAR slice has only the due page; the sibling is massed additively.
      expect(expandMutashabihat([due], lookup).map((c) => c.pageId), [1, 2]);
    });

    test('a three-way group: one due member pulls BOTH siblings (whole-group)',
        () {
      final cards = cardsFor([1, 2, 3]);
      final lookup = confusionSiblingsFor(groupOf([1, 2, 3]), cards);
      expect(
        expandMutashabihat([cards.first], lookup).map((c) => c.pageId),
        [1, 2, 3],
      );
    });

    test('the massed sibling carries no schedule mutation (D/S/dueAt intact)',
        () {
      final due = pageCard(1, 100);
      final notDue = pageCard(2, 77, lastReview: 125, due: 200);
      final lookup = confusionSiblingsFor(groupOf([1, 2]), [due, notDue]);
      final massed =
          expandMutashabihat([due], lookup).firstWhere((c) => c.pageId == 2);
      expect(massed.stabilityDays, notDue.stabilityDays);
      expect(massed.difficulty, notDue.difficulty);
      expect(massed.dueAt, notDue.dueAt);
    });
  });

  group('integration: buildToday masses the group in the FAR band', () {
    test('a due Far member and its not-due Far sibling recite adjacent today',
        () {
      final due = pageCard(1, 100); // due
      final sibling = pageCard(2, 100, lastReview: 125, due: 200); // not due
      final plan = engine.buildToday(
        [due, sibling],
        today,
        confusionSiblings:
            confusionSiblingsFor(groupOf([1, 2]), [due, sibling]),
      );
      final ids = plan.allPageIds;
      expect(ids, containsAll([1, 2]));
      expect((ids.indexOf(1) - ids.indexOf(2)).abs(), 1); // adjacent
    });

    test('no projection (empty) leaves the plan exactly as un-massed', () {
      final cards = [pageCard(1, 100), pageCard(2, 90)];
      final massed = engine.buildToday(
        cards,
        today,
        confusionSiblings: confusionSiblingsFor(MutashabihGroups.empty, cards),
      );
      final plain = engine.buildToday(cards, today);
      expect(massed.allPageIds, plain.allPageIds);
    });
  });

  group('properties — whole-group, additive, deterministic, idempotent', () {
    Glados<List<int>>(
      any.listWithLengthInRange(2, 6, any.intInRange(1, 200)),
    ).test('a due member masses its whole group (every sibling co-occurs)',
        (rawPages) {
      final pages = rawPages.toSet().toList();
      if (pages.length < 2) return; // need a real group
      final cards = cardsFor(pages);
      final lookup = confusionSiblingsFor(groupOf(pages), cards);
      // Start with only the first member in the slice; the rest are massed.
      final out = expandMutashabihat([cards.first], lookup)
          .map((c) => c.pageId)
          .toSet();
      expect(out, pages.toSet()); // whole group present (additive)
    });

    Glados<List<int>>(
      any.listWithLengthInRange(2, 6, any.intInRange(1, 200)),
    ).test('massing is idempotent — applying it to its own output is a no-op',
        (rawPages) {
      final pages = rawPages.toSet().toList();
      if (pages.length < 2) return;
      final cards = cardsFor(pages);
      final lookup = confusionSiblingsFor(groupOf(pages), cards);
      final once = expandMutashabihat([cards.first], lookup);
      final twice = expandMutashabihat(once, lookup);
      expect(twice.map((c) => c.pageId), once.map((c) => c.pageId));
    });
  });
}
