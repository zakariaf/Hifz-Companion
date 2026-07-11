// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The new-memorization (sabaq) intake write path (E21-T02). One transaction
// inserts one New card for a newly-memorized page; a re-mark is refused (never a
// clobber of live D/S); a malformed seed rolls back to zero rows. Intake writes
// no review_log row — the sanad is a log of recitations only.

import 'package:data/src/db/database.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:data/src/repositories/cold_start_repository.dart';
import 'package:data/src/repositories/sabaq_intake_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const pageCount = 12;
  const profileId = ProfileId('p1');
  final today = CalendarDate.ymd(2026, 7, 11);

  late HifzDatabase db;
  late LiveSabaqIntakeRepository repository;

  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON;');
    await _seedReferenceFixture(db, pageCount);
    // A profile with ZERO cards — the real starting state of a from-zero
    // beginner (and the F04 in-app profile). Intake grows it from here.
    await LiveColdStartRepository(db)
        .seedColdStart(_profile(), _cycleConfig, const []);
    repository = LiveSabaqIntakeRepository(db);
  });
  tearDown(() async => db.close());

  // The engine's conservative fresh-sabaq prior (E21-T01), constructed directly
  // so the data test stays independent of the engine.
  CardSeed sabaqSeed(int page) => CardSeed(
        pageId: page,
        track: ReviewTrack.newPage,
        difficulty: 7,
        stabilityDays: 4,
        lastReviewedDay: today,
        dueAt: today,
      );

  Future<int> cardCount() async {
    final row =
        await db.customSelect('SELECT COUNT(*) AS n FROM card').getSingle();
    return row.read<int>('n');
  }

  test('starting a page memorizes it as one New card, due today', () async {
    await repository.startMemorizing(profileId, sabaqSeed(3));

    expect(await cardCount(), 1);
    final card = await db.cardDao.byId(profileId, 3);
    if (card == null) fail('the sabaq card was not committed');
    expect(card.track, ReviewTrack.newPage);
    expect(card.difficulty, 7);
    expect(card.stabilityDays, 4);
    expect(card.dueAt, today);
    expect(card.lastReviewedDay, today);
  });

  test('re-marking an already-started page is refused, never a clobber',
      () async {
    await repository.startMemorizing(profileId, sabaqSeed(3));

    // A second attempt with a *different* prior must not overwrite the live card.
    final clobber = CardSeed(
      pageId: 3,
      track: ReviewTrack.newPage,
      difficulty: 1, // would inflate difficulty if it clobbered
      stabilityDays: 99, // would inflate stability if it clobbered
      lastReviewedDay: today,
      dueAt: today,
    );
    await expectLater(
      repository.startMemorizing(profileId, clobber),
      throwsA(isA<SabaqPageAlreadyStarted>()),
    );

    expect(await cardCount(), 1);
    final card = await db.cardDao.byId(profileId, 3);
    expect(card!.difficulty, 7, reason: 'the original prior is untouched');
    expect(card.stabilityDays, 4, reason: 'the original prior is untouched');
  });

  test('a malformed seed rolls back to zero new cards', () async {
    // A New card with a null due day trips the card CHECK
    // (track != UNMEMORIZED => due_at NOT NULL).
    const bad = CardSeed(
      pageId: 5,
      track: ReviewTrack.newPage,
      difficulty: 7,
      stabilityDays: 4,
    );
    await expectLater(
      repository.startMemorizing(profileId, bad),
      throwsA(isA<SabaqIntakeConstraintViolated>()),
    );
    expect(await cardCount(), 0);
  });

  test('intake appends no review_log row — the sanad is recitations only',
      () async {
    await repository.startMemorizing(profileId, sabaqSeed(3));
    final log = await db
        .customSelect('SELECT COUNT(*) AS n FROM review_log')
        .getSingle();
    expect(log.read<int>('n'), 0);
  });

  test('memory is never newer than disk: the committed card is on disk',
      () async {
    await repository.startMemorizing(profileId, sabaqSeed(7));
    // A fresh read over the same connection sees the durably-committed row.
    final onDisk = await db.cardDao.byId(profileId, 7);
    expect(onDisk, isNotNull);
    expect(onDisk!.track, ReviewTrack.newPage);
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
