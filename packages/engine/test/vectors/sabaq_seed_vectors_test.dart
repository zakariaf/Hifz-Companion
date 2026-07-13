// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Sabaq (new-memorization) seed golden vectors (E21-T01; PRD §7.8; 06 §5). Pure
// `package:test`, no clock — `today` is a CalendarDate literal. The single seed
// row is the frozen oracle: a future edit that raises the fresh-sabaq prior
// fails loudly, so intake can never silently drift. `sabaqSeed` returns a
// CardSeed (no profileId — the sabaq-intake repository binds it, E21-T02), it
// is a *seed* act (it creates a card), never a graduation transition.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

// The frozen fresh-sabaq prior — a page memorized *today* enters active
// revision (the New track), conservatively under-estimated so the first
// recitation can only surprise upward (C-009). If these change, it must be a
// deliberate, reviewed edit — this row exists to fail the build otherwise.
const double _sabaqD = 7.0;
const double _sabaqS = 4.0;

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());
  final today = day(1000);

  group('sabaq seed golden vector', () {
    test('a newly-memorized page seeds the exact (D, S) prior on the New track',
        () {
      final seed = engine.sabaqSeed(7, today);
      expect(seed.difficulty, closeTo(_sabaqD, 1e-6));
      expect(seed.stabilityDays, closeTo(_sabaqS, 1e-6));
      expect(seed.track, ReviewTrack.newPage);
      expect(seed.pageId, 7);
    });

    test('the entry track is derived from S, not hard-coded', () {
      final seed = engine.sabaqSeed(7, today);
      expect(seed.track, bandForStability(seed.stabilityDays));
      // Conservative prior stays strictly inside the New band.
      expect(seed.stabilityDays, lessThan(kNearMinS));
      expect(seed.stabilityDays, greaterThanOrEqualTo(kMinStability));
    });
  });

  group('enters the schedule immediately (first revision today)', () {
    test('dueAt == today and lastReviewedDay == today; never unmemorized', () {
      final seed = engine.sabaqSeed(120, today);
      expect(seed.dueAt, today);
      expect(seed.lastReviewedDay, today);
      expect(seed.track, isNot(ReviewTrack.unmemorized));
      // The schema invariant: a non-unmemorized card always has a due date.
      expect(seed.dueAt, isNotNull);
    });

    test('difficulty and stability are inside their valid domains', () {
      final seed = engine.sabaqSeed(604, today);
      expect(seed.difficulty, inInclusiveRange(1.0, 10.0));
      expect(seed.stabilityDays, greaterThanOrEqualTo(0.0));
    });
  });

  group('page bounds + determinism', () {
    test('accepts every muṣḥaf page 1..604 and rejects out-of-range in asserts',
        () {
      expect(engine.sabaqSeed(1, today).pageId, 1);
      expect(engine.sabaqSeed(604, today).pageId, 604);
      expect(() => engine.sabaqSeed(0, today), throwsA(isA<AssertionError>()));
      expect(() => engine.sabaqSeed(605, today), throwsA(isA<AssertionError>()));
    });

    test('sabaqSeed is pure: identical inputs → identical seed', () {
      CardSeed seedOf() => engine.sabaqSeed(42, today);
      final a = seedOf();
      final b = seedOf();
      expect(a.difficulty, b.difficulty);
      expect(a.stabilityDays, b.stabilityDays);
      expect(a.track, b.track);
      expect(a.dueAt, b.dueAt);
      expect(a.pageId, b.pageId);
    });
  });
}
