// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import '../db/database.dart';

/// One profile's complete set of user rows for the backup-snapshot assembly
/// (E17-T07; domain-backup-format §4). `models` value types only.
typedef ProfileExportRows = ({
  Profile profile,
  CycleConfig cycleConfig,
  List<Card> cards,
  List<LineBlock> lineBlocks,
  List<ReviewLog> reviewLog,
  List<ConfusionEdge> confusionEdges,
});

/// Reads every row of one profile for export (E17-T07). A single bundled read
/// (rather than per-entity `forProfile` seams, which would collide with the
/// handle's inline `CardRepository.forProfile`); read-only, no transaction.
abstract interface class BackupReadRepository {
  /// Every row of [profileId] for the export snapshot, or null if the profile
  /// (or its cycle config) is absent — nothing to export.
  Future<ProfileExportRows?> readProfileForExport(ProfileId profileId);
}

/// The live [BackupReadRepository] over the Drift [HifzDatabase].
final class LiveBackupReadRepository implements BackupReadRepository {
  /// Creates the repository over the Drift [database].
  LiveBackupReadRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<ProfileExportRows?> readProfileForExport(ProfileId profileId) async {
    final profile = await _database.profileDao.byId(profileId);
    final cycleConfig = await _database.cycleConfigDao.byProfile(profileId);
    if (profile == null || cycleConfig == null) return null;
    return (
      profile: profile,
      cycleConfig: cycleConfig,
      cards: await _database.cardDao.forProfile(profileId),
      lineBlocks: await _database.lineBlockDao.forProfile(profileId),
      reviewLog: await _database.reviewLogDao.forProfile(profileId),
      confusionEdges: await _database.confusionEdgeDao.forProfile(profileId),
    );
  }
}
