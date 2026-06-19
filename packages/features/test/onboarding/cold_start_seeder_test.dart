// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The cold-start seed orchestration, tested by faking the repositories (not the
// engine): a held juz expands to its page cards, the captured confidence maps
// verbatim through the pure engine (so the resulting track is the engine's), and
// the seed commits through the single all-or-nothing write path. The FSRS (D, S)
// numbers are the engine's own golden vectors — here we assert wiring.

import 'package:data/data.dart'
    show ColdStartRepository, ColdStartSeedFailed, ReferenceRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart' show ColdStartSeeder;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart'
    show CycleConfig, Profile, ProfileId, kKfgqpcHafsMadaniV2Edition;

import '../test_setup.dart';

class _FakeReference implements ReferenceRepository {
  _FakeReference(this._pagesByJuz);
  final Map<int, List<int>> _pagesByJuz;

  @override
  Future<List<int>> pageIdsForJuz(int juz) async =>
      _pagesByJuz[juz] ?? const <int>[];
}

class _RecordingColdStart implements ColdStartRepository {
  Profile? profile;
  CycleConfig? cycleConfig;
  List<CardSeed>? seeds;
  int calls = 0;

  @override
  Future<void> seedColdStart(
    Profile profile,
    CycleConfig cycleConfig,
    List<CardSeed> seeds,
  ) async {
    this.profile = profile;
    this.cycleConfig = cycleConfig;
    this.seeds = seeds;
    calls++;
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

  test('expands each held juz to its page cards via the engine', () async {
    final coldStart = _RecordingColdStart();
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1, 2, 3],
        2: [22, 23],
      }),
      coldStart: coldStart,
      engine: engine,
      newId: () => 'p-fixed',
    );
    final today = CalendarDate.ymd(2026, 6, 19);

    final id = await seeder.seed(
      heldJuz: {1, 2},
      confidence: {1: JuzConfidence.solid, 2: JuzConfidence.rusty},
      today: today,
    );

    expect(coldStart.calls, 1);
    expect(id, const ProfileId('p-fixed'));
    expect(coldStart.seeds!.map((s) => s.pageId).toList(), [1, 2, 3, 22, 23]);

    // Confidence maps verbatim through the engine: solid → FAR, rusty → NEW
    // (the seed table's bandForStability), proving no UI re-mapping.
    final juz1 =
        coldStart.seeds!.where((s) => const [1, 2, 3].contains(s.pageId));
    expect(juz1.every((s) => s.track == ReviewTrack.far), isTrue);
    final juz2 =
        coldStart.seeds!.where((s) => const [22, 23].contains(s.pageId));
    expect(juz2.every((s) => s.track == ReviewTrack.newPage), isTrue);

    // Calibration: every held page due now, last-reviewed today (injected).
    expect(coldStart.seeds!.every((s) => s.dueAt == today), isTrue);
    expect(coldStart.seeds!.every((s) => s.lastReviewedDay == today), isTrue);

    // Profile + cycle config bound to the new id; default muṣḥaf edition.
    expect(coldStart.profile!.profileId, const ProfileId('p-fixed'));
    expect(coldStart.cycleConfig!.profileId, const ProfileId('p-fixed'));
    expect(coldStart.profile!.mushafId, kKfgqpcHafsMadaniV2Edition.mushafId);
  });

  test('un-held juz produce no card', () async {
    final coldStart = _RecordingColdStart();
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1, 2],
        3: [44, 45],
      }),
      coldStart: coldStart,
      engine: engine,
    );

    await seeder.seed(
      heldJuz: {1},
      confidence: {1: JuzConfidence.solid},
      today: CalendarDate.ymd(2026, 6, 19),
    );

    expect(coldStart.seeds!.map((s) => s.pageId).toSet(), {1, 2});
  });

  test('a held-but-unrated juz is skipped (no card, no crash)', () async {
    final coldStart = _RecordingColdStart();
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1],
        2: [22],
      }),
      coldStart: coldStart,
      engine: engine,
    );

    await seeder.seed(
      heldJuz: {1, 2},
      confidence: {1: JuzConfidence.solid}, // juz 2 held but unrated
      today: CalendarDate.ymd(2026, 6, 19),
    );

    expect(coldStart.seeds!.map((s) => s.pageId).toSet(), {1});
  });

  test('a failed seed propagates the typed write error', () async {
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1],
      }),
      coldStart: _ThrowingColdStart(),
      engine: engine,
    );

    await expectLater(
      seeder.seed(
        heldJuz: {1},
        confidence: {1: JuzConfidence.solid},
        today: CalendarDate.ymd(2026, 6, 19),
      ),
      throwsA(isA<ColdStartSeedFailed>()),
    );
  });
}
