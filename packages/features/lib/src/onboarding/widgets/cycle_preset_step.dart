// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/pickers/cycle_preset_picker.dart';
import '../../design_system/pickers/settings_picker.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../../l10n/term_set.dart' show kDefaultTermSetRegion;
import '../onboarding_view_model.dart' show CustomCycleConfig;
import 'custom_cycle_editor.dart';

/// The named cycle-preset + daily-budget step (E11-T08): composes E10's
/// [CyclePresetPicker] (named single-select + Pure-cycle fidelity toggle) and a
/// bounded daily-budget stepper. Custom reveals exactly four bounded fields. The
/// View captures `cyclePreset` / `pureCycleMode` / `dailyBudgetMinutes` /
/// `customCycle` through callbacks only — **no `Slider`, no `target_R`, no FSRS
/// number, no "recommended for you", no readiness %**. A dumb View.
class CyclePresetStep extends StatelessWidget {
  /// Creates the step.
  const CyclePresetStep({
    required this.selected,
    required this.pureCycleEnabled,
    required this.budgetMinutes,
    required this.customCycle,
    required this.onPresetSelected,
    required this.onPureCycleChanged,
    required this.onBudgetChanged,
    required this.onCustomChanged,
    super.key,
  });

  /// The captured preset (null before a pick — a sensible default is shown).
  final CyclePreset? selected;

  /// Whether Pure-cycle mode is on.
  final bool pureCycleEnabled;

  /// The captured daily budget (null before set — the default is shown).
  final int? budgetMinutes;

  /// The captured Custom fields (null until Custom is edited).
  final CustomCycleConfig? customCycle;

  /// Emits the chosen preset.
  final ValueChanged<CyclePreset> onPresetSelected;

  /// Emits the Pure-cycle toggle value.
  final ValueChanged<bool> onPureCycleChanged;

  /// Emits the chosen daily budget.
  final ValueChanged<int> onBudgetChanged;

  /// Emits an updated Custom config.
  final ValueChanged<CustomCycleConfig> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    const region = kDefaultTermSetRegion;
    final effective = selected ?? CyclePreset.weeklyKhatm;
    final budget = budgetMinutes ?? kDefaultDailyBudgetMinutes;

    return ListView(
      padding: EdgeInsetsDirectional.all(space.space4),
      children: [
        Text(
          l10n.onboardingCyclePresetStepTitle,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: space.space2),
        Text(
          l10n.onboardingCyclePresetStepBody,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: space.space4),
        CyclePresetPicker(
          presets: [
            SettingsOption(
              value: CyclePreset.weeklyKhatm,
              label: l10n.cycleWeeklyKhatm(region),
            ),
            SettingsOption(
              value: CyclePreset.oneJuzPerDay,
              label: l10n.cycleOneJuzPerDay(region),
            ),
            SettingsOption(
              value: CyclePreset.halfJuzPerDay,
              label: l10n.cycleHalfJuzPerDay(region),
            ),
            SettingsOption(
              value: CyclePreset.twoJuzPerDay,
              label: l10n.cycleTwoJuzPerDay(region),
            ),
            SettingsOption(
              value: CyclePreset.custom,
              label: l10n.cycleCustom(region),
              disclosure: true,
            ),
          ],
          selected: effective,
          onPresetSelected: onPresetSelected,
          pureCycleEnabled: pureCycleEnabled,
          onPureCycleChanged: onPureCycleChanged,
          pureCycleLabel: l10n.cyclePureMode(region),
          pureCycleSubtitle: l10n.cyclePureModeSubtitle,
        ),
        SizedBox(height: space.space4),
        if (effective == CyclePreset.custom)
          CustomCycleEditor(
            config: customCycle ?? kDefaultCustomCycle,
            budgetMinutes: budget,
            onConfigChanged: onCustomChanged,
            onBudgetChanged: onBudgetChanged,
          )
        else ...[
          BoundedStepper(
            label: l10n.dailyBudgetLabel,
            value: budget,
            min: kMinDailyBudgetMinutes,
            max: kMaxDailyBudgetMinutes,
            step: kBudgetStepMinutes,
            onChanged: onBudgetChanged,
          ),
          // The chosen budget as a calm "{count} minutes" line — the count is
          // remapped to the locale numeral set downstream (intl #197).
          Text(
            toLocaleNumerals(
              l10n.dailyBudgetMinutes(budget),
              Localizations.localeOf(context),
            ),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
