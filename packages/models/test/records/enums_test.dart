// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  // The frozen CHECK (... IN (...)) literal sets from
  // docs/engineering/05-persistence-and-encryption.md §2. If the schema (E03-T03)
  // and these enums ever drift, one of these assertions fails.
  group('enum wire tokens equal the schema CHECK literal sets (05 §2)', () {
    test('ProfileRole == role IN (self, student, child)', () {
      expect(
        ProfileRole.values.map((e) => e.wireValue).toSet(),
        {'self', 'student', 'child'},
      );
    });

    test('ProfileLocale == locale IN (ar, fa, ckb)', () {
      expect(
        ProfileLocale.values.map((e) => e.wireValue).toSet(),
        {'ar', 'fa', 'ckb'},
      );
    });

    test('ReviewTrack == track IN (NEW, NEAR, FAR, UNMEMORIZED)', () {
      expect(
        ReviewTrack.values.map((e) => e.wireValue).toSet(),
        {'NEW', 'NEAR', 'FAR', 'UNMEMORIZED'},
      );
    });

    test('ReviewGrade == grade IN (again, hard, good, easy)', () {
      expect(
        ReviewGrade.values.map((e) => e.wireValue).toSet(),
        {'again', 'hard', 'good', 'easy'},
      );
    });

    test('GradeSource == source IN (self, teacher)', () {
      expect(
        GradeSource.values.map((e) => e.wireValue).toSet(),
        {'self', 'teacher'},
      );
    });
  });

  test('wire tokens round-trip through a reverse lookup', () {
    // The DAO (E03-T06) maps a stored token back to an enum; prove the mapping
    // is total and unambiguous for ReviewTrack (the most error-prone, with its
    // new -> newPage rename).
    ReviewTrack fromWire(String wire) =>
        ReviewTrack.values.firstWhere((t) => t.wireValue == wire);
    expect(fromWire('NEW'), ReviewTrack.newPage);
    expect(fromWire('UNMEMORIZED'), ReviewTrack.unmemorized);
  });
}
