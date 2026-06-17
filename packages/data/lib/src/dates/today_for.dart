// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show CalendarDate;

/// Names the user's local civil day from a clock reading (07 §5).
///
/// Reads the local zone exactly once via `now.toLocal()` — the same boundary
/// discipline as `civilDayOf` (07 §3) — so a 23:00-local review in Tehran is
/// *today*, not tomorrow. It deliberately does **not** derive "today" from a
/// UTC `(y, m, d)`, which would name the UTC day across midnight.
///
/// `todayFor` is clock-free itself: it converts the `now` it is *given*. The one
/// sanctioned `DateTime.now()` lives in `todayProvider`'s default body (the app
/// composition root), so the engine and every scheduling path receive an
/// injected `CalendarDate` and never read a clock.
CalendarDate todayFor(DateTime now) {
  final local = now.toLocal(); // the one boundary conversion (07 §5)
  return CalendarDate.ymd(local.year, local.month, local.day);
}
