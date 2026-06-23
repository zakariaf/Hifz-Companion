// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader view-model is display-only: it maps the active edition into one
// immutable UI state, reaches no DAO/engine, and writes nothing. Provider test
// over the injected edition seam (never the notifier).

import 'package:composition/composition.dart' show initialActiveProfileProvider;
import 'package:features/features.dart'
    show activeEditionProvider, mushafReaderViewModelProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show MushafEdition, ProfileId;

import '../test_setup.dart';

MushafEdition fakeEdition({String id = 'test_edition'}) => MushafEdition(
      mushafId: id,
      riwayah: 'Test Riwāyah',
      displayName: 'Test Riwāyah — Test muṣḥaf',
      pageCount: 604,
      lineCount: 15,
      textSha256: '',
      layoutSha256: '',
      fontSha256: const <int, String>{},
    );

void main() {
  useOfflineTestPolicy();

  const profile = ProfileId('p1');

  test('build maps the active edition into immutable UI state', () async {
    final edition = fakeEdition();
    final container = ProviderContainer(
      overrides: [activeEditionProvider.overrideWithValue(edition)],
    );
    addTearDown(container.dispose);

    final state =
        await container.read(mushafReaderViewModelProvider(profile).future);
    expect(state.edition.displayName, 'Test Riwāyah — Test muṣḥaf');
    expect(state.edition.riwayah, 'Test Riwāyah');
    // The reader opens on the safe default (first) page absent a deep link.
    expect(state.initialPage, 1);
  });

  test('display-only: it resolves without any persistence (no DAO touched)',
      () async {
    // persistenceProvider is intentionally NOT overridden — it throws if read.
    // The view-model resolving anyway proves it reaches no DB/DAO.
    final container = ProviderContainer(
      overrides: [activeEditionProvider.overrideWithValue(fakeEdition())],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(mushafReaderViewModelProvider(profile).future),
      completes,
    );
  });

  test('family keying yields independent instances per profile', () async {
    final container = ProviderContainer(
      overrides: [
        activeEditionProvider.overrideWithValue(fakeEdition()),
        initialActiveProfileProvider.overrideWithValue(profile),
      ],
    );
    addTearDown(container.dispose);

    final a = container.read(mushafReaderViewModelProvider(profile).notifier);
    final b = container
        .read(mushafReaderViewModelProvider(const ProfileId('p2')).notifier);
    expect(identical(a, b), isFalse);
    expect(a.profile, profile);
    expect(b.profile, const ProfileId('p2'));
  });
}
