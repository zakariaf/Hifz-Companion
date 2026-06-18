// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:models/models.dart';

/// The engine's ordered, budget-fitted plan for one day (06 §7) — an immutable
/// list of page cards in recitation order (manzil → near → new) plus the calm
/// honest [budgetOverflow] signal the load balancer (E04-T09) sets when
/// mandatory manzil exceeds the time budget.
///
/// It carries opaque page ids and a boolean only — no user-facing string, no
/// numeral, no "overdue"/red state. How the day is *displayed* (RTL, locale
/// numerals, band headers, the catch-up banner) is the fa/ckb/ar UI layer (E12).
@immutable
class DayPlan {
  /// The cards to revise today, in recitation order.
  final List<Card> items;

  /// Whether mandatory manzil overflowed the time budget — a calm honest signal
  /// the UI surfaces as a banner, never a drop (06 §7; PRD §7.9). Set by the
  /// load balancer (E04-T09); `false` before it runs.
  final bool budgetOverflow;

  /// Creates a day plan. [budgetOverflow] defaults to `false`.
  const DayPlan({required this.items, this.budgetOverflow = false});

  /// The page ids in the plan, in order — the projection INV-2 checks against.
  List<int> get allPageIds => [for (final c in items) c.pageId];

  /// A deterministic fingerprint of the ordered plan (the page-id sequence plus
  /// the overflow flag) — INV-4 asserts two builds over identical inputs are
  /// fingerprint-equal, so a reintroduced `Random`/interval fuzz fails loudly.
  String fingerprint() => '${allPageIds.join(',')}|$budgetOverflow';

  @override
  bool operator ==(Object other) =>
      other is DayPlan &&
      other.budgetOverflow == budgetOverflow &&
      other.fingerprint() == fingerprint();

  @override
  int get hashCode => fingerprint().hashCode;
}
