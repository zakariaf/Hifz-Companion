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

  test('a self-graded review_log row round-trips identically', () async {
    final log = ReviewLog(
      logId: const LogId('log-1'),
      profileId: const ProfileId('p'),
      pageId: 42,
      reviewedAtInstant: DateTime.utc(2026, 6, 17, 21, 30),
      trackAtReview: ReviewTrack.far,
      grade: ReviewGrade.good,
      errorLineIndices: const [3, 7],
      elapsedDays: 18,
      predictedRetrievability: 0.91,
      stabilityDaysBefore: 24,
      stabilityDaysAfter: 31.5,
      difficultyBefore: 6.4,
      difficultyAfter: 6.2,
      source: GradeSource.self,
    );
    await db.reviewLogDao.insert(log);

    final rows = await db.reviewLogDao.forCard(const ProfileId('p'), 42);
    expect(rows, hasLength(1));
    final read = rows.single;
    expect(read.reviewedAtInstant, DateTime.utc(2026, 6, 17, 21, 30));
    expect(read.reviewedAtInstant.isUtc, isTrue);
    expect(read.elapsedDays, 18);
    expect(read.trackAtReview, ReviewTrack.far);
    expect(read.grade, ReviewGrade.good);
    expect(read.source, GradeSource.self);
    expect(read.errorLineIndices, [3, 7]);
    expect(read.predictedRetrievability, closeTo(0.91, 1e-6));
    expect(read.stabilityDaysBefore, closeTo(24, 1e-6));
    expect(read.stabilityDaysAfter, closeTo(31.5, 1e-6));
    expect(read.difficultyBefore, closeTo(6.4, 1e-6));
    expect(read.difficultyAfter, closeTo(6.2, 1e-6));
    expect(read.teacherLabel, isNull);
  });

  test('a teacher-graded row round-trips the sanad label and null doubles',
      () async {
    final log = ReviewLog(
      logId: const LogId('log-2'),
      profileId: const ProfileId('p'),
      pageId: 42,
      reviewedAtInstant: DateTime.utc(2026, 6, 18, 9),
      trackAtReview: ReviewTrack.far,
      grade: ReviewGrade.again,
      elapsedDays: 1,
      source: GradeSource.teacher,
      teacherLabel: 'Ustadh Yusuf',
    );
    await db.reviewLogDao.insert(log);

    final read = (await db.reviewLogDao.forCard(const ProfileId('p'), 42))
        .firstWhere((r) => r.logId == const LogId('log-2'));
    expect(read.source, GradeSource.teacher);
    expect(read.grade, ReviewGrade.again);
    expect(read.teacherLabel, 'Ustadh Yusuf');
    expect(read.errorLineIndices, isNull);
    expect(read.predictedRetrievability, isNull);
    expect(read.stabilityDaysBefore, isNull);
  });
}
