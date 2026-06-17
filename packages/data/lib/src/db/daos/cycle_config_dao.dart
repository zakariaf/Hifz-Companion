// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../database.dart';
import '../tables/user/cycle_configs.dart';

part 'cycle_config_dao.g.dart';

/// Reads and upserts the one-per-profile `cycle_config` row as a
/// `models.CycleConfig` value type (05 §2).
@DriftAccessor(tables: [CycleConfigs])
class CycleConfigDao extends DatabaseAccessor<HifzDatabase>
    with _$CycleConfigDaoMixin {
  /// Creates the DAO over [db].
  CycleConfigDao(super.db);

  /// Inserts or replaces a profile's cycle configuration.
  Future<void> upsert(CycleConfig config) =>
      into(cycleConfigs).insertOnConflictUpdate(_toCompanion(config));

  /// The cycle configuration for [profileId], or null if none.
  Future<CycleConfig?> byProfile(ProfileId profileId) async {
    final query = select(cycleConfigs)
      ..where((c) => c.profileId.equals(profileId.value));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  CycleConfig _toModel(CycleConfigRow row) {
    return CycleConfig(
      profileId: ProfileId(row.profileId),
      cycleType: row.cycleType,
      newLinesPerDay: row.newLinesPerDay,
      nearWindowJuz: row.nearWindowJuz,
      farTargetPerDay: row.farTargetPerDay,
      cycleCeilingDays: row.farCycleDays,
      dailyBudgetMinutes: row.dailyBudgetMinutes,
      isPureCycleMode: row.pureCycleMode,
      termLabelSet: row.termLabelSet,
      regionPreset: row.regionPreset,
    );
  }

  CycleConfigsCompanion _toCompanion(CycleConfig config) {
    return CycleConfigsCompanion(
      profileId: Value(config.profileId.value),
      cycleType: Value(config.cycleType),
      newLinesPerDay: Value(config.newLinesPerDay),
      nearWindowJuz: Value(config.nearWindowJuz),
      farTargetPerDay: Value(config.farTargetPerDay),
      farCycleDays: Value(config.cycleCeilingDays),
      dailyBudgetMinutes: Value(config.dailyBudgetMinutes),
      pureCycleMode: Value(config.isPureCycleMode),
      termLabelSet: Value(config.termLabelSet),
      regionPreset: Value(config.regionPreset),
    );
  }
}
