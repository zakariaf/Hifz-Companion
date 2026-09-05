// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// The one calm, desaturated Quran-green every Mihrab appearance is seeded from
/// (design-system 03 §1/§2). There is no per-appearance seed and no dynamic
/// (wallpaper) colour — this is the floor and the ceiling of the palette.
const Color mihrabSeedGreen = Color(0xFF1F6E5A);

/// The standard contrast level for `ColorScheme.fromSeed` (low-vision tuning is
/// a single edit here, not a magic literal at each call site).
const double contrastLevelStandard = 0.0;

/// A reading appearance — the concrete palette in effect (03 §3).
enum MihrabAppearance {
  /// Positive-polarity daytime default (dark text on light surface).
  light,

  /// Warm-paper, positive polarity — softens blue-white glare.
  sepia,

  /// Light-on-off-black for low light / OS dark; never pure black.
  dark,

  /// Dark warmed and luminance-reduced for comfort. No sleep claim.
  night,
}

/// The brightness each appearance renders at.
extension MihrabAppearanceBrightness on MihrabAppearance {
  /// `Brightness.light` for [light]/[sepia], `Brightness.dark` otherwise.
  Brightness get brightnessOf => switch (this) {
        MihrabAppearance.light || MihrabAppearance.sepia => Brightness.light,
        MihrabAppearance.dark || MihrabAppearance.night => Brightness.dark,
      };
}

/// The user's appearance choice. [followSystem] is a distinct state from the
/// explicit [light]/[dark]; Sepia and Night are explicit overrides (03 §3).
enum AppearanceSetting {
  /// Follow the OS light/dark setting (the default).
  followSystem,

  /// Always Light.
  light,

  /// Always Sepia.
  sepia,

  /// Always Dark.
  dark,

  /// Always Night.
  night,
}

/// The default appearance setting — respect the OS (03 §3).
const AppearanceSetting defaultAppearanceSetting =
    AppearanceSetting.followSystem;

/// Resolves the active [MihrabAppearance] from the user [setting] and the
/// injected [platformBrightness] — pure, reads no `MediaQuery` and no clock.
MihrabAppearance resolveAppearance(
  AppearanceSetting setting,
  Brightness platformBrightness,
) {
  return switch (setting) {
    AppearanceSetting.followSystem => platformBrightness == Brightness.light
        ? MihrabAppearance.light
        : MihrabAppearance.dark,
    AppearanceSetting.light => MihrabAppearance.light,
    AppearanceSetting.sepia => MihrabAppearance.sepia,
    AppearanceSetting.dark => MihrabAppearance.dark,
    AppearanceSetting.night => MihrabAppearance.night,
  };
}

/// The audited `ColorScheme` for [appearance] (roles pinned to 03 §7).
ColorScheme colorSchemeFor(MihrabAppearance appearance) => switch (appearance) {
      MihrabAppearance.light => _lightScheme,
      MihrabAppearance.sepia => _sepiaScheme,
      MihrabAppearance.dark => _darkScheme,
      MihrabAppearance.night => _nightScheme,
    };

// Each scheme starts from the one seed (keeping `tonalSpot`), then pins the
// audited roles from 03 §7. This file is the single sanctioned hex site.

// The named `contrastLevel` is passed explicitly so low-vision tuning is one
// edit here; at the default 0.0 the analyzer's redundant-value lint is waived.
ColorScheme _seeded(Brightness brightness) => ColorScheme.fromSeed(
      seedColor: mihrabSeedGreen,
      brightness: brightness,
      // ignore: avoid_redundant_argument_values
      contrastLevel: contrastLevelStandard,
    );

// Mihrab-architecture appearance (owner-directed design amendment): a limestone
// plaster surface, glazed-teal primary, and a deep tile-shadow ink — the palette
// of a serene tiled mosque (concept 03). Every text/accent role is tuned to clear
// the WCAG 2.2 AA floors re-audited in 03 §7 (the teal is deepened from the
// concept's #1F7A6D so it holds 4.5:1 as chip/label text on the limestone).
final ColorScheme _lightScheme = _seeded(Brightness.light).copyWith(
  // Plain redesign (2026-09-05 owner amendment): a neutral near-white ground,
  // white cards, one hairline, one accent. No ornament tokens are read.
  surface: const Color(0xFFF4F4F2),
  surfaceContainer: const Color(0xFFFFFFFF),
  surfaceContainerLow: const Color(0xFFFFFFFF),
  surfaceContainerHigh: const Color(0xFFFFFFFF),
  surfaceContainerHighest: const Color(0xFFEFEFEC),
  onSurface: const Color(0xFF1A1C1B),
  onSurfaceVariant: const Color(0xFF6B6F6D),
  outline: const Color(0xFFC9CBC8),
  outlineVariant: const Color(0xFFE6E6E2),
  primary: const Color(0xFF157A63),
  onPrimary: const Color(0xFFFFFFFF),
  primaryContainer: const Color(0xFFE3F1EC),
  onPrimaryContainer: const Color(0xFF0F4F40),
  secondaryContainer: const Color(0xFFEEF0EE),
  onSecondaryContainer: const Color(0xFF3A423F),
  tertiaryContainer: const Color(0xFFF0EFEA),
  onTertiaryContainer: const Color(0xFF4A473F),
);

final ColorScheme _sepiaScheme = _seeded(Brightness.light).copyWith(
  // Plain redesign: warm paper ground, near-white cards, one hairline.
  surface: const Color(0xFFF6F1E7),
  surfaceContainer: const Color(0xFFFFFCF6),
  surfaceContainerLow: const Color(0xFFFFFCF6),
  surfaceContainerHigh: const Color(0xFFFFFCF6),
  surfaceContainerHighest: const Color(0xFFEFE8DA),
  onSurface: const Color(0xFF2B2620),
  onSurfaceVariant: const Color(0xFF6E6353),
  outlineVariant: const Color(0xFFE6DFD0),
  primary: const Color(0xFF166650),
  onPrimary: const Color(0xFFFFFFFF),
  primaryContainer: const Color(0xFFE0EEE6),
  onPrimaryContainer: const Color(0xFF0F4F40),
  secondaryContainer: const Color(0xFFF0EBE0),
  onSecondaryContainer: const Color(0xFF4A4438),
);

final ColorScheme _darkScheme = _seeded(Brightness.dark).copyWith(
  // Plain redesign: off-black ground, one step lighter cards, one hairline.
  surface: const Color(0xFF121413),
  surfaceContainer: const Color(0xFF1E211F),
  surfaceContainerLow: const Color(0xFF1E211F),
  surfaceContainerHigh: const Color(0xFF1E211F),
  surfaceContainerHighest: const Color(0xFF2A2E2C),
  onSurface: const Color(0xFFE6EAE3),
  onSurfaceVariant: const Color(0xFFA7B0A8),
  outlineVariant: const Color(0xFF2E3230),
  primary: const Color(0xFF6FC2A8),
  onPrimary: const Color(0xFF0C140F),
  primaryContainer: const Color(0xFF1F3D34),
  onPrimaryContainer: const Color(0xFFBFE6D8),
  secondaryContainer: const Color(0xFF262A28),
  onSecondaryContainer: const Color(0xFFC9D0CB),
);

final ColorScheme _nightScheme = _seeded(Brightness.dark).copyWith(
  // Plain redesign: warm-dim ground, one step lighter cards, one hairline.
  surface: const Color(0xFF14110C),
  surfaceContainer: const Color(0xFF221C13),
  surfaceContainerLow: const Color(0xFF221C13),
  surfaceContainerHigh: const Color(0xFF221C13),
  surfaceContainerHighest: const Color(0xFF2E271B),
  onSurface: const Color(0xFFD8CBB2),
  onSurfaceVariant: const Color(0xFFA89A80),
  outlineVariant: const Color(0xFF332C20),
  primary: const Color(0xFF7FB48C),
  onPrimary: const Color(0xFF0C140F),
  primaryContainer: const Color(0xFF233A2A),
  onPrimaryContainer: const Color(0xFFCFE3C8),
  secondaryContainer: const Color(0xFF2A241A),
  onSecondaryContainer: const Color(0xFFCFC3A8),
);
