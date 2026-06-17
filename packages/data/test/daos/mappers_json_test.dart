// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/daos/mappers.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

/// A malformed `*_json` payload must map to the sealed [MappingException] — it
/// must never leak a raw `TypeError`/`FormatException` past the data boundary
/// (a lazy `cast` would throw lazily in the caller, bypassing the boundary).
void main() {
  useOfflineTestPolicy();

  group('lineIndicesFromJson', () {
    test('valid input round-trips; null stays null', () {
      expect(lineIndicesFromJson('[3,7]'), [3, 7]);
      expect(lineIndicesFromJson(null), isNull);
    });

    test('a non-array payload throws MappingException', () {
      expect(
        () => lineIndicesFromJson('{"a":1}'),
        throwsA(isA<MappingException>()),
      );
    });

    test('a non-int element throws MappingException (eager, not lazy)', () {
      expect(
        () => lineIndicesFromJson('[1,"x"]'),
        throwsA(isA<MappingException>()),
      );
    });

    test('malformed JSON throws MappingException, not a raw FormatException',
        () {
      expect(
        () => lineIndicesFromJson('not json'),
        throwsA(isA<MappingException>()),
      );
    });
  });

  group('settingsFromJson', () {
    test('valid object round-trips; null stays null', () {
      expect(settingsFromJson('{"reminderHour":20}'), {'reminderHour': 20});
      expect(settingsFromJson(null), isNull);
    });

    test('a non-object payload throws MappingException', () {
      expect(
        () => settingsFromJson('[1,2]'),
        throwsA(isA<MappingException>()),
      );
    });

    test('malformed JSON throws MappingException', () {
      expect(
        () => settingsFromJson('{not json'),
        throwsA(isA<MappingException>()),
      );
    });
  });
}
