// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T07: the reminder time renders in the user's locale numerals across ALL
// three locales — Extended Arabic-Indic (U+06Fx) for fa/ckb, Arabic-Indic
// (U+066x) for ar — and never ASCII. (A wall-clock time-of-day uses the numeral
// helpers directly, NOT the CalendarPresenter, which renders calendar DATES; the
// E10 unit test pins ar only, so this closes the fa/ckb gap. The visual RTL/
// appearance matrix is the E10 reminder_row golden — T11.)

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/offline_test_bootstrap.dart';

Widget _host(Locale locale) => MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(
        body: ReminderRow(
          state: const ReminderRowState(
            enabled: true,
            time: TimeOfDay(hour: 9, minute: 5),
          ),
          callbacks: ReminderRowCallbacks(
            onEnabledChanged: _ignoreBool,
            onTimeChanged: _ignoreTime,
            onCatchUpNoteChanged: _ignoreBool,
          ),
        ),
      ),
    );

void _ignoreBool(bool _) {}
void _ignoreTime(TimeOfDay _) {}

String _timeRun(WidgetTester tester, String anyDigit) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .firstWhere((d) => d.contains(anyDigit), orElse: () => '');

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('fa renders 9:05 in Extended Arabic-Indic (۹:۰۵), never ASCII',
      (tester) async {
    await tester.pumpWidget(_host(const Locale('fa')));
    final run = _timeRun(tester, '۹');
    expect(run.contains('۹'), isTrue);
    expect(run.contains('۰۵'), isTrue); // zero-padded minute keeps its leading 0
    expect(RegExp(r'[0-9]').hasMatch(run), isFalse);
  });

  testWidgets('ckb renders 9:05 in Extended Arabic-Indic (۹:۰۵), never ASCII',
      (tester) async {
    await tester.pumpWidget(_host(const Locale('ckb')));
    final run = _timeRun(tester, '۹');
    expect(run.contains('۹'), isTrue);
    expect(run.contains('۰۵'), isTrue);
    expect(RegExp(r'[0-9]').hasMatch(run), isFalse);
  });

  testWidgets('ar renders 9:05 in Arabic-Indic (٩:٠٥), never ASCII',
      (tester) async {
    await tester.pumpWidget(_host(const Locale('ar')));
    final run = _timeRun(tester, '٩');
    expect(run.contains('٩'), isTrue);
    expect(run.contains('٠٥'), isTrue);
    expect(RegExp(r'[0-9]').hasMatch(run), isFalse);
  });
}
