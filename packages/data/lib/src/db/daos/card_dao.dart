// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../database.dart';
import '../tables/user/cards.dart';
import 'mappers.dart';

part 'card_dao.g.dart';

/// Reads and upserts `card` rows as `models.Card` value types — no Drift symbol
/// crosses its public surface (05 §2; 01 §3.1).
@DriftAccessor(tables: [Cards])
class CardDao extends DatabaseAccessor<HifzDatabase> with _$CardDaoMixin {
  /// Creates the DAO over [db].
  CardDao(super.db);

  /// Inserts or replaces the card for its `(profileId, pageId)` key.
  Future<void> upsert(Card card) =>
      into(cards).insertOnConflictUpdate(_toCompanion(card));

  /// Batch-inserts many cards in one statement (cold-start seeding, E03-T08).
  ///
  /// Plain `INSERT` (not upsert): a duplicate `(profileId, pageId)` or a `CHECK`
  /// violation fails the batch, which inside the seed transaction rolls the
  /// whole provisioning back to zero rows.
  Future<void> insertAll(List<Card> values) =>
      batch((b) => b.insertAll(cards, values.map(_toCompanion).toList()));

  /// The card for `(profileId, pageId)`, or null if none.
  Future<Card?> byId(ProfileId profileId, int pageId) async {
    final query = select(cards)
      ..where(
        (c) => c.profileId.equals(profileId.value) & c.pageId.equals(pageId),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// All cards for a profile.
  Future<List<Card>> forProfile(ProfileId profileId) async {
    final query = select(cards)
      ..where((c) => c.profileId.equals(profileId.value));
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  /// A reactive stream of a profile's cards: emits on listen and re-emits after
  /// every committed `card` write on this connection (the Today queue's source).
  Stream<List<Card>> watchForProfile(ProfileId profileId) {
    final query = select(cards)
      ..where((c) => c.profileId.equals(profileId.value));
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  Card _toModel(CardRow row) {
    return Card(
      profileId: ProfileId(row.profileId),
      pageId: row.pageId,
      track: enumFromWire(
        ReviewTrack.values,
        (t) => t.wireValue,
        row.track,
        'ReviewTrack',
      ),
      difficulty: row.difficulty,
      stabilityDays: row.stabilityDays,
      lastReviewedDay: calendarDateFromSerial(row.lastReviewAt),
      dueAt: calendarDateFromSerial(row.dueAt),
      reps: row.reps,
      lapses: row.lapses,
      isWeak: row.weakFlag,
      signoffs: row.signoffs,
      hasManualLock: row.manualLock,
      isPrayerCritical: row.prayerCritical,
      isEnabled: row.enabled,
    );
  }

  CardsCompanion _toCompanion(Card card) {
    return CardsCompanion(
      profileId: Value(card.profileId.value),
      pageId: Value(card.pageId),
      track: Value(card.track.wireValue),
      difficulty: Value(card.difficulty),
      stabilityDays: Value(card.stabilityDays),
      lastReviewAt: Value(serialFromCalendarDate(card.lastReviewedDay)),
      dueAt: Value(serialFromCalendarDate(card.dueAt)),
      reps: Value(card.reps),
      lapses: Value(card.lapses),
      weakFlag: Value(card.isWeak),
      signoffs: Value(card.signoffs),
      manualLock: Value(card.hasManualLock),
      prayerCritical: Value(card.isPrayerCritical),
      enabled: Value(card.isEnabled),
    );
  }
}
