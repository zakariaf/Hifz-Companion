// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

/// One line of the QUL page-layout dataset (`pages` table): its 1-based
/// [pageNumber]/[lineNumber], its [lineType], whether it is [isCentered], the
/// inclusive mushaf-sequential word-id range [firstWordId]..[lastWordId] (null
/// for a `surah_name`/`basmallah` line, which carries no ayah words), and the
/// [surahNumber] the line starts (only on a `surah_name` line).
class LayoutLine {
  /// Creates a layout line.
  const LayoutLine({
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
    this.firstWordId,
    this.lastWordId,
    this.surahNumber,
  });

  /// The 1-based page.
  final int pageNumber;

  /// The 1-based line number on the page.
  final int lineNumber;

  /// The QUL line type: `'surah_name'`, `'ayah'`, or `'basmallah'`.
  final String lineType;

  /// Whether the line is centred.
  final bool isCentered;

  /// The first word id on the line (inclusive), or null for a decorative line.
  final int? firstWordId;

  /// The last word id on the line (inclusive), or null for a decorative line.
  final int? lastWordId;

  /// The sūra a `surah_name` line announces, else null.
  final int? surahNumber;
}

/// One word of the QUL word-by-word glyph DB (`words` table): its
/// mushaf-sequential [id], its [surah]/[ayah]/[word] position, and its opaque
/// QPC V2 [glyph] code string (the rendered glyph — never parsed as Arabic
/// text; R1).
class GlyphWord {
  /// Creates a glyph word.
  const GlyphWord({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.word,
    required this.glyph,
  });

  /// The mushaf-sequential word id (matches the layout's word ranges).
  final int id;

  /// The 1-based sūra number.
  final int surah;

  /// The 1-based ayah number within the sūra.
  final int ayah;

  /// The 1-based word position within the ayah (the last word is the end
  /// marker).
  final int word;

  /// The opaque QPC V2 glyph code string for this word.
  final String glyph;
}

/// The QUL line types, mapped to E03's `line.line_type` CHECK set
/// (`ayah` / `surah_header` / `basmala`).
const Map<String, String> _lineTypeMap = {
  'ayah': 'ayah',
  'surah_name': 'surah_header',
  'basmallah': 'basmala',
};

/// A built `line` reference row — opaque glyph layer, never re-typeset (R1).
class LineRowData {
  /// Creates a line row.
  const LineRowData({
    required this.lineId,
    required this.pageId,
    required this.lineNo,
    required this.lineType,
    required this.ayahRefsJson,
    required this.textGlyphRef,
  });

  /// The stable line id (sequential across the muṣḥaf).
  final int lineId;

  /// The page this line is on.
  final int pageId;

  /// The 1-based line number on the page (1–15).
  final int lineNo;

  /// `ayah` / `surah_header` / `basmala`.
  final String lineType;

  /// JSON array of the `'surah:ayah'` ids occupying this line (empty for a
  /// decorative line).
  final String ayahRefsJson;

  /// The concatenated opaque glyph codes for the line (empty for a decorative
  /// `surah_header`/`basmala` line, whose header/basmala glyph comes from the
  /// dedicated QPC surah-name glyph source — pinned separately).
  final String textGlyphRef;
}

/// A built `ayah` reference row — location only, never the ayah's text (R1).
class AyahRowData {
  /// Creates an ayah row.
  const AyahRowData({
    required this.ayahId,
    required this.surah,
    required this.ayah,
    required this.pageId,
    required this.lineRefsJson,
    required this.sajda,
  });

  /// The `'surah:ayah'` id (e.g. `'2:255'`).
  final String ayahId;

  /// The sūra number.
  final int surah;

  /// The ayah number within its sūra.
  final int ayah;

  /// The page the ayah's words start on.
  final int pageId;

  /// JSON array of the line numbers (`page:line`) this ayah occupies.
  final String lineRefsJson;

  /// Whether this is a sajda ayah.
  final bool sajda;
}

/// The built line + ayah reference rows (the existential glyph/structure layer).
class ReferenceLinesAndAyat {
  /// Creates the result.
  const ReferenceLinesAndAyat({required this.lines, required this.ayat});

  /// The `line` rows (in `lineId` order).
  final List<LineRowData> lines;

  /// The `ayah` rows (in mushaf order).
  final List<AyahRowData> ayat;
}

/// Assembles the **existential** glyph/structure layer of the reference data —
/// the `line` and `ayah` rows — from the QUL [layout] lines and the QUL [words]
/// glyph DB, with the [sajdaAyahKeys] set (`'surah:ayah'`) from the Tanzil
/// metadata.
///
/// Pure: no IO, no clock. The line glyph string is a **plain concatenation** of
/// the opaque per-word glyph codes over the line's word range (never shaped,
/// never re-typeset; R1). Lines are grouped strictly by the QUL `page-line`
/// structure (never by verse). An ayah's `lineRefs` are the lines whose word
/// range covers any of its words; its `pageId` is where its first word sits.
///
/// Throws [ArgumentError] if a line references a word id absent from [words]
/// (a torn layout↔words pairing must fail loudly, never render a gap).
ReferenceLinesAndAyat buildLinesAndAyat({
  required List<LayoutLine> layout,
  required List<GlyphWord> words,
  required Set<String> sajdaAyahKeys,
}) {
  final wordById = {for (final w in words) w.id: w};

  final lines = <LineRowData>[];
  // ayahKey -> (pageId, ordered set of 'page:line' refs)
  final ayahPage = <String, int>{};
  final ayahLineRefs = <String, List<String>>{};
  final ayahOrder = <String>[]; // first-seen mushaf order

  var lineId = 0;
  for (final line in layout) {
    lineId++;
    final mappedType = _lineTypeMap[line.lineType];
    if (mappedType == null) {
      throw ArgumentError('Unknown QUL line_type "${line.lineType}".');
    }

    final ayahKeysOnLine = <String>[];
    final glyphBuffer = StringBuffer();
    final hasRange = line.firstWordId != null && line.lastWordId != null;
    if (hasRange) {
      for (var wid = line.firstWordId!; wid <= line.lastWordId!; wid++) {
        final w = wordById[wid];
        if (w == null) {
          throw ArgumentError(
            'Layout line ${line.pageNumber}:${line.lineNumber} references '
            'word id $wid not present in the word DB.',
          );
        }
        glyphBuffer.write(w.glyph);
        final key = '${w.surah}:${w.ayah}';
        if (ayahKeysOnLine.isEmpty || ayahKeysOnLine.last != key) {
          if (!ayahKeysOnLine.contains(key)) ayahKeysOnLine.add(key);
        }
        final pageLine = '${line.pageNumber}:${line.lineNumber}';
        ayahPage.putIfAbsent(key, () => line.pageNumber);
        final refs = ayahLineRefs.putIfAbsent(key, () => <String>[]);
        if (refs.isEmpty || refs.last != pageLine) refs.add(pageLine);
        if (!ayahOrder.contains(key)) ayahOrder.add(key);
      }
    }

    lines.add(
      LineRowData(
        lineId: lineId,
        pageId: line.pageNumber,
        lineNo: line.lineNumber,
        lineType: mappedType,
        ayahRefsJson: jsonEncode(ayahKeysOnLine),
        textGlyphRef: glyphBuffer.toString(),
      ),
    );
  }

  final ayat = <AyahRowData>[
    for (final key in ayahOrder)
      AyahRowData(
        ayahId: key,
        surah: int.parse(key.split(':')[0]),
        ayah: int.parse(key.split(':')[1]),
        pageId: ayahPage[key]!,
        lineRefsJson: jsonEncode(ayahLineRefs[key]),
        sajda: sajdaAyahKeys.contains(key),
      ),
  ];

  return ReferenceLinesAndAyat(lines: lines, ayat: ayat);
}
