// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = OFF;');
  });
  tearDown(() async => db.close());

  test('Profile round-trips role/locale enums, UTC instant, settings map',
      () async {
    final profile = Profile(
      profileId: const ProfileId('p'),
      displayName: 'Aisha',
      role: ProfileRole.student,
      locale: ProfileLocale.ckb,
      mushafId: 'hafs_madani_15',
      createdAtInstant: DateTime.utc(2026, 1, 5, 8),
      settings: const {'reminderHour': 20, 'theme': 'sepia'},
    );
    await db.profileDao.upsert(profile);

    final read = await db.profileDao.byId(const ProfileId('p'));
    if (read == null) fail('profile was not persisted');
    expect(read.displayName, 'Aisha');
    expect(read.role, ProfileRole.student);
    expect(read.locale, ProfileLocale.ckb);
    expect(read.mushafId, 'hafs_madani_15');
    expect(read.createdAtInstant, DateTime.utc(2026, 1, 5, 8));
    expect(read.createdAtInstant.isUtc, isTrue);
    expect(read.settings, {'reminderHour': 20, 'theme': 'sepia'});
  });

  test('ConfusionEdge round-trips the canonical ordering and nullable instant',
      () async {
    final edge = ConfusionEdge.between(
      const ProfileId('p'),
      '2:1',
      '2:2',
      weight: 4.5,
      lastConfusedAtInstant: DateTime.utc(2026, 6, 17),
    );
    await db.confusionEdgeDao.upsert(edge);

    final read =
        (await db.confusionEdgeDao.forProfile(const ProfileId('p'))).single;
    expect(read.ayahA, '2:1');
    expect(read.ayahB, '2:2');
    expect(read.weight, closeTo(4.5, 1e-6));
    expect(read.lastConfusedAtInstant, DateTime.utc(2026, 6, 17));
    expect(read.lastConfusedAtInstant?.isUtc, isTrue);
  });

  test('CycleConfig round-trips unit-named ints and the pure-cycle flag',
      () async {
    const config = CycleConfig(
      profileId: ProfileId('p'),
      cycleType: '7_manzil',
      newLinesPerDay: 5,
      nearWindowJuz: 3,
      farTargetPerDay: 4,
      cycleCeilingDays: 7,
      dailyBudgetMinutes: 45,
      isPureCycleMode: true,
      termLabelSet: 'classical',
      regionPreset: 'south_asia',
    );
    await db.cycleConfigDao.upsert(config);

    final read = await db.cycleConfigDao.byProfile(const ProfileId('p'));
    expect(read, config);
  });

  test('LineBlock round-trips line numbers and stumble count', () async {
    const block = LineBlock(
      blockId: BlockId('b1'),
      profileId: ProfileId('p'),
      pageId: 42,
      lineStart: 4,
      lineEnd: 9,
      errorCount: 3,
    );
    await db.lineBlockDao.upsert(block);

    final read =
        (await db.lineBlockDao.forCard(const ProfileId('p'), 42)).single;
    expect(read, block);
  });
}
