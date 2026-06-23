// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:quran/quran.dart'
    show OverlayKind, OverlayMarker, PageGeometry, WordRef;

/// One weak sub-page line range on a page (projected from the active profile's
/// `line_block` rows, E03). It carries only line **numbers** — never a card, a
/// D/S/R, a `due_at`, or any Quran text (R1).
@immutable
class WeakLineBlock {
  /// Creates a weak line range `[lineStart, lineEnd]` (1-based, inclusive).
  const WeakLineBlock({required this.lineStart, required this.lineEnd});

  /// The first weak line on the page (1-based).
  final int lineStart;

  /// The last weak line on the page (1-based, `>= lineStart`).
  final int lineEnd;

  @override
  bool operator ==(Object other) =>
      other is WeakLineBlock &&
      other.lineStart == lineStart &&
      other.lineEnd == lineEnd;

  @override
  int get hashCode => Object.hash(lineStart, lineEnd);
}

/// One mutashābihāt anchor on a page: the **distinguishing word(s)** of a
/// confusable member, as coordinate [words] only (from the read-only
/// `distinguishing_word_index_json` dataset, E14) — never the whole āyah, never
/// reconstructed text.
@immutable
class ConfusableAnchor {
  /// Creates an anchor over the distinguishing [words].
  const ConfusableAnchor({required this.words});

  /// The distinguishing word references (the anchor), not the whole āyah.
  final List<WordRef> words;

  @override
  bool operator ==(Object other) =>
      other is ConfusableAnchor && listEquals(other.words, words);

  @override
  int get hashCode => Object.hashAll(words);
}

/// Assembles the coordinate-only overlay markers for the page on screen — a pure
/// function of already-loaded refs + the bundled [geometry] (E13-T05). It paints
/// only the refs it is handed: it measures **no** shaped Arabic, computes **no**
/// rectangle (the painter does that from [geometry]), reconstructs **no** verse
/// text, and decides for *neither* overlay which words are weak or confusable.
/// Total and side-effect-free — no clock, no DB, no randomness.
///
/// - A weak `line_block` `[lineStart, lineEnd]` expands to **every** word on
///   those whole lines — the `WordRef`s the bundled [geometry] already names for
///   that line range (a weak *line*, not a weak word).
/// - A mutashābihāt member contributes its distinguishing word(s) **exactly**.
///
/// An overlay whose toggle is off contributes nothing.
List<OverlayMarker> overlayMarkers({
  required int pageNumber,
  required bool weakLineVisible,
  required bool mutashabihVisible,
  required List<WeakLineBlock> weakLines,
  required List<ConfusableAnchor> confusables,
  required PageGeometry geometry,
}) {
  final markers = <OverlayMarker>[];

  if (weakLineVisible) {
    for (final block in weakLines) {
      final words = _wordsOnLines(geometry, block.lineStart, block.lineEnd);
      if (words.isNotEmpty) {
        markers.add(
          OverlayMarker(
            kind: OverlayKind.weakLine,
            words: words,
          ),
        );
      }
    }
  }

  if (mutashabihVisible) {
    for (final anchor in confusables) {
      if (anchor.words.isNotEmpty) {
        markers.add(
          OverlayMarker(
            kind: OverlayKind.mutashabihAnchor,
            words: anchor.words,
          ),
        );
      }
    }
  }

  return markers;
}

/// Every word the bundled [geometry] names on lines `[lineStart, lineEnd]`,
/// ordered by `(lineNumber, position)`. The geometry is the source of truth for
/// which words exist on a line — the reader never counts words from shaped text.
List<WordRef> _wordsOnLines(PageGeometry geometry, int lineStart, int lineEnd) {
  final words = geometry.wordBoxes.keys
      .where((w) => w.lineNumber >= lineStart && w.lineNumber <= lineEnd)
      .toList()
    ..sort((a, b) {
      final byLine = a.lineNumber.compareTo(b.lineNumber);
      return byLine != 0 ? byLine : a.position.compareTo(b.position);
    });
  return words;
}
