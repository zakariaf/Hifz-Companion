// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'constants.dart';

/// Confusion-aware grading: a logged wrong-branch swap raises `Difficulty` on
/// **every** member of the confusable group (PRD §9.2; science 05 §4; CLAIMS
/// C-029).
///
/// Drilling/strengthening one twin alone *suppresses* the unpracticed twin
/// (retrieval-induced forgetting), so the bump is a property of the **group**,
/// not the recited node: it maps over all [groupMembers]. Each member's `D` rises
/// by `kConfusionDifficultyBump × confusionWeight`, clamped to `[1, 10]`. Because
/// the FSRS `stabilityOnSuccess` equation carries the `(11−D)` factor, the higher
/// `D` automatically yields a smaller stability gain — and therefore a shorter
/// interval — at each member's next review. The shorter interval comes **only**
/// from that existing channel: this function changes `D` and nothing else (it
/// touches no `S`/`dueAt`, runs no FSRS curve, adds no bespoke override), so it
/// is **not** a second scheduler.
///
/// Full strength regardless of source: there is no source/confidence parameter —
/// a self-reported swap bumps `D` identically to a teacher-flagged one;
/// `sourceConfidence` scales only the stability move in `onReview`, untouched
/// here (06 §4). Pure and deterministic: identical inputs → identical output,
/// stable member order preserved, no clock and no randomness.
///
/// [confusionWeight] is the pair's logged `confusion_edge.weight` (grown only
/// from the user's own swaps; E14-T03) — a non-negative, bounded bookkeeping
/// value, never inferred or trained. A weight of `0` (or an empty group) is the
/// identity.
List<Card> applyConfusionBump(List<Card> groupMembers, double confusionWeight) {
  assert(confusionWeight >= 0, 'a confusion weight is never negative');
  final delta = kConfusionDifficultyBump * confusionWeight;
  return [
    for (final card in groupMembers)
      card.copyWith(
        difficulty: (card.difficulty + delta).clamp(1.0, 10.0),
      ),
  ];
}
