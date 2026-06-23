// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart'
    show
        BuildDay,
        CalendarDate,
        Card,
        DayPlan,
        LoadBalance,
        ReviewTrack,
        SchedulingEngine,
        estMinutes,
        phaseOf,
        retrievability;

import 'today_session.dart';

/// The minimum overdue gap (days) that turns the ordinary day into a calm
/// catch-up situation. Opening a day late (gap < this) is the normal day; a
/// larger gap means the user genuinely missed days and the re-spread plan is
/// offered instead of a dumped pile. A read-model classification threshold, not
/// FSRS math.
const int kCatchUpMinGapDays = 2;

/// The upper bound on the catch-up re-spread horizon (days), so the offered plan
/// never sprawls.
const int kCatchUpMaxSpreadDays = 14;

/// Builds the immutable [TodaySession] read model from the live card set
/// (04 §1.3; PRD §7.8–§7.9). This is the one place the engine's schedule methods
/// are reached for the Today surface — the controller and View never call them.
/// It runs the engine's pre-built day, groups it Far → Near → New by the engine's
/// own [phaseOf] (never re-sorting within a section), carries the budget-overflow
/// flag, and — when an overdue backlog indicates a missed gap — surfaces the
/// engine's pre-built re-spread plan as a coexisting [TodayCatchUp]. It never
/// computes stability/retrievability of its own beyond the engine's exported
/// curve, never reads a clock (the [today] is injected), and never mutates.
TodaySession buildTodaySession(
  List<Card> cards,
  CalendarDate today,
  SchedulingEngine engine,
) {
  final DayPlan plan = engine.buildToday(cards, today);

  final far = <Card>[];
  final near = <Card>[];
  final newSabaq = <Card>[];
  for (final card in plan.items) {
    switch (phaseOf(card)) {
      case ReviewTrack.far:
        far.add(card);
      case ReviewTrack.near:
        near.add(card);
      case ReviewTrack.newPage:
        newSabaq.add(card);
      case ReviewTrack.unmemorized:
        break; // not part of the revision day
    }
  }

  return TodaySession(
    far: far,
    near: near,
    newSabaq: newSabaq,
    budgetOverflow: plan.budgetOverflow,
    catchUp: _catchUpFor(cards, today, engine),
  );
}

/// Derives the catch-up plan from the overdue backlog, or null when there is no
/// gap to catch up on. The gap (`missedDays`) is the largest number of days a
/// due page is overdue; the re-spread itself (the ordered, budget-sized plan) is
/// the engine's `catchUp` — this layer only classifies that a gap exists and
/// chooses the horizon to fit the daily budget, never re-spreading in the View.
TodayCatchUp? _catchUpFor(
  List<Card> cards,
  CalendarDate today,
  SchedulingEngine engine,
) {
  final backlog = <Card>[];
  var missedDays = 0;
  for (final card in cards) {
    final due = card.dueAt;
    if (due == null || !due.isBefore(today)) continue;
    backlog.add(card);
    final overdue = today.epochDay - due.epochDay;
    if (overdue > missedDays) missedDays = overdue;
  }
  if (backlog.isEmpty || missedDays < kCatchUpMinGapDays) return null;

  // Horizon fits the backlog into the daily budget (the engine's documented
  // caller policy: ceil(backlogMinutes / dailyBudget)), bounded so it never
  // sprawls; the engine then spreads the backlog most-decayed first.
  final backlogMinutes = backlog.fold<int>(0, (sum, c) => sum + estMinutes(c));
  final budget = engine.config.dailyBudgetMinutes;
  // Guard a zero/negative budget (a division by zero would yield infinity, and
  // .ceil() on infinity throws): degrade to a single day.
  final spreadDays = budget > 0
      ? (backlogMinutes / budget).ceil().clamp(1, kCatchUpMaxSpreadDays)
      : 1;

  double rOf(Card c) => c.lastReviewedDay == null
      ? 1.0
      : retrievability(
          today.epochDay - c.lastReviewedDay!.epochDay,
          c.stabilityDays,
        );

  final plans = engine.catchUp(backlog, spreadDays, today, rOf);
  final todayItems = plans.isEmpty ? backlog : plans.first.items;
  return TodayCatchUp(
    missedDays: missedDays,
    planDays: spreadDays,
    items: todayItems,
  );
}
