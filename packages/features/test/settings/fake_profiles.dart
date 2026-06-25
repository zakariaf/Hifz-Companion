// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:data/data.dart' show ProfileRepository;
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

  StreamController<Profile?> _controllerFor(String id) =>
      _controllers.putIfAbsent(id, StreamController<Profile?>.broadcast);

  @override
  Future<List<Profile>> all() async => store.values.toList();

  @override
  Future<Profile?> byProfileId(ProfileId id) async => store[id.value];

  @override
  Future<void> upsert(Profile profile) async {
    store[profile.profileId.value] = profile;
    _controllerFor(profile.profileId.value).add(profile);
  }

  @override
  Stream<Profile?> watchById(ProfileId id) async* {
    yield store[id.value];
    yield* _controllerFor(id.value).stream;
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
