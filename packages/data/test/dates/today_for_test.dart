// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Pure-day-logic suite for the "today" edge function `todayFor` (07 §5). No
// widget binding, no wall-clock read in any assertion — every `DateTime` is a
// literal and every expectation a `CalendarDate.ymd(...)`. The shared throwing
// HttpOverrides offline guard stays installed; this suite touches no network.

import 'package:data/data.dart';
import 'package:engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('todayFor names the local civil day', () {
    test('a local-zone literal returns that calendar day', () {
      expect(todayFor(DateTime(2026, 6, 16, 9)), CalendarDate.ymd(2026, 6, 16));
    });

    test('23:00 local lands on the local day, never rolls forward', () {
      // 23:00 local on 2026-06-16: the civil day is June 16, not the next day
      // (the §5/T10 boundary intent). The hostile-timezone variant is E02-T08.
      final at2300 = todayFor(DateTime(2026, 6, 16, 23));
      expect(at2300, CalendarDate.ymd(2026, 6, 16));
    });
  });

  group('todayFor applies .toLocal() once, like civilDayOf', () {
    test('a UTC instant is named by its local civil day (same as civilDayOf)',
        () {
      final inst = DateTime.utc(2026, 6, 16, 19, 30);
      expect(todayFor(inst), civilDayOf(inst));
      expect(
        todayFor(inst),
        CalendarDate.ymd(
          inst.toLocal().year,
          inst.toLocal().month,
          inst.toLocal().day,
        ),
      );
    });
  });
}
