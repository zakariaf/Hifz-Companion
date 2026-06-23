// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The recite-flow normalizer: the sacred-text cap (a missed/altered word is
// never Good/Easy), the pinned stumble→suggested-grade thresholds, source
// tagging without inlined confidence weights, and full-strength errorLines.
// Pure package:test — no clock, no I/O.

import 'package:engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group('sacred-text cap (R1)', () {
    test('a missed/altered word is never Good or Easy', () {
      for (final entry in <ReviewGrade, ReviewGrade>{
        ReviewGrade.good: ReviewGrade.hard,
        ReviewGrade.easy: ReviewGrade.hard,
        ReviewGrade.hard: ReviewGrade.hard,
        ReviewGrade.again: ReviewGrade.again,
      }.entries) {
        final input = RecitationGrading.normalize(
          grade: entry.key,
          source: GradeSource.self,
          missedOrAlteredWord: true,
        );
        expect(input.grade, entry.value, reason: '${entry.key} should cap');
      }
    });

    test('without a missed word every grade passes through unchanged', () {
      for (final g in ReviewGrade.values) {
        final input = RecitationGrading.normalize(
          grade: g,
          source: GradeSource.self,
        );
        expect(input.grade, g);
      }
    });
  });

  group('suggestGradeFromStumbles', () {
    test('pinned thresholds for a 15-line page', () {
      ReviewGrade s(int n) =>
          RecitationGrading.suggestGradeFromStumbles(n, pageLineCount: 15);
      expect(s(0), ReviewGrade.good);
      expect(s(1), ReviewGrade.hard);
      expect(s(3), ReviewGrade.hard); // ceil(15*0.2) = 3
      expect(s(4), ReviewGrade.again);
      expect(s(15), ReviewGrade.again);
    });

    test('monotone — more stumbles never suggests a better grade', () {
      // ReviewGrade index: again 0 < hard 1 < good 2 < easy 3, so "worse" is a
      // LOWER index. More stumbles must never raise the index (never improve).
      var prev = ReviewGrade.easy.index + 1;
      for (var n = 0; n <= 15; n++) {
        final g = RecitationGrading.suggestGradeFromStumbles(
          n,
          pageLineCount: 15,
        );
        expect(
          g.index,
          lessThanOrEqualTo(prev),
          reason: 'grade improved at n=$n',
        );
        prev = g.index;
      }
    });

    test('never auto-suggests Easy', () {
      for (var n = 0; n <= 30; n++) {
        expect(
          RecitationGrading.suggestGradeFromStumbles(n, pageLineCount: 15),
          isNot(ReviewGrade.easy),
        );
      }
    });
  });

  group('source + errorLines', () {
    test('source round-trips untouched', () {
      for (final src in GradeSource.values) {
        final input = RecitationGrading.normalize(
          grade: ReviewGrade.good,
          source: src,
        );
        expect(input.source, src);
      }
    });

    test('errorLines are full-strength and unmodifiable', () {
      final input = RecitationGrading.normalize(
        grade: ReviewGrade.hard,
        source: GradeSource.self,
        errorLines: const [3, 7],
      );
      expect(input.errorLines, [3, 7]);
      expect(() => input.errorLines.add(9), throwsUnsupportedError);
    });
  });
}
