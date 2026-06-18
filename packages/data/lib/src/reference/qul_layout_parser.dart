// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:sqlite3/common.dart';

import 'reference_data_builder.dart';
import 'reference_db_builder.dart' show ReferenceLoadError;

/// The muṣḥaf-level facts read from the QUL layout `info` row — the page/line
/// counts and font name come **from the data**, never the 604/15 literals (the
/// muṣḥaf is swappable).
class QulInfo {
  /// Creates the parsed `info` record.
  const QulInfo({
    required this.name,
    required this.pageCount,
    required this.lineCount,
    required this.fontName,
  });

  /// The edition name as the dataset states it (e.g. `QCF V2 ( 1421H print )`).
  final String name;

  /// The number of pages (`number_of_pages`).
  final int pageCount;

  /// The lines per page (`lines_per_page`).
  final int lineCount;

  /// The font family (`font_name`, e.g. `v2`).
  final String fontName;
}

/// Reads the QUL **layout** DB (`qpc-v2-15-lines.db`) `info` row.
///
/// Throws [ReferenceLoadError.malformedLayout] if the row is absent — a layout
/// DB with no `info` cannot govern a muṣḥaf and must fail loudly, never default.
QulInfo parseLayoutInfo(CommonDatabase layoutDb) {
  final rows = layoutDb.select(
    'SELECT name, number_of_pages, lines_per_page, font_name FROM info',
  );
  if (rows.isEmpty) {
    throw const ReferenceLoadError.malformedLayout('layout DB has no info row');
  }
  final r = rows.first;
  return QulInfo(
    name: r['name'] as String,
    pageCount: r['number_of_pages'] as int,
    lineCount: r['lines_per_page'] as int,
    fontName: r['font_name'] as String,
  );
}

/// Coerces a QUL nullable-integer cell to `int?`. The dataset stores "no value"
/// as an **empty string** (not SQL NULL) on decorative lines, and SQLite's
/// dynamic typing returns those cells as `String`; treat empty/NULL as absent.
int? _nullableInt(Object? cell) {
  if (cell == null) return null;
  if (cell is int) return cell;
  if (cell is String) {
    if (cell.isEmpty) return null;
    final parsed = int.tryParse(cell);
    if (parsed == null) {
      throw ReferenceLoadError.malformedLayout('non-integer cell "$cell"');
    }
    return parsed;
  }
  throw ReferenceLoadError.malformedLayout(
    'unexpected cell type ${cell.runtimeType}',
  );
}

/// Reads the QUL **layout** DB `pages` table into [LayoutLine]s, in
/// page-then-line order — the page/line geometry exactly as the dataset
/// records it, never recomputed (08 §3). Decorative lines carry null word ids.
List<LayoutLine> parseLayoutLines(CommonDatabase layoutDb) {
  final rows = layoutDb.select(
    'SELECT page_number, line_number, line_type, is_centered, '
    'first_word_id, last_word_id, surah_number FROM pages '
    'ORDER BY page_number, line_number',
  );
  return [
    for (final r in rows)
      LayoutLine(
        pageNumber: r['page_number'] as int,
        lineNumber: r['line_number'] as int,
        lineType: r['line_type'] as String,
        isCentered: (r['is_centered'] as int) != 0,
        firstWordId: _nullableInt(r['first_word_id']),
        lastWordId: _nullableInt(r['last_word_id']),
        surahNumber: _nullableInt(r['surah_number']),
      ),
  ];
}

/// Reads the QUL **word-by-word glyph** DB (`qpc-v2.db`) `words` table into
/// [GlyphWord]s, in mushaf-sequential `id` order (the order the layout's word
/// ranges index into). The `text` column holds the **opaque** QPC glyph code —
/// stored as-is, never parsed as Arabic (R1).
List<GlyphWord> parseGlyphWords(CommonDatabase wordsDb) {
  final rows = wordsDb.select(
    'SELECT id, surah, ayah, word, text FROM words ORDER BY id',
  );
  return [
    for (final r in rows)
      GlyphWord(
        id: r['id'] as int,
        surah: r['surah'] as int,
        ayah: r['ayah'] as int,
        word: r['word'] as int,
        glyph: r['text'] as String,
      ),
  ];
}
