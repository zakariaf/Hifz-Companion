// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Proves the injected-"today" boundary: an `overrideWithValue` makes
// `ref.read(todayProvider)` return a fixed `CalendarDate` with no clock read —
// the deterministic double the engine goldens (E04) and the DST matrix (E02-T08)
// rely on. The shared throwing HttpOverrides offline guard stays installed.

import 'package:composition/composition.dart';
import 'package:engine/engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('todayProvider is an injectable, fixed-date-overridable clock', () {
    test('overrideWithValue returns exactly that date, no clock read', () {
      final fixed = CalendarDate.ymd(2026, 6, 16);
      final container = ProviderContainer(
        overrides: [todayProvider.overrideWithValue(fixed)],
      );
      addTearDown(container.dispose);

      expect(container.read(todayProvider), fixed);
    });

    test('two reads within a session return the identical date', () {
      final fixed = CalendarDate.ymd(2026, 6, 16);
      final container = ProviderContainer(
        overrides: [todayProvider.overrideWithValue(fixed)],
      );
      addTearDown(container.dispose);

      expect(container.read(todayProvider), container.read(todayProvider));
      expect(container.read(todayProvider), fixed);
    });

    test('the default body produces a CalendarDate via the todayFor edge', () {
      // The one sanctioned clock read; its value is host-dependent, so only the
      // type — a CalendarDate produced through the todayFor edge — is asserted.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(todayProvider), isA<CalendarDate>());
    });
  });
}
