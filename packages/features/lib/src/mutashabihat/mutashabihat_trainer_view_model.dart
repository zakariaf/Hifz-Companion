// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show activeProfileProvider;
import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ConfusionEdge, MutashabihGroup;

import 'mutashabihat_providers.dart';

/// The calm landing state the Mutashābihāt trainer publishes (E14-T07): the
/// browsable confusable [groups] (the bundled reviewed dataset) and the active
/// profile's confusion [hotspots] ("you keep swapping these two"), ranked.
///
/// An immutable value carrying read-model summaries only — never a mutable
/// `Card`/`ConfusionEdge` graph, never reconstructed verse text. The rich drill
/// (E14-T08) and hotspots list (E14-T10) render from these.
@immutable
class MutashabihatTrainerState {
  /// Creates the landing state.
  const MutashabihatTrainerState({
    this.groups = const [],
    this.hotspots = const [],
  });

  /// The scholar-reviewed confusable groups available to drill.
  final List<MutashabihGroup> groups;

  /// The active profile's confusion edges, most-confused first.
  final List<ConfusionEdge> hotspots;

  /// Whether there is nothing to show yet (no dataset and no logged swaps) — the
  /// calm first-run/empty surface.
  bool get isEmpty => groups.isEmpty && hotspots.isEmpty;

  /// Returns a copy with the given fields replaced.
  MutashabihatTrainerState copyWith({
    List<MutashabihGroup>? groups,
    List<ConfusionEdge>? hotspots,
  }) =>
      MutashabihatTrainerState(
        groups: groups ?? this.groups,
        hotspots: hotspots ?? this.hotspots,
      );

  @override
  bool operator ==(Object other) =>
      other is MutashabihatTrainerState &&
      listEquals(other.groups, groups) &&
      listEquals(other.hotspots, hotspots);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(groups), Object.hashAll(hotspots));
}

/// The 1:1 view-model for the Mutashābihāt trainer landing (E14-T07).
///
/// Composes the E14-T06 read-model providers into the immutable landing state.
/// It holds **no** mutation command (the swap write is E14-T03), **never
/// navigates** (the View / `go_router` decide what is on screen), and **never
/// reads `DateTime.now()`**.
class MutashabihatTrainerController
    extends AsyncNotifier<MutashabihatTrainerState> {
  @override
  Future<MutashabihatTrainerState> build() async {
    final profile = ref.watch(activeProfileProvider);
    final groups = await ref.watch(mutashabihGroupsProvider.future);
    if (profile == null) {
      return MutashabihatTrainerState(groups: groups);
    }
    final hotspots = await ref.watch(confusionHotspotsProvider(profile).future);
    return MutashabihatTrainerState(groups: groups, hotspots: hotspots);
  }
}

/// The trainer's 1:1 controller provider.
final mutashabihatTrainerControllerProvider = AsyncNotifierProvider<
    MutashabihatTrainerController, MutashabihatTrainerState>(
  MutashabihatTrainerController.new,
);
