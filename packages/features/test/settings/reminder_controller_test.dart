// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T03: the reminder controller. Opt-in persists OFF->ON to settings_json
// BEFORE it schedules; scheduling cancels-then-arms exactly one daily reminder (a
// derived cache); silencing persists ON->OFF and cancels without re-arming;
// setTime reschedules at the new wall-clock time; the body is the active locale's
// reminderNotificationBody; reconcile re-derives from persisted prefs without a
// change. Offline guard installed — nothing reaches the network.

import 'package:composition/composition.dart'
    show
        initialActiveProfileProvider,
        notificationSchedulerProvider,
        profileRepositoryProvider;
import 'package:composition/testing.dart' show FakeNotificationScheduler;
import 'package:features/features.dart'
    show reminderControllerProvider, reminderPreferencesProvider;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart' show AppLocalizations;
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';
import 'fake_profiles.dart';

void main() {
  useOfflineTestPolicy();

  ProviderContainer makeContainer(
    FakeNotificationScheduler scheduler,
    FakeProfileRepository profiles,
  ) {
    final c = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profiles),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
        notificationSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  // Settle the reactive prefs stream before acting on the controller.
  Future<void> settle(ProviderContainer c) async {
    final sub = c.listen(reminderPreferencesProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();
  }

  test('opt-in persists OFF->ON, then schedules exactly one daily reminder',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([fakeProfile('p1')]);
    final c = makeContainer(scheduler, profiles);
    await settle(c);

    await c.read(reminderControllerProvider).setEnabled(enabled: true);
    await pumpEventQueue();

    // Persisted to settings_json...
    expect(profiles.store['p1']!.settings!['reminderEnabled'], true);
    // ...then cancel-then-arm: exactly one reminder, no duplicate.
    expect(scheduler.calls, <String>['cancel', 'schedule']);
    expect(scheduler.scheduled.single.hour, 7);
    expect(scheduler.scheduled.single.minute, 0);

    // The body is the active profile's locale (fa) notification line.
    final expectedBody =
        (await AppLocalizations.delegate.load(const Locale('fa')))
            .reminderNotificationBody;
    expect(scheduler.scheduled.single.body, expectedBody);
    expect(expectedBody, isNotEmpty);
  });

  test('silencing persists ON->OFF and cancels without re-arming', () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([
      fakeProfile('p1', settings: {'reminderEnabled': true, 'reminderHour': 6}),
    ]);
    final c = makeContainer(scheduler, profiles);
    await settle(c);

    await c.read(reminderControllerProvider).setEnabled(enabled: false);
    await pumpEventQueue();

    expect(profiles.store['p1']!.settings!['reminderEnabled'], false);
    expect(scheduler.calls, <String>['cancel']); // cancelled, nothing armed
    expect(scheduler.scheduled, isEmpty);
  });

  test('setTime reschedules at the new wall-clock time', () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([
      fakeProfile('p1', settings: {'reminderEnabled': true}),
    ]);
    final c = makeContainer(scheduler, profiles);
    await settle(c);

    await c.read(reminderControllerProvider).setTime(hour: 21, minute: 15);
    await pumpEventQueue();

    expect(profiles.store['p1']!.settings!['reminderHour'], 21);
    expect(profiles.store['p1']!.settings!['reminderMinute'], 15);
    expect(scheduler.scheduled.single.hour, 21);
    expect(scheduler.scheduled.single.minute, 15);
  });

  test('the catch-up toggle persists independently of the daily switch',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([fakeProfile('p1')]);
    final c = makeContainer(scheduler, profiles);
    await settle(c);

    await c.read(reminderControllerProvider).setCatchUpNote(enabled: true);
    await pumpEventQueue();

    expect(profiles.store['p1']!.settings!['reminderCatchUpNote'], true);
    // The daily reminder stays off (it was never opted in) — nothing armed.
    expect(profiles.store['p1']!.settings!['reminderEnabled'], false);
    expect(scheduler.scheduled, isEmpty);
  });

  test('reconcile re-derives the schedule from persisted prefs, no change',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([
      fakeProfile('p1', settings: {'reminderEnabled': true, 'reminderHour': 8}),
    ]);
    final c = makeContainer(scheduler, profiles);
    await settle(c);

    await c.read(reminderControllerProvider).reconcile();

    expect(scheduler.calls, <String>['cancel', 'schedule']);
    expect(scheduler.scheduled.single.hour, 8);
  });

  test('opt-in requests OS permission in context; nothing else prompts',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([fakeProfile('p1')]);
    final c = makeContainer(scheduler, profiles);
    await settle(c);
    final controller = c.read(reminderControllerProvider);

    await controller.setEnabled(enabled: true);
    expect(scheduler.requestPermissionCount, 1); // the in-context opt-in prompt

    // No other path prompts — never a re-prompt or a nag.
    await controller.setTime(hour: 8, minute: 0);
    await controller.setCatchUpNote(enabled: true);
    await controller.reconcile();
    await controller.setEnabled(enabled: false);
    expect(scheduler.requestPermissionCount, 1);
  });
}
