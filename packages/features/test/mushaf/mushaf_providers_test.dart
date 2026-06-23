// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader-chrome notifier is display-only: every command is a pure single-
// field rebuild that touches no engine/repository/DAO/clock. The container
// overrides NO persistence/engine provider — those throw if read — so a clean
// run proves the store reaches none of them. Run under throwing HttpOverrides.

import 'package:features/features.dart'
    show
        MushafReaderState,
        ReaderTheme,
        kReaderMaxZoom,
        kReaderMinZoom,
        mushafReaderStateProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  ProviderContainer reader() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Keep the autoDispose provider alive for the test's duration.
    container.listen(mushafReaderStateProvider(255), (_, __) {});
    return container;
  }

  MushafReaderState read(ProviderContainer c) =>
      c.read(mushafReaderStateProvider(255));

  test('build seeds the initial state from the entry page', () {
    final c = reader();
    final s = read(c);
    expect(s.pageNumber, 255);
    expect(s.zoom, 1.0);
    expect(s.theme, ReaderTheme.light);
    expect(s.isWeakLineOverlayVisible, isFalse);
    expect(s.isMutashabihatOverlayVisible, isFalse);
  });

  test('setPage changes only the page', () {
    final c = reader();
    final before = read(c);
    c.read(mushafReaderStateProvider(255).notifier).setPage(120);
    final after = read(c);
    expect(after.pageNumber, 120);
    expect(after.zoom, before.zoom);
    expect(after.theme, before.theme);
    expect(after.isWeakLineOverlayVisible, before.isWeakLineOverlayVisible);
  });

  test('setZoom changes only the zoom; band boundaries are accepted', () {
    final c = reader();
    final n = c.read(mushafReaderStateProvider(255).notifier);
    n.setZoom(2.0);
    expect(read(c).zoom, 2.0);
    expect(read(c).pageNumber, 255);
    n.setZoom(kReaderMinZoom);
    expect(read(c).zoom, kReaderMinZoom);
    n.setZoom(kReaderMaxZoom);
    expect(read(c).zoom, kReaderMaxZoom);
  });

  test('setTheme changes only the theme', () {
    final c = reader();
    c.read(mushafReaderStateProvider(255).notifier).setTheme(ReaderTheme.dark);
    expect(read(c).theme, ReaderTheme.dark);
    expect(read(c).pageNumber, 255);
    expect(read(c).zoom, 1.0);
  });

  test('the two overlay toggles flip independently and round-trip', () {
    final c = reader();
    final n = c.read(mushafReaderStateProvider(255).notifier);

    n.toggleWeakLineOverlay();
    expect(read(c).isWeakLineOverlayVisible, isTrue);
    // Flipping one never moves the other.
    expect(read(c).isMutashabihatOverlayVisible, isFalse);

    n.toggleMutashabihatOverlay();
    expect(read(c).isMutashabihatOverlayVisible, isTrue);
    expect(read(c).isWeakLineOverlayVisible, isTrue);

    // Two flips return to the original visibility.
    n.toggleWeakLineOverlay();
    expect(read(c).isWeakLineOverlayVisible, isFalse);
  });

  test('display-only: every command runs with no persistence/engine touched',
      () {
    // No persistenceProvider/engineProvider override — they throw if read. A
    // clean run of every command proves the store reaches no DB/engine/DAO.
    final c = reader();
    final n = c.read(mushafReaderStateProvider(255).notifier);
    n
      ..setPage(7)
      ..setZoom(1.5)
      ..setTheme(ReaderTheme.sepia)
      ..toggleWeakLineOverlay()
      ..toggleMutashabihatOverlay();
    final s = read(c);
    expect(s.pageNumber, 7);
    expect(s.zoom, 1.5);
    expect(s.theme, ReaderTheme.sepia);
    expect(s.isWeakLineOverlayVisible, isTrue);
    expect(s.isMutashabihatOverlayVisible, isTrue);
  });

  test('autoDispose: state resets to seed once the last listener is gone',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sub = container.listen(mushafReaderStateProvider(50), (_, __) {});
    container.read(mushafReaderStateProvider(50).notifier).setPage(300);
    expect(container.read(mushafReaderStateProvider(50)).pageNumber, 300);

    sub.close();
    await Future<void>.delayed(Duration.zero);

    // A fresh listen rebuilds from the entry-page seed (the mutated state did
    // not leak across reader sessions).
    container.listen(mushafReaderStateProvider(50), (_, __) {});
    expect(container.read(mushafReaderStateProvider(50)).pageNumber, 50);
  });
}
