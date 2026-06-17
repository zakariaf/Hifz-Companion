// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// T10 of the date-correctness gate (07 §7; PRD §20 gate 5): a review lands on
// the LOCAL civil day, never UTC's next date. `package:test` only — no
// flutter_test, no widget binding, no wall clock; every instant is a constructed
// DateTime literal. The engine bans dart:io, so the offline guard is structural.
//
// This is the gate-level restatement of the E02-T03 civilDayOf boundary, kept
// here so it joins the engine date suite that the CI `date-matrix` job runs once
// per TZ (Asia/Tehran +03:30 · Pacific/Kiritimati +14 · UTC). A TZ=UTC-only pass
// proves nothing about a Tehran user crossing midnight (07 §7) — the cases below
// build instants from LOCAL wall-clock literals near midnight, so on a non-UTC
// host the persisted UTC instant lands on a different calendar day, catching a
// no-`.toLocal()` regression in whichever direction that host's offset exposes.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group("T10 — a review lands on the LOCAL civil day, never UTC's", () {
    test('a 23:00-local review maps to that local day, not UTC next date', () {
      // 23:00 local on 2026-06-16: on a positive-offset host the UTC instant is
      // earlier the same day; on a negative-offset host UTC has already rolled
      // over to 2026-06-17. civilDayOf follows LOCAL either way (07 §3/§5).
      final review = DateTime(2026, 6, 16, 23).toUtc();
      expect(civilDayOf(review), CalendarDate.ymd(2026, 6, 16));
      expect(civilDayOf(review), isNot(CalendarDate.ymd(2026, 6, 17)));
    });

    test('control: a 01:00-local review the same day maps to that local day',
        () {
      // Proves the rule is "use the local day", not an incidental −1 subtraction.
      final review = DateTime(2026, 6, 16, 1).toUtc();
      expect(civilDayOf(review), CalendarDate.ymd(2026, 6, 16));
    });

    test('control: a 00:30-local review maps to the NEW local day', () {
      // Catches a no-`.toLocal()` regression under POSITIVE-offset hosts, where
      // 00:30 local is still the previous day in UTC.
      final review = DateTime(2026, 6, 17, 0, 30).toUtc();
      expect(civilDayOf(review), CalendarDate.ymd(2026, 6, 17));
    });

    test('whenever local (y,m,d) differs from UTC, the LOCAL day wins', () {
      final review = DateTime(2026, 6, 16, 23, 30).toUtc();
      final local = review.toLocal();
      if (local.day != review.day) {
        // Host genuinely diverges (non-UTC): the naive UTC-field day is wrong.
        expect(
          civilDayOf(review),
          isNot(CalendarDate.ymd(review.year, review.month, review.day)),
        );
      }
      expect(
        civilDayOf(review),
        CalendarDate.ymd(local.year, local.month, local.day),
      );
    });
  });
}
