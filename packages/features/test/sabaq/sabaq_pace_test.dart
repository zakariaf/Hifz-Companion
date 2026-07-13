// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E21-T03: the sabaq intake pace signal. A 0 pace means new memorization is
// paused/off (no intake surface); any positive pace means it is active. Pure —
// no engine cap, no clock, no I/O.

import 'package:features/features.dart' show sabaqIntakeActive;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show CycleConfig, ProfileId;

CycleConfig config(int newLinesPerDay) => CycleConfig(
      profileId: const ProfileId('p1'),
      cycleType: 'custom',
      nearWindowJuz: 3,
      farTargetPerDay: 4,
      cycleCeilingDays: 30,
      dailyBudgetMinutes: 30,
      termLabelSet: 'classical',
      newLinesPerDay: newLinesPerDay,
    );

void main() {
  test('a 0 pace means intake is paused / off (the opt-in default)', () {
    expect(sabaqIntakeActive(config(0)), isFalse);
  });

  test('any positive pace means intake is active', () {
    expect(sabaqIntakeActive(config(1)), isTrue);
    expect(sabaqIntakeActive(config(5)), isTrue);
    expect(sabaqIntakeActive(config(40)), isTrue);
  });
}
