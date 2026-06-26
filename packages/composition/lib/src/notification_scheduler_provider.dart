// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schedules the one calm, opt-in daily reminder, or cancels it (E18; PRD §14).
///
/// A side-effect boundary (`eng-define-service-boundary`): the live impl
/// (`flutter_local_notifications`, in `app`) is wired in `main`; tests inject a
/// deterministic fake. The app transmits NOTHING — no push, no server, no
/// network; the OS fires the local notification. The fire time keys off the
/// device's local civil day, never a UTC or Hijri instant. The boundary holds no
/// strings of its own: [scheduleDaily] is given the already-localized [body] the
/// caller resolved at the feature layer.
abstract interface class NotificationScheduler {
  /// Schedules exactly one notification per day at local [hour]:[minute] showing
  /// [body]. Replacing, never stacking: every reschedule is preceded by
  /// [cancelAll], because the OS schedule is a rebuildable derived cache, not a
  /// source of truth.
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String body,
  });

  /// Cancels every scheduled reminder. One tap silences the reminder; every
  /// reschedule calls this first so the schedule can never duplicate or go stale.
  Future<void> cancelAll();

  /// Requests OS permission to post notifications — Android 13+ `POST_NOTIFICATIONS`
  /// / iOS authorization — **in context, only when the user opts in** (E18-T08).
  /// Returns whether it is granted; it never forces the user, and after a prior
  /// decision it is a no-op that reports the current state.
  Future<bool> requestPermission();

  /// Whether the OS currently permits notifications — a **non-prompting** check
  /// used to reflect a calm, non-obstructive denied state in the row (the reminder
  /// is honestly shown as not firing), never to block or nag.
  Future<bool> isPermissionGranted();
}

/// The local-notification scheduler seam — wired in `main`
/// (`flutter_local_notifications`), faked in tests; throws until overridden so a
/// stray read never silently no-ops.
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => throw UnimplementedError(
    'notificationSchedulerProvider is wired only in main '
    '(flutter_local_notifications).',
  ),
);
