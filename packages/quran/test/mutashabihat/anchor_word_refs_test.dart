// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The mutashābihāt anchor resolver (E14-T09): āyah-relative distinguishing-word
// index → page-relative WordRef, over the SAME bundled geometry the glyphs use —
// never reading or reconstructing verse text. Pure unit, explicit PageGeometry
// literals, no Drift/IO/clock. Authored test-first.

import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import '../test_setup.dart';

// Āyah 2:1 has three words on line 1 (positions 1–3); āyah 2:2 straddles lines
// 1 and 2 (one word each).
const _geometry = PageGeometry(
  pageNumber: 2,
  ayahWords: {
    '2:1': [
      WordRef(lineNumber: 1, position: 1),
      WordRef(lineNumber: 1, position: 2),
      WordRef(lineNumber: 1, position: 3),
    ],
    '2:2': [
      WordRef(lineNumber: 1, position: 4),
      WordRef(lineNumber: 2, position: 1),
    ],
  },
);

void main() {
  useOfflineTestPolicy();

  test('single-word anchor resolves to the exact page WordRef', () {
    final r = anchorWordRefs('2:1', const [1], _geometry);
    expect(r, isA<AnchorResolved>());
    expect((r as AnchorResolved).words, const [
      WordRef(lineNumber: 1, position: 2),
    ]);
  });

  test('multi-word divergence resolves to refs in dataset order', () {
    final r = anchorWordRefs('2:1', const [0, 2], _geometry) as AnchorResolved;
    expect(r.words, const [
      WordRef(lineNumber: 1, position: 1),
      WordRef(lineNumber: 1, position: 3),
    ]);
  });

  test('an āyah straddling two lines yields refs on different lineNumbers', () {
    final r = anchorWordRefs('2:2', const [0, 1], _geometry) as AnchorResolved;
    expect(r.words.map((w) => w.lineNumber), [1, 2]);
  });

  test('the marker is exactly one grouped mutashabihAnchor with all words', () {
    final marker = anchorMarker('2:1', const [0, 2], _geometry);
    expect(marker, isNotNull);
    expect(marker!.kind, OverlayKind.mutashabihAnchor);
    expect(marker.words, hasLength(2));
  });

  test('fail loud: an absent āyah is AnchorUnavailable, not a guessed box', () {
    final r = anchorWordRefs('9:9', const [0], _geometry);
    expect(r, isA<AnchorUnavailable>());
    expect((r as AnchorUnavailable).reason, contains('9:9'));
    expect(anchorMarker('9:9', const [0], _geometry), isNull);
  });

  test('fail loud: an out-of-range index is AnchorUnavailable', () {
    final r = anchorWordRefs('2:1', const [7], _geometry);
    expect(r, isA<AnchorUnavailable>());
    expect((r as AnchorUnavailable).reason, contains('7'));
  });

  test('no per-word geometry (bundle-first) resolves to no anchor, never a box',
      () {
    const empty = PageGeometry(pageNumber: 2);
    expect(anchorWordRefs('2:1', const [0], empty), isA<AnchorUnavailable>());
    expect(anchorMarker('2:1', const [0], empty), isNull);
  });
}
