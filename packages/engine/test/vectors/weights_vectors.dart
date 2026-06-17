// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The frozen, independent oracle for the FSRS-4.5 default weight vector (06 §8).
//
// These 19 values are the published FSRS-4.5 default weights (w0…w18), sourced
// from the FSRS reference documentation cited in engineering 06 §8 (the FSRS
// "Algorithm" wiki / py-fsrs / Borretti) — NOT copied from the engine's own
// kDefaultWeights45. The two live in separate files as separate literals, so a
// single mistyped weight in either fails the element-wise check in
// constants_test.dart. We do not add a `dart-fsrs` dev-dependency for this:
// a new dependency needs a tech-decision-log amendment, the engine spec only
// wants dart-fsrs read "as a cross-check oracle," and the published vector
// frozen as committed data is an equally independent, offline oracle.

/// The published FSRS-4.5 default weight vector, frozen as the independent
/// oracle constants_test.dart pins `kDefaultWeights45` against.
const oracleDefaultWeights45 = <double>[
  0.40255, // w0  — initial stability, Again
  1.18385, // w1  — initial stability, Hard
  3.173, //   w2  — initial stability, Good
  15.69105, // w3 — initial stability, Easy
  7.1949, //  w4  — initial difficulty base
  0.5345, //  w5  — initial difficulty decay
  1.4604, //  w6  — difficulty delta per grade
  0.0046, //  w7  — difficulty mean-reversion
  1.54575, // w8  — stability-growth scale
  0.1192, //  w9  — stability-growth stability exponent
  1.01925, // w10 — stability-growth retrievability term
  1.9395, //  w11 — post-lapse stability scale
  0.11, //    w12 — post-lapse difficulty exponent
  0.29605, // w13 — post-lapse stability exponent
  2.2698, //  w14 — post-lapse retrievability term
  0.2315, //  w15 — Hard penalty multiplier
  2.9898, //  w16 — Easy bonus multiplier
  0.51655, // w17 — same-day stability (unused — maintenance reviews once/day)
  0.6621, //  w18 — same-day stability (unused)
];
