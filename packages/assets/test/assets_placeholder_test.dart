// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('asset integrity error shape', () {
    String describe(AssetIntegrityError error) => switch (error) {
          ChecksumMismatch() => 'checksum-mismatch',
          PackUnavailable() => 'pack-unavailable',
        };

    test('the sealed error switch is exhaustive over its subtypes', () {
      expect(describe(const ChecksumMismatch()), 'checksum-mismatch');
      expect(describe(const PackUnavailable()), 'pack-unavailable');
    });
  });
}
