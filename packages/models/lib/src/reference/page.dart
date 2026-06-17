// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// One muṣḥaf page's immutable structural descriptor (05 §2 `page`; PRD §10.1).
///
/// Read-only reference geometry from the fixed QUL layout dataset — never
/// recomputed and never written at runtime (R1). It names which juz/ḥizb/rub
/// the page falls in, the surah/āyah it spans, and the dedicated glyph font
/// the page is rendered with; it holds **no** Quran text.
@immutable
class Page {
  /// The page number (1–604; schema `CHECK (page_id BETWEEN 1 AND 604)`).
  final int pageNumber;

  /// The juz this page falls in (1–30).
  final int juz;

  /// The ḥizb this page falls in (1–60).
  final int hizb;

  /// The rub' this page falls in (1–240).
  final int rub;

  /// The sūrah the page starts in (FK into `surah`).
  final int surahStart;

  /// The first āyah on the page.
  final int ayahStart;

  /// The sūrah the page ends in (FK into `surah`).
  final int surahEnd;

  /// The last āyah on the page.
  final int ayahEnd;

  /// The number of lines on this page.
  final int lineCount;

  /// This page's dedicated KFGQPC glyph-font family name (§08).
  final String qpcFontName;

  /// Creates a page descriptor.
  const Page({
    required this.pageNumber,
    required this.juz,
    required this.hizb,
    required this.rub,
    required this.surahStart,
    required this.ayahStart,
    required this.surahEnd,
    required this.ayahEnd,
    required this.lineCount,
    required this.qpcFontName,
  });

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  Page copyWith({
    int? pageNumber,
    int? juz,
    int? hizb,
    int? rub,
    int? surahStart,
    int? ayahStart,
    int? surahEnd,
    int? ayahEnd,
    int? lineCount,
    String? qpcFontName,
  }) {
    return Page(
      pageNumber: pageNumber ?? this.pageNumber,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      rub: rub ?? this.rub,
      surahStart: surahStart ?? this.surahStart,
      ayahStart: ayahStart ?? this.ayahStart,
      surahEnd: surahEnd ?? this.surahEnd,
      ayahEnd: ayahEnd ?? this.ayahEnd,
      lineCount: lineCount ?? this.lineCount,
      qpcFontName: qpcFontName ?? this.qpcFontName,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Page &&
      other.pageNumber == pageNumber &&
      other.juz == juz &&
      other.hizb == hizb &&
      other.rub == rub &&
      other.surahStart == surahStart &&
      other.ayahStart == ayahStart &&
      other.surahEnd == surahEnd &&
      other.ayahEnd == ayahEnd &&
      other.lineCount == lineCount &&
      other.qpcFontName == qpcFontName;

  @override
  int get hashCode => Object.hash(
        pageNumber,
        juz,
        hizb,
        rub,
        surahStart,
        ayahStart,
        surahEnd,
        ayahEnd,
        lineCount,
        qpcFontName,
      );
}
