// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The seven evidence grades from `CLAIMS.md`, parsed once from the register
/// (never the raw `[..]` tag at the widget layer).
///
/// Ordered best→weakest among the empirical grades, with [trad] **last** —
/// named scholarship paired with a source, NOT ranked above the empirical
/// grades and issuing no fiqh ruling (CLAIMS scope clause; C-046). The grade
/// describes the strength of the evidence behind a claim, kept strictly separate
/// from any certainty about the user's own Quran (C-047).
enum EvidenceGrade {
  /// `[MA]` — a meta-analysis (among the best-established findings).
  ma,

  /// `[RCT]` — a randomized controlled trial (a single controlled study).
  rct,

  /// `[EXP]` — a controlled experiment (a single controlled study).
  exp,

  /// `[CS]` — a classic foundational study.
  cs,

  /// `[OBS]` — an observational / field study.
  obs,

  /// `[TEXT]` — an expert review / algorithm documentation.
  text,

  /// `[TRAD]` — traditional scholarship, named below; methodology, not a ruling.
  trad;

  /// Parses a register tag (`"[MA]"`, `"MA"`, `" ma "`) to its grade.
  ///
  /// Strips brackets/whitespace and lowercases, then matches by [name]. An
  /// unknown grade is a **release-blocking register-integrity defect**, not a UI
  /// concern — it throws [EvidenceGradeFormatException], never a silent default.
  static EvidenceGrade parse(String tag) {
    final normalized = tag.replaceAll(RegExp(r'[\[\]\s]'), '').toLowerCase();
    for (final grade in values) {
      if (grade.name == normalized) return grade;
    }
    throw EvidenceGradeFormatException(tag);
  }
}

/// Thrown when a CLAIMS tag does not name a known [EvidenceGrade] — a
/// release-blocking data defect surfaced loudly, never rendered as a default.
class EvidenceGradeFormatException implements Exception {
  /// Creates the exception for the offending [tag].
  const EvidenceGradeFormatException(this.tag);

  /// The unrecognised tag.
  final String tag;

  @override
  String toString() =>
      'EvidenceGradeFormatException: unknown evidence grade "$tag" '
      '(a CLAIMS register-integrity defect).';
}
