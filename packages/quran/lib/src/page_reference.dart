// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// The sūra + ayah-range a muṣḥaf page covers, derived **only** from the bundled
/// QUL structure dataset — never from glyph codes. The objective reference the
/// screen reader is given for a page.
@immutable
class SurahAyahRange {
  /// Creates a range over [surah] from [firstAyah] to [lastAyah] (1-based,
  /// inclusive).
  const SurahAyahRange({
    required this.surah,
    required this.firstAyah,
    required this.lastAyah,
  });

  /// The 1-based sūra number this range is in.
  final int surah;

  /// The 1-based first ayah of the range on the page.
  final int firstAyah;

  /// The 1-based last ayah of the range on the page.
  final int lastAyah;

  @override
  bool operator ==(Object other) =>
      other is SurahAyahRange &&
      other.surah == surah &&
      other.firstAyah == firstAyah &&
      other.lastAyah == lastAyah;

  @override
  int get hashCode => Object.hash(surah, firstAyah, lastAyah);
}

/// What the screen reader receives for a muṣḥaf page: its 1-based [pageNumber],
/// its sūra/ayah [range], and its [juz] — the page **reference**, never the QPC
/// glyph codepoints (design-system 09 §7).
///
/// QPC PUA glyph codes are opaque addresses, not readable text; the reader is
/// never fed them. Every field here is an integer-or-range derived from the
/// bundled QUL structure dataset; this type carries **no** glyph code, opaque
/// address, or reconstructed āyah string by construction. The feature layer
/// composes the spoken string from this reference through the E08-T02
/// `Semantics` label + the ARB set (so it speaks fa/ckb/ar with locale
/// numerals); this type only guarantees the reference *data* flows.
@immutable
class PageReference {
  /// Creates the reference for [pageNumber] covering [range] in [juz].
  const PageReference({
    required this.pageNumber,
    required this.range,
    required this.juz,
  });

  /// The 1-based muṣḥaf page number.
  final int pageNumber;

  /// The sūra/ayah range the page covers.
  final SurahAyahRange range;

  /// The 1-based juz the page is in.
  final int juz;

  @override
  bool operator ==(Object other) =>
      other is PageReference &&
      other.pageNumber == pageNumber &&
      other.range == range &&
      other.juz == juz;

  @override
  int get hashCode => Object.hash(pageNumber, range, juz);
}
