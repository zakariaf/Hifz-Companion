// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Smoke test for the pure-Dart engine package boundary (06 §1). It proves the
// public barrel resolves and compiles as a workspace member, and documents that
// the engine's offline guarantee is STRUCTURAL, not a runtime override: the
// package declares no `http`/`dio` and no `dart:io`, so there is no socket to
// reach and nothing for an `HttpOverrides` to intercept — installing one here
// would itself import `dart:io` and trip `tool/check_engine_purity.sh`. The
// no-network/no-clock guard is the `meta`(+`models`)-only dependency line plus
// that grep gate, not code in this file (matches the day-math suite's note).
//
// `package:test` only — plain `dart test`, no `flutter_test`, no widget binding.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group('engine package boundary', () {
    test('the public barrel resolves and the package compiles', () {
      // Touch a re-exported symbol so the import is load-bearing, not unused:
      // CalendarDate is the injected "today" type every engine function takes.
      final today = CalendarDate.ymd(2026, 6, 17);
      expect(today.epochDay, isA<int>());
      expect(true, isTrue);
    });
  });
}
