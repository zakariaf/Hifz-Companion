// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The trust clamp + cycle ceiling (06 §6; PRD §7.6, §7.11). Pure
// `package:glados`, no clock — day counts are integer arithmetic. INV-1 (the
// covenant) is written FIRST: a `max` where `min` belongs would push a page past
// its ceiling — the silent-decay failure the product exists to prevent. INV-1's
// canonical home is the register in invariants_test.dart (E04-T11); this is its
// test-first landing.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import 'support/fixtures.dart';

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults()); // far 30, near 7
  final today = day(130);

  group('min, never max — the clamp direction', () {
    test('idealDue < ceilingDue → ideal (SR pulled forward)', () {
      // far S=60 → interval(60, 0.95)=28 < farCycleDays 30.
      final due = engine.trustClamp(testCard(stabilityDays: 60), today);
      expect(due, today.addDays(28));
    });

    test('idealDue > ceilingDue → ceiling (ideal clamped down)', () {
      // far S=1000 → interval ≫ 30; clamped to today + farCycleDays.
      final due = engine.trustClamp(testCard(stabilityDays: 1000), today);
      expect(due, today.addDays(30));
    });

    test('idealDue == ceilingDue → that day (equal is harmless)', () {
      final tight = SchedulingEngine(const EngineConfig(farCycleDays: 28));
      final due = tight.trustClamp(testCard(stabilityDays: 60), today);
      expect(due, today.addDays(28));
    });
  });

  group('cycleCeilingDays — pure function of card + config', () {
    for (final cfg in [
      const EngineConfig(farCycleDays: 7), // near defaults to 7 (== far here)
      const EngineConfig(farCycleDays: 21), // near defaults to 7 (< far)
    ]) {
      test(
          'far/new/unmemorized → farCycleDays, near → nearCeilingDays '
          '(far=${cfg.farCycleDays})', () {
        final far = cycleCeilingDays(testCard(stabilityDays: 100), cfg);
        final near = cycleCeilingDays(testCard(stabilityDays: 20), cfg);
        final fresh = cycleCeilingDays(testCard(stabilityDays: 5), cfg);
        final unmemorized =
            cycleCeilingDays(testCard(track: ReviewTrack.unmemorized), cfg);
        expect(far, cfg.farCycleDays);
        expect(near, cfg.nearCeilingDays);
        expect(fresh, cfg.farCycleDays);
        expect(unmemorized, cfg.farCycleDays);
      });
    }
  });

  group('pure-cycle mode — fixed rotation, ceiling = farCycleDays everywhere',
      () {
    // far/near default to 30/7; pure-cycle makes every phase clamp to far (30).
    const pure = EngineConfig(pureCycleMode: true);
    test('every phase clamps to farCycleDays, not the per-phase ceiling', () {
      expect(cycleCeilingDays(testCard(stabilityDays: 100), pure), 30);
      expect(cycleCeilingDays(testCard(stabilityDays: 20), pure), 30); // not 7
      expect(cycleCeilingDays(testCard(stabilityDays: 5), pure), 30);
    });
  });

  group('the strongest page is still clamped', () {
    test('a far S=1000 page comes back at today + farCycleDays, never longer',
        () {
      final due = engine.trustClamp(testCard(stabilityDays: 1000), today);
      expect(due.epochDay - today.epochDay, 30);
    });
  });

  group('the clamp reads the POST-review phase (after graduation)', () {
    test('a near page lifted into the far band gets the far ceiling', () {
      // S=55 (near) + a fluent Easy grows S past kFarMinS → phaseOf far.
      final out = engine.onReview(
        testCard(
          track: ReviewTrack.near,
          stabilityDays: 55,
          lastReviewedDay: day(80),
        ),
        ReviewInput(grade: ReviewGrade.easy, source: GradeSource.teacher),
        today,
        weakLineCount: 0,
      );
      expect(phaseOf(out), ReviewTrack.far); // S crossed kFarMinS
      expect(cycleCeilingDays(out, engine.config), 30);
      expect(out.dueAt!.epochDay - today.epochDay, lessThanOrEqualTo(30));
    });
  });

  group('config invariant', () {
    test('nearCeilingDays > farCycleDays trips the assert', () {
      // farCycleDays defaults to 30; near 40 > far 30 trips the assert.
      expect(
        () => EngineConfig(nearCeilingDays: 40),
        throwsA(isA<AssertionError>()),
      );
    });

    test('a non-positive farCycleDays trips the assert (no modulo-by-zero)',
        () {
      expect(
        () => EngineConfig(farCycleDays: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // INV-1 — THE TRUST CLAMP. PRD §7.6: SR may only make a page MORE frequent,
  // never push it past the cycle. A `max` stub would fail this.
  Glados3<int, int, int>(
    any.intInRange(1, 300),
    any.intInRange(0, ReviewGrade.values.length),
    any.intInRange(0, 400),
  ).test('due_at − today ≤ cycleCeilingDays, always', (sInt, gi, gap) {
    final out = engine.onReview(
      testCard(stabilityDays: sInt.toDouble(), lastReviewedDay: day(0)),
      ReviewInput(grade: ReviewGrade.values[gi], source: GradeSource.teacher),
      day(gap),
      weakLineCount: 0,
    );
    expect(
      out.dueAt!.epochDay - day(gap).epochDay,
      lessThanOrEqualTo(cycleCeilingDays(out, engine.config)),
    );
  });
}
