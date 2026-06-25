// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show activeCycleConfigProvider, termSetRegionProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/pickers/cycle_preset_picker.dart';
import '../../design_system/pickers/settings_picker.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../cycle_config_writer.dart';
import '../cycle_preset_config.dart';
import '../settings_providers.dart';
import 'settings_section.dart';

/// The Cycle group of the Settings screen (PRD §15.1): the named cycle-preset
/// picker, the Pure-cycle fidelity toggle, the daily time budget, and the Custom
/// four-field editor. Every control writes only `cycle_config` through the
/// [CycleConfigWriter] — the trust-clamp ceiling that the engine's `buildToday`
/// reads — **never a `target_R`, a retention slider, or an FSRS number**.
///
/// A dumb View: it reads the active profile's persisted config and renders E10's
/// [CyclePresetPicker] plus bounded steppers; it computes no schedule.
class CycleSettingsSection extends ConsumerWidget {
  /// Creates the Cycle settings group.
  const CycleSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final config = ref.watch(activeCycleConfigProvider).asData?.value;
    final region = ref.watch(termSetRegionProvider);
    final writer = ref.read(cycleConfigWriterProvider);

    final preset = config == null
        ? CyclePreset.weeklyKhatm
        : cyclePresetForType(config.cycleType);
    final budget = config?.dailyBudgetMinutes ?? 30;

    return SettingsSection(
      title: l10n.settingsSectionCycle,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                selected: preset,
                onPresetSelected: writer.setCyclePreset,
                pureCycleEnabled: config?.isPureCycleMode ?? false,
                onPureCycleChanged: (value) =>
                    writer.setPureCycle(enabled: value),
                pureCycleLabel: l10n.cyclePureMode(region),
                pureCycleSubtitle: l10n.cyclePureModeSubtitle,
              ),
              SizedBox(height: space.space4),
              if (preset == CyclePreset.custom)
                _CustomCycleEditor(
                  farCycleDays: config?.cycleCeilingDays ?? kMinFarCycleDays,
                  nearWindowJuz: config?.nearWindowJuz ?? kMinNearWindowJuz,
                  newLinesPerDay: config?.newLinesPerDay ?? kMinNewLinesPerDay,
                  budget: budget,
                  writer: writer,
                )
              else
                _SettingsStepper(
                  label: l10n.dailyBudgetLabel,
                  value: budget,
                  min: kMinDailyBudgetMinutes,
                  max: kMaxDailyBudgetMinutes,
                  step: kBudgetStepMinutes,
                  onChanged: writer.setDailyBudget,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The Custom-cycle reveal — exactly four bounded steppers, each mapping 1:1 to a
/// `cycle_config` field (far-cycle days · near-window juz · new-lines/day · daily
/// budget). No retention target, no fifth field, no slider.
class _CustomCycleEditor extends StatelessWidget {
  const _CustomCycleEditor({
    required this.farCycleDays,
    required this.nearWindowJuz,
    required this.newLinesPerDay,
    required this.budget,
    required this.writer,
  });

  final int farCycleDays;
  final int nearWindowJuz;
  final int newLinesPerDay;
  final int budget;
  final CycleConfigWriter writer;

  void _writeCustom({int? far, int? near, int? lines}) => writer.setCustomCycle(
        farCycleDays: far ?? farCycleDays,
        nearWindowJuz: near ?? nearWindowJuz,
        newLinesPerDay: lines ?? newLinesPerDay,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsStepper(
          label: l10n.customFarCycleDays,
          value: farCycleDays,
          min: kMinFarCycleDays,
          max: kMaxFarCycleDays,
          step: 1,
          onChanged: (v) => _writeCustom(far: v),
        ),
        _SettingsStepper(
          label: l10n.customNearWindowJuz,
          value: nearWindowJuz,
          min: kMinNearWindowJuz,
          max: kMaxNearWindowJuz,
          step: 1,
          onChanged: (v) => _writeCustom(near: v),
        ),
        _SettingsStepper(
          label: l10n.customNewLinesPerDay,
          value: newLinesPerDay,
          min: kMinNewLinesPerDay,
          max: kMaxNewLinesPerDay,
          step: 1,
          onChanged: (v) => _writeCustom(lines: v),
        ),
        _SettingsStepper(
          label: l10n.dailyBudgetLabel,
          value: budget,
          min: kMinDailyBudgetMinutes,
          max: kMaxDailyBudgetMinutes,
          step: kBudgetStepMinutes,
          onChanged: writer.setDailyBudget,
        ),
      ],
    );
  }
}

/// A bounded −/＋ stepper for one integer field (the value in the locale numeral
/// set; buttons disable at the bounds — out-of-range input is impossible). No
/// slider. (A settings-local twin of onboarding's BoundedStepper, which lives in
/// another feature's `src/` and cannot be imported across the feature boundary.)
class _SettingsStepper extends StatelessWidget {
  const _SettingsStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);
    return Semantics(
      label: label,
      value: formatLocaleNumber(locale, value),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: space.space1),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            IconButton(
              onPressed:
                  value - step >= min ? () => onChanged(value - step) : null,
              icon: const Icon(Icons.remove),
            ),
            Text(
              formatLocaleNumber(locale, value),
              style: theme.textTheme.titleMedium,
            ),
            IconButton(
              onPressed:
                  value + step <= max ? () => onChanged(value + step) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
