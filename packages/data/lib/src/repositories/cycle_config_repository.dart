// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import '../db/database.dart';
import 'repositories.dart';

/// The live [CycleConfigRepository] over the Drift [HifzDatabase] — the one
/// transactional write path for a profile's cycle configuration (the cycle
/// preset, engine targets, and term-set region).
///
/// A separate object from the [PersistenceHandle] facade (like the review and
/// cold-start repositories) so its `upsert(CycleConfig)` never collides with
/// [ProfileRepository.upsert] on one handle. It leaks no Drift symbol: it takes
/// and returns `models` value types only.
final class LiveCycleConfigRepository implements CycleConfigRepository {
  /// Wraps the given Drift [database].
  LiveCycleConfigRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<CycleConfig?> byProfile(ProfileId profileId) =>
      _database.cycleConfigDao.byProfile(profileId);

  @override
  Future<void> upsert(CycleConfig config) =>
      _database.transaction(() => _database.cycleConfigDao.upsert(config));

  @override
  Stream<CycleConfig?> watchByProfile(ProfileId profileId) =>
      _database.cycleConfigDao.watchByProfile(profileId);
}
