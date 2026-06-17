// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import 'pages.dart';
import 'surahs.dart';

/// The `ayah` reference table — per-āyah position (05 §2).
///
/// Read-only by construction; holds the āyah's location only, never its text
/// (R1). Index `ayah_by_page (page_id)`. `STRICT`.
@DataClassName('AyahRow')
@TableIndex(name: 'ayah_by_page', columns: {#pageId})
class Ayat extends Table {
  @override
  String get tableName => 'ayah';

  /// The `'surah:ayah'` id, e.g. `'2:255'` (PK).
  TextColumn get ayahId => text()();

  /// The sūrah number (FK into `surah`).
  IntColumn get surah => integer().references(Surahs, #surahId)();

  /// The āyah number within its sūrah.
  IntColumn get ayah => integer()();

  /// The page this āyah falls on (FK into `page`).
  IntColumn get pageId => integer().references(Pages, #pageId)();

  /// Which lines this āyah occupies — small structural refs.
  TextColumn get lineRefsJson => text()();

  /// Whether this is a sajda āyah (stored 0/1).
  BoolColumn get sajda => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {ayahId};

  @override
  bool get isStrict => true;
}
