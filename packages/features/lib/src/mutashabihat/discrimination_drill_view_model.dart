// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show MutashabihMemberView;

import 'mutashabihat_providers.dart';

/// One branch's recall phase in the discrimination drill (science 05 §6):
/// hidden (recite the continuation from memory) → revealed (the immutable page
/// is shown) → anchored (the distinguishing-word overlay is added). The order is
/// mandatory — the page (and the anchor) are never shown before a recall attempt.
enum BranchPhase {
  /// The immutable page is occluded; the ḥāfiẓ recites from memory.
  hidden,

  /// The immutable page is revealed after a reveal tap.
  revealed,

  /// The distinguishing-word anchor overlay is shown over the revealed page.
  anchored,
}

/// The immutable discrimination-drill state (E14-T08): the whole confusable
/// group's [members] in order, the [activeIndex] into them, each member's
/// [phases] entry, and whether the group is [isComplete].
///
/// It carries only the member geometry/refs the E05 page view + overlay seam
/// consume — never a rendered string, glyph code, or reconstructed verse.
@immutable
class DiscriminationDrillState {
  /// Creates the drill state.
  const DiscriminationDrillState({
    required this.members,
    required this.activeIndex,
    required this.phases,
    this.isComplete = false,
  });

  /// The whole group's members, in stable order (group-not-node — always ≥ 2).
  final List<MutashabihMemberView> members;

  /// The index of the member currently being drilled.
  final int activeIndex;

  /// One [BranchPhase] per member, parallel to [members].
  final List<BranchPhase> phases;

  /// Whether the last member has been drilled and the group is complete.
  final bool isComplete;

  /// The member currently being drilled.
  MutashabihMemberView get activeMember => members[activeIndex];

  /// The current member's phase.
  BranchPhase get activePhase => phases[activeIndex];

  /// Whether the active member is the last in the group.
  bool get isLastBranch => activeIndex == members.length - 1;

  /// Returns a copy with the given fields replaced.
  DiscriminationDrillState copyWith({
    int? activeIndex,
    List<BranchPhase>? phases,
    bool? isComplete,
  }) =>
      DiscriminationDrillState(
        members: members,
        activeIndex: activeIndex ?? this.activeIndex,
        phases: phases ?? this.phases,
        isComplete: isComplete ?? this.isComplete,
      );

  @override
  bool operator ==(Object other) =>
      other is DiscriminationDrillState &&
      listEquals(other.members, members) &&
      other.activeIndex == activeIndex &&
      listEquals(other.phases, phases) &&
      other.isComplete == isComplete;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(members),
        activeIndex,
        Object.hashAll(phases),
        isComplete,
      );
}

/// The 1:1 discrimination-drill view-model, `family`-keyed by group id and
/// `autoDispose`d (E14-T08).
///
/// `build` reads the E14-T06 group read model and starts the whole group at
/// `activeIndex 0` with every branch `hidden`. It exposes only **ephemeral** UI
/// transitions — [reveal], [showAnchor], [next] — never a persisted mutation (the
/// swap write is E14-T03), never navigates, and never reads `DateTime.now()`.
class DiscriminationDrillController
    extends AsyncNotifier<DiscriminationDrillState> {
  /// Creates the controller for [groupId] (the family key).
  DiscriminationDrillController(this.groupId);

  /// The confusable group being drilled.
  final String groupId;

  @override
  Future<DiscriminationDrillState> build() async {
    final group = await ref.watch(mutashabihGroupProvider(groupId).future);
    if (group == null) {
      throw StateError('mutashābihāt group "$groupId" was not found');
    }
    return DiscriminationDrillState(
      members: group.members,
      activeIndex: 0,
      phases:
          List<BranchPhase>.filled(group.members.length, BranchPhase.hidden),
    );
  }

  /// Reveals the active branch's immutable page (`hidden → revealed`).
  void reveal() {
    final current = state.value;
    if (current == null || current.activePhase != BranchPhase.hidden) return;
    state = AsyncData(
      current.copyWith(phases: _withPhase(current, BranchPhase.revealed)),
    );
  }

  /// Adds the distinguishing-word anchor to the active branch
  /// (`revealed → anchored`).
  void showAnchor() {
    final current = state.value;
    if (current == null || current.activePhase != BranchPhase.revealed) return;
    state = AsyncData(
      current.copyWith(phases: _withPhase(current, BranchPhase.anchored)),
    );
  }

  /// Advances to the next sibling back-to-back (`anchored` → next member
  /// `hidden`), or completes the group after the last member. No spacing, no
  /// interstitial — juxtaposition is the cure (science 05 §5).
  void next() {
    final current = state.value;
    if (current == null || current.activePhase != BranchPhase.anchored) return;
    if (current.isLastBranch) {
      state = AsyncData(current.copyWith(isComplete: true));
      return;
    }
    final nextIndex = current.activeIndex + 1;
    final phases = [...current.phases]..[nextIndex] = BranchPhase.hidden;
    state = AsyncData(current.copyWith(activeIndex: nextIndex, phases: phases));
  }

  List<BranchPhase> _withPhase(
    DiscriminationDrillState current,
    BranchPhase phase,
  ) =>
      [...current.phases]..[current.activeIndex] = phase;
}

/// The discrimination-drill controller provider, `family` by group id +
/// `autoDispose`.
final discriminationDrillControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DiscriminationDrillController, DiscriminationDrillState, String>(
  DiscriminationDrillController.new,
);
