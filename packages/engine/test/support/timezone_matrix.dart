// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Committed fixtures and the date-pipeline stand-in for the DST/timezone matrix
// (07 §7 T4/T5). Pure Dart, no clock, no `dart:io` — the engine-purity gate
// bans `dart:io` from `packages/engine/test`, so a process-zone switch cannot
// live here. It does not need to: the stand-in is pure `CalendarDate` epochDay
// arithmetic with no `.toLocal()`, so it is zone-independent BY CONSTRUCTION.
// The authoritative cross-zone proof is the CI `date-matrix` job, which runs the
// engine suite once per `TZ` (Asia/Tehran · Pacific/Kiritimati · UTC) and
// compares EACH leg to the single committed [goldenSchedule] below — any zone
// dependence shows as one leg diverging. A TZ=UTC-only run is never accepted.

import 'package:engine/engine.dart';

/// One pinned scheduling card: enough to drive the date pipeline (07 §7).
///
/// `lastReviewDay` is carried for realism and the E04 swap-in (the real
/// `buildToday` measures `elapsedDays` from it); the stand-in clamp uses only
/// the pre-computed `idealDays`/`ceilingDays` offsets.
class FixtureCard {
  const FixtureCard({
    required this.pageId,
    required this.lastReviewDay,
    required this.idealDays,
    required this.ceilingDays,
  });

  final int pageId;
  final CalendarDate lastReviewDay;
  final int idealDays;
  final int ceilingDays;
}

/// A pinned multi-card fixture exercising `ideal < ceiling`, `ideal > ceiling`,
/// `ideal == ceiling`, and a due-today card.
final List<FixtureCard> pinnedFixture = [
  FixtureCard(
    pageId: 1,
    lastReviewDay: CalendarDate.ymd(2026, 3, 1),
    idealDays: 5,
    ceilingDays: 30,
  ),
  FixtureCard(
    pageId: 2,
    lastReviewDay: CalendarDate.ymd(2026, 2, 1),
    idealDays: 90, // SR wants later than the ceiling -> clamped to 30
    ceilingDays: 30,
  ),
  FixtureCard(
    pageId: 3,
    lastReviewDay: CalendarDate.ymd(2026, 3, 5),
    idealDays: 7,
    ceilingDays: 7,
  ),
  FixtureCard(
    pageId: 4,
    lastReviewDay: CalendarDate.ymd(2026, 3, 8),
    idealDays: 0, // due today
    ceilingDays: 15,
  ),
  FixtureCard(
    pageId: 5,
    lastReviewDay: CalendarDate.ymd(2025, 12, 1),
    idealDays: 60, // clamped to 45
    ceilingDays: 45,
  ),
];

/// The injected "today" the schedule is built from — a US spring-forward date.
final CalendarDate matrixToday = CalendarDate.ymd(2026, 3, 8);

/// The committed golden schedule: `(pageId, dueEpochDay)` rows for [matrixToday]
/// (epochDay 20520, verified independently via `DateTime.utc(2026,3,8)`).
///
/// Each `dueEpochDay` is `20520 + min(idealDays, ceilingDays)` — the human-
/// specified clamp offset per card, NOT the engine asserting against its own
/// live output: pages 1..5 clamp to offsets 5, 30, 7, 0, 45.
const List<(int pageId, int dueEpochDay)> goldenSchedule = [
  (1, 20525),
  (2, 20550),
  (3, 20527),
  (4, 20520),
  (5, 20565),
];

/// The date-pipeline stand-in for E04's future `buildToday`: maps each fixture
/// card's clamp through the E02-T02 `dueWithCeiling` primitive to a
/// `(pageId, dueEpochDay)` row. Pure `CalendarDate` arithmetic — zone-blind.
///
/// TODO(E04): swap this stand-in for the real `buildToday(state, today)`; the
/// `TZ`-matrix runner and [goldenSchedule] stay unchanged.
List<(int, int)> buildTodayStandin(
  List<FixtureCard> fixture,
  CalendarDate today,
) {
  return [
    for (final card in fixture)
      (
        card.pageId,
        dueWithCeiling(today, card.idealDays, card.ceilingDays).epochDay,
      ),
  ];
}
