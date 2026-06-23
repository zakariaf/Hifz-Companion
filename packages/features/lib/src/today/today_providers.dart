// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_recorder.dart';
import 'today_session.dart';
import 'today_session_builder.dart';
import 'today_view_model.dart';

/// The reactive Today read model: the immutable [TodaySession] for the active
/// profile — the engine's pre-built day grouped Far → Near → New, the budget
/// flag, and the coexisting catch-up plan — recomputed on every committed card
/// write (04 §3 — derived read models are `StreamProvider`s over Drift).
///
/// The engine's schedule methods are reached **only** inside [buildTodaySession]
/// here, never in the controller or View. Ordering/`R` are computed on read,
/// never stored. Empty when no profile is active. Because it watches the
/// committed card stream, a graded page re-emits only after the review is
/// durably on disk (persist-before-republish) — there is no second place to
/// update, no manual republish.
final todaySessionProvider = StreamProvider<TodaySession>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) {
    return Stream<TodaySession>.value(const TodaySession.empty());
  }
  final engine = ref.watch(engineProvider);
  final today = ref.watch(todayProvider);
  return ref
      .watch(cardRepositoryProvider)
      .watchForProfile(profileId)
      .map((cards) => buildTodaySession(cards, today, engine));
});

/// The 1:1 Today view-model provider — the single thing the dumb [TodayScreen]
/// reads (04 §1.3). App-scope (never `autoDispose`): Today is the persistent
/// home tab and the controller holds no per-screen state. It publishes the
/// immutable [TodaySession]; tests drive its states by overriding the upstream
/// [todaySessionProvider], never the notifier.
final todayControllerProvider =
    AsyncNotifierProvider<TodayController, TodaySession>(TodayController.new);

/// The grade-one-page command, wired from the composition seams (the persistence
/// handle's read seam + single write path, and the pure engine).
///
/// App-scope (no `autoDispose`): it holds no per-screen state — it is a thin
/// orchestrator the Today view's grade button calls (E07-T08). It opens no IO
/// itself; the live handle/engine arrive through the overridden seams.
final reviewRecorderProvider = Provider<ReviewRecorder>((ref) {
  final persistence = ref.watch(persistenceProvider);
  return ReviewRecorder(
    cards: persistence.cards,
    reviews: persistence.reviews,
    engine: ref.watch(engineProvider),
  );
});
