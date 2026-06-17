// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'calendar_date.dart';

/// Turns a real event **instant** into the civil [CalendarDate] the engine
/// measures from (07 §3).
///
/// Calls `.toLocal()` exactly once, so "I revised this tonight" means tonight's
/// *local* date, not tomorrow's UTC date. This is the single boundary where the
/// two date kinds meet without conflating them: the instant itself stays UTC in
/// the append-only `review_log` audit trail and is **never recomputed or
/// normalized** — this conversion is read-only and only *derives* the civil
/// day, which is what drives scheduling. After this boundary the engine sees
/// only `CalendarDate`s.
///
/// Total: returns a valid [CalendarDate] for any representable [DateTime] and
/// never throws. The clock read itself is not here — `civilDayOf` converts an
/// instant it is *given*; "today" is read once via `todayFor` (E02-T04).
CalendarDate civilDayOf(DateTime instant) {
  final local = instant.toLocal(); // the one boundary conversion (07 §3)
  return CalendarDate.ymd(local.year, local.month, local.day);
}
