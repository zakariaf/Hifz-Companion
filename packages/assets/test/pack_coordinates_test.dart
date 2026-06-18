// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

void main() {
  // No network here: PackCoordinates only builds a Uri string. Keep the
  // throwing offline guard installed.
  useOfflineTestPolicy();

  group('PackCoordinates pinning', () {
    test('pinnedTag is a non-empty exact literal, never "latest"', () {
      expect(PackCoordinates.pinnedTag, isNotEmpty);
      expect(PackCoordinates.pinnedTag, isNot('latest'));
    });

    test('repo is the public open-source data repo', () {
      expect(PackCoordinates.repo, 'hifz-companion/quran-assets');
    });

    test('assetUrl builds the immutable-Release URL at the pinned tag', () {
      expect(
        PackCoordinates.assetUrl('reciter-001.opus').toString(),
        'https://github.com/hifz-companion/quran-assets/releases/download/'
        'core-v1.0.0/reciter-001.opus',
      );
    });

    test('assetUrl is pure — same input yields the same Uri', () {
      expect(
        PackCoordinates.assetUrl('x.bin'),
        PackCoordinates.assetUrl('x.bin'),
      );
    });
  });
}
