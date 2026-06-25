// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T05: the reschedule reconciler — the OS schedule is a rebuildable derived
// cache over the persisted prefs. reconcile() is idempotent: every arm is preceded
// by a cancel, so repeated calls never stack a second reminder; with the reminder
// off it cancels and arms nothing; after a direct (non-controller) prefs change (a
// restore / profile switch) it re-derives from the NEW persisted value. From any
// starting OS state, cancel-then-reschedule converges to exactly one reminder (or
// zero). Offline guard installed — nothing reaches the network.

import 'package:composition/composition.dart'
    show
        initialActiveProfileProvider,
        notificationSchedulerProvider,
        profileRepositoryProvider;
import 'package:composition/testing.dart' show FakeNotificationScheduler;
import 'package:features/features.dart'
    show reminderControllerProvider, reminderPreferencesProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<void> settle(ProviderContainer c) async {
    final sub = c.listen(reminderPreferencesProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();
  }

  test('reconcile is idempotent — repeated calls never stack a 2nd reminder',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([
      fakeProfile('p1', settings: {'reminderEnabled': true, 'reminderHour': 7}),
    ]);
    final c = makeContainer(scheduler, profiles);
    await settle(c);
    final controller = c.read(reminderControllerProvider);

    await controller.reconcile();
    await controller.reconcile();
    await controller.reconcile();

    // Every 'schedule' is immediately preceded by a 'cancel' — the OS never
    // accumulates reminders, so the net live state is exactly one.
    expect(scheduler.calls, <String>[
      'cancel', 'schedule', //
      'cancel', 'schedule', //
      'cancel', 'schedule',
    ]);
    expect(scheduler.scheduled.every((r) => r.hour == 7), isTrue);
  });

  test('reconcile with the reminder off cancels and arms nothing', () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([fakeProfile('p1')]); // off by default
    final c = makeContainer(scheduler, profiles);
    await settle(c);

    await c.read(reminderControllerProvider).reconcile();
    await c.read(reminderControllerProvider).reconcile();

    expect(scheduler.calls, <String>['cancel', 'cancel']); // never armed
    expect(scheduler.scheduled, isEmpty);
  });

  test('reconcile re-derives from a direct prefs change (restore / switch)',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([fakeProfile('p1')]); // off
    final c = makeContainer(scheduler, profiles);
    await settle(c);

    // Off → reconcile cancels, arms nothing.
    await c.read(reminderControllerProvider).reconcile();
    expect(scheduler.scheduled, isEmpty);

    // A restore (or a profile edit) writes ON + 09:30 straight into settings_json,
    // NOT through the controller; the reactive prefs stream re-emits.
    await profiles.upsert(
      profiles.store['p1']!.copyWith(
        settings: {
          'reminderEnabled': true,
          'reminderHour': 9,
          'reminderMinute': 30,
        },
      ),
    );
    await pumpEventQueue();

    // reconcile re-derives from the NEW persisted value — the derived cache.
    await c.read(reminderControllerProvider).reconcile();
    expect(scheduler.scheduled.last.hour, 9);
    expect(scheduler.scheduled.last.minute, 30);
  });
}
