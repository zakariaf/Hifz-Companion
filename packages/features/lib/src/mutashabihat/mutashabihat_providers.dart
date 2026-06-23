// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show confusionRepositoryProvider, referenceRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart'
    show ConfusionEdge, MutashabihGroup, MutashabihGroupView, ProfileId;

/// The read models the Mutashābihāt trainer binds to (E14-T06): two read-only
/// projections of the local store, reached through the injected repositories on
/// [persistenceProvider] / [confusionRepositoryProvider] — never a raw DAO and
/// never a `DateTime.now()`. The Views (E14-T07/T08/T10) `ref.watch` these and
/// render; they do not query, parse, or sort.

/// Every scholar-reviewed mutashābihāt group, for the calm browse list.
///
/// A `FutureProvider`, not a stream: the `mutashabih_*` reference tables are
/// **read-only and bundled once**, so the set is static after install — a Future
/// is the honest shape (the hotspots below are a stream because they re-emit on
/// every committed write). Empty until the dataset loads (bundle-first).
final mutashabihGroupsProvider =
    FutureProvider.autoDispose<List<MutashabihGroup>>(
  (ref) => ref.watch(referenceRepositoryProvider).allMutashabihGroups(),
);

/// One group's assembled view (members + page + distinguishing-word indices),
/// keyed by group id — the whole group the discrimination drill iterates
/// (group-not-node). Null if the group is absent.
final mutashabihGroupProvider =
    FutureProvider.autoDispose.family<MutashabihGroupView?, String>(
  (ref, groupId) =>
      ref.watch(referenceRepositoryProvider).mutashabihGroupView(groupId),
);

/// The active profile's confusion hotspots ("you keep swapping these two"),
/// ranked most-confused first (`weight` DESC, then `last_confused_at` DESC).
///
/// A `family`+`autoDispose` `StreamProvider` keyed by the stable [ProfileId] (no
/// global "current profile", zero leakage between students); it re-emits after a
/// committed `logSwap` so the View rebuilds from the durable store, never a
/// second cache. The ranking is data-supplied by the DAO, not view-computed.
final confusionHotspotsProvider =
    StreamProvider.autoDispose.family<List<ConfusionEdge>, ProfileId>(
  (ref, profileId) =>
      ref.watch(confusionRepositoryProvider).watchEdgesForProfile(profileId),
);
