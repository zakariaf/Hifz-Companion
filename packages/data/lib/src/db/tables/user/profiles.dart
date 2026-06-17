// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import '../reference/mushafs.dart';

/// The `profile` user table — one local profile per row (05 §2; PRD §10.2).
///
/// `display_name` is the only typed "PII" (PRD §17); `created_at` is a UTC
/// ISO-8601 instant stored as TEXT (never a `DateTimeColumn`). `STRICT`.
@DataClassName('ProfileRow')
class Profiles extends Table {
  @override
  String get tableName => 'profile';

  /// The profile UUID (PK).
  TextColumn get profileId => text()();

  /// The user-typed display name — the only PII (PRD §17).
  TextColumn get displayName => text()();

  /// `self` / `student` / `child`.
  TextColumn get role => text()();

  /// `ar` / `fa` / `ckb`.
  TextColumn get locale => text()();

  /// The selected muṣḥaf edition (FK into `mushaf`, no cascade — immutable).
  TextColumn get mushafId => text().references(Mushafs, #mushafId)();

  /// Creation instant — UTC ISO-8601 TEXT, never a scheduling day.
  TextColumn get createdAt => text()();

  /// Decode-validated preference JSON, or null — never health/Quran facts.
  TextColumn get settingsJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {profileId};

  @override
  List<String> get customConstraints => const [
        "CHECK (role IN ('self', 'student', 'child'))",
        "CHECK (locale IN ('ar', 'fa', 'ckb'))",
      ];

  @override
  bool get isStrict => true;
}
