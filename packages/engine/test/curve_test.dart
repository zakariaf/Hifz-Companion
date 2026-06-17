// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// FSRS-4.5 curve + interval (06 §3, §8). Pure `package:test`, no clock, no RNG;
// all inputs are explicit literals. The four definitional anchors were written
// FIRST (red against an unimplemented curve) so a constant drift fails CI before
// it can change a ḥāfiẓ's schedule. Floats assert closeTo (never ==); integer
// day counts assert with ==. Vectors come from the FSRS definition, never the
// engine under test.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

import 'vectors/curve_vectors.dart';

void main() {
  group('curve identity anchors', () {
    test('R(S, S) == 0.9 by definition of kFactor (holds for all S)', () {
      expect(retrievability(10, 10.0), closeTo(0.9, 1e-9));
      expect(retrievability(60, 60.0), closeTo(0.9, 1e-9));
    });

    test('retrievability decays monotonically as elapsed grows', () {
      expect(
        retrievability(20, 10.0),
        lessThan(retrievability(10, 10.0)),
      );
      expect(
        retrievability(10, 10.0),
        lessThan(retrievability(5, 10.0)),
      );
    });
  });

  group('interval identity anchors', () {
    test('I(S, 0.9) == S exactly at kDecay = -0.5', () {
      expect(interval(10.0, 0.9), 10);
      expect(interval(60.0, 0.9), 60);
    });

    test('tier multipliers: 0.95 → 46, 0.97 → 27 (exact 19/81 closed form)',
        () {
      // engineering 06 §8 quotes 45 for 0.95, but that uses the approximate
      // 0.448·S multiplier; the exact kFactor = 19/81 form gives 0.46056·S → 46.
      expect(interval(100.0, 0.95), 46);
      expect(interval(100.0, 0.97), 27);
    });

    test('a higher retention tier is a strictly shorter interval', () {
      expect(interval(100.0, 0.97), lessThan(interval(100.0, 0.95)));
      expect(interval(100.0, 0.95), lessThan(interval(100.0, 0.90)));
    });
  });

  group('frozen oracle table', () {
    test('every retrievability vector reproduces (closeTo 1e-6)', () {
      for (final v in retrievabilityVectors) {
        expect(
          retrievability(v.elapsed, v.s),
          closeTo(v.expected, 1e-6),
          reason: v.notes,
        );
      }
    });

    test('every interval vector reproduces (integer days, ==)', () {
      for (final v in intervalVectors) {
        expect(interval(v.s, v.targetR), v.expected, reason: v.notes);
      }
    });
  });

  group('clamp behaviour — never 0, never past the ceiling', () {
    test('a near-perfect page still returns ≥ 1 day (never "safe to drop")',
        () {
      expect(interval(10.0, 0.999), greaterThanOrEqualTo(1));
      expect(interval(1.0, 0.9999), greaterThanOrEqualTo(1));
    });

    test('a huge interval is clamped to kMaxInterval', () {
      expect(interval(1000000.0, 0.5), kMaxInterval);
    });
  });

  group('determinism — no hidden fuzz', () {
    test('two interval() calls on the same input return the same int', () {
      expect(interval(50.0, 0.9), interval(50.0, 0.9));
      expect(interval(37.5, 0.94), interval(37.5, 0.94));
    });
  });

  group('defensive totality — never NaN, never divide by zero', () {
    test('retrievability with s ≤ 0 is finite (floored at kMinStability)', () {
      expect(retrievability(10, 0).isFinite, isTrue);
      expect(retrievability(10, -5).isFinite, isTrue);
    });

    test('retrievability with negative elapsed clamps to R = 1 (≤ 100%)', () {
      expect(retrievability(-30, 50), closeTo(1.0, 1e-12));
      expect(retrievability(0, 50), closeTo(1.0, 1e-12));
    });

    test('interval with s ≤ 0 still returns ≥ 1 day (never 0/negative)', () {
      expect(interval(0, 0.9), greaterThanOrEqualTo(1));
      expect(interval(-10, 0.9), greaterThanOrEqualTo(1));
    });
  });
}
