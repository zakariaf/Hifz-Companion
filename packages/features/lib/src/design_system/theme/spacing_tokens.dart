// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The Mihrab spacing scale — a 4dp-step-on-an-8dp-grid set of distances, read
/// only through `Theme.of(context).extension<SpacingTokens>()` so no widget
/// hardcodes a raw dp (design-system 05 §1).
@immutable
class SpacingTokens extends ThemeExtension<SpacingTokens> {
  /// Creates a spacing set from explicit step values.
  const SpacingTokens({
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.space7,
    required this.space8,
  });

  /// The audited Mihrab scale (05 §1): 4 · 8 · 12 · 16 · 20 · 24 · 32 · 48 dp.
  const SpacingTokens.standard()
      : space1 = 4,
        space2 = 8,
        space3 = 12,
        space4 = 16,
        space5 = 20,
        space6 = 24,
        space7 = 32,
        space8 = 48;

  /// 4dp — hairline gaps between tightly related glyphs/marks.
  final double space1;

  /// 8dp — the minimum gap between two touch targets.
  final double space2;

  /// 12dp — dense list-row inner spacing.
  final double space3;

  /// 16dp — default card/sheet padding and the compact screen edge margin.
  final double space4;

  /// 20dp — comfortable separation between grouped blocks.
  final double space5;

  /// 24dp — section spacing.
  final double space6;

  /// 32dp — major section breaks.
  final double space7;

  /// 48dp — the minimum interactive touch-target size.
  final double space8;

  @override
  SpacingTokens copyWith({
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
    double? space6,
    double? space7,
    double? space8,
  }) {
    return SpacingTokens(
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      space7: space7 ?? this.space7,
      space8: space8 ?? this.space8,
    );
  }

  @override
  SpacingTokens lerp(ThemeExtension<SpacingTokens>? other, double t) {
    if (other is! SpacingTokens) return this;
    return SpacingTokens(
      space1: lerpDouble(space1, other.space1, t) ?? space1,
      space2: lerpDouble(space2, other.space2, t) ?? space2,
      space3: lerpDouble(space3, other.space3, t) ?? space3,
      space4: lerpDouble(space4, other.space4, t) ?? space4,
      space5: lerpDouble(space5, other.space5, t) ?? space5,
      space6: lerpDouble(space6, other.space6, t) ?? space6,
      space7: lerpDouble(space7, other.space7, t) ?? space7,
      space8: lerpDouble(space8, other.space8, t) ?? space8,
    );
  }
}
