// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../design_system/theme/mihrab_color_schemes.dart' show MihrabAppearance;

/// The decoded view of a profile's `settings_json` display preferences — a small
/// immutable projection over the `Map<String, Object?>` `Profile.settings` (PRD
/// §10.2, §15.2). Each field is a pure **display transform**: changing it
/// re-renders the chrome and never touches a `due_at` or engine state.
///
/// Per-profile by design (locale and muṣḥaf are first-class `Profile` columns;
/// the calendar / numeral / theme choices live here). Decoding is total — a
/// null, absent, or malformed entry falls back to the calm per-field default,
/// never a throw — and [toSettings] **preserves unknown keys**, so preferences
/// added later (calendar, numerals — E16-T04) round-trip cleanly.
class DisplayPreferences {
  /// Creates a display-preferences view with explicit values.
  const DisplayPreferences({this.appearance = kDefaultAppearance});

  /// Decodes the preferences from a profile's [settings] map.
  factory DisplayPreferences.fromSettings(Map<String, Object?>? settings) {
    return DisplayPreferences(
      appearance: _appearanceFromWire(settings?[_kAppearance]),
    );
  }

  /// The reading appearance (light / sepia / dark / night).
  final MihrabAppearance appearance;

  /// The appearance applied when none is stored — the positive-polarity day theme.
  static const MihrabAppearance kDefaultAppearance = MihrabAppearance.light;

  static const String _kAppearance = 'appearance';

  /// Returns a copy with [appearance] replaced.
  DisplayPreferences copyWith({MihrabAppearance? appearance}) =>
      DisplayPreferences(appearance: appearance ?? this.appearance);

  /// Merges these preferences into [existing] (preserving unknown keys) for
  /// persistence into `settings_json`.
  Map<String, Object?> toSettings(Map<String, Object?>? existing) => {
        ...?existing,
        _kAppearance: appearance.name,
      };

  static MihrabAppearance _appearanceFromWire(Object? wire) {
    for (final value in MihrabAppearance.values) {
      if (value.name == wire) return value;
    }
    return kDefaultAppearance;
  }

  @override
  bool operator ==(Object other) =>
      other is DisplayPreferences && other.appearance == appearance;

  @override
  int get hashCode => appearance.hashCode;
}
