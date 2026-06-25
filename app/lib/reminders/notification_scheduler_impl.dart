// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show NotificationScheduler;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The Android channel + stable id for the single daily revision reminder.
const String _kChannelId = 'hifz_daily_reminder';
const String _kChannelName = 'Daily revision reminder';
const int _kReminderId = 0;

/// The next instant a daily reminder for local [hour]:[minute] should fire,
/// relative to [now] and in [now]'s zone — today if that time is still ahead,
/// otherwise tomorrow.
///
/// Pure and DST-correct: because [now] is a `TZDateTime`, building the same
/// wall-clock time and adding a calendar day are resolved by the `timezone`
/// database (not a fixed offset), so a daily 07:00 stays 07:00 *local* across a
/// spring-forward / fall-back. E18-T04 pins this with DST/timezone vectors; the
/// live scheduler supplies the real `tz.TZDateTime.now(tz.local)` at the app
/// edge, so this function reads no clock.
tz.TZDateTime nextDailyFire({
  required tz.TZDateTime now,
  required int hour,
  required int minute,
}) {
  var fire =
      tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
  if (!fire.isAfter(now)) {
    fire = fire.add(const Duration(days: 1));
  }
  return fire;
}

/// The live [NotificationScheduler] (E18; PRD §14): one local daily reminder via
/// `flutter_local_notifications`, fired at a fixed *local* wall-clock time that
/// stays correct across DST because `zonedSchedule` is handed a `TZDateTime` in
/// the device's own zone (`timezone` + `flutter_timezone`, taken only here at the
/// app edge — Decision log #14 / doc 07 §6; the engine never sees a zone).
///
/// NO push, NO server, NO network — the OS fires it. Alarms are **inexact**
/// (`inexactAllowWhileIdle`, so no `SCHEDULE_EXACT_ALARM` permission). Thin
/// platform glue; untested (no device in CI). The fire-time arithmetic is the
/// pure [nextDailyFire] above; the one clock read is the app-edge
/// `tz.TZDateTime.now(tz.local)` below, never `DateTime.now()` in shell logic.
final class LiveNotificationScheduler implements NotificationScheduler {
  /// Creates the scheduler over [plugin] (defaults to a fresh plugin instance).
  LiveNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Initializes the timezone database, pins the device's local zone, and
  /// initializes the plugin — once, idempotently. Permission is requested in
  /// context on opt-in (E18-T08), so initialization requests none here.
  Future<void> _ensureReady() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation(await FlutterTimezone.getLocalTimezone()),
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String body,
  }) async {
    await _ensureReady();
    await _plugin.zonedSchedule(
      _kReminderId,
      null,
      body,
      nextDailyFire(
        now: tz.TZDateTime.now(tz.local),
        hour: hour,
        minute: minute,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kChannelId,
          _kChannelName,
          channelDescription:
              'One calm daily reminder that your revision is ready.',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelAll() async {
    await _ensureReady();
    await _plugin.cancelAll();
  }
}
