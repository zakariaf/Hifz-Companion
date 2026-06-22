// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The Today controller maps the engine's pre-built day into the immutable
// TodaySession, grouped Far → Near → New in the engine's order, gated on the
// active profile. Provider test over a faked queue — no widget tree, no DB.

import 'dart:async';

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show Card;
import 'package:features/features.dart'
    show
        TodayListState,
        TodaySession,
        todayControllerProvider,
        todayQueueProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  // Each override builds a FRESH stream per subscription (a single-subscription
  // Stream.value reused across listens throws). A keep-alive listener subscribes
  // the graph before the .future is awaited.
  Future<TodaySession> session(
    List<Card> cards, {
    bool withProfile = true,
  }) async {
    final container = ProviderContainer(
      overrides: [
        if (withProfile)
          initialActiveProfileProvider.overrideWithValue(kTestProfile),
        todayProvider.overrideWithValue(kToday),
        todayQueueProvider.overrideWith((ref) => Stream.value(cards)),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(todayControllerProvider, (_, __) {});
    addTearDown(sub.close);
    return container.read(todayControllerProvider.future);
  }

  test('no active profile yields the empty all-done session', () async {
    final s = await session([dueFar(1)], withProfile: false);
    expect(s.isEmpty, isTrue);
    expect(s.listState, TodayListState.allDone);
  });

  test('an empty day maps to the all-done state', () async {
    final s = await session(const <Card>[]);
    expect(s.listState, TodayListState.allDone);
    expect(s.pageCount, 0);
  });

  test('groups the day into Far → Near → New by phase, populated', () async {
    final s = await session([dueFar(10), dueNear(20), dueNew(30)]);
    expect(s.listState, TodayListState.populated);
    expect(s.far.map((c) => c.pageId), [10]);
    expect(s.near.map((c) => c.pageId), [20]);
    expect(s.newSabaq.map((c) => c.pageId), [30]);
  });

  test('preserves the engine order within each section (no re-sort)', () async {
    final s = await session([dueFar(7), dueFar(3), dueFar(5)]);
    // Index order is the engine's; the controller never re-sorts by page id.
    expect(s.far.map((c) => c.pageId), [7, 3, 5]);
  });

  test('the published sections are unmodifiable', () async {
    final s = await session([dueFar(1)]);
    expect(() => s.far.add(dueFar(2)), throwsUnsupportedError);
  });

  test('a queue error surfaces as a controller error', () async {
    final c = StreamController<List<Card>>();
    addTearDown(c.close);
    final container = ProviderContainer(
      overrides: [
        initialActiveProfileProvider.overrideWithValue(kTestProfile),
        todayProvider.overrideWithValue(kToday),
        todayQueueProvider.overrideWith((ref) => c.stream),
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
