// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show Card, ReviewTrack, phaseOf;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'today_providers.dart' show todayQueueProvider;
import 'today_session.dart';

/// The 1:1 Today view-model (04 §1.3). A dumb `AsyncNotifier` that publishes one
/// immutable [TodaySession] the View renders; it holds no per-screen state, owns
/// no grade/mutation command (the single write path is E12-T06/T07), never
/// navigates, and never reads `DateTime.now()` — "today" enters only through the
/// injected `todayProvider` inside the read model it watches.
///
/// `build()` gates on the active profile, then maps the engine's pre-built day
/// (the `todayQueueProvider` read model) into the three recitation-ordered
/// sections via the engine's own `phaseOf` — it never sorts, caps, or
/// load-balances. The budget-overflow and catch-up flags arrive in E12-T02.
class TodayController extends AsyncNotifier<TodaySession> {
  @override
  Future<TodaySession> build() async {
    final profile = ref.watch(activeProfileProvider);
    if (profile == null) return const TodaySession.empty();
    // The day arrives pre-ordered, pre-capped from the engine (inside the read
    // model). Re-emits on every committed write — there is no second cache.
    final cards = await ref.watch(todayQueueProvider.future);
    return _toSession(cards);
  }

  /// Groups the engine's flat, already-ordered day into Far → Near → New,
  /// preserving the engine's index order within each section (never re-sorted).
  TodaySession _toSession(List<Card> cards) {
    final far = <Card>[];
    final near = <Card>[];
    final newSabaq = <Card>[];
    for (final card in cards) {
      switch (phaseOf(card)) {
        case ReviewTrack.far:
          far.add(card);
        case ReviewTrack.near:
          near.add(card);
        case ReviewTrack.newPage:
          newSabaq.add(card);
        case ReviewTrack.unmemorized:
          // Unmemorized pages are not part of the revision day.
          break;
      }
    }
    return TodaySession(far: far, near: near, newSabaq: newSabaq);
  }
}
