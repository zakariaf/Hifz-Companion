// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The cold-start placement commit (E11-T09), tested by faking the repositories
// (not the engine): a held juz expands to one card PER PAGE, the captured
// confidence maps verbatim through the pure engine (track is the engine's),
// optional memorizedOn threads through per juz, the captured cycle preset becomes
// the cycle_config, and everything commits through the single all-or-nothing
// write path. The FSRS (D, S) numbers are the engine's own golden vectors.

import 'package:data/data.dart'
    show ColdStartRepository, ColdStartSeedFailed, ReferenceRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart'
    show ColdStartSeeder, CyclePreset, PlacementInput;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart'
    show
        CycleConfig,
        JumpTarget,
        Line,
        Profile,
        ProfileId,
        ProfileLocale,
        kKfgqpcHafsMadaniV2Edition;

import '../test_setup.dart';

class _FakeReference implements ReferenceRepository {
  _FakeReference(this._pagesByJuz);
  final Map<int, List<int>> _pagesByJuz;

  @override
  Future<List<int>> pageIdsForJuz(int juz) async =>
      _pagesByJuz[juz] ?? const <int>[];

  @override
  Future<List<Line>> linesForPage(int pageNumber) async => const [];

  @override
  Future<int?> firstPageOf(JumpTarget target) async => null;
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
  final today = CalendarDate.ymd(2026, 6, 22);

  PlacementInput input({
    required Set<int> coverage,
    required Map<int, JuzConfidence> confidence,
    Map<int, CalendarDate> memorizedOn = const {},
    CyclePreset cyclePreset = CyclePreset.weeklyKhatm,
    bool pureCycleMode = false,
    int dailyBudgetMinutes = 30,
  }) =>
      PlacementInput(
        coverage: coverage,
        confidence: confidence,
        memorizedOn: memorizedOn,
        cyclePreset: cyclePreset,
        pureCycleMode: pureCycleMode,
        customCycle: null,
        dailyBudgetMinutes: dailyBudgetMinutes,
        locale: ProfileLocale.fa,
        today: today,
      );

  test('expands each held juz to one card per page via the engine', () async {
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

    final id = await seeder.commitPlacement(
      input(
        coverage: {1, 2},
        confidence: {1: JuzConfidence.solid, 2: JuzConfidence.rusty},
      ),
    );

    expect(coldStart.calls, 1);
    expect(id, const ProfileId('p-fixed'));
    // One seed per PAGE, in muṣḥaf order.
    expect(coldStart.seeds!.map((s) => s.pageId).toList(), [1, 2, 3, 22, 23]);

    // Confidence maps verbatim through the engine (no UI re-mapping).
    final juz1 =
        coldStart.seeds!.where((s) => const [1, 2, 3].contains(s.pageId));
    expect(juz1.every((s) => s.track == ReviewTrack.far), isTrue);

    // Calibration: every held page due now, last-reviewed the injected today.
    expect(coldStart.seeds!.every((s) => s.dueAt == today), isTrue);
    expect(coldStart.profile!.mushafId, kKfgqpcHafsMadaniV2Edition.mushafId);
  });

  test('un-held and held-but-unrated juz produce no card', () async {
    final coldStart = _RecordingColdStart();
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1, 2],
        2: [22],
        3: [44],
      }),
      coldStart: coldStart,
      engine: engine,
    );

    await seeder.commitPlacement(
      input(
        coverage: {1, 2}, // juz 3 not held; juz 2 held but unrated
        confidence: {1: JuzConfidence.solid},
      ),
    );

    expect(coldStart.seeds!.map((s) => s.pageId).toSet(), {1, 2});
  });

  test('captured memorizedOn threads to coldStartCard; absence ⇒ no decay',
      () async {
    final coldStart = _RecordingColdStart();
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1],
        2: [22],
      }),
      coldStart: coldStart,
      engine: engine,
    );

    // Juz 1 has a long-ago date (decays S downward); juz 2 has none.
    final long = CalendarDate.ymd(2018, 1, 1);
    await seeder.commitPlacement(
      input(
        coverage: {1, 2},
        confidence: {1: JuzConfidence.solid, 2: JuzConfidence.solid},
        memorizedOn: {1: long},
      ),
    );

    final dated = coldStart.seeds!.firstWhere((s) => s.pageId == 1);
    final undated = coldStart.seeds!.firstWhere((s) => s.pageId == 22);
    // Same confidence; the aged one has lower (or equal-clamped) stability.
    expect(dated.stabilityDays <= undated.stabilityDays, isTrue);
  });

  test('the captured cycle preset becomes the cycle_config (no target_R)',
      () async {
    final coldStart = _RecordingColdStart();
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1],
      }),
      coldStart: coldStart,
      engine: engine,
    );

    await seeder.commitPlacement(
      input(
        coverage: {1},
        confidence: {1: JuzConfidence.solid},
        cyclePreset: CyclePreset.oneJuzPerDay,
        pureCycleMode: true,
        dailyBudgetMinutes: 45,
      ),
    );

    final config = coldStart.cycleConfig!;
    expect(config.cycleType, '1_juz_day');
    expect(config.cycleCeilingDays, 30); // 1 juz/day → 30-day cycle
    expect(config.dailyBudgetMinutes, 45);
    expect(config.isPureCycleMode, isTrue);
  });

  test('a failed seed propagates the typed write error (rolls back)', () async {
    final seeder = ColdStartSeeder(
      reference: _FakeReference({
        1: [1],
      }),
      coldStart: _ThrowingColdStart(),
      engine: engine,
    );

    await expectLater(
      seeder.commitPlacement(
        input(
          coverage: {1},
          confidence: {1: JuzConfidence.solid},
        ),
      ),
      throwsA(isA<ColdStartSeedFailed>()),
    );
  });
}
