// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

/// The `mushaf` reference table — one row per swappable muṣḥaf edition (05 §2).
///
/// Read-only by construction: no DAO exposes a write to it; the bundled,
/// checksum-verified asset loader (E05) is the only writer. `STRICT`.
@DataClassName('MushafRow')
class Mushafs extends Table {
  @override
  String get tableName => 'mushaf';

  /// The stable edition id (PK).
  TextColumn get mushafId => text()();

  /// The named riwāyah (e.g. `hafs_an_asim`) — stated explicitly (R2).
  TextColumn get riwayah => text()();

  /// The display name of the edition.
  TextColumn get name => text()();

  /// Lines per page (a field, never hardcoded — the muṣḥaf is swappable).
  IntColumn get lineCount => integer()();

  /// Pages in the edition (a field, never hardcoded).
  IntColumn get pageCount => integer()();

  /// The page-glyph font family.
  TextColumn get fontFamily => text()();

  /// The pinned SHA-256 verified against the asset manifest (E05).
  TextColumn get checksumSha256 => text()();

  @override
  Set<Column<Object>> get primaryKey => {mushafId};

  @override
  bool get isStrict => true;
}
