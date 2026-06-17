// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Frozen golden vectors for the onReview S/D update (06 §4, §8). Each row's
// (dOut, sOut) was computed ONCE from the FSRS-4.5 definition with
// kDefaultWeights45 (an independent standalone oracle implementing the §4
// formulas), NEVER by calling the engine's onReview — a fixture must not agree
// with a bug (eng-write-engine-golden-vector pattern 8). All rows share
// dIn=5.0, sIn=30.0, elapsed=30 (so R = retrievability(30,30) = 0.9 exactly),
// source=teacher (conf=1.0), errorLines=[], weakLineCount=0.

import 'package:engine/engine.dart' show ReviewGrade;

/// One frozen review-update row: (input D/S, grade, elapsed) → (expected D, S).
class FsrsVector {
  /// Constructs a frozen row.
  const FsrsVector(
    this.dIn,
    this.sIn,
    this.grade,
    this.elapsed,
    this.dOut,
    this.sOut,
    this.notes,
  );

  /// Difficulty before the review.
  final double dIn;

  /// Stability before the review (days).
  final double sIn;

  /// The grade applied.
  final ReviewGrade grade;

  /// Elapsed days since the last review.
  final int elapsed;

  /// Difficulty the FSRS update gives.
  final double dOut;

  /// Stability the FSRS update gives (days).
  final double sOut;

  /// Why this row exists.
  final String notes;
}

/// The branch-coverage vectors: success grows S; Hard < Good < Easy; a lapse
/// shrinks S far below the prior and bumps D.
const reviewUpdateVectors = <FsrsVector>[
  FsrsVector(
    5.0,
    30.0,
    ReviewGrade.good,
    30,
    5.001299198342667,
    90.41040860466238,
    'on-time Good grows S',
  ),
  FsrsVector(
    5.0,
    30.0,
    ReviewGrade.hard,
    30,
    5.808900398342668,
    43.98500959197934,
    'Hard w[15]: S < the Good row',
  ),
  FsrsVector(
    5.0,
    30.0,
    ReviewGrade.easy,
    30,
    4.193697998342667,
    210.61503964621957,
    'Easy w[16]: S > the Good row',
  ),
  FsrsVector(
    5.0,
    30.0,
    ReviewGrade.again,
    30,
    7.616501598342667,
    3.5962166400202826,
    'lapse: post-lapse S <= prior, D += bump',
  ),
];
