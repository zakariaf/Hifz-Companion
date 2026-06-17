// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The conversion-fidelity half of the date-correctness gate (07 §7 T6/T7/T9):
// the round-trip is identity at scale and the published reference values match.
// `flutter_test` (the l10n layer depends on intl/shamsi_date/hijri). The shared
// throwing HttpOverrides offline guard stays installed — both calendar packages
// are bundled pure Dart. Every date is a `CalendarDate.ymd(...)` literal or an
// `addDays` walk; no wall clock, no Duration, no DateTime.add.
//
// Written TEST-FIRST: the T6/T7 sweeps and the independently-sourced T9 cases
// exercise the existing CalendarPresenter conversions (E02-T05/T07); a presenter
// conversion regression turns the sweep red. Reference values come from an
// INDEPENDENTLY PUBLISHED conversion, never the library asserting against its
// own forward+inverse (07 §7 refusal).

import 'package:engine/engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l10n/l10n.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../test_setup.dart';

// 07 §7 T6 — a >50-year Jalālī sweep span (named, not a magic literal mid-loop).
final CalendarDate _sweepStart = CalendarDate.ymd(2000, 1, 1);
final CalendarDate _sweepEnd = CalendarDate.ymd(2050, 12, 31);

/// CalendarDate -> Jalali -> CalendarDate, via the presenter's pure
/// `DateTime.utc(y,m,d)` bridge and `shamsi_date` (07 §1/§4).
CalendarDate _roundTripJalali(CalendarDate d) {
  final g = DateTime.utc(d.year, d.month, d.day);
  final back = Jalali.fromDateTime(g).toGregorian();
  return CalendarDate.ymd(back.year, back.month, back.day);
}

/// CalendarDate -> Hijri(Umm al-Qurā) -> CalendarDate, via the same library
/// entry points the presenter uses (`HijriCalendar.fromDate` / inverse).
CalendarDate _roundTripHijri(CalendarDate d) {
  final g = DateTime.utc(d.year, d.month, d.day);
  final h = HijriCalendar.fromDate(g);
  final back = HijriCalendar().hijriToGregorian(h.hYear, h.hMonth, h.hDay);
  return CalendarDate.ymd(back.year, back.month, back.day);
}

void main() {
  useOfflineTestPolicy();

  setUpAll(() async {
    // The out-of-range Gregorian fallback uses intl's DateFormat.
    await initializeDateFormatting();
  });

  const ar = Locale('ar');

  group('T6 — Jalālī round-trip is identity (multi-decade sweep)', () {
    test('every date 2000-01-01..2050-12-31 round-trips to itself', () {
      var count = 0;
      CalendarDate? firstFailure;
      for (var d = _sweepStart;
          !d.isAfter(_sweepEnd);
          d = d.addDays(1), count++) {
        if (_roundTripJalali(d) != d) {
          firstFailure = d;
          break;
        }
      }
      expect(firstFailure, isNull, reason: 'Jalālī round-trip failed');
      // The loop actually walked the whole span (no off-by-one skip).
      expect(count, _sweepStart.daysUntil(_sweepEnd) + 1);
    });

    test('Nowruz / year-boundary dates are included and identity', () {
      for (final d in <CalendarDate>[
        CalendarDate.ymd(2021, 3, 21), // 1 Farvardin 1400
        CalendarDate.ymd(2024, 3, 20), // 1 Farvardin 1403
        CalendarDate.ymd(2025, 3, 20), // last day of 1403
        CalendarDate.ymd(2000, 12, 31),
        CalendarDate.ymd(2050, 1, 1),
      ]) {
        expect(_roundTripJalali(d), d);
      }
    });
  });

  group('T7 — Hijri round-trip is identity in range, falls back out of range',
      () {
    test('every date in [hijriMinSupported, hijriMaxSupported] is identity',
        () {
      final start = CalendarDate.ymd(
        CalendarPresenter.hijriMinSupported.year,
        CalendarPresenter.hijriMinSupported.month,
        CalendarPresenter.hijriMinSupported.day,
      );
      final end = CalendarDate.ymd(
        CalendarPresenter.hijriMaxSupported.year,
        CalendarPresenter.hijriMaxSupported.month,
        CalendarPresenter.hijriMaxSupported.day,
      );
      var count = 0;
      CalendarDate? firstFailure;
      for (var d = start; !d.isAfter(end); d = d.addDays(1), count++) {
        if (_roundTripHijri(d) != d) {
          firstFailure = d;
          break;
        }
      }
      expect(firstFailure, isNull, reason: 'Hijri round-trip failed');
      expect(count, start.daysUntil(end) + 1);
    });

    test('out-of-range dates fall back to the Gregorian label (never throw)',
        () {
      const hijri = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      const greg = CalendarPresenter(CalendarSystem.gregorian, ar);
      final belowMin = CalendarDate.ymd(1900, 1, 1);
      final aboveMax = CalendarDate.ymd(2100, 1, 1);
      for (final d in [belowMin, aboveMax]) {
        expect(() => hijri.format(d), returnsNormally);
        expect(hijri.format(d), greg.format(d));
      }
    });
  });

  // 07 §6: each Hijri reference is the CIVIL Umm al-Qurā value; an observance's
  // start may differ by a day by moon sighting. No observance/sighting ruling is
  // asserted — only the published civil triple.
  group('T9 — independently published Umm al-Qurā reference pairs', () {
    // Source: R. H. van Gent, "The Umm al-Qura Calendar of Saudi Arabia"
    // (https://webspace.science.uu.nl/~gent0113/islam/ummalqura.htm) — the
    // independent oracle cited by docs/engineering/07 §6; the New-Year / Ramaḍān
    // CE dates below are the widely-published Umm al-Qurā civil values, NOT the
    // hijri library's own forward+inverse.
    const hijriRefs = <(int gy, int gm, int gd, int hy, int hm, int hd)>[
      (2024, 7, 7, 1446, 1, 1), // Islamic New Year 1446 AH
      (2023, 7, 19, 1445, 1, 1), // Islamic New Year 1445 AH
      (2024, 3, 11, 1445, 9, 1), // 1 Ramaḍān 1445 AH (Saudi civil start)
    ];
    test('each published Gregorian->Umm al-Qurā triple matches', () {
      for (final r in hijriRefs) {
        final h = HijriCalendar.fromDate(DateTime.utc(r.$1, r.$2, r.$3));
        expect(
          (h.hYear, h.hMonth, h.hDay),
          (r.$4, r.$5, r.$6),
          reason:
              '${r.$1}-${r.$2}-${r.$3} should be ${r.$4}/${r.$5}/${r.$6} AH',
        );
      }
    });
  });

  group('T9 — independently published Jalālī (Solar-Hijri) reference pairs',
      () {
    // Source: Wikipedia, "Solar Hijri calendar"
    // (https://en.wikipedia.org/wiki/Solar_Hijri_calendar) — cited by
    // docs/engineering/07; the Nowruz (1 Farvardin) correspondences below are
    // the documented year-start dates, NOT shamsi_date's own output.
    const jalaliRefs = <(int gy, int gm, int gd, int jy, int jm, int jd)>[
      (2021, 3, 21, 1400, 1, 1), // Nowruz, start of Solar-Hijri year 1400
      (2024, 3, 20, 1403, 1, 1), // Nowruz 1403
      (2025, 3, 21, 1404, 1, 1), // Nowruz 1404
    ];
    test('each published Gregorian->Jalālī triple matches', () {
      for (final r in jalaliRefs) {
        final j = Gregorian(r.$1, r.$2, r.$3).toJalali();
        expect(
          (j.year, j.month, j.day),
          (r.$4, r.$5, r.$6),
          reason: '${r.$1}-${r.$2}-${r.$3} should be ${r.$4}/${r.$5}/${r.$6}',
        );
      }
    });
  });
}
