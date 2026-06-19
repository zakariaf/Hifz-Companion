// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show JuzConfidence;
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_providers.dart';

/// Where the cold-start sub-step is: capturing input, seeding (committing), or
/// a calm retryable failure.
enum OnboardingStatus {
  /// The user is selecting held juz / rating confidence.
  capturing,

  /// The seed is committing through the single write path.
  seeding,

  /// The seed write failed; the View offers a calm retry.
  failed,
}

/// The immutable cold-start capture: which juz are held and each held juz's
/// self-reported confidence. An un-held juz is simply absent (it stays
/// `UNMEMORIZED`), never a stored "0%".
@immutable
class OnboardingState {
  /// Creates the capture state.
  const OnboardingState({
    this.heldJuz = const <int>{},
    this.confidence = const <int, JuzConfidence>{},
    this.status = OnboardingStatus.capturing,
  });

  /// The juz (1–30) the ḥāfiẓ holds.
  final Set<int> heldJuz;

  /// The per-held-juz self-reported confidence.
  final Map<int, JuzConfidence> confidence;

  /// The current step status.
  final OnboardingStatus status;

  /// Whether every held juz has a confidence pick (the gate for committing).
  bool get isReadyToSeed =>
      heldJuz.isNotEmpty && heldJuz.every(confidence.containsKey);

  /// Returns a copy with the given fields replaced.
  OnboardingState copyWith({
    Set<int>? heldJuz,
    Map<int, JuzConfidence>? confidence,
    OnboardingStatus? status,
  }) =>
      OnboardingState(
        heldJuz: heldJuz ?? this.heldJuz,
        confidence: confidence ?? this.confidence,
        status: status ?? this.status,
      );
}

/// The cold-start sub-step controller: holds the capture state and runs the
/// seed through the single write path. It navigates nothing and computes no
/// `(D, S)` — it delegates to [ColdStartSeeder] (which calls the pure engine)
/// and flips the active profile only **after** the durable commit.
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Toggles whether [juz] is held; un-holding a juz also drops its confidence.
  void toggleJuz(int juz) {
    final held = Set<int>.of(state.heldJuz);
    final confidence = Map<int, JuzConfidence>.of(state.confidence);
    if (held.remove(juz)) {
      confidence.remove(juz);
    } else {
      held.add(juz);
    }
    state = state.copyWith(heldJuz: held, confidence: confidence);
  }

  /// Records the self-reported [confidence] for a held [juz].
  void setConfidence(int juz, JuzConfidence confidence) {
    if (!state.heldJuz.contains(juz)) return;
    state = state.copyWith(
      confidence: Map<int, JuzConfidence>.of(state.confidence)
        ..[juz] = confidence,
    );
  }

  /// Seeds the profile through the single write path, then makes it active so
  /// `appReady` flips and Today has a real queue. Persist precedes republish:
  /// the active profile is set only after the commit resolves; on failure the
  /// status becomes [OnboardingStatus.failed] and no profile is activated.
  Future<void> commitPlacement() async {
    if (!state.isReadyToSeed) return;
    state = state.copyWith(status: OnboardingStatus.seeding);
    try {
      final profileId = await ref.read(coldStartSeederProvider).seed(
            heldJuz: state.heldJuz,
            confidence: state.confidence,
            today: ref.read(todayProvider),
          );
      ref.read(activeProfileProvider.notifier).select(profileId);
    } on Exception {
      state = state.copyWith(status: OnboardingStatus.failed);
    }
  }
}
