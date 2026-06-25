// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:data/data.dart' show CycleConfigRepository, ProfileRepository;
import 'package:models/models.dart';

/// An in-memory [ProfileRepository] for Settings tests: `watchById` emits the
/// current row on listen then re-emits each committed upsert — the same
/// observable contract as Drift's `watchSingleOrNull`, without a database.
class FakeProfileRepository implements ProfileRepository {
  /// Creates the fake seeded with [seed].
  FakeProfileRepository(Iterable<Profile> seed) {
    for (final p in seed) {
      store[p.profileId.value] = p;
    }
  }

  /// The current rows, keyed by profile id — tests assert against this directly.
  final Map<String, Profile> store = {};
  final Map<String, StreamController<Profile?>> _controllers = {};
  final StreamController<List<Profile>> _allController =
      StreamController<List<Profile>>.broadcast();

  StreamController<Profile?> _controllerFor(String id) =>
      _controllers.putIfAbsent(id, StreamController<Profile?>.broadcast);

  void _emitAll() => _allController.add(store.values.toList());

  @override
  Future<List<Profile>> all() async => store.values.toList();

  @override
  Future<Profile?> byProfileId(ProfileId id) async => store[id.value];

  @override
  Future<void> upsert(Profile profile) async {
    store[profile.profileId.value] = profile;
    _controllerFor(profile.profileId.value).add(profile);
    _emitAll();
  }

  @override
  Future<void> delete(ProfileId id) async {
    store.remove(id.value);
    _controllerFor(id.value).add(null);
    _emitAll();
  }

  @override
  Stream<Profile?> watchById(ProfileId id) async* {
    yield store[id.value];
    yield* _controllerFor(id.value).stream;
  }

  @override
  Stream<List<Profile>> watchAll() async* {
    yield store.values.toList();
    yield* _allController.stream;
  }
}

/// A minimal profile fixture — only the required fields; the only PII is the name.
Profile fakeProfile(
  String id, {
  Map<String, Object?>? settings,
  ProfileLocale locale = ProfileLocale.fa,
}) =>
    Profile(
      profileId: ProfileId(id),
      displayName: 'name-$id',
      role: ProfileRole.self,
      locale: locale,
      mushafId: 'm1',
      createdAtInstant: DateTime.utc(2026, 6, 17),
      settings: settings,
    );

/// An in-memory [CycleConfigRepository] for Settings tests — the same
/// emit-current-then-re-emit contract as the Drift `watchSingleOrNull`.
class FakeCycleConfigRepository implements CycleConfigRepository {
  /// Creates the fake seeded with [seed].
  FakeCycleConfigRepository([Iterable<CycleConfig> seed = const []]) {
    for (final c in seed) {
      store[c.profileId.value] = c;
    }
  }

  /// The current configs, keyed by profile id — tests assert against this.
  final Map<String, CycleConfig> store = {};
  final Map<String, StreamController<CycleConfig?>> _controllers = {};

  StreamController<CycleConfig?> _controllerFor(String id) =>
      _controllers.putIfAbsent(id, StreamController<CycleConfig?>.broadcast);

  @override
  Future<CycleConfig?> byProfile(ProfileId id) async => store[id.value];

  @override
  Future<void> upsert(CycleConfig config) async {
    store[config.profileId.value] = config;
    _controllerFor(config.profileId.value).add(config);
  }

  @override
  Stream<CycleConfig?> watchByProfile(ProfileId id) async* {
    yield store[id.value];
    yield* _controllerFor(id.value).stream;
  }
}

/// A minimal cycle-config fixture (a 7-Manzil weekly khatm; valid CHECK values).
CycleConfig fakeCycleConfig(String id, {String? regionPreset}) => CycleConfig(
      profileId: ProfileId(id),
      cycleType: '7_manzil',
      nearWindowJuz: 1,
      farTargetPerDay: 1,
      cycleCeilingDays: 7,
      dailyBudgetMinutes: 30,
      termLabelSet: 'classical',
      regionPreset: regionPreset,
    );
