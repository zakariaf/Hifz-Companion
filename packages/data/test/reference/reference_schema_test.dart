// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;

  setUp(() async {
    db = openTestDatabase();
    // createAll() runs on first open; the FK pragma is E03-T04's job in the
    // real connection, so the FK-violation assertions turn it on here.
    await db.customStatement('PRAGMA foreign_keys = ON;');
  });

  tearDown(() async => db.close());

  Future<Set<String>> tableNames() async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  Future<Set<String>> indexNames() async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  Future<String> createSqlFor(String table) async {
    // `table` is always a hardcoded constant below — safe to inline.
    final rows = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '$table'",
        )
        .get();
    return rows.single.read<String>('sql');
  }

  group('reference tables and indices exist', () {
    test('all seven reference tables are created', () async {
      expect(
        await tableNames(),
        containsAll(<String>[
          'mushaf',
          'surah',
          'page',
          'line',
          'ayah',
          'mutashabih_group',
          'mutashabih_member',
        ]),
      );
    });

    test('the documented indices exist', () async {
      expect(
        await indexNames(),
        containsAll(<String>['line_by_page', 'ayah_by_page']),
      );
    });

    test('every reference table is STRICT', () async {
      for (final t in const [
        'mushaf',
        'surah',
        'page',
        'line',
        'ayah',
        'mutashabih_group',
        'mutashabih_member',
      ]) {
        expect(await createSqlFor(t), contains('STRICT'), reason: '$t STRICT');
      }
    });
  });

  group('CHECK constraints reject out-of-range rows', () {
    Future<void> seedSurah1() => db.customStatement(
          "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
          "bismillah_pre) VALUES (1, 'الفاتحة', 'meccan', 7, 1)",
        );

    test('surah_id outside 1..114 is rejected', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
          "bismillah_pre) VALUES (0, 'x', 'meccan', 1, 0)",
        ),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
          "bismillah_pre) VALUES (115, 'x', 'meccan', 1, 0)",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('revelation outside the wire set is rejected', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
          "bismillah_pre) VALUES (2, 'x', 'martian', 1, 0)",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('ayah_count must be > 0', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
          "bismillah_pre) VALUES (3, 'x', 'meccan', 0, 0)",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('page_id outside 1..604 is rejected', () async {
      await seedSurah1();
      await expectLater(
        db.customStatement(
          'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
          'surah_end, ayah_end, line_count, qpc_font_name) '
          "VALUES (605, 1, 1, 1, 1, 1, 1, 7, 15, 'QCF_P605')",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('line_no outside 1..15 is rejected', () async {
      await seedSurah1();
      await db.customStatement(
        'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
        'surah_end, ayah_end, line_count, qpc_font_name) '
        "VALUES (1, 1, 1, 1, 1, 1, 1, 7, 15, 'QCF_P001')",
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO line (line_id, page_id, line_no, line_type, "
          "ayah_refs_json, text_glyph_ref) VALUES (1, 1, 16, 'ayah', '[]', 'g')",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('line_type outside the wire set is rejected', () async {
      await seedSurah1();
      await db.customStatement(
        'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
        'surah_end, ayah_end, line_count, qpc_font_name) '
        "VALUES (1, 1, 1, 1, 1, 1, 1, 7, 15, 'QCF_P001')",
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO line (line_id, page_id, line_no, line_type, "
          "ayah_refs_json, text_glyph_ref) "
          "VALUES (1, 1, 1, 'footnote', '[]', 'g')",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('mutashabih_group.type outside the wire set is rejected', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO mutashabih_group (group_id, type) "
          "VALUES ('g1', 'thematic')",
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('foreign keys are enforced when ON', () {
    test('an ayah referencing a missing page is rejected', () async {
      await db.customStatement(
        "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
        "bismillah_pre) VALUES (2, 'البقرة', 'medinan', 286, 1)",
      );
      // surah 2 exists, but page 999 does not -> FK violation on page_id.
      await expectLater(
        db.customStatement(
          "INSERT INTO ayah (ayah_id, surah, ayah, page_id, line_refs_json, "
          "sajda) VALUES ('2:1', 2, 1, 999, '[]', 0)",
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
