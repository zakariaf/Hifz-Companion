// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// A civil calendar day on the proleptic-Gregorian calendar.
///
/// Stored as the integer count of days since `1970-01-01` (the Unix-epoch
/// date). This is **not** an instant: it has no time, no zone, and no DST
/// surface. It is the Dart fix for the missing `LocalDate` and the only date
/// type the pure scheduling engine reasons in (07 §1). A `DateTime` never
/// enters the engine, and a [CalendarDate] is never silently widened into an
/// instant inside scheduling code.
@immutable
class CalendarDate implements Comparable<CalendarDate> {
  /// Days since `1970-01-01` (the Unix-epoch date). Negative for earlier days.
  ///
  /// This integer **is** the stored representation: the DAO maps it to a SQLite
  /// `INTEGER` column with bit-for-bit fidelity (07 §1), so a `due_at`
  /// round-trips through the database with no parsing.
  final int epochDay;

  const CalendarDate._(this.epochDay);

  /// Builds a day from a `(year, month, day)` triple.
  ///
  /// Uses `DateTime.utc` purely as a deterministic proleptic-Gregorian
  /// calculator — it reads no clock and involves no zone. This is the one
  /// permitted `DateTime` use in the engine (07 §1). Local midnight
  /// (`DateTime(y, m, d)`) is refused: it would bake in the device zone the
  /// type exists to remove.
  factory CalendarDate.ymd(int year, int month, int day) {
    final utcMidnight = DateTime.utc(year, month, day);
    return CalendarDate._(utcMidnight.millisecondsSinceEpoch ~/ _msPerDay);
  }

  static const int _msPerDay = 86400000; // 24 * 60 * 60 * 1000

  /// The proleptic-Gregorian year this day falls in.
  int get year => _asUtc.year;

  /// The month-of-year (1–12) this day falls in.
  int get month => _asUtc.month;

  /// The day-of-month (1–31) this day falls in.
  int get day => _asUtc.day;

  DateTime get _asUtc => DateTime.fromMillisecondsSinceEpoch(
        epochDay * _msPerDay,
        isUtc: true,
      );

  /// Returns the day `days` calendar days after this one (negative goes back).
  ///
  /// Pure integer epoch-day arithmetic — total and DST-immune by construction
  /// (07 §2). Never `Duration(days: n)`, `DateTime.add`, or any wall-clock add:
  /// those add 24 physical hours and land on the wrong calendar day across a
  /// daylight-saving transition.
  CalendarDate addDays(int days) => CalendarDate._(epochDay + days);

  /// The signed count of calendar days from `this` to [other].
  ///
  /// Exact integer day-distance (07 §2). Never
  /// `DateTime.difference(...).inDays`, which truncates a sub-24h span to the
  /// wrong count across a DST boundary.
  int daysUntil(CalendarDate other) => other.epochDay - epochDay;

  /// Whether this day is strictly earlier than [other].
  bool isBefore(CalendarDate other) => epochDay < other.epochDay;

  /// Whether this day is strictly later than [other].
  bool isAfter(CalendarDate other) => epochDay > other.epochDay;

  @override
  int compareTo(CalendarDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate && other.epochDay == epochDay;

  @override
  int get hashCode => epochDay.hashCode;

  /// The ISO-8601 `full-date` (`YYYY-MM-DD`, zero-padded) for logs and backups.
  ///
  /// This is a non-localized machine form, never a user-facing label: locale
  /// numerals and the Hijri/Jalālī/Gregorian calendars are the
  /// `CalendarPresenter`'s job (07 §4; E02-T05), the one place a [CalendarDate]
  /// becomes localized text.
  @override
  String toString() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
