// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:data/src/repositories/cold_start_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // A representative page count: it exercises the same single batch.insertAll
  // path as the 604-page production seed, all in one outer transaction.
  const pageCount = 12;
  const profileId = ProfileId('p1');

  late HifzDatabase db;
  late LiveColdStartRepository repository;

  setUp(() async {
    db = openTestDatabase();
    // FK ON: the profile-before-cards ordering is real referential integrity.
    await db.customStatement('PRAGMA foreign_keys = ON;');
    await _seedReferenceFixture(db, pageCount);
    repository = LiveColdStartRepository(db);
  });
  tearDown(() async => db.close());

  Profile profile() => Profile(
        profileId: profileId,
        displayName: 'Aisha',
        role: ProfileRole.self,
        locale: ProfileLocale.fa,
        mushafId: 'm1',
        createdAtInstant: DateTime.utc(2026, 6, 17),
      );

  const cycleConfig = CycleConfig(
    profileId: profileId,
    cycleType: '7_manzil',
    nearWindowJuz: 3,
    farTargetPerDay: 4,
    cycleCeilingDays: 7,
    dailyBudgetMinutes: 45,
    termLabelSet: 'classical',
  );

  // A held FAR card on the odd pages, an un-held UNMEMORIZED card on the even.
  List<CardSeed> validSeeds() => [
        for (var page = 1; page <= pageCount; page++)
          if (page.isOdd)
            CardSeed(
              pageId: page,
              track: ReviewTrack.far,
              difficulty: 6,
              stabilityDays: 30,
              lastReviewedDay: CalendarDate.ymd(2026, 6, 1),
              dueAt: CalendarDate.ymd(2026, 6, 17),
            )
          else
            CardSeed(
              pageId: page,
              track: ReviewTrack.unmemorized,
              difficulty: 5,
              stabilityDays: 0,
            ),
      ];

  Future<int> countOf(String table) async {
    final row =
        await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle();
    return row.read<int>('n');
  }

  test('a mid-seed failure leaves zero rows — no partial profile', () async {
    // One held card with a null due day trips the card CHECK inside the batch;
    // the profile inserted in step 1 must roll back with it.
    final seeds = [
      ...validSeeds(),
      const CardSeed(
        pageId: 1,
        track: ReviewTrack.far, // held...
        difficulty: 6,
        stabilityDays: 30, // ...but dueAt is null -> CHECK violated
      ),
    ];

    await expectLater(
      repository.seedColdStart(profile(), cycleConfig, seeds),
      throwsA(isA<ColdStartWriteException>()),
    );

    expect(await countOf('profile'), 0);
    expect(await countOf('card'), 0);
    expect(await countOf('cycle_config'), 0);
  });

  test('the happy path commits the profile, all cards, and the cycle_config',
      () async {
    await repository.seedColdStart(profile(), cycleConfig, validSeeds());

    expect(await countOf('profile'), 1);
    expect(await countOf('card'), pageCount);
    expect(await countOf('cycle_config'), 1);

    // Held card persisted verbatim (consume-not-recompute, CalendarDate-serial).
    final held = await db.cardDao.byId(profileId, 1);
    if (held == null) fail('held card was not committed');
    expect(held.track, ReviewTrack.far);
    expect(held.dueAt, CalendarDate.ymd(2026, 6, 17));

    // Un-held page is UNMEMORIZED with a null due day.
    final unheld = await db.cardDao.byId(profileId, 2);
    if (unheld == null) fail('un-held card was not committed');
    expect(unheld.track, ReviewTrack.unmemorized);
    expect(unheld.dueAt, isNull);
  });

  test('FK ordering holds: the seed commits without a foreign-key error',
      () async {
    // The cards reference the profile; committing cleanly proves the profile
    // row was inserted before the card batch (FK ON).
    await repository.seedColdStart(profile(), cycleConfig, validSeeds());
    expect(await countOf('card'), pageCount);
  });

  test('memory is never newer than disk: a failed seed then a retry succeeds',
      () async {
    await expectLater(
      repository.seedColdStart(profile(), cycleConfig, [
        const CardSeed(
          pageId: 1,
          track: ReviewTrack.far,
          difficulty: 6,
          stabilityDays: 30,
        ),
      ]),
      throwsA(isA<ColdStartWriteException>()),
    );
    expect(await countOf('profile'), 0);

    // The failed attempt left nothing behind, so the retry provisions cleanly.
    await repository.seedColdStart(profile(), cycleConfig, validSeeds());
    expect(await countOf('profile'), 1);
    expect(await countOf('card'), pageCount);
  });
}

Future<void> _seedReferenceFixture(HifzDatabase db, int pageCount) async {
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
    for (var page = 1; page <= pageCount; page++) {
      await db.customStatement(
        'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
        'surah_end, ayah_end, line_count, qpc_font_name) '
        "VALUES ($page, 1, 1, 1, 1, 1, 1, 7, 15, 'QCF_P001')",
      );
    }
  });
}
