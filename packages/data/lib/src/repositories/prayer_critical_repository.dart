// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../db/database.dart';
import '../persistence_exception.dart';

/// The write path for a page's **prayer-critical** flag (E21-T08; PRD §7.2/§7.5)
/// — a user preference, set from the Progress page-detail sheet, that raises the
/// engine's retention floor for that page (0.97). Never a fiqh ruling.
abstract interface class PrayerCriticalRepository {
  /// Sets whether the card for ([profileId], [pageId]) is prayer-critical, in one
  /// transaction (persist-before-republish). A calm **no-op** when the page has
  /// no card (nothing to mark) or the flag is already [value] (idempotent).
  /// Throws a [PrayerCriticalWriteException] on a store failure.
  Future<void> setPrayerCritical(
    ProfileId profileId,
    int pageId, {
    required bool value,
  });
}

/// The live [PrayerCriticalRepository] over the Drift [HifzDatabase] (05 §3).
///
/// One `db.transaction`: read the card, and if it exists and the flag differs,
/// upsert the single-field change. It writes **no** `review_log` row — a
/// preference toggle is not a recitation (the append-only sanad stays a log of
/// reviews). The returned `Future` resolves only after the durable commit, so
/// the reactive card stream (and the heat-map read model over it) republishes
/// strictly after.
final class LivePrayerCriticalRepository implements PrayerCriticalRepository {
  /// Creates the repository over the Drift [database].
  LivePrayerCriticalRepository(this._database);

  final HifzDatabase _database;

  @override
  Future<void> setPrayerCritical(
    ProfileId profileId,
    int pageId, {
    required bool value,
  }) async {
    try {
      await _database.transaction(() async {
        final card = await _database.cardDao.byId(profileId, pageId);
        // No card (an un-held / un-placed page) → nothing to mark; the flag is a
        // property of a page you already revise. Idempotent when unchanged.
        if (card == null || card.isPrayerCritical == value) return;
        await _database.cardDao.upsert(card.copyWith(isPrayerCritical: value));
      });
    } on CouldNotRollBackException {
      throw const PrayerCriticalRollbackFailed();
    } on Exception {
      throw const PrayerCriticalWriteFailed();
    }
  }
}
