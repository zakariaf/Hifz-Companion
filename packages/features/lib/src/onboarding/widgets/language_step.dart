// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/pickers/settings_picker.dart';
import '../../design_system/theme/spacing_tokens.dart';

/// The language-pick step (E11-T03): a single-select over fa / ckb / ar (all
/// RTL), each shown by its **endonym**. Choosing a language applies live as a
/// display transform (the onboarding subtree re-renders via the screen's
/// `Localizations.override`) — it mutates no engine state and stores only the
/// captured `locale`. A dumb View composing E10's [SettingsPicker].
class LanguageStep extends StatelessWidget {
  /// Creates the step; [selected] is the captured locale (null until picked),
  /// [onSelected] writes it through the controller.
  const LanguageStep({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// The captured locale, or null before the user picks.
  final Locale? selected;

  /// Emits the chosen locale.
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return ListView(
      padding: EdgeInsetsDirectional.all(space.space4),
      children: [
        Text(
          l10n.onboardingLanguageStepTitle,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: space.space2),
        Text(
          l10n.onboardingLanguageStepBody,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: space.space4),
        SettingsPicker<Locale>(
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
          // A sentinel that matches no option leaves nothing highlighted until
          // the user makes an explicit pick (the cursor guard requires it).
          selected: selected ?? const Locale('und'),
          onSelected: onSelected,
        ),
      ],
    );
  }
}
