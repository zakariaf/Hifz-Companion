// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// EngineConfig — the sabaq-intake allotment field (E21-T01). The app ships as
// pure maintenance (default 0, opt-in); a negative allotment is a construction
// bug, never a silent value.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group('EngineConfig.newLinesPerDay', () {
    test('defaults to 0 — the app ships as pure maintenance (opt-in sabaq)', () {
      expect(const EngineConfig().newLinesPerDay, 0);
      expect(EngineConfig.defaults().newLinesPerDay, 0);
    });

    test('carries a positive opt-in allotment', () {
      expect(const EngineConfig(newLinesPerDay: 5).newLinesPerDay, 5);
    });

    test('a negative allotment fails loudly at construction', () {
      expect(
        () => EngineConfig(newLinesPerDay: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('the existing fields keep their defaults (a new field breaks nothing)',
        () {
      const config = EngineConfig(newLinesPerDay: 3);
      expect(config.farCycleDays, 30);
      expect(config.nearCeilingDays, 7);
      expect(config.dailyBudgetMinutes, 30);
      expect(config.pureCycleMode, isFalse);
    });
  });
}
