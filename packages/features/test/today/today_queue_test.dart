// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The Today queue StreamProvider: it runs the real pure engine's buildToday over
// the active profile's card stream and re-emits on every write — proven by
// faking the card repository with a controllable stream (no DB, no FK fixture).

import 'dart:async';

import 'package:composition/composition.dart';
import 'package:data/data.dart' show CardRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart' show todayQueueProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

class _StreamCards implements CardRepository {
  final StreamController<List<Card>> _controller =
      StreamController<List<Card>>.broadcast();

  void emit(List<Card> cards) => _controller.add(cards);

  @override
  Stream<List<Card>> watchForProfile(ProfileId profile) => _controller.stream;

  @override
  Future<Card?> byId(ProfileId profile, int pageId) async => null;

  @override
  Future<List<Card>> forProfile(ProfileId profile) async => const <Card>[];
}

Card dueFar(int pageId) => Card(
      profileId: const ProfileId('p1'),
      pageId: pageId,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 30,
      lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
      dueAt: CalendarDate.ymd(2026, 6, 19),
    );

void main() {
  useOfflineTestPolicy();

  test('is empty when no profile is active', () async {
    final container = ProviderContainer(
      overrides: [cardRepositoryProvider.overrideWithValue(_StreamCards())],
    );
    addTearDown(container.dispose);
    final sub = container.listen(todayQueueProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();
    expect(container.read(todayQueueProvider).asData?.value, isEmpty);
  });

  test('runs buildToday over the card stream and re-emits on a write',
      () async {
    final cards = _StreamCards();
    final container = ProviderContainer(
      overrides: [
        cardRepositoryProvider.overrideWithValue(cards),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
        todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 19)),
      ],
    );
    addTearDown(container.dispose);

    final emissions = <Set<int>>[];
    final sub = container.listen(todayQueueProvider, (_, next) {
      final value = next.asData?.value;
      if (value != null) emissions.add(value.map((c) => c.pageId).toSet());
    });
    addTearDown(sub.close);

    cards.emit([dueFar(1), dueFar(2)]);
    await pumpEventQueue();
    cards.emit([dueFar(1)]);
    await pumpEventQueue();

    // The two due pages appeared, then the queue re-emitted with page 2 gone —
    // the reactive read tracks the committed card set.
    expect(emissions.any((s) => s.containsAll(<int>{1, 2})), isTrue);
    expect(emissions.last, <int>{1});
  });
}
