// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:models/models.dart';

import 'constants.dart';
import 'curve.dart';
import 'phases.dart';
import 'review_input.dart';
import 'scheduling_engine.dart';
import 'trust_clamp.dart';

/// The one deterministic review-update path (06 §4; PRD §7.7) and the vendored
/// FSRS-4.5 difficulty/stability branches it runs.
///
/// Every weight read goes through the passed `w` (the engine's
/// `config.weights`), named by its FSRS role at the read site — never an inlined
/// literal. The functions are total: they `assert` (never throw) and always
/// return a value.

/// FSRS initial difficulty `D0(G) = w4 − e^(w5·(G−1)) + 1`, clamped `[1, 10]`.
///
/// `G = grade.index + 1`, so `G − 1 = grade.index`. Harder grades seed a higher
/// difficulty (Again → ~w4; Easy → lowest).
double initialDifficulty(List<double> w, ReviewGrade grade) =>
    (w[4] - exp(w[5] * grade.index) + 1).clamp(1.0, 10.0);

/// FSRS next difficulty: mean-reverts toward the Good anchor `D0(3)`.
///
/// `ΔD = −w6·(G − 3)` (Good is the anchor, `G = 3`), `D' = D + ΔD·(10 − D)/9`
/// (linear damping), then `w7·D0(Good) + (1 − w7)·D'`, clamped `[1, 10]`. Fed
/// the **capped** grade from the sacred-text guard.
double nextDifficulty(List<double> w, double d, ReviewGrade grade) {
  final deltaD = -w[6] * (grade.index + 1 - 3);
  final dPrime = d + deltaD * (10 - d) / 9;
  final reverted =
      w[7] * initialDifficulty(w, ReviewGrade.good) + (1 - w[7]) * dPrime;
  return reverted.clamp(1.0, 10.0);
}

/// FSRS stability after a SUCCESSFUL review (`S'_r`).
///
/// `S·(1 + e^{w8}·(11−D)·S^{−w9}·(e^{w10·(1−R)} − 1)·hard·easy)`, with
/// `hard = w[15]` only on Hard and `easy = w[16]` only on Easy. The `(11−D)`
/// factor is the interference channel: a higher `D` shrinks the gain
/// automatically, so a weak/confusable page returns sooner with no parallel
/// scheduler. The `e^{w10·(1−R)}` term is the desirable-difficulty effect —
/// reviewing when `R` is lower yields a larger gain (CLAIMS C-011, C-012).
double stabilityOnSuccess(
  List<double> w,
  double d,
  double s,
  double r,
  double hard,
  double easy,
) =>
    s *
    (1 +
        exp(w[8]) *
            (11 - d) *
            pow(s, -w[9]) *
            (exp(w[10] * (1 - r)) - 1) *
            hard *
            easy);

/// FSRS stability after a LAPSE (`S'_f`), clamped so a lapse NEVER grows `S`.
///
/// `w11·D^{−w12}·((S+1)^{w13} − 1)·e^{w14·(1−R)}`, then `min(·, S)` so a
/// forgotten page never earns a longer interval than it had, floored at
/// [kMinStability] (06 §4; INV-3).
double postLapseStability(List<double> w, double d, double s, double r) {
  final sf =
      w[11] * pow(d, -w[12]) * (pow(s + 1, w[13]) - 1) * exp(w[14] * (1 - r));
  return min(sf.toDouble(), s).clamp(kMinStability, double.infinity);
}

/// The single graded-review update path on the engine façade.
extension ReviewUpdate on SchedulingEngine {
  /// Applies one graded [review] to [card] with the injected [today], returning
  /// a new [Card] (06 §4; PRD §7.7). Pure: identical inputs → identical output.
  ///
  /// Steps, in fixed order: sacred-text guard (cap at Hard before any math) →
  /// source-confidence scaling (self moves `S` less) → lapse/success split →
  /// weak-line `(11−D)` channel → graduation → trust clamp. [weakLineCount] is
  /// the page's chronically-weak-line tally, **injected** by the caller (E12
  /// from `data`): the pure engine never reads `line_block` rows itself.
  ///
  /// [recentWindow] reports whether a card is in the recent-juz window (the
  /// Near → Far graduation gate); it is injected because the pure engine owns no
  /// juz map. It defaults to "in window" for every card — the conservative
  /// choice that holds a page in the more-frequent Near track until the feature
  /// layer (E11/E14) supplies the real most-recent-juz predicate.
  Card onReview(
    Card card,
    ReviewInput review,
    CalendarDate today, {
    required int weakLineCount,
    bool Function(Card card)? recentWindow,
  }) {
    assert(weakLineCount >= 0, 'weakLineCount is a count, never negative');
    final w = config.weights;
    final elapsed = card.lastReviewedDay == null
        ? 0
        : today.epochDay - card.lastReviewedDay!.epochDay;
    final r = elapsed == 0 ? 1.0 : retrievability(elapsed, card.stabilityDays);

    // Sacred-text guard, BEFORE any arithmetic: a missed/altered word is NEVER
    // Good. R1 — the cap only ever lowers (PRD §7.7).
    final grade = review.missedOrAlteredWord &&
            review.grade.index > ReviewGrade.hard.index
        ? ReviewGrade.hard
        : review.grade;

    // Teacher = ground truth (1.0); self-rating is noisy, so it moves S less.
    final conf = review.source == GradeSource.teacher ? 1.0 : kSelfConfidence;
    var d = nextDifficulty(w, card.difficulty, grade);
    double s;
    var lapses = card.lapses;
    var weak = card.isWeak;

    if (grade == ReviewGrade.again) {
      // ---- lapse branch: demotes, never grows S ----
      lapses += 1;
      d = (d + kLapseDifficultyBump).clamp(1.0, 10.0);
      s = postLapseStability(w, card.difficulty, card.stabilityDays, r);
      weak = true; // data layer may lazily split into line_blocks (E03)
    } else {
      // ---- success branch ----
      final hard = grade == ReviewGrade.hard ? w[15] : 1.0;
      final easy = grade == ReviewGrade.easy ? w[16] : 1.0;
      final raw = stabilityOnSuccess(
        w,
        card.difficulty,
        card.stabilityDays,
        r,
        hard,
        easy,
      );
      // Only the GAIN is confidence-scaled — a noisy self-rating moves S less,
      // never the unchanged base S, never D, never errorLines/weak-line bumps.
      final gain = (raw - card.stabilityDays) * conf;
      s = card.stabilityDays + gain;
      if ((grade == ReviewGrade.good || grade == ReviewGrade.easy) &&
          review.errorLines.isEmpty) {
        weak = false;
      }
    }

    // Weak-line (11−D) channel — full strength regardless of source: an
    // interference/weak-line bump is graph truth, not a confidence-scaled magnitude.
    d = (d + kWeakLineFactor * weakLineCount).clamp(1.0, 10.0);

    final reviewed = card.copyWith(
      difficulty: d,
      stabilityDays: max(s, kMinStability),
      lastReviewedDay: today,
      reps: card.reps + 1,
      lapses: lapses,
      isWeak: weak,
    );
    // Predictable, sign-off-gated graduation (E04-T05), on the post-update card.
    final graduated = updateGraduation(
      reviewed,
      grade,
      review.source,
      inRecentWindow: recentWindow?.call(reviewed) ?? true,
    );
    // The trust clamp (E04-T07): due_at = min(ideal_due, ceiling_due), the
    // EARLIER date — SR may only make a page MORE frequent, never push it past
    // the cycle (PRD §7.6). Runs on the already-graduated card so the ceiling
    // reflects the post-review phaseOf.
    return graduated.copyWith(dueAt: trustClamp(graduated, today));
  }
}
