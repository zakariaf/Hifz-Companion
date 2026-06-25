// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart' show kKfgqpcHafsMadaniV2Edition;

import '../design_system/pickers/cycle_preset_picker.dart' show CyclePreset;

/// The named-cycle ↔ persisted-config helpers the Settings cycle surface writes
/// through (PRD §15.1). These mirror onboarding's cold-start seeder
/// (`_cycleTypeFor` / `farCycleDaysFor`) — both are the canonical preset markers
/// and must stay in sync; settings cannot import onboarding's `src/`. There is
/// **no `target_R`** here: a named cycle, never a retention dial.

/// Daily-budget bounds in minutes (scheduling-config limits, not design tokens).
const int kMinDailyBudgetMinutes = 5;
const int kMaxDailyBudgetMinutes = 120;
const int kBudgetStepMinutes = 5;

/// Custom-cycle field bounds (each maps 1:1 to a `cycle_config` field).
const int kMinFarCycleDays = 7;
const int kMaxFarCycleDays = 120;
const int kMinNearWindowJuz = 1;
const int kMaxNearWindowJuz = 10;
const int kMinNewLinesPerDay = 0;
const int kMaxNewLinesPerDay = 40;

/// The named preset → far-cycle ceiling (days); Custom carries its own ceiling
/// and returns null. 7-Manzil → 7, 1 juz/day → 30, ½ → 60, 2 juz/day → 15.
int? farCycleDaysForPreset(CyclePreset preset) => switch (preset) {
      CyclePreset.weeklyKhatm => 7,
      CyclePreset.oneJuzPerDay => 30,
      CyclePreset.halfJuzPerDay => 60,
      CyclePreset.twoJuzPerDay => 15,
      CyclePreset.custom => null,
    };

/// The named preset → persisted `cycle_type` string.
String cycleTypeForPreset(CyclePreset preset) => switch (preset) {
      CyclePreset.weeklyKhatm => '7_manzil',
      CyclePreset.oneJuzPerDay => '1_juz_day',
      CyclePreset.halfJuzPerDay => '0.5_juz_day',
      CyclePreset.twoJuzPerDay => '2_juz_day',
      CyclePreset.custom => 'custom',
    };

/// The persisted `cycle_type` string → named preset for the picker's selection;
/// an unknown type shows as Custom.
CyclePreset cyclePresetForType(String cycleType) => switch (cycleType) {
      '7_manzil' => CyclePreset.weeklyKhatm,
      '1_juz_day' => CyclePreset.oneJuzPerDay,
      '0.5_juz_day' => CyclePreset.halfJuzPerDay,
      '2_juz_day' => CyclePreset.twoJuzPerDay,
      _ => CyclePreset.custom,
    };

/// Far-revision pages/day to complete the cycle over [ceilingDays] (the muṣḥaf
/// page count over the ceiling) — the persisted `far_target_per_day`.
int farTargetPerDayFor(int ceilingDays) =>
    (kKfgqpcHafsMadaniV2Edition.pageCount / ceilingDays).ceil();
