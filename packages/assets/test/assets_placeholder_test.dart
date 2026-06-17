// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

void main() {
  // assets is the SINGLE sanctioned opt-out from the throwing-HttpOverrides
  // guard: E05's downloader test resets HttpOverrides.global to a mock client in
  // its own setUp. This E01 placeholder makes no network call, so it keeps the
  // throwing guard installed.
  useOfflineTestPolicy();

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
