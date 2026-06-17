// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Pure-engine unit suite for `CalendarDate` (07 §1–§2). `package:test` only —
// no flutter_test, no widget binding, no wall clock. Every date is a constructed
// `CalendarDate.ymd(...)` literal; the type opens no socket by construction (the
// engine bans dart:io, so the offline guard is structural, not installed here).
//
// Written TEST-FIRST: the T1 `addDays` and T2 `daysUntil` DST pins below existed
// and failed (red) before the `CalendarDate` body — the off-by-one-day class the
// whole epic exists to remove is pinned, not patched (07 §7 T1/T2).

import 'package:engine/engine.dart';
import 'package:test/test.dart';

void main() {
  // 2026 US daylight-saving transitions: spring-forward 2026-03-08 (clocks lose
  // an hour), fall-back 2026-11-01 (clocks gain an hour). A `Duration`/`add`
  // based day-shift lands on the wrong calendar day across these; `addDays` on
  // an epoch-day integer cannot (07 §2).
  group('T1 — addDays is DST-immune', () {
    test('spring-forward week: +1 day is exactly +1 epochDay', () {
      final mar7 = CalendarDate.ymd(2026, 3, 7);
      final mar8 = CalendarDate.ymd(2026, 3, 8); // the spring-forward date
      expect(mar7.addDays(1), mar8);
      expect(mar8.epochDay - mar7.epochDay, 1);
    });

    test('fall-back week: +1 day is exactly +1 epochDay', () {
      final oct31 = CalendarDate.ymd(2026, 10, 31);
      final nov1 = CalendarDate.ymd(2026, 11, 1); // the fall-back date
      expect(oct31.addDays(1), nov1);
      expect(nov1.epochDay - oct31.epochDay, 1);
    });

    test('a no-transition control week behaves identically', () {
      final jun16 = CalendarDate.ymd(2026, 6, 16);
      expect(jun16.addDays(1), CalendarDate.ymd(2026, 6, 17));
      expect(jun16.addDays(1).epochDay - jun16.epochDay, 1);
    });

    test('addDays shifts epochDay by exactly n (positive and negative)', () {
      final base = CalendarDate.ymd(2026, 1, 1);
      for (final n in const [-400, -31, -1, 0, 1, 7, 30, 365, 366]) {
        expect(base.addDays(n).epochDay, base.epochDay + n);
      }
    });
  });

  group('T2 — daysUntil is exact across DST (never a 23h/25h artifact)', () {
    test('7-day span straddling spring-forward counts exactly 7', () {
      final mar5 = CalendarDate.ymd(2026, 3, 5);
      final mar12 = CalendarDate.ymd(2026, 3, 12); // span contains 2026-03-08
      expect(mar5.daysUntil(mar12), 7);
      expect(mar12.daysUntil(mar5), -7);
    });

    test('7-day span straddling fall-back counts exactly 7', () {
      final oct29 = CalendarDate.ymd(2026, 10, 29);
      final nov5 = CalendarDate.ymd(2026, 11, 5); // span contains 2026-11-01
      expect(oct29.daysUntil(nov5), 7);
      expect(nov5.daysUntil(oct29), -7);
    });

    test('daysUntil is antisymmetric: a.daysUntil(b) == -b.daysUntil(a)', () {
      final a = CalendarDate.ymd(2026, 3, 5);
      final b = CalendarDate.ymd(2026, 11, 5);
      expect(a.daysUntil(b), -b.daysUntil(a));
    });

    test('daysUntil(self) is zero', () {
      final d = CalendarDate.ymd(2026, 3, 8);
      expect(d.daysUntil(d), 0);
    });
  });

  group('ymd <-> epochDay round-trip', () {
    test('the Unix-epoch date is epochDay 0', () {
      expect(CalendarDate.ymd(1970, 1, 1).epochDay, 0);
      expect(CalendarDate.ymd(1970, 1, 2).epochDay, 1);
      expect(CalendarDate.ymd(1969, 12, 31).epochDay, -1);
    });

    test('known serial anchors match published proleptic-Gregorian counts', () {
      // 1970-01-01 -> 2000-01-01 is 30 years with 7 leap days (1972..1996).
      expect(CalendarDate.ymd(2000, 1, 1).epochDay, 30 * 365 + 7);
    });

    test('(y,m,d) round-trips for a multi-year sweep incl. leap day & bounds',
        () {
      final dates = <CalendarDate>[
        CalendarDate.ymd(2024, 2, 29), // leap day
        CalendarDate.ymd(2023, 12, 31), // year boundary
        CalendarDate.ymd(2024, 1, 1),
        CalendarDate.ymd(2000, 2, 29), // century leap year
        CalendarDate.ymd(1900, 3, 1), // proleptic: 1900 is NOT a leap year
        CalendarDate.ymd(2026, 6, 16),
      ];
      for (final d in dates) {
        expect(CalendarDate.ymd(d.year, d.month, d.day), d);
      }
    });

    test('derived (year, month, day) getters read back the construction triple',
        () {
      final d = CalendarDate.ymd(2024, 2, 29);
      expect(d.year, 2024);
      expect(d.month, 2);
      expect(d.day, 29);
    });
  });

  group('addDays / daysUntil inverse law', () {
    test('today.addDays(n).daysUntil(today) == -n', () {
      final today = CalendarDate.ymd(2024, 2, 28); // straddles a leap day
      for (final n in const [-366, -30, -1, 0, 1, 30, 365, 366]) {
        expect(today.addDays(n).daysUntil(today), -n);
        expect(today.daysUntil(today.addDays(n)), n);
      }
    });
  });

  group('ordering & value semantics', () {
    test('isBefore / isAfter / compareTo agree with epochDay ordering', () {
      final earlier = CalendarDate.ymd(2026, 1, 1);
      final later = CalendarDate.ymd(2026, 12, 31);
      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.isAfter(later), isFalse);
      expect(earlier.compareTo(later), lessThan(0));
      expect(later.compareTo(earlier), greaterThan(0));
      expect(earlier.compareTo(CalendarDate.ymd(2026, 1, 1)), 0);
    });

    test('== and hashCode are equal iff epochDay is equal', () {
      final a = CalendarDate.ymd(2026, 6, 16);
      final b = CalendarDate.ymd(2026, 6, 16);
      final c = CalendarDate.ymd(2026, 6, 17);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('toString is non-localized ISO-8601 full-date', () {
    test('YYYY-MM-DD, zero-padded, ASCII only', () {
      expect(CalendarDate.ymd(2026, 6, 16).toString(), '2026-06-16');
      expect(CalendarDate.ymd(2026, 1, 5).toString(), '2026-01-05');
      expect(CalendarDate.ymd(999, 12, 9).toString(), '0999-12-09');
    });

    test('contains only ASCII digits and hyphens (no localization here)', () {
      final s = CalendarDate.ymd(2026, 6, 16).toString();
      expect(RegExp(r'^[0-9-]+$').hasMatch(s), isTrue);
    });
  });
}
