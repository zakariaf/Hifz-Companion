// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E21-T06/T07: the "start memorizing this page" command. It asks the pure engine
// for a conservative fresh-sabaq seed and persists it through the single write
// path, mapping the outcome to a calm result — no profile is a no-op, an
// already-started page is not a failure.

import 'package:data/data.dart'
    show
        SabaqIntakeRepository,
        SabaqIntakeConstraintViolated,
        SabaqPageAlreadyStarted;
import 'package:engine/engine.dart' show EngineConfig, SchedulingEngine;
import 'package:features/features.dart'
    show SabaqIntakeController, SabaqIntakeResult;
import 'package:models/models.dart' show CalendarDate, CardSeed, ProfileId;
import 'package:flutter_test/flutter_test.dart';

class _FakeIntake implements SabaqIntakeRepository {
  final List<(ProfileId, CardSeed)> calls = [];
  Object? throwThis;

  @override
  Future<void> startMemorizing(ProfileId profileId, CardSeed seed) async {
    calls.add((profileId, seed));
    if (throwThis != null) throw throwThis!;
  }
}

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());
  final today = CalendarDate.ymd(2026, 7, 11);

  SabaqIntakeController controller(
    _FakeIntake intake, {
    ProfileId? profile = const ProfileId('p1'),
  }) =>
      SabaqIntakeController(
        intake: intake,
        engine: engine,
        readActiveProfileId: () => profile,
        readToday: () => today,
      );

  test('starting a page seeds a NEW card via the write path', () async {
    final intake = _FakeIntake();
    final result = await controller(intake).startMemorizing(3);
    expect(result, SabaqIntakeResult.started);
    expect(intake.calls, hasLength(1));
    final (profileId, seed) = intake.calls.single;
    expect(profileId, const ProfileId('p1'));
    // The engine owns the conservative prior — a NEW card due today.
    expect(seed.pageId, 3);
    expect(seed.dueAt, today);
  });

  test('no active profile is a calm no-op (nothing written)', () async {
    final intake = _FakeIntake();
    final result = await controller(intake, profile: null).startMemorizing(3);
    expect(result, SabaqIntakeResult.noProfile);
    expect(intake.calls, isEmpty);
  });

  test('an already-started page is not a failure', () async {
    final intake = _FakeIntake()..throwThis = const SabaqPageAlreadyStarted();
    final result = await controller(intake).startMemorizing(3);
    expect(result, SabaqIntakeResult.alreadyStarted);
  });

  test('a write failure maps to a calm retry result', () async {
    final intake = _FakeIntake()
      ..throwThis = const SabaqIntakeConstraintViolated();
    final result = await controller(intake).startMemorizing(3);
    expect(result, SabaqIntakeResult.failed);
  });
}
