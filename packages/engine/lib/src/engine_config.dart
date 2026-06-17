// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'constants.dart';

/// The engine's immutable runtime configuration: the FSRS weight vector and the
/// chosen-cycle day-counts the scheduler reasons over (06 §6, §8).
///
/// It carries day-count integers and the weight prior — **never** a "retention
/// %", a target-R dial, a clock, a profile id, or a locale (06 §6; the stakes-
/// tiered retention targets are fixed named constants, not config fields, so
/// there is no retention slider anywhere — PRD §7.5). The feature layer (E16)
/// builds one from the persisted `CycleConfig`, mapping its `cycleCeilingDays`
/// to [farCycleDays] — this type is the engine's view, the persisted row stays
/// in `models`.
///
/// Fields are added by the dependency-ordered E04 tasks: E04-T10 lands
/// [weights]; E04-T07 adds the cycle ceilings; E04-T08/T09 add the day budget
/// and intake. All are named with defaults so a later field never breaks a
/// construction site.
@immutable
class EngineConfig {
  /// The FSRS-4.5 weight vector. Length asserted `== kFsrsWeightCount` where it
  /// first enters the engine (`SchedulingEngine`'s constructor); a 19-vs-21
  /// mismatch must fail loudly, never silently mis-schedule (06 §8).
  final List<double> weights;

  /// The far/manzil cycle ceiling in **days** — the longest interval the trust
  /// clamp allows for a Far page (e.g. 7 for a weekly khatm, 30 for one juz a
  /// day). The hard floor of the "nothing decays silently" covenant (06 §6;
  /// PRD §7.6). A day-count, never a retention %. The feature layer (E16) maps
  /// the persisted `CycleConfig.cycleCeilingDays` onto this.
  final int farCycleDays;

  /// The Near recent-juz window ceiling in **days** — never looser than
  /// [farCycleDays] (asserted at construction), so Near is always revised at
  /// least as often as Far (06 §6).
  final int nearCeilingDays;

  /// Whether pure-cycle mode is on: a fixed rotation only, SR ordering and
  /// pull-forward off, so the ceiling is [farCycleDays] for every phase — the
  /// faithful-traditional-tracker mode for ulama who distrust reordering
  /// (06 §6; PRD §7.11). Default off.
  final bool pureCycleMode;

  /// Creates an engine configuration. [weights] defaults to the published
  /// flashcard-average prior [kDefaultWeights45]; the cycle defaults are a
  /// one-juz-a-day shape the feature layer overrides per profile.
  const EngineConfig({
    this.weights = kDefaultWeights45,
    this.farCycleDays = 30,
    this.nearCeilingDays = 7,
    this.pureCycleMode = false,
  }) : assert(
          nearCeilingDays <= farCycleDays,
          'nearCeilingDays must never be looser than farCycleDays (06 §6).',
        );

  /// The engine's default configuration — the published weight prior and the
  /// shipped cycle defaults. Used wherever the engine is constructed without a
  /// profile-specific cycle (tests, and as the seed the feature layer overrides).
  factory EngineConfig.defaults() => const EngineConfig();
}
