// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'reference_enums.dart';

/// One sūrah's immutable metadata (05 §2 `surah`; PRD §10.1).
///
/// Read-only reference structure, never written at runtime. Holds structural
/// facts only — no tafsīr, translation, or commentary (R2).
@immutable
class Surah {
  /// The sūrah number (1–114; schema `CHECK (surah_id BETWEEN 1 AND 114)`).
  final int surahNumber;

  /// The Arabic name of the sūrah.
  final String nameAr;

  /// Whether the sūrah is Meccan or Medinan.
  final Revelation revelation;

  /// The number of āyāt in the sūrah (`> 0`).
  final int ayahCount;

  /// Whether a basmala precedes this sūrah (true for all but al-Tawbah).
  final bool bismillahPre;

  /// Creates a sūrah metadata record.
  const Surah({
    required this.surahNumber,
    required this.nameAr,
    required this.revelation,
    required this.ayahCount,
    required this.bismillahPre,
  });

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  Surah copyWith({
    int? surahNumber,
    String? nameAr,
    Revelation? revelation,
    int? ayahCount,
    bool? bismillahPre,
  }) {
    return Surah(
      surahNumber: surahNumber ?? this.surahNumber,
      nameAr: nameAr ?? this.nameAr,
      revelation: revelation ?? this.revelation,
      ayahCount: ayahCount ?? this.ayahCount,
      bismillahPre: bismillahPre ?? this.bismillahPre,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Surah &&
      other.surahNumber == surahNumber &&
      other.nameAr == nameAr &&
      other.revelation == revelation &&
      other.ayahCount == ayahCount &&
      other.bismillahPre == bismillahPre;

  @override
  int get hashCode =>
      Object.hash(surahNumber, nameAr, revelation, ayahCount, bismillahPre);
}
