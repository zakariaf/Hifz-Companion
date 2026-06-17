// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import '../reference/pages.dart';
import 'profiles.dart';

/// The `line_block` user table — a sub-page line range a profile keeps lapsing
/// on, created lazily (05 §2; PRD §10.2).
///
/// Stores line **numbers** and a stumble count only, never Quran text (R1).
/// `STRICT`. Index `line_block_by_card (profile_id, page_id)`.
@DataClassName('LineBlockRow')
@TableIndex(name: 'line_block_by_card', columns: {#profileId, #pageId})
class LineBlocks extends Table {
  @override
  String get tableName => 'line_block';

  /// The block UUID (PK).
  TextColumn get blockId => text()();

  /// The owning profile (FK, `ON DELETE CASCADE`).
  TextColumn get profileId =>
      text().references(Profiles, #profileId, onDelete: KeyAction.cascade)();

  /// The muṣḥaf page (FK into `page`, no cascade).
  IntColumn get pageId => integer().references(Pages, #pageId)();

  /// The first line of the range (1–15).
  IntColumn get lineStart => integer()();

  /// The last line of the range (`line_start ≤ line_end ≤ 15`).
  IntColumn get lineEnd => integer()();

  /// Stumble count for this range (≥ 0).
  IntColumn get errorCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {blockId};

  @override
  List<String> get customConstraints => const [
        'CHECK (line_start BETWEEN 1 AND 15)',
        'CHECK (line_end BETWEEN line_start AND 15)',
        'CHECK (error_count >= 0)',
      ];

  @override
  bool get isStrict => true;
}
