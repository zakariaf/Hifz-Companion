// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Suite for the CalendarPresenter conversion boundary (07 §4). `flutter_test`
// (the l10n layer depends on intl + Flutter localizations). Every date is a
// constructed `CalendarDate.ymd(...)` literal; no wall clock is read. The shared
// throwing HttpOverrides offline guard stays installed — both calendar packages
// are bundled pure Dart and open no socket.

import 'package:engine/engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  setUpAll(() async {
    // The Gregorian path uses intl's DateFormat, which needs locale date
    // symbols loaded — flutter_localizations does this in-app; we do it here.
    await initializeDateFormatting();
  });

  const fa = Locale('fa');
  const ckb = Locale('ckb');
  const ar = Locale('ar');
  final june16 = CalendarDate.ymd(2026, 6, 16);

  group('per-system label shape — month name + era from the right package', () {
    test('Jalālī renders shamsi_date day · month-name · year', () {
      // Digits are remapped to the locale block downstream (E02-T06): fa uses
      // Extended Arabic-Indic, so day ۲۶ / year ۱۴۰۵.
      const presenter = CalendarPresenter(CalendarSystem.jalali, fa);
      expect(presenter.format(june16), '۲۶ خرداد ۱۴۰۵');
    });

    test('Umm al-Qurā renders hijri month-name, labelled Umm al-Qurā', () {
      const presenter = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      final label = presenter.format(june16);
      expect(label, '١ محرم ١٤٤٨ (Umm al-Qurā)'); // ar -> Arabic-Indic digits
      // labelled Umm al-Qurā, never "the Hijri date" in the absolute.
      expect(label, contains('Umm al-Qurā'));
    });

    test('Gregorian renders intl DateFormat per locale', () {
      expect(
        const CalendarPresenter(CalendarSystem.gregorian, ar).format(june16),
        '١٦ يونيو ٢٠٢٦',
      );
      expect(
        const CalendarPresenter(CalendarSystem.gregorian, fa).format(june16),
        '۱۶ ژوئن ۲۰۲۶',
      );
    });
  });

  group('each locale renders each calendar (explicit parameter, not inferred)',
      () {
    for (final locale in const [fa, ckb, ar]) {
      for (final system in CalendarSystem.values) {
        test('${locale.languageCode} × ${system.name} is non-empty', () {
          final label = CalendarPresenter(system, locale).format(june16);
          expect(label, isNotEmpty);
        });
      }
    }

    test(
        'fa can render Gregorian and ar can render Hijri (offered to every '
        'locale; calendar is the system parameter, never Locale.current)', () {
      expect(
        const CalendarPresenter(CalendarSystem.gregorian, fa).format(june16),
        isNot(contains('خرداد')), // Gregorian, not the fa-default Jalālī
      );
      expect(
        const CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar)
            .format(june16),
        contains('Umm al-Qurā'),
      );
    });
  });

  group('wrong-renderer guard — Jalālī/Hijri are not the intl Gregorian label',
      () {
    test('the three systems produce three different labels for one date', () {
      final greg =
          const CalendarPresenter(CalendarSystem.gregorian, fa).format(june16);
      final jalali =
          const CalendarPresenter(CalendarSystem.jalali, fa).format(june16);
      final hijri = const CalendarPresenter(CalendarSystem.hijriUmmAlQura, fa)
          .format(june16);
      expect(jalali, isNot(greg));
      expect(hijri, isNot(greg));
      expect(jalali, isNot(hijri));
    });
  });

  group('pure bridge — no clock, deterministic, const-constructible', () {
    test('two format calls for one date are identical', () {
      const presenter = CalendarPresenter(CalendarSystem.jalali, fa);
      expect(presenter.format(june16), presenter.format(june16));
    });

    test('CalendarPresenter is const-constructible', () {
      const presenter = CalendarPresenter(CalendarSystem.gregorian, ar);
      expect(presenter.system, CalendarSystem.gregorian);
      expect(presenter.locale, ar);
    });
  });

  group('T9 reference pair (single smoke) — independently published anchor',
      () {
    test('1 Muḥarram 1446 AH = 7 July 2024 CE (Islamic New Year 1446)', () {
      // The CE date of Islamic New Year 1446 (Umm al-Qurā civil) is documented
      // independently of the library; the multi-decade published reference set
      // is E02-T09.
      const presenter = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      expect(
        presenter.format(CalendarDate.ymd(2024, 7, 7)),
        '١ محرم ١٤٤٦ (Umm al-Qurā)', // ar -> Arabic-Indic digits
      );
    });
  });
}
