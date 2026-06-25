// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show NotificationScheduler;
import 'package:flutter/widgets.dart' show Locale;
import 'package:l10n/l10n.dart' show AppLocalizations;

import 'preferences_writer.dart';
import 'reminder_preferences.dart';

/// Persists a reminder-preference change through the single write path, then
/// re-derives the OS schedule from it (E18-T03; ui-reminder-row §6,
/// eng-create-riverpod-store §3/§6).
///
/// The OS schedule is a **rebuildable derived cache** over the persisted
/// [ReminderPreferences]: every change `cancelAll`s then re-arms (only if
/// enabled), so it can never duplicate or go stale. Persistence **commits before**
/// any scheduling, and no view touches the scheduler directly. Holds no state —
/// the single source of truth is the persisted prefs; the row reads
/// `reminderPreferencesProvider`, this only writes + schedules. It reads no clock:
/// the local fire time is computed at the scheduler edge.
class ReminderController {
  /// Creates the controller over the [writer] (persistence), the injected
  /// [scheduler] (the OS boundary), and lazy reads of the current
  /// [ReminderPreferences] and the active [Locale] (for the localized body).
  ReminderController({
    required PreferencesWriter writer,
    required NotificationScheduler scheduler,
    required ReminderPreferences Function() readPreferences,
    required Locale? Function() readLocale,
  })  : _writer = writer,
        _scheduler = scheduler,
        _readPreferences = readPreferences,
        _readLocale = readLocale;

  final PreferencesWriter _writer;
  final NotificationScheduler _scheduler;
  final ReminderPreferences Function() _readPreferences;
  final Locale? Function() _readLocale;

  /// Opt-in / silence: turns the daily reminder on or off, persists, then
  /// (re)schedules or cancels it.
  Future<void> setEnabled({required bool enabled}) =>
      _apply(_readPreferences().copyWith(enabled: enabled));

  /// Sets the local fire time, persists, then reschedules at the new time.
  Future<void> setTime({required int hour, required int minute}) =>
      _apply(_readPreferences().copyWith(hour: hour, minute: minute));

  /// Turns the optional catch-up note on or off, persists, then reschedules.
  Future<void> setCatchUpNote({required bool enabled}) =>
      _apply(_readPreferences().copyWith(catchUpNoteEnabled: enabled));

  /// Re-derives the OS schedule from the currently persisted prefs WITHOUT a
  /// change — the reschedule reconciler's primitive (E18-T05): app start, a
  /// permission grant, a profile switch. Idempotent: `cancelAll` then re-arm if
  /// enabled, so repeated calls converge to exactly one (or zero) reminder.
  Future<void> reconcile() => _schedule(_readPreferences());

  Future<void> _apply(ReminderPreferences next) async {
    // Persist (commit) FIRST; schedule the SAME committed value AFTER. The new
    // value is passed forward rather than re-read, because the reactive prefs
    // stream republishes a microtask later than the upsert resolves.
    await _writer.updateReminderPreferences((_) => next);
    await _schedule(next);
  }

  Future<void> _schedule(ReminderPreferences prefs) async {
    // The OS schedule is a derived cache — always clear before re-deriving, so it
    // can never duplicate or leave a stale fire behind.
    await _scheduler.cancelAll();
    if (!prefs.enabled) return;
    await _scheduler.scheduleDaily(
      hour: prefs.hour,
      minute: prefs.minute,
      body: await _resolveBody(),
    );
  }

  Future<String> _resolveBody() async {
    final locale = _readLocale() ?? AppLocalizations.supportedLocales.first;
    final l10n = await AppLocalizations.delegate.load(locale);
    return l10n.reminderNotificationBody;
  }
}
