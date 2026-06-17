// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// A frozen placeholder standing in for the engine's future
/// `(state, grade, elapsed) -> (difficulty, stability, due)` golden-vector
/// output.
///
/// It is total — it returns a value for every (no) input and never throws —
/// mirroring the engine contract E04 implements. E04 replaces it with the real
/// FSRS-style arithmetic and its frozen vectors; the `closeTo(_, 1e-6)` test
/// slot in `engine_placeholder_test.dart` already exists to receive them.
double frozenStabilityPlaceholder() => 1.0;
