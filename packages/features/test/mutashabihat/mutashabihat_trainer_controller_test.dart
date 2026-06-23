// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The trainer controller (E14-T07): a dumb composition of the E14-T06 read
// models into the immutable landing state, gated on the active profile. No
// mutation command, no navigation, no clock. Provider test over faked read
// models (never the Notifier).

import 'package:composition/composition.dart' show initialActiveProfileProvider;
import 'package:features/features.dart'
    show
        confusionHotspotsProvider,
        mutashabihGroupsProvider,
        mutashabihatTrainerControllerProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../test_setup.dart';

const _profile = ProfileId('A');

ConfusionEdge _edge(String a, String b, double w) => ConfusionEdge.between(
      _profile,
      a,
      b,
      weight: w,
      lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
    );

void main() {
  useOfflineTestPolicy();

  test('composes the group + hotspots read models for the active profile',
      () async {
    final container = ProviderContainer(
      overrides: [
        initialActiveProfileProvider.overrideWithValue(_profile),
        mutashabihGroupsProvider.overrideWith(
          (ref) async => const [
            MutashabihGroup(groupId: 'g1', type: MutashabihType.nearIdentical),
          ],
        ),
        confusionHotspotsProvider(_profile).overrideWith(
          (ref) => Stream.value([_edge('2:1', '2:2', 3)]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state =
        await container.read(mutashabihatTrainerControllerProvider.future);
    expect(state.groups.map((g) => g.groupId), ['g1']);
    expect(state.hotspots.single.weight, 3);
    expect(state.isEmpty, isFalse);
  });

  test('with no active profile, hotspots are empty but groups still load',
      () async {
    final container = ProviderContainer(
      overrides: [
        initialActiveProfileProvider.overrideWithValue(null),
        mutashabihGroupsProvider.overrideWith(
          (ref) async => const [
            MutashabihGroup(groupId: 'g1', type: MutashabihType.identical),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final state =
        await container.read(mutashabihatTrainerControllerProvider.future);
    expect(state.groups, hasLength(1));
    expect(state.hotspots, isEmpty);
  });
}
