// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// What a marker means — all calm and **diagnostic**, never decorative or
/// congratulatory (adab §3): a decaying [weakLine], the [currentAyah] focus, a
/// [mutashabihAnchor] distinguishing word, or an [errorPosition] stumble.
enum OverlayKind {
  /// A muṣḥaf line that is decaying / needs attention.
  weakLine,

  /// The ayah currently in focus.
  currentAyah,

  /// A mutashābihāt anchor (distinguishing) word.
  mutashabihAnchor,

  /// A stumble / error position.
  errorPosition,
}

/// A coordinate reference to one word on the page — `(lineNumber, position)`
/// only, **no text**. The painter resolves it to a rectangle from the bundled
/// geometry; nothing reconstructs or stores the word's glyphs (PRD R1).
@immutable
class WordRef {
  /// Creates a word reference.
  const WordRef({required this.lineNumber, required this.position});

  /// The 1-based line on the page.
  final int lineNumber;

  /// The 1-based position within the line.
  final int position;

  @override
  bool operator ==(Object other) =>
      other is WordRef &&
      other.lineNumber == lineNumber &&
      other.position == position;

  @override
  int get hashCode => Object.hash(lineNumber, position);
}

/// One marker to paint over the immutable glyph layer: its [kind] and the
/// [words] it covers — coordinate refs only, never text. The *which-words*
/// decision is E14's; this is a finished marker handed to the painter.
@immutable
class OverlayMarker {
  /// Creates a marker covering [words] with the given [kind].
  const OverlayMarker({required this.kind, required this.words});

  /// What the marker means (placement/colour only).
  final OverlayKind kind;

  /// The word references the marker covers.
  final List<WordRef> words;

  @override
  bool operator ==(Object other) =>
      other is OverlayMarker &&
      other.kind == kind &&
      listEquals(other.words, words);

  @override
  int get hashCode => Object.hash(kind, Object.hashAll(words));
}
