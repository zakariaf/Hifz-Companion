// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The app-ready gate: coreVerified reads the verified-text stamp through the
// persistence boundary (no socket), and appReady = a profile exists AND the
// core is verified (PRD R1). The composition is tested by faking its two inputs;
// the stamp read itself is covered at the data layer.

import 'package:app/composition/active_profile_provider.dart';
import 'package:app/composition/app_ready_provider.dart';
import 'package:app/composition/persistence_provider.dart';
import 'package:data/testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('coreVerifiedProvider is false when the stamp is absent (fresh install)',
      () async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    final container = ProviderContainer(
      overrides: [persistenceProvider.overrideWithValue(handle)],
    );
    addTearDown(container.dispose);

    expect(await container.read(coreVerifiedProvider.future), isFalse);
  });

  group('appReadyProvider = a profile exists AND the core is verified', () {
    Future<ProviderContainer> build({
      required bool verified,
      ProfileId? profile,
    }) async {
      final overrides = [
        coreVerifiedProvider.overrideWith((ref) async => verified),
        if (profile != null)
          initialActiveProfileProvider.overrideWithValue(profile),
      ];
      final container = ProviderContainer(overrides: overrides);
      addTearDown(container.dispose);
      // Resolve the FutureProvider so appReady reads its settled value.
      await container.read(coreVerifiedProvider.future);
      return container;
    }

    test('false when no profile, even if the core is verified', () async {
      final container = await build(verified: true);
      expect(container.read(appReadyProvider), isFalse);
    });

    test('false when a profile exists but the core is not verified', () async {
      final container =
          await build(verified: false, profile: const ProfileId('p1'));
      expect(container.read(appReadyProvider), isFalse);
    });

    test('true only when a profile exists and the core is verified', () async {
      final container =
          await build(verified: true, profile: const ProfileId('p1'));
      expect(container.read(appReadyProvider), isTrue);
    });
  });
}
