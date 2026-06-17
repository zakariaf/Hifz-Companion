// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/database.dart';
import '../persistence_exception.dart';

/// The cold-start provisioning write path (05 §3; PRD §7.10).
abstract interface class ColdStartRepository {
  /// Provisions a new profile atomically: one outer transaction inserting the
  /// [profile], the 600+ [seeds] (bound to the profile), and its
  /// [cycleConfig] — all-or-nothing. On failure it throws a
  /// [ColdStartWriteException] and leaves zero rows.
  Future<void> seedColdStart(
    Profile profile,
    CycleConfig cycleConfig,
    List<CardSeed> seeds,
  );
}

/// The live [ColdStartRepository] over the Drift [HifzDatabase] (05 §3).
///
/// One **outer** `db.transaction` with every query `await`-ed: the `profile`
/// row first (the `card.profile_id` FK needs it), then the 600+ cards in one
/// `batch.insertAll` (not 600 awaited inserts), then the `cycle_config`. A
/// failure at any step rolls back to **zero** rows — no partially-provisioned
/// profile. The engine's conservative priors (E11) are persisted verbatim — no
/// `(D, S)`/`dueAt` is recomputed, no stale-time decay applied. The Future
/// resolves only after the durable commit; onboarding republishes strictly
/// after — never an optimistic "all set" before the cards are on disk.
final class LiveColdStartRepository implements ColdStartRepository {
  /// Creates the repository over the Drift [database].
  LiveColdStartRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<void> seedColdStart(
    Profile profile,
    CycleConfig cycleConfig,
    List<CardSeed> seeds,
  ) async {
    // Bind each profileId-free seed to the profile being provisioned. No
    // (D, S)/dueAt arithmetic here — the seeds are the engine's priors verbatim.
    final cards = [
      for (final seed in seeds)
        Card(
          profileId: profile.profileId,
          pageId: seed.pageId,
          track: seed.track,
          difficulty: seed.difficulty,
          stabilityDays: seed.stabilityDays,
          lastReviewedDay: seed.lastReviewedDay,
          dueAt: seed.dueAt,
        ),
    ];

    try {
      await _database.transaction(() async {
        // 1. INSERT the profile FIRST — the card FK (profile_id) requires it.
        await _database.profileDao.upsert(profile); // await — the footgun
        // 2. BATCH-insert the cards in one batch (not per-row awaited inserts).
        await _database.cardDao.insertAll(cards); // await
        // 3. INSERT the cycle_config (the cycle ceiling, named-preset config).
        await _database.cycleConfigDao.upsert(cycleConfig); // await
      });
      // When this Future resolves, every row is durably on disk
      // (synchronous=FULL). Onboarding republishes only AFTER this returns.
    } on CouldNotRollBackException {
      throw const ColdStartRollbackFailed();
    } on SqliteException {
      throw const ColdStartConstraintViolated();
    } on Exception {
      throw const ColdStartSeedFailed();
    }
  }
}
