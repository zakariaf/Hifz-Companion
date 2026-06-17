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

  /// Creates an engine configuration. [weights] defaults to the published
  /// flashcard-average prior [kDefaultWeights45].
  const EngineConfig({this.weights = kDefaultWeights45});

  /// The engine's default configuration — the published weight prior and the
  /// shipped cycle defaults. Used wherever the engine is constructed without a
  /// profile-specific cycle (tests, and as the seed the feature layer overrides).
  factory EngineConfig.defaults() => const EngineConfig();
}
