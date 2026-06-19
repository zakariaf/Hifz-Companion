// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart';
import 'package:data/src/db/database.dart';
import 'package:data/src/live_persistence_handle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

/// The shell-facing read seams the E07 spine consumes through the public
/// [PersistenceHandle]: the profile-exists read (app-ready gate), the card
/// snapshot + reactive stream (Today queue), and the generic `app_meta` read
/// (the verified-text stamp). FK is OFF so this isolates the reads from the
/// referential-integrity tests; the CHECKs still apply.
void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  late PersistenceHandle handle;

  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    handle = LivePersistenceHandle(db);
  });
  tearDown(() async => handle.close());

  Profile profile(String id) => Profile(
        profileId: ProfileId(id),
        displayName: 'name-$id',
        role: ProfileRole.self,
        locale: ProfileLocale.fa,
        mushafId: 'm1',
        createdAtInstant: DateTime.utc(2026, 6, 17),
      );

  Card card(String profileId, int pageId) => Card(
        profileId: ProfileId(profileId),
        pageId: pageId,
        track: ReviewTrack.far,
        difficulty: 5,
        stabilityDays: 30,
        lastReviewedDay: CalendarDate.ymd(2026, 6, 1),
        dueAt: CalendarDate.ymd(2026, 6, 17),
      );

  group('ProfileRepository.all', () {
    test('is empty on a fresh store (drives onboarding on first run)',
        () async {
      expect(await handle.profiles.all(), isEmpty);
    });

    test('returns every profile on the device', () async {
      await db.profileDao.upsert(profile('p1'));
      await db.profileDao.upsert(profile('p2'));
      final all = await handle.profiles.all();
      expect(all.map((p) => p.profileId.value).toSet(), {'p1', 'p2'});
    });
  });

  group('CardRepository.forProfile', () {
    test('returns only the requested profile\'s cards', () async {
      await db.cardDao.upsert(card('p1', 1));
      await db.cardDao.upsert(card('p1', 2));
      await db.cardDao.upsert(card('p2', 1));
      final cards = await handle.cards.forProfile(const ProfileId('p1'));
      expect(cards.map((c) => c.pageId).toSet(), {1, 2});
    });
  });

  group('CardRepository.watchForProfile', () {
    test('emits the current set and re-emits after a committed write',
        () async {
      await db.cardDao.upsert(card('p1', 1));

      final lengths = <int>[];
      final sub = handle.cards
          .watchForProfile(const ProfileId('p1'))
          .listen((cards) => lengths.add(cards.length));
      await pumpEventQueue();

      // A new card on the same profile must push a fresh emission.
      await db.cardDao.upsert(card('p1', 2));
      await pumpEventQueue();

      await sub.cancel();
      expect(lengths, [1, 2]);
    });
  });

  group('AppMetaRepository.read', () {
    test('returns null for an absent key (never a throw)', () async {
      expect(
        await handle.meta.read(kAppMetaKeyTextChecksumVerifiedAt),
        isNull,
      );
    });

    test('returns the stored value once the key is set', () async {
      await db.appMetaDao.set(kAppMetaKeyTextChecksumVerifiedAt, '2026-06-19');
      expect(
        await handle.meta.read(kAppMetaKeyTextChecksumVerifiedAt),
        '2026-06-19',
      );
    });
  });
}
