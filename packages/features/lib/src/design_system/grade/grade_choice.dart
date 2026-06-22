// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The four-level self-grade a [GradeBand] emits (design-system 07 §5).
///
/// Display-blind: the engine's `G = 1..4` mapping and the sacred-text grade guard
/// live in E04/E12, never in the leaf — the band is a dumb four-choice control.
enum GradeChoice {
  /// Needed help — not yet recalled (the calm "review again soon" verdict).
  again,

  /// Minor mistakes / slow-but-correct — not yet automatic.
  hard,

  /// Recited clean.
  good,

  /// Effortless — automaticity (C-024); never "mastered"/"safe to drop".
  easy,
}
