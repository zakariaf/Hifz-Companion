// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The engine's scalar constants and FSRS weight vector, in exactly one place
/// (06 §8). Every scheduling call site references these **by name** — a literal
/// `36500`/`0.5`/`0.15` at a call site is a review failure (eng-write-engine-
/// golden-vector pattern 10) — so an FSRS-6 bump is one reviewed re-freeze.
///
/// `kDecay`/`kFactor` deliberately do **not** live here — they are the curve
/// constants in `curve.dart`, kept computed so FSRS-6 is the one-line
/// `kDecay = -w[20]` change. This file holds plain `const` data and imports
/// nothing.
///
/// E04-T03 seeds this with the two constants `curve.dart` references
/// (`kMaxInterval`, `kFsrsWeightCount`); E04-T05 adds the phase/retention
/// thresholds and E04-T10 adds the FSRS tunables and `kDefaultWeights45`.
library;

/// Number of FSRS weights this engine expects: 19 for FSRS-4.5/5; 21 for
/// FSRS-6 (which adds `w19` and the trainable curve decay `w20`).
///
/// The weight vector's length is asserted `== this` at construction (06 §8): a
/// 19-vs-21 mismatch must fail **loudly**, not silently mis-schedule every
/// interval. The FSRS-6 path is `kDecay = -w[20]` in `curve.dart`, this count
/// → 21, and a reviewed re-freeze of `kDefaultWeights45` — no structural change.
const int kFsrsWeightCount = 19;

/// Interval ceiling in days (~100 years) — matches the reference scheduler
/// clamps. `interval(...)` (E04-T03) clamps its result to `[1, kMaxInterval]`,
/// so a near-perfect page still returns `≥ 1` day: no arithmetic path can ever
/// imply a page is "safe to drop" (06 §3, §8; PRD §7.12).
const int kMaxInterval = 36500;
