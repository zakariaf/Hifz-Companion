// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The onReview update path (06 §4; PRD §7.7). Pure `package:test` + `glados`,
// no clock, no RNG — `today`/`lastReview` are explicit CalendarDate literals and
// elapsed is integer subtraction. The sacred-text-cap case and the golden
// vectors were written FIRST: an inverted branch would let a forgotten page earn
// a longer interval, or a dropped word read "Good". Floats assert closeTo, never
// ==. Vectors come from the FSRS definition (vectors/review_update_vectors.dart),
// never the engine under test.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';
import 'package:models/models.dart' show ProfileId;

import 'vectors/review_update_vectors.dart';

CalendarDate day(int v) => CalendarDate.fromEpochDay(v);

Card card({
  required double d,
  required double s,
  CalendarDate? lastReview,
  ReviewTrack track = ReviewTrack.far,
}) =>
    Card(
      profileId: const ProfileId('p'),
      pageId: 42,
      track: track,
      difficulty: d,
      stabilityDays: s,
      lastReviewedDay: lastReview,
      dueAt: lastReview ?? day(0),
    );

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());

  group('golden vectors — both stability branches + Hard/Easy multipliers', () {
    test('every frozen row reproduces (D, S) to closeTo 1e-6', () {
      for (final v in reviewUpdateVectors) {
        final out = engine.onReview(
          card(d: v.dIn, s: v.sIn, lastReview: day(100)),
          ReviewInput(grade: v.grade, source: GradeSource.teacher),
          day(100 + v.elapsed),
          weakLineCount: 0,
        );
        expect(out.difficulty, closeTo(v.dOut, 1e-6), reason: v.notes);
        expect(out.stabilityDays, closeTo(v.sOut, 1e-6), reason: v.notes);
      }
    });

    test('success grows S; Hard < Good < Easy; a lapse shrinks S below prior',
        () {
      double sOf(ReviewGrade g) => engine
          .onReview(
            card(d: 5, s: 30, lastReview: day(100)),
            ReviewInput(grade: g, source: GradeSource.teacher),
            day(130),
            weakLineCount: 0,
          )
          .stabilityDays;
      expect(sOf(ReviewGrade.good), greaterThan(30));
      expect(sOf(ReviewGrade.hard), lessThan(sOf(ReviewGrade.good)));
      expect(sOf(ReviewGrade.easy), greaterThan(sOf(ReviewGrade.good)));
      expect(sOf(ReviewGrade.again), lessThan(30));
    });
  });

  group('sacred-text guard (R1) — a dropped word is NEVER Good', () {
    // PRD §7.7 / R1: cap the grade at Hard BEFORE any arithmetic; the cap only
    // ever lowers.
    Card review(ReviewGrade g, {bool flag = false}) => engine.onReview(
          card(d: 5, s: 30, lastReview: day(100)),
          ReviewInput(
            grade: g,
            source: GradeSource.teacher,
            missedOrAlteredWord: flag,
          ),
          day(130),
          weakLineCount: 0,
        );

    test('Easy + missedOrAlteredWord yields exactly a Hard outcome', () {
      final hard = review(ReviewGrade.hard);
      final easyFlagged = review(ReviewGrade.easy, flag: true);
      expect(easyFlagged.difficulty, closeTo(hard.difficulty, 1e-12));
      expect(easyFlagged.stabilityDays, closeTo(hard.stabilityDays, 1e-12));
    });

    test('Good + missedOrAlteredWord yields exactly a Hard outcome', () {
      final hard = review(ReviewGrade.hard);
      final goodFlagged = review(ReviewGrade.good, flag: true);
      expect(goodFlagged.difficulty, closeTo(hard.difficulty, 1e-12));
      expect(goodFlagged.stabilityDays, closeTo(hard.stabilityDays, 1e-12));
    });

    test('Again + missedOrAlteredWord stays Again (the cap only lowers)', () {
      final again = review(ReviewGrade.again);
      final againFlagged = review(ReviewGrade.again, flag: true);
      expect(againFlagged.difficulty, closeTo(again.difficulty, 1e-12));
      expect(againFlagged.stabilityDays, closeTo(again.stabilityDays, 1e-12));
    });
  });

  group('source confidence (C-021) — self moves S less, only the gain', () {
    Card grade(GradeSource source) => engine.onReview(
          card(d: 5, s: 30, lastReview: day(100)),
          ReviewInput(grade: ReviewGrade.good, source: source),
          day(130),
          weakLineCount: 0,
        );

    test('self gain is exactly kSelfConfidence × the teacher gain', () {
      final teacher = grade(GradeSource.teacher);
      final self = grade(GradeSource.self);
      final teacherGain = teacher.stabilityDays - 30;
      final selfGain = self.stabilityDays - 30;
      expect(selfGain, closeTo(kSelfConfidence * teacherGain, 1e-9));
      expect(selfGain, lessThan(teacherGain));
    });

    test('the D change is identical across sources (only the S gain differs)',
        () {
      expect(
        grade(GradeSource.self).difficulty,
        closeTo(grade(GradeSource.teacher).difficulty, 1e-12),
      );
    });
  });

  group('weak-line (11−D) channel — full strength regardless of source', () {
    Card weak(int count, GradeSource source) => engine.onReview(
          card(d: 5, s: 30, lastReview: day(100)),
          ReviewInput(grade: ReviewGrade.good, source: source),
          day(130),
          weakLineCount: count,
        );

    test('D increases by kWeakLineFactor × weakLineCount (clamped)', () {
      final base = weak(0, GradeSource.teacher);
      final bumped = weak(2, GradeSource.teacher);
      expect(
        bumped.difficulty,
        closeTo(base.difficulty + kWeakLineFactor * 2, 1e-9),
      );
    });

    test('the bump is identical for self and teacher (graph truth)', () {
      expect(
        weak(2, GradeSource.self).difficulty,
        closeTo(weak(2, GradeSource.teacher).difficulty, 1e-12),
      );
    });

    test('a higher D yields a measurably shorter next interval ((11−D))', () {
      final base = weak(0, GradeSource.teacher);
      final bumped = weak(2, GradeSource.teacher);
      // Same S after this review; the higher D shrinks the NEXT success gain.
      final nextBase = stabilityOnSuccess(
        kDefaultWeights45,
        base.difficulty,
        base.stabilityDays,
        0.9,
        1,
        1,
      );
      final nextBumped = stabilityOnSuccess(
        kDefaultWeights45,
        bumped.difficulty,
        bumped.stabilityDays,
        0.9,
        1,
        1,
      );
      expect(nextBumped, lessThan(nextBase));
    });
  });

  group('lapse never grows stability (postLapseStability ≤ s)', () {
    test('clamp holds for several (d, s, r)', () {
      for (final t in [
        [5.0, 30.0, 0.7],
        [2.0, 5.0, 0.5],
        [9.0, 100.0, 0.95],
      ]) {
        final sf = postLapseStability(kDefaultWeights45, t[0], t[1], t[2]);
        expect(sf, lessThanOrEqualTo(t[1]));
        expect(sf, greaterThanOrEqualTo(kMinStability));
      }
    });

    Glados2<int, int>(any.intInRange(1, 200), any.intInRange(0, 365))
        .test('Again ⇒ S\' ≤ S, lapses++, weak set (INV-3 seed)', (sInt, gap) {
      final before = card(d: 5, s: sInt.toDouble(), lastReview: day(0));
      final lapse = ReviewInput(
        grade: ReviewGrade.again,
        source: GradeSource.teacher,
      );
      final after = engine.onReview(before, lapse, day(gap), weakLineCount: 0);
      expect(after.stabilityDays, lessThanOrEqualTo(before.stabilityDays));
      expect(after.lapses, before.lapses + 1);
      expect(after.isWeak, isTrue);
    });
  });

  group('determinism + stub boundary', () {
    test('onReview is pure: identical inputs → byte-identical Card', () {
      final c = card(d: 5, s: 30, lastReview: day(100));
      final rv = ReviewInput(grade: ReviewGrade.good, source: GradeSource.self);
      expect(
        engine.onReview(c, rv, day(130), weakLineCount: 1),
        engine.onReview(c, rv, day(130), weakLineCount: 1),
      );
    });

    test('a memorized result has a finite, non-null dueAt (stub honours T07)',
        () {
      // The real min(ideal, ceiling) clamp + ceiling guarantee land in E04-T07;
      // here we only assert no memorized card escapes with a null/absent dueAt.
      final out = engine.onReview(
        card(d: 5, s: 30, lastReview: day(100)),
        ReviewInput(grade: ReviewGrade.good, source: GradeSource.teacher),
        day(130),
        weakLineCount: 0,
      );
      expect(out.dueAt, isNotNull);
      expect(out.dueAt!.epochDay, lessThan(kMaxInterval + 130));
    });
  });
}
