// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  LayoutWord word(int line, int pos, String glyph, {LineType? type}) =>
      LayoutWord(
        pageNumber: 1,
        lineNumber: line,
        position: pos,
        glyphCode: glyph,
        lineType: type ?? LineType.ayah,
      );

  test(
      'groups by page-line, NEVER by verse — a line spanning two ayāt is one '
      'line', () {
    // Line 3 ends ayah 5 and begins ayah 6 — different ayāt, same muṣḥaf line.
    final layout = MushafLayout([
      word(3, 1, 'A'), // last word of ayah 5
      word(3, 2, 'B'), // first word of ayah 6
      word(3, 3, 'C'), // second word of ayah 6
    ]);
    final page = assemblePage(1, layout);
    expect(page.lines.length, 1);
    expect(page.lines.single.lineNumber, 3);
    expect(page.lines.single.glyphCodes, 'ABC');
  });

  test('emits lines in ascending lineNumber order', () {
    final layout = MushafLayout([
      word(2, 1, 'b'),
      word(1, 1, 'a'),
      word(3, 1, 'c'),
    ]);
    final page = assemblePage(1, layout);
    expect(page.lines.map((l) => l.lineNumber), [1, 2, 3]);
  });

  test('orders words within a line by position before concatenating', () {
    final layout = MushafLayout([
      word(1, 3, 'Z'),
      word(1, 1, 'X'),
      word(1, 2, 'Y'),
    ]);
    expect(assemblePage(1, layout).lines.single.glyphCodes, 'XYZ');
  });

  test('only includes the requested page', () {
    final layout = MushafLayout([
      word(1, 1, 'p1'),
      const LayoutWord(
        pageNumber: 2,
        lineNumber: 1,
        position: 1,
        glyphCode: 'p2',
        lineType: LineType.ayah,
      ),
    ]);
    final page = assemblePage(1, layout);
    expect(page.pageNumber, 1);
    expect(page.lines.single.glyphCodes, 'p1');
  });

  test('carries the line type from the dataset', () {
    final layout = MushafLayout([word(1, 1, 'h', type: LineType.surahName)]);
    expect(assemblePage(1, layout).lines.single.type, LineType.surahName);
  });
}
