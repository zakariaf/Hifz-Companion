// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'glyph_line.dart';

/// The bundled QUL page layout for the muṣḥaf — a plain value type the `quran`
/// renderer consumes (the feature layer maps the verified reference rows into
/// it; this package stays dependency-free). Holds the layout [words]; line and
/// page breaks are **read from here, never recomputed** (engineering 08 §3).
class MushafLayout {
  /// Creates a layout from its [words].
  const MushafLayout(this.words);

  /// Every layout word, across pages.
  final List<LayoutWord> words;

  /// The words on [pageNumber], unsorted (assemblePage orders them).
  Iterable<LayoutWord> wordsOnPage(int pageNumber) =>
      words.where((w) => w.pageNumber == pageNumber);
}

/// Assembles page [pageNumber] into its [GlyphLine]s, grouping words **strictly**
/// by `page-{p}-line-{l}` — **never** by verse boundary, because one muṣḥaf line
/// mixes words from multiple ayāt (engineering 08 §3). Within a line, words are
/// ordered by [LayoutWord.position] and their opaque glyph codes are plainly
/// concatenated (not shaped, not split into spans). Pure: no `BuildContext`, no
/// IO, no clock; line count comes from the data, never a hardcoded `15`.
ImmutableGlyphPage assemblePage(int pageNumber, MushafLayout layout) {
  final byLine = <int, List<LayoutWord>>{};
  for (final word in layout.wordsOnPage(pageNumber)) {
    (byLine[word.lineNumber] ??= <LayoutWord>[]).add(word);
  }

  final lineNumbers = byLine.keys.toList()..sort();
  final lines = <GlyphLine>[
    for (final lineNumber in lineNumbers)
      _line(pageNumber, lineNumber, byLine[lineNumber]!),
  ];
  return ImmutableGlyphPage(pageNumber: pageNumber, lines: lines);
}

GlyphLine _line(int pageNumber, int lineNumber, List<LayoutWord> words) {
  words.sort((a, b) => a.position.compareTo(b.position));
  return GlyphLine(
    pageNumber: pageNumber,
    lineNumber: lineNumber,
    type: words.first.lineType,
    glyphCodes: words.map((w) => w.glyphCode).join(),
  );
}
