// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show CalendarDate;
import 'package:flutter/widgets.dart' show Locale;
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../generated/app_localizations.dart';

/// The user's chosen calendar — an **explicit** Settings value (07 §4).
///
/// Never inferred from `Locale.current`: a Persian speaker may want Hijri, an
/// Arabic speaker Gregorian. The `fa` default of [jalali] is chosen at the
/// Settings layer (E16), never here. Deliberately has no `fromLocale` factory.
enum CalendarSystem {
  /// Solar-Hijri (Jalālī), via `shamsi_date`. The default for `fa`.
  jalali,

  /// The Umm al-Qurā civil Hijri calendar, via `hijri` — labelled as such, a
  /// civil approximation, never a religious sighting authority (07 §6).
  hijriUmmAlQura,

  /// The proleptic-Gregorian calendar, via `intl`'s `DateFormat`.
  gregorian,
}

/// The **only** place a pure-engine [CalendarDate] becomes localized human text
/// (07 §4).
///
/// Conversion uses pure-Dart, offline, BSD-licensed packages — `shamsi_date`
/// (Jalālī), `hijri` (Umm al-Qurā), and `intl`'s `DateFormat` (Gregorian only).
/// The month name and era for Jalālī/Hijri come from the **calendar package's**
/// localized tables, never `intl`'s Gregorian-only `DateFormat`. The calendar is
/// the explicit [system] parameter, never read off `Locale.current`, and Hijri
/// and Gregorian are offered to every locale.
///
/// `format` is total and reads no clock — its only `DateTime` use is the pure
/// `DateTime.utc(y, m, d)` bridge. Its Gregorian path needs `intl` date
/// formatting initialized for the locale (done by `flutter_localizations`
/// in-app; the tests initialize it once). These calendar packages are
/// importable here in `l10n` and provably unimportable from `engine/` (the
/// banned-import gate), keeping the engine calendar-agnostic.
class CalendarPresenter {
  /// Creates a presenter for an explicit [system] and [locale].
  const CalendarPresenter(this.system, this.locale);

  /// The calendar to render in — an explicit Settings value, never inferred.
  final CalendarSystem system;

  /// The active locale, used for the month name/era and (downstream) numerals.
  final Locale locale;

  /// Converts [d] to a localized date label in [system] for [locale].
  String format(CalendarDate d) {
    // A pure (y, m, d) bridge into the calendar packages — `DateTime.utc`, never
    // a clock or a local `DateTime`, so no zone is baked in (07 §1, §4).
    final g = DateTime.utc(d.year, d.month, d.day);
    final label = switch (system) {
      CalendarSystem.gregorian => _gregorianLabel(g),
      CalendarSystem.jalali => _jalaliLabel(g),
      CalendarSystem.hijriUmmAlQura => _hijriLabel(g),
    };
    // Remap the converted label's digits to the locale block DOWNSTREAM of the
    // calendar conversion — the unconditional last step for every system, so no
    // CalendarSystem path can emit a Latin-digit date (07 §4; PRD §13.3).
    return toLocaleNumerals(label, locale);
  }

  /// Day · Jalālī month name · year, the month name from `shamsi_date`'s tables.
  String _jalaliLabel(DateTime g) {
    final f = Jalali.fromDateTime(g).formatter; // localized Jalālī month name
    return '${f.d} ${f.mN} ${f.yyyy}';
  }

  /// Day · Umm al-Qurā month name · year, labelled Umm al-Qurā (07 §6).
  ///
  /// Range-guarded: the `hijri` Umm al-Qurā table is bounded, so a date outside
  /// it (or any library failure) falls back to the Gregorian label rather than
  /// throwing — a date label never crashes a screen (07 §6). The civil-
  /// approximation caveat that accompanies a Hijri surface is the
  /// `hijriCivilApproximationCaveat` ARB string, rendered by the calendar
  /// surface (E16/E19), not concatenated here.
  String _hijriLabel(DateTime g) {
    if (g.isBefore(_hijriMinSupported) || g.isAfter(_hijriMaxSupported)) {
      return _gregorianLabel(g);
    }
    // Arabic-script Umm al-Qurā month names from `hijri`'s tables; correct for
    // every Arabic-script locale we ship (ar/fa/ckb). The month name comes from
    // the calendar package, never `intl`'s Gregorian `DateFormat` (07 §4).
    HijriCalendar.language = 'ar';
    HijriCalendar h;
    try {
      h = HijriCalendar.fromDate(g);
    } on ArgumentError {
      return _gregorianLabel(g); // defensive: never propagate a library failure
    }
    // The localized "(Umm al-Qurā)" qualifier, so a Hijri date is never shown as
    // "the Hijri date" in the absolute (07 §6).
    final qualifier = lookupAppLocalizations(locale).hijriUmmAlQuraQualifier;
    return '${h.hDay} ${h.longMonthName} ${h.hYear} $qualifier';
  }

  /// The one path that uses `intl`'s `DateFormat` directly (Gregorian only).
  String _gregorianLabel(DateTime g) {
    // `intl` ships no `ckb` date symbols, so Sorani falls back to the closest
    // Arabic-script locale it does have; fa/ar use their own symbols.
    // TODO(E09): supply ckb Gregorian month names from the app's own tables.
    final code = switch (locale.languageCode) {
      'ckb' => 'ar',
      _ => locale.languageCode,
    };
    return DateFormat.yMMMMd(code).format(g);
  }

  // The `hijri` Umm al-Qurā table spans 1356 AH (14 Mar 1937 CE) to 1500 AH
  // (16 Nov 2077 CE) — the package's own documented bounds (07 §6). Every real
  // due date is comfortably inside; the guard covers backup and cold-start
  // "when memorized" dates and keeps `format` total.
  static final DateTime _hijriMinSupported = DateTime.utc(1937, 3, 14);
  static final DateTime _hijriMaxSupported = DateTime.utc(2077, 11, 16);
}

/// Remaps the ASCII digits in an already-converted date label to the active
/// locale's numeral block — the downstream numeral pass (07 §4; PRD §13.3).
///
/// `fa`/`ckb` → Extended Arabic-Indic (`۰۱۲۳۴۵۶۷۸۹`, U+06F0–U+06F9); `ar` →
/// Arabic-Indic (`٠١٢٣٤٥٦٧٨٩`, U+0660–U+0669); other locales pass through. The
/// two blocks are distinct and never cross: `ar` never shows `۴`, `fa`/`ckb`
/// never show `٤`.
///
/// It substitutes **only** the ASCII digit code points (`0x30`–`0x39`), so a
/// month name or the "(Umm al-Qurā)" tag — which carry no ASCII digit — pass
/// through verbatim, and there is no grouping separator or sign to desync.
/// It is idempotent: a string already in a locale block has no ASCII to remap.
///
/// This deliberately does **not** route date numerals through `intl`'s
/// `NumberFormat`: in the pinned `intl` (0.20.x) the `-u-nu-arab` Unicode
/// numbering-system extension is ignored — `ar` still renders Latin digits —
/// and `decimalPattern` injects a thousands separator that is wrong for a year
/// field. A field-safe digit-block substitution is the locale-faithful
/// mechanism for dates (no grouping, no sign), which is what this matches.
String toLocaleNumerals(String latin, Locale locale) {
  final blockStart = switch (locale.languageCode) {
    'fa' || 'ckb' => 0x06F0, // Extended Arabic-Indic
    'ar' => 0x0660, // Arabic-Indic
    _ => null,
  };
  if (blockStart == null) return latin;
  const asciiZero = 0x30, asciiNine = 0x39;
  return String.fromCharCodes([
    for (final code in latin.codeUnits)
      if (code >= asciiZero && code <= asciiNine)
        blockStart + (code - asciiZero)
      else
        code,
  ]);
}
