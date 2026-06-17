// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('MotionTokens pins short/medium only (06 §1/§2)', () {
    test('standard values', () {
      const m = MotionTokens.standard();
      expect(m.durationShort, const Duration(milliseconds: 150));
      expect(m.durationMedium, const Duration(milliseconds: 250));
      expect(m.curveStandard, Curves.fastOutSlowIn);
    });

    test('durations interpolate; the curve threshold-switches at 0.5', () {
      const a = MotionTokens.standard();
      final b = a.copyWith(durationShort: const Duration(milliseconds: 350));
      expect(a.lerp(b, 0.5).durationShort, const Duration(milliseconds: 250));
      expect(a.lerp(null, 0.5).durationShort, a.durationShort);
    });
  });

  group('HapticTokens is exactly three pulses (06 §4)', () {
    test('no fourth/success/reward pulse exists', () {
      expect(HapticPulse.values, [
        HapticPulse.selection,
        HapticPulse.confirm,
        HapticPulse.warning,
      ]);
    });

    test('lerp is a no-op (discrete platform calls)', () {
      const h = HapticTokens.standard();
      expect(h.lerp(const HapticTokens.standard(), 0.5), h);
    });
  });
}
