// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The five steps of the single-hue retention ramp (design-system 08 §2) —
/// **ordered by lightness, not hue**, so the magnitude survives grayscale and
/// colour-vision deficiency. Maps 1:1 to `color.heatmap.{strong..faded}`.
///
/// Display-blind: the engine's `card.R → HeatLevel` classification and the juz
/// min-leaning roll-up are computed upstream (E04/E15), never in the leaf.
enum HeatLevel {
  /// Strongest retention — the calm base green, the dark end of the ramp.
  strong,

  /// Good retention — a step lighter.
  good,

  /// Fair retention — the mid step.
  fair,

  /// Weak retention — a muted, desaturated step.
  weak,

  /// Faded — the lightest muted neutral (never-recited / most-decayed); quiet,
  /// never injured, never red.
  faded,
}
