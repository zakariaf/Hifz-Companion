// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The group-not-node invariant for confusion-aware grading (E14-T04): a logged
// swap bumps Difficulty on EVERY member of the confusable group — including the
// unpracticed twin that was NOT recited today — so retrieval-induced forgetting
// can never leave a sibling behind (science 05 §4; CLAIMS C-029). Pure
// `package:glados` — no clock, no RNG, no fixed lucky seed; rely on shrinking.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import '../support/fixtures.dart';

extension AnyConfusionGroup on Any {
  /// A card with a generated in-range difficulty (the page id varies so a group
  /// is a plausible set of distinct pages).
  Generator<Card> get bumpCard => combine2(
        any.intInRange(1, 605),
        any.intInRange(1, 11), // difficulty 1..10
        (id, d) => testCard(pageId: id, difficulty: d.toDouble()),
      );

  /// A confusable group: two or more member cards (group-not-node).
  Generator<List<Card>> get confusableGroup =>
      any.listWithLengthInRange(2, 6, any.bumpCard);

  /// A bounded, non-negative logged-swap weight (0..10), as a double.
  Generator<double> get confusionWeight =>
      any.intInRange(0, 11).map((w) => w.toDouble());
}

void main() {
  // EVERY member is bumped (group-not-node) — no twin left at its pre-swap D.
  Glados2<List<Card>, double>(any.confusableGroup, any.confusionWeight).test(
    'a swap bumps D on every group member, never just the recited node (C-029)',
    (members, weight) {
      final bumped = applyConfusionBump(members, weight);
      // The whole group survives, in order (group-not-node).
      expect(bumped.length, members.length);
      for (var i = 0; i < members.length; i++) {
        final before = members[i].difficulty;
        final after = bumped[i].difficulty;
        // Bounded: the bump can only pull D up, clamped to [1,10].
        expect(after, lessThanOrEqualTo(10.0));
        expect(after, greaterThanOrEqualTo(before));
        // Whole-group: with a real swap, the unpracticed twin IS bumped too —
        // no member is left at its pre-swap D unless already at the ceiling.
        if (weight > 0 && before < 10.0) {
          expect(
            after,
            greaterThan(before),
            reason: 'member $i (the unpracticed twin) must be bumped',
          );
        }
        // Only D moves — massing/S/dueAt are other concerns.
        expect(bumped[i].stabilityDays, members[i].stabilityDays);
        expect(bumped[i].pageId, members[i].pageId);
      }
    },
  );

  // Determinism: identical inputs → identical output (no clock, no RNG).
  Glados2<List<Card>, double>(any.confusableGroup, any.confusionWeight).test(
    'applyConfusionBump is pure: identical inputs → identical output',
    (members, weight) {
      final a = applyConfusionBump(members, weight);
      final b = applyConfusionBump(members, weight);
      expect(a.map((c) => c.difficulty), b.map((c) => c.difficulty));
    },
  );
}
