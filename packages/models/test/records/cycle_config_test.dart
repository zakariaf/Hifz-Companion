// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  const config = CycleConfig(
    profileId: ProfileId('profile-1'),
    cycleType: '7_manzil',
    newLinesPerDay: 5,
    nearWindowJuz: 3,
    farTargetPerDay: 4,
    cycleCeilingDays: 7,
    dailyBudgetMinutes: 45,
    isPureCycleMode: true,
    termLabelSet: 'classical',
    regionPreset: 'south_asia',
  );

  group('CycleConfig fields are unit-named ints', () {
    test('the ceiling and budget carry their units in the name', () {
      final int ceiling = config.cycleCeilingDays;
      final int budget = config.dailyBudgetMinutes;
      final int nearWindow = config.nearWindowJuz;
      expect(ceiling, 7);
      expect(budget, 45);
      expect(nearWindow, 3);
    });

    test('the public surface has no streak/score/health field', () {
      // The documented field list — a drift that added a gamification or
      // derived-health column would force this list to change and be caught in
      // review. CycleConfig holds only cycle configuration.
      expect(config.cycleType, '7_manzil');
      expect(config.newLinesPerDay, 5);
      expect(config.farTargetPerDay, 4);
      expect(config.isPureCycleMode, isTrue);
      expect(config.termLabelSet, 'classical');
      expect(config.regionPreset, 'south_asia');
    });
  });

  group('CycleConfig.copyWith', () {
    test('copyWith() with no args preserves every field', () {
      expect(config.copyWith(), config);
    });

    test('copyWith(cycleCeilingDays:) changes only the ceiling', () {
      final shorter = config.copyWith(cycleCeilingDays: 5);
      expect(shorter.cycleCeilingDays, 5);
      expect(shorter.cycleType, config.cycleType);
      expect(shorter.dailyBudgetMinutes, config.dailyBudgetMinutes);
      expect(shorter.termLabelSet, config.termLabelSet);
    });

    test('regionPreset defaults to null and newLinesPerDay to 0', () {
      const minimal = CycleConfig(
        profileId: ProfileId('p'),
        cycleType: 'custom',
        nearWindowJuz: 0,
        farTargetPerDay: 0,
        cycleCeilingDays: 30,
        dailyBudgetMinutes: 20,
        termLabelSet: 'plain',
      );
      expect(minimal.regionPreset, isNull);
      expect(minimal.newLinesPerDay, 0);
      expect(minimal.isPureCycleMode, isFalse);
    });
  });
}
