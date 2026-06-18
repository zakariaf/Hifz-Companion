// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:data/src/reference/qul_layout_parser.dart';
import 'package:data/src/reference/reference_data_builder.dart';
import 'package:data/src/reference/reference_db_builder.dart';
import 'package:data/src/reference/reference_metadata.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  setUpAll(ensureTestSqlite3Loaded);

  group('parsing a synthetic QUL layout/words schema (CI)', () {
    late CommonDatabase layout;
    late CommonDatabase words;

    setUp(() {
      layout = sqlite3.openInMemory();
      layout.execute(
        'CREATE TABLE info (name TEXT, number_of_pages INTEGER, '
        'lines_per_page INTEGER, font_name TEXT);'
        'CREATE TABLE pages (page_number INTEGER, line_number INTEGER, '
        'line_type TEXT, is_centered INTEGER, first_word_id INTEGER, '
        'last_word_id INTEGER, surah_number INTEGER);',
      );
      layout.execute(
        "INSERT INTO info VALUES ('QCF V2 ( 1421H print )', 604, 15, 'v2');",
      );
      layout.execute(
        // A decorative surah_name line (null word ids), then an ayah line.
        'INSERT INTO pages VALUES '
        "(1, 1, 'surah_name', 1, NULL, NULL, 1), "
        "(1, 2, 'ayah', 0, 1, 2, NULL);",
      );

      words = sqlite3.openInMemory();
      words.execute(
        'CREATE TABLE words (id INTEGER, location TEXT, surah INTEGER, '
        'ayah INTEGER, word INTEGER, text TEXT);',
      );
      words.execute(
        "INSERT INTO words VALUES (1, '1:1:1', 1, 1, 1, 'ﱁ'), "
        "(2, '1:1:2', 1, 1, 2, 'ﱂ');",
      );
    });

    tearDown(() {
      layout.dispose();
      words.dispose();
    });

    test('info comes from the row, never a literal', () {
      final info = parseLayoutInfo(layout);
      expect(info.pageCount, 604);
      expect(info.lineCount, 15);
      expect(info.fontName, 'v2');
      expect(info.name, 'QCF V2 ( 1421H print )');
    });

    test('a missing info row fails loudly (never a default)', () {
      final empty = sqlite3.openInMemory()
        ..execute('CREATE TABLE info (name TEXT, number_of_pages INTEGER, '
            'lines_per_page INTEGER, font_name TEXT);');
      addTearDown(empty.dispose);
      expect(
        () => parseLayoutInfo(empty),
        throwsA(isA<ReferenceLoadError>()),
      );
    });

    test('layout lines map types, centering, and null decorative word ids', () {
      final lines = parseLayoutLines(layout);
      expect(lines, hasLength(2));
      expect(lines[0].lineType, 'surah_name');
      expect(lines[0].isCentered, isTrue);
      expect(lines[0].firstWordId, isNull); // decorative — no words
      expect(lines[0].surahNumber, 1);
      expect(lines[1].lineType, 'ayah');
      expect(lines[1].isCentered, isFalse);
      expect(lines[1].firstWordId, 1);
      expect(lines[1].lastWordId, 2);
    });

    test('glyph words carry the opaque QPC code verbatim', () {
      final w = parseGlyphWords(words);
      expect(w.map((g) => g.id), [1, 2]);
      expect(w[0].glyph, 'ﱁ'); // opaque PUA glyph, never parsed as Arabic
      expect(w[0].surah, 1);
      expect(w[0].word, 1);
    });
  });

  group('full pipeline over the REAL muṣḥaf data (local-only)', () {
    // The QUL DBs + Tanzil XML live in the git-ignored assets-src/ working dir
    // (unstated license → not committed). This is the existential R1 validation
    // — parse → build → load the WHOLE muṣḥaf and assert it is complete and
    // intact — but it can only run where the data is present, so it skips in CI.
    File? find(String name) => [
          File('assets-src/core/$name'),
          File('../../assets-src/core/$name'),
        ].where((f) => f.existsSync()).firstOrNull;

    test(
      'parse → parts 1+2 → load yields the complete 604/114/6236 structure',
      () async {
        final layoutFile = find('qpc-v2-15-lines.db');
        final wordsFile = find('qpc-v2.db');
        final xmlFile = find('quran-data.xml');
        if (layoutFile == null || wordsFile == null || xmlFile == null) {
          markTestSkipped('assets-src/core/* not present (CI)');
          return;
        }

        final layoutDb = sqlite3.open(layoutFile.path);
        final wordsDb = sqlite3.open(wordsFile.path);
        addTearDown(layoutDb.dispose);
        addTearDown(wordsDb.dispose);

        final info = parseLayoutInfo(layoutDb);
        final layout = parseLayoutLines(layoutDb);
        final words = parseGlyphWords(wordsDb);
        final meta = parseQuranMetadata(xmlFile.readAsStringSync());

        final linesAndAyat = buildLinesAndAyat(
          layout: layout,
          words: words,
          sajdaAyahKeys: meta.sajdaAyahKeys,
        );
        final data = CoreReferenceData(
          mushafId: 'hafs_madani_15',
          riwayah: 'hafs_an_asim',
          name: info.name,
          fontFamily: info.fontName,
          // A structural test: the byte-for-byte text checksum governance is
          // T03/T04's; here a non-empty pin just clears the fail-closed gate.
          checksumSha256: 'x' * 64,
          pageCount: info.pageCount,
          lineCount: info.lineCount,
          surahs: buildSurahRows(meta),
          pages: buildPageRows(layout: layout, words: words, meta: meta),
          lines: linesAndAyat.lines,
          ayat: linesAndAyat.ayat,
        );

        final db = openTestDatabase();
        addTearDown(db.close);
        await loadCoreReference(db, data);

        Future<int> n(String t) async => (await db
                .customSelect('SELECT COUNT(*) AS c FROM $t')
                .getSingle())
            .read<int>('c');
        expect(await n('mushaf'), 1);
        expect(await n('surah'), 114);
        expect(await n('page'), 604);
        expect(await n('ayah'), 6236);
        expect(await n('line'), layout.length); // every QUL line is loaded
      },
      tags: const ['real-data'],
    );
  });
}
