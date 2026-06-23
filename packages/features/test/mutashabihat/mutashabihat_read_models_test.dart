// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The trainer read models (E14-T06): two read-only projections wired through the
// injected repositories. Provider tests over plain in-memory fakes — no mock
// framework, no DB, no clock. The DAO assembly + the re-emit-after-write are
// proven at the data tier; this pins the provider wiring + per-profile isolation.

import 'package:composition/composition.dart'
    show confusionRepositoryProvider, referenceRepositoryProvider;
import 'package:data/data.dart' show ConfusionRepository, ReferenceRepository;
import 'package:features/features.dart'
    show
        confusionHotspotsProvider,
        mutashabihGroupProvider,
        mutashabihGroupsProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../test_setup.dart';

const _profileA = ProfileId('A');
const _profileB = ProfileId('B');

class _FakeReferenceRepository implements ReferenceRepository {
  _FakeReferenceRepository({this.groups = const [], this.views = const {}});
  final List<MutashabihGroup> groups;
  final Map<String, MutashabihGroupView> views;

  @override
  Future<List<MutashabihGroup>> allMutashabihGroups() async => groups;

  @override
  Future<MutashabihGroupView?> mutashabihGroupView(String groupId) async =>
      views[groupId];

  @override
  Future<String?> mutashabihGroupIdForAyah(String ayahId) async => null;

  @override
  Future<List<int>> pageIdsForJuz(int juz) => throw UnimplementedError();
  @override
  Future<List<Line>> linesForPage(int pageNumber) => throw UnimplementedError();
  @override
  Future<int?> firstPageOf(JumpTarget target) => throw UnimplementedError();
}

class _FakeConfusionRepository implements ConfusionRepository {
  _FakeConfusionRepository(this.byProfile);
  final Map<ProfileId, List<ConfusionEdge>> byProfile;

  @override
  Stream<List<ConfusionEdge>> watchEdgesForProfile(ProfileId profileId) =>
      Stream<List<ConfusionEdge>>.value(byProfile[profileId] ?? const []);

  @override
  Future<void> logSwap({
    required ProfileId profileId,
    required String ayahX,
    required String ayahY,
    required CalendarDate today,
  }) =>
      throw UnimplementedError();
}

ConfusionEdge _edge(ProfileId p, String a, String b, double w) =>
    ConfusionEdge.between(
      p,
      a,
      b,
      weight: w,
      lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
    );

ProviderContainer _container({
  ReferenceRepository? reference,
  ConfusionRepository? confusion,
}) {
  final container = ProviderContainer(
    overrides: [
      referenceRepositoryProvider
          .overrideWithValue(reference ?? _FakeReferenceRepository()),
      confusionRepositoryProvider
          .overrideWithValue(confusion ?? _FakeConfusionRepository(const {})),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  useOfflineTestPolicy();

  test('mutashabihGroupsProvider returns the reference repo groups', () async {
    final container = _container(
      reference: _FakeReferenceRepository(
        groups: const [
          MutashabihGroup(groupId: 'g1', type: MutashabihType.nearIdentical),
          MutashabihGroup(groupId: 'g2', type: MutashabihType.identical),
        ],
      ),
    );
    container.listen(mutashabihGroupsProvider, (_, __) {});
    final groups = await container.read(mutashabihGroupsProvider.future);
    expect(groups.map((g) => g.groupId), ['g1', 'g2']);
  });

  test('mutashabihGroupProvider returns the assembled group view', () async {
    const view = MutashabihGroupView(
      groupId: 'g1',
      type: MutashabihType.nearIdentical,
      noteKey: 'note_g1',
      members: [
        MutashabihMemberView(
          ayahId: '2:1',
          pageNumber: 1,
          distinguishingWordIndices: [0, 2],
        ),
        MutashabihMemberView(
          ayahId: '2:3',
          pageNumber: 2,
          distinguishingWordIndices: [1],
        ),
      ],
    );
    final container = _container(
      reference: _FakeReferenceRepository(views: const {'g1': view}),
    );
    container.listen(mutashabihGroupProvider('g1'), (_, __) {});
    final result = await container.read(mutashabihGroupProvider('g1').future);
    expect(result, view); // whole group (group-not-node), value-equal
    expect(result!.members, hasLength(2));
  });

  test('confusionHotspotsProvider passes the per-profile ranked edges through',
      () async {
    final container = _container(
      confusion: _FakeConfusionRepository({
        _profileA: [
          _edge(_profileA, '2:1', '2:3', 9),
          _edge(_profileA, '2:1', '2:2', 1),
        ],
      }),
    );
    container.listen(confusionHotspotsProvider(_profileA), (_, __) {});
    final hotspots =
        await container.read(confusionHotspotsProvider(_profileA).future);
    expect(hotspots.map((e) => e.weight), [9, 1]); // ranking preserved
  });

  test('per-profile isolation: A and B return disjoint hotspots', () async {
    final container = _container(
      confusion: _FakeConfusionRepository({
        _profileA: [_edge(_profileA, '2:1', '2:2', 5)],
        _profileB: [_edge(_profileB, '2:3', '2:4', 2)],
      }),
    );
    container.listen(confusionHotspotsProvider(_profileA), (_, __) {});
    container.listen(confusionHotspotsProvider(_profileB), (_, __) {});
    final a = await container.read(confusionHotspotsProvider(_profileA).future);
    final b = await container.read(confusionHotspotsProvider(_profileB).future);
    expect(a.single.ayahA, '2:1');
    expect(a.every((e) => e.profileId == _profileA), isTrue);
    expect(b.single.ayahA, '2:3');
    expect(b.every((e) => e.profileId == _profileB), isTrue);
  });

  test('empty / first-run: a profile with no swaps emits an empty list',
      () async {
    final container = _container(
      confusion: _FakeConfusionRepository(const {}),
    );
    container.listen(confusionHotspotsProvider(_profileA), (_, __) {});
    final hotspots =
        await container.read(confusionHotspotsProvider(_profileA).future);
    expect(hotspots, isEmpty);
  });

  // No mutation / no clock on this path: the providers expose no write method and
  // contain no DateTime.now()/onReview/expandMutashabihat/drift symbol — every
  // write to either graph is the single write path elsewhere (T01 load, T03
  // logSwap). Grep-verifiable over mutashabihat_providers.dart.
}
