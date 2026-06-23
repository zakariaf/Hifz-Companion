// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The Today controller is a dumb pass-through over the pre-built session read
// model, gated on the active profile. It publishes the AsyncValue states and
// exposes no mutation command. Provider test over a faked session stream.

import 'dart:async';

import 'package:composition/composition.dart';
import 'package:features/features.dart'
    show
        TodayListState,
        TodaySession,
        todayControllerProvider,
        todaySessionProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  Future<TodaySession> read(
    Stream<TodaySession> sessions, {
    bool withProfile = true,
  }) async {
    final container = ProviderContainer(
      overrides: [
        if (withProfile)
          initialActiveProfileProvider.overrideWithValue(kTestProfile),
        todayProvider.overrideWithValue(kToday),
        todaySessionProvider.overrideWith((ref) => sessions),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(todayControllerProvider, (_, __) {});
    addTearDown(sub.close);
    return container.read(todayControllerProvider.future);
  }

  test('publishes the pre-built session unchanged (populated)', () async {
    final built = TodaySession(far: [dueFar(10)], near: [dueNear(20)]);
    final s = await read(Stream<TodaySession>.value(built));
    expect(s.listState, TodayListState.populated);
    expect(s.far.map((c) => c.pageId), [10]);
    expect(s.near.map((c) => c.pageId), [20]);
  });

  test('an empty session maps to the all-done state', () async {
    final s = await read(Stream<TodaySession>.value(const TodaySession.empty()));
    expect(s.listState, TodayListState.allDone);
    expect(s.pageCount, 0);
  });

  test('no active profile still resolves to a session', () async {
    final s = await read(
      Stream<TodaySession>.value(const TodaySession.empty()),
      withProfile: false,
    );
    expect(s.isEmpty, isTrue);
  });

  test('a read-model error surfaces as a controller error', () async {
    final c = StreamController<TodaySession>();
    addTearDown(c.close);
    final container = ProviderContainer(
      overrides: [
        initialActiveProfileProvider.overrideWithValue(kTestProfile),
        todayProvider.overrideWithValue(kToday),
        todaySessionProvider.overrideWith((ref) => c.stream),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(todayControllerProvider, (_, __) {});
    addTearDown(sub.close);
    c.addError(StateError('read failed'));
    await expectLater(
      container.read(todayControllerProvider.future),
      throwsA(isA<StateError>()),
    );
    expect(container.read(todayControllerProvider).hasError, isTrue);
  });
}
