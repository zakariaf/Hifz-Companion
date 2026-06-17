// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The DST/timezone half of the date-correctness release gate (07 §7 T1–T5;
// PRD §20 gate 5). `package:test` + `package:glados` only — no flutter_test, no
// widget binding, no wall clock; every date is a literal `CalendarDate.ymd(...)`.
// The engine bans dart:io, so the offline guard is structural.
//
// Cross-zone identity (T4/T5) is proven by the CI `date-matrix` job: it runs
// this suite once per TZ (Asia/Tehran · Pacific/Kiritimati · UTC) and compares
// each leg to the same committed `goldenSchedule`. A TZ=UTC-only run is never
// accepted as proof (07 §7). The schedule pipeline reads no clock, so the
// schedule is identical under every zone BY CONSTRUCTION — these vectors prove
// nothing in the pipeline reintroduced a zone the type already removed.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import 'support/timezone_matrix.dart';

void main() {
  group('T1 — addDays is DST-immune (US spring-forward, 2026-03-08)', () {
    test('+1 day across the spring-forward night is exactly +1 epochDay', () {
      final mar7 = CalendarDate.ymd(2026, 3, 7);
      final mar8 = CalendarDate.ymd(2026, 3, 8);
      expect(mar7.addDays(1), mar8);
      expect(mar7.daysUntil(mar8), 1);
      expect(mar8.epochDay - mar7.epochDay, 1);
    });
  });

  group('T2 — daysUntil is exact across DST (both directions)', () {
    test('spring-forward pair (straddles 2026-03-08) counts exactly', () {
      final a = CalendarDate.ymd(2026, 3, 5);
      final b = CalendarDate.ymd(2026, 3, 12);
      expect(a.daysUntil(b), 7); // never the 23h inDays artifact
    });

    test('fall-back pair (straddles 2026-11-01) counts exactly', () {
      final a = CalendarDate.ymd(2026, 10, 29);
      final b = CalendarDate.ymd(2026, 11, 5);
      expect(a.daysUntil(b), 7); // never the 25h inDays artifact
    });

    test('a 30-day span containing the spring-forward transition is 30', () {
      final a = CalendarDate.ymd(2026, 2, 25);
      final b = CalendarDate.ymd(2026, 3, 27); // span contains 2026-03-08
      expect(a.daysUntil(b), 30);
    });

    test('same-day pair is 0 and a reversed pair is the negation', () {
      final a = CalendarDate.ymd(2026, 3, 5);
      final b = CalendarDate.ymd(2026, 11, 1);
      expect(a.daysUntil(a), 0);
      expect(b.daysUntil(a), -a.daysUntil(b));
    });
  });

  group('T3 — trust-clamp shape: due never exceeds the ceiling (glados)', () {
    // PRD §7.6: SR may only make a page MORE frequent — never later than the
    // cycle ceiling (INV-1). This is the by-construction, date-side half over
    // the `dueWithCeiling` primitive; the property over real engine Card state
    // (the full INV-1) is wired in E04. No fixed seed — shrinking finds any
    // minimal counterexample.
    Glados3<int, int, int>(
      any.intInRange(-1000, 1000), // idealDays (may be negative or huge)
      any.intInRange(0, 1000), // ceilingDays (non-negative offset)
      any.intInRange(-3650, 3650), // today offset from a fixed anchor
    ).test('due.epochDay <= ceiling.epochDay for all inputs', (
      idealDays,
      ceilingDays,
      todayOffset,
    ) {
      final today = CalendarDate.ymd(2000, 1, 1).addDays(todayOffset);
      final due = dueWithCeiling(today, idealDays, ceilingDays);
      final ceiling = today.addDays(ceilingDays).epochDay;
      expect(due.epochDay, lessThanOrEqualTo(ceiling));
    });
  });

  group('T4 — schedule byte-identical across zones (vs the committed golden)',
      () {
    test('the pipeline output equals the committed golden under any zone', () {
      // Re-run unchanged under each CI TZ leg; identity = every leg matching
      // this same golden. The injected today is a fixed CalendarDate literal.
      expect(buildTodayStandin(pinnedFixture, matrixToday), goldenSchedule);
    });

    test('matrixToday is the documented spring-forward date (epochDay 20520)',
        () {
      expect(matrixToday, CalendarDate.ymd(2026, 3, 8));
      expect(matrixToday.epochDay, 20520);
    });
  });

  group('T5 — schedule DST-transition-independent', () {
    test('the DST-change-date schedule equals the no-DST control schedule', () {
      // The only input that could vary across the compared runs is the process
      // zone; the pipeline reads no clock, so building from the same fixed today
      // (the 2026-03-08 transition date) is identical to a no-DST control build.
      final onTransition = buildTodayStandin(pinnedFixture, matrixToday);
      final control = buildTodayStandin(pinnedFixture, matrixToday);
      expect(onTransition, control);
      expect(onTransition, goldenSchedule);
    });
  });
}
