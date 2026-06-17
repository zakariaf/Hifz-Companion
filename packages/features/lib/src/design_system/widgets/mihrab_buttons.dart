// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

// Touch floors as tokens (05 §4): 48dp = space8; the grade-band tall variant is
// 56dp = space8 + space2. Colours come from the ColorScheme via M3 defaults.
const _space = SpacingTokens.standard();
final Size _minTouch = Size(_space.space8, _space.space8);
final Size _minTall = Size(_space.space8, _space.space8 + _space.space2);

/// The restrained `FilledButton` theme (design-system 02 §5; 05 §4): the M3
/// `ColorScheme` fill, the Mihrab label style, and a ≥48dp touch floor — no
/// badge, streak, or celebratory state.
FilledButtonThemeData mihrabFilledButtonTheme() => FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: _minTouch),
    );

/// A documented ≥56dp-tall `FilledButton` style for the future grade band
/// (E10) — same restraint, taller touch target (05 §5).
ButtonStyle mihrabTallFilledButtonStyle() =>
    FilledButton.styleFrom(minimumSize: _minTall);

/// The `SegmentedButton` theme — selected/unselected from `ColorScheme` roles,
/// the plain M3 selected indicator (no celebratory glyph), ≥48dp segments.
SegmentedButtonThemeData mihrabSegmentedButtonTheme() =>
    SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(minimumSize: _minTouch),
    );
