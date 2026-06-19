// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Kill-and-relaunch crash safety (PRD §17): a committed review is durable across
// a relaunch of the file-backed WAL store. The durability mechanism is
// `synchronous = FULL` (asserted by connection_pragmas_test) — it fsyncs the WAL
// on every commit, so the review is on disk the instant commitReview resolves,
// before any graceful shutdown. Here we prove the round-trip: provision a card,
// commit a review, drop the handle, reopen the SAME file through the SAME
// connection setup, and find the new card state + the appended review_log row.

import 'dart:io';

import 'package:data/src/db/connection.dart';
import 'package:data/src/db/database.dart';
import 'package:data/src/live_persistence_handle.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import 'db/test_database.dart';
import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late Directory tempDir;
  setUp(() {
    ensureTestSqlite3Loaded();
    tempDir = Directory.systemTemp.createTempSync('hifz_crash');
  });
  tearDown(() => tempDir.deleteSync(recursive: true));

  HifzDatabase openFileDatabase() => HifzDatabase(
        NativeDatabase(
          File('${tempDir.path}/hifz.sqlite'),
          setup: applyConnectionSetup,
        ),
      );

  Future<void> seedReference(HifzDatabase db) async {
    await db.customStatement(
      "INSERT INTO mushaf (mushaf_id, riwayah, name, line_count, page_count, "
      "font_family, checksum_sha256) "
      "VALUES ('m1', 'hafs_an_asim', 'Madani', 15, 604, 'QCF', 'abc')",
    );
    await db.customStatement(
      "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
      "bismillah_pre) VALUES (1, 'الفاتحة', 'meccan', 7, 1)",
    );
    await db.customStatement(
      'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
      'surah_end, ayah_end, line_count, qpc_font_name) '
      "VALUES (1, 1, 1, 1, 1, 1, 1, 7, 15, 'QCF_P001')",
    );
  }

  test('a committed review survives a relaunch of the WAL store', () async {
    const profileId = ProfileId('p1');

    // --- Launch 1: provision a profile + one card, then commit a review. ---
    final db1 = openFileDatabase();
    await seedReference(db1);
    final handle1 = LivePersistenceHandle(db1);

    await handle1.coldStart.seedColdStart(
      Profile(
        profileId: profileId,
        displayName: 'self',
        role: ProfileRole.self,
        locale: ProfileLocale.fa,
        mushafId: 'm1',
        createdAtInstant: DateTime.utc(2026, 6, 19),
      ),
      const CycleConfig(
        profileId: profileId,
        cycleType: '7_manzil',
        nearWindowJuz: 3,
        farTargetPerDay: 4,
        cycleCeilingDays: 7,
        dailyBudgetMinutes: 30,
        termLabelSet: 'classical',
      ),
      [
        CardSeed(
          pageId: 1,
          track: ReviewTrack.far,
          difficulty: 5,
          stabilityDays: 30,
          lastReviewedDay: CalendarDate.ymd(2026, 6, 1),
          dueAt: CalendarDate.ymd(2026, 6, 19),
        ),
      ],
    );

    final before = await handle1.cards.byId(profileId, 1);
    final reviewed = before!.copyWith(
      dueAt: CalendarDate.ymd(2026, 7, 19),
      reps: before.reps + 1,
      stabilityDays: 45,
    );
    await handle1.reviews.commitReview(
      ReviewOutcome(
        logRow: ReviewLog(
          logId: const LogId('log-1'),
          profileId: profileId,
          pageId: 1,
          reviewedAtInstant: DateTime.utc(2026, 6, 19),
          trackAtReview: ReviewTrack.far,
          grade: ReviewGrade.good,
          elapsedDays: 18,
          source: GradeSource.self,
        ),
        cardUpdate: reviewed,
      ),
    );

    // The commit is durable now (synchronous=FULL). Release the handle to
    // relaunch — a real crash after this point would lose nothing.
    await handle1.close();

    // --- Launch 2: reopen the SAME file. ---
    final db2 = openFileDatabase();
    final handle2 = LivePersistenceHandle(db2);
    addTearDown(handle2.close);

    final after = await handle2.cards.byId(profileId, 1);
    expect(after, isNotNull);
    expect(after!.dueAt, CalendarDate.ymd(2026, 7, 19));
    expect(after.reps, before.reps + 1);
    expect(after.stabilityDays, closeTo(45, 1e-9));

    final logCount = (await db2
            .customSelect('SELECT COUNT(*) AS n FROM review_log')
            .getSingle())
        .read<int>('n');
    expect(
      logCount,
      1,
      reason: 'the appended review_log row survived relaunch',
    );
  });
}
