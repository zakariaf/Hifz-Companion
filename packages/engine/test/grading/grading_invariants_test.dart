// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The sacred-text-cap covenant (R1) as a glados property over generated
// (grade, source, missedOrAlteredWord) inputs: a dropped/added/swapped word is
// NEVER graded Good/Easy by the normalizer, before the ReviewInput is emitted.
// (INV-3 "Again ⇒ S'≤S ∧ track'≤track" and INV-5 "teacher overrides self" are
// pinned over onReview histories in invariants_test.dart — not re-derived here.)

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

typedef _Case = ({ReviewGrade grade, GradeSource source, bool missed});

extension _AnyNormalize on Any {
  Generator<_Case> get normalizeCase => combine3(
        any.intInRange(0, ReviewGrade.values.length),
        any.intInRange(0, GradeSource.values.length),
        any.intInRange(0, 2),
        (gi, si, m) => (
          grade: ReviewGrade.values[gi],
          source: GradeSource.values[si],
          missed: m == 1,
        ),
      );
}

void main() {
  Glados<_Case>(any.normalizeCase).test(
    'a dropped/altered word is never graded Good/Easy (R1)',
    (c) {
      final input = RecitationGrading.normalize(
        grade: c.grade,
        source: c.source,
        missedOrAlteredWord: c.missed,
      );
      if (c.missed) {
        expect(input.grade.index, lessThanOrEqualTo(ReviewGrade.hard.index));
      } else {
        expect(input.grade, c.grade); // no cap when no word was missed
      }
      // The flag is always carried through to the engine untouched.
      expect(input.missedOrAlteredWord, c.missed);
    },
  );
}
