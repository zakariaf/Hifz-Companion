// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'curve.dart';
import 'engine_config.dart';
import 'phases.dart';
import 'scheduling_engine.dart';

/// The trust clamp — the whole engine in one rule (06 §6; PRD §7.6): the SR
/// math may only ever pull a page *forward*, never past the user's chosen cycle.
/// The FSRS curve is a prior; this ceiling is the promise.

/// The per-card cycle ceiling in days, a pure function of `card + config`
/// (06 §6) — no clock, no profile lookup, no I/O.
///
/// Pure-cycle mode short-circuits to [EngineConfig.farCycleDays] for every
/// phase (fixed rotation). Otherwise a Near page gets [EngineConfig.nearCeilingDays]
/// and every other phase gets [EngineConfig.farCycleDays] — so the ceiling is
/// **never looser** than the far cycle anywhere. There is no path that lengthens
/// a ceiling toward infinity or exempts a page (PRD §7.12).
int cycleCeilingDays(Card card, EngineConfig config) {
  if (config.pureCycleMode) return config.farCycleDays;
  return switch (phaseOf(card)) {
    ReviewTrack.near => config.nearCeilingDays,
    ReviewTrack.far => config.farCycleDays,
    ReviewTrack.newPage =>
      config.farCycleDays, // never longer than the far cycle
    ReviewTrack.unmemorized =>
      config.farCycleDays, // defensive; never scheduled
  };
}

/// The trust clamp on the engine façade.
extension TrustClamp on SchedulingEngine {
  /// Clamps the SR-ideal next-due to the cycle ceiling: the **earlier** date,
  /// always (06 §6; PRD §7.6).
  ///
  /// `idealDue = today + interval(S, targetR(card))` is what the math wants;
  /// `ceilingDue = today + cycleCeilingDays(card, config)` is what tradition
  /// promises. Returns whichever is earlier — `min`, never `max`: SR may only
  /// make a page MORE frequent, never push it past the cycle. This is the single
  /// most-tested line in the engine.
  CalendarDate trustClamp(Card card, CalendarDate today) {
    final idealDue = today.addDays(interval(card.stabilityDays, targetR(card)));
    final ceilingDue = today.addDays(cycleCeilingDays(card, config));
    // min, never max — the earlier date wins; equal is harmless (same day).
    return idealDue.epochDay <= ceilingDue.epochDay ? idealDue : ceilingDue;
  }
}
