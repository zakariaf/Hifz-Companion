// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The grading-signal value type the engine consumes (06 §2; PRD §8). Pure
// `package:test`, deterministic, no clock — these are value-type assertions, no
// arithmetic. The non-null-dueAt invariant lives on the `models` Card and is
// pinned by that package's card_test.dart; the engine re-exports Card and the
// closed-set enums, which the barrel re-export test below pins by construction.

import 'package:engine/engine.dart';
import 'package:models/models.dart' show ProfileId;
import 'package:test/test.dart';

void main() {
  group('ReviewInput shape', () {
    test('defaults: errorLines empty, missedOrAlteredWord false', () {
      final rv = ReviewInput(grade: ReviewGrade.good, source: GradeSource.self);
      expect(rv.errorLines, isEmpty);
      expect(rv.missedOrAlteredWord, isFalse);
      expect(rv.grade, ReviewGrade.good);
      expect(rv.source, GradeSource.self);
    });

    test('keeps 1-based stumble-line indices and the guard flag', () {
      final rv = ReviewInput(
        grade: ReviewGrade.again,
        source: GradeSource.teacher,
        errorLines: const [1, 4, 13],
        missedOrAlteredWord: true,
      );
      expect(rv.errorLines, [1, 4, 13]);
      expect(rv.missedOrAlteredWord, isTrue);
      expect(rv.source, GradeSource.teacher);
    });

    test('errorLines is effectively immutable — a passed list cannot mutate it',
        () {
      final mutable = [1, 2, 3];
      final rv = ReviewInput(
        grade: ReviewGrade.hard,
        source: GradeSource.self,
        errorLines: mutable,
      );
      mutable.add(99); // mutate the caller's list AFTER construction
      expect(rv.errorLines, [1, 2, 3]); // stored value is unaffected
      // The stored list is unmodifiable, not just a defensive copy.
      expect(() => rv.errorLines.add(0), throwsUnsupportedError);
    });
  });

  group('ReviewInput value equality', () {
    test('identical fields are == and share a hashCode', () {
      final a = ReviewInput(
        grade: ReviewGrade.good,
        source: GradeSource.teacher,
        errorLines: const [2, 5],
      );
      final b = ReviewInput(
        grade: ReviewGrade.good,
        source: GradeSource.teacher,
        errorLines: const [2, 5],
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing one field breaks equality', () {
      final base = ReviewInput(
        grade: ReviewGrade.good,
        source: GradeSource.teacher,
        errorLines: const [2, 5],
      );
      final differentGrade = ReviewInput(
        grade: ReviewGrade.hard,
        source: GradeSource.teacher,
        errorLines: const [2, 5],
      );
      final differentSource = ReviewInput(
        grade: ReviewGrade.good,
        source: GradeSource.self,
        errorLines: const [2, 5],
      );
      final differentLines = ReviewInput(
        grade: ReviewGrade.good,
        source: GradeSource.teacher,
        errorLines: const [2],
      );
      final differentGuard = ReviewInput(
        grade: ReviewGrade.good,
        source: GradeSource.teacher,
        errorLines: const [2, 5],
        missedOrAlteredWord: true,
      );
      expect(base, isNot(differentGrade));
      expect(base, isNot(differentSource));
      expect(base, isNot(differentLines));
      expect(base, isNot(differentGuard));
    });
  });

  group('JuzConfidence', () {
    test('declares exactly solid / shaky / rusty (PRD §7.10)', () {
      expect(JuzConfidence.values, [
        JuzConfidence.solid,
        JuzConfidence.shaky,
        JuzConfidence.rusty,
      ]);
    });
  });

  group('engine barrel re-exports the models value types', () {
    test('Card and the closed-set enums resolve through package:engine', () {
      // A compile-time pin: if a refactor stopped re-exporting these, this file
      // would fail to resolve. Construction also proves the field shape the
      // engine reads (difficulty/stabilityDays/dueAt/track).
      final card = Card(
        profileId: const ProfileId('p'),
        pageId: 1,
        track: ReviewTrack.far,
        difficulty: 5,
        stabilityDays: 60,
        lastReviewedDay: CalendarDate.ymd(2026, 6, 1),
        dueAt: CalendarDate.ymd(2026, 6, 8),
      );
      expect(card.track, ReviewTrack.far);
      expect(card.dueAt, isNotNull);
      expect(ReviewGrade.values.length, 4);
      expect(GradeSource.values, [GradeSource.self, GradeSource.teacher]);
    });
  });
}
