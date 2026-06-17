// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

/// The `mutashabih_group` reference table — scholar-reviewed similar-verse
/// groups (05 §2; R4).
///
/// Read-only by construction; objective near-identical wording only, no tafsīr.
/// `STRICT`.
@DataClassName('MutashabihGroupRow')
class MutashabihGroups extends Table {
  @override
  String get tableName => 'mutashabih_group';

  /// The group's stable id (PK).
  TextColumn get groupId => text()();

  /// The kind of similarity (`identical` / `near_identical` / `structural`).
  TextColumn get type => text()();

  /// An optional localizable note resource key (a key into `l10n`), or null.
  TextColumn get noteKey => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {groupId};

  @override
  List<String> get customConstraints => const [
        "CHECK (type IN ('identical', 'near_identical', 'structural'))",
      ];

  @override
  bool get isStrict => true;
}
