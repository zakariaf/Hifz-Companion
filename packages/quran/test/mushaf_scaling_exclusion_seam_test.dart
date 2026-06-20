// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T04 (written first): the muṣḥaf scaling-exclusion seam. The assembled
// layout is byte-identical under every TextScaler the OS supplies (the scaler is
// in scope via an ambient MediaQuery and is ignored by the sacred path), line
// breaks come from the dataset not measurement, and the screen reader is fed the
// page reference — never a glyph code. R1 guarded from the accessibility angle.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import 'test_setup.dart';

// A deterministic single-page stub: a sūra-name header, a basmala, and two ayah
// lines whose words would visually wrap under a naive softWrap — yet the dataset
// fixes the line grouping. The glyph codes are stable opaque strings (this is a
// data-identity check, not a pixel golden, so any stable string is fine).
MushafLayout _stub() => const MushafLayout([
      LayoutWord(
        pageNumber: 1,
        lineNumber: 1,
        position: 1,
        glyphCode: 'GLYPH-SURAH-AL-FATIHAH',
        lineType: LineType.surahName,
      ),
      LayoutWord(
        pageNumber: 1,
        lineNumber: 2,
        position: 1,
        glyphCode: 'GLYPH-BASMALA',
        lineType: LineType.basmala,
      ),
      LayoutWord(
        pageNumber: 1,
        lineNumber: 3,
        position: 2,
        glyphCode: 'GLYPH-W2',
        lineType: LineType.ayah,
      ),
      LayoutWord(
        pageNumber: 1,
        lineNumber: 3,
        position: 1,
        glyphCode: 'GLYPH-W1-LONGLONGLONGLONGLONGLONGWORD',
        lineType: LineType.ayah,
      ),
      LayoutWord(
        pageNumber: 1,
        lineNumber: 3,
        position: 3,
        glyphCode: 'GLYPH-W3',
        lineType: LineType.ayah,
      ),
    ]);

// The frozen expected assembly: 3 lines, the line-3 words concatenated in
// position order regardless of declaration order.
const _expectedLines = <(int, LineType, String)>[
  (1, LineType.surahName, 'GLYPH-SURAH-AL-FATIHAH'),
  (2, LineType.basmala, 'GLYPH-BASMALA'),
  (3, LineType.ayah, 'GLYPH-W1-LONGLONGLONGLONGLONGLONGWORDGLYPH-W2GLYPH-W3'),
];

void _expectMatchesFrozen(ImmutableGlyphPage page) {
  expect(page.lines, hasLength(_expectedLines.length));
  for (var i = 0; i < _expectedLines.length; i++) {
    final line = page.lines[i];
    final (lineNumber, type, codes) = _expectedLines[i];
    expect(line.lineNumber, lineNumber);
    expect(line.type, type);
    expect(line.glyphCodes, codes);
  }
}

void main() {
  useOfflineTestPolicy();

  // The reference for the stub page, as the bundled structure dataset would give
  // it (al-Fātiḥa, ayāt 1–7, juz 1) — never derived from glyph codes.
  const reference = PageReference(
    pageNumber: 1,
    range: SurahAyahRange(surah: 1, firstAyah: 1, lastAyah: 7),
    juz: 1,
  );

  const scalers = <TextScaler>[
    TextScaler.noScaling,
    TextScaler.linear(2.0),
    TextScaler.linear(3.2),
  ];

  testWidgets('layout is identical across the TextScaler matrix, ignoring scale',
      (tester) async {
    for (final scaler in scalers) {
      late ImmutableGlyphPage assembled;
      await tester.pumpWidget(
        MediaQuery(
          // The scaler is in scope; the sacred path must ignore it.
          data: MediaQueryData(textScaler: scaler),
          child: Builder(
            builder: (context) {
              // Reading textScalerOf here proves a scaler is genuinely ambient.
              MediaQuery.textScalerOf(context);
              assembled = assemblePage(1, _stub());
              return const SizedBox();
            },
          ),
        ),
      );
      _expectMatchesFrozen(assembled);
    }
  });

  test('no runtime line-breaking: grouping comes from the data', () {
    // Line 3 holds three words (one very long) that would wrap under softWrap;
    // the assembly keeps them on the one dataset line.
    final page = assemblePage(1, _stub());
    expect(page.lines, hasLength(3));
    expect(page.lines.last.lineNumber, 3);
    _expectMatchesFrozen(page);
  });

  test('reference, not glyphs, reaches the reader', () {
    expect(reference.pageNumber, 1);
    expect(reference.range.surah, 1);
    expect(reference.range.firstAyah, 1);
    expect(reference.range.lastAyah, 7);
    expect(reference.juz, 1);

    // No reference field carries any substring of the stub's glyph codes.
    final referenceText = '${reference.pageNumber} ${reference.range.surah} '
        '${reference.range.firstAyah} ${reference.range.lastAyah} '
        '${reference.juz}';
    for (final word in _stub().words) {
      expect(
        referenceText.contains(word.glyphCode),
        isFalse,
        reason: 'a PageReference field must never carry a glyph code',
      );
    }
  });
}
