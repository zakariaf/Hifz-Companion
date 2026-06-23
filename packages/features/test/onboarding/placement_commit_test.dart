// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The controller's placement commit (E11-T09): persist strictly BEFORE republish
// — the active profile flips only AFTER the durable commit resolves; a failed
// commit republishes nothing (a calm retry state). Faked at the repository so no
// real DB is touched.

import 'dart:async';
import 'dart:ui' show Locale;

import 'package:composition/composition.dart';
import 'package:data/data.dart'
    show ColdStartRepository, ColdStartSeedFailed, ReferenceRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart'
    show
        ColdStartSeeder,
        PlacementStatus,
        coldStartSeederProvider,
        onboardingControllerProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart'
    show CycleConfig, JumpTarget, Line, Profile, ProfileId;

import '../test_setup.dart';

class _FakeReference implements ReferenceRepository {
  @override
  Future<List<int>> pageIdsForJuz(int juz) async => [juz * 10 + 1];

  @override
  Future<List<Line>> linesForPage(int pageNumber) async => const [];

  @override
  Future<int?> firstPageOf(JumpTarget target) async => null;
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
        todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 22)),
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
    // Keep the autoDispose family controller alive across reads so the notifier
    // we drive and the one we read back are the same instance (and it isn't
    // disposed mid-commit).
    container.listen(onboardingControllerProvider(null), (_, __) {});
    return container;
  }

  PlacementStatus placementOf(ProviderContainer c) =>
      c.read(onboardingControllerProvider(null)).placement;

  test('persist before republish: profile flips only after the commit',
      () async {
    final gated = _GatedColdStart();
    final c = containerWith(gated);
    final ctrl = c.read(onboardingControllerProvider(null).notifier)
      ..setLocale(const Locale('fa'))
      ..toggleJuz(1)
      ..setJuzConfidence(1, JuzConfidence.solid);

    final future = ctrl.commitAndBuildFirstDay();
    await pumpEventQueue();

    // Committing; NOT yet republished.
    expect(gated.started, isTrue);
    expect(c.read(activeProfileProvider), isNull);
    expect(placementOf(c), PlacementStatus.committing);

    gated.gate.complete();
    await future;

    // Republished only after the durable commit.
    expect(c.read(activeProfileProvider), const ProfileId('p1'));
  });

  test('a failed commit republishes nothing; status becomes failed', () async {
    final c = containerWith(_ThrowingColdStart());
    final ctrl = c.read(onboardingControllerProvider(null).notifier)
      ..toggleJuz(1)
      ..setJuzConfidence(1, JuzConfidence.solid);

    await ctrl.commitAndBuildFirstDay();

    expect(c.read(activeProfileProvider), isNull);
    expect(placementOf(c), PlacementStatus.failed);
  });
}
