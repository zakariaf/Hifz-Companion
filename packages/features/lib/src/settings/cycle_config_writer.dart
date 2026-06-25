// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show CycleConfigRepository;
import 'package:models/models.dart' show CycleConfig, ProfileId;

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
}
