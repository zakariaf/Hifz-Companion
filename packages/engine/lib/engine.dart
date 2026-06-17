// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The pure-Dart Hifz scheduling engine: total functions over immutable value
/// types, with "today" always injected as a `CalendarDate` — no Flutter, no
/// I/O, no wall clock, no randomness.
///
/// The real FSRS-style D/S/R math — retrievability, interval, the review
/// update, the sabaq/sabqi/manzil tracks, cold start, the load balancer, and
/// the TRUST CLAMP — plus its frozen golden vectors and `glados` invariants are
/// authored in E04. This barrel currently exports only a compile-proving stub.
library;

export 'src/dates/calendar_date.dart' show CalendarDate;
export 'src/day_math.dart'
    show catchUpWindow, dueWithCeiling, elapsedDays, nextDue;
export 'src/engine_stub.dart';
