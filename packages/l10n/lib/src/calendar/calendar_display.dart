// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The render-only calendar-display chrome layer. It takes a date E02 has
/// ALREADY converted and ALREADY digit-remapped — `CalendarPresenter.format` —
/// and only places it inside an RTL line (bidi isolation) plus exposes the CLDR
/// week-start. It performs NO calendar conversion and NO `CalendarDate` math and
/// NO numeral remap (all E02's): it imports no `hijri`/`shamsi_date` and runs no
/// `numberFormatFor`/`replaceAll` (engineering 07 §4; design 12 §5, §8).
library;

import 'package:engine/engine.dart' show CalendarDate;
import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/intl.dart';

import '../bidi.dart';
import 'calendar_presenter.dart';

/// The app-wide initial default calendar — Jalālī, because Persian (`fa`) is the
/// primary locale. The Settings picker (E16) lets ANY locale choose Jalālī /
/// Hijri Umm al-Qurā / Gregorian; this is only the seed. There is deliberately
/// NO `CalendarSystem.fromLocale` — the calendar is a chosen value threaded into
/// the presenter, never inferred from `Locale.current` at render time (07 §4).
const CalendarSystem kDefaultCalendarSystem = CalendarSystem.jalali;

/// Renders [date] via [presenter] (which already converted it to the chosen
/// `CalendarSystem` and remapped its digits to the locale block — E02-T06) and
/// isolates the run for safe placement inside an RTL line.
///
/// Uses `isolateRtl` (RLI…PDI), not `isolate` (FSI): the run is known-RTL
/// (a localized month name + locale-block digits), and FSI's first-strong would
/// mis-guess if the label opened with a digit (engineering 12 §4). The returned
/// value is one embedded run, ready to inject as an ICU `{date}` placeholder —
/// never concatenated into chrome copy, never split (design 12 §3). Chrome only:
/// the muṣḥaf's printed ayah numbers are the immutable glyph layer, never this
/// path (design 12 §8).
String isolatedDateLabel(CalendarPresenter presenter, CalendarDate date) =>
    isolateRtl(presenter.format(date));

/// The first day of the week for [locale], in the Flutter/CLDR convention
/// (0 = Sunday … 6 = Saturday), sourced from CLDR via `intl`'s `DateSymbols` —
/// **Saturday (6)** for `fa`/`ar`/`ckb` — never a hardcoded `DateTime.monday`/
/// `sunday`. The calendar choice does NOT change the week-start: week-start is
/// locale data, the calendar is a separate display transform (design 12 §5).
///
/// `intl` ships no `ckb` data, so Sorani borrows `ar` (both start Saturday).
/// `intl`'s `FIRSTDAYOFWEEK` is Monday-based (0=Mon … 6=Sun); `(+1) % 7` converts
/// it to the Flutter `firstDayOfWeekIndex` convention. Requires the locale's
/// date data initialized (done by `flutter_localizations` in-app; the tests call
/// `initializeDateFormatting`).
int firstDayOfWeekIndexFor(Locale locale) {
  final code = switch (locale.languageCode) {
    'ckb' => 'ar',
    _ => locale.languageCode,
  };
  final mondayBased = DateFormat.yMd(code).dateSymbols.FIRSTDAYOFWEEK;
  return (mondayBased + 1) % 7;
}
