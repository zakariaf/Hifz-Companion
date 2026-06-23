// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart' show GradeSource, ReviewGrade;

import '../review_input.dart';

/// The recite-flow normalization layer (PRD §8; domain-grading-pipeline): it
/// turns the user's taps into **exactly one** [ReviewInput] and suggests a grade
/// from the stumble count. Pure: no I/O, no clock, no stability math, no `due_at`
/// — the engine's `onReview` owns all scheduling. The sacred-text guard (R1) is
/// applied **here, before the input is emitted**, so it holds for every caller.
abstract final class RecitationGrading {
  /// Builds the single normalized signal the engine consumes.
  ///
  /// The sacred-text guard: a dropped/added/swapped word ([missedOrAlteredWord])
  /// can never be graded `Good`/`Easy` — the grade is capped at [ReviewGrade.hard]
  /// before the input is emitted (R1; engineering 06 §4). `errorLines` is carried
  /// at full strength regardless of [source] (only the engine confidence-scales
  /// the stability move) and is wrapped unmodifiable. The per-source confidence
  /// weight (`kSelfConfidence` / teacher `1.0`) is the engine's, applied inside
  /// `onReview` — never inlined here.
  static ReviewInput normalize({
    required ReviewGrade grade,
    required GradeSource source,
    List<int> errorLines = const <int>[],
    bool missedOrAlteredWord = false,
  }) {
    // R1 sacred-text guard: cap a missed/altered-word grade at Hard before emit.
    final capped = missedOrAlteredWord && grade.index > ReviewGrade.hard.index
        ? ReviewGrade.hard
        : grade;
    return ReviewInput(
      grade: capped,
      source: source,
      errorLines: List<int>.unmodifiable(errorLines),
      missedOrAlteredWord: missedOrAlteredWord,
    );
  }

  /// Maps a stumble-line count to a *suggested*, user-confirmable grade
  /// (PRD §8.1). Monotone — more stumbles never suggests a better grade — and
  /// never auto-`Easy` (effortless fluency is the user's own deliberate verdict):
  /// a clean attempt suggests `Good`; up to ~a fifth of the page's lines stumbled
  /// suggests `Hard`; more suggests `Again`. The cap in [normalize] still applies
  /// after the user confirms, so a low count plus a missed word can never emit
  /// `Good`/`Easy`.
  static ReviewGrade suggestGradeFromStumbles(
    int stumbleLineCount, {
    required int pageLineCount,
  }) {
    final n = stumbleLineCount < 0 ? 0 : stumbleLineCount;
    if (n == 0) return ReviewGrade.good;
    final hardCeiling = (pageLineCount * 0.2).ceil().clamp(1, pageLineCount);
    return n <= hardCeiling ? ReviewGrade.hard : ReviewGrade.again;
  }
}
