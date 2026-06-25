// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:composition/testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test(
      'reading notificationSchedulerProvider un-overridden throws — never a '
      'silent no-op', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      () => container.read(notificationSchedulerProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<UnimplementedError>().having(
            (s) => s.message,
            'message',
            contains('main'),
          ),
        ),
      ),
    );
  });

  test('an override binds the injected scheduler', () {
    final fake = FakeNotificationScheduler();
    final container = ProviderContainer(
      overrides: [notificationSchedulerProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    expect(container.read(notificationSchedulerProvider), same(fake));
  });

  test('the fake records cancel-then-schedule in order', () async {
    final fake = FakeNotificationScheduler();
    await fake.cancelAll();
    await fake.scheduleDaily(hour: 7, minute: 0, body: 'ready');

    expect(fake.cancelAllCount, 1);
    expect(fake.scheduled.single.hour, 7);
    expect(fake.scheduled.single.minute, 0);
    expect(fake.scheduled.single.body, 'ready');
    // The reschedule contract: cancel precedes schedule, so the OS schedule can
    // never duplicate or go stale (a rebuildable derived cache).
    expect(fake.calls, <String>['cancel', 'schedule']);
  });
}
