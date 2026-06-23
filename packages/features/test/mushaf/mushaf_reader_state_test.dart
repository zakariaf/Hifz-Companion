// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader-chrome state is an immutable value: a single-field copyWith leaves
// every other field byte-equal and never mutates the prior object. Pure unit.

import 'package:features/features.dart' show MushafReaderState, ReaderTheme;
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('initial is calm: page seeded, no zoom, light, overlays hidden', () {
    const state = MushafReaderState.initial(255);
    expect(state.pageNumber, 255);
    expect(state.zoom, 1.0);
    expect(state.theme, ReaderTheme.light);
    expect(state.isWeakLineOverlayVisible, isFalse);
    expect(state.isMutashabihatOverlayVisible, isFalse);
  });

  test('copyWith changes exactly one field, others preserved', () {
    const before = MushafReaderState.initial(3);
    final after = before.copyWith(zoom: 2.5);
    expect(after.zoom, 2.5);
    // Every other field is unchanged.
    expect(after.pageNumber, before.pageNumber);
    expect(after.theme, before.theme);
    expect(after.isWeakLineOverlayVisible, before.isWeakLineOverlayVisible);
    expect(
      after.isMutashabihatOverlayVisible,
      before.isMutashabihatOverlayVisible,
    );
    // The prior object is untouched (immutability).
    expect(before.zoom, 1.0);
  });

  test('value equality is by field', () {
    const a = MushafReaderState.initial(10);
    const b = MushafReaderState.initial(10);
    final c = a.copyWith(theme: ReaderTheme.dark);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == c, isFalse);
  });
}
