// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// T8 vector (07 §7): a converted date renders its numeric fields in the active
// locale's digit block — Extended Arabic-Indic (U+06F0–U+06F9) for fa/ckb,
// Arabic-Indic (U+0660–U+0669) for ar — with ZERO ASCII digits and no
// cross-block bleed. `flutter_test` (display layer). The shared throwing
// HttpOverrides offline guard stays installed.
//
// Written TEST-FIRST: these per-locale digit-block assertions failed (the
// presenter still emitted Latin digits) before `toLocaleNumerals` was wired in
// as the final step of `format`.

import 'package:engine/engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

const _asciiZero = 0x30, _asciiNine = 0x39;
const _extLo = 0x06F0, _extHi = 0x06F9; // Extended Arabic-Indic (fa/ckb)
const _arLo = 0x0660, _arHi = 0x0669; // Arabic-Indic (ar)

bool _anyRuneIn(String s, int lo, int hi) =>
    s.runes.any((r) => r >= lo && r <= hi);

void main() {
  useOfflineTestPolicy();

  setUpAll(() async {
    await initializeDateFormatting();
  });

  const fa = Locale('fa');
  const ckb = Locale('ckb');
  const ar = Locale('ar');
  final june16 = CalendarDate.ymd(2026, 6, 16);

  group('T8 — fa/ckb render Extended Arabic-Indic only', () {
    test('fa Jalālī: every digit is Extended Arabic-Indic, no grouping', () {
      final label =
          const CalendarPresenter(CalendarSystem.jalali, fa).format(june16);
      expect(label, '۲۶ خرداد ۱۴۰۵'); // day ۲۶, year ۱۴۰۵ (no thousands sep)
      expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
      expect(_anyRuneIn(label, _arLo, _arHi), isFalse); // no ar bleed
      expect(_anyRuneIn(label, _extLo, _extHi), isTrue);
    });

    test('ckb Jalālī shares fa Extended block, distinct from ar', () {
      final label =
          const CalendarPresenter(CalendarSystem.jalali, ckb).format(june16);
      expect(label, '۲۶ خرداد ۱۴۰۵');
      expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
      expect(_anyRuneIn(label, _arLo, _arHi), isFalse);
      expect(_anyRuneIn(label, _extLo, _extHi), isTrue);
    });
  });

  group('T8 — ar renders Arabic-Indic only, system-agnostic', () {
    test('ar Umm al-Qurā: Arabic-Indic digits, no ASCII, no Extended', () {
      final label = const CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar)
          .format(june16);
      expect(label, '١ محرم ١٤٤٨ (Umm al-Qurā)');
      expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
      expect(_anyRuneIn(label, _extLo, _extHi), isFalse); // no fa bleed
      expect(_anyRuneIn(label, _arLo, _arHi), isTrue);
    });

    test('ar Gregorian: Arabic-Indic digits, no ASCII, no Extended', () {
      final label =
          const CalendarPresenter(CalendarSystem.gregorian, ar).format(june16);
      expect(label, '١٦ يونيو ٢٠٢٦');
      expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
      expect(_anyRuneIn(label, _extLo, _extHi), isFalse);
      expect(_anyRuneIn(label, _arLo, _arHi), isTrue);
    });
  });

  group('no ASCII digit in any system × any locale (unconditional last step)',
      () {
    for (final locale in const [fa, ckb, ar]) {
      for (final system in CalendarSystem.values) {
        test('${locale.languageCode} × ${system.name} has zero ASCII digits',
            () {
          final label = CalendarPresenter(system, locale).format(june16);
          expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
        });
      }
    }
  });

  group('the month name and era are untouched (only digits are remapped)', () {
    test('Jalālī month name survives the numeral pass', () {
      final label =
          const CalendarPresenter(CalendarSystem.jalali, fa).format(june16);
      expect(label, contains('خرداد'));
    });

    test('Umm al-Qurā month name and label survive the numeral pass', () {
      final label = const CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar)
          .format(june16);
      expect(label, contains('محرم'));
      expect(label, contains('Umm al-Qurā'));
    });
  });

  group('toLocaleNumerals is downstream and idempotent', () {
    test('re-running on an already-localized string finds no ASCII to convert',
        () {
      final once =
          const CalendarPresenter(CalendarSystem.gregorian, ar).format(june16);
      expect(toLocaleNumerals(once, ar), once); // idempotent
    });

    test('it maps only digits — non-digit text passes through verbatim', () {
      expect(toLocaleNumerals('16 خرداد', fa), '۱۶ خرداد');
      expect(toLocaleNumerals('16 محرم', ar), '١٦ محرم');
    });
  });
}
