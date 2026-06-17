// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import 'surahs.dart';

/// The `page` reference table — the fixed per-page layout descriptor (05 §2).
///
/// Read-only by construction; the geometry comes from the QUL dataset and is
/// never recomputed (R1). `STRICT`.
@DataClassName('PageRow')
class Pages extends Table {
  @override
  String get tableName => 'page';

  /// The page number 1–604 (PK).
  IntColumn get pageId => integer()();

  /// The juz (1–30).
  IntColumn get juz => integer()();

  /// The ḥizb (1–60).
  IntColumn get hizb => integer()();

  /// The rub' (1–240).
  IntColumn get rub => integer()();

  /// The sūrah the page starts in (FK into `surah`).
  @ReferenceName('pagesStartingInSurah')
  IntColumn get surahStart => integer().references(Surahs, #surahId)();

  /// The first āyah on the page.
  IntColumn get ayahStart => integer()();

  /// The sūrah the page ends in (FK into `surah`).
  @ReferenceName('pagesEndingInSurah')
  IntColumn get surahEnd => integer().references(Surahs, #surahId)();

  /// The last āyah on the page.
  IntColumn get ayahEnd => integer()();

  /// The number of lines on the page.
  IntColumn get lineCount => integer()();

  /// This page's dedicated KFGQPC glyph-font family (§08).
  TextColumn get qpcFontName => text()();

  @override
  Set<Column<Object>> get primaryKey => {pageId};

  @override
  List<String> get customConstraints => const [
        'CHECK (page_id BETWEEN 1 AND 604)',
        'CHECK (juz BETWEEN 1 AND 30)',
        'CHECK (hizb BETWEEN 1 AND 60)',
        'CHECK (rub BETWEEN 1 AND 240)',
      ];

  @override
  bool get isStrict => true;
}
