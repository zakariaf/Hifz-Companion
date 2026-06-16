// template.dart — domain-calendars-and-hifzdate
//
// Copy-paste scaffold for a date / calendar change in the Hifz Companion app.
// Governing spec: docs/engineering/07-dates-calendars-and-correctness.md (cite §N in PRs).
//
// FOUR layers, deliberately separated — keep each in its own file/package:
//   1. engine/         — the pure CalendarDate value type + integer day math (NO clock, NO calendar pkg)   §1, §2
//   2. app edge        — todayFor / civilDayOf : the ONLY place a clock is read for scheduling             §3, §5
//   3. display         — CalendarPresenter : the ONLY place a CalendarDate becomes localized text          §4, §6
//   4. test            — the DST / timezone / round-trip / numeral release-gate matrix                     §7
//
// The engine calls this type `SerialDay` (06-scheduling-engine.md §1); it is the SAME type.
// Fill every // TODO. Never inline an epoch, a supported AH range, or an ASCII digit.

// ───────────────────────────────────────────────────────────────────────────
// LAYER 1 — engine/ : pure CalendarDate value type  (§1, §2)
//   No `import 'package:flutter'`, no DateTime.now(), no hijri/shamsi_date/intl here.
//   The banned-import grep gate (eng-offline-ci-gates) enforces this.
// ───────────────────────────────────────────────────────────────────────────

import 'package:meta/meta.dart';

/// A civil calendar day on the proleptic-Gregorian calendar.
/// Stored as the integer count of days since 1970-01-01 (the Unix-epoch DATE).
/// This is NOT an instant: it has no time, no zone, no DST surface.   §1
@immutable
class CalendarDate implements Comparable<CalendarDate> {
  /// Days since 1970-01-01. Negative for earlier dates. The stored representation.
  final int epochDay;
  const CalendarDate._(this.epochDay);

  static const int _msPerDay = 86400000; // 24 * 60 * 60 * 1000

  /// Build from a (year, month, day) triple. Uses DateTime.utc as a PURE
  /// proleptic-Gregorian calculator — no clock is read, no zone is involved.   §1
  factory CalendarDate.ymd(int year, int month, int day) {
    final utcMidnight = DateTime.utc(year, month, day);
    return CalendarDate._(utcMidnight.millisecondsSinceEpoch ~/ _msPerDay);
  }

  int get _utcMs => epochDay * _msPerDay;
  DateTime get _asUtc =>
      DateTime.fromMillisecondsSinceEpoch(_utcMs, isUtc: true);
  int get year => _asUtc.year;
  int get month => _asUtc.month;
  int get day => _asUtc.day;

  /// Add or subtract whole calendar days — pure integer math, DST-immune.   §2
  /// NEVER use Duration(days: n) for this: a Duration is physical time and
  /// disagrees with calendar days across a DST transition.
  CalendarDate addDays(int days) => CalendarDate._(epochDay + days);

  /// Calendar days from `this` to `other` (signed). Exact, no Duration.   §2
  /// NEVER use DateTime.difference(...).inDays: it truncates across DST.
  int daysUntil(CalendarDate other) => other.epochDay - epochDay;

  bool isBefore(CalendarDate o) => epochDay < o.epochDay;
  bool isAfter(CalendarDate o) => epochDay > o.epochDay;

  @override
  int compareTo(CalendarDate o) => epochDay.compareTo(o.epochDay);
  @override
  bool operator ==(Object o) => o is CalendarDate && o.epochDay == epochDay;
  @override
  int get hashCode => epochDay.hashCode;

  /// ISO 8601 full-date, for logs/backup — NEVER localized here (that is §4).
  @override
  String toString() => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

/// Example consumer in the engine: every time-dimensioned quantity is integer days.  §2
/// (The full curve/interval/clamp math is owned by domain-scheduling-engine-rules.)
int elapsedDays(CalendarDate lastReviewDay, CalendarDate today) =>
    lastReviewDay.daysUntil(today); // exact, DST-immune — never inDays

CalendarDate nextDue(CalendarDate today, int intervalDays) =>
    today.addDays(intervalDays); // integer addition — never lastReview.add(Duration(...))

// ───────────────────────────────────────────────────────────────────────────
// LAYER 2 — app edge : the ONLY place a clock is read for scheduling  (§3, §5)
// ───────────────────────────────────────────────────────────────────────────

/// "Today" as the device's LOCAL civil day. The one clock read for scheduling.   §5
CalendarDate todayFor(DateTime now) {
  final local = now.toLocal(); // device's own local zone — no IANA/timezone pkg
  return CalendarDate.ymd(local.year, local.month, local.day);
}

/// Turn a real event INSTANT into the civil day the engine measures from.   §3
/// `.toLocal()` exactly once, so "I revised this tonight" means tonight's LOCAL date,
/// not tomorrow's UTC date. The instant itself is still persisted UTC in review_log.
CalendarDate civilDayOf(DateTime instant) {
  final local = instant.toLocal();
  return CalendarDate.ymd(local.year, local.month, local.day);
}

// Riverpod wiring: a single provider supplies `today`; tests override it with a fixed date.
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// final todayProvider = Provider<CalendarDate>((ref) => todayFor(DateTime.now()));
// // Engine call sites receive ref.read(todayProvider) / ref.watch(todayProvider),
// // NEVER DateTime.now(). Tests: ProviderScope(overrides: [todayProvider.overrideWithValue(fixed)]).
// TODO: declare `todayProvider` in your providers file and inject it at every scheduling call site.

// ───────────────────────────────────────────────────────────────────────────
// LAYER 3 — display : the ONLY place a CalendarDate becomes localized text  (§4, §6)
//   Pure-Dart offline packages: shamsi_date (Jalālī), hijri (Umm al-Qurā), intl (Gregorian + numerals).
// ───────────────────────────────────────────────────────────────────────────

// import 'dart:ui' show Locale;
// import 'package:shamsi_date/shamsi_date.dart';
// import 'package:hijri/hijri_calendar.dart';
// import 'package:intl/intl.dart';

/// User-selected calendar — an EXPLICIT Settings value, never inferred from locale.   §4
enum CalendarSystem { jalali, hijriUmmAlQura, gregorian }

/// Default per locale (the DEFAULT only; the user may switch any locale to any system). §4
CalendarSystem defaultCalendarFor(String languageCode) =>
    languageCode == 'fa' ? CalendarSystem.jalali : CalendarSystem.gregorian;
// TODO: source the live value from the Settings store (ui-rtl-localization owns the picker),
//       defaulting via defaultCalendarFor — NEVER from Locale.current at render time.

/// The single place a CalendarDate becomes human text.   §4
class CalendarPresenter {
  final CalendarSystem system;
  // final Locale locale;
  // const CalendarPresenter(this.system, this.locale);
  const CalendarPresenter(this.system);

  /// CalendarDate -> localized, locale-numeralled date label.
  String format(CalendarDate d) {
    // final g = DateTime.utc(d.year, d.month, d.day); // pure (y,m,d), not a clock
    final String latin = switch (system) {
      // CalendarSystem.gregorian      => _gregorianLabel(g),  // intl DateFormat (Gregorian-only)
      // CalendarSystem.jalali         => _jalaliLabel(g),     // shamsi_date
      // CalendarSystem.hijriUmmAlQura => _hijriLabel(g),      // hijri.fromDate(...), §6 guarded
      CalendarSystem.gregorian => '', // TODO _gregorianLabel
      CalendarSystem.jalali => '', // TODO _jalaliLabel (shamsi_date: Jalali.fromDateTime(g).formatter)
      CalendarSystem.hijriUmmAlQura => '', // TODO _hijriLabel (range-guarded, §6)
    };
    // Numerals are remapped DOWNSTREAM of the calendar conversion — never inside it,
    // and never by concatenating raw ASCII digits.   §4 + PRD §13.3
    return toLocaleNumerals(latin);
  }

  // String _jalaliLabel(DateTime g) {
  //   final f = Jalali.fromDateTime(g).formatter; // shamsi_date DateFormatter
  //   return '${f.d} ${f.mN} ${f.yyyy}';          // day monthName year (Latin digits)
  // }

  /// §6 — Hijri is a CIVIL Umm al-Qurā approximation, never a religious authority:
  ///   - label it "Umm al-Qurā", carry the standing honesty note near the picker,
  ///   - range-guard the conversion and FALL BACK to a Gregorian label rather than throw,
  ///   - never key a deadline/reminder/guarantee to a Hijri date being exact,
  ///   - stay madhhab/sect-neutral; issue no sighting ruling.
  // String _hijriLabel(DateTime g) {
  //   if (g.isBefore(_hijriMinSupported) || g.isAfter(_hijriMaxSupported)) {
  //     return _gregorianLabel(g); // graceful fallback, logs nothing off-device
  //   }
  //   final h = HijriCalendar.fromDate(g); // Umm al-Qurā
  //   return '${h.hDay} ${h.longMonthName} ${h.hYear}'; // + a localized "(Umm al-Qurā)" qualifier
  // }
  // TODO: register the Hijri honesty note as a graded claim before it ships
  //       (domain-claims-register-and-science-screen) — never invent a citation.
}

/// Map a date string's ASCII digits to the locale numeral set, AFTER conversion.   §4 + PRD §13.3
///   fa / ckb -> Extended Arabic-Indic (۰۱۲۳۴۵۶۷۸۹)
///   ar       -> Arabic-Indic (٠١٢٣٤٥٦٧٨٩)
/// Prefer intl NumberFormat with the locale's numbering system over a hand map.
String toLocaleNumerals(String latin /*, Locale locale */) {
  // TODO: implement via intl NumberFormat / the locale numbering-system map.
  //       A date that reaches a widget with ASCII digits is a localization defect (T8).
  return latin;
}

// ───────────────────────────────────────────────────────────────────────────
// LAYER 4 — test : the correctness matrix (release gate)  (§7, PRD §20 gate 5)
//   Harness via eng-write-dart-test. Run T4/T5 under multiple TZ env vars — never green only on UTC.
// ───────────────────────────────────────────────────────────────────────────

// import 'package:test/test.dart';
// import 'package:glados/glados.dart';

// void main() {
//   // T1 — addDays is DST-immune (US spring-forward week).
//   test('addDays is exactly +1 epochDay across a DST week', () {
//     final d = CalendarDate.ymd(2026, 3, 7).addDays(1);
//     expect(d, CalendarDate.ymd(2026, 3, 8));
//   });
//
//   // T2 — daysUntil is exact across DST (never 23h/25h artifacts).
//   // TODO: pick two dates spanning a spring-forward AND a fall-back; assert exact integer count.
//
//   // T3 — trust clamp never exceeds the cycle ceiling (property; engine-owned math).
//   // glados2(anyCard, anyReview).test('due_at <= ceiling', ...); // see domain-scheduling-engine-rules
//
//   // T4/T5 — schedule is timezone- AND DST-independent (run under TZ=Asia/Tehran,
//   //          Pacific/Kiritimati, UTC, and on a DST-change date) with the SAME injected today.
//   test('schedule is identical across timezones and DST', () {
//     final today = CalendarDate.ymd(2026, 3, 8); // a US DST-change date
//     // final schedule = buildToday(pinnedFixtureCards(), today);
//     // expect(schedule, equals(goldenSchedule)); // byte-identical on every runner/zone
//   });
//
//   // T6 — Jalālī round-trip is identity over a date sweep.
//   // TODO: CalendarDate -> Jalali -> CalendarDate == identity for every date in range.
//
//   // T7 — Hijri (Umm al-Qurā) round-trip is identity IN range; graceful Gregorian fallback out of range.
//
//   // T8 — numerals map per locale; NO ASCII digits in fa/ckb/ar output.
//   // TODO: format a known date in fa/ckb (Extended Arabic-Indic) and ar (Arabic-Indic); assert no [0-9].
//
//   // T9 — a DOCUMENTED, independently published Umm al-Qurā reference pair matches
//   //      (never assert the library against itself).
//
//   // T10 — a 23:00-local review in a +UTC-offset zone yields the LOCAL civil day, not UTC's next date.
//   test('civilDayOf uses the local day at 23:00', () {
//     // TODO: construct a 23:00 local instant in a +offset zone; expect today's local date.
//   });
// }
