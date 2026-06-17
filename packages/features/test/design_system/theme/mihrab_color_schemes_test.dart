// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('pinned roles equal the 03 §7 audited hexes', () {
    test('Light', () {
      final s = colorSchemeFor(MihrabAppearance.light);
      expect(s.brightness, Brightness.light);
      expect(s.surface, const Color(0xFFF3F6F1));
      expect(s.onSurface, const Color(0xFF1A211E));
      expect(s.primary, const Color(0xFF18745A));
    });

    test('Dark uses off-black surface and the re-toned accent', () {
      final s = colorSchemeFor(MihrabAppearance.dark);
      expect(s.brightness, Brightness.dark);
      expect(s.surface, const Color(0xFF121413));
      expect(s.surface, isNot(const Color(0xFF000000))); // never pure black
      expect(s.primary, const Color(0xFF6FC2A8)); // lighter, non-vibrating
    });

    test('Night is warm-dim, never pure black', () {
      final s = colorSchemeFor(MihrabAppearance.night);
      expect(s.surface, const Color(0xFF14110C));
      expect(s.surface, isNot(const Color(0xFF000000)));
    });
  });

  group('appearance resolver is pure and total', () {
    test('follow-system maps by platform brightness', () {
      expect(
        resolveAppearance(AppearanceSetting.followSystem, Brightness.light),
        MihrabAppearance.light,
      );
      expect(
        resolveAppearance(AppearanceSetting.followSystem, Brightness.dark),
        MihrabAppearance.dark,
      );
    });

    test('explicit overrides win regardless of platform brightness', () {
      for (final b in Brightness.values) {
        expect(
          resolveAppearance(AppearanceSetting.sepia, b),
          MihrabAppearance.sepia,
        );
        expect(
          resolveAppearance(AppearanceSetting.night, b),
          MihrabAppearance.night,
        );
      }
    });

    test('the default setting follows the system', () {
      expect(defaultAppearanceSetting, AppearanceSetting.followSystem);
    });

    test('brightnessOf / colorSchemeFor are total for every appearance', () {
      for (final a in MihrabAppearance.values) {
        expect(a.brightnessOf, isNotNull);
        expect(colorSchemeFor(a), isNotNull);
      }
    });
  });
}
