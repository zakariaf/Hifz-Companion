// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:app/composition/persistence_provider.dart';
import 'package:data/testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('reading persistenceProvider un-overridden throws a named StateError',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Riverpod 3 wraps an error thrown in a provider body in a
    // ProviderException; the underlying cause is our descriptive StateError.
    expect(
      () => container.read(persistenceProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<StateError>().having(
            (s) => s.message,
            'message',
            contains('without an override'),
          ),
        ),
      ),
    );
  });

  test('an override binds the in-memory fake handle', () async {
    final handle = inMemoryPersistenceHandle();
    final container = ProviderContainer(
      overrides: [persistenceProvider.overrideWithValue(handle)],
    );
    addTearDown(container.dispose);

    expect(container.read(persistenceProvider), same(handle));
    await handle.close();
  });
}
