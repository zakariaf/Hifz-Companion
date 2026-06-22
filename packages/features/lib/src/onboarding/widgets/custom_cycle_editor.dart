// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../onboarding_view_model.dart' show CustomCycleConfig;

/// Domain bounds for the budget and the Custom fields (not styling — these are
/// scheduling-config limits, so they are plain named constants).
const int kMinDailyBudgetMinutes = 5;
const int kMaxDailyBudgetMinutes = 120;
const int kDefaultDailyBudgetMinutes = 30;
const int kBudgetStepMinutes = 5;

const CustomCycleConfig kDefaultCustomCycle = CustomCycleConfig(
  farCycleDays: 30,
  nearWindowJuz: 3,
  newLinesPerDay: 0,
);

/// A bounded −/＋ stepper for one integer field. The value renders in the active
/// locale's numeral set; the buttons disable at the bounds (out-of-range input
/// is impossible rather than coerced). No slider — a discrete, named control.
class BoundedStepper extends StatelessWidget {
  /// Creates the stepper.
  const BoundedStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    super.key,
  });

  /// The localized field label.
  final String label;

  /// The current value.
  final int value;

  /// The inclusive lower bound.
  final int min;

  /// The inclusive upper bound.
  final int max;

  /// The increment/decrement amount.
  final int step;

  /// Emits the new value.
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
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            IconButton(
              onPressed: value > min ? () => onChanged(value - step) : null,
              icon: const Icon(Icons.remove),
            ),
            Text(
              formatLocaleNumber(locale, value),
              style: theme.textTheme.titleMedium,
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + step) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Custom-cycle reveal (E11-T08): exactly four bounded steppers — far-cycle
/// days · near-window juz · new-lines/day · daily-budget minutes — each mapping
/// 1:1 to an `EngineConfig`/`cycle_config` field. No raw retention target, no
/// fifth field, no slider, no unbounded input.
class CustomCycleEditor extends StatelessWidget {
  /// Creates the editor over the captured [config] and [budgetMinutes].
  const CustomCycleEditor({
    required this.config,
    required this.budgetMinutes,
    required this.onConfigChanged,
    required this.onBudgetChanged,
    super.key,
  });

  /// The captured Custom fields.
  final CustomCycleConfig config;

  /// The captured daily budget (the fourth Custom field).
  final int budgetMinutes;

  /// Emits an updated Custom config.
  final ValueChanged<CustomCycleConfig> onConfigChanged;

  /// Emits an updated daily budget.
  final ValueChanged<int> onBudgetChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BoundedStepper(
          label: l10n.customFarCycleDays,
          value: config.farCycleDays,
          min: 7,
          max: 120,
          step: 1,
          onChanged: (v) => onConfigChanged(config.copyWith(farCycleDays: v)),
        ),
        BoundedStepper(
          label: l10n.customNearWindowJuz,
          value: config.nearWindowJuz,
          min: 1,
          max: 10,
          step: 1,
          onChanged: (v) => onConfigChanged(config.copyWith(nearWindowJuz: v)),
        ),
        BoundedStepper(
          label: l10n.customNewLinesPerDay,
          value: config.newLinesPerDay,
          min: 0,
          max: 40,
          step: 1,
          onChanged: (v) => onConfigChanged(config.copyWith(newLinesPerDay: v)),
        ),
        BoundedStepper(
          label: l10n.dailyBudgetLabel,
          value: budgetMinutes,
          min: kMinDailyBudgetMinutes,
          max: kMaxDailyBudgetMinutes,
          step: kBudgetStepMinutes,
          onChanged: onBudgetChanged,
        ),
      ],
    );
  }
}
