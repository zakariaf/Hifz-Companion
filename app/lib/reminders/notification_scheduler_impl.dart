// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show NotificationScheduler;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'next_daily_fire.dart';

/// The Android channel + stable id for the single daily revision reminder.
const String _kChannelId = 'hifz_daily_reminder';
const String _kChannelName = 'Daily revision reminder';
const int _kReminderId = 0;

/// The live [NotificationScheduler] (E18; PRD §14): one local daily reminder via
/// `flutter_local_notifications`, fired at a fixed *local* wall-clock time that
/// stays correct across DST because `zonedSchedule` is handed a `TZDateTime` in
/// the device's own zone (`timezone` + `flutter_timezone`, taken only here at the
/// app edge — Decision log #14 / doc 07 §6; the engine never sees a zone).
///
/// NO push, NO server, NO network — the OS fires it. Alarms are **inexact**
/// (`inexactAllowWhileIdle`, so no `SCHEDULE_EXACT_ALARM` permission). Thin
/// platform glue; untested (no device in CI). The fire-time arithmetic is the
/// pure [nextDailyFire] helper; the one clock read is the app-edge
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
    // A device may report a zone name absent from the bundled IANA database
    // (rare, on heavily-customized Android); fall back to UTC rather than crash
    // initialization — the reminder then fires at UTC wall-clock there, degraded
    // but never a crash (Gemini review, PR #22). 'UTC' is always present.
    try {
      tz.setLocalLocation(
        tz.getLocation(await FlutterTimezone.getLocalTimezone()),
      );
    } on Exception {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
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

  @override
  Future<bool> requestPermission() async {
    await _ensureReady();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        // On Android < 13 there is no runtime POST_NOTIFICATIONS permission, so
        // the request returns null — fall back to the actual enabled state rather
        // than report a false denial (Gemini review, PR #22).
        return granted ?? await isPermissionGranted();
      case TargetPlatform.iOS:
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, sound: true);
        // A null result (unresolved plugin) falls back to the actual enabled
        // state rather than a false denial.
        return granted ?? await isPermissionGranted();
      default:
        // No explicit notification-permission gate on this platform.
        return true;
    }
  }

  @override
  Future<bool> isPermissionGranted() async {
    await _ensureReady();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final enabled = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        return enabled ?? false;
      case TargetPlatform.iOS:
        final options = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
        return options?.isEnabled ?? false;
      default:
        return true;
    }
  }
}
