// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import 'pages.dart';

/// The `line` reference table — per-line layout (05 §2).
///
/// Read-only by construction. `text_glyph_ref` holds opaque glyph codes that
/// are never parsed as Arabic text (R1). Index `line_by_page (page_id,
/// line_no)`. `STRICT`.
@DataClassName('LineRow')
@TableIndex(name: 'line_by_page', columns: {#pageId, #lineNo})
class Lines extends Table {
  @override
  String get tableName => 'line';

  /// The line's stable id (PK).
  IntColumn get lineId => integer()();

  /// The page this line is on (FK into `page`).
  IntColumn get pageId => integer().references(Pages, #pageId)();

  /// The line number on the page (1–15).
  IntColumn get lineNo => integer()();

  /// What the line holds (`ayah` / `surah_header` / `basmala`).
  TextColumn get lineType => text()();

  /// Which āyāt occupy this line — small structural refs, never text.
  TextColumn get ayahRefsJson => text()();

  /// Opaque glyph-code reference — never parsed as Quran text (R1).
  TextColumn get textGlyphRef => text()();

  @override
  Set<Column<Object>> get primaryKey => {lineId};

  @override
  List<String> get customConstraints => const [
        'CHECK (line_no BETWEEN 1 AND 15)',
        "CHECK (line_type IN ('ayah', 'surah_header', 'basmala'))",
      ];

  @override
  bool get isStrict => true;
}
