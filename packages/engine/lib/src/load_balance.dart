// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'constants.dart';
import 'day_plan.dart';
import 'phases.dart';
import 'scheduling_engine.dart';

/// The budget-aware load balancer and graceful missed-day catch-up (06 §7;
/// PRD §7.9): fit the assembled day into the time budget — manzil mandatory,
/// Near by urgency above the floor, New only on spare budget — and re-spread a
/// gap's backlog calmly, never a red overdue pile.

/// Estimated minutes to revise one page — the budget unit (a flat per-page
/// estimate for E04; [kEstMinutesPerPage]).
int estMinutes(Card card) => kEstMinutesPerPage;

/// Re-groups scheduled cards into recitation order: manzil → near → new,
/// preserving within-band order (06 §7).
List<Card> _orderForRecitation(List<Card> cards) => [
      ...cards.where((c) => phaseOf(c) == ReviewTrack.far),
      ...cards.where((c) => phaseOf(c) == ReviewTrack.near),
      ...cards.where((c) => phaseOf(c) == ReviewTrack.newPage),
    ];

/// The load balancer and catch-up on the engine façade.
extension LoadBalance on SchedulingEngine {
  /// Fits the assembled [day] into [budgetMin] minutes (06 §7; PRD §7.9). Pure
  /// and deterministic — no clock, no RNG.
  ///
  /// 1. **FAR/manzil is mandatory** — every Far item is scheduled with no budget
  ///    guard; an overflow sets [DayPlan.budgetOverflow] (a calm signal), never
  ///    drops a page. 2. **NEAR by urgency** (`targetR − R` descending): a page
  ///    that does not fit is deferred only while its `R` stays **above**
  ///    [kHardFloorR] (the bounded, deterministic declumping — no `Random`); a
  ///    page at or below the floor is promoted and scheduled even over budget.
  ///    3. **NEW** only while budget remains. The budget can set the overflow
  ///    flag and defer an above-floor Near page within its ceiling — never past
  ///    it, never below the floor, never a Far drop.
  DayPlan loadBalance(
    List<Card> day,
    int budgetMin,
    CalendarDate today,
    double Function(Card) rOf,
  ) {
    var budget = budgetMin;
    final scheduled = <Card>[];

    // 1. FAR/manzil due items are MANDATORY — scheduled even if they overflow.
    for (final c in day.where((c) => phaseOf(c) == ReviewTrack.far)) {
      scheduled.add(c);
      budget -= estMinutes(c);
    }
    final overflow =
        budget < 0; // a calm banner signal, never a drop (PRD §7.9)

    // 2. NEAR by urgency (targetR − R, descending); defer ONLY above the floor.
    final near = day.where((c) => phaseOf(c) == ReviewTrack.near).toList()
      ..sort((a, b) => (targetR(b) - rOf(b)).compareTo(targetR(a) - rOf(a)));
    for (final c in near) {
      if (estMinutes(c) <= budget) {
        scheduled.add(c);
        budget -= estMinutes(c);
      } else if (rOf(c) > kHardFloorR) {
        // Safe slip: defer within the ceiling (bounded declumping, no RNG).
      } else {
        scheduled.add(c); // crossed the floor → promote, cannot defer
        budget -= estMinutes(c);
      }
    }

    // 3. NEW only while budget remains (the consolidated-sabaq sub-gate is a
    // feature-layer concern — it needs profile history the pure engine lacks).
    for (final c in day.where((c) => phaseOf(c) == ReviewTrack.newPage)) {
      if (budget > 0) {
        scheduled.add(c);
        budget -= estMinutes(c);
      }
    }

    return DayPlan(
      items: _orderForRecitation(scheduled),
      budgetOverflow: overflow,
    );
  }

  /// Re-spreads a missed-day [backlog] over [spreadDays] calm plans (06 §7;
  /// PRD §7.9; CLAIMS C-042) — most-decayed and prayer-critical first, the cycle
  /// still completes. Re-spread, never a red overdue pile; emits no number and
  /// no "overdue"/streak state.
  ///
  /// The backlog is sorted by urgency (lowest `R` first, prayer-critical ahead
  /// of equal-`R` non-critical, page id as the deterministic tiebreak), then
  /// split evenly across [spreadDays] days so the most-decayed pages land first
  /// and no single day is massed. The caller chooses [spreadDays] to fit the
  /// budget (e.g. `ceil(backlogMinutes / dailyBudget)`); the union of all plans'
  /// items equals the backlog — nothing dropped, nothing dumped into one day.
  List<DayPlan> catchUp(
    List<Card> backlog,
    int spreadDays,
    CalendarDate today,
    double Function(Card) rOf,
  ) {
    assert(spreadDays > 0, 'spreadDays must be positive');
    if (backlog.isEmpty) return const [];
    final sorted = [...backlog]..sort((a, b) {
        final byR = rOf(a).compareTo(rOf(b)); // lowest R first
        if (byR != 0) return byR;
        if (a.isPrayerCritical != b.isPrayerCritical) {
          return a.isPrayerCritical
              ? -1
              : 1; // prayer-critical first at equal R
        }
        return a.pageId.compareTo(b.pageId); // deterministic tiebreak
      });
    final perDay = (sorted.length / spreadDays).ceil();
    return [
      for (var i = 0; i < sorted.length; i += perDay)
        DayPlan(
          items: sorted.sublist(
            i,
            i + perDay < sorted.length ? i + perDay : sorted.length,
          ),
        ),
    ];
  }
}
