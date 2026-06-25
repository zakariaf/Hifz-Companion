// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T07: the CycleConfigWriter cycle methods. A named preset writes its
// cycle_type and the trust-clamp ceiling (cycleCeilingDays → EngineConfig.
// farCycleDays); Pure-cycle flips exactly one flag; the daily budget and the
// four Custom fields persist. ProfileRepository/CycleConfig faked; offline guard.

import 'package:composition/composition.dart'
    show cycleConfigRepositoryProvider, initialActiveProfileProvider;
import 'package:features/features.dart'
    show CyclePreset, cycleConfigWriterProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';
import 'fake_profiles.dart';

void main() {
  useOfflineTestPolicy();

  (ProviderContainer, FakeCycleConfigRepository) setup() {
    final fake = FakeCycleConfigRepository([fakeCycleConfig('p1')]);
    final container = ProviderContainer(
      overrides: [
        cycleConfigRepositoryProvider.overrideWithValue(fake),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
      ],
    );
    return (container, fake);
  }

  test('a named preset writes its cycle_type and trust-clamp ceiling', () async {
    final (container, fake) = setup();
    addTearDown(container.dispose);
    await container
        .read(cycleConfigWriterProvider)
        .setCyclePreset(CyclePreset.oneJuzPerDay);
    expect(fake.store['p1']!.cycleType, '1_juz_day');
    expect(fake.store['p1']!.cycleCeilingDays, 30);
  });

  test('weekly khatm maps to a 7-day ceiling', () async {
    final (container, fake) = setup();
    addTearDown(container.dispose);
    await container
        .read(cycleConfigWriterProvider)
        .setCyclePreset(CyclePreset.weeklyKhatm);
    expect(fake.store['p1']!.cycleType, '7_manzil');
    expect(fake.store['p1']!.cycleCeilingDays, 7);
  });

  test('Pure-cycle flips exactly one flag', () async {
    final (container, fake) = setup();
    addTearDown(container.dispose);
    final before = fake.store['p1']!;
    await container
        .read(cycleConfigWriterProvider)
        .setPureCycle(enabled: true);
    final after = fake.store['p1']!;
    expect(after.isPureCycleMode, isTrue);
    // Reverting the one flag yields the original — nothing else moved.
    expect(after.copyWith(isPureCycleMode: false), before);
  });

  test('the daily budget persists', () async {
    final (container, fake) = setup();
    addTearDown(container.dispose);
    await container.read(cycleConfigWriterProvider).setDailyBudget(45);
    expect(fake.store['p1']!.dailyBudgetMinutes, 45);
  });

  test('the Custom editor writes the four bounded fields', () async {
    final (container, fake) = setup();
    addTearDown(container.dispose);
    await container.read(cycleConfigWriterProvider).setCustomCycle(
          farCycleDays: 45,
          nearWindowJuz: 5,
          newLinesPerDay: 10,
        );
    final c = fake.store['p1']!;
    expect(c.cycleType, 'custom');
    expect(c.cycleCeilingDays, 45);
    expect(c.nearWindowJuz, 5);
    expect(c.newLinesPerDay, 10);
  });
}
