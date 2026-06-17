// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

/// The `surah` reference table — sūrah metadata (05 §2).
///
/// Read-only by construction. Every invariant is a table `CHECK`, not Dart
/// validation. `STRICT`.
@DataClassName('SurahRow')
class Surahs extends Table {
  @override
  String get tableName => 'surah';

  /// The sūrah number 1–114 (PK).
  IntColumn get surahId => integer()();

  /// The Arabic name of the sūrah.
  TextColumn get nameAr => text()();

  /// Meccan or Medinan.
  TextColumn get revelation => text()();

  /// The number of āyāt (`> 0`).
  IntColumn get ayahCount => integer()();

  /// Whether a basmala precedes the sūrah (stored 0/1).
  BoolColumn get bismillahPre => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {surahId};

  @override
  List<String> get customConstraints => const [
        'CHECK (surah_id BETWEEN 1 AND 114)',
        "CHECK (revelation IN ('meccan', 'medinan'))",
        'CHECK (ayah_count > 0)',
      ];

  @override
  bool get isStrict => true;
}
