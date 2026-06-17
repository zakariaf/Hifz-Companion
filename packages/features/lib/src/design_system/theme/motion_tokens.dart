// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The Mihrab motion vocabulary — short/medium durations and the standard
/// easing curve, read through `Theme.of(context).extension<MotionTokens>()`
/// (design-system 06 §1).
///
/// There is deliberately **no** celebrate/long/emphasized tier: routine UI uses
/// only short and medium rungs, and no confetti/"success" animation exists to
/// reach for (06 §2). The absence is the enforcement.
@immutable
class MotionTokens extends ThemeExtension<MotionTokens> {
  /// Creates a motion set from explicit values.
  const MotionTokens({
    required this.durationShort,
    required this.durationMedium,
    required this.curveStandard,
  });

  /// The audited Mihrab motion set (06 §1): 150ms / 250ms / `fastOutSlowIn`.
  const MotionTokens.standard()
      : durationShort = const Duration(milliseconds: 150),
        durationMedium = const Duration(milliseconds: 250),
        curveStandard = Curves.fastOutSlowIn;

  /// 150ms — small state changes (selection, a chip toggle).
  final Duration durationShort;

  /// 250ms — a card/sheet enter, a tab change.
  final Duration durationMedium;

  /// The standard easing curve for routine transitions.
  final Curve curveStandard;

  @override
  MotionTokens copyWith({
    Duration? durationShort,
    Duration? durationMedium,
    Curve? curveStandard,
  }) {
    return MotionTokens(
      durationShort: durationShort ?? this.durationShort,
      durationMedium: durationMedium ?? this.durationMedium,
      curveStandard: curveStandard ?? this.curveStandard,
    );
  }

  @override
  MotionTokens lerp(ThemeExtension<MotionTokens>? other, double t) {
    if (other is! MotionTokens) return this;
    return MotionTokens(
      durationShort: _lerpDuration(durationShort, other.durationShort, t),
      durationMedium: _lerpDuration(durationMedium, other.durationMedium, t),
      // A Curve does not meaningfully interpolate; threshold-switch at the
      // midpoint so the transition still ends on the target curve.
      curveStandard: t < 0.5 ? curveStandard : other.curveStandard,
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) => Duration(
        microseconds:
            lerpDouble(a.inMicroseconds, b.inMicroseconds, t)!.round(),
      );
}
