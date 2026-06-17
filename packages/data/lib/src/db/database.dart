// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import 'tables/reference/ayat.dart';
import 'tables/reference/lines.dart';
import 'tables/reference/mushafs.dart';
import 'tables/reference/mutashabih_groups.dart';
import 'tables/reference/mutashabih_members.dart';
import 'tables/reference/pages.dart';
import 'tables/reference/surahs.dart';
import 'tables/user/app_meta.dart';
import 'tables/user/cards.dart';
import 'tables/user/confusion_edges.dart';
import 'tables/user/cycle_configs.dart';
import 'tables/user/line_blocks.dart';
import 'tables/user/profiles.dart';
import 'tables/user/review_log.dart';
import 'daos/app_meta_dao.dart';
import 'daos/card_dao.dart';
import 'daos/confusion_edge_dao.dart';
import 'daos/cycle_config_dao.dart';
import 'daos/line_block_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/reference_read_dao.dart';
import 'daos/review_log_dao.dart';

part 'database.g.dart';

/// The single Drift/SQLite database for Hifz Companion — the only type that
/// holds the schema, confined to the `data` package (05 §1).
///
/// It is constructed from an injected [QueryExecutor] so tests can pass an
/// in-memory `NativeDatabase.memory()` and the app composition root can pass
/// the file-backed, crash-safe connection (the connection `setup`/`beforeOpen`
/// pragmas — WAL, `synchronous=FULL`, `foreign_keys=ON` — are wired in E03-T04).
///
/// The table list is split into the **read-only reference** block (the fixed
/// Quran structure, filled only by the checksum-verified asset loader, E05) and
/// the read-write **user** block (per-profile records, added in E03-T03). No
/// DAO exposes a write to any reference table — read-only by construction (R1).
@DriftDatabase(
  tables: [
    // user (read-write — per profile)
    Profiles,
    Cards,
    LineBlocks,
    ReviewLog,
    ConfusionEdges,
    CycleConfigs,
    AppMeta,
    // reference (read-only — never written at runtime, 05 §2; R1)
    Mushafs,
    Surahs,
    Pages,
    Lines,
    Ayat,
    MutashabihGroups,
    MutashabihMembers,
  ],
  daos: [
    ProfileDao,
    CardDao,
    LineBlockDao,
    ReviewLogDao,
    ConfusionEdgeDao,
    CycleConfigDao,
    AppMetaDao,
    ReferenceReadDao,
  ],
)
class HifzDatabase extends _$HifzDatabase {
  /// Opens the database over the given [executor] (a file-backed connection in
  /// the app, `NativeDatabase.memory()` in tests).
  HifzDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        // Pragmas are per-connection and NOT persisted in the file, so the FK
        // pragma is re-issued on every open (05 §1). `setup` (connection.dart)
        // sets it on the raw handle; this covers drift's own re-open. The
        // assert is debug-fail-fast: if a refactor ever drops the FK pragma,
        // debug/test builds trip here rather than silently allowing orphan rows
        // across the whole user-table graph (card/review_log/line_block/
        // confusion_edge/cycle_config all REFERENCES profile ON DELETE CASCADE).
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          assert(await _foreignKeysAreOn());
        },
      );

  /// Whether `PRAGMA foreign_keys` is live on this connection (backs the
  /// `beforeOpen` startup assertion).
  Future<bool> _foreignKeysAreOn() async {
    final row = await customSelect('PRAGMA foreign_keys;').getSingle();
    return row.read<int>('foreign_keys') == 1;
  }
}
