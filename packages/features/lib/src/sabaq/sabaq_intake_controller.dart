// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart'
    show
        SabaqIntakeRepository,
        SabaqIntakeWriteException,
        SabaqPageAlreadyStarted;
import 'package:engine/engine.dart' show SabaqIntake, SchedulingEngine;
import 'package:models/models.dart' show CalendarDate, ProfileId;

/// The outcome of a "start memorizing this page" command — rendered calmly by
/// the intake surfaces (E21-T06/T07). Never a shame or failure celebration.
enum SabaqIntakeResult {
  /// The page entered the schedule as a new sabaq card.
  started,

  /// The page was already in this profile's revision — a calm no-op, never a
  /// clobber of its live D/S state.
  alreadyStarted,

  /// The write failed and rolled back; the surface offers a calm retry.
  failed,

  /// No profile is active — nothing was written.
  noProfile,
}

/// The command behind "I've memorized this page / start revising it" — the
/// page-granular sabaq intake (E21; PRD §7.8). It reads the active profile and
/// the injected day, asks the **pure engine** for a conservative fresh-sabaq
/// seed, and persists it through the single write path (E21-T02).
///
/// It holds no state, reads no wall clock, opens no socket, and never recomputes
/// `(D, S)`/`dueAt` (the engine owns the prior; the trust clamp is the only sink).
class SabaqIntakeController {
  /// Creates the controller over the intake write path + the pure [engine],
  /// reading the active profile id and "today" at call time.
  SabaqIntakeController({
    required SabaqIntakeRepository intake,
    required SchedulingEngine engine,
    required ProfileId? Function() readActiveProfileId,
    required CalendarDate Function() readToday,
  })  : _intake = intake,
        _engine = engine,
        _readActiveProfileId = readActiveProfileId,
        _readToday = readToday;

  final SabaqIntakeRepository _intake;
  final SchedulingEngine _engine;
  final ProfileId? Function() _readActiveProfileId;
  final CalendarDate Function() _readToday;

  /// Introduces [pageId] into the active profile's schedule as a New sabaq card,
  /// returning a calm result the surface renders. A no-op (`noProfile`) when no
  /// profile is active; `alreadyStarted` when the page is already in revision.
  Future<SabaqIntakeResult> startMemorizing(int pageId) async {
    final profileId = _readActiveProfileId();
    if (profileId == null) return SabaqIntakeResult.noProfile;
    final seed = _engine.sabaqSeed(pageId, _readToday());
    try {
      await _intake.startMemorizing(profileId, seed);
      return SabaqIntakeResult.started;
    } on SabaqPageAlreadyStarted {
      return SabaqIntakeResult.alreadyStarted;
    } on SabaqIntakeWriteException {
      return SabaqIntakeResult.failed;
    }
  }
}
