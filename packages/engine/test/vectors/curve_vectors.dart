// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Frozen golden vectors for the FSRS-4.5 curve and interval (06 §3, §8). Every
// expected value is computed ONCE from the FSRS *definition* (the curve/interval
// closed-form identities), NEVER from the engine under test — a fixture must not
// agree with a bug (eng-write-engine-golden-vector pattern 8). Regenerated only
// by a reviewed change; CI only verifies.

/// One frozen retrievability anchor: `R(elapsed, s)` and its expected value.
class RetrievabilityVector {
  /// Constructs an anchor row.
  const RetrievabilityVector(this.elapsed, this.s, this.expected, this.notes);

  /// Elapsed days since the last review.
  final int elapsed;

  /// Stability `S` in days.
  final double s;

  /// The retrievability the FSRS curve identity gives for `(elapsed, s)`.
  final double expected;

  /// Why this row exists / its source-of-truth identity.
  final String notes;
}

/// One frozen interval anchor: `I(s, targetR)` and its expected integer days.
class IntervalVector {
  /// Constructs an anchor row.
  const IntervalVector(this.s, this.targetR, this.expected, this.notes);

  /// Stability `S` in days.
  final double s;

  /// The target recall probability the interval is solved for.
  final double targetR;

  /// The integer day interval the FSRS closed form gives, after `.round()`.
  final int expected;

  /// Why this row exists / its source-of-truth identity.
  final String notes;
}

/// The curve anchors: `R(S, S) = 0.9` holds for *every* `S` because `kFactor`
/// is computed from `kDecay` (not a single mid-curve point).
const retrievabilityVectors = <RetrievabilityVector>[
  RetrievabilityVector(10, 10.0, 0.9, 'R(S,S)=0.9 by definition of kFactor'),
  RetrievabilityVector(60, 60.0, 0.9, 'holds for all S, not one'),
];

/// The interval anchors. `I(S, 0.9) = S` exactly; the higher tiers shrink the
/// interval by the §3 closed-form multiplier.
///
/// NOTE on the 0.95 row: engineering 06 §8 quotes `45 (≈ 0.448·S)`, but the
/// exact `kFactor = 19/81` form gives a multiplier of `0.46056…`, so
/// `I(100, 0.95) = round(46.056) = 46`. The doc's `0.448`/`45` is an
/// approximation slip; the FSRS *definition* (the mandated oracle) is `46`.
const intervalVectors = <IntervalVector>[
  IntervalVector(10.0, 0.9, 10, 'I(S,0.9)=S at kDecay=-0.5'),
  IntervalVector(60.0, 0.9, 60, 'I(S,0.9)=S, second S'),
  IntervalVector(100.0, 0.95, 46, 'Far ordinary tier; 0.46056·S → 46'),
  IntervalVector(100.0, 0.97, 27, 'Far weak/critical tier; 0.26778·S → 27'),
];
