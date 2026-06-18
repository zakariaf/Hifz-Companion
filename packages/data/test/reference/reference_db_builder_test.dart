// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:data/src/reference/reference_data_builder.dart';
import 'package:data/src/reference/reference_db_builder.dart';
import 'package:data/src/reference/reference_metadata.dart';
import 'package:drift/drift.dart' show TableInfo;
import 'package:flutter_test/flutter_test.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

/// A non-empty 64-hex stand-in for the pinned, already-verified SHA-256.
const _verifiedSha =
    '0000000000000000000000000000000000000000000000000000000000000000';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  // A small, valid two-page synthetic edition. `pageCount`/`lineCount` stand in
  // for the QUL `info` row — every count the tests assert is read from this
  // value bundle, never a 604/15 literal.
  CoreReferenceData validData({
    String checksumSha256 = _verifiedSha,
    int pageCount = 2,
    List<PageRowData>? pages,
  }) =>
      CoreReferenceData(
        mushafId: 'hafs_madani_15',
        riwayah: 'hafs_an_asim',
        name: 'Madani 15-line',
        fontFamily: 'v2',
        checksumSha256: checksumSha256,
        pageCount: pageCount,
        lineCount: 15,
        surahs: const [
          SurahRowData(
            surahId: 1,
            nameAr: 'الفاتحة',
            revelation: 'meccan',
            ayahCount: 7,
            bismillahPre: false,
          ),
          SurahRowData(
            surahId: 2,
            nameAr: 'البقرة',
            revelation: 'medinan',
            ayahCount: 286,
            bismillahPre: true,
          ),
        ],
        pages: pages ??
            const [
              PageRowData(
                pageId: 1,
                juz: 1,
                hizb: 1,
                rub: 1,
                surahStart: 1,
                ayahStart: 1,
                surahEnd: 1,
                ayahEnd: 7,
                lineCount: 15,
                qpcFontName: 'QPC_P001',
              ),
              PageRowData(
                pageId: 2,
                juz: 1,
                hizb: 1,
                rub: 2,
                surahStart: 2,
                ayahStart: 1,
                surahEnd: 2,
                ayahEnd: 5,
                lineCount: 15,
                qpcFontName: 'QPC_P002',
              ),
            ],
        lines: const [
          LineRowData(
            lineId: 1,
            pageId: 1,
            lineNo: 1,
            lineType: 'surah_header',
            ayahRefsJson: '[]',
            textGlyphRef: '',
          ),
          LineRowData(
            lineId: 2,
            pageId: 1,
            lineNo: 2,
            lineType: 'ayah',
            ayahRefsJson: '["1:1"]',
            textGlyphRef: 'g1g2',
          ),
          LineRowData(
            lineId: 3,
            pageId: 2,
            lineNo: 1,
            lineType: 'ayah',
            ayahRefsJson: '["2:1"]',
            textGlyphRef: 'g3',
          ),
        ],
        ayat: const [
          AyahRowData(
            ayahId: '1:1',
            surah: 1,
            ayah: 1,
            pageId: 1,
            lineRefsJson: '["1:2"]',
            sajda: false,
          ),
          AyahRowData(
            ayahId: '2:1',
            surah: 2,
            ayah: 1,
            pageId: 2,
            lineRefsJson: '["2:1"]',
            sajda: false,
          ),
        ],
      );

  Future<int> count(TableInfo<dynamic, dynamic> table) async =>
      (await db.customSelect('SELECT COUNT(*) AS c FROM ${table.actualTableName}')
              .getSingle())
          .read<int>('c');

  Future<bool> allReferenceTablesEmpty() async =>
      await count(db.mushafs) == 0 &&
      await count(db.surahs) == 0 &&
      await count(db.pages) == 0 &&
      await count(db.lines) == 0 &&
      await count(db.ayat) == 0;

  group('structure (TEST-FIRST) — counts read from data, never recomputed', () {
    test('loads exactly the read structure into the five reference tables',
        () async {
      await loadCoreReference(db, validData());

      expect(await count(db.mushafs), 1);
      expect(await count(db.surahs), 2);
      expect(await count(db.pages), 2);
      expect(await count(db.lines), 3);
      expect(await count(db.ayat), 2);

      final mushaf = await db.select(db.mushafs).getSingle();
      // The count is the LOADED value, not a literal in the assertion.
      expect(mushaf.pageCount, validData().pageCount);
      expect(mushaf.lineCount, validData().lineCount);
      expect(mushaf.riwayah, 'hafs_an_asim');
      expect(mushaf.checksumSha256, _verifiedSha);

      final page1 = await (db.select(db.pages)
            ..where((p) => p.pageId.equals(1)))
          .getSingle();
      expect(page1.juz, 1);
      expect(page1.qpcFontName, 'QPC_P001');
    });
  });

  test('fail-closed: an unverified input writes nothing', () async {
    expect(
      () => loadCoreReference(db, validData(checksumSha256: '')),
      throwsA(isA<ReferenceLoadError>()),
    );
    expect(await allReferenceTablesEmpty(), isTrue);
  });

  group('atomic rollback (TEST-FIRST) — one bad row empties all five tables',
      () {
    test('a CHECK violation (page_id = 605) rolls the whole load back',
        () async {
      final bad = validData(
        pageCount: 1,
        pages: const [
          PageRowData(
            pageId: 605, // violates CHECK (page_id BETWEEN 1 AND 604)
            juz: 1,
            hizb: 1,
            rub: 1,
            surahStart: 1,
            ayahStart: 1,
            surahEnd: 1,
            ayahEnd: 7,
            lineCount: 15,
            qpcFontName: 'QPC_P605',
          ),
        ],
      );
      await expectLater(
        () => loadCoreReference(db, bad),
        throwsA(isA<ReferenceLoadError>()),
      );
      expect(await allReferenceTablesEmpty(), isTrue);
    });

    test('a CHECK violation (line_no = 16) rolls the whole load back',
        () async {
      final base = validData();
      final bad = CoreReferenceData(
        mushafId: base.mushafId,
        riwayah: base.riwayah,
        name: base.name,
        fontFamily: base.fontFamily,
        checksumSha256: base.checksumSha256,
        pageCount: base.pageCount,
        lineCount: base.lineCount,
        surahs: base.surahs,
        pages: base.pages,
        lines: const [
          LineRowData(
            lineId: 1,
            pageId: 1,
            lineNo: 16, // violates CHECK (line_no BETWEEN 1 AND 15)
            lineType: 'ayah',
            ayahRefsJson: '["1:1"]',
            textGlyphRef: 'g1',
          ),
        ],
        ayat: base.ayat,
      );
      await expectLater(
        () => loadCoreReference(db, bad),
        throwsA(isA<ReferenceLoadError>()),
      );
      expect(await allReferenceTablesEmpty(), isTrue);
    });

    test('a dangling surah FK rolls the whole load back', () async {
      final base = validData();
      final bad = CoreReferenceData(
        mushafId: base.mushafId,
        riwayah: base.riwayah,
        name: base.name,
        fontFamily: base.fontFamily,
        checksumSha256: base.checksumSha256,
        pageCount: 1,
        lineCount: base.lineCount,
        surahs: base.surahs,
        pages: const [
          PageRowData(
            pageId: 1,
            juz: 1,
            hizb: 1,
            rub: 1,
            surahStart: 99, // no surah 99 → dangling FK
            ayahStart: 1,
            surahEnd: 99,
            ayahEnd: 7,
            lineCount: 15,
            qpcFontName: 'QPC_P001',
          ),
        ],
        lines: const [],
        ayat: const [],
      );
      await expectLater(
        () => loadCoreReference(db, bad),
        throwsA(isA<ReferenceLoadError>()),
      );
      expect(await allReferenceTablesEmpty(), isTrue);
    });
  });

  test('structural mismatch: declared page count ≠ page rows is refused',
      () async {
    expect(
      () => loadCoreReference(db, validData(pageCount: 99)),
      throwsA(isA<ReferenceLoadError>()),
    );
    expect(await allReferenceTablesEmpty(), isTrue);
  });

  test('idempotent: a re-run for the same mushaf_id does not duplicate rows',
      () async {
    await loadCoreReference(db, validData());
    await loadCoreReference(db, validData());
    expect(await count(db.mushafs), 1);
    expect(await count(db.surahs), 2);
    expect(await count(db.pages), 2);
    expect(await count(db.lines), 3);
    expect(await count(db.ayat), 2);
  });
}
