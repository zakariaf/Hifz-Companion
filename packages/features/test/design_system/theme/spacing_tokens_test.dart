// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('SpacingTokens.standard pins the 4-on-8 scale (05 §1)', () {
    test('every step equals its audited dp', () {
      const s = SpacingTokens.standard();
      expect(
        [
          s.space1,
          s.space2,
          s.space3,
          s.space4,
          s.space5,
          s.space6,
          s.space7,
          s.space8,
        ],
        [4, 8, 12, 16, 20, 24, 32, 48],
      );
    });
  });

  test('copyWith overrides only the named step', () {
    const s = SpacingTokens.standard();
    final out = s.copyWith(space4: 99);
    expect(out.space4, 99);
    expect(out.space1, s.space1);
    expect(out.space8, s.space8);
  });

  test('lerp interpolates each step and handles the ends', () {
    const a = SpacingTokens.standard();
    final b = a.copyWith(space4: 32);
    expect(a.lerp(b, 0).space4, closeTo(16, 1e-6));
    expect(a.lerp(b, 1).space4, closeTo(32, 1e-6));
    expect(a.lerp(b, 0.5).space4, closeTo(24, 1e-6));
    expect(a.lerp(null, 0.5).space4, a.space4); // null -> this
  });
}
