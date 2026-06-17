// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';

import 'profiles.dart';

/// The `cycle_config` user table — one revision-cycle configuration per profile
/// (05 §2; PRD §10.2, §7.6).
///
/// `profile_id` is PK and FK in one (one config per profile). `far_cycle_days`
/// is the cycle ceiling (`> 0`). `cycle_type` is free TEXT — the named-preset
/// set is validated at the feature/engine layer, since presets evolve. `STRICT`.
@DataClassName('CycleConfigRow')
class CycleConfigs extends Table {
  @override
  String get tableName => 'cycle_config';

  /// The owning profile — PK and FK (`ON DELETE CASCADE`).
  TextColumn get profileId =>
      text().references(Profiles, #profileId, onDelete: KeyAction.cascade)();

  /// The named cycle preset (free TEXT, e.g. `7_manzil`).
  TextColumn get cycleType => text()();

  /// New lines introduced per day (≥ 0).
  IntColumn get newLinesPerDay => integer().withDefault(const Constant(0))();

  /// The near-revision window width in juz (≥ 0).
  IntColumn get nearWindowJuz => integer()();

  /// The far-revision target pages per day (≥ 0).
  IntColumn get farTargetPerDay => integer()();

  /// The far-cycle ceiling in days (`> 0`; PRD §7.6).
  IntColumn get farCycleDays => integer()();

  /// The daily revision time budget in minutes (`> 0`).
  IntColumn get dailyBudgetMinutes => integer()();

  /// Whether pure-cycle mode is on.
  BoolColumn get pureCycleMode =>
      boolean().withDefault(const Constant(false))();

  /// The sabaq/sabqi/manzil term set the UI renders (a key into `l10n`).
  TextColumn get termLabelSet => text()();

  /// An optional regional preset hint, or null.
  TextColumn get regionPreset => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {profileId};

  @override
  List<String> get customConstraints => const [
        'CHECK (new_lines_per_day >= 0)',
        'CHECK (near_window_juz >= 0)',
        'CHECK (far_target_per_day >= 0)',
        'CHECK (far_cycle_days > 0)',
        'CHECK (daily_budget_minutes > 0)',
      ];

  @override
  bool get isStrict => true;
}
