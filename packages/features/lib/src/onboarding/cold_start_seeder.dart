// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show ColdStartRepository, ReferenceRepository;
import 'package:engine/engine.dart'
    show CalendarDate, CardSeed, ColdStart, JuzConfidence, SchedulingEngine;
import 'package:models/models.dart'
    show
        CycleConfig,
        Profile,
        ProfileId,
        ProfileLocale,
        ProfileRole,
        kKfgqpcHafsMadaniV2Edition;

import '../ids/uuid_v4.dart';

/// The cold-start seed orchestration (06 §5; PRD §7.10) — the engine owns the
/// priors.
///
/// For every held juz it expands the fixed juz→page span (from the read-only
/// reference data, C-031) and asks the pure engine for each page's conservative
/// prior via `coldStartCard(pageId, confidence, today)` — the UI invents no
/// `(D, S)`. The seeded cards persist through the single all-or-nothing
/// [ColdStartRepository.seedColdStart] write path, committed before the caller
/// republishes "ready". `memorizedOn` is omitted (stale-time decay is E11), so
/// every held page is due now and the first weeks revise each once.
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

  /// Seeds a new profile from the captured coverage + per-juz [confidence] on
  /// the injected [today]; returns the new profile's id once durably committed.
  ///
  /// An un-held (or unrated) juz produces no card. Throws the data layer's
  /// sealed cold-start write error on failure (leaving zero rows) — the caller
  /// must not mark the profile ready until this resolves.
  Future<ProfileId> seed({
    required Set<int> heldJuz,
    required Map<int, JuzConfidence> confidence,
    required CalendarDate today,
    String displayName = 'self',
    ProfileLocale locale = ProfileLocale.fa,
  }) async {
    final profileId = ProfileId(_newId());
    final orderedJuz = heldJuz.toList()..sort();
    // The per-juz page-span reads are independent — run them concurrently and
    // keep juz order (Future.wait preserves input order). The engine is the sole
    // source of (D, S, track); no UI seed table. A held-but-unrated juz yields
    // no card.
    final seedGroups = await Future.wait(
      orderedJuz.map((juz) async {
        final juzConfidence = confidence[juz];
        if (juzConfidence == null) return const <CardSeed>[];
        final pageIds = await _reference.pageIdsForJuz(juz);
        return [
          for (final pageId in pageIds)
            _engine.coldStartCard(pageId, juzConfidence, today),
        ];
      }),
    );
    final seeds = [for (final group in seedGroups) ...group];
    final profile = Profile(
      profileId: profileId,
      displayName: displayName,
      role: ProfileRole.self,
      locale: locale,
      mushafId: kKfgqpcHafsMadaniV2Edition.mushafId,
      // The event instant; the spine reads no wall clock (determinism), so the
      // creation moment is midnight UTC of the injected scheduling day.
      createdAtInstant: DateTime.utc(today.year, today.month, today.day),
    );
    final cycleConfig = CycleConfig(
      profileId: profileId,
      cycleType: '7_manzil',
      nearWindowJuz: 3,
      farTargetPerDay: 4,
      cycleCeilingDays: 7,
      dailyBudgetMinutes: 30,
      termLabelSet: 'classical',
    );
    // 05 §3 / 04 §4: one all-or-nothing transaction, committed before republish.
    await _coldStart.seedColdStart(profile, cycleConfig, seeds);
    return profileId;
  }
}
