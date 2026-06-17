// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The consolidated DISPLAY half of the date-correctness gate (07 §7; PRD §20
// gate 5): T8 (per-locale numeral blocks, no ASCII, no cross-bleed) and a T9
// reference re-run, asserted through the real E02-T05/T06 CalendarPresenter so
// the gate and the unit tests (calendar_presenter_numerals_test /
// calendar_roundtrip_sweep_test) cannot disagree. Same fixed date, same locales.
// `flutter_test` (presenter + intl are display-layer). The shared throwing
// HttpOverrides offline guard is installed — no date/calendar path opens a
// socket. A red vector here blocks the `fast` job exactly as a missing ARB key
// does.

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
  final date = CalendarDate.ymd(2026, 6, 16);

  group('T8 — per-locale numeral block, no ASCII, no cross-bleed', () {
    test('fa renders Extended Arabic-Indic only', () {
      final label =
          const CalendarPresenter(CalendarSystem.jalali, fa).format(date);
      expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
      expect(_anyRuneIn(label, _arLo, _arHi), isFalse);
      expect(_anyRuneIn(label, _extLo, _extHi), isTrue);
    });

    test('ckb renders Extended Arabic-Indic only (shares fa block)', () {
      final label =
          const CalendarPresenter(CalendarSystem.jalali, ckb).format(date);
      expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
      expect(_anyRuneIn(label, _arLo, _arHi), isFalse);
      expect(_anyRuneIn(label, _extLo, _extHi), isTrue);
    });

    test('ar renders Arabic-Indic only (Hijri and Gregorian)', () {
      for (final system in const [
        CalendarSystem.hijriUmmAlQura,
        CalendarSystem.gregorian,
      ]) {
        final label = CalendarPresenter(system, ar).format(date);
        expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
        expect(_anyRuneIn(label, _extLo, _extHi), isFalse);
        expect(_anyRuneIn(label, _arLo, _arHi), isTrue);
      }
    });

    test('no rendered date has an ASCII digit in any system × locale', () {
      for (final locale in const [fa, ckb, ar]) {
        for (final system in CalendarSystem.values) {
          final label = CalendarPresenter(system, locale).format(date);
          expect(_anyRuneIn(label, _asciiZero, _asciiNine), isFalse);
        }
      }
    });
  });

  group('T9 re-run — an independently published Umm al-Qurā reference pair',
      () {
    test('1 Muḥarram 1446 AH = 7 July 2024 CE through the presenter', () {
      // Islamic New Year 1446 (Umm al-Qurā civil); the full reference set and
      // the multi-decade sweep are calendar_roundtrip_sweep_test (E02-T09).
      const presenter = CalendarPresenter(CalendarSystem.hijriUmmAlQura, ar);
      expect(
        presenter.format(CalendarDate.ymd(2024, 7, 7)),
        '١ محرم ١٤٤٦ (Umm al-Qurā)',
      );
    });
  });
}
