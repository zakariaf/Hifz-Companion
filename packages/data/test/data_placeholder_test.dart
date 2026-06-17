// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('data package stub', () {
    test('placeholder DTO is const-constructible and equal by value', () {
      expect(const PlaceholderRecord(), const PlaceholderRecord());
    });

    test('a fake repository returns the placeholder record', () {
      final PlaceholderRepository repository = _FakePlaceholderRepository();
      expect(repository.current(), const PlaceholderRecord());
    });
  });
}

class _FakePlaceholderRepository implements PlaceholderRepository {
  @override
  PlaceholderRecord current() => const PlaceholderRecord();
}
