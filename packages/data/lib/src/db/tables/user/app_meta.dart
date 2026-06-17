// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

/// The `app_meta` table — an app-level key/value singleton store (05 §2).
///
/// Not per profile (no `profile_id`, no FK). Holds keys like `schema_version`,
/// `text_checksum_verified_at`, `active_profile`, `encryption_enabled`. The key
/// set is deliberately open — documented here, not pinned by a `CHECK`.
/// `STRICT`.
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  @override
  String get tableName => 'app_meta';

  /// The meta key (PK).
  TextColumn get key => text()();

  /// The meta value.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  bool get isStrict => true;
}
