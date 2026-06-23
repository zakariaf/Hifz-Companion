// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The Today session StreamProvider runs the real pure engine's buildTodaySession
// over the active profile's card stream and re-emits on every committed write —
// proven by faking the card repository with a controllable stream (no DB).

import 'dart:async';

import 'package:composition/composition.dart';
import 'package:data/data.dart' show CardRepository;
import 'package:engine/engine.dart' show Card;
import 'package:features/features.dart' show todaySessionProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';
import 'today_fixtures.dart';

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

void main() {
  useOfflineTestPolicy();

  test('is the empty all-done session when no profile is active', () async {
    final container = ProviderContainer(
      overrides: [cardRepositoryProvider.overrideWithValue(_StreamCards())],
    );
    addTearDown(container.dispose);
    final sub = container.listen(todaySessionProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();
    final session = container.read(todaySessionProvider).asData?.value;
    expect(session?.isEmpty, isTrue);
  });

  test('builds the session over the card stream and re-emits on a write',
      () async {
    final cards = _StreamCards();
    final container = ProviderContainer(
      overrides: [
        cardRepositoryProvider.overrideWithValue(cards),
        initialActiveProfileProvider.overrideWithValue(kTestProfile),
        todayProvider.overrideWithValue(kToday),
      ],
    );
    addTearDown(container.dispose);

    final emissions = <Set<int>>[];
    final sub = container.listen(todaySessionProvider, (_, next) {
      final value = next.asData?.value;
      if (value != null) {
        emissions.add(value.far.map((c) => c.pageId).toSet());
      }
    });
    addTearDown(sub.close);

    cards.emit([dueFar(1), dueFar(2)]);
    await pumpEventQueue();
    cards.emit([dueFar(1)]);
    await pumpEventQueue();

    // The two far pages appeared, then the session re-emitted with page 2 gone —
    // the reactive read tracks the committed card set.
    expect(emissions.any((s) => s.containsAll(<int>{1, 2})), isTrue);
    expect(emissions.last, <int>{1});
  });
}
