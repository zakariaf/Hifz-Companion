// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show
        activeProfileProvider,
        cardRepositoryProvider,
        persistenceProvider,
        todayProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ReviewLog;

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

/// The append-only `review_log` history for one [pageId] (oldest first) — the
/// short history the page-detail sheet renders (E15-T06). Read-only, offline;
/// autoDispose+family so a closed sheet drops its query. Empty without a profile.
final reviewLogForPageProvider =
    FutureProvider.autoDispose.family<List<ReviewLog>, int>((ref, pageId) async {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return const <ReviewLog>[];
  return ref.watch(persistenceProvider).reviewLog.forPage(profileId, pageId);
});

/// The count of pages due over the next 7 days — the calm upcoming-load forecast
/// (E15-T08), a planning aid the user reads to pace revision, never a deadline
/// pile. Computed on read from the live card set + the injected "today"; stores
/// nothing and opens no socket.
final upcomingLoadProvider = StreamProvider<int>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return Stream<int>.value(0);
  final today = ref.watch(todayProvider);
  final horizon = today.epochDay + 7;
  return ref.watch(cardRepositoryProvider).watchForProfile(profileId).map(
        (cards) => cards
            .where(
              (c) =>
                  c.dueAt != null &&
                  c.dueAt!.epochDay >= today.epochDay &&
                  c.dueAt!.epochDay <= horizon,
            )
            .length,
      );
});
