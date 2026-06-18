// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Phases, stakes-tiered retention, and predictable sign-off-gated graduation
// (06 §5; PRD §7.4, §7.5). Pure `package:test`, no clock. The fluency gate and
// the no-global-0.99 guard were written FIRST. Constants by name, never inlined
// 9/60/0.97. Interval consequences come from the FSRS definition.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';
import 'vectors/retention_tiers_vectors.dart';

void main() {
  group('phaseOf — derived from S, manualLock wins, boundaries exercised', () {
    test('S-band boundaries map to the right phase', () {
      ReviewTrack phaseAt(double s) => phaseOf(testCard(stabilityDays: s));
      expect(phaseAt(kNearMinS - 0.1), ReviewTrack.newPage);
      expect(phaseAt(kNearMinS), ReviewTrack.near);
      expect(phaseAt(kFarMinS - 0.1), ReviewTrack.near);
      expect(phaseAt(kFarMinS), ReviewTrack.far);
    });

    test('an unmemorized card is unmemorized regardless of S', () {
      expect(
        phaseOf(testCard(track: ReviewTrack.unmemorized, stabilityDays: 100)),
        ReviewTrack.unmemorized,
      );
    });

    test('a manualLock card returns its stored track even when S disagrees',
        () {
      // track defaults to far; S=5 would say New, but the teacher pin wins.
      final pinned = testCard(stabilityDays: 5, hasManualLock: true);
      expect(phaseOf(pinned), ReviewTrack.far);
    });
  });

  group('targetR — stakes-tiered, never a global 0.99', () {
    test('each phase maps to its frozen tier (and the interval consequence)',
        () {
      expect(targetR(testCard(stabilityDays: 5)), retentionTiers[0].targetR);
      expect(targetR(testCard(stabilityDays: 20)), retentionTiers[1].targetR);
      expect(targetR(testCard(stabilityDays: 70)), retentionTiers[2].targetR);
      for (final tier in retentionTiers) {
        expect(
          interval(100, tier.targetR),
          tier.intervalAt100,
          reason: tier.label,
        );
      }
    });

    test('Far escalates to the critical tier for prayer-critical/weak/lapsed',
        () {
      final critical = testCard(stabilityDays: 70, isPrayerCritical: true);
      final weak = testCard(stabilityDays: 70, isWeak: true);
      final lapsed = testCard(stabilityDays: 70, lapses: 1);
      expect(targetR(critical), kCriticalTargetR);
      expect(targetR(weak), kCriticalTargetR);
      expect(targetR(lapsed), kCriticalTargetR);
    });

    test('a higher tier is a strictly shorter interval', () {
      final critical = interval(100, kCriticalTargetR);
      final far = interval(100, kFarTargetR);
      final near = interval(100, kNearTargetR);
      final fresh = interval(100, kNewTargetR);
      expect(critical, lessThan(far));
      expect(far, lessThan(near));
      expect(near, lessThan(fresh));
    });

    test('no targetR is ever ≥ 0.99 (the never-global-0.99 covenant)', () {
      for (final s in [5.0, 20.0, 70.0]) {
        final ordinary = targetR(testCard(stabilityDays: s));
        final escalated =
            targetR(testCard(stabilityDays: s, isPrayerCritical: true));
        expect(ordinary, lessThan(0.99));
        expect(escalated, lessThan(0.99));
      }
    });
  });

  group('graduation New → Near — fluency AND sign-offs gated', () {
    // sBand=near (S≥kNearMinS); stored track held at New until the gate passes.
    Card promote(ReviewGrade grade, GradeSource source) => updateGraduation(
          testCard(track: ReviewTrack.newPage, stabilityDays: 20),
          grade,
          source,
          inRecentWindow: true,
        );

    test('Easy with a teacher sign-off (reaches kGraduationSignoffs) promotes',
        () {
      final t = promote(ReviewGrade.easy, GradeSource.teacher).track;
      expect(t, ReviewTrack.near);
    });

    test('the same Easy review one sign-off short does NOT promote', () {
      // A self Easy does not increment signoffs → stays below kGraduationSignoffs.
      final t = promote(ReviewGrade.easy, GradeSource.self).track;
      expect(t, ReviewTrack.newPage);
    });

    test('a correct-but-effortful Good/Hard never promotes (fluency gate)', () {
      final good = promote(ReviewGrade.good, GradeSource.teacher).track;
      final hard = promote(ReviewGrade.hard, GradeSource.teacher).track;
      expect(good, ReviewTrack.newPage);
      expect(hard, ReviewTrack.newPage);
    });

    test('a New page reaching far-band S graduates only ONE level (to Near)',
        () {
      // Even with far-band S and an Easy sign-off, a New page may not skip the
      // Near/sabqi consolidation phase straight to Far in a single review.
      final newAtFarS =
          testCard(track: ReviewTrack.newPage, stabilityDays: 100);
      final after = updateGraduation(
        newAtFarS,
        ReviewGrade.easy,
        GradeSource.teacher,
        inRecentWindow: false,
      );
      expect(after.track, ReviewTrack.near);
    });
  });

  group('graduation Near → Far — S ≥ kFarMinS AND outside window AND fluency',
      () {
    Card promote({
      required double s,
      required ReviewGrade grade,
      required bool inWindow,
    }) =>
        updateGraduation(
          testCard(track: ReviewTrack.near, stabilityDays: s),
          grade,
          GradeSource.teacher,
          inRecentWindow: inWindow,
        );

    test('all three conditions met → Far', () {
      final t = promote(s: 70, grade: ReviewGrade.easy, inWindow: false).track;
      expect(t, ReviewTrack.far);
    });

    test('S below kFarMinS blocks promotion', () {
      final t = promote(s: 30, grade: ReviewGrade.easy, inWindow: false).track;
      expect(t, ReviewTrack.near);
    });

    test('still in the recent-juz window blocks promotion', () {
      final t = promote(s: 70, grade: ReviewGrade.easy, inWindow: true).track;
      expect(t, ReviewTrack.near);
    });

    test('a non-fluent Good blocks promotion', () {
      final t = promote(s: 70, grade: ReviewGrade.good, inWindow: false).track;
      expect(t, ReviewTrack.near);
    });
  });

  group('manualLock freezes graduation', () {
    test('a pinned card is never auto-promoted or demoted', () {
      // track defaults to far; S=5 would demote, but the pin stands.
      final pinned = testCard(stabilityDays: 5, hasManualLock: true);
      final after = updateGraduation(
        pinned,
        ReviewGrade.again,
        GradeSource.teacher,
        inRecentWindow: false,
      );
      expect(after.track, ReviewTrack.far);
    });
  });
}
