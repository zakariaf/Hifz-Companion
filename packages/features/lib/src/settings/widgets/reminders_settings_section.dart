// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/components/reminder_row.dart';
import '../settings_providers.dart';
import 'settings_section.dart';

/// The Reminders group of the Settings screen (PRD §14): the one calm, opt-in,
/// off-by-default daily reminder and its optional catch-up note. It mounts E10's
/// domain-blind [ReminderRow] and wires it to the persisted reminder preferences
/// and the [reminderControllerProvider] (E18-T03/T06) — a toggle or time change
/// persists through the single write path, then re-derives the OS schedule.
///
/// A dumb View: it reads the decoded [reminderPreferencesProvider] for the switch,
/// time, and catch-up state and forwards the row's callbacks to the controller. It
/// reads no clock, schedules nothing itself, formats no number, and opens no
/// socket — the time numerals and FSI/PDI isolation live inside [ReminderRow].
class RemindersSettingsSection extends ConsumerWidget {
  /// Creates the Reminders settings group.
  const RemindersSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(reminderPreferencesProvider);
    final controller = ref.read(reminderControllerProvider);

    return SettingsSection(
      title: l10n.settingsSectionReminders,
      children: [
        ReminderRow(
          state: ReminderRowState(
            enabled: prefs.enabled,
            time: TimeOfDay(hour: prefs.hour, minute: prefs.minute),
            catchUpNote: prefs.catchUpNoteEnabled,
          ),
          callbacks: ReminderRowCallbacks(
            onEnabledChanged: (value) => controller.setEnabled(enabled: value),
            onTimeChanged: (time) =>
                controller.setTime(hour: time.hour, minute: time.minute),
            onCatchUpNoteChanged: (value) =>
                controller.setCatchUpNote(enabled: value),
          ),
        ),
      ],
    );
  }
}
