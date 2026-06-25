// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T02: the ProfileRepository write/watch seam the Settings surface uses —
// upsert persists a profile (settings_json round-tripped), byId reads it back
// (null for an absent id, never a throw), and watchById emits the current row
// then re-emits after a committed write (persist-before-republish). FK is OFF to
// isolate from the referential-integrity tests; the CHECKs still apply.

import 'package:data/data.dart';
import 'package:data/src/db/database.dart';
import 'package:data/src/live_persistence_handle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

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

  Profile profile(String id, {Map<String, Object?>? settings}) => Profile(
        profileId: ProfileId(id),
        displayName: 'name-$id',
        role: ProfileRole.self,
        locale: ProfileLocale.fa,
        mushafId: 'm1',
        createdAtInstant: DateTime.utc(2026, 6, 17),
        settings: settings,
      );

  Card card(int pageId, CalendarDate dueAt) => Card(
        profileId: const ProfileId('p1'),
        pageId: pageId,
        track: ReviewTrack.far,
        difficulty: 5,
        stabilityDays: 30,
        lastReviewedDay: CalendarDate.ymd(2026, 6, 1),
        dueAt: dueAt,
      );

  test('upsert persists a profile that byId reads back (settings round-trip)',
      () async {
    await handle.profiles
        .upsert(profile('p1', settings: {'appearance': 'dark'}));
    final read = await handle.profiles.byProfileId(const ProfileId('p1'));
    expect(read?.displayName, 'name-p1');
    expect(read?.settings?['appearance'], 'dark');
  });

  test('byId is null for an absent profile (never a throw)', () async {
    expect(await handle.profiles.byProfileId(const ProfileId('absent')), isNull);
  });

  test('upsert updates an existing row in place (no duplicate)', () async {
    await handle.profiles.upsert(profile('p1'));
    await handle.profiles.upsert(profile('p1', settings: {'appearance': 'sepia'}));
    final all = await handle.profiles.all();
    expect(all.length, 1);
    expect(all.single.settings?['appearance'], 'sepia');
  });

  test('watchById emits the current row then re-emits after a committed write',
      () async {
    await handle.profiles
        .upsert(profile('p1', settings: {'appearance': 'light'}));

    final appearances = <Object?>[];
    final sub = handle.profiles
        .watchById(const ProfileId('p1'))
        .listen((p) => appearances.add(p?.settings?['appearance']));
    await pumpEventQueue();

    await handle.profiles
        .upsert(profile('p1', settings: {'appearance': 'sepia'}));
    await pumpEventQueue();

    await sub.cancel();
    expect(appearances, ['light', 'sepia']);
  });

  test('a calendar-setting change leaves a card due_at unchanged (E16-T04 '
      'display-transform discipline)', () async {
    final due = CalendarDate.ymd(2026, 6, 30);
    await db.cardDao.upsert(card(1, due));
    // Switching the calendar is a profile settings_json write — it must not
    // touch the card's scheduling instant.
    await handle.profiles.upsert(profile('p1', settings: {'calendar': 'gregorian'}));
    final stored = await db.cardDao.byId(const ProfileId('p1'), 1);
    expect(stored?.dueAt, due);
  });
}
