// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The cold-start controller, tested by faking the repository (not the Notifier)
// with a FixedClock: it flips the active profile only AFTER the seed commits
// (persist-before-republish), surfaces a failed write as a retryable status
// without republishing, and refuses to commit a partial capture.

import 'dart:async';

import 'package:composition/composition.dart';
import 'package:data/data.dart'
    show ColdStartRepository, ColdStartSeedFailed, ReferenceRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart'
    show
        ColdStartSeeder,
        OnboardingStatus,
        coldStartSeederProvider,
        onboardingControllerProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show CycleConfig, Profile, ProfileId;

import '../test_setup.dart';

class _FakeReference implements ReferenceRepository {
  @override
  Future<List<int>> pageIdsForJuz(int juz) async => [juz * 10 + 1];
}

class _GatedColdStart implements ColdStartRepository {
  final Completer<void> gate = Completer<void>();
  bool started = false;

  @override
  Future<void> seedColdStart(
    Profile profile,
    CycleConfig cycleConfig,
    List<CardSeed> seeds,
  ) async {
    started = true;
    await gate.future;
  }
}

class _ThrowingColdStart implements ColdStartRepository {
  @override
  Future<void> seedColdStart(
    Profile profile,
    CycleConfig cycleConfig,
    List<CardSeed> seeds,
  ) async =>
      throw const ColdStartSeedFailed();
}

void main() {
  useOfflineTestPolicy();

  final engine = SchedulingEngine(EngineConfig.defaults());

  ProviderContainer containerWith(ColdStartRepository coldStart) {
    final container = ProviderContainer(
      overrides: [
        todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 19)),
        coldStartSeederProvider.overrideWithValue(
          ColdStartSeeder(
            reference: _FakeReference(),
            coldStart: coldStart,
            engine: engine,
            newId: () => 'p1',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('republishes the active profile only AFTER the seed commits', () async {
    final gated = _GatedColdStart();
    final container = containerWith(gated);
    final controller = container.read(onboardingControllerProvider.notifier)
      ..toggleJuz(1)
      ..setConfidence(1, JuzConfidence.solid);

    final future = controller.commitPlacement();
    await pumpEventQueue();

    // The seed is committing; the profile is NOT yet republished.
    expect(gated.started, isTrue);
    expect(container.read(activeProfileProvider), isNull);
    expect(
      container.read(onboardingControllerProvider).status,
      OnboardingStatus.seeding,
    );

    gated.gate.complete();
    await future;

    // Republished only after the durable commit.
    expect(container.read(activeProfileProvider), const ProfileId('p1'));
  });

  test('a failed seed never republishes; status becomes failed', () async {
    final container = containerWith(_ThrowingColdStart());
    final controller = container.read(onboardingControllerProvider.notifier)
      ..toggleJuz(1)
      ..setConfidence(1, JuzConfidence.solid);

    await controller.commitPlacement();

    expect(container.read(activeProfileProvider), isNull);
    expect(
      container.read(onboardingControllerProvider).status,
      OnboardingStatus.failed,
    );
  });

  test('does not commit a partial capture (held juz left unrated)', () async {
    final gated = _GatedColdStart();
    final container = containerWith(gated);
    container.read(onboardingControllerProvider.notifier).toggleJuz(1);

    await container
        .read(onboardingControllerProvider.notifier)
        .commitPlacement();

    expect(gated.started, isFalse);
    expect(container.read(activeProfileProvider), isNull);
  });

  test('un-holding a juz drops its confidence', () {
    final container = containerWith(_GatedColdStart());
    final controller = container.read(onboardingControllerProvider.notifier)
      ..toggleJuz(5)
      ..setConfidence(5, JuzConfidence.shaky)
      ..toggleJuz(5);

    final state = container.read(onboardingControllerProvider);
    expect(state.heldJuz, isEmpty);
    expect(state.confidence, isEmpty);
  });
}
