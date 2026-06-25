// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileLocale;

import '../../design_system/pickers/settings_picker.dart';
import '../../design_system/theme/mihrab_color_schemes.dart'
    show MihrabAppearance;
import '../../design_system/theme/spacing_tokens.dart';
import '../settings_providers.dart';
import 'settings_section.dart';

/// The Display group of the Settings screen (PRD §15.2): the UI-language and
/// theme pickers. Each is a pure **display transform** persisted per-profile
/// through the single write path (the E16-T02 [preferencesWriterProvider]) —
/// switching either re-renders the app chrome and never touches a `due_at` or
/// engine state.
///
/// A dumb View: it reads the active profile's locale and decoded preferences and
/// renders E10's [SettingsPicker]s. It opens no socket, formats no number, and
/// draws no Quran glyph. (The Quran font-size/zoom control lands with the reader
/// seam; the muṣḥaf, calendar, numeral, and term-set pickers fill this group in
/// E16-T04..T06.)
class DisplaySettingsSection extends ConsumerWidget {
  /// Creates the Display settings group.
  const DisplaySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileRecordProvider).asData?.value;
    final appearance = ref.watch(displayPreferencesProvider).appearance;
    final writer = ref.read(preferencesWriterProvider);

    // A sentinel that matches no option leaves nothing highlighted until the
    // active profile (and its locale) have loaded.
    final selectedLocale = profile == null
        ? const Locale('und')
        : Locale(profile.locale.wireValue);

    return SettingsSection(
      title: l10n.settingsSectionDisplay,
      children: [
        _LabeledPicker(
          label: l10n.settingsLanguageLabel,
          child: SettingsPicker<Locale>(
            options: [
              SettingsOption(
                value: const Locale('fa'),
                label: l10n.languageNameFa,
              ),
              SettingsOption(
                value: const Locale('ckb'),
                label: l10n.languageNameCkb,
              ),
              SettingsOption(
                value: const Locale('ar'),
                label: l10n.languageNameAr,
              ),
            ],
            selected: selectedLocale,
            onSelected: (locale) => writer.mutateActiveProfile(
              (p) => p.copyWith(locale: _profileLocaleOf(locale)),
            ),
          ),
        ),
        _LabeledPicker(
          label: l10n.settingsThemeLabel,
          child: SettingsPicker<MihrabAppearance>(
            options: [
              SettingsOption(
                value: MihrabAppearance.light,
                label: l10n.appearanceLight,
              ),
              SettingsOption(
                value: MihrabAppearance.sepia,
                label: l10n.appearanceSepia,
              ),
              SettingsOption(
                value: MihrabAppearance.dark,
                label: l10n.appearanceDark,
              ),
            ],
            selected: appearance,
            onSelected: (value) => writer.updateDisplayPreferences(
              (p) => p.copyWith(appearance: value),
            ),
          ),
        ),
      ],
    );
  }

  ProfileLocale _profileLocaleOf(Locale locale) => ProfileLocale.values
      .firstWhere((l) => l.wireValue == locale.languageCode);
}

/// A quiet sub-group label above a single picker (so a screen-reader and a
/// sighted user can tell the language radiogroup from the theme one).
class _LabeledPicker extends StatelessWidget {
  const _LabeledPicker({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: space.space4,
            end: space.space4,
            top: space.space2,
            bottom: space.space1,
          ),
          child: Text(label, style: theme.textTheme.titleSmall),
        ),
        child,
      ],
    );
  }
}
