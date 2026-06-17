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

final ColorScheme _lightScheme = _seeded(Brightness.light).copyWith(
  surface: const Color(0xFFF3F6F1),
  surfaceContainer: const Color(0xFFE7ECE4),
  onSurface: const Color(0xFF1A211E),
  onSurfaceVariant: const Color(0xFF46514B),
  primary: const Color(0xFF1F6E5A),
  onPrimary: const Color(0xFFFFFFFF),
);

final ColorScheme _sepiaScheme = _seeded(Brightness.light).copyWith(
  surface: const Color(0xFFF3EAD8),
  surfaceContainer: const Color(0xFFE9DEC6),
  onSurface: const Color(0xFF2B2620),
  onSurfaceVariant: const Color(0xFF5A5042),
  primary: const Color(0xFF1C6450),
  onPrimary: const Color(0xFFFFFFFF),
);

final ColorScheme _darkScheme = _seeded(Brightness.dark).copyWith(
  surface: const Color(0xFF121413),
  surfaceContainer: const Color(0xFF1E211F),
  onSurface: const Color(0xFFE6EAE3),
  onSurfaceVariant: const Color(0xFFA7B0A8),
  primary: const Color(0xFF6FC2A8),
  onPrimary: const Color(0xFF0C140F),
);

final ColorScheme _nightScheme = _seeded(Brightness.dark).copyWith(
  surface: const Color(0xFF14110C),
  surfaceContainer: const Color(0xFF221C13),
  onSurface: const Color(0xFFD8CBB2),
  onSurfaceVariant: const Color(0xFFA89A80),
  primary: const Color(0xFF7FB48C),
  onPrimary: const Color(0xFF0C140F),
);
