// SCAFFOLD — this file bundles the numeral-and-date rendering primitive for the
// Hifz Companion app. It is NOT a standalone Dart file: it contains the locale-numeral
// helper, the calendar presenter, a mixed-run formatter, and a golden-test stub. Copy each
// labelled block into the right file under packages/, then fill every // TODO. Opening this
// file on its own shows unresolved symbols — that is expected; the real symbols
// (CalendarDate from the engine, AppLocalizations, the bidi isolate* helpers, intl,
// shamsi_date, hijri) resolve only inside the pub workspace.
//
// Four pieces, in the l10n / presentation layer (NEVER the pure engine):
//   1. numberFormatFor(locale)  — l10n/numerals.dart : the ONE locale-numeral formatter.
//   2. CalendarPresenter        — l10n/ (or features/): CalendarDate -> localized date string.
//   3. localizedPageJuz(...)    — the canonical mixed-run: format THEN FSI/PDI-isolate.
//   4. Golden-test stub         — per-locale numeral + date goldens.
//
// Tokens / rules are referenced BY NAME ONLY (type.numeral; numberFormatFor; CalendarPresenter;
// isolate / isolateLtr from eng-rtl-and-bidi-layout). The docs own the concrete values.
//
// Governing docs:
//   docs/design-system/12-localization-and-rtl.md §4 (locale numerals via intl; type.numeral),
//     §5 (three user-selectable calendars; display transform), §3 (FSI/PDI isolation),
//     §8 (the Quran is never localized — toolkit stops at the chrome)
//   docs/engineering/07-dates-calendars-and-correctness.md §4 (the one CalendarPresenter;
//     numerals remapped DOWNSTREAM of the conversion), §6 (Hijri honesty: Umm al-Qurā,
//     caveat, range-guard fallback), §2 (day-distance is calendar-invariant)
//   docs/engineering/12-localization-rtl-accessibility-impl.md §5 (numberFormatFor; pin -u-nu-),
//     §4 (the one isolation helper; prefer isolateLtr for digits), §6 (ICU plural + locale digits)
//
// Non-negotiables this scaffold encodes:
//   - NEVER "Page " + n.toString(); NEVER a raw int into Text/ARB. Numbers are FORMATTED.
//   - fa/ckb -> Extended Arabic-Indic (۰۱۲, U+06F0..); ar -> Arabic-Indic (٠١٢, U+0660..). Two blocks.
//   - The numbering system is PINNED on the tag (-u-nu-arabext / -u-nu-arab), not a sublocale default.
//   - Dates render through ONE CalendarPresenter; numerals remapped AFTER the calendar conversion.
//   - Rendering NEVER mutates a stored instant / due_at / engine state — it only re-renders.
//   - Hijri = Umm al-Qurā CIVIL date, labelled + caveated, range-guarded; never an observance deadline.
//   - intl reshaping is CHROME-ONLY: the muṣḥaf page's ayah numbers stay the immutable glyph layer.
//   - Offline / no-AI: shamsi_date + hijri are bundled pure Dart; no network, no model, no telemetry.

import 'package:flutter/widgets.dart';

// ============================================================================
// BLOCK 1 — packages/l10n/lib/src/numerals.dart
// The ONE locale-numeral formatter. Pin the numbering system on the tag so digit
// choice is EXPLICIT, never a sublocale default (12-impl §5; 12-design §4). Every
// chrome number on every surface (page card, Today, heat-map %, budget minutes,
// settings option labels, dates) flows through this — never a hand-rolled toString().
// ============================================================================

// import 'package:intl/intl.dart';

/// The locale-numeral formatter for one [locale]. This is the `type.numeral` discipline:
/// fa/ckb render Extended Arabic-Indic (۰۱۲۳۴۵۶۷۸۹, U+06F0..); ar renders Arabic-Indic
/// (٠١٢٣٤٥٦٧٨٩, U+0660..). The two blocks are distinct, non-interchangeable codepoints —
/// `٤٥٦` shown to a Persian reader is a defect (12-design §4).
Object /* TODO: NumberFormat */ numberFormatFor(Locale locale) {
  // Pin the numbering system with a Unicode -u-nu- extension. intl's Eastern-digit
  // emission is inconsistent between dates and numbers and across sublocales, so we
  // never trust the default (12-impl §5).
  final tag = switch (locale.languageCode) {
    'fa' => 'fa-u-nu-arabext', // Extended Arabic-Indic ۰۱۲۳۴۵۶۷۸۹ (U+06F0..)
    'ckb' => 'ckb-u-nu-arabext', // Sorani uses the same Extended set
    'ar' => 'ar-u-nu-arab', // Arabic-Indic ٠١٢٣٤٥٦٧٨٩ (U+0660..) — pinned, not default
    _ => 'en',
  };
  // TODO: return NumberFormat.decimal(tag);
  // For an integer index use NumberFormat with no grouping where a thousands separator
  // would be wrong (e.g. a 3-digit page number). For the heat-map percentage use the
  // locale percent pattern. Keep ALL of these behind this one function.
  return Object(); // TODO placeholder
}

/// Shape a single int into the locale digit set. The ONLY way a number becomes text.
String localeDigits(int value, Locale locale) {
  final fmt = numberFormatFor(locale);
  // TODO: return (fmt as NumberFormat).format(value);
  return '$value'; // TODO placeholder — REPLACE: a raw toString() is the bug this prevents.
}

// ============================================================================
// BLOCK 2 — packages/l10n/lib/src/calendar_presenter.dart  (or features/)
// The ONE place a CalendarDate becomes localized date text. Three calendars, one helper;
// numerals remapped DOWNSTREAM of the conversion (07 §4). The engine never sees a calendar;
// a view never builds a Jalali/HijriCalendar — it asks the presenter.
// ============================================================================

// import 'package:engine/engine.dart' show CalendarDate; // the day type the engine reasons in
// import 'package:intl/intl.dart' show DateFormat;       // Gregorian month names / pattern only
// import 'package:shamsi_date/shamsi_date.dart' show Jalali, Gregorian; // pure Dart, BSD-3, offline
// import 'package:hijri/hijri_calendar.dart' show HijriCalendar;        // pure Dart, BSD-2, Umm al-Qurā

/// The user's chosen calendar (an explicit Settings value — NOT inferred from Locale.current).
/// Jalālī is the default for `fa`; Hijri Umm al-Qurā leads for `ar`; Gregorian offered to all (12-design §5).
enum CalendarSystem { jalali, hijriUmmAlQura, gregorian }

/// Maps a [CalendarDate] (computed by the engine) to a localized, locale-numeralled date label.
/// Pure rendering: it reads a day, it mutates nothing (no instant, no due_at, no engine state — 07 §2).
class CalendarPresenter {
  const CalendarPresenter(this.system, this.locale);

  final CalendarSystem system;
  final Locale locale;

  /// CalendarDate -> localized date string. Convert FIRST, remap numerals LAST (07 §4).
  String format(Object /* TODO: CalendarDate */ d) {
    // Pure (year, month, day) — NOT a clock read. The CalendarDate carries no zone (07 §1).
    // final g = DateTime.utc(d.year, d.month, d.day);

    // 1) Calendar conversion: month name + era come from the calendar package's localized
    //    tables (intl's DateFormat is Gregorian-only for non-Gregorian calendars). Output
    //    here may carry LATIN digits — that is fine; step 2 fixes it.
    final String converted = switch (system) {
      // TODO: CalendarSystem.gregorian => _gregorianLabel(g),       // intl DateFormat(locale)
      // TODO: CalendarSystem.jalali => _jalaliLabel(g),             // Jalali.fromGregorian(...).formatter
      // TODO: CalendarSystem.hijriUmmAlQura => _hijriLabel(g),      // HijriCalendar.fromDate(g) + caveat
      _ => '', // TODO
    };

    // 2) Numerals remapped DOWNSTREAM of the conversion: re-shape the date's numeric fields
    //    through the locale numeral path so no ASCII digit reaches a widget (07 §4; 12-impl §5).
    return _toLocaleNumerals(converted, locale);
  }

  /// Re-map any Latin digits in [s] to the locale digit set. Runs AFTER the calendar conversion.
  String _toLocaleNumerals(String s, Locale locale) {
    // TODO: map each ASCII digit through numberFormatFor(locale) / the locale numbering system,
    // OR build the label from already-localized numeric fields (preferred — see localizedPageJuz).
    return s; // TODO placeholder
  }

  // String _jalaliLabel(DateTime g) {
  //   final f = Jalali.fromDateTime(g).formatter; // shamsi_date — pure Dart, offline (07 §4)
  //   return '${f.d} ${f.mN} ${f.yyyy}';          // day monthName year (Latin digits; remapped in step 2)
  // }

  /// Hijri = Umm al-Qurā CIVIL date. Labelled "Umm al-Qurā", carries the standing honesty
  /// caveat near the picker, NEVER asserts an observance date, and falls back to a Gregorian
  /// label out of range rather than throwing (07 §6). Conscience-check via domain-adab-and-religious-integrity.
  String _hijriLabel(DateTime g, Locale locale) {
    // TODO: guard the supported AH/Gregorian range; on out-of-range OR conversion failure,
    // return _gregorianLabel(g) silently and locally (log nothing off-device).
    //   final h = HijriCalendar.fromDate(g);
    //   return '${h.hDay} ${h.longMonthName} ${h.hYear}'; // append/label "Umm al-Qurā" in the surface copy
    return ''; // TODO placeholder
  }

  // String _gregorianLabel(DateTime g) => DateFormat.yMMMMd(locale.toString()).format(g);
}

// ============================================================================
// BLOCK 3 — the canonical mixed-run: "Page N · Juz M" / "Juz N"
// Format EACH numeric token to locale digits, then FSI/PDI-ISOLATE it (prefer the
// known-direction isolateLtr over first-strong FSI for a digit run — 12-impl §4), then
// inject the isolated tokens as ARB placeholders. NEVER splice raw digits; NEVER let the
// run reorder ("page 7 of 30" -> "30 of 7" — 12-design §3).
// ============================================================================

// import 'package:l10n/l10n.dart';                 // AppLocalizations — every string from here
// import 'package:l10n/src/bidi.dart' show isolateLtr; // the ONE isolation helper (owned by eng-rtl-and-bidi-layout)

/// Build the localized "Page N · Juz M" headline used by the page card and reader chrome.
/// Returns text ready to drop into a single Text/TextSpan — NOT fragmented (12-design §3).
String localizedPageJuz({
  required int page,
  required int juz,
  required Locale locale,
  required Object /* TODO: AppLocalizations */ l10n,
}) {
  // 1) Format each number to the locale digit set (Block 1) — never toString().
  final pageDigits = localeDigits(page, locale); // ۲۵۳ / ٢٥٣
  final juzDigits = localeDigits(juz, locale); // ۱۳ / ١٣

  // 2) Isolate each known-direction digit run so the Bidi algorithm can't reorder it.
  //    Prefer isolateLtr over FSI: first-strong mis-detects on a leading non-digit (12-impl §4).
  final pageToken = isolateLtr(pageDigits);
  final juzToken = isolateLtr(juzDigits);

  // 3) Inject the isolated tokens as ARB PLACEHOLDERS — never concatenate "Page " + ... (12-impl §1).
  // TODO: return (l10n as AppLocalizations).pageJuz(pageToken, juzToken);
  //   ARB (app_ar.arb): "pageJuz": "صفحة {page} · جزء {juz}"
  //   with @placeholders { page: {type: String}, juz: {type: String} } — Strings, already isolated.
  return ''; // TODO placeholder

  // Placeholder stub so the helper is referenced (remove once wired):
  // ignore: dead_code
}

/// Isolation helper signature — IMPLEMENTED in eng-rtl-and-bidi-layout (l10n/bidi.dart),
/// shown here only so this scaffold reads. Do NOT re-implement it; import it.
String isolateLtr(String run) {
  // import 'package:flutter/foundation.dart' show Unicode;
  // return '${Unicode.LRI}$run${Unicode.PDI}';
  return run; // TODO placeholder — replace with the imported helper.
}

/// Count-bearing strings: shape the count to locale numerals, then place it in an ICU
/// `plural` form (Arabic needs all six CLDR categories — 12-impl §6). NOT "$count pages".
String localizedPagesDue({
  required int count,
  required Locale locale,
  required Object /* TODO: AppLocalizations */ l10n,
}) {
  // The count is formatted to locale digits AND routed through the plural message; both
  // must be right. The ARB `pagesDue` plural (app_ar.arb) defines zero/one/two/few/many/other.
  // TODO: return (l10n as AppLocalizations).pagesDue(count); // gen_l10n shapes digits via the locale
  return ''; // TODO placeholder
}

// ============================================================================
// TESTS (mirror the source tree under packages/l10n/test/ and packages/features/test/)
// Per-locale numeral + date goldens load the REAL bundled UI font (never Ahem) so Persian
// digits and Sorani letters are actually exercised; runner pinned (eng-write-dart-test).
// These share the localization & accessibility gate (PRD §20 gate 5).
// ============================================================================

// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   // T8-style numeral golden: fa/ckb render U+06F0-range, ar renders U+0660-range — no ASCII.
//   for (final locale in const [Locale('fa'), Locale('ckb'), Locale('ar')]) {
//     testWidgets('numerals render in the locale block · $locale', (tester) async {
//       // TODO: pump a Text(localeDigits(456, locale)) inside MaterialApp(supportedLocales:[ar,fa,ckb],
//       //   localizationsDelegates: GlobalWidgets/Material + Ckb...). Assert the rendered string contains
//       //   ONLY the expected block: U+06F4 U+06F5 U+06F6 for fa/ckb, U+0664 U+0665 U+0666 for ar; and
//       //   contains NO ASCII '4'/'5'/'6'. Then matchesGoldenFile('goldens/numerals_$locale.png').
//     });
//   }
//
//   testWidgets('Page N · Juz M is isolated and does not reorder', (tester) async {
//     // TODO: render localizedPageJuz(page: 253, juz: 13, locale: Locale('fa'), ...). Assert the
//     //   page/juz tokens are wrapped in LRI..PDI and the visual order is page-then-juz under RTL
//     //   (no "30 of 7" flip). Golden: goldens/page_juz_fa.png (12-design §3; 12-impl §4).
//   });
//
//   test('Jalālī label formats a known date in the locale numerals', () {
//     // TODO: CalendarPresenter(CalendarSystem.jalali, Locale('fa')).format(CalendarDate.ymd(2026,3,21))
//     //   == the documented Nowrūz-day Jalali label with Extended Arabic-Indic digits (07 §4; numerals downstream).
//   });
//
//   test('Hijri label is Umm al-Qurā, range-guarded, never throws', () {
//     // TODO: an in-range date -> a "(Umm al-Qurā)"-labelled Hijri label; an out-of-range date ->
//     //   a graceful Gregorian fallback, NOT an exception (07 §6). Assert the standing caveat copy
//     //   accompanies the Hijri surface (domain-adab-and-religious-integrity).
//   });
//
//   test('a calendar / numeral switch never mutates the stored instant or due_at', () {
//     // TODO: format the same CalendarDate under jalali / hijri / gregorian and fa / ar; assert the
//     //   underlying CalendarDate.epochDay and any due_at are byte-identical across all renders
//     //   (07 §2; 12-design §5 — rendering is a pure display transform).
//   });
//
//   testWidgets('intl reshaping never touches the muṣḥaf page numerals', (tester) async {
//     // TODO: assert the reader's printed ayah numbers / juz markers come from the immutable glyph
//     //   layer and are NOT routed through numberFormatFor — the toolkit stops at the chrome
//     //   (12-design §4/§8; domain-mushaf-text-integrity).
//   });
// }
