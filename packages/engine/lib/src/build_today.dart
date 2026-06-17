// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'curve.dart';
import 'day_plan.dart';
import 'load_balance.dart';
import 'phases.dart';
import 'scheduling_engine.dart';

/// Building the day: tradition shapes it, SR only orders it and pulls weak pages
/// forward (06 §7; PRD §7.8). Recitation order is manzil → near → new (old
/// before new); manzil is un-skippable; mutashābihāt siblings are massed into
/// one session, never spaced apart.

/// A lookup from a page card to its scholar-reviewed confusable sibling cards.
/// The dataset is owned by E05/E14; the pure engine consumes this lookup, never
/// builds the dataset. Defaults to "no siblings".
typedef ConfusionSiblings = List<Card> Function(Card card);

/// A predicate reporting whether a card is in the recent-juz window (the Near
/// band / Near→Far gate). Injected because the pure engine owns no juz map.
typedef RecentWindow = bool Function(Card card);

/// The pull-forward floor for a Far page: its retention target. A Far page whose
/// recomputed `R` has fallen below this is pulled into today even if today's
/// cycle slice does not cover it (06 §7).
double retentionFloor(Card c) => targetR(c);

/// Masses confusable siblings back-to-back in the SAME session (06 §7; PRD §9.2).
///
/// For each page in [ordered], its sibling(s) from [siblings] are spliced
/// **immediately after** it so the group recites contiguously — interference is
/// cured by massing, NEVER by spacing siblings apart. A sibling is *additive*
/// (added even if not independently due) and deduplicated by page id; an empty
/// lookup returns the input unchanged.
List<Card> expandMutashabihat(List<Card> ordered, ConfusionSiblings siblings) {
  final result = <Card>[];
  final seen = <int>{};
  for (final card in ordered) {
    if (seen.add(card.pageId)) result.add(card);
    for (final sibling in siblings(card)) {
      // Splice each new sibling adjacent to its page → same session.
      if (seen.add(sibling.pageId)) result.add(sibling);
    }
  }
  return result;
}

List<Card> _dedupByPageId(List<Card> cards) {
  final seen = <int>{};
  return [
    for (final c in cards)
      if (seen.add(c.pageId)) c,
  ];
}

/// The Far pages the chosen cycle assigns to *today* — full coverage over the
/// cycle by even round-robin on `today.epochDay` and `config.farCycleDays`, so
/// every Far page is covered exactly once per cycle. (Juz-contiguous slicing
/// needs the reference juz map, E05; this even spread guarantees coverage and a
/// flat daily load.)
List<Card> _farCycleSliceForToday(
  List<Card> far,
  CalendarDate today,
  int farCycleDays,
) {
  if (far.isEmpty) return const [];
  final bucket = today.epochDay % farCycleDays;
  final sorted = [...far]..sort((a, b) => a.pageId.compareTo(b.pageId));
  return [
    for (var i = 0; i < sorted.length; i++)
      if (i % farCycleDays == bucket) sorted[i],
  ];
}

List<Card> _sortByWeakestR(List<Card> cards, double Function(Card) rOf) {
  final sorted = [...cards];
  // Stable: weakest R first, page id as the deterministic tiebreak (INV-4).
  sorted.sort((a, b) {
    final byR = rOf(a).compareTo(rOf(b));
    return byR != 0 ? byR : a.pageId.compareTo(b.pageId);
  });
  return sorted;
}

bool _isDue(Card c, CalendarDate today) =>
    c.dueAt != null && c.dueAt!.epochDay <= today.epochDay;

/// Building the day on the engine façade.
extension BuildDay on SchedulingEngine {
  /// Builds today's revision plan (06 §7; PRD §7.8). Pure: identical inputs →
  /// fingerprint-equal plan; `R` is recomputed from the injected [today], no
  /// clock anywhere.
  ///
  /// Order is structural: `[...far, ...near, ...new]` (manzil → near → new). The
  /// FAR band is every **due** Far page (mandatory — INV-2) plus today's cycle
  /// slice (coverage) plus, when not in pure-cycle, the pull-forward of weak Far
  /// pages (`R < retentionFloor`), ordered weakest-`R` first, then mutashābihāt-
  /// expanded. NEAR is the recent-juz window, weakest-first. NEW is the due
  /// `newPage`-phase pages (solidifying / heavily-lapsed) — brand-new sabaq
  /// intake is the feature layer's job, not pure scheduling.
  ///
  /// [confusionSiblings] (the scholar-reviewed dataset lookup, E05/E14) and
  /// [recentWindow] (the most-recent-juz predicate) are injected; both default
  /// conservatively (no siblings; every Near page in the window). Budget-fitting
  /// (deferral, catch-up, peak-smoothing) is the load balancer (E04-T09); until
  /// then this returns the assembled bands with `budgetOverflow: false`.
  DayPlan buildToday(
    List<Card> cards,
    CalendarDate today, {
    ConfusionSiblings? confusionSiblings,
    RecentWindow? recentWindow,
  }) {
    final siblingsOf = confusionSiblings ?? (_) => const <Card>[];
    final inWindow = recentWindow ?? (_) => true;
    final memorized =
        cards.where((c) => c.track != ReviewTrack.unmemorized).toList();
    double rOf(Card c) => c.lastReviewedDay == null
        ? 1.0
        : retrievability(
            today.epochDay - c.lastReviewedDay!.epochDay,
            c.stabilityDays,
          );

    // FAR (manzil): the cycle guarantees coverage; every due page is mandatory;
    // SR only orders and pulls weak pages forward.
    final far = memorized.where((c) => phaseOf(c) == ReviewTrack.far).toList();
    final cycleSlice = _farCycleSliceForToday(far, today, config.farCycleDays);
    final dueFar = far.where((c) => _isDue(c, today)).toList();
    final pullFwd = config.pureCycleMode
        ? const <Card>[]
        : far.where((c) => rOf(c) < retentionFloor(c)).toList();
    final farPool = _dedupByPageId([...cycleSlice, ...pullFwd, ...dueFar]);
    final farOrdered = config.pureCycleMode
        ? (farPool..sort((a, b) => a.pageId.compareTo(b.pageId)))
        : _sortByWeakestR(farPool, rOf);
    final farToday = expandMutashabihat(farOrdered, siblingsOf);

    // NEAR (sabqi): the recent-juz window, weakest-first.
    final nearToday = _sortByWeakestR(
      memorized
          .where((c) => phaseOf(c) == ReviewTrack.near && inWindow(c))
          .toList(),
      rOf,
    );

    // NEW (sabaq): due newPage-phase pages (solidifying / heavily-lapsed).
    final newToday = _sortByWeakestR(
      memorized
          .where((c) => phaseOf(c) == ReviewTrack.newPage && _isDue(c, today))
          .toList(),
      rOf,
    );

    // Recited OLD before NEW: manzil → near → new (structural, never sorted).
    final day = [...farToday, ...nearToday, ...newToday];
    // Fit the day into the time budget: manzil mandatory, Near above the floor,
    // New on spare budget (E04-T09).
    return loadBalance(day, config.dailyBudgetMinutes, today, rOf);
  }
}
