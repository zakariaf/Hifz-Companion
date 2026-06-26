// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show
        activeProfileProvider,
        cycleConfigRepositoryProvider,
        notificationSchedulerProvider,
        profileRepositoryProvider;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show Profile;

import '../today/today_providers.dart' show hasCatchUpBacklogProvider;
import 'cycle_config_writer.dart';
import 'display_preferences.dart';
import 'preferences_writer.dart';
import 'reminder_controller.dart';
import 'reminder_preferences.dart';

/// The active profile's row, streamed reactively (null until a profile exists
/// and is selected). It re-emits after every committed preference write, so the
/// app chrome (theme, calendar, numerals) re-renders without a second cache
/// (eng-create-riverpod-store §5). Keyed implicitly by [activeProfileProvider]:
/// a halaqa switch re-subscribes it to the new student's row.
final activeProfileRecordProvider = StreamProvider<Profile?>((ref) {
  final id = ref.watch(activeProfileProvider);
  if (id == null) return Stream<Profile?>.value(null);
  return ref.watch(profileRepositoryProvider).watchById(id);
});

/// The active profile's decoded [DisplayPreferences] — a pure display projection
/// of `settings_json`, falling back to the calm per-field defaults until a
/// profile (or a stored value) exists. The View reads this for a picker's
/// current selection; the app root reads it to choose the theme/calendar.
final displayPreferencesProvider = Provider<DisplayPreferences>((ref) {
  final profile = ref.watch(activeProfileRecordProvider).asData?.value;
  return DisplayPreferences.fromSettings(profile?.settings);
});

/// The active profile's decoded [ReminderPreferences] — the single source of
/// truth E18 owns (off by default until a profile stores otherwise). The reminder
/// row reads it for the switch + time; the reminder controller (E18-T03/T05)
/// re-derives the OS schedule from it. A pure projection: reading it schedules
/// nothing.
final reminderPreferencesProvider = Provider<ReminderPreferences>((ref) {
  final profile = ref.watch(activeProfileRecordProvider).asData?.value;
  return ReminderPreferences.fromSettings(profile?.settings);
});

/// The single write path for preference mutations — reads the current active
/// profile id on demand and persists transactionally before the
/// [activeProfileRecordProvider] stream republishes.
final preferencesWriterProvider = Provider<PreferencesWriter>((ref) {
  return PreferencesWriter(
    profiles: ref.watch(profileRepositoryProvider),
    readActiveProfileId: () => ref.read(activeProfileProvider),
  );
});

/// The reminder controller (E18-T03) — persists a reminder-preference change
/// through the single write path, then re-derives the OS schedule via the
/// injected [notificationSchedulerProvider]. The body is resolved for the active
/// profile's locale; the schedule is a derived cache (cancel-then-arm).
final reminderControllerProvider = Provider<ReminderController>((ref) {
  return ReminderController(
    writer: ref.watch(preferencesWriterProvider),
    scheduler: ref.watch(notificationSchedulerProvider),
    readPreferences: () => ref.read(reminderPreferencesProvider),
    readLocale: () {
      final profile = ref.read(activeProfileRecordProvider).asData?.value;
      return profile == null ? null : Locale(profile.locale.wireValue);
    },
    readHasCatchUpBacklog: () => ref.read(hasCatchUpBacklogProvider),
  );
});

/// Whether the OS currently permits notifications (E18-T08) — a non-prompting
/// check the reminder row reads to show a calm, non-obstructive denied state when
/// the reminder is on but the OS is blocking it. Auto-disposed so it re-checks
/// each time the Settings surface re-subscribes (e.g. after the user returns from
/// the system notification settings). Defaults to granted until it resolves, so
/// the denied note never flashes on first paint.
final notificationPermissionGrantedProvider =
    FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(notificationSchedulerProvider).isPermissionGranted();
});

/// The single write path for cycle-config mutations (the term-set region today;
/// the cycle preset + budget in E16-T07) — persists transactionally before the
/// `activeCycleConfigProvider` stream republishes.
final cycleConfigWriterProvider = Provider<CycleConfigWriter>((ref) {
  return CycleConfigWriter(
    configs: ref.watch(cycleConfigRepositoryProvider),
    readActiveProfileId: () => ref.read(activeProfileProvider),
  );
});
