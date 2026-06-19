// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The engine is injected as a plain DI Provider: it opens no IO, so it resolves
// live with no override, and a buildToday on an empty card set is a pure call.

import 'package:composition/composition.dart';
import 'package:engine/engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
