// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_recorder.dart';

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
