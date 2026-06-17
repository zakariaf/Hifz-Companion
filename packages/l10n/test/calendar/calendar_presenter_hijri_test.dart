// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Hijri honesty suite (07 §6): Umm al-Qurā labelled, range-guarded with a
// Gregorian fallback (never throws), plus the standing civil-approximation
// caveat ARB slot. `flutter_test` (display layer). The shared throwing
// HttpOverrides offline guard stays installed — both calendar packages are
// bundled pure Dart.
//
// Written TEST-FIRST: the out-of-range Gregorian-fallback cases (the "a date
// label crashes a screen" failure) failed (the presenter threw ArgumentError)
// before the range guard was wired (07 §7 T7).

import 'package:engine/engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

const _asciiZero = 0x30, _asciiNine = 0x39;
bool _hasAsciiDigit(String s) =>
    s.runes.any((r) => r >= _asciiZero && r <= _asciiNine);

void main() {
  useOfflineTestPolicy();

  setUpAll(() async {
    await initializeDateFormatting();
  });

  const fa = Locale('fa');
  const ckb = Locale('ckb');
  const ar = Locale('ar');

  group('T7 — in-range Hijri round-trip is identity', () {
    test('CalendarDate -> Umm al-Qurā -> CalendarDate is identity in range',
        () {
      final dates = <CalendarDate>[
        CalendarDate.ymd(2024, 7, 7), // 1 Muḥarram 1446
        CalendarDate.ymd(2026, 6, 16), // 1 Muḥarram 1448
        CalendarDate.ymd(2000, 2, 29), // leap configuration
        CalendarDate.ymd(1937, 3, 14), // the supported lower bound
        CalendarDate.ymd(2077, 11, 16), // the supported upper bound
      ];
      for (final d in dates) {
        final g = DateTime.utc(d.year, d.month, d.day);
        final h = HijriCalendar.fromDate(g);
        final back =
            HijriCalendar().hijriToGregorian(h.hYear, h.hMonth, h.hDay);
        expect(
          CalendarDate.ymd(back.year, back.month, back.day),
          d,
          reason: 'round-trip must be identity for $d',
        );
      }
    });

    test('in-range label carries the localized (Umm al-Qurā) qualifier', () {
      const presenter = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      final label = presenter.format(CalendarDate.ymd(2026, 6, 16));
      final qualifier = lookupAppLocalizations(ar).hijriUmmAlQuraQualifier;
      expect(label, contains(qualifier));
      // Umm al-Qurā month name from the hijri tables.
      expect(label, contains('محرم'));
    });
  });

  group('T7 — out-of-range falls back to Gregorian, never throws', () {
    final belowMin = CalendarDate.ymd(1900, 1, 1); // < 1937-03-14
    final aboveMax = CalendarDate.ymd(2100, 1, 1); // > 2077-11-16

    test('a date below the supported range returns the Gregorian label', () {
      const hijri = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      const greg = CalendarPresenter(CalendarSystem.gregorian, ar);
      expect(() => hijri.format(belowMin), returnsNormally);
      expect(hijri.format(belowMin), greg.format(belowMin));
    });

    test('a date above the supported range returns the Gregorian label', () {
      const hijri = CalendarPresenter(CalendarSystem.hijriUmmAlQura, fa);
      const greg = CalendarPresenter(CalendarSystem.gregorian, fa);
      expect(() => hijri.format(aboveMax), returnsNormally);
      expect(hijri.format(aboveMax), greg.format(aboveMax));
    });

    test('the fallback label is non-empty and carries no Umm al-Qurā tag', () {
      const hijri = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      final label = hijri.format(belowMin);
      expect(label, isNotEmpty);
      expect(label, isNot(contains('Umm al-Qurā')));
    });
  });

  group('T9 — independently published Umm al-Qurā reference pairs', () {
    // Documented Islamic-New-Year / Saudi-civil anchors (CE dates published
    // independently of the hijri library, not its own forward+inverse):
    //   1 Muḥarram 1446 AH = 7 July 2024 CE  (Islamic New Year 1446)
    //   1 Muḥarram 1445 AH = 19 July 2023 CE (Islamic New Year 1445)
    test('the presenter reproduces each documented reference pair', () {
      const presenter = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      expect(
        presenter.format(CalendarDate.ymd(2024, 7, 7)),
        '١ محرم ١٤٤٦ (Umm al-Qurā)',
      );
      expect(
        presenter.format(CalendarDate.ymd(2023, 7, 19)),
        '١ محرم ١٤٤٥ (Umm al-Qurā)',
      );
    });
  });

  group('the civil-approximation caveat slot renders per locale', () {
    test(
        'the caveat key resolves in all of fa/ckb/ar (no missing-key fallback)',
        () {
      final caveats = {
        for (final l in const [fa, ckb, ar])
          l.languageCode:
              lookupAppLocalizations(l).hijriCivilApproximationCaveat,
      };
      for (final entry in caveats.entries) {
        expect(entry.value, isNotEmpty, reason: '${entry.key} caveat missing');
      }
      // Transcreated, not one shared string: ar/fa/ckb differ.
      expect(caveats['ar'], isNot(caveats['fa']));
      expect(caveats['fa'], isNot(caveats['ckb']));
    });

    test('the caveat carries no ASCII digits (locale numerals only)', () {
      for (final l in const [fa, ckb, ar]) {
        final caveat = lookupAppLocalizations(l).hijriCivilApproximationCaveat;
        expect(_hasAsciiDigit(caveat), isFalse);
      }
    });
  });

  group('adab / neutrality guard — no ruling, sect, or citation in the copy',
      () {
    // No fiqh-ruling, sect/madhhab, or CLAIMS-id/citation token in the
    // user-facing caveat or qualifier (07 §6; the caveat is graded by E19).
    final banned = RegExp(
      r'(C-\d|\[(MA|RCT|EXP|CS|OBS|TEXT|TRAD)\]|fatwa|Sunni|Shia|Shiite|'
      r'haram|halal|must |should |سنّ?ي|شيع)',
      caseSensitive: false,
    );
    test('no banned ruling/sect/citation token in caveat or qualifier', () {
      for (final l in const [fa, ckb, ar]) {
        final loc = lookupAppLocalizations(l);
        expect(banned.hasMatch(loc.hijriCivilApproximationCaveat), isFalse);
        expect(banned.hasMatch(loc.hijriUmmAlQuraQualifier), isFalse);
      }
    });
  });

  group('no schedule/deadline is keyed off a Hijri date being exact', () {
    test('day-distance is calendar-invariant — selecting Hijri changes no math',
        () {
      // The presenter is read-only display; day-distance lives on CalendarDate,
      // independent of any CalendarSystem (07 §2/§6).
      final a = CalendarDate.ymd(2026, 6, 16);
      final b = CalendarDate.ymd(2026, 6, 23);
      expect(a.daysUntil(b), 7);
      // Formatting in any system does not mutate or re-key the dates.
      for (final system in CalendarSystem.values) {
        CalendarPresenter(system, ar).format(a);
        CalendarPresenter(system, ar).format(b);
      }
      expect(a.daysUntil(b), 7);
    });
  });
}
