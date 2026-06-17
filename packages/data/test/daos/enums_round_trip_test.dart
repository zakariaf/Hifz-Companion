// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/daos/mappers.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  void expectRoundTrip<T extends Enum>(
    Iterable<T> values,
    String Function(T) wireOf,
    String enumName,
    Set<String> checkSet,
  ) {
    for (final value in values) {
      expect(
        enumFromWire(values, wireOf, wireOf(value), enumName),
        value,
        reason:
            '$enumName ${value.name} must round-trip through "${wireOf(value)}"',
      );
    }
    expect(
      values.map(wireOf).toSet(),
      checkSet,
      reason: '$enumName wire set must equal its 05 §2 CHECK literal set',
    );
  }

  test('ReviewTrack maps both ways and equals its CHECK set', () {
    expectRoundTrip(
      ReviewTrack.values,
      (t) => t.wireValue,
      'ReviewTrack',
      {'NEW', 'NEAR', 'FAR', 'UNMEMORIZED'},
    );
  });

  test('ReviewGrade maps both ways and equals its CHECK set', () {
    expectRoundTrip(
      ReviewGrade.values,
      (g) => g.wireValue,
      'ReviewGrade',
      {'again', 'hard', 'good', 'easy'},
    );
  });

  test('GradeSource maps both ways and equals its CHECK set', () {
    expectRoundTrip(
      GradeSource.values,
      (s) => s.wireValue,
      'GradeSource',
      {'self', 'teacher'},
    );
  });

  test('ProfileRole maps both ways and equals its CHECK set', () {
    expectRoundTrip(
      ProfileRole.values,
      (r) => r.wireValue,
      'ProfileRole',
      {'self', 'student', 'child'},
    );
  });

  test('ProfileLocale maps both ways and equals its CHECK set', () {
    expectRoundTrip(
      ProfileLocale.values,
      (l) => l.wireValue,
      'ProfileLocale',
      {'ar', 'fa', 'ckb'},
    );
  });

  test('an unknown wire token throws MappingException, never a silent default',
      () {
    expect(
      () => enumFromWire(
        ReviewGrade.values,
        (g) => g.wireValue,
        'perfect',
        'ReviewGrade',
      ),
      throwsA(isA<MappingException>()),
    );
  });
}
