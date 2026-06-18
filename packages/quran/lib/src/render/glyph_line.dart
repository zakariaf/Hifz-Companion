// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// What a muṣḥaf line is (from the QUL layout dataset, never inferred): an
/// `ayah` line of verse words, a `surahName` header, a `basmala`, or a
/// `centered` short line. Drives only vertical placement — never the glyphs.
enum LineType {
  /// A line of verse (ayah) words.
  ayah,

  /// A sūra-name header line.
  surahName,

  /// A basmala line.
  basmala,

  /// A short centred line.
  centered,
}

/// One word of the bundled QUL layout: its 1-based [pageNumber]/[lineNumber],
/// its [position] within the line (1-based), the opaque pre-shaped [glyphCode]
/// string for the page's KFGQPC font, and its [lineType]. A plain value type so
/// the `quran` renderer needs no local package dependency.
@immutable
class LayoutWord {
  /// Creates a layout word.
  const LayoutWord({
    required this.pageNumber,
    required this.lineNumber,
    required this.position,
    required this.glyphCode,
    required this.lineType,
  });

  /// The 1-based muṣḥaf page this word is on.
  final int pageNumber;

  /// The 1-based line on the page (`1..lineCount`).
  final int lineNumber;

  /// The 1-based position within the line (left-to-right in dataset order).
  final int position;

  /// The opaque pre-shaped glyph-code string for this word — NEVER parsed,
  /// normalised, split, searched, or logged as Arabic text.
  final String glyphCode;

  /// The type of the line this word belongs to.
  final LineType lineType;
}

/// One assembled muṣḥaf line, ready to draw: its [pageNumber]/[lineNumber], its
/// [type], and the concatenated opaque [glyphCodes] of every word on the line
/// (in position order). Built only by `assemblePage` — never by verse.
@immutable
class GlyphLine {
  /// Creates a glyph line.
  const GlyphLine({
    required this.pageNumber,
    required this.lineNumber,
    required this.type,
    required this.glyphCodes,
  });

  /// The 1-based muṣḥaf page this line is on.
  final int pageNumber;

  /// The 1-based line number on the page.
  final int lineNumber;

  /// The line's type (placement only).
  final LineType type;

  /// The concatenated opaque glyph codes for the whole line — drawn straight,
  /// never shaped, split, or searched.
  final String glyphCodes;
}

/// One immutable, already-verified muṣḥaf page: its [pageNumber] and its [lines]
/// in dataset (`lineNumber` ascending) order. The renderer draws these as-is and
/// never reorders, mirrors, or re-cuts them.
@immutable
class ImmutableGlyphPage {
  /// Creates an immutable glyph page.
  const ImmutableGlyphPage({required this.pageNumber, required this.lines});

  /// The 1-based muṣḥaf page number.
  final int pageNumber;

  /// The page's lines in ascending `lineNumber` order.
  final List<GlyphLine> lines;
}

/// The dedicated KFGQPC glyph-font family for [pageNumber] — `'QPC_P001'` …
/// `'QPC_P604'`. The font selection **is** the shaping (engineering 08 §2): one
/// page, one family, one glyph table. The single definition of this convention.
String qpcFontFamily(int pageNumber) =>
    'QPC_P${pageNumber.toString().padLeft(3, '0')}';
