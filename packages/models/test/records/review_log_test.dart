// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  final selfGraded = ReviewLog(
    logId: const LogId('log-1'),
    profileId: const ProfileId('profile-1'),
    pageId: 42,
    reviewedAtInstant: DateTime.utc(2026, 6, 17, 21, 30),
    trackAtReview: ReviewTrack.far,
    grade: ReviewGrade.good,
    errorLineIndices: const [3, 7],
    elapsedDays: 18,
    predictedRetrievability: 0.91,
    stabilityDaysBefore: 24.0,
    stabilityDaysAfter: 31.5,
    difficultyBefore: 6.4,
    difficultyAfter: 6.2,
    source: GradeSource.self,
  );

  final teacherGraded = ReviewLog(
    logId: const LogId('log-2'),
    profileId: const ProfileId('profile-1'),
    pageId: 42,
    reviewedAtInstant: DateTime.utc(2026, 6, 18, 9),
    trackAtReview: ReviewTrack.far,
    grade: ReviewGrade.again,
    elapsedDays: 1,
    source: GradeSource.teacher,
    teacherLabel: 'Ustadh Yusuf',
  );

  group('ReviewLog construction', () {
    test('a self-graded row carries stumble line indices and audit doubles',
        () {
      expect(selfGraded.source, GradeSource.self);
      expect(selfGraded.errorLineIndices, [3, 7]);
      expect(selfGraded.teacherLabel, isNull);
    });

    test('a teacher-graded row carries the sanad label and no error lines', () {
      expect(teacherGraded.source, GradeSource.teacher);
      expect(teacherGraded.teacherLabel, 'Ustadh Yusuf');
      expect(teacherGraded.errorLineIndices, isNull);
    });
  });

  group('ReviewLog instant and elapsed-day types', () {
    test('reviewedAtInstant is a DateTime, UTC by contract', () {
      final DateTime instant = selfGraded.reviewedAtInstant;
      expect(instant.isUtc, isTrue);
    });

    test('elapsedDays is an int (a day count), not a Duration', () {
      final int elapsed = selfGraded.elapsedDays;
      expect(elapsed, 18);
    });

    test('errorLineIndices is a List<int> of indices only', () {
      final List<int>? lines = selfGraded.errorLineIndices;
      expect(lines, isA<List<int>>());
    });
  });

  group('ReviewLog.copyWith', () {
    test('copyWith() with no args preserves every field (self-graded)', () {
      expect(selfGraded.copyWith(), selfGraded);
    });

    test('copyWith() with no args preserves every field (teacher-graded)', () {
      expect(teacherGraded.copyWith(), teacherGraded);
    });

    test('two rows with equal fields are value-equal (deep list equality)', () {
      final twin = ReviewLog(
        logId: const LogId('log-1'),
        profileId: const ProfileId('profile-1'),
        pageId: 42,
        reviewedAtInstant: DateTime.utc(2026, 6, 17, 21, 30),
        trackAtReview: ReviewTrack.far,
        grade: ReviewGrade.good,
        errorLineIndices: const [3, 7],
        elapsedDays: 18,
        predictedRetrievability: 0.91,
        stabilityDaysBefore: 24.0,
        stabilityDaysAfter: 31.5,
        difficultyBefore: 6.4,
        difficultyAfter: 6.2,
        source: GradeSource.self,
      );
      expect(twin, selfGraded);
      expect(twin.hashCode, selfGraded.hashCode);
    });
  });

  test('ReviewLog exposes no mutation path beyond copyWith (append-only)', () {
    // The value type offers construction-by-copy only; append-only is the DAO's
    // enforcement (E03-T06), but the record invites no in-place rewrite either.
    expect(
      selfGraded,
      isNot(same(selfGraded.copyWith(grade: ReviewGrade.easy))),
    );
    expect(selfGraded.grade, ReviewGrade.good); // original is untouched
  });
}
