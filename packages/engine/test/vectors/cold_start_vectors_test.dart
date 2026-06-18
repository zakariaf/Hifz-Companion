// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Cold-start seed golden vectors (06 §5; PRD §7.10). Pure `package:test`, no
// clock — `today`/`memorizedOn` are CalendarDate literals, age is integer
// subtraction. The three seed rows are the frozen oracle (the §5 / §7.10 seed
// table): a future edit that raises a prior fails loudly, so onboarding can
// never silently drift. coldStartCard returns a CardSeed (no profileId — the
// cold-start repository binds it, E03-T08).

import 'package:engine/engine.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

/// One frozen cold-start seed: confidence → exact `(D, S, track)` prior.
class SeedVector {
  const SeedVector(this.confidence, this.d, this.s, this.track, this.notes);

  /// The per-juz self-assessment.
  final JuzConfidence confidence;

  /// The seeded difficulty.
  final double d;

  /// The seeded stability (days).
  final double s;

  /// The entry track the seed's `S` derives.
  final ReviewTrack track;

  /// Why this seed exists.
  final String notes;
}

const seedVectors = <SeedVector>[
  SeedVector(JuzConfidence.solid, 3.0, 60.0, ReviewTrack.far, 'Solid → manzil'),
  SeedVector(JuzConfidence.shaky, 5.0, 14.0, ReviewTrack.near, 'Shaky → near'),
  SeedVector(JuzConfidence.rusty, 7.0, 4.0, ReviewTrack.newPage, 'Rusty → new'),
];

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());
  final today = day(1000);

  group('seed golden vectors (no decay)', () {
    test('each confidence seeds its exact (D, S, track) prior', () {
      for (final v in seedVectors) {
        final seed = engine.coldStartCard(1, v.confidence, today);
        expect(seed.difficulty, closeTo(v.d, 1e-6), reason: v.notes);
        expect(seed.stabilityDays, closeTo(v.s, 1e-6), reason: v.notes);
        expect(seed.track, v.track, reason: v.notes);
      }
    });

    test('the entry track is derived from S, not switched on confidence', () {
      for (final v in seedVectors) {
        final seed = engine.coldStartCard(1, v.confidence, today);
        expect(seed.track, bandForStability(seed.stabilityDays));
      }
    });
  });

  group('calibration due-date (every held page reviewed once early)', () {
    test('dueAt == today and lastReviewedDay == today for every seed', () {
      for (final v in seedVectors) {
        final seed = engine.coldStartCard(1, v.confidence, today);
        expect(seed.dueAt, today);
        expect(seed.lastReviewedDay, today);
        expect(seed.track, isNot(ReviewTrack.unmemorized));
      }
    });
  });

  group('stale-time decay', () {
    test('memorizedOn == today (age 0) leaves S exactly at the seed', () {
      for (final v in seedVectors) {
        final seed = engine.coldStartCard(
          1,
          v.confidence,
          today,
          memorizedOn: today,
        );
        expect(seed.stabilityDays, closeTo(v.s, 1e-9), reason: v.notes);
      }
    });

    test(
        'a juz memorized years ago decays S below the seed into a weaker track',
        () {
      final fiveYearsAgo = day(1000 - 1825);
      final seed = engine.coldStartCard(
        1,
        JuzConfidence.solid,
        today,
        memorizedOn: fiveYearsAgo,
      );
      expect(seed.stabilityDays, lessThan(60.0));
      expect(seed.stabilityDays, greaterThanOrEqualTo(kMinStability));
      final rank = trackStrength(seed.track);
      expect(rank, lessThan(trackStrength(ReviewTrack.far)));
    });

    test('a very old juz never decays below kMinStability', () {
      final longAgo = day(1000 - 36500); // ~100 years
      final seed = engine.coldStartCard(
        1,
        JuzConfidence.solid,
        today,
        memorizedOn: longAgo,
      );
      expect(seed.stabilityDays, greaterThanOrEqualTo(kMinStability));
    });
  });

  group('determinism', () {
    test('coldStartCard is pure: identical inputs → identical seed', () {
      CardSeed seedOf() => engine.coldStartCard(7, JuzConfidence.shaky, today);
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
