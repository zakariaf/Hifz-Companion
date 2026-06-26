// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T06: the Reminders settings connector. OFF by default (the switch is off,
// the time + catch-up controls are hidden); opting in persists ON to settings_json
// (FakeProfileRepository) AND schedules exactly one reminder (FakeNotification
// Scheduler), then reveals the time row + catch-up switch; the honest local-only
// line is always shown. The section reads no clock and schedules nothing itself.

import 'package:composition/composition.dart'
    show
        initialActiveProfileProvider,
        notificationSchedulerProvider,
        profileRepositoryProvider;
import 'package:composition/testing.dart' show FakeNotificationScheduler;
import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import 'fake_profiles.dart';

Future<(AppLocalizations, FakeNotificationScheduler, FakeProfileRepository)> _pump(
  WidgetTester tester, {
  bool permissionGranted = true,
  Map<String, Object?>? settings,
}) async {
  final scheduler = FakeNotificationScheduler()
    ..permissionGranted = permissionGranted;
  final profiles = FakeProfileRepository([fakeProfile('p1', settings: settings)]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profiles),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
        notificationSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: RemindersSettingsSection()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
  return (l10n, scheduler, profiles);
}

void main() {
  testWidgets('off by default — the switch is off, time + catch-up are hidden',
      (tester) async {
    final (l10n, scheduler, _) = await _pump(tester);

    expect(find.text(l10n.settingsSectionReminders), findsOneWidget);
    expect(find.text(l10n.reminderToggleLabel), findsOneWidget);
    // Off: a single switch (the daily toggle), value false.
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    // The time row + catch-up switch appear only once enabled.
    expect(find.text(l10n.reminderTimeLabel), findsNothing);
    expect(find.text(l10n.reminderCatchUpNoteLabel), findsNothing);
    // Nothing scheduled.
    expect(scheduler.scheduled, isEmpty);
  });

  testWidgets('opting in persists + schedules, then reveals the controls',
      (tester) async {
    final (l10n, scheduler, profiles) = await _pump(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    // Persisted ON to settings_json...
    expect(profiles.store['p1']!.settings!['reminderEnabled'], true);
    // ...scheduled exactly one reminder (cancel-then-arm)...
    expect(scheduler.calls, <String>['cancel', 'schedule']);
    // ...and the time row + catch-up switch are now revealed.
    expect(find.text(l10n.reminderTimeLabel), findsOneWidget);
    expect(find.text(l10n.reminderCatchUpNoteLabel), findsOneWidget);
  });

  testWidgets('the honest local-only line is always shown', (tester) async {
    final (l10n, _, _) = await _pump(tester);
    expect(find.text(l10n.reminderHonestLine), findsOneWidget);
  });

  testWidgets('a blocked OS permission shows the calm denied note (enabled)',
      (tester) async {
    final (l10n, _, _) = await _pump(
      tester,
      permissionGranted: false,
      settings: {'reminderEnabled': true},
    );
    expect(find.text(l10n.reminderPermissionDeniedNote), findsOneWidget);
  });

  testWidgets('a granted permission shows no denied note', (tester) async {
    final (l10n, _, _) = await _pump(tester, settings: {'reminderEnabled': true});
    expect(find.text(l10n.reminderPermissionDeniedNote), findsNothing);
  });

  testWidgets('the denied note is absent while the reminder is off',
      (tester) async {
    // Even with the OS blocking, an off reminder shows no note — nothing to fire.
    final (l10n, _, _) = await _pump(tester, permissionGranted: false);
    expect(find.text(l10n.reminderPermissionDeniedNote), findsNothing);
  });
}
