// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show activeProfileProvider, cardRepositoryProvider, todayProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../today/today_providers.dart' show pageJuzProvider;
import 'progress_overview.dart';

/// The Progress read model: streams the whole-Quran [ProgressOverview] — per-page
/// `R` + decay band and the min-leaning juz roll-up — recomputed **on read** from
/// the live card set via the pure [buildProgressOverview] (PRD §10.3). It opens
/// no socket, records nothing, and stores no derived health; it re-emits after
/// every committed write (the card stream) and reads "today" once from the
/// injected clock. Empty until a profile exists and the bundled reference (the
/// page→juz map) has loaded.
final progressHeatmapProvider = StreamProvider<ProgressOverview>((ref) async* {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) {
    yield const ProgressOverview.empty();
    return;
  }
  final today = ref.watch(todayProvider);
  // The page→juz reference map (bundled-core); the heat-map needs it to group
  // the 604 pages into 30 juz. Empty until the reference is loaded → empty grid.
  final pageJuz = await ref.watch(pageJuzProvider.future);
  if (pageJuz.isEmpty) {
    yield const ProgressOverview.empty();
    return;
  }
  yield* ref.watch(cardRepositoryProvider).watchForProfile(profileId).map(
        (cards) => buildProgressOverview(
          cards: cards,
          pageJuz: pageJuz,
          today: today,
        ),
      );
});
