// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show CycleConfigRepository;
import 'package:models/models.dart' show CycleConfig, ProfileId;

import '../design_system/pickers/cycle_preset_picker.dart' show CyclePreset;
import 'cycle_preset_config.dart';

/// The single write path for a profile's cycle configuration (the term-set
/// region in E16-T05; the cycle preset + budget in E16-T07). It reads the active
/// profile's config, applies an immutable change, and **persists transactionally
/// before** the reactive `activeCycleConfigProvider` stream republishes.
///
/// A no-op when no profile is active or its config has not been seeded yet
/// (cold-start seeds exactly one `cycle_config` row per profile during
/// onboarding). It holds no state, reads no clock, and opens no socket.
class CycleConfigWriter {
  /// Creates a writer over the [configs] repository, reading the current active
  /// profile id through [readActiveProfileId] at write time.
  CycleConfigWriter({
    required CycleConfigRepository configs,
    required ProfileId? Function() readActiveProfileId,
  })  : _configs = configs,
        _readActiveProfileId = readActiveProfileId;

  final CycleConfigRepository _configs;
  final ProfileId? Function() _readActiveProfileId;

  /// Reads the active profile's config, applies [update], and upserts the
  /// result — the generic persist-before-republish cycle-config mutation.
  Future<void> mutateActiveConfig(
    CycleConfig Function(CycleConfig current) update,
  ) async {
    final id = _readActiveProfileId();
    if (id == null) return;
    final current = await _configs.byProfile(id);
    if (current == null) return;
    await _configs.upsert(update(current));
  }

  /// Persists the chosen term-set [region] (the sabaq/sabqi/manzil vocabulary
  /// branch) — a display relabel only, never an engine grade/track change.
  Future<void> setTermSetRegion(String region) =>
      mutateActiveConfig((config) => config.copyWith(regionPreset: region));

  /// Switches to the named cycle [preset] — writes the preset's cycle_type and
  /// the trust-clamp ceiling (`cycleCeilingDays` → `EngineConfig.farCycleDays`);
  /// a named preset resets the intake/near shape, Custom keeps the current
  /// fields as the editing seed. The engine rebuilds the day deterministically.
  Future<void> setCyclePreset(CyclePreset preset) =>
      mutateActiveConfig((config) {
        final ceiling =
            farCycleDaysForPreset(preset) ?? config.cycleCeilingDays;
        final isCustom = preset == CyclePreset.custom;
        return config.copyWith(
          cycleType: cycleTypeForPreset(preset),
          cycleCeilingDays: ceiling,
          nearWindowJuz: isCustom ? config.nearWindowJuz : 3,
          newLinesPerDay: isCustom ? config.newLinesPerDay : 0,
          farTargetPerDay: farTargetPerDayFor(ceiling),
        );
      });

  /// Sets Pure-cycle mode — a single fidelity flag ("follow my cycle exactly").
  Future<void> setPureCycle({required bool enabled}) =>
      mutateActiveConfig((config) => config.copyWith(isPureCycleMode: enabled));

  /// Sets the daily revision time budget in [minutes].
  Future<void> setDailyBudget(int minutes) => mutateActiveConfig(
        (config) => config.copyWith(dailyBudgetMinutes: minutes),
      );

  /// Writes the four bounded Custom fields (cycle_type → 'custom'); each maps 1:1
  /// to a cycle_config field — no retention target, no fifth field.
  Future<void> setCustomCycle({
    required int farCycleDays,
    required int nearWindowJuz,
    required int newLinesPerDay,
  }) =>
      mutateActiveConfig(
        (config) => config.copyWith(
          cycleType: 'custom',
          cycleCeilingDays: farCycleDays,
          nearWindowJuz: nearWindowJuz,
          newLinesPerDay: newLinesPerDay,
          farTargetPerDay: farTargetPerDayFor(farCycleDays),
        ),
      );
}
