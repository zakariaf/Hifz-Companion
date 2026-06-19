// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show BuildDay, Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_recorder.dart';

/// The reactive Today queue: the engine-selected due pages for the active
/// profile in recitation order (Far → Near → New), recomputed on every committed
/// card write (04 §3 — derived read models are `StreamProvider`s over Drift).
///
/// `R` and ordering are computed on read by `buildToday`, never stored. Empty
/// when no profile is active. Because it watches the committed card stream, a
/// graded page re-emits the queue only after the review is durably on disk
/// (persist-before-republish) — there is no second place to update.
final todayQueueProvider = StreamProvider<List<Card>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return Stream<List<Card>>.value(const <Card>[]);
  final engine = ref.watch(engineProvider);
  final today = ref.watch(todayProvider);
  return ref
      .watch(cardRepositoryProvider)
      .watchForProfile(profileId)
      .map((cards) => engine.buildToday(cards, today).items);
});

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
