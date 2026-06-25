// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The engine is injected as a plain DI Provider: it opens no IO, so it resolves
// live with no override, and a buildToday on an empty card set is a pure call.

import 'package:composition/composition.dart';
import 'package:engine/engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show CycleConfig, ProfileId;

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('engineProvider resolves to a SchedulingEngine with no override', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(engineProvider), isA<SchedulingEngine>());
  });

  test('the injected engine is a pure function: empty cards → empty day plan',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final plan = container
        .read(engineProvider)
        .buildToday(const [], CalendarDate.ymd(2026, 6, 19));
    expect(plan.items, isEmpty);
  });

  test('falls back to the engine defaults when no cycle config is active (E16-T07)',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(engineProvider).config.farCycleDays,
      EngineConfig.defaults().farCycleDays,
    );
  });

  test('reflects the active profile cycle ceiling, mode, and budget (E16-T07)',
      () async {
    const config = CycleConfig(
      profileId: ProfileId('p1'),
      cycleType: '7_manzil',
      nearWindowJuz: 1,
      farTargetPerDay: 87,
      cycleCeilingDays: 7,
      dailyBudgetMinutes: 20,
      termLabelSet: 'classical',
      isPureCycleMode: true,
    );
    final container = ProviderContainer(
      overrides: [
        activeCycleConfigProvider.overrideWith((ref) => Stream.value(config)),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(engineProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();

    final engineConfig = container.read(engineProvider).config;
    expect(engineConfig.farCycleDays, 7); // = cycleCeilingDays
    expect(engineConfig.pureCycleMode, isTrue);
    expect(engineConfig.dailyBudgetMinutes, 20);
    // The near ceiling is clamped to the cycle so it never exceeds farCycleDays.
    expect(engineConfig.nearCeilingDays, lessThanOrEqualTo(7));
  });
}
