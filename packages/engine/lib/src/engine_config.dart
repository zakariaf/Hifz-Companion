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
/// Fields are added by the dependency-ordered tasks: E04-T10 lands [weights];
/// E04-T07 adds the cycle ceilings; E04-T08 adds the day budget; **E21-T01 fills
/// the reserved sabaq-intake slot ([newLinesPerDay])**. All are named with
/// defaults so a later field never breaks a construction site.
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

  /// The user's daily revision time budget in **minutes** (PRD §7.9). The load
  /// balancer (E04-T09) fits the day into it — deferring above-floor Near pages,
  /// never dropping manzil. A plain minute count, not a retention dial.
  final int dailyBudgetMinutes;

  /// The daily new-memorization (sabaq) intake allotment in **new lines/day**
  /// (PRD §7.8, §15.1). **Default 0**: the app ships as pure maintenance; a value
  /// is opt-in via the Custom cycle. The feature layer (E16) maps the persisted
  /// `CycleConfig.newLinesPerDay` onto this, and the load balancer (E21-T03)
  /// reads it to pace the daily New load — old before new, budget first, manzil
  /// never dropped. A plain count, never a retention dial; no recommended number
  /// is shown (no registered CLAIMS row exists for one).
  final int newLinesPerDay;

  /// Creates an engine configuration. [weights] defaults to the published
  /// flashcard-average prior [kDefaultWeights45]; the cycle defaults are a
  /// one-juz-a-day shape the feature layer overrides per profile.
  const EngineConfig({
    this.weights = kDefaultWeights45,
    this.farCycleDays = 30,
    this.nearCeilingDays = 7,
    this.pureCycleMode = false,
    this.dailyBudgetMinutes = 30,
    this.newLinesPerDay = 0,
  })  : assert(farCycleDays > 0, 'farCycleDays must be positive'),
        assert(nearCeilingDays > 0, 'nearCeilingDays must be positive'),
        assert(dailyBudgetMinutes >= 0, 'dailyBudgetMinutes must be ≥ 0'),
        assert(newLinesPerDay >= 0, 'newLinesPerDay must be ≥ 0'),
        assert(
          nearCeilingDays <= farCycleDays,
          'nearCeilingDays must never be looser than farCycleDays (06 §6).',
        );

  /// The engine's default configuration — the published weight prior and the
  /// shipped cycle defaults. Used wherever the engine is constructed without a
  /// profile-specific cycle (tests, and as the seed the feature layer overrides).
  factory EngineConfig.defaults() => const EngineConfig();
}
