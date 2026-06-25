// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show EngineConfig, SchedulingEngine;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show CycleConfig;

import 'active_cycle_config_provider.dart';

/// The pure scheduling engine as an injected DI dependency (04 §1.1; decision
/// log #4).
///
/// The engine imports no Riverpod and no Flutter — it is reached only as a
/// `Provider<SchedulingEngine>` the repository and the Today queue read. It is
/// built from the **active profile's** persisted [CycleConfig] (E16-T07): the
/// trust-clamp ceiling `cycleCeilingDays` maps to `EngineConfig.farCycleDays`,
/// Pure-cycle mode and the daily budget map directly, so changing the cycle in
/// Settings re-emits this provider and `buildToday` rebuilds deterministically.
/// Until a profile and its config exist (or in tests that wire neither), it
/// falls back to [EngineConfig.defaults] — never a throw.
final engineProvider = Provider<SchedulingEngine>((ref) {
  final config = ref.watch(activeCycleConfigProvider).asData?.value;
  return SchedulingEngine(
    config == null ? EngineConfig.defaults() : _engineConfigFor(config),
  );
});

/// Maps the persisted [config] onto the engine's runtime view. Only the day-count
/// fields the engine reasons over cross the boundary — never `target_R` (there is
/// none) or the preset string. `nearCeilingDays` is clamped to the cycle ceiling
/// so the `nearCeilingDays <= farCycleDays` invariant holds for short cycles.
EngineConfig _engineConfigFor(CycleConfig config) {
  final defaultNear = EngineConfig.defaults().nearCeilingDays;
  return EngineConfig(
    farCycleDays: config.cycleCeilingDays,
    nearCeilingDays: config.cycleCeilingDays < defaultNear
        ? config.cycleCeilingDays
        : defaultNear,
    pureCycleMode: config.isPureCycleMode,
    dailyBudgetMinutes: config.dailyBudgetMinutes,
  );
}
