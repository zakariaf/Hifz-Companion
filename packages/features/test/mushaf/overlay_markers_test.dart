// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The overlay-marker builder is sacred-text-adjacent: a wrong WordRef highlights
// the wrong word on the muṣḥaf. Pure unit over an explicit fixture geometry —
// no clock, no DB. Asserts the exact (kind, line, position) refs.

import 'dart:ui' show Rect;

import 'package:features/features.dart'
    show ConfusableAnchor, WeakLineBlock, overlayMarkers;
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart'
    show OverlayKind, OverlayMarker, PageGeometry, WordRef;

import '../test_setup.dart';

// A 3-line fixture page: line 1 has 2 words, line 2 has 3, line 3 has 1.
final _geometry = PageGeometry(
  pageNumber: 5,
  wordBoxes: {
    const WordRef(lineNumber: 1, position: 1): Rect.zero,
    const WordRef(lineNumber: 1, position: 2): Rect.zero,
    const WordRef(lineNumber: 2, position: 1): Rect.zero,
    const WordRef(lineNumber: 2, position: 2): Rect.zero,
    const WordRef(lineNumber: 2, position: 3): Rect.zero,
    const WordRef(lineNumber: 3, position: 1): Rect.zero,
  },
);

List<OverlayMarker> buildWith({
  bool weak = true,
  bool mutashabih = true,
  List<WeakLineBlock> weakLines = const [],
  List<ConfusableAnchor> confusables = const [],
}) =>
    overlayMarkers(
      pageNumber: 5,
      weakLineVisible: weak,
      mutashabihVisible: mutashabih,
      weakLines: weakLines,
      confusables: confusables,
      geometry: _geometry,
    );

void main() {
  useOfflineTestPolicy();

  group('toggle gating', () {
    test('an off toggle emits no markers of that kind', () {
      final weakOff = buildWith(
        weak: false,
        weakLines: const [WeakLineBlock(lineStart: 1, lineEnd: 1)],
        confusables: [
          const ConfusableAnchor(
            words: [WordRef(lineNumber: 2, position: 2)],
          ),
        ],
      );
      expect(weakOff.where((m) => m.kind == OverlayKind.weakLine), isEmpty);
      expect(
        weakOff.where((m) => m.kind == OverlayKind.mutashabihAnchor),
        hasLength(1),
      );
    });

    test('both off ⇒ empty list', () {
      expect(
        buildWith(
          weak: false,
          mutashabih: false,
          weakLines: const [WeakLineBlock(lineStart: 1, lineEnd: 3)],
          confusables: [
            const ConfusableAnchor(
              words: [WordRef(lineNumber: 1, position: 1)],
            ),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('weak-line expansion (whole line range, geometry-driven)', () {
    test('one block expands to every word on its lines', () {
      final markers =
          buildWith(weakLines: const [WeakLineBlock(lineStart: 2, lineEnd: 2)]);
      final weak = markers.where((m) => m.kind == OverlayKind.weakLine).single;
      expect(weak.words, const [
        WordRef(lineNumber: 2, position: 1),
        WordRef(lineNumber: 2, position: 2),
        WordRef(lineNumber: 2, position: 3),
      ]);
    });

    test('a multi-line block spans every word across the range, in order', () {
      final markers =
          buildWith(weakLines: const [WeakLineBlock(lineStart: 1, lineEnd: 2)]);
      final weak = markers.where((m) => m.kind == OverlayKind.weakLine).single;
      expect(weak.words, const [
        WordRef(lineNumber: 1, position: 1),
        WordRef(lineNumber: 1, position: 2),
        WordRef(lineNumber: 2, position: 1),
        WordRef(lineNumber: 2, position: 2),
        WordRef(lineNumber: 2, position: 3),
      ]);
    });

    test('two blocks ⇒ two weak-line markers', () {
      final markers = buildWith(
        weakLines: const [
          WeakLineBlock(lineStart: 1, lineEnd: 1),
          WeakLineBlock(lineStart: 3, lineEnd: 3),
        ],
      );
      expect(
        markers.where((m) => m.kind == OverlayKind.weakLine),
        hasLength(2),
      );
    });

    test('a block on no geometry lines ⇒ no marker', () {
      final markers = buildWith(
        weakLines: const [WeakLineBlock(lineStart: 9, lineEnd: 10)],
      );
      expect(markers.where((m) => m.kind == OverlayKind.weakLine), isEmpty);
    });
  });

  group('mutashābihāt anchor (distinguishing word(s) only)', () {
    test('an anchor marks exactly its words, never the whole āyah', () {
      final markers = buildWith(
        confusables: [
          const ConfusableAnchor(
            words: [
              WordRef(lineNumber: 2, position: 2),
              WordRef(lineNumber: 2, position: 3),
            ],
          ),
        ],
      );
      final anchor =
          markers.where((m) => m.kind == OverlayKind.mutashabihAnchor).single;
      expect(anchor.words, const [
        WordRef(lineNumber: 2, position: 2),
        WordRef(lineNumber: 2, position: 3),
      ]);
    });

    test('two members ⇒ two anchor markers', () {
      final markers = buildWith(
        confusables: [
          const ConfusableAnchor(
            words: [WordRef(lineNumber: 1, position: 1)],
          ),
          const ConfusableAnchor(
            words: [WordRef(lineNumber: 3, position: 1)],
          ),
        ],
      );
      expect(
        markers.where((m) => m.kind == OverlayKind.mutashabihAnchor),
        hasLength(2),
      );
    });
  });

  test('every emitted marker carries coordinate refs only (no text field)', () {
    final markers = buildWith(
      weakLines: const [WeakLineBlock(lineStart: 1, lineEnd: 1)],
      confusables: [
        const ConfusableAnchor(words: [WordRef(lineNumber: 2, position: 1)]),
      ],
    );
    for (final marker in markers) {
      for (final word in marker.words) {
        expect(word.lineNumber, greaterThan(0));
        expect(word.position, greaterThan(0));
      }
    }
  });
}
