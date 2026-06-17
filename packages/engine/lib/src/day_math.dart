// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

/// The four time-dimensioned scheduling primitives every later engine quantity
/// is built from (07 §2). Each is pure integer day arithmetic over
/// [CalendarDate] — total for valid inputs, clock-free, and DST-immune by
/// construction. The SR curve, the cycle ceiling, and the catch-up re-spread
/// *values* that feed these are E04; this file owns only their day-math shape.

/// Calendar days elapsed since the last review — the signed integer distance
/// `lastReviewDay.daysUntil(today)` (07 §2).
///
/// Signed on purpose: a `today` that precedes the last review yields a negative
/// count, and the caller (E04) decides any clamping — this primitive never lies
/// about the distance. Never `DateTime.difference(...).inDays`, which truncates
/// a sub-24h span to the wrong count across a DST midnight pair.
int elapsedDays(CalendarDate lastReviewDay, CalendarDate today) =>
    lastReviewDay.daysUntil(today);

/// The due date `intervalDays` after `today` — `today.addDays(intervalDays)`
/// (07 §2).
///
/// The FSRS curve (E04) produces `intervalDays` as an integer; this primitive
/// only turns it into a due *date* by integer addition. Never
/// `lastReview.add(Duration(days: n))`, which adds physical hours and lands on
/// the wrong calendar day across a daylight-saving transition.
CalendarDate nextDue(CalendarDate today, int intervalDays) =>
    today.addDays(intervalDays);

/// The earlier of the SR-ideal due day and the cycle-ceiling day, by `epochDay`
/// (07 §2) — the day-math shape of the §7.6 trust clamp
/// `due = min(SR-ideal, cycle ceiling)`.
///
/// This is a thin `min`-over-`epochDay` helper, not the clamp itself: it takes
/// two pre-computed day counts and never derives `S`, `R`, `targetR`, or the
/// cycle ceiling (those are E04). Because it only ever returns the smaller
/// `epochDay`, the result is never later than the ceiling — the local,
/// by-construction half of §7.12 INV-1 (the property over real engine state is
/// E04). Comparison is over `epochDay` (via [CalendarDate.isBefore]), never a
/// clock comparison.
CalendarDate dueWithCeiling(
  CalendarDate today,
  int idealDays,
  int ceilingDays,
) {
  final idealDue = today.addDays(idealDays);
  final ceilingDue = today.addDays(ceilingDays);
  return idealDue.isBefore(ceilingDue) ? idealDue : ceilingDue;
}

/// The `spanDays` consecutive civil days `[today, today.addDays(1), …]` a
/// missed-day backlog is re-spread across (07 §2).
///
/// Exactly the §2 "a sequence of `today.addDays(i)`", never iterating
/// wall-clock days. `spanDays == 0` yields the empty list; a negative
/// `spanDays` is an impossible scheduling input and is rejected, never silently
/// producing a wrong window. This ships only the *enumeration* of the days; how
/// the backlog is distributed across them (most-decayed / prayer-critical
/// first) is E04 §7.9.
List<CalendarDate> catchUpWindow(CalendarDate today, int spanDays) {
  RangeError.checkNotNegative(spanDays, 'spanDays');
  return [for (var i = 0; i < spanDays; i++) today.addDays(i)];
}
