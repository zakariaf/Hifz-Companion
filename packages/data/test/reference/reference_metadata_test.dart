// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:data/src/reference/reference_data_builder.dart';
import 'package:data/src/reference/reference_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // Synthetic metadata: 2 sūras, sūra 1 (3 āyāt, global 0..2), sūra 2 (4 āyāt,
  // global 3..6). Juz 1 @ global 0, juz 2 @ global 4. Rubʿ 1,2,3,4 @ 0,2,4,6.
  QuranMetadata meta() => QuranMetadata(
        surahs: const [
          SurahMeta(
            number: 1,
            nameAr: 'الفاتحة',
            revelation: 'meccan',
            ayahCount: 3,
            globalStart: 0,
          ),
          SurahMeta(
            number: 2,
            nameAr: 'البقرة',
            revelation: 'medinan',
            ayahCount: 4,
            globalStart: 3,
          ),
        ],
        juzBoundaries: const [DivisionBoundary(1, 0), DivisionBoundary(2, 4)],
        rubBoundaries: const [
          DivisionBoundary(1, 0),
          DivisionBoundary(2, 2),
          DivisionBoundary(3, 4),
          DivisionBoundary(4, 6),
        ],
        sajdaAyahKeys: const {'2:3'},
      );

  group('division lookups', () {
    test('globalIndexOf uses the sūra start offset', () {
      expect(meta().globalIndexOf(1, 1), 0);
      expect(meta().globalIndexOf(2, 1), 3);
      expect(meta().globalIndexOf(2, 4), 6);
    });

    test('juz / rubʿ / ḥizb resolve from the largest boundary ≤ index', () {
      final m = meta();
      expect(m.juzOf(0), 1);
      expect(m.juzOf(3), 1);
      expect(m.juzOf(4), 2);
      expect(m.rubOf(0), 1);
      expect(m.rubOf(3), 2);
      expect(m.rubOf(6), 4);
      // ḥizb = ceil(rubʿ/4): rubʿ 1-4 → ḥizb 1.
      expect(m.hizbOf(0), 1);
      expect(m.hizbOf(6), 1);
    });
  });

  group('buildSurahRows', () {
    test('maps name/revelation/ayahCount and the bismillahPre rule', () {
      final rows = buildSurahRows(meta());
      expect(rows[0].surahId, 1);
      expect(rows[0].revelation, 'meccan');
      expect(rows[0].ayahCount, 3);
      // Sūra 1's basmala is ayah 1 → no separate pre-header.
      expect(rows[0].bismillahPre, isFalse);
      expect(rows[1].bismillahPre, isTrue); // sūra 2 has a preceding basmala
    });
  });

  group('buildPageRows', () {
    test('derives line count, ayah span, juz/ḥizb/rubʿ, and font name', () {
      const layout = [
        LayoutLine(
          pageNumber: 1,
          lineNumber: 1,
          lineType: 'surah_name',
          isCentered: true,
          surahNumber: 1,
        ),
        LayoutLine(
          pageNumber: 1,
          lineNumber: 2,
          lineType: 'ayah',
          isCentered: true,
          firstWordId: 1,
          lastWordId: 2,
        ),
        LayoutLine(
          pageNumber: 1,
          lineNumber: 3,
          lineType: 'ayah',
          isCentered: true,
          firstWordId: 3,
          lastWordId: 4,
        ),
      ];
      const words = [
        GlyphWord(id: 1, surah: 1, ayah: 1, word: 1, glyph: 'a'),
        GlyphWord(id: 2, surah: 1, ayah: 1, word: 2, glyph: 'b'),
        GlyphWord(id: 3, surah: 1, ayah: 2, word: 1, glyph: 'c'),
        GlyphWord(id: 4, surah: 1, ayah: 3, word: 1, glyph: 'd'),
      ];
      final page =
          buildPageRows(layout: layout, words: words, meta: meta()).single;
      expect(page.pageId, 1);
      expect(page.lineCount, 3); // includes the sūra-header line
      expect(page.surahStart, 1);
      expect(page.ayahStart, 1);
      expect(page.surahEnd, 1);
      expect(page.ayahEnd, 3); // last word is 1:3
      expect(page.juz, 1);
      expect(page.qpcFontName, 'QPC_P001');
    });
  });

  group('parseQuranMetadata (against the real Tanzil quran-data.xml)', () {
    // Local-only: the file lives in the git-ignored assets-src/ working dir
    // (unstated QUL/Tanzil license → not committed). Skips in CI.
    final xml = [
      File('assets-src/core/quran-data.xml'),
      File('../../assets-src/core/quran-data.xml'),
    ].where((f) => f.existsSync()).firstOrNull;

    test(
      'parses the canonical counts + known anchors',
      () {
        if (xml == null) {
          markTestSkipped('quran-data.xml not present (CI)');
          return;
        }
        final m = parseQuranMetadata(xml.readAsStringSync());
        expect(m.surahs.length, 114);
        final fatiha = m.surahs.first;
        expect(fatiha.number, 1);
        expect(fatiha.revelation, 'meccan');
        expect(fatiha.ayahCount, 7);
        expect(m.sajdaAyahKeys, contains('7:206'));
        // Juz 30 begins at An-Naba (78:1).
        expect(m.juzOf(m.globalIndexOf(78, 1)), 30);
      },
      tags: const ['real-data'],
    );
  });
}
