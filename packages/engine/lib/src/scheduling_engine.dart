// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'constants.dart';
import 'engine_config.dart';

/// The single stateless façade over the pure scheduling engine (06 §1).
///
/// Constructed once with an immutable [EngineConfig], then called freely: every
/// method is a pure function of its arguments and the injected `today` — it
/// reads no clock, opens no database, and consumes no randomness. The review
/// update (E04-T04), cold-start seeding (E04-T06), the trust clamp (E04-T07),
/// and the day builder (E04-T08/T09) are added as methods by those tasks.
///
/// The constructor is the **single guarded entry point** for a weight vector:
/// it asserts the length is [kFsrsWeightCount], so a 19-vs-21 (FSRS-6) mismatch
/// fails loudly here instead of silently corrupting every interval downstream
/// (06 §8).
class SchedulingEngine {
  /// Creates the engine over an immutable [config]. Asserts the FSRS weight
  /// count so a length mismatch can never silently mis-schedule.
  SchedulingEngine(this.config)
      : assert(
          config.weights.length == kFsrsWeightCount,
          'FSRS weight count mismatch: got ${config.weights.length}, '
          'expected $kFsrsWeightCount (19 = FSRS-4.5/5, 21 = FSRS-6). '
          'A length mismatch silently mis-schedules every interval — 06 §8.',
        );

  /// The immutable configuration this engine reasons over.
  final EngineConfig config;
}
