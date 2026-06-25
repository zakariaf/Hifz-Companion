// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:timezone/timezone.dart' as tz;

/// The next instant a daily reminder for local [hour]:[minute] should fire,
/// relative to [now] and in [now]'s zone — today if that wall-clock time is still
/// ahead, otherwise the same wall-clock time tomorrow.
///
/// Pure, clock-free, and DST-correct. The "tomorrow" branch **reconstructs** the
/// date (`now.day + 1` at [hour]:[minute]) instead of adding a fixed
/// `Duration(days: 1)`: a 24-hour add would shift the wall clock by the hour
/// gained or lost on a spring-forward / fall-back night, so a daily 07:00 would
/// silently drift to 06:00 or 08:00. Reconstructing the calendar date keeps the
/// fire pinned to 07:00 *local* across the transition; the `TZDateTime`
/// constructor also normalizes month/year roll-over. The live scheduler supplies
/// the real `tz.TZDateTime.now(tz.local)`, so this function reads no clock; the
/// OS then re-anchors each later day via `matchDateTimeComponents.time`.
/// (E18-T04 — pinned by DST/timezone vectors.)
tz.TZDateTime nextDailyFire({
  required tz.TZDateTime now,
  required int hour,
  required int minute,
}) {
  final today =
      tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
  if (today.isAfter(now)) return today;
  return tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day + 1,
    hour,
    minute,
  );
}
