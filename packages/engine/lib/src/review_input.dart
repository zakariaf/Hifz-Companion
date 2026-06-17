// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:models/models.dart';

/// The normalized grading signal one review hands the engine (06 §2; PRD §8).
///
/// It is the *input* to `onReview` — a pure, human-produced signal, never a
/// result: there is no `dueAt`, no stability, no clock here. The recite flow
/// (E12) builds it from a reveal-on-tap self-rating or an on-device teacher
/// (talaqqī) sign-off and normalizes both to this one shape; the engine
/// consumes it.
///
/// This is an engine-only input type — it is **not** persisted, so it lives in
/// `engine`, not `models` (unlike [ReviewGrade]/[GradeSource], which the
/// append-only `review_log` stores). The output the single write path persists
/// is the separate `ReviewOutcome` DTO in `models`.
@immutable
class ReviewInput {
  /// The four-level grade the human assigned (Again/Hard/Good/Easy).
  final ReviewGrade grade;

  /// The 1-based muṣḥaf-line indices the reciter stumbled on; may be empty.
  ///
  /// Stored as an unmodifiable copy, so a caller mutating the list it passed in
  /// can never reach into a constructed [ReviewInput]. Recorded and acted on at
  /// **full strength regardless of [source]** — even a self-reported stumble is
  /// real localization data; only the magnitude of the stability move is
  /// confidence-scaled (06 §4).
  final List<int> errorLines;

  /// Who produced the grade — the ḥāfiẓ (self) or a present teacher (talaqqī).
  ///
  /// Carries the per-source confidence split the engine applies (self scales
  /// the stability gain down; teacher is the *sanad*-respecting ground truth
  /// that supersedes). The weight itself is the named `kSelfConfidence`
  /// constant (E04-T10), never inlined here.
  final GradeSource source;

  /// The sacred-text guard flag: a word was dropped, added, or swapped (R1).
  ///
  /// This type only *carries* the flag; `onReview` (E04-T04) reads it and caps
  /// the grade at [ReviewGrade.hard] **before any arithmetic** — a dropped or
  /// altered sacred word is never "Good" (PRD R1, §7.7).
  final bool missedOrAlteredWord;

  /// Creates a grading signal. [errorLines] defaults to empty and is copied
  /// into an unmodifiable list so the value type is honestly immutable;
  /// [missedOrAlteredWord] defaults to `false`.
  ReviewInput({
    required this.grade,
    required this.source,
    List<int> errorLines = const [],
    this.missedOrAlteredWord = false,
  }) : errorLines = List<int>.unmodifiable(errorLines);

  @override
  bool operator ==(Object other) =>
      other is ReviewInput &&
      other.grade == grade &&
      other.source == source &&
      other.missedOrAlteredWord == missedOrAlteredWord &&
      _intListEquals(other.errorLines, errorLines);

  @override
  int get hashCode => Object.hash(
        grade,
        source,
        missedOrAlteredWord,
        Object.hashAll(errorLines),
      );
}

/// Value equality for the stumble-line-index lists (no `package:collection`
/// dependency at this layer; mirrors the `review_log` helper).
bool _intListEquals(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
