// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import 'ayat.dart';
import 'mutashabih_groups.dart';

/// The `mutashabih_member` reference table — āyāt belonging to a similar-verse
/// group (05 §2; R4).
///
/// Read-only by construction. Composite PK `(group_id, ayah_id)`.
/// `distinguishing_word_index_json` carries structural word indices only, drawn
/// as a coordinate overlay, never reconstructed text (R1). `STRICT`.
@DataClassName('MutashabihMemberRow')
class MutashabihMembers extends Table {
  @override
  String get tableName => 'mutashabih_member';

  /// The owning group (FK into `mutashabih_group`).
  TextColumn get groupId => text().references(MutashabihGroups, #groupId)();

  /// The member āyah (FK into `ayah`).
  TextColumn get ayahId => text().references(Ayat, #ayahId)();

  /// Structural distinguishing-word indices, or null.
  TextColumn get distinguishingWordIndexJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {groupId, ayahId};

  @override
  bool get isStrict => true;
}
