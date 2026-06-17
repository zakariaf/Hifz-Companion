// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Pure-engine suite for the integer day-math primitives (07 §2). Encodes the
// engine-quantity table row by row, then pins T1/T2 DST-immunity. `package:test`
// + `glados` only — no flutter_test, no widget binding, no wall clock; every
// date is a literal `CalendarDate.ymd(...)`. The engine bans dart:io, so the
// offline guard is structural (no socket reachable), not installed here.
//
// Written TEST-FIRST: every group below was committed red before the four
// primitives existed, so the DST off-by-one class is pinned, not patched.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

void main() {
  final today = CalendarDate.ymd(2026, 6, 16);

  group('§2 row: elapsed_days = lastReviewDay.daysUntil(today)', () {
    test('equals the signed epochDay distance', () {
      final last = CalendarDate.ymd(2026, 6, 1);
      expect(elapsedDays(last, today), today.epochDay - last.epochDay);
      expect(elapsedDays(last, today), 15);
    });

    test('is signed: today before last review yields a negative count', () {
      final future = CalendarDate.ymd(2026, 6, 20);
      expect(elapsedDays(future, today), -4);
    });

    test('same-day pair is zero', () {
      expect(elapsedDays(today, today), 0);
    });
  });

  group('§2 row: interval(S,R) -> due = today.addDays(intervalDays)', () {
    test('nextDue advances epochDay by exactly the interval', () {
      for (final k in const [0, 1, 7, 15, 30, 60, 365]) {
        expect(nextDue(today, k).epochDay, today.epochDay + k);
      }
    });
  });

  group('§2 row: due_at = min(idealDue, ceilingDue) over epochDay', () {
    test('returns the earlier of ideal and ceiling by epochDay', () {
      // ideal < ceiling -> ideal wins
      expect(dueWithCeiling(today, 7, 30), today.addDays(7));
      // ideal > ceiling -> ceiling wins (SR may only make a page MORE frequent)
      expect(dueWithCeiling(today, 90, 30), today.addDays(30));
      // ideal == ceiling -> either; epochDay is identical
      expect(dueWithCeiling(today, 30, 30), today.addDays(30));
    });

    test('result is never later than the ceiling, by construction', () {
      for (final ideal in const [0, 5, 15, 30, 45, 100]) {
        for (final ceil in const [7, 15, 30]) {
          expect(
            dueWithCeiling(today, ideal, ceil).epochDay,
            lessThanOrEqualTo(today.addDays(ceil).epochDay),
          );
        }
      }
    });
  });

  group('§2 row: catch-up window = a sequence of today.addDays(i)', () {
    test('enumerates [today .. today.addDays(span-1)] exactly', () {
      final window = catchUpWindow(today, 5);
      expect(window, [
        today,
        today.addDays(1),
        today.addDays(2),
        today.addDays(3),
        today.addDays(4),
      ]);
    });

    test('span 0 is the empty window', () {
      expect(catchUpWindow(today, 0), isEmpty);
    });

    test('window is strictly increasing with consecutive gaps of 1 day', () {
      final window = catchUpWindow(today, 7);
      expect(window.length, 7);
      expect(window.first, today);
      expect(window.last, today.addDays(6));
      for (var i = 0; i < window.length - 1; i++) {
        expect(window[i].daysUntil(window[i + 1]), 1);
      }
    });

    test('a negative span is rejected, never a silently wrong window', () {
      expect(() => catchUpWindow(today, -1), throwsA(isA<Error>()));
    });
  });

  group('T1 — nextDue/addDays is DST-immune (spring-forward)', () {
    test('nextDue(2026-03-07, 1) == 2026-03-08, exactly +1 epochDay', () {
      final mar7 = CalendarDate.ymd(2026, 3, 7);
      expect(nextDue(mar7, 1), CalendarDate.ymd(2026, 3, 8));
      expect(nextDue(mar7, 1).epochDay - mar7.epochDay, 1);
    });
  });

  group('T2 — elapsedDays is exact across DST (never a 23h/25h artifact)', () {
    test('7-day span straddling spring-forward counts exactly 7', () {
      final mar5 = CalendarDate.ymd(2026, 3, 5);
      final mar12 = CalendarDate.ymd(2026, 3, 12);
      expect(elapsedDays(mar5, mar12), 7);
    });

    test('7-day span straddling fall-back counts exactly 7', () {
      final oct29 = CalendarDate.ymd(2026, 10, 29);
      final nov5 = CalendarDate.ymd(2026, 11, 5);
      expect(elapsedDays(oct29, nov5), 7);
    });

    test('reversed pair is the negation; same-day is zero', () {
      final mar5 = CalendarDate.ymd(2026, 3, 5);
      final mar12 = CalendarDate.ymd(2026, 3, 12);
      expect(elapsedDays(mar12, mar5), -7);
      expect(elapsedDays(mar5, mar5), 0);
    });
  });

  group('glados — primitives are exact integer inverses (calendar-invariant)',
      () {
    Glados2<int, int>(
      any.intInRange(-3650, 3650),
      any.intInRange(-3650, 3650),
    ).test('nextDue/elapsedDays invert with no DST or zone surface',
        (offset, k) {
      final t = CalendarDate.ymd(2000, 1, 1).addDays(offset);
      expect(nextDue(t, k).daysUntil(t), -k);
      expect(elapsedDays(t, t.addDays(k)), k);
    });
  });
}
