// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../widgets/mihrab_buttons.dart';
import 'haptic_tokens.dart';
import 'mihrab_color_schemes.dart';
import 'mihrab_colors.dart';
import 'motion_tokens.dart';
import 'spacing_tokens.dart';

/// Builds the composed `ThemeData` for [appearance] — the audited `ColorScheme`
/// plus the Mihrab [SpacingTokens]/[MihrabColors] extensions and the UI type
/// ramp. (Bundled Vazirmatn/Estedad faces are E06-T04; this interim ramp uses
/// the platform UI font so the appearance/layout can be reviewed first.)
ThemeData mihrabThemeFor(MihrabAppearance appearance) {
  final scheme = colorSchemeFor(appearance);
  final text = _mihrabTextTheme(scheme);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text,
    extensions: <ThemeExtension<dynamic>>[
      const SpacingTokens.standard(),
      const MotionTokens.standard(),
      const HapticTokens.standard(),
      mihrabColorsFor(appearance),
    ],
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    filledButtonTheme: mihrabFilledButtonTheme(),
    segmentedButtonTheme: mihrabSegmentedButtonTheme(),
  );
}

// The line-height ~1.5 ramp (04 §6), zero letter-spacing. Colours come from the
// scheme; the bundled-font family is wired in E06-T04.
TextTheme _mihrabTextTheme(ColorScheme scheme) {
  const height = 1.5;
  const base = TextTheme(
    displaySmall: TextStyle(
      fontSize: 30,
      height: 1.25,
      letterSpacing: 0,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: height,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      height: height,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: height, letterSpacing: 0),
    bodyMedium: TextStyle(fontSize: 15, height: height, letterSpacing: 0),
    labelLarge: TextStyle(
      fontSize: 14,
      height: height,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(fontSize: 12.5, height: height, letterSpacing: 0),
    bodySmall: TextStyle(fontSize: 12.5, height: height, letterSpacing: 0),
  );
  return base.apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );
}

MihrabColors mihrabColorsFor(MihrabAppearance appearance) =>
    switch (appearance) {
      MihrabAppearance.light => _lightColors,
      MihrabAppearance.sepia => _sepiaColors,
      MihrabAppearance.dark => _darkColors,
      MihrabAppearance.night => _nightColors,
    };

// Heat-map ramp + bespoke tints per 03 §5/§6. (T02/T03/T10 finalise + audit.)
const _lightColors = MihrabColors(
  heatmapStrong: Color(0xFF1B8A5A),
  heatmapGood: Color(0xFF49A074),
  heatmapFair: Color(0xFF93BFA6),
  heatmapWeak: Color(0xFFB9C3BC),
  heatmapFaded: Color(0xFFD2D8D2),
  trackChipSurface: Color(0xFFDCE6DF),
  trackChipText: Color(0xFF46514B),
  decayCalm: Color(0xFFB9C3BC),
  readerSurfaceSepia: Color(0xFFF3EAD8),
  readerSurfaceNight: Color(0xFF14110C),
  semanticWarning: Color(0xFF8A5A00),
  accentGold: Color(0xFFA57F33),
  textTertiary: Color(0xFF5C665F),
);

const _sepiaColors = MihrabColors(
  heatmapStrong: Color(0xFF1B8A5A),
  heatmapGood: Color(0xFF49A074),
  heatmapFair: Color(0xFF93BFA6),
  heatmapWeak: Color(0xFFC4BBA6),
  heatmapFaded: Color(0xFFE0D6BF),
  trackChipSurface: Color(0xFFE9DEC6),
  trackChipText: Color(0xFF5A5042),
  decayCalm: Color(0xFFC4BBA6),
  readerSurfaceSepia: Color(0xFFF3EAD8),
  readerSurfaceNight: Color(0xFF14110C),
  semanticWarning: Color(0xFF8A5A00),
  accentGold: Color(0xFF9A742B),
  textTertiary: Color(0xFF6E6353),
);

const _darkColors = MihrabColors(
  heatmapStrong: Color(0xFF58C495),
  heatmapGood: Color(0xFF418C6A),
  heatmapFair: Color(0xFF356B55),
  heatmapWeak: Color(0xFF38453E),
  heatmapFaded: Color(0xFF262B27),
  trackChipSurface: Color(0xFF2A322D),
  trackChipText: Color(0xFFA7B0A8),
  decayCalm: Color(0xFF38453E),
  readerSurfaceSepia: Color(0xFFF3EAD8),
  readerSurfaceNight: Color(0xFF14110C),
  semanticWarning: Color(0xFFE8B23C),
  accentGold: Color(0xFFD8BC7E),
  textTertiary: Color(0xFF828B83),
);

const _nightColors = MihrabColors(
  heatmapStrong: Color(0xFF85C398),
  heatmapGood: Color(0xFF619A72),
  heatmapFair: Color(0xFF466B52),
  heatmapWeak: Color(0xFF3A352A),
  heatmapFaded: Color(0xFF241F16),
  trackChipSurface: Color(0xFF2A2419),
  trackChipText: Color(0xFFA89A80),
  decayCalm: Color(0xFF3A352A),
  readerSurfaceSepia: Color(0xFFF3EAD8),
  readerSurfaceNight: Color(0xFF14110C),
  semanticWarning: Color(0xFFE8B23C),
  accentGold: Color(0xFFD8BC7E),
  textTertiary: Color(0xFF8A7C62),
);
