// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T09 — the reminder row: OFF by default, the time picker + catch-up toggle
// appear only when enabled, the time renders in locale numerals, calm help-framed
// copy, and it schedules/persists/reads-no-clock (reports config only).

import 'dart:io';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';
import '../banners/catch_up_banner_test.dart' show assertNoBannedPhrase;

ReminderRowCallbacks _noop({
  ValueChanged<bool>? onEnabled,
  ValueChanged<TimeOfDay>? onTime,
  ValueChanged<bool>? onNote,
}) =>
    ReminderRowCallbacks(
      onEnabledChanged: onEnabled ?? (_) {},
      onTimeChanged: onTime ?? (_) {},
      onCatchUpNoteChanged: onNote ?? (_) {},
    );

Widget _host(ReminderRowState state, {ReminderRowCallbacks? callbacks}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light)
        .copyWith(platform: TargetPlatform.android),
    home: Scaffold(
      body: ReminderRow(state: state, callbacks: callbacks ?? _noop()),
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('off by default — switch off, time + catch-up toggle absent',
      (tester) async {
    await tester.pumpWidget(_host(const ReminderRowState()));
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.reminderTimeLabel), findsNothing);
    expect(find.text(l10n.reminderCatchUpNoteLabel), findsNothing);
  });

  testWidgets('enabling reveals the time + catch-up toggle; opt-in is one tap',
      (tester) async {
    final enabledChanges = <bool>[];
    await tester.pumpWidget(
      _host(
        const ReminderRowState(),
        callbacks: _noop(onEnabled: enabledChanges.add),
      ),
    );
    await tester.tap(find.byType(Switch));
    expect(enabledChanges, [true]);

    // Pump the enabled state to assert the revealed controls.
    await tester.pumpWidget(_host(const ReminderRowState(enabled: true)));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.reminderTimeLabel), findsOneWidget);
    expect(find.text(l10n.reminderCatchUpNoteLabel), findsOneWidget);
  });

  testWidgets('the time renders in locale numerals, never ASCII',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const ReminderRowState(
          enabled: true,
          time: TimeOfDay(hour: 7, minute: 5),
        ),
      ),
    );
    // 7:05 → ٧:٠٥ (Arabic-Indic), isolated.
    expect(find.textContaining('٧'), findsWidgets);
    expect(find.textContaining('٠٥'), findsWidgets);
    final trailing = tester
        .widgetList<Text>(find.byType(Text))
        .firstWhere((t) => (t.data ?? '').contains('٧'));
    expect(RegExp(r'[0-9]').hasMatch(trailing.data ?? ''), isFalse);
  });

  testWidgets('copy is calm — honest line present, no banned phrase',
      (tester) async {
    await tester.pumpWidget(_host(const ReminderRowState(enabled: true)));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.reminderHonestLine), findsOneWidget);
    assertNoBannedPhrase(tester);
  });

  test('the leaf references no scheduler / clock', () {
    for (final base in const [
      'packages/features/lib/src/design_system/components',
      '../../packages/features/lib/src/design_system/components',
    ]) {
      final file = File('$base/reminder_row.dart');
      if (!file.existsSync()) continue;
      final src = file.readAsStringSync();
      for (final banned in const [
        'flutter_local_notifications',
        'NotificationScheduler',
        'DateTime.now',
        'package:engine',
      ]) {
        expect(
          src.contains(banned),
          isFalse,
          reason: 'must not reference $banned',
        );
      }
      return;
    }
    fail('reminder_row.dart not found from ${Directory.current}');
  });

  testWidgets('>=48dp labelled targets (meetsLibraryGuidelines)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const ReminderRowState(enabled: true)));
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });
}
