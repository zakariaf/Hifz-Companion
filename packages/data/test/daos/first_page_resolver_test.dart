// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The jump-to resolver reads the page a unit starts on from the `page` table —
// it NEVER computes a boundary by arithmetic (engineering 08 §3). The fixture
// seeds deliberately NON-arithmetic page numbers (juz 2 starts on page 99, not
// 22), so an arithmetic resolver would fail these vectors. The frozen REAL
// 604-page boundary vectors (al-Baqarah → 2, …) are deferred to the asset phase
// (the bundled reference data is not committed); this pins the read logic.

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    // juz 1: pages 5,6,7 ; juz 2: pages 99,100 ; juz 3: page 40 (out of order).
    // hizb 2 spans pages 6,99 ; surah_start 18 first falls on page 100.
    await _seedPage(db, page: 7, juz: 1, hizb: 1, surahStart: 1);
    await _seedPage(db, page: 5, juz: 1, hizb: 1, surahStart: 1);
    await _seedPage(db, page: 6, juz: 1, hizb: 2, surahStart: 1);
    await _seedPage(db, page: 100, juz: 2, hizb: 2, surahStart: 18);
    await _seedPage(db, page: 99, juz: 2, hizb: 2, surahStart: 2);
    await _seedPage(db, page: 40, juz: 3, hizb: 3, surahStart: 99);
  });
  tearDown(() async => db.close());

  group('reads MIN(page_id) from the table, never an arithmetic derivation', () {
    test('juz → its lowest page, even when seeded out of order', () async {
      expect(await db.referenceReadDao.firstPageInJuz(1), 5);
      // Arithmetic ((2-1)*N+1) could never yield 99 — only a table read does.
      expect(await db.referenceReadDao.firstPageInJuz(2), 99);
      expect(await db.referenceReadDao.firstPageInJuz(3), 40);
    });

    test('ḥizb → its lowest page across juz boundaries', () async {
      expect(await db.referenceReadDao.firstPageInHizb(2), 6);
    });

    test('sūrah → the lowest page its first āyah falls on', () async {
      expect(await db.referenceReadDao.firstPageOfSurah(2), 99);
      expect(await db.referenceReadDao.firstPageOfSurah(18), 100);
    });
  });

  group('an absent unit yields null, never a guessed page', () {
    test('a juz/ḥizb/sūrah not in the data is null', () async {
      expect(await db.referenceReadDao.firstPageInJuz(30), isNull);
      expect(await db.referenceReadDao.firstPageInHizb(60), isNull);
      expect(await db.referenceReadDao.firstPageOfSurah(114), isNull);
    });
  });
}

Future<void> _seedPage(
  HifzDatabase db, {
  required int page,
  required int juz,
  required int hizb,
  required int surahStart,
}) =>
    db.customStatement(
      'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
      'surah_end, ayah_end, line_count, qpc_font_name) '
      "VALUES ($page, $juz, $hizb, 1, $surahStart, 1, $surahStart, 7, 15, 'f')",
    );
