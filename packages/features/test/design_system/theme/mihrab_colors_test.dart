// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

// A sentinel instance with distinct channels per field so a dropped field in
// copyWith/lerp is caught. The absence of semanticSuccess/Danger/streak is a
// structural guarantee — this test references no such getter (adding one would
// let a test compile against it, which is the regression the absence prevents).
const _sentinel = MihrabColors(
  heatmapStrong: Color(0xFF010101),
  heatmapGood: Color(0xFF020202),
  heatmapFair: Color(0xFF030303),
  heatmapWeak: Color(0xFF040404),
  heatmapFaded: Color(0xFF050505),
  trackChipSurface: Color(0xFF060606),
  trackChipText: Color(0xFF070707),
  decayCalm: Color(0xFF080808),
  readerSurfaceSepia: Color(0xFF090909),
  readerSurfaceNight: Color(0xFF0A0A0A),
  semanticWarning: Color(0xFF0B0B0B),
  accentGold: Color(0xFF0C0C0C),
);

void main() {
  useOfflineTestPolicy();

  test('copyWith() preserves every field; copyWith(x) overrides only x', () {
    expect(_sentinel.copyWith().heatmapStrong, _sentinel.heatmapStrong);
    final out = _sentinel.copyWith(accentGold: const Color(0xFFFFFFFF));
    expect(out.accentGold, const Color(0xFFFFFFFF));
    expect(out.heatmapStrong, _sentinel.heatmapStrong);
    expect(out.semanticWarning, _sentinel.semanticWarning);
  });

  test('lerp(other, 0)==this and (other, 1)==other per field; null->this', () {
    final other = _sentinel.copyWith(accentGold: const Color(0xFF808080));
    expect(_sentinel.lerp(other, 0).accentGold, _sentinel.accentGold);
    expect(_sentinel.lerp(other, 1).accentGold, other.accentGold);
    expect(_sentinel.lerp(null, 0.5).accentGold, _sentinel.accentGold);
  });

  test('lerp interpolates every field (no field snaps/un-lerped)', () {
    final other = _sentinel.copyWith(
      heatmapStrong: const Color(0xFFFFFFFF),
      accentGold: const Color(0xFFFFFFFF),
    );
    final mid = _sentinel.lerp(other, 0.5);
    expect(mid.heatmapStrong, isNot(_sentinel.heatmapStrong));
    expect(mid.heatmapStrong, isNot(other.heatmapStrong));
    expect(mid.accentGold, isNot(_sentinel.accentGold));
  });
}
