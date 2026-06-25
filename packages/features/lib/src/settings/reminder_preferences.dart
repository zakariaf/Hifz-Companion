// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The decoded view of a profile's reminder preferences — a small immutable
/// projection over the `Map<String, Object?>` `Profile.settings` (PRD §14). This
/// is the **only** state E18 owns and the single source of truth: the OS schedule
/// is a rebuildable derived cache re-derived from these, never the reverse.
///
/// **Off by default**: [enabled] decodes to false unless explicitly stored true,
/// so opt-in is always a deliberate tap and a wipe-and-reschedule converges to
/// silence ([10-privacy-and-trust-ux.md] §9). Decoding is total — a null, absent,
/// or out-of-range entry falls back to the calm per-field default, never a throw
/// — and [toSettings] **preserves unknown keys**, so it coexists with the display
/// preferences in the same `settings_json` map.
class ReminderPreferences {
  /// Creates a reminder-preferences view with explicit values.
  const ReminderPreferences({
    this.enabled = false,
    this.hour = kDefaultHour,
    this.minute = kDefaultMinute,
    this.catchUpNoteEnabled = false,
  });

  /// Decodes the preferences from a profile's [settings] map.
  factory ReminderPreferences.fromSettings(Map<String, Object?>? settings) {
    return ReminderPreferences(
      enabled: settings?[_kEnabled] == true,
      hour: _intInRange(settings?[_kHour], fallback: kDefaultHour, max: 23),
      minute: _intInRange(settings?[_kMinute], fallback: kDefaultMinute, max: 59),
      catchUpNoteEnabled: settings?[_kCatchUpNote] == true,
    );
  }

  /// Whether the daily reminder is on. **OFF by default** — opt-in is one tap.
  final bool enabled;

  /// The local hour (0–23) the reminder fires.
  final int hour;

  /// The local minute (0–59) the reminder fires.
  final int minute;

  /// Whether the optional, help-framed catch-up note is on — a second switch,
  /// independently **off by default**.
  final bool catchUpNoteEnabled;

  /// The default reminder time when none is stored — a calm 07:00.
  static const int kDefaultHour = 7;

  /// The default reminder minute when none is stored.
  static const int kDefaultMinute = 0;

  static const String _kEnabled = 'reminderEnabled';
  static const String _kHour = 'reminderHour';
  static const String _kMinute = 'reminderMinute';
  static const String _kCatchUpNote = 'reminderCatchUpNote';

  /// Returns a copy with the given fields replaced.
  ReminderPreferences copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    bool? catchUpNoteEnabled,
  }) =>
      ReminderPreferences(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        catchUpNoteEnabled: catchUpNoteEnabled ?? this.catchUpNoteEnabled,
      );

  /// Merges these preferences into [existing] (preserving unknown keys — e.g. the
  /// display preferences) for persistence into `settings_json`.
  Map<String, Object?> toSettings(Map<String, Object?>? existing) => {
        ...?existing,
        _kEnabled: enabled,
        _kHour: hour,
        _kMinute: minute,
        _kCatchUpNote: catchUpNoteEnabled,
      };

  static int _intInRange(Object? wire, {required int fallback, required int max}) {
    if (wire is int && wire >= 0 && wire <= max) return wire;
    return fallback;
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderPreferences &&
      other.enabled == enabled &&
      other.hour == hour &&
      other.minute == minute &&
      other.catchUpNoteEnabled == catchUpNoteEnabled;

  @override
  int get hashCode => Object.hash(enabled, hour, minute, catchUpNoteEnabled);
}
