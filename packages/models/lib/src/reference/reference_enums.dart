// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The closed value sets of the read-only Quran reference structure (05 §2).
///
/// Each member carries the exact lowercase token its `CHECK (... IN (...))`
/// constraint stores, so the reference DAO (E03-T06) maps a row to an enum from
/// one source of truth. These describe the fixed muṣḥaf structure only — no
/// tafsīr, translation, or sect/madhhab marker (R2).
library;

/// Where a sūrah was revealed (05 §2 `surah.revelation`).
enum Revelation {
  /// Revealed at Mecca.
  meccan('meccan'),

  /// Revealed at Medina.
  medinan('medinan');

  const Revelation(this.wireValue);

  /// The exact token stored in the `surah.revelation` `CHECK` set (05 §2).
  final String wireValue;
}

/// What a muṣḥaf line holds (05 §2 `line.line_type`).
enum LineType {
  /// One or more āyāt (or part of one).
  ayah('ayah'),

  /// A sūrah header band.
  surahHeader('surah_header'),

  /// The basmala line.
  basmala('basmala');

  const LineType(this.wireValue);

  /// The exact token stored in the `line.line_type` `CHECK` set (05 §2).
  final String wireValue;
}

/// The kind of similarity binding a mutashābihāt group (05 §2
/// `mutashabih_group.type`).
///
/// Objective, near-identical wording only — scholar-reviewed and scoped to
/// avoid any interpretive claim (R4).
enum MutashabihType {
  /// Word-for-word identical passages.
  identical('identical'),

  /// Near-identical passages differing in a small number of words.
  nearIdentical('near_identical'),

  /// Structurally parallel passages.
  structural('structural');

  const MutashabihType(this.wireValue);

  /// The exact token stored in the `mutashabih_group.type` `CHECK` set (05 §2).
  final String wireValue;
}
