// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T04: the local-civil-day fire-time computation, pinned by DST/timezone
// vectors. nextDailyFire fires today when the chosen wall-clock time is still
// ahead, else the same wall-clock time tomorrow; the fire HOUR never drifts
// across a spring-forward / fall-back night (a 24-hour add would shift it by the
// gained/lost hour). Host-timezone independent — every vector pins an explicit
// zone, so the result is identical whatever TZ the test runs under.

import 'package:app/reminders/next_daily_fire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location ny;
  setUpAll(() {
    tzdata.initializeTimeZones();
    ny = tz.getLocation('America/New_York');
  });

  group('nextDailyFire (E18-T04) — local civil day', () {
    test('fires today when the chosen time is still ahead', () {
      final now = tz.TZDateTime(ny, 2026, 6, 15, 6);
      final fire = nextDailyFire(now: now, hour: 7, minute: 0);
      expect([fire.year, fire.month, fire.day], [2026, 6, 15]);
      expect([fire.hour, fire.minute], [7, 0]);
      expect(fire.location, ny); // preserves the device's own zone
      expect(fire.isAfter(now), isTrue);
    });

    test('fires tomorrow when the chosen time has passed', () {
      final now = tz.TZDateTime(ny, 2026, 6, 15, 8);
      final fire = nextDailyFire(now: now, hour: 7, minute: 0);
      expect([fire.month, fire.day], [6, 16]);
      expect([fire.hour, fire.minute], [7, 0]);
    });

    test('exactly at the chosen minute fires tomorrow, never a duplicate today',
        () {
      final now = tz.TZDateTime(ny, 2026, 6, 15, 7);
      final fire = nextDailyFire(now: now, hour: 7, minute: 0);
      expect(fire.day, 16);
      expect([fire.hour, fire.minute], [7, 0]);
    });

    test('rolls a month/year boundary by reconstruction', () {
      final now = tz.TZDateTime(ny, 2026, 12, 31, 23);
      final fire = nextDailyFire(now: now, hour: 6, minute: 30);
      expect([fire.year, fire.month, fire.day], [2027, 1, 1]);
      expect([fire.hour, fire.minute], [6, 30]);
    });
  });

  group('nextDailyFire (E18-T04) — DST does not drift the wall clock', () {
    test('across spring-forward the fire hour stays put (no forward drift)', () {
      // America/New_York springs forward 2026-03-08 02:00 → 03:00 (loses an hour).
      final eveningBefore = tz.TZDateTime(ny, 2026, 3, 7, 20);
      final fire = nextDailyFire(now: eveningBefore, hour: 7, minute: 0);
      expect([fire.month, fire.day], [3, 8]);
      // 07:00 EDT — NOT 08:00, which a fixed Duration(days: 1) add would produce.
      expect([fire.hour, fire.minute], [7, 0]);
      // The night really did cross a DST transition (the offset changed).
      expect(fire.timeZoneOffset, isNot(eveningBefore.timeZoneOffset));
    });

    test('across fall-back the fire hour stays put (no backward drift)', () {
      // America/New_York falls back 2026-11-01 02:00 → 01:00 (gains an hour).
      final eveningBefore = tz.TZDateTime(ny, 2026, 10, 31, 20);
      final fire = nextDailyFire(now: eveningBefore, hour: 7, minute: 0);
      expect([fire.month, fire.day], [11, 1]);
      // 07:00 EST — NOT 06:00, which a fixed Duration(days: 1) add would produce.
      expect([fire.hour, fire.minute], [7, 0]);
      expect(fire.timeZoneOffset, isNot(eveningBefore.timeZoneOffset));
    });

    test('is correct in a southern-hemisphere DST zone too', () {
      // Australia/Sydney springs forward 2026-10-04 02:00 → 03:00.
      final syd = tz.getLocation('Australia/Sydney');
      final eveningBefore = tz.TZDateTime(syd, 2026, 10, 3, 21);
      final fire = nextDailyFire(now: eveningBefore, hour: 7, minute: 0);
      expect([fire.month, fire.day], [10, 4]);
      expect([fire.hour, fire.minute], [7, 0]);
      expect(fire.timeZoneOffset, isNot(eveningBefore.timeZoneOffset));
    });

    test('a no-DST zone (UTC) behaves identically under any host TZ', () {
      final utc = tz.getLocation('UTC');
      final now = tz.TZDateTime(utc, 2026, 6, 15, 6);
      final fire = nextDailyFire(now: now, hour: 7, minute: 0);
      expect([fire.day, fire.hour], [15, 7]);
      expect(fire.location, utc);
    });
  });
}
