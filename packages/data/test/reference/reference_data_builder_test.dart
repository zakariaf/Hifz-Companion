// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/reference/reference_data_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  GlyphWord w(int id, int s, int a, int word, String g) =>
      GlyphWord(id: id, surah: s, ayah: a, word: word, glyph: g);

  group('line + ayah assembly (Al-Fātiḥa shape)', () {
    // Page 1: line 1 = sūra header (no words), lines 2-3 = ayah lines.
    // 1:1 = words 1-5 (4 words + end marker), 1:2 = words 6-10.
    final layout = [
      const LayoutLine(
        pageNumber: 1,
        lineNumber: 1,
        lineType: 'surah_name',
        isCentered: true,
        surahNumber: 1,
      ),
      const LayoutLine(
        pageNumber: 1,
        lineNumber: 2,
        lineType: 'ayah',
        isCentered: true,
        firstWordId: 1,
        lastWordId: 5,
      ),
      const LayoutLine(
        pageNumber: 1,
        lineNumber: 3,
        lineType: 'ayah',
        isCentered: true,
        firstWordId: 6,
        lastWordId: 10,
      ),
    ];
    final words = [
      for (var i = 1; i <= 5; i++) w(i, 1, 1, i, 'a$i'),
      for (var i = 6; i <= 10; i++) w(i, 1, 2, i - 5, 'b${i - 5}'),
    ];

    late ReferenceLinesAndAyat r;
    setUp(() {
      r = buildLinesAndAyat(
        layout: layout,
        words: words,
        sajdaAyahKeys: const {},
      );
    });

    test('maps QUL line types to the E03 CHECK set', () {
      expect(r.lines.map((l) => l.lineType), [
        'surah_header',
        'ayah',
        'ayah',
      ]);
    });

    test('the sūra-header line carries no glyph and no ayah refs', () {
      final header = r.lines.first;
      expect(header.textGlyphRef, isEmpty);
      expect(header.ayahRefsJson, '[]');
    });

    test('an ayah line concatenates its words\' opaque glyph codes in order',
        () {
      expect(r.lines[1].textGlyphRef, 'a1a2a3a4a5'); // 1:1, incl end marker
      expect(r.lines[1].ayahRefsJson, '["1:1"]');
      expect(r.lines[2].textGlyphRef, 'b1b2b3b4b5'); // 1:2
    });

    test('ayah rows carry location + page + line refs, never text', () {
      expect(r.ayat.map((a) => a.ayahId), ['1:1', '1:2']);
      final a1 = r.ayat.first;
      expect(a1.surah, 1);
      expect(a1.ayah, 1);
      expect(a1.pageId, 1);
      expect(a1.lineRefsJson, '["1:2"]');
      expect(a1.sajda, isFalse);
    });
  });

  test('a basmala line maps to basmala with no glyph/ayah', () {
    final r = buildLinesAndAyat(
      layout: const [
        LayoutLine(
          pageNumber: 2,
          lineNumber: 2,
          lineType: 'basmallah',
          isCentered: true,
        ),
      ],
      words: const [],
      sajdaAyahKeys: const {},
    );
    expect(r.lines.single.lineType, 'basmala');
    expect(r.lines.single.textGlyphRef, isEmpty);
  });

  test('a line spanning two ayāt lists BOTH (grouped by line, never split)',
      () {
    // One line holds the end of 2:5 (word) and the start of 2:6 (word).
    final r = buildLinesAndAyat(
      layout: const [
        LayoutLine(
          pageNumber: 3,
          lineNumber: 4,
          lineType: 'ayah',
          isCentered: true,
          firstWordId: 100,
          lastWordId: 101,
        ),
      ],
      words: [w(100, 2, 5, 9, 'x'), w(101, 2, 6, 1, 'y')],
      sajdaAyahKeys: const {},
    );
    expect(r.lines.single.ayahRefsJson, '["2:5","2:6"]');
    expect(r.lines.single.textGlyphRef, 'xy');
    // Both ayāt record this line.
    expect(r.ayat.map((a) => a.ayahId), ['2:5', '2:6']);
    expect(r.ayat.every((a) => a.lineRefsJson == '["3:4"]'), isTrue);
  });

  test('an ayah spanning two lines records both line refs', () {
    final r = buildLinesAndAyat(
      layout: const [
        LayoutLine(
          pageNumber: 5,
          lineNumber: 1,
          lineType: 'ayah',
          isCentered: true,
          firstWordId: 200,
          lastWordId: 200,
        ),
        LayoutLine(
          pageNumber: 5,
          lineNumber: 2,
          lineType: 'ayah',
          isCentered: true,
          firstWordId: 201,
          lastWordId: 201,
        ),
      ],
      words: [w(200, 2, 255, 1, 'p'), w(201, 2, 255, 2, 'q')],
      sajdaAyahKeys: const {},
    );
    expect(r.ayat.single.ayahId, '2:255');
    expect(r.ayat.single.lineRefsJson, '["5:1","5:2"]');
  });

  test('sajda ayāt are flagged from the metadata set', () {
    final r = buildLinesAndAyat(
      layout: const [
        LayoutLine(
          pageNumber: 200,
          lineNumber: 5,
          lineType: 'ayah',
          isCentered: true,
          firstWordId: 1,
          lastWordId: 1,
        ),
      ],
      words: [w(1, 7, 206, 1, 'z')],
      sajdaAyahKeys: const {'7:206'},
    );
    expect(r.ayat.single.sajda, isTrue);
  });

  test('a torn layout↔words pairing fails loudly (never a silent gap)', () {
    expect(
      () => buildLinesAndAyat(
        layout: const [
          LayoutLine(
            pageNumber: 1,
            lineNumber: 2,
            lineType: 'ayah',
            isCentered: true,
            firstWordId: 1,
            lastWordId: 3, // word 3 missing
          ),
        ],
        words: [w(1, 1, 1, 1, 'a'), w(2, 1, 1, 2, 'b')],
        sajdaAyahKeys: const {},
      ),
      throwsArgumentError,
    );
  });

  test('an unknown line_type fails loudly', () {
    expect(
      () => buildLinesAndAyat(
        layout: const [
          LayoutLine(
            pageNumber: 1,
            lineNumber: 1,
            lineType: 'mystery',
            isCentered: false,
          ),
        ],
        words: const [],
        sajdaAyahKeys: const {},
      ),
      throwsArgumentError,
    );
  });
}
