// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../database.dart';
import '../tables/user/line_blocks.dart';

part 'line_block_dao.g.dart';

/// Reads and inserts `line_block` rows as `models.LineBlock` value types — the
/// lazily-created sub-page ranges a profile keeps lapsing on (05 §2).
@DriftAccessor(tables: [LineBlocks])
class LineBlockDao extends DatabaseAccessor<HifzDatabase>
    with _$LineBlockDaoMixin {
  /// Creates the DAO over [db].
  LineBlockDao(super.db);

  /// Inserts or replaces a line block by its `block_id`.
  Future<void> upsert(LineBlock block) =>
      into(lineBlocks).insertOnConflictUpdate(_toCompanion(block));

  /// All line blocks for one card.
  Future<List<LineBlock>> forCard(ProfileId profileId, int pageId) async {
    final query = select(lineBlocks)
      ..where(
        (b) => b.profileId.equals(profileId.value) & b.pageId.equals(pageId),
      );
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  LineBlock _toModel(LineBlockRow row) {
    return LineBlock(
      blockId: BlockId(row.blockId),
      profileId: ProfileId(row.profileId),
      pageId: row.pageId,
      lineStart: row.lineStart,
      lineEnd: row.lineEnd,
      errorCount: row.errorCount,
    );
  }

  LineBlocksCompanion _toCompanion(LineBlock block) {
    return LineBlocksCompanion(
      blockId: Value(block.blockId.value),
      profileId: Value(block.profileId.value),
      pageId: Value(block.pageId),
      lineStart: Value(block.lineStart),
      lineEnd: Value(block.lineEnd),
      errorCount: Value(block.errorCount),
    );
  }
}
