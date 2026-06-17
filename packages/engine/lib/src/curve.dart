// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'constants.dart';

/// The FSRS-4.5 power-law forgetting curve and its closed-form interval inverse
/// (06 §3) — the arithmetic backbone every later rule multiplies onto.
///
/// The curve is a *prior*, never the guarantee: it is trained on flashcard
/// recognition, not hifz (CLAIMS C-025). What guarantees "nothing decays
/// silently" is the §6 trust clamp (E04-T07), which caps the interval below to
/// the cycle ceiling — not this probability target.

/// The FSRS-4.5 curve decay — the ONLY place it lives (06 §3).
///
/// `kFactor` is **computed** from it so the literals `0.2346`/`19`/`81` appear
/// nowhere; an FSRS-6 adoption is the one-line change `kDecay = -w[20]`.
const double kDecay = -0.5;

/// The FSRS-4.5 curve factor `0.9^(1/kDecay) − 1` (= 19/81 ≈ 0.23456790…).
///
/// Defined so `R(S, S) = 0.9` by construction (a `pow` call cannot be `const`,
/// so this is a top-level `final`). Never written as a literal — it is derived
/// from [kDecay] (06 §3, §8).
final double kFactor = pow(0.9, 1 / kDecay).toDouble() - 1;

/// Probability of recall after [elapsedDays] given stability [s] (days).
///
/// `R(t, S) = (1 + kFactor·t/S)^kDecay`; `R(S, S) = 0.9` by definition of
/// [kFactor]. Takes a pre-computed integer elapsed-days — the caller forms it
/// by `today.epochDay − card.lastReviewedDay.epochDay` (plain integer
/// subtraction, DST-immune) — and reads no clock (06 §3).
double retrievability(int elapsedDays, double s) =>
    pow(1 + kFactor * elapsedDays / s, kDecay).toDouble();

/// Days until recall probability falls to [targetR], given stability [s].
///
/// The closed-form inverse of the curve, **never fuzzed**:
/// `I(r, S) = (S/kFactor)·(r^(1/kDecay) − 1)`, so `I(S, 0.9) = S` exactly at
/// `kDecay = -0.5`. Clamped to `[1, kMaxInterval]`: the floor of `1` is the
/// "no page is ever safe to drop" arithmetic; the ceiling matches the
/// reference clamps. There is no jitter or `Random` here — any declumping is
/// the bounded `loadBalance` peak-smoothing (E04-T09), never hidden RNG
/// (06 §3, §7).
int interval(double s, double targetR) =>
    ((s / kFactor) * (pow(targetR, 1 / kDecay) - 1))
        .round()
        .clamp(1, kMaxInterval);
