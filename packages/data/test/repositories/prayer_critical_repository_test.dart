// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The prayer-critical toggle write path (E21-T08). One transaction flips a held
// page's flag; unknown pages and unchanged values are calm no-ops; it writes no
// review_log row (a preference, not a recitation).

import 'package:data/src/db/database.dart';
import 'package:data/src/repositories/cold_start_repository.dart';
import 'package:data/src/repositories/prayer_critical_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const profileId = ProfileId('p1');
  late HifzDatabase db;
  late LivePrayerCriticalRepository repository;

  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON;');
    await _seedReferenceFixture(db);
    // A profile holding page 3 (a FAR card), not prayer-critical.
    await LiveColdStartRepository(db).seedColdStart(
      _profile(),
      _cycleConfig,
      [
        CardSeed(
          pageId: 3,
          track: ReviewTrack.far,
          difficulty: 6,
          stabilityDays: 30,
          lastReviewedDay: CalendarDate.ymd(2026, 6, 1),
          dueAt: CalendarDate.ymd(2026, 6, 17),
        ),
      ],
    );
    repository = LivePrayerCriticalRepository(db);
  });
  tearDown(() async => db.close());

  test('marking a held page prayer-critical persists the flag', () async {
    expect((await db.cardDao.byId(profileId, 3))!.isPrayerCritical, isFalse);
    await repository.setPrayerCritical(profileId, 3, value: true);
    expect((await db.cardDao.byId(profileId, 3))!.isPrayerCritical, isTrue);
    // …and un-marking restores it.
    await repository.setPrayerCritical(profileId, 3, value: false);
    expect((await db.cardDao.byId(profileId, 3))!.isPrayerCritical, isFalse);
  });

  test('an unknown page is a calm no-op (nothing thrown, nothing written)',
      () async {
    await repository.setPrayerCritical(profileId, 99, value: true);
    expect(await db.cardDao.byId(profileId, 99), isNull);
  });

  test('the toggle writes no review_log row (the sanad is recitations only)',
      () async {
    await repository.setPrayerCritical(profileId, 3, value: true);
    final log = await db
        .customSelect('SELECT COUNT(*) AS n FROM review_log')
        .getSingle();
    expect(log.read<int>('n'), 0);
  });
}

Profile _profile() => Profile(
      profileId: const ProfileId('p1'),
      displayName: 'Aisha',
      role: ProfileRole.self,
      locale: ProfileLocale.fa,
      mushafId: 'm1',
      createdAtInstant: DateTime.utc(2026, 6, 17),
    );

const _cycleConfig = CycleConfig(
  profileId: ProfileId('p1'),
  cycleType: '7_manzil',
  nearWindowJuz: 3,
  farTargetPerDay: 4,
  cycleCeilingDays: 7,
  dailyBudgetMinutes: 45,
  termLabelSet: 'classical',
);

Future<void> _seedReferenceFixture(HifzDatabase db) async {
  await db.customStatement(
    "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
    "bismillah_pre) VALUES (1, 'الفاتحة', 'meccan', 7, 1)",
  );
  await db.customStatement(
    "INSERT INTO mushaf (mushaf_id, riwayah, name, line_count, page_count, "
    "font_family, checksum_sha256) "
    "VALUES ('m1', 'hafs_an_asim', 'Madani', 15, 604, 'QCF', 'abc')",
  );
  await db.transaction(() async {
    for (var page = 1; page <= 4; page++) {
      await db.customStatement(
        'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
        'surah_end, ayah_end, line_count, qpc_font_name) '
        "VALUES ($page, 1, 1, 1, 1, 1, 1, 7, 15, 'QCF_P001')",
      );
    }
  });
}
