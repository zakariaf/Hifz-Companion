// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

import 'glyph_line.dart';

/// One muṣḥaf line as a **plain reference** the feature layer hands to the
/// `quran` renderer — its 1-based [lineNumber], its [lineType] (placement only),
/// and the opaque pre-shaped [textGlyphRef] for the page's KFGQPC font.
///
/// This is the wall-safe bridge across the "two pipelines, one rule" boundary
/// (design-system 04 §1; PRD R1): the feature carries line *refs* (no
/// `ImmutableGlyphPage`, no `glyphCodes` symbol), and the **assembly into the
/// immutable glyph layer happens only inside this package** ([MushafReaderPage]).
/// [textGlyphRef] is NEVER parsed, normalised, split, searched, or logged as
/// Arabic text — it is drawn straight by the page's pre-shaped font.
@immutable
class MushafLineRef {
  /// Creates a line ref.
  const MushafLineRef({
    required this.lineNumber,
    required this.lineType,
    required this.textGlyphRef,
  });

  /// The 1-based line number on the page.
  final int lineNumber;

  /// The line's type (vertical placement only — never the glyphs).
  final LineType lineType;

  /// The opaque pre-shaped glyph-code string for the whole line.
  final String textGlyphRef;

  @override
  bool operator ==(Object other) =>
      other is MushafLineRef &&
      other.lineNumber == lineNumber &&
      other.lineType == lineType &&
      other.textGlyphRef == textGlyphRef;

  @override
  int get hashCode => Object.hash(lineNumber, lineType, textGlyphRef);
}
