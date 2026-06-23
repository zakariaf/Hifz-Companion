// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';

import 'render/overlay_marker.dart';

/// Muṣḥaf page geometry — the per-word rectangles a page's overlays are drawn
/// from, in the layer's coordinate space. A plain value type derived from the
/// **fixed QUL layout dataset** (never recomputed, never measured from shaped
/// text), received by the renderer so `quran` needs no local package dependency.
@immutable
class PageGeometry {
  /// Creates page geometry for the 1-based [pageNumber] with its [wordBoxes]
  /// and, for the mutashābihāt anchor resolver (E14-T09), the per-āyah ordered
  /// [ayahWords] (ayah id → its words' refs in āyah order) — both derived from
  /// the **fixed QUL layout dataset**, never recomputed.
  const PageGeometry({
    required this.pageNumber,
    this.wordBoxes = const {},
    this.ayahWords = const {},
  });

  /// The 1-based muṣḥaf page number this geometry describes.
  final int pageNumber;

  /// Word reference → its rectangle in the layer's coordinate space.
  final Map<WordRef, Rect> wordBoxes;

  /// Āyah id (`'s:a'`) → its words' [WordRef]s on this page, in āyah word order.
  ///
  /// The anchor resolver indexes into this by an āyah-relative word index to find
  /// the page-relative `(line, position)` of a distinguishing word. A single
  /// āyah may straddle two lines, so its refs can span more than one `lineNumber`.
  final Map<String, List<WordRef>> ayahWords;

  /// The rectangle for the word at [lineNumber]/[position], or [Rect.zero] if
  /// the geometry has no box for it (an absent box paints nothing — never a
  /// guessed or text-measured rectangle).
  Rect wordRect(int lineNumber, int position) =>
      wordBoxes[WordRef(lineNumber: lineNumber, position: position)] ??
      Rect.zero;

  /// The ordered [WordRef]s of āyah [ayahId] on this page, or null if the āyah is
  /// not present in this geometry (the resolver fails loudly — never a guess).
  List<WordRef>? wordsOfAyah(String ayahId) => ayahWords[ayahId];

  @override
  bool operator ==(Object other) =>
      other is PageGeometry &&
      other.pageNumber == pageNumber &&
      _boxesEqual(other.wordBoxes, wordBoxes);

  @override
  int get hashCode => Object.hash(
        pageNumber,
        Object.hashAllUnordered(
          wordBoxes.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  static bool _boxesEqual(Map<WordRef, Rect> a, Map<WordRef, Rect> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
