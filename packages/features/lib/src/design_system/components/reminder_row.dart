// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../theme/spacing_tokens.dart';
import '../widgets/mihrab_note_card.dart';

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
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: space.space2),
        _SettingCard(
          child: SwitchListTile.adaptive(
            value: state.enabled,
            onChanged: callbacks.onEnabledChanged,
            title: Text(l10n.reminderToggleLabel),
          ),
        ),
        // The time + catch-up toggle are absent when off and revealed only when
        // on — opt-in is one tap, nothing configured until then.
        if (state.enabled) ...[
          SizedBox(height: space.space2),
          _SettingCard(
            child: ListTile(
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
          ),
          SizedBox(height: space.space2),
          _SettingCard(
            child: SwitchListTile.adaptive(
              value: state.catchUpNote,
              onChanged: callbacks.onCatchUpNoteChanged,
              title: Text(l10n.reminderCatchUpNoteLabel),
            ),
          ),
        ],
        SizedBox(height: space.space3),
        // A calm preview of exactly what the one daily reminder says — neutral,
        // never a nag or a streak.
        _NotificationPreview(body: l10n.reminderNotificationBody),
        SizedBox(height: space.space3),
        // The honest local-only line — an important disclosure kept plainly
        // legible (privacy 10 §9), in a calm privacy-shield note.
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
          child: MihrabNoteCard(
            text: l10n.reminderHonestLine,
            icon: Icons.shield_outlined,
          ),
        ),
        SizedBox(height: space.space4),
      ],
    );
  }
}

/// A calm limestone card wrapping one reminder control, on the screen-edge grid.
class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
      child: Card(clipBehavior: Clip.antiAlias, child: child),
    );
  }
}

/// A quiet illustration of the single daily reminder — a glazed-teal app tile
/// beside the exact neutral notification line. Purely display: non-interactive,
/// no bell/alarm framing, no count.
class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
      child: Card(
        color: scheme.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsetsDirectional.all(space.space4),
          child: Row(
            children: [
              Container(
                width: space.space7,
                height: space.space7,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.all(Radius.circular(space.space3)),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: scheme.onPrimary,
                  size: space.space5,
                ),
              ),
              SizedBox(width: space.space3),
              Expanded(child: Text(body, style: text.bodyLarge)),
            ],
          ),
        ),
      ),
    );
  }
}
