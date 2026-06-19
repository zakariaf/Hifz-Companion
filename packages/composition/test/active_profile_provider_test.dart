// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The active-profile gate: null on a fresh install (→ onboarding), initialised
// from the injected persisted id, and mutated only by select/clear.

import 'package:composition/composition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('defaults to null on a fresh install (no initial override)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(activeProfileProvider), isNull);
  });

  test('initialises from the injected persisted profile id', () {
    final container = ProviderContainer(
      overrides: [
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(activeProfileProvider), const ProfileId('p1'));
  });

  test('select() makes a profile active; clear() resets it', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(activeProfileProvider.notifier)
        .select(const ProfileId('p2'));
    expect(container.read(activeProfileProvider), const ProfileId('p2'));

    container.read(activeProfileProvider.notifier).clear();
    expect(container.read(activeProfileProvider), isNull);
  });
}
