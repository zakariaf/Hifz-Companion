// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'reference_enums.dart';

/// One muṣḥaf line's immutable descriptor (05 §2 `line`; PRD §10.1).
///
/// Read-only reference geometry. [textGlyphRef] is an **opaque** address into
/// the page's glyph layer — pre-shaped glyph codes that are *never* parsed,
/// normalized, searched, lower-cased, or logged as real Arabic text (R1,
/// domain-mushaf-text-integrity). Equality is byte-for-byte over that opaque
/// reference, never a text comparison.
@immutable
class Line {
  /// The line's stable id.
  final int lineId;

  /// The page this line is on (FK into `page`).
  final int pageNumber;

  /// The line number on the page (1–15; schema `CHECK (line_no BETWEEN 1 AND
  /// 15)`).
  final int lineNumber;

  /// Whether the line holds āyāt, a sūrah header, or the basmala.
  final LineType lineType;

  /// The raw `ayah_refs_json` payload — which āyāt occupy this line.
  ///
  /// Small structural refs only, carried opaquely; the decode-validation shape
  /// is the consumer's concern (E05/E14), never reconstructed Quran text.
  final String ayahRefsJson;

  /// The opaque glyph-code reference for this line — **never** parsed as text
  /// (R1). The `quran` package renders it via the page's pre-shaped font.
  final String textGlyphRef;

  /// Creates a line descriptor.
  const Line({
    required this.lineId,
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.ayahRefsJson,
    required this.textGlyphRef,
  });

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  Line copyWith({
    int? lineId,
    int? pageNumber,
    int? lineNumber,
    LineType? lineType,
    String? ayahRefsJson,
    String? textGlyphRef,
  }) {
    return Line(
      lineId: lineId ?? this.lineId,
      pageNumber: pageNumber ?? this.pageNumber,
      lineNumber: lineNumber ?? this.lineNumber,
      lineType: lineType ?? this.lineType,
      ayahRefsJson: ayahRefsJson ?? this.ayahRefsJson,
      textGlyphRef: textGlyphRef ?? this.textGlyphRef,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Line &&
      other.lineId == lineId &&
      other.pageNumber == pageNumber &&
      other.lineNumber == lineNumber &&
      other.lineType == lineType &&
      other.ayahRefsJson == ayahRefsJson &&
      other.textGlyphRef == textGlyphRef;

  @override
  int get hashCode => Object.hash(
        lineId,
        pageNumber,
        lineNumber,
        lineType,
        ayahRefsJson,
        textGlyphRef,
      );
}
