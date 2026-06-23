// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// A navigation unit the muṣḥaf reader can jump by (PRD §6.1, §12.3). The fixed
/// hierarchy is read-only reference data — the reader never recomputes which
/// page a unit starts on (engineering 08 §3).
enum JumpUnit {
  /// One of the 30 ajzāʾ (1–30).
  juz,

  /// One of the 60 aḥzāb (1–60).
  hizb,

  /// One of the 114 suwar (1–114) — resolves to the page its first āyah falls on.
  surah,

  /// One of the muṣḥaf pages (1–`pageCount`) — resolves to itself.
  page,
}

/// A jump request: a [unit] and a 1-based [index] within that unit's range. The
/// page it resolves to is **read** from the bundled `page`/`surah` reference
/// tables (`ReferenceRepository.firstPageOf`), never computed — a wrong start
/// page would send the reader to the wrong āyah on a sacred boundary.
@immutable
class JumpTarget {
  /// Creates a jump request for [unit] at the 1-based [index].
  const JumpTarget({required this.unit, required this.index});

  /// The unit being jumped by.
  final JumpUnit unit;

  /// The 1-based index within the unit's range.
  final int index;

  /// The inclusive upper bound of [index] for [unit] in the standard 604-page
  /// Madani muṣḥaf (PRD §6.1): juz 30, ḥizb 60, sūrah 114, page 604.
  static int maxIndexFor(JumpUnit unit) => switch (unit) {
        JumpUnit.juz => 30,
        JumpUnit.hizb => 60,
        JumpUnit.surah => 114,
        JumpUnit.page => 604,
      };

  /// Whether [index] is within `1..maxIndexFor(unit)`.
  bool get isInRange => index >= 1 && index <= maxIndexFor(unit);

  @override
  bool operator ==(Object other) =>
      other is JumpTarget && other.unit == unit && other.index == index;

  @override
  int get hashCode => Object.hash(unit, index);
}
