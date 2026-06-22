// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The optional "when memorized" sub-control (E11-T07): skipping is first-class
// (no value = a calm invitation + bands, never a required field); picking a band
// stores one CalendarDate; a set value shows the date in the user's calendar and
// can be cleared back to skipped. No clock read, no persistence, no glyph.

import 'package:engine/engine.dart' show CalendarDate;
import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/when_memorized_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  final today = CalendarDate.ymd(2026, 6, 22);

  Future<AppLocalizations> pump(
    WidgetTester tester, {
    required CalendarDate? value,
    void Function(int, CalendarDate)? onSet,
    void Function(int)? onClear,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: WhenMemorizedInput(
            juz: 13,
            value: value,
            today: today,
            calendarSystem: CalendarSystem.jalali,
            onSet: onSet ?? (_, __) {},
            onClear: onClear ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('fa'));
  }

  testWidgets('no value: a calm optional invitation + bands, no error state',
      (t) async {
    final l10n = await pump(t, value: null);
    expect(find.text(l10n.whenMemorizedOptionalLabel), findsOneWidget);
    expect(find.text(l10n.staleBandThisYear), findsOneWidget);
    expect(find.text(l10n.staleBandMoreThanFiveYears), findsOneWidget);
    // No clear affordance when skipped.
    expect(find.text(l10n.whenMemorizedClear), findsNothing);
  });

  testWidgets('picking a band stores the resolved CalendarDate', (t) async {
    CalendarDate? set;
    int? forJuz;
    void record(int j, CalendarDate d) {
      forJuz = j;
      set = d;
    }

    final l10n = await pump(t, value: null, onSet: record);
    await t.tap(find.text(l10n.staleBandOneToTwoYears));
    await t.pumpAndSettle();
    expect(forJuz, 13);
    expect(set, memorizedDateForBand(StaleBand.oneToTwoYears, today));
  });

  testWidgets('a set value shows the date and a clear back to skipped',
      (t) async {
    var cleared = 0;
    final l10n = await pump(
      t,
      value: CalendarDate.ymd(2022, 3, 1),
      onClear: (_) => cleared++,
    );
    // The date is shown (in the user's calendar) and bands are gone.
    expect(find.text(l10n.staleBandThisYear), findsNothing);
    final clear = find.text(l10n.whenMemorizedClear);
    expect(clear, findsOneWidget);
    await t.tap(clear);
    await t.pumpAndSettle();
    expect(cleared, 1);
  });
}
