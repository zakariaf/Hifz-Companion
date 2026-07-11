// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/database.dart';
import '../persistence_exception.dart';

/// The new-memorization (sabaq) intake write path (E21-T02; PRD §7.8) — the
/// page-granular intake E04 deferred to the feature layer (`build_today.dart`).
abstract interface class SabaqIntakeRepository {
  /// Introduces one newly-memorized page into [profileId]'s schedule by
  /// persisting the engine's [seed] as a new card, in exactly one transaction.
  /// Resolves only after the durable commit (persist-before-republish).
  ///
  /// Throws [SabaqPageAlreadyStarted] — a clean, expected refusal — when the page
  /// already has a card (a re-mark must never clobber live D/S state), and a
  /// [SabaqIntakeWriteException] on any store failure, leaving the store exactly
  /// as it was.
  Future<void> startMemorizing(ProfileId profileId, CardSeed seed);
}

/// The live [SabaqIntakeRepository] over the Drift [HifzDatabase] (05 §3).
///
/// One `db.transaction`: refuse if the page already has a card (a re-mark is a
/// calm "already in your revision", never a clobber of live D/S/due), else
/// plain-`INSERT` the engine's [CardSeed] as a new card. The conservative prior
/// is persisted **verbatim** — no `(D, S)`/`dueAt` is recomputed here (the trust
/// clamp is the only sink, 01 §4). The returned `Future` resolves only after the
/// durable commit, so the controller republishes strictly *after*. Intake is
/// **not** a review, so it appends **no** `review_log` row — the card's creation
/// is the record; the append-only sanad stays a log of recitations only.
final class LiveSabaqIntakeRepository implements SabaqIntakeRepository {
  /// Creates the repository over the Drift [database].
  LiveSabaqIntakeRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<void> startMemorizing(ProfileId profileId, CardSeed seed) async {
    // Bind the profileId-free seed to the profile; no (D, S)/dueAt arithmetic
    // here — the seed is the engine's conservative prior verbatim.
    final card = Card(
      profileId: profileId,
      pageId: seed.pageId,
      track: seed.track,
      difficulty: seed.difficulty,
      stabilityDays: seed.stabilityDays,
      lastReviewedDay: seed.lastReviewedDay,
      dueAt: seed.dueAt,
    );

    try {
      await _database.transaction(() async {
        // Refuse a re-mark: an existing card means the page is already being
        // revised — never overwrite its live D/S/due with a fresh seed.
        final existing = await _database.cardDao.byId(profileId, seed.pageId);
        if (existing != null) {
          throw const SabaqPageAlreadyStarted();
        }
        // Plain INSERT (not upsert): a duplicate/CHECK violation fails the
        // transaction and rolls back to the exact pre-intake state.
        await _database.cardDao.insertAll([card]);
      });
      // When this resolves, the card is durably on disk (synchronous=FULL);
      // the controller republishes only AFTER this returns.
    } on SabaqPageAlreadyStarted {
      rethrow; // an expected, clean refusal — not a store failure
    } on CouldNotRollBackException {
      throw const SabaqIntakeRollbackFailed();
    } on SqliteException {
      // A CHECK/constraint rejected the seed; the transaction rolled back.
      throw const SabaqIntakeConstraintViolated();
    } on Exception {
      throw const SabaqIntakeFailed();
    }
  }
}
