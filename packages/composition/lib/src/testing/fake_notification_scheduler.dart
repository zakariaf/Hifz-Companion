// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../notification_scheduler_provider.dart';

/// A deterministic [NotificationScheduler] double (E18) — it records every
/// `scheduleDaily` / `cancelAll` call so tests can assert the persist-then-
/// schedule ordering and the cancel-then-reschedule idempotency without a device.
class FakeNotificationScheduler implements NotificationScheduler {
  /// Every `scheduleDaily` call, in order.
  final List<ScheduledReminder> scheduled = <ScheduledReminder>[];

  /// How many times `cancelAll` has been called.
  int cancelAllCount = 0;

  /// A flat, ordered log of `'cancel'` / `'schedule'` calls for ordering asserts.
  final List<String> calls = <String>[];

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String body,
  }) async {
    scheduled.add(ScheduledReminder(hour: hour, minute: minute, body: body));
    calls.add('schedule');
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    calls.add('cancel');
  }
}

/// One recorded `scheduleDaily` call.
class ScheduledReminder {
  /// Records the [hour], [minute], and [body] a reminder was scheduled with.
  const ScheduledReminder({
    required this.hour,
    required this.minute,
    required this.body,
  });

  /// The local hour the reminder was scheduled for.
  final int hour;

  /// The local minute the reminder was scheduled for.
  final int minute;

  /// The (already-localized) body the reminder was scheduled with.
  final String body;
}
