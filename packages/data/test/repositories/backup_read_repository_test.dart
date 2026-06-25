// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T07 — the per-profile export read. Seed a profile through the (tested)
// restore write path, then read it back as the export bundle.

import 'package:data/src/db/database.dart';
import 'package:data/src/repositories/backup_read_repository.dart';
import 'package:data/src/repositories/restore_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  const profileId = ProfileId('p1');
  final today = CalendarDate.ymd(2026, 6, 25);
  late HifzDatabase db;

  setUp(() async {
    db = openTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON;');
    await _seedReference(db);
  });
  tearDown(() async => db.close());

  Future<void> seedProfile() => LiveRestoreRepository(db).replaceProfile(
        profile: Profile(
          profileId: profileId,
          displayName: 'Aisha',
          role: ProfileRole.self,
          locale: ProfileLocale.fa,
          mushafId: 'm1',
          createdAtInstant: DateTime.utc(2026),
        ),
        cycleConfig: const CycleConfig(
          profileId: profileId,
          cycleType: '7_manzil',
          nearWindowJuz: 3,
          farTargetPerDay: 4,
          cycleCeilingDays: 7,
          dailyBudgetMinutes: 45,
          termLabelSet: 'classical',
        ),
        cards: <Card>[
          Card(
            profileId: profileId,
            pageId: 1,
            track: ReviewTrack.far,
            difficulty: 6,
            stabilityDays: 20,
            lastReviewedDay: CalendarDate.ymd(2026, 6, 20),
            dueAt: CalendarDate.ymd(2026, 7, 1),
          ),
        ],
        lineBlocks: const <LineBlock>[],
        reviewLog: <ReviewLog>[
          ReviewLog(
            logId: const LogId('l1'),
            profileId: profileId,
            pageId: 1,
            reviewedAtInstant: DateTime.utc(2026, 6, 20),
            trackAtReview: ReviewTrack.far,
            grade: ReviewGrade.good,
            elapsedDays: 5,
            source: GradeSource.self,
          ),
        ],
        confusionEdges: const <ConfusionEdge>[],
        today: today,
      );

  test('readProfileForExport returns every row of the profile', () async {
    await seedProfile();
    final rows = await LiveBackupReadRepository(db).readProfileForExport(profileId);
    expect(rows, isNotNull);
    expect(rows!.profile.displayName, 'Aisha');
    expect(rows.cycleConfig.cycleCeilingDays, 7);
    expect(rows.cards, hasLength(1));
    expect(rows.reviewLog.single.logId.value, 'l1');
  });

  test('returns null for an absent profile', () async {
    expect(
      await LiveBackupReadRepository(db).readProfileForExport(profileId),
      isNull,
    );
  });
}

Future<void> _seedReference(HifzDatabase db) async {
  await db.customStatement(
    "INSERT INTO surah (surah_id, name_ar, revelation, ayah_count, "
    "bismillah_pre) VALUES (1, 'الفاتحة', 'meccan', 7, 1)",
  );
  await db.customStatement(
    "INSERT INTO mushaf (mushaf_id, riwayah, name, line_count, page_count, "
    "font_family, checksum_sha256) "
    "VALUES ('m1', 'hafs_an_asim', 'Madani', 15, 604, 'QCF', 'abc')",
  );
  await db.customStatement(
    'INSERT INTO page (page_id, juz, hizb, rub, surah_start, ayah_start, '
    'surah_end, ayah_end, line_count, qpc_font_name) '
    "VALUES (1, 1, 1, 1, 1, 1, 1, 7, 15, 'QCF_P001')",
  );
}
