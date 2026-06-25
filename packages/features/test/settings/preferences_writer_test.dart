// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T02: the display-preference write path. PreferencesWriter persists a
// change to the active profile's settings_json BEFORE the reactive
// displayPreferencesProvider republishes; the change round-trips through the
// decoded DisplayPreferences; a null active profile is a safe no-op; and
// switching the active profile re-scopes the read to the new student.
// ProfileRepository is faked with a controllable watchById stream (no DB);
// offline guard installed — the write path opens no socket.

import 'dart:async';

import 'package:composition/composition.dart'
    show
        activeProfileProvider,
        initialActiveProfileProvider,
        profileRepositoryProvider;
import 'package:data/data.dart' show ProfileRepository;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        displayPreferencesProvider,
        preferencesWriterProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../test_setup.dart';

/// An in-memory [ProfileRepository] whose `watchById` emits the current row on
/// listen then re-emits each committed upsert — the same observable contract as
/// the Drift `watchSingleOrNull`, without a database.
class _FakeProfiles implements ProfileRepository {
  _FakeProfiles(Iterable<Profile> seed) {
    for (final p in seed) {
      _store[p.profileId.value] = p;
    }
  }

  final Map<String, Profile> _store = {};
  final Map<String, StreamController<Profile?>> _controllers = {};

  StreamController<Profile?> _controllerFor(String id) => _controllers
      .putIfAbsent(id, StreamController<Profile?>.broadcast);

  @override
  Future<List<Profile>> all() async => _store.values.toList();

  @override
  Future<Profile?> byProfileId(ProfileId id) async => _store[id.value];

  @override
  Future<void> upsert(Profile profile) async {
    _store[profile.profileId.value] = profile;
    _controllerFor(profile.profileId.value).add(profile);
  }

  @override
  Stream<Profile?> watchById(ProfileId id) async* {
    yield _store[id.value];
    yield* _controllerFor(id.value).stream;
  }
}

Profile _profile(String id, {Map<String, Object?>? settings}) => Profile(
      profileId: ProfileId(id),
      displayName: 'name-$id',
      role: ProfileRole.self,
      locale: ProfileLocale.fa,
      mushafId: 'm1',
      createdAtInstant: DateTime.utc(2026, 6, 17),
      settings: settings,
    );

void main() {
  useOfflineTestPolicy();

  test('updateDisplayPreferences persists, then the provider republishes',
      () async {
    final fake = _FakeProfiles([_profile('p1')]);
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fake),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(displayPreferencesProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();

    expect(
      container.read(displayPreferencesProvider).appearance,
      MihrabAppearance.light, // the calm default before any write
    );

    await container.read(preferencesWriterProvider).updateDisplayPreferences(
          (p) => p.copyWith(appearance: MihrabAppearance.dark),
        );
    await pumpEventQueue();

    // Persisted into settings_json AND republished through the stream.
    expect(fake._store['p1']!.settings!['appearance'], 'dark');
    expect(
      container.read(displayPreferencesProvider).appearance,
      MihrabAppearance.dark,
    );
  });

  test('no active profile makes a preference write a safe no-op', () async {
    final fake = _FakeProfiles([_profile('p1')]);
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    await container.read(preferencesWriterProvider).updateDisplayPreferences(
          (p) => p.copyWith(appearance: MihrabAppearance.dark),
        );

    expect(fake._store['p1']!.settings, isNull);
  });

  test('switching the active profile re-scopes the preferences read', () async {
    final fake = _FakeProfiles([
      _profile('p1', settings: {'appearance': 'dark'}),
      _profile('p2', settings: {'appearance': 'sepia'}),
    ]);
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fake),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(displayPreferencesProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();

    expect(
      container.read(displayPreferencesProvider).appearance,
      MihrabAppearance.dark,
    );

    container.read(activeProfileProvider.notifier).select(const ProfileId('p2'));
    await pumpEventQueue();

    expect(
      container.read(displayPreferencesProvider).appearance,
      MihrabAppearance.sepia,
    );
  });
}
