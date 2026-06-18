// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'reference_data_builder.dart';

/// One sūra's fixed metadata from Tanzil's `quran-data.xml`.
class SurahMeta {
  /// Creates sūra metadata.
  const SurahMeta({
    required this.number,
    required this.nameAr,
    required this.revelation,
    required this.ayahCount,
    required this.globalStart,
  });

  /// The 1-based sūra number.
  final int number;

  /// The Arabic name.
  final String nameAr;

  /// `'meccan'` or `'medinan'` (the E03 CHECK form).
  final String revelation;

  /// The number of āyāt.
  final int ayahCount;

  /// The 0-based global index of this sūra's first ayah (Tanzil `start`).
  final int globalStart;
}

/// A juz/rubʿ division boundary: the division [number] begins at the ayah whose
/// 0-based [globalIndex] this is.
class DivisionBoundary {
  /// Creates a division boundary.
  const DivisionBoundary(this.number, this.globalIndex);

  /// The 1-based division number (juz 1–30, or rubʿ 1–240).
  final int number;

  /// The 0-based global ayah index at which the division begins.
  final int globalIndex;
}

/// The fixed Quran metadata parsed from Tanzil's `quran-data.xml`: sūra info,
/// juz boundaries, rubʿ (ḥizb-quarter) boundaries, and the sajda ayah keys.
class QuranMetadata {
  /// Creates parsed metadata.
  QuranMetadata({
    required this.surahs,
    required List<DivisionBoundary> juzBoundaries,
    required List<DivisionBoundary> rubBoundaries,
    required this.sajdaAyahKeys,
  })  : _juz = juzBoundaries,
        _rub = rubBoundaries,
        _surahByNumber = {for (final s in surahs) s.number: s};

  /// Every sūra's metadata, in order.
  final List<SurahMeta> surahs;

  /// The sajda ayah keys (`'surah:ayah'`).
  final Set<String> sajdaAyahKeys;

  final List<DivisionBoundary> _juz;
  final List<DivisionBoundary> _rub;
  final Map<int, SurahMeta> _surahByNumber;

  /// The 0-based global ayah index of [surah]:[ayah] (Tanzil `start` + ayah-1).
  int globalIndexOf(int surah, int ayah) =>
      _surahByNumber[surah]!.globalStart + (ayah - 1);

  /// The juz (1–30) containing the ayah at [globalIndex].
  int juzOf(int globalIndex) => _divisionOf(_juz, globalIndex);

  /// The rubʿ / ḥizb-quarter (1–240) containing the ayah at [globalIndex].
  int rubOf(int globalIndex) => _divisionOf(_rub, globalIndex);

  /// The ḥizb (1–60) — four rubʿ per ḥizb.
  int hizbOf(int globalIndex) => ((rubOf(globalIndex) - 1) ~/ 4) + 1;

  static int _divisionOf(List<DivisionBoundary> boundaries, int globalIndex) {
    var result = boundaries.first.number;
    for (final b in boundaries) {
      if (b.globalIndex <= globalIndex) {
        result = b.number;
      } else {
        break;
      }
    }
    return result;
  }
}

final _suraRe = RegExp(
  r'<sura\s+index="(\d+)"\s+ayas="(\d+)"\s+start="(\d+)"\s+name="([^"]*)"'
  r'[^>]*?type="(Meccan|Medinan)"',
);
final _juzRe = RegExp(r'<juz\s+index="(\d+)"\s+sura="(\d+)"\s+aya="(\d+)"');
final _quarterRe =
    RegExp(r'<quarter\s+index="(\d+)"\s+sura="(\d+)"\s+aya="(\d+)"');
final _sajdaRe = RegExp(r'<sajda\s+index="\d+"\s+sura="(\d+)"\s+aya="(\d+)"');

/// Parses Tanzil's `quran-data.xml` into [QuranMetadata]. Throws [FormatException]
/// if the canonical counts (114 sūras, 30 juz, 240 rubʿ, 15 sajdas) are not met —
/// a malformed metadata file must never silently yield a wrong muṣḥaf index.
QuranMetadata parseQuranMetadata(String xml) {
  final surahs = [
    for (final m in _suraRe.allMatches(xml))
      SurahMeta(
        number: int.parse(m.group(1)!),
        ayahCount: int.parse(m.group(2)!),
        globalStart: int.parse(m.group(3)!),
        nameAr: m.group(4)!,
        revelation: m.group(5)! == 'Meccan' ? 'meccan' : 'medinan',
      ),
  ];
  final byNumber = {for (final s in surahs) s.number: s};

  int globalOf(int sura, int aya) => byNumber[sura]!.globalStart + (aya - 1);

  final juz = [
    for (final m in _juzRe.allMatches(xml))
      DivisionBoundary(
        int.parse(m.group(1)!),
        globalOf(int.parse(m.group(2)!), int.parse(m.group(3)!)),
      ),
  ];
  final rub = [
    for (final m in _quarterRe.allMatches(xml))
      DivisionBoundary(
        int.parse(m.group(1)!),
        globalOf(int.parse(m.group(2)!), int.parse(m.group(3)!)),
      ),
  ];
  final sajdas = {
    for (final m in _sajdaRe.allMatches(xml)) '${m.group(1)}:${m.group(2)}',
  };

  final counts = {
    'sūras': (surahs.length, 114),
    'juz': (juz.length, 30),
    'rubʿ': (rub.length, 240),
    'sajdas': (sajdas.length, 15),
  };
  for (final entry in counts.entries) {
    final (actual, want) = entry.value;
    if (actual != want) {
      throw FormatException(
        'quran-data.xml: expected $want ${entry.key}, got $actual',
      );
    }
  }

  return QuranMetadata(
    surahs: surahs,
    juzBoundaries: juz,
    rubBoundaries: rub,
    sajdaAyahKeys: sajdas,
  );
}

/// A built `surah` reference row.
class SurahRowData {
  /// Creates a sūra row.
  const SurahRowData({
    required this.surahId,
    required this.nameAr,
    required this.revelation,
    required this.ayahCount,
    required this.bismillahPre,
  });

  /// The 1-based sūra number.
  final int surahId;

  /// The Arabic name.
  final String nameAr;

  /// `'meccan'` / `'medinan'`.
  final String revelation;

  /// The number of āyāt (> 0).
  final int ayahCount;

  /// Whether a basmala precedes the sūra (every sūra except At-Tawba (9); for
  /// Al-Fātiḥa (1) the basmala is ayah 1, so it is not a separate pre-header).
  final bool bismillahPre;
}

/// A built `page` reference row.
class PageRowData {
  /// Creates a page row.
  const PageRowData({
    required this.pageId,
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

  /// The 1-based page (1–604).
  final int pageId;

  /// The juz (1–30) the page begins in.
  final int juz;

  /// The ḥizb (1–60).
  final int hizb;

  /// The rubʿ (1–240).
  final int rub;

  /// The sūra the page begins in.
  final int surahStart;

  /// The first ayah on the page.
  final int ayahStart;

  /// The sūra the page ends in.
  final int surahEnd;

  /// The last ayah on the page.
  final int ayahEnd;

  /// The number of lines on the page.
  final int lineCount;

  /// The page's dedicated KFGQPC family (`'QPC_P###'`).
  final String qpcFontName;
}

/// The dedicated KFGQPC glyph-font family for [page] — one definition shared
/// with the renderer (`QPC_P001` … `QPC_P604`).
String qpcFontFamilyName(int page) => 'QPC_P${page.toString().padLeft(3, '0')}';

/// Builds the `surah` rows from [meta]; `bismillahPre` is the standard rule
/// (every sūra except 9; Al-Fātiḥa's basmala is its first ayah).
List<SurahRowData> buildSurahRows(QuranMetadata meta) => [
      for (final s in meta.surahs)
        SurahRowData(
          surahId: s.number,
          nameAr: s.nameAr,
          revelation: s.revelation,
          ayahCount: s.ayahCount,
          bismillahPre: s.number != 1 && s.number != 9,
        ),
    ];

/// Builds the `page` rows from the QUL [layout], the QUL [words] (for the
/// page's ayah span), and the Tanzil [meta] (juz/ḥizb/rubʿ). Words carry no
/// page, so a word's page comes from the layout line that contains its id.
List<PageRowData> buildPageRows({
  required List<LayoutLine> layout,
  required List<GlyphWord> words,
  required QuranMetadata meta,
}) {
  final wordById = {for (final w in words) w.id: w};
  // page -> (lineCount, min word id, max word id)
  final lineCounts = <int, int>{};
  final minWord = <int, int>{};
  final maxWord = <int, int>{};
  for (final line in layout) {
    lineCounts.update(line.pageNumber, (v) => v + 1, ifAbsent: () => 1);
    if (line.firstWordId != null && line.lastWordId != null) {
      minWord.update(
        line.pageNumber,
        (v) => v < line.firstWordId! ? v : line.firstWordId!,
        ifAbsent: () => line.firstWordId!,
      );
      maxWord.update(
        line.pageNumber,
        (v) => v > line.lastWordId! ? v : line.lastWordId!,
        ifAbsent: () => line.lastWordId!,
      );
    }
  }

  final rows = <PageRowData>[];
  for (final page in lineCounts.keys.toList()..sort()) {
    final firstWord = wordById[minWord[page]];
    final lastWord = wordById[maxWord[page]];
    if (firstWord == null || lastWord == null) {
      throw ArgumentError('Page $page has no ayah words in the word DB.');
    }
    final gi = meta.globalIndexOf(firstWord.surah, firstWord.ayah);
    rows.add(
      PageRowData(
        pageId: page,
        juz: meta.juzOf(gi),
        hizb: meta.hizbOf(gi),
        rub: meta.rubOf(gi),
        surahStart: firstWord.surah,
        ayahStart: firstWord.ayah,
        surahEnd: lastWord.surah,
        ayahEnd: lastWord.ayah,
        lineCount: lineCounts[page]!,
        qpcFontName: qpcFontFamilyName(page),
      ),
    );
  }
  return rows;
}
