// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../theme/spacing_tokens.dart';

/// The reminder configuration a [ReminderRow] reflects — display data only.
@immutable
class ReminderRowState {
  /// Creates the state; the canonical default is OFF.
  const ReminderRowState({
    this.enabled = false,
    this.time = const TimeOfDay(hour: 7, minute: 0),
    this.catchUpNote = false,
  });

  /// Whether the daily reminder is on (OFF by default — opt-in is one tap).
  final bool enabled;

  /// The chosen reminder time (displayed via the T01 numeral path).
  final TimeOfDay time;

  /// Whether the optional help-framed catch-up note is on.
  final bool catchUpNote;
}

/// The callbacks a [ReminderRow] reports through — it configures only, it never
/// schedules (E18) or persists (E16).
@immutable
class ReminderRowCallbacks {
  /// Creates the callback set.
  const ReminderRowCallbacks({
    required this.onEnabledChanged,
    required this.onTimeChanged,
    required this.onCatchUpNoteChanged,
  });

  /// Reports an opt-in / silence tap.
  final ValueChanged<bool> onEnabledChanged;

  /// Reports a newly chosen reminder time.
  final ValueChanged<TimeOfDay> onTimeChanged;

  /// Reports the catch-up-note toggle.
  final ValueChanged<bool> onCatchUpNoteChanged;
}

/// The opt-in, off-by-default daily-reminder row (ui-reminder-row; privacy 10
/// §9–§10) — a calm config leaf, never a guilt/streak/escalation surface.
///
/// Domain-blind: the switch value comes straight from [ReminderRowState.enabled]
/// (default false); the time picker + catch-up toggle are **absent** when off
/// and revealed only when on; the time renders in locale numerals via the T01
/// path (FSI/PDI-isolated). It reports `(enabled, time, catchUpNote)` through
/// [ReminderRowCallbacks] — it reads no clock, schedules nothing, persists
/// nothing.
class ReminderRow extends StatelessWidget {
  /// Creates the row from [state] + [callbacks].
  const ReminderRow({required this.state, required this.callbacks, super.key});

  /// The current configuration.
  final ReminderRowState state;

  /// The callbacks to report changes through.
  final ReminderRowCallbacks callbacks;

  String _timeLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final hour = localeDigits(state.time.hour, locale);
    final minute =
        toLocaleNumerals(state.time.minute.toString().padLeft(2, '0'), locale);
    // A known-direction clock run inside RTL chrome.
    return isolateLtr('$hour:$minute');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile.adaptive(
          value: state.enabled,
          onChanged: callbacks.onEnabledChanged,
          title: Text(l10n.reminderToggleLabel),
        ),
        if (state.enabled) ...[
          ListTile(
            title: Text(l10n.reminderTimeLabel),
            trailing: Text(_timeLabel(context), style: text.bodyLarge),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: state.time,
              );
              if (picked != null) callbacks.onTimeChanged(picked);
            },
          ),
          SwitchListTile.adaptive(
            value: state.catchUpNote,
            onChanged: callbacks.onCatchUpNoteChanged,
            title: Text(l10n.reminderCatchUpNoteLabel),
          ),
        ],
        Padding(
          padding: EdgeInsetsDirectional.all(space.space4),
          // The honest local-only line is `type.body` in `color.text.primary`
          // (privacy 10 §9 allows primary/secondary) — an important disclosure
          // that stays plainly legible (not a faint 12.5dp aside).
          child: Text(
            l10n.reminderHonestLine,
            style: text.bodyMedium?.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }
}
