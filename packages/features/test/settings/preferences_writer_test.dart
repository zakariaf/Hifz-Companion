// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T02: the display-preference write path. PreferencesWriter persists a
// change to the active profile's settings_json BEFORE the reactive
// displayPreferencesProvider republishes; the change round-trips through the
// decoded DisplayPreferences; a null active profile is a safe no-op; and
// switching the active profile re-scopes the read to the new student.
// ProfileRepository is faked with a controllable watchById stream (no DB);
// offline guard installed — the write path opens no socket.

import 'package:composition/composition.dart'
    show
        activeProfileProvider,
        initialActiveProfileProvider,
        profileRepositoryProvider;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        displayPreferencesProvider,
        preferencesWriterProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';
import 'fake_profiles.dart';

void main() {
  useOfflineTestPolicy();

  test('updateDisplayPreferences persists, then the provider republishes',
      () async {
    final fake = FakeProfileRepository([fakeProfile('p1')]);
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
    expect(fake.store['p1']!.settings!['appearance'], 'dark');
    expect(
      container.read(displayPreferencesProvider).appearance,
      MihrabAppearance.dark,
    );
  });

  test('no active profile makes a preference write a safe no-op', () async {
    final fake = FakeProfileRepository([fakeProfile('p1')]);
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    await container.read(preferencesWriterProvider).updateDisplayPreferences(
          (p) => p.copyWith(appearance: MihrabAppearance.dark),
        );

    expect(fake.store['p1']!.settings, isNull);
  });

  test('switching the active profile re-scopes the preferences read', () async {
    final fake = FakeProfileRepository([
      fakeProfile('p1', settings: {'appearance': 'dark'}),
      fakeProfile('p2', settings: {'appearance': 'sepia'}),
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
