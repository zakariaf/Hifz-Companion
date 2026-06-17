// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The engine's named constants + weight vector as data with a length assert
// (06 §8). Pure `package:test`, no clock. The two length-guard cases were
// written FIRST (red against a SchedulingEngine with no assert) so a 19-vs-21
// mismatch fails loudly, never silently mis-schedules. The default vector is
// pinned against an INDEPENDENT frozen oracle (vectors/weights_vectors.dart),
// not asserted against itself.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

import 'vectors/weights_vectors.dart';

void main() {
  group('length assert — the single guarded weight-vector entry point', () {
    test('19 weights (kDefaultWeights45) constructs cleanly', () {
      final engine = SchedulingEngine(EngineConfig.defaults());
      expect(engine.config.weights.length, kFsrsWeightCount);
      expect(kFsrsWeightCount, 19);
    });

    test('a 20-element vector throws an AssertionError (loud, not silent)', () {
      final twenty = [...kDefaultWeights45, 0.5];
      expect(
        () => SchedulingEngine(EngineConfig(weights: twenty)),
        throwsA(isA<AssertionError>()),
      );
    });

    test('an 18-element vector likewise throws (FSRS-pre / truncation)', () {
      final eighteen = kDefaultWeights45.sublist(0, 18);
      expect(
        () => SchedulingEngine(EngineConfig(weights: eighteen)),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('default weight vector — frozen against an independent oracle', () {
    test('length is exactly kFsrsWeightCount', () {
      expect(kDefaultWeights45.length, kFsrsWeightCount);
      expect(oracleDefaultWeights45.length, kFsrsWeightCount);
    });

    test('every weight equals the frozen oracle element-wise (closeTo 1e-9)',
        () {
      for (var i = 0; i < kFsrsWeightCount; i++) {
        expect(
          kDefaultWeights45[i],
          closeTo(oracleDefaultWeights45[i], 1e-9),
          reason: 'w$i drifted from the published FSRS-4.5 default',
        );
      }
    });
  });

  group('named-constant values — single source of truth (06 §8)', () {
    test('FSRS tunables hold their §8 values', () {
      expect(kMinStability, 0.1);
      expect(kMaxInterval, 36500);
      expect(kSelfConfidence, 0.5);
      expect(kLapseDifficultyBump, 1.0);
      expect(kWeakLineFactor, 0.15);
      expect(kHardFloorR, 0.85);
    });

    test('phase thresholds and retention tiers hold their §5 values', () {
      expect(kNearMinS, 9.0);
      expect(kFarMinS, 60.0);
      expect(kGraduationSignoffs, 1);
      expect(kNewTargetR, 0.90);
      expect(kNearTargetR, 0.94);
      expect(kFarTargetR, 0.95);
      expect(kCriticalTargetR, 0.97);
    });

    test('no global 0.99: every retention tier is < 0.99', () {
      const tiers = [kNewTargetR, kNearTargetR, kFarTargetR, kCriticalTargetR];
      for (final r in tiers) {
        expect(r, lessThan(0.99));
      }
    });
  });
}
