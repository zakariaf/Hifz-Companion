// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';

// The WCAG 2.2 relative-luminance constants — named, never magic (the audit
// re-derives ratios from these, design-system 03 §7; W3C WCAG 2.2).
const double _linearThreshold = 0.03928;
const double _gammaOffset = 0.055;
const double _gammaScale = 1.055;
const double _gammaExponent = 2.4;
const double _lowSlope = 12.92;
const double _weightRed = 0.2126;
const double _weightGreen = 0.7152;
const double _weightBlue = 0.0722;
const double _ambient = 0.05; // the +0.05 flare term in the ratio

double _linearize(double channel) => channel <= _linearThreshold
    ? channel / _lowSlope
    : math
        .pow((channel + _gammaOffset) / _gammaScale, _gammaExponent)
        .toDouble();

/// The WCAG 2.2 relative luminance of [color] in `[0, 1]` (0 black, 1 white).
double relativeLuminance(Color color) {
  final r = _linearize(color.r);
  final g = _linearize(color.g);
  final b = _linearize(color.b);
  return _weightRed * r + _weightGreen * g + _weightBlue * b;
}

/// The WCAG 2.2 contrast ratio between [a] and [b] in `[1, 21]`.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + _ambient) / (lo + _ambient);
}
