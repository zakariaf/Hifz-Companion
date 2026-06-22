// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show ColdStartRepository, ReferenceRepository;
import 'package:engine/engine.dart' show CardSeed, ColdStart, SchedulingEngine;
import 'package:models/models.dart'
    show
        CycleConfig,
        Profile,
        ProfileId,
        ProfileRole,
        kKfgqpcHafsMadaniV2Edition;

import '../design_system/pickers/cycle_preset_picker.dart' show CyclePreset;
import '../ids/uuid_v4.dart';
import 'onboarding_view_model.dart' show PlacementInput;
import 'widgets/cycle_preset_mapping.dart';
import 'widgets/custom_cycle_editor.dart' show kDefaultCustomCycle;

/// The cold-start placement commit (06 §5; PRD §7.10) — the largest single write
/// in the app, the *sanad*-load-bearing one.
///
/// For every held page (the fixed juz→page span from the read-only reference
/// data, C-031) it asks the pure engine for each page's conservative prior via
/// `coldStartCard(pageId, confidence, today, memorizedOn:)` — the UI invents no
/// `(D, S)` and hardcodes no seed table. The seeded cards **plus** the
/// `cycle_config` (mapped from the named preset) persist through the single
/// all-or-nothing [ColdStartRepository.seedColdStart] transaction, committed
/// **before** the caller republishes the active profile. A mid-commit failure
/// rolls back (WAL) — there is never a profile with a partial card set.
class ColdStartSeeder {
  /// Creates the seeder over the reference read, the cold-start write path, and
  /// the pure engine. [newId] supplies the profile id (default a v4 UUID).
  ColdStartSeeder({
    required ReferenceRepository reference,
    required ColdStartRepository coldStart,
    required SchedulingEngine engine,
    String Function() newId = uuidV4,
  })  : _reference = reference,
        _coldStart = coldStart,
        _engine = engine,
        _newId = newId;

  final ReferenceRepository _reference;
  final ColdStartRepository _coldStart;
  final SchedulingEngine _engine;
  final String Function() _newId;

  /// Commits the captured [input] as a seeded, durable profile; returns the new
  /// profile id once the write is durable. Throws the data layer's sealed
  /// cold-start write error on failure (leaving zero rows) — the caller must not
  /// republish the active profile until this resolves.
  Future<ProfileId> commitPlacement(PlacementInput input) async {
    final profileId = ProfileId(_newId());
    final orderedJuz = input.coverage.toList()..sort();
    // The per-juz page-span reads are independent — run them concurrently and
    // keep juz order (Future.wait preserves input order). The engine is the sole
    // source of (D, S, track); a held-but-unrated juz yields no card.
    final seedGroups = await Future.wait(
      orderedJuz.map((juz) async {
        final juzConfidence = input.confidence[juz];
        if (juzConfidence == null) return const <CardSeed>[];
        final pageIds = await _reference.pageIdsForJuz(juz);
        return [
          // One coldStartCard call per PAGE (a juz spans ~20 pages), threading
          // the optional captured memorizedOn for stale-time decay.
          for (final pageId in pageIds)
            _engine.coldStartCard(
              pageId,
              juzConfidence,
              input.today,
              memorizedOn: input.memorizedOn[juz],
            ),
        ];
      }),
    );
    final seeds = [for (final group in seedGroups) ...group];
    final profile = Profile(
      profileId: profileId,
      displayName: 'self',
      role: ProfileRole.self,
      locale: input.locale,
      mushafId: kKfgqpcHafsMadaniV2Edition.mushafId,
      // The event instant; the spine reads no wall clock (determinism), so the
      // creation moment is midnight UTC of the injected scheduling day.
      createdAtInstant:
          DateTime.utc(input.today.year, input.today.month, input.today.day),
    );
    // 05 §3 / 04 §4: one all-or-nothing transaction, committed before republish.
    await _coldStart.seedColdStart(
      profile,
      _cycleConfigFor(profileId, input),
      seeds,
    );
    return profileId;
  }
}

/// Maps the captured named preset (+ Pure-cycle / Custom / budget) to the
/// persisted `cycle_config`. The load-bearing field is [CycleConfig.cycleCeilingDays]
/// (= the trust clamp's far-cycle ceiling); there is **no `target_R`**.
CycleConfig _cycleConfigFor(ProfileId profileId, PlacementInput input) {
  final custom = input.customCycle ?? kDefaultCustomCycle;
  final ceiling = farCycleDaysFor(input.cyclePreset) ?? custom.farCycleDays;
  final isCustom = input.cyclePreset == CyclePreset.custom;
  return CycleConfig(
    profileId: profileId,
    cycleType: _cycleTypeFor(input.cyclePreset),
    nearWindowJuz: isCustom ? custom.nearWindowJuz : 3,
    newLinesPerDay: isCustom ? custom.newLinesPerDay : 0,
    // Far-revision pages/day to complete the cycle (604 pages over the ceiling).
    farTargetPerDay: (604 / ceiling).ceil(),
    cycleCeilingDays: ceiling,
    dailyBudgetMinutes: input.dailyBudgetMinutes,
    isPureCycleMode: input.pureCycleMode,
    termLabelSet: 'classical',
  );
}

String _cycleTypeFor(CyclePreset preset) => switch (preset) {
      CyclePreset.weeklyKhatm => '7_manzil',
      CyclePreset.oneJuzPerDay => '1_juz_day',
      CyclePreset.halfJuzPerDay => '0.5_juz_day',
      CyclePreset.twoJuzPerDay => '2_juz_day',
      CyclePreset.custom => 'custom',
    };
