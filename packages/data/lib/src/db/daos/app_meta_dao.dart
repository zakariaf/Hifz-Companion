// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/user/app_meta.dart';

part 'app_meta_dao.g.dart';

/// The app-level `(key, value)` singleton store — a `String`/`String` map, not
/// a per-profile domain record (05 §2). No `models` value type.
@DriftAccessor(tables: [AppMeta])
class AppMetaDao extends DatabaseAccessor<HifzDatabase> with _$AppMetaDaoMixin {
  /// Creates the DAO over [db].
  AppMetaDao(super.db);

  /// The value for [key], or null if the key is absent (not a throw).
  Future<String?> get(String key) async {
    final query = select(appMeta)..where((m) => m.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  /// Sets [key] to [value], replacing any existing value.
  Future<void> set(String key, String value) => into(appMeta)
      .insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));
}
