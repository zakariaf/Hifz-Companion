// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T05: the CycleConfigRepository seam the Settings term-set + cycle surfaces
// use — byProfile reads the one-per-profile row, upsert persists the chosen
// term-set region, and watchByProfile emits the current row then re-emits after
// a committed write (persist-before-republish). FK is OFF to isolate from the
// referential-integrity tests; the CHECKs still apply.

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

  CycleConfig config(String id, {String? regionPreset}) => CycleConfig(
        profileId: ProfileId(id),
        cycleType: '7_manzil',
        nearWindowJuz: 1,
        farTargetPerDay: 1,
        cycleCeilingDays: 7,
        dailyBudgetMinutes: 30,
        termLabelSet: 'classical',
        regionPreset: regionPreset,
      );

  test('upsert persists a config that byProfile reads back', () async {
    await handle.cycleConfig.upsert(config('p1', regionPreset: 'levant'));
    final read = await handle.cycleConfig.byProfile(const ProfileId('p1'));
    expect(read?.regionPreset, 'levant');
    expect(read?.cycleType, '7_manzil');
  });

  test('byProfile is null for an absent profile (never a throw)', () async {
    expect(await handle.cycleConfig.byProfile(const ProfileId('absent')), isNull);
  });

  test('watchByProfile emits the current row then re-emits after a write',
      () async {
    await handle.cycleConfig.upsert(config('p1', regionPreset: 'other'));

    final regions = <Object?>[];
    final sub = handle.cycleConfig
        .watchByProfile(const ProfileId('p1'))
        .listen((c) => regions.add(c?.regionPreset));
    await pumpEventQueue();

    await handle.cycleConfig.upsert(config('p1', regionPreset: 'subcontinent'));
    await pumpEventQueue();

    await sub.cancel();
    expect(regions, ['other', 'subcontinent']);
  });
}
