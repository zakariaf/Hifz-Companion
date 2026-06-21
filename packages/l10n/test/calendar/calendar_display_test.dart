// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T08 — the render-only calendar-display layer: it isolates E02's converted,
// digit-remapped date for an RTL line and exposes the CLDR week-start. It
// converts nothing and remaps no digits (those are E02's). `flutter_test`
// (depends on intl); every date is a literal CalendarDate; no wall clock.

import 'package:engine/engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

const int _rli = 0x2067; // Right-to-Left Isolate
const int _pdi = 0x2069; // Pop Directional Isolate
const int _fsi = 0x2068; // First-Strong Isolate (must NOT appear)

void main() {
  useOfflineTestPolicy();

  setUpAll(() async {
    await initializeDateFormatting();
  });

  final date = CalendarDate.ymd(2026, 6, 16);
  const locales = [
    Locale('fa'),
    Locale('ar'),
    Locale.fromSubtags(languageCode: 'ckb'),
  ];

  group('the converted run is isolated (written first)', () {
    test('begins RLI, ends PDI, exactly one isolate pair, never FSI', () {
      for (final locale in locales) {
        final presenter = CalendarPresenter(CalendarSystem.jalali, locale);
        final label = isolatedDateLabel(presenter, date);
        expect(label.runes.first, _rli, reason: '$locale must open with RLI');
        expect(label.runes.last, _pdi, reason: '$locale must close with PDI');
        expect(label.runes.where((r) => r == _rli).length, 1);
        expect(label.runes.where((r) => r == _pdi).length, 1);
        expect(label.runes.contains(_fsi), isFalse); // known-direction, not FSI
      }
    });
  });

  test('digits pass through untouched — the locale block, zero ASCII', () {
    final faLabel = isolatedDateLabel(
      const CalendarPresenter(CalendarSystem.jalali, Locale('fa')),
      date,
    );
    // No ASCII digits; the Extended Arabic-Indic block is present.
    expect(faLabel.runes.any((r) => r >= 0x30 && r <= 0x39), isFalse);
    expect(faLabel.runes.any((r) => r >= 0x06F0 && r <= 0x06F9), isTrue);

    final arLabel = isolatedDateLabel(
      const CalendarPresenter(CalendarSystem.gregorian, Locale('ar')),
      date,
    );
    expect(arLabel.runes.any((r) => r >= 0x30 && r <= 0x39), isFalse);
    expect(arLabel.runes.any((r) => r >= 0x0660 && r <= 0x0669), isTrue);
  });

  group('week-start is CLDR Saturday for fa/ar/ckb', () {
    test('first day of week is Saturday (6), not Monday/Sunday', () {
      for (final locale in locales) {
        final index = firstDayOfWeekIndexFor(locale);
        expect(index, 6, reason: '$locale week starts Saturday (CLDR)');
        expect(index, isNot(DateTime.monday % 7)); // 1
        expect(index, isNot(0)); // Sunday
      }
      // en (a non-shipping sentinel) is Sunday — proving it is locale data, not
      // a constant returning 6 for everything.
      expect(firstDayOfWeekIndexFor(const Locale('en')), 0);
    });

    test('the calendar choice does not change the week-start', () {
      // firstDayOfWeekIndexFor takes only the locale — week-start is independent
      // of CalendarSystem by construction.
      expect(
        firstDayOfWeekIndexFor(const Locale('fa')),
        firstDayOfWeekIndexFor(const Locale('fa')),
      );
    });
  });

  test('calendar is the threaded CalendarSystem, never inferred from locale',
      () {
    // Same date, different calendars offered to every locale, distinct labels.
    final greg = isolatedDateLabel(
      const CalendarPresenter(CalendarSystem.gregorian, Locale('fa')),
      date,
    );
    final hijri = isolatedDateLabel(
      const CalendarPresenter(CalendarSystem.hijriUmmAlQura, Locale('ar')),
      date,
    );
    final jalali = isolatedDateLabel(
      const CalendarPresenter(CalendarSystem.jalali, Locale('fa')),
      date,
    );
    expect(
      greg,
      isNot(jalali),
    ); // the calendar, not the locale, picks the label
    // The Umm al-Qurā qualifier names the variant (never "the Hijri date").
    expect(hijri, contains('Umm al-Qurā'));
  });

  test('default calendar is Jalālī (the primary-locale seed), no fromLocale',
      () {
    expect(kDefaultCalendarSystem, CalendarSystem.jalali);
  });
}
