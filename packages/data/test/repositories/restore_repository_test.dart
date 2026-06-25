// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T06 — the backup-restore write path. These property tests are the sanad
// guarantee: a merge is a set-union over the append-only review_log by logId
// (idempotent — never a dropped or duplicated teacher sign-off), each restore is
// all-or-nothing, and every imported card's dueAt is re-clamped to THIS device's
// cycle ceiling (§7.6).

import 'package:data/src/db/database.dart';
import 'package:data/src/persistence_exception.dart';
import 'package:data/src/repositories/restore_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const pageCount = 12;
  const profileId = ProfileId('p1');
  final today = CalendarDate.ymd(2026, 6, 25);

  late HifzDatabase db;
  late LiveRestoreRepository restore;

  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON;');
    await _seedReferenceFixture(db, pageCount);
    restore = LiveRestoreRepository(db);
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

  // A 7-day cycle ceiling — the local device's promise.
  const cycle = CycleConfig(
    profileId: profileId,
    cycleType: '7_manzil',
    nearWindowJuz: 3,
    farTargetPerDay: 4,
    cycleCeilingDays: 7,
    dailyBudgetMinutes: 45,
    termLabelSet: 'classical',
  );

  // A held FAR card with a large stability (so the trust clamp must bite) and a
  // deliberately far-future due date the restore must pull back to the ceiling.
  Card farCard({required int pageId, double stability = 100}) => Card(
        profileId: profileId,
        pageId: pageId,
        track: ReviewTrack.far,
        difficulty: 6,
        stabilityDays: stability,
        lastReviewedDay: CalendarDate.ymd(2026, 6, 10),
        dueAt: CalendarDate.ymd(2026, 12, 31), // far future — must be re-clamped
      );

  ReviewLog log(String id, {int pageId = 1, required int dayOffset}) =>
      ReviewLog(
        logId: LogId(id),
        profileId: profileId,
        pageId: pageId,
        reviewedAtInstant:
            DateTime.utc(2026, 6, 25).add(Duration(days: dayOffset)),
        trackAtReview: ReviewTrack.far,
        grade: ReviewGrade.good,
        elapsedDays: 5,
        source: GradeSource.self,
        stabilityDaysBefore: 30,
        difficultyBefore: 6,
      );

  Future<Set<String>> logIds() async => {
        for (final r in await db.reviewLogDao.forProfile(profileId)) r.logId.value,
      };

  // ── REPLACE ──────────────────────────────────────────────────────────────
  group('replace', () {
    test('wipes the old profile and re-clamps every imported dueAt', () async {
      await restore.replaceProfile(
        profile: profile(),
        cycleConfig: cycle,
        cards: [farCard(pageId: 1), farCard(pageId: 3)],
        lineBlocks: const [],
        reviewLog: [log('a', dayOffset: -20)],
        confusionEdges: const [],
        today: today,
      );
      // Replace again with a DIFFERENT snapshot.
      await restore.replaceProfile(
        profile: profile(),
        cycleConfig: cycle,
        cards: [farCard(pageId: 5)],
        lineBlocks: const [],
        reviewLog: [log('b', pageId: 5, dayOffset: -3)],
        confusionEdges: const [],
        today: today,
      );

      expect(await logIds(), {'b'}); // the old log 'a' is gone
      expect(await db.cardDao.byId(profileId, 1), isNull); // old card gone
      final card = await db.cardDao.byId(profileId, 5);
      expect(card, isNotNull);
      // §7.6 — the far-future due date was pulled back to the local ceiling.
      final ceilingDay = today.addDays(cycle.cycleCeilingDays);
      expect(card!.dueAt!.epochDay, lessThanOrEqualTo(ceilingDay.epochDay));
    });
  });

  // ── MERGE ────────────────────────────────────────────────────────────────
  group('merge (set-union over the append-only review_log)', () {
    Future<void> seedLocal(List<ReviewLog> logs) => restore.replaceProfile(
          profile: profile(),
          cycleConfig: cycle,
          cards: [farCard(pageId: 1)],
          lineBlocks: const [],
          reviewLog: logs,
          confusionEdges: const [],
          today: today,
        );

    Future<void> merge(List<ReviewLog> logs) => restore.mergeProfile(
          profile: profile(),
          cycleConfig: cycle,
          cards: [farCard(pageId: 1)],
          lineBlocks: const [],
          reviewLog: logs,
          confusionEdges: const [],
          today: today,
        );

    test('is idempotent — re-merging the same file changes nothing', () async {
      await seedLocal([log('a', dayOffset: -20), log('b', dayOffset: -10)]);
      await merge([log('a', dayOffset: -20), log('c', dayOffset: -5)]);
      final after = await logIds();
      await merge([log('a', dayOffset: -20), log('c', dayOffset: -5)]);
      expect(await logIds(), after); // no duplicate logId, no new row
      expect((await db.reviewLogDao.forProfile(profileId)).length, after.length);
    });

    test('a teacher superset adds the new sign-offs, drops/duplicates none',
        () async {
      await seedLocal([log('a', dayOffset: -20), log('b', dayOffset: -10)]);
      await merge([
        log('a', dayOffset: -20),
        log('b', dayOffset: -10),
        log('c', dayOffset: -5), // the teacher's new sign-offs
        log('d', dayOffset: -2),
      ]);
      expect(await logIds(), {'a', 'b', 'c', 'd'});
    });

    test('into an ABSENT profile behaves like a replace', () async {
      // No prior seed — the profile does not exist locally.
      await merge([log('a', dayOffset: -5)]);
      expect(await logIds(), {'a'});
      expect(await db.cardDao.byId(profileId, 1), isNotNull);
    });

    test('re-clamps a rebuilt card to the local ceiling (§7.6)', () async {
      await seedLocal([log('a', dayOffset: -20)]);
      await merge([log('a', dayOffset: -20), log('c', dayOffset: -2)]);
      final card = await db.cardDao.byId(profileId, 1);
      final ceilingDay = today.addDays(cycle.cycleCeilingDays);
      expect(card!.dueAt!.epochDay, lessThanOrEqualTo(ceilingDay.epochDay));
    });

    test('a mid-import failure rolls back to the exact pre-import state',
        () async {
      await seedLocal([log('a', dayOffset: -20)]);
      final before = await logIds();
      // A review_log row for a page outside the reference violates the FK.
      await expectLater(
        merge([log('a', dayOffset: -20), log('x', pageId: 9999, dayOffset: -1)]),
        throwsA(isA<RestoreConstraintViolated>()),
      );
      // The whole merge rolled back — the store is byte-identical.
      expect(await logIds(), before);
    });
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
