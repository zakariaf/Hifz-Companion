// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Confusion-aware grading (E14-T04): a logged swap raises D on every confusable
// group member, and the existing (11−D) factor in stabilityOnSuccess turns the
// higher D into a shorter interval — no bespoke override, no second scheduler
// (PRD §9.2; science 05 §4; CLAIMS C-029; engineering 06 §4). Pure `package:test`
// — no flutter_test, no widget binding, no network (the engine is pure Dart).
//
// The D-bump magnitude is frozen exact arithmetic (D + kConfusionDifficultyBump ×
// weight, clamped); the "shorter interval" is asserted RELATIONALLY against the
// no-swap run through the real onReview — the smaller stability (always) and the
// strictly-earlier due (under a non-binding ceiling) are the (11−D) consequence,
// never numbers blessed from the engine under test.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

void main() {
  // A deliberately huge cycle ceiling so the SR-ideal interval (not the trust
  // clamp) binds — that is where the (11−D) shortening is observable in `due`.
  final engine = SchedulingEngine(const EngineConfig(farCycleDays: 3650));
  final goodTeacher = ReviewInput(
    grade: ReviewGrade.good,
    source: GradeSource.teacher,
  );

  group('the D-bump magnitude is exact (frozen arithmetic)', () {
    test('D += kConfusionDifficultyBump × weight, clamped to [1,10]', () {
      final base = testCard();
      final bumped = applyConfusionBump([base], 2).single;
      expect(
        bumped.difficulty,
        closeTo(base.difficulty + kConfusionDifficultyBump * 2, 1e-6),
      );
    });

    test('a heavy weight cannot push D above 10 (clamp holds)', () {
      final base = testCard(difficulty: 9);
      final bumped = applyConfusionBump([base], 1000).single;
      expect(bumped.difficulty, 10.0);
    });

    test('a zero weight (or empty group) is the identity', () {
      final base = testCard(difficulty: 4.2);
      expect(applyConfusionBump([base], 0).single.difficulty, 4.2);
      expect(applyConfusionBump(const [], 5), isEmpty);
    });
  });

  group('the bump touches ONLY D — no bespoke interval override', () {
    test('applyConfusionBump changes no S / dueAt', () {
      final base = testCard(
        stabilityDays: 42,
        dueAt: day(200),
      );
      final bumped = applyConfusionBump([base], 3).single;
      expect(bumped.stabilityDays, base.stabilityDays);
      expect(bumped.dueAt, base.dueAt);
      expect(bumped.difficulty, greaterThan(base.difficulty));
    });
  });

  group('the shorter interval comes only from the (11−D) channel', () {
    // A well-established page reviewed on-time Good, under the huge ceiling so
    // the SR-ideal binds and the day-granular interval gap is visible.
    final base = testCard(
      stabilityDays: 200,
      lastReviewedDay: day(100),
      dueAt: day(130),
    );
    final today = day(130);

    test('a swapped page returns SOONER, explained by a smaller stability', () {
      final noSwap =
          engine.onReview(base, goodTeacher, today, weakLineCount: 0);
      final swapped = engine.onReview(
        applyConfusionBump([base], 4).single,
        goodTeacher,
        today,
        weakLineCount: 0,
      );

      // (11−D): higher input D → smaller stability gain.
      expect(swapped.stabilityDays, lessThan(noSwap.stabilityDays));
      // …and therefore a strictly earlier next-due, with no extra subtraction.
      expect(
        swapped.dueAt!.epochDay - today.epochDay,
        lessThan(noSwap.dueAt!.epochDay - today.epochDay),
      );
    });

    test('full strength regardless of source: the D bump is not source-scaled',
        () {
      // applyConfusionBump has no source parameter, so a self vs teacher review
      // bumps D identically; only the stability GAIN differs by kSelfConfidence.
      final bumped = applyConfusionBump([base], 4).single;
      final goodSelf = ReviewInput(
        grade: ReviewGrade.good,
        source: GradeSource.self,
      );
      final viaTeacher =
          engine.onReview(bumped, goodTeacher, today, weakLineCount: 0);
      final viaSelf =
          engine.onReview(bumped, goodSelf, today, weakLineCount: 0);
      // The input D into both reviews was identical (the bump ignored source).
      expect(
        bumped.difficulty,
        closeTo(base.difficulty + kConfusionDifficultyBump * 4, 1e-6),
      );
      // Source still scales only the S move (teacher gains more than self).
      expect(viaTeacher.stabilityDays, greaterThan(viaSelf.stabilityDays));
    });
  });

  group('the trust clamp still runs last (INV-1 unchanged)', () {
    test('a bumped page never returns past its cycle ceiling', () {
      final far = SchedulingEngine(EngineConfig.defaults());
      final base = testCard(
        lastReviewedDay: day(100),
        dueAt: day(130),
      );
      final today = day(130);
      final swapped = far.onReview(
        applyConfusionBump([base], 10).single,
        goodTeacher,
        today,
        weakLineCount: 0,
      );
      expect(
        swapped.dueAt!.epochDay - today.epochDay,
        lessThanOrEqualTo(cycleCeilingDays(swapped, EngineConfig.defaults())),
      );
    });
  });
}
