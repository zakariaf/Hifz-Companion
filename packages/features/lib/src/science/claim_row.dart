// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../design_system/certainty/evidence_grade.dart';

/// The ten thematic groups of `docs/science/CLAIMS.md` (A–J), in register order.
///
/// The group is the screen's calm card grouping (PRD §11.1.1; the science doc
/// §3). The human label is localized at the View layer — this enum carries only
/// the stable [letter] the register and the no-orphan gate key on.
enum ClaimGroup {
  /// A — Memory & forgetting.
  a,

  /// B — Spacing & scheduling.
  b,

  /// C — Spaced-repetition engine (the math, stated honestly).
  c,

  /// D — Retrieval & self-testing.
  d,

  /// E — Interference & mutashābihāt.
  e,

  /// F — Serial recall & the page unit.
  f,

  /// G — Overlearning & lifelong retention.
  g,

  /// H — Traditional methodology (sect-neutral; no rulings).
  h,

  /// I — Motivation & adab (non-coercive by design).
  i,

  /// J — Cross-cutting honesty & neutrality.
  j;

  /// The upper-case group letter (`"A"`–`"J"`) as it appears in `CLAIMS.md`.
  String get letter => name.toUpperCase();

  /// Parses a group letter (`"A"`, `" a "`) to its [ClaimGroup].
  ///
  /// An unknown group is a **release-blocking register-integrity defect**, never
  /// a silent default — it throws [ClaimRegisterFormatException].
  static ClaimGroup parse(String letter) {
    final normalized = letter.trim().toLowerCase();
    for (final group in values) {
      if (group.name == normalized) return group;
    }
    throw ClaimRegisterFormatException('unknown claim group "$letter"');
  }
}

/// One named, dated source behind a registered claim, rendered as **readable
/// on-device text** so the citation reads identically in airplane mode (science
/// doc §2, §4).
///
/// [label] is the attribution exactly as shown (author/year/venue, or a hadith
/// collection + number) — a Latin/transliterated run the View bidi-isolates
/// (FSI/PDI) and whose digits the View remaps to locale numerals. [url] is an
/// **optional convenience** only: the citation is fully trustworthy without it,
/// and offline it simply does nothing (science doc §2; `ui-science-source-row`).
@immutable
class ClaimSource {
  /// Creates a source citation.
  const ClaimSource({required this.label, this.url});

  /// The full reference as on-device text (e.g. `"Cepeda et al., 2006 —
  /// Psychological Bulletin"`, or `"Ṣaḥīḥ al-Bukhārī 5032"`).
  final String label;

  /// An optional external URL the View may open in the system browser; `null`
  /// when there is no link. Never fetched in-app (offline, no-AI — PRD C1/C2).
  final String? url;

  @override
  bool operator ==(Object other) =>
      other is ClaimSource && other.label == label && other.url == url;

  @override
  int get hashCode => Object.hash(label, url);
}

/// One row of the bundled, read-only `CLAIMS.md` register — the **only author**
/// of a user-facing factual claim (science doc §1).
///
/// The screen renders this; it invents no fact, re-grades nothing, and re-derives
/// no engine rule. The plain headline and any honest caveat are localized at the
/// View layer keyed by [id]; the structural facts (grades, sources, group) live
/// here so the no-orphan / grade-coverage gate can check them.
@immutable
class ClaimRow {
  /// Creates a register row.
  const ClaimRow({
    required this.id,
    required this.group,
    required this.grades,
    required this.sources,
    this.needsScholarlyReview = false,
  });

  /// The stable register id, e.g. `"C-001"`.
  final String id;

  /// The thematic group (A–J) this claim sits under.
  final ClaimGroup group;

  /// The claim's evidence grade(s), strongest-first, mirroring the register's
  /// `Grade` column (a claim may rest on more than one kind of evidence). Always
  /// non-empty: a row with no known grade is a release-blocking defect.
  final List<EvidenceGrade> grades;

  /// The named, dated source(s) behind the claim. Always non-empty: a claim with
  /// no source must not ship (the absolute register rule).
  final List<ClaimSource> sources;

  /// Whether this `[TRAD]`/methodology row awaits named scholarly sign-off; the
  /// View shows a plain "needs scholarly review" note where `true` (science doc
  /// §8; PRD §21). Methodology only — it never becomes a fiqh ruling.
  final bool needsScholarlyReview;

  /// The strongest grade (the first), used for the row's primary confidence
  /// phrasing; the full [grades] list is still surfaced in the evidence layer.
  EvidenceGrade get primaryGrade => grades.first;

  @override
  bool operator ==(Object other) =>
      other is ClaimRow &&
      other.id == id &&
      other.group == group &&
      listEquals(other.grades, grades) &&
      listEquals(other.sources, sources) &&
      other.needsScholarlyReview == needsScholarlyReview;

  @override
  int get hashCode => Object.hash(
        id,
        group,
        Object.hashAll(grades),
        Object.hashAll(sources),
        needsScholarlyReview,
      );
}

/// Thrown when the bundled register is structurally malformed (a missing field,
/// an unknown group, an empty grade/source list) — a release-blocking data
/// defect surfaced loudly, never rendered as a fallback (science doc §1; the
/// register-drift risk in the epic).
class ClaimRegisterFormatException implements Exception {
  /// Creates the exception with a human-readable [message].
  const ClaimRegisterFormatException(this.message);

  /// What was malformed.
  final String message;

  @override
  String toString() => 'ClaimRegisterFormatException: $message';
}
