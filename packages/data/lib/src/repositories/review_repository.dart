// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/database.dart';
import '../persistence_exception.dart';

/// The single write path for one review (05 §3; 01 §4).
abstract interface class ReviewRepository {
  /// Persists one [outcome] atomically in exactly one transaction, resolving
  /// only after the durable WAL commit (persist-before-republish). On failure
  /// it throws a [ReviewWriteException] and commits nothing.
  Future<void> commitReview(ReviewOutcome outcome);
}

/// The live [ReviewRepository] over the Drift [HifzDatabase] (05 §3).
///
/// Every review is **one** `db.transaction` with every query `await`-ed; the
/// engine's [ReviewOutcome] is persisted verbatim — no D/S/`dueAt` is
/// recomputed here (the trust clamp is the only sink, 01 §4). The `review_log`
/// row is `INSERT`-only (append-only audit). The returned `Future` resolves
/// only after the durable commit, so the controller (E07) republishes strictly
/// *after* — no code path leaves memory newer than disk, and a teacher sign-off
/// is never acknowledged before its commit.
final class LiveReviewRepository implements ReviewRepository {
  /// Creates the repository over the Drift [database].
  LiveReviewRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<void> commitReview(ReviewOutcome outcome) async {
    try {
      await _database.transaction(() async {
        // 1. APPEND the immutable audit row (never updated/deleted — sanad).
        await _database.reviewLogDao.insert(outcome.logRow); // await — footgun
        // 2. UPSERT the card's engine state (D, S, dueAt, flags, reps, lapses).
        await _database.cardDao.upsert(outcome.cardUpdate); // await
        // 3. LAZILY create line-blocks for a repeatedly-lapsing page (if any).
        for (final block in outcome.newLineBlocks) {
          await _database.lineBlockDao.upsert(block); // await
        }
        // 4. BUMP mutashābihāt confusion edges (if a wrong-branch stumble).
        for (final bump in outcome.confusionBumps) {
          await _database.confusionEdgeDao.upsert(bump); // await
        }
      });
      // When this Future resolves, every row is durably on disk
      // (synchronous=FULL). The controller republishes only AFTER this returns.
    } on CouldNotRollBackException {
      // Even the ROLLBACK failed: surface as recovery-needed (logged locally
      // only, never transmitted), never swallowed.
      throw const ReviewRollbackFailed();
    } on SqliteException {
      // A CHECK/constraint rejected the outcome; the transaction rolled back.
      throw const ReviewConstraintViolated();
    } on Exception {
      // Any other store failure (e.g. a background-isolate transport error):
      // mapped to a typed write error, never a raw Drift exception, never
      // swallowed. Programming errors (Error subtypes) propagate.
      throw const ReviewTransactionFailed();
    }
  }
}
