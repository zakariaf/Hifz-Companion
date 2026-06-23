// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show Card;
import 'package:flutter/foundation.dart';

/// The closed set of calm list states the Today View renders (07-components §1,
/// §6). `loading` and `error` are carried by the `AsyncValue` of the controller,
/// so the value type distinguishes only the two *data* states; the `catchUp`
/// banner is modelled as a coexisting flag on [TodaySession], never a fifth
/// mutually-exclusive state that hides the day (PRD §7.9).
enum TodayListState {
  /// The day has at least one due page in some section.
  populated,

  /// The engine returned an empty plan and there is no outstanding backlog —
  /// the day is genuinely complete (the View shows a calm closing line, T04).
  allDone,
}

/// The engine's pre-built catch-up re-spread, surfaced to the View after a gap
/// (PRD §7.9). A coexisting value on [TodaySession]; non-null means the
/// `catchUp` banner (E12-T05) renders above the ordinary day. The View renders
/// the [items] in the order received and never re-spreads or re-sorts — the
/// spread math is the engine's, this is display data only.
@immutable
class TodayCatchUp {
  /// Creates the display plan over the pre-built [items].
  TodayCatchUp({
    required this.missedDays,
    required this.planDays,
    required List<Card> items,
  }) : items = List<Card>.unmodifiable(items);

  /// How many days passed without revision (pre-computed, never derived in the
  /// View from a wall clock).
  final int missedDays;

  /// The horizon of the engine's re-spread plan, in days.
  final int planDays;

  /// The plan's pages, most-decayed/prayer-critical first (engine order).
  final List<Card> items;

  @override
  bool operator ==(Object other) =>
      other is TodayCatchUp &&
      other.missedDays == missedDays &&
      other.planDays == planDays &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(missedDays, planDays, Object.hashAll(items));
}

/// The immutable Today read model the controller publishes and the dumb View
/// renders (04 §1.3). It holds the day already grouped Far (manzil) → Near
/// (sabqi) → New (sabaq) in the engine's recitation order, plus the calm budget
/// and catch-up flags — value types only, no strings, no streak/score, no Quran
/// or factual claim. The View never sorts, caps, load-balances, or reads a
/// clock; it renders exactly this.
@immutable
class TodaySession {
  /// Creates a session over the three ordered sections.
  TodaySession({
    List<Card> far = const <Card>[],
    List<Card> near = const <Card>[],
    List<Card> newSabaq = const <Card>[],
    this.budgetOverflow = false,
    this.catchUp,
  })  : far = List<Card>.unmodifiable(far),
        near = List<Card>.unmodifiable(near),
        newSabaq = List<Card>.unmodifiable(newSabaq);

  /// An empty session — the all-done shape with no due pages and no backlog.
  const TodaySession.empty()
      : far = const <Card>[],
        near = const <Card>[],
        newSabaq = const <Card>[],
        budgetOverflow = false,
        catchUp = null;

  /// The Far (manzil) section, in the engine's recitation order.
  final List<Card> far;

  /// The Near (sabqi) section, in the engine's recitation order.
  final List<Card> near;

  /// The New (sabaq) section, in the engine's recitation order.
  final List<Card> newSabaq;

  /// True when the chosen scope cannot fit the daily time budget; the View
  /// shows the honest budget-feedback line (T04). FAR/manzil is never dropped.
  final bool budgetOverflow;

  /// The pre-built catch-up plan after a gap, or null when there is none.
  final TodayCatchUp? catchUp;

  /// True when no section holds a due page.
  bool get isEmpty => far.isEmpty && near.isEmpty && newSabaq.isEmpty;

  /// The total number of due pages across the three sections.
  int get pageCount => far.length + near.length + newSabaq.length;

  /// The derived data-state: `populated` when any section has a page, else
  /// `allDone`. (Loading/error are the controller's `AsyncValue`.) The mapping
  /// is total — every session yields exactly one [TodayListState].
  TodayListState get listState =>
      isEmpty ? TodayListState.allDone : TodayListState.populated;

  /// Returns a copy with the given fields replaced.
  TodaySession copyWith({
    List<Card>? far,
    List<Card>? near,
    List<Card>? newSabaq,
    bool? budgetOverflow,
    TodayCatchUp? catchUp,
  }) =>
      TodaySession(
        far: far ?? this.far,
        near: near ?? this.near,
        newSabaq: newSabaq ?? this.newSabaq,
        budgetOverflow: budgetOverflow ?? this.budgetOverflow,
        catchUp: catchUp ?? this.catchUp,
      );

  @override
  bool operator ==(Object other) =>
      other is TodaySession &&
      listEquals(other.far, far) &&
      listEquals(other.near, near) &&
      listEquals(other.newSabaq, newSabaq) &&
      other.budgetOverflow == budgetOverflow &&
      other.catchUp == catchUp;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(far),
        Object.hashAll(near),
        Object.hashAll(newSabaq),
        budgetOverflow,
        catchUp,
      );
}
