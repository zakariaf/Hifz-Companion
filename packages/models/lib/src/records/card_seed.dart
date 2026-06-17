// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import '../dates/calendar_date.dart';
import 'enums.dart';

/// One page's cold-start seed — the engine's conservative prior for a single
/// page, before it is bound to a profile (PRD §7.10; cold-start math is E11).
///
/// Carries no `profileId`: the write path ([ColdStartRepository.seedColdStart],
/// E03-T08) binds every seed to the profile it provisions. An un-held page is
/// seeded [ReviewTrack.unmemorized] with a null [dueAt] (the `card` `CHECK`
/// permits exactly this). The conservative `(difficulty, stabilityDays)` priors
/// (Solid/Shaky/Rusty, CLAIMS C-009) are produced upstream — this DTO carries
/// them, the store persists them, neither recomputes them.
@immutable
class CardSeed {
  /// The muṣḥaf page this seed is for (1–604).
  final int pageId;

  /// The seeded track (`unmemorized` for an un-held page).
  final ReviewTrack track;

  /// The seeded FSRS difficulty `D` (1–10).
  final double difficulty;

  /// The seeded FSRS stability `S` in days (≥ 0).
  final double stabilityDays;

  /// The seeded civil day last reviewed, or null.
  final CalendarDate? lastReviewedDay;

  /// The seeded civil day next due — null exactly for an unmemorized page.
  final CalendarDate? dueAt;

  /// Creates a cold-start seed for one page.
  const CardSeed({
    required this.pageId,
    required this.track,
    required this.difficulty,
    required this.stabilityDays,
    this.lastReviewedDay,
    this.dueAt,
  });
}
