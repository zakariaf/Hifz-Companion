// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import '../test_setup.dart';

/// Records every `drawRRect` and flags any text drawing, so the test can prove
/// the painter draws boxes only — no glyphs, no shaped Arabic. `noSuchMethod`
/// no-ops every other Canvas call.
class _RecordingCanvas implements Canvas {
  final List<RRect> rrects = [];
  bool drewText = false;

  @override
  void drawRRect(RRect rrect, Paint paint) => rrects.add(rrect);

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) => drewText = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  useOfflineTestPolicy();

  const box = Rect.fromLTWH(10, 20, 30, 40);
  // Not const: a WordRef key overrides ==, so the map literal cannot be const
  // (runtime map lookup by value equality is exactly what wordRect relies on).
  final geometry = PageGeometry(
    pageNumber: 1,
    wordBoxes: {const WordRef(lineNumber: 2, position: 3): box},
  );
  const style = OverlayStyle(
    fillColors: {OverlayKind.weakLine: Color(0xFF112233)},
    cornerRadius: 3,
  );

  MushafOverlayPainter painter(List<OverlayMarker> markers) =>
      MushafOverlayPainter(markers: markers, geometry: geometry, style: style);

  test('empty markers draw nothing (page stays the bare glyph layer)', () {
    final canvas = _RecordingCanvas();
    painter(const []).paint(canvas, const Size(100, 100));
    expect(canvas.rrects, isEmpty);
    expect(canvas.drewText, isFalse);
  });

  test('each WordRef is drawn as an RRect at geometry.wordRect — never text',
      () {
    final canvas = _RecordingCanvas();
    painter(const [
      OverlayMarker(
        kind: OverlayKind.weakLine,
        words: [WordRef(lineNumber: 2, position: 3)],
      ),
    ]).paint(canvas, const Size(100, 100));

    expect(canvas.rrects, hasLength(1));
    expect(canvas.rrects.single.outerRect, box);
    expect(
      canvas.drewText,
      isFalse,
      reason: 'a marker is coordinates, not text',
    );
  });

  test('a word with no geometry box paints nothing (no guessed rectangle)', () {
    final canvas = _RecordingCanvas();
    painter(const [
      OverlayMarker(
        kind: OverlayKind.weakLine,
        words: [WordRef(lineNumber: 9, position: 9)], // not in wordBoxes
      ),
    ]).paint(canvas, const Size(100, 100));
    expect(canvas.rrects, isEmpty);
  });

  group('shouldRepaint is value-based', () {
    test('identical markers/geometry/style → no repaint', () {
      expect(painter(const []).shouldRepaint(painter(const [])), isFalse);
    });

    test('a changed marker list → repaint', () {
      final a = painter(const []);
      final b = painter(const [
        OverlayMarker(
          kind: OverlayKind.currentAyah,
          words: [WordRef(lineNumber: 1, position: 1)],
        ),
      ]);
      expect(b.shouldRepaint(a), isTrue);
    });
  });

  group('value equality of the coordinate types', () {
    test('WordRef compares by value (not identity)', () {
      // Not const-foldable → a genuinely distinct runtime instance.
      final one = int.parse('1'), two = int.parse('2');
      final a = WordRef(lineNumber: one, position: two);
      const b = WordRef(lineNumber: 1, position: 2);
      expect(identical(a, b), isFalse);
      expect(a, b);
    });

    test('OverlayMarker compares by value', () {
      final one = int.parse('1'); // runtime → non-const
      final a = OverlayMarker(
        kind: OverlayKind.weakLine,
        words: [WordRef(lineNumber: one, position: one)],
      );
      const b = OverlayMarker(
        kind: OverlayKind.weakLine,
        words: [WordRef(lineNumber: 1, position: 1)],
      );
      expect(a, b);
    });
  });
}
