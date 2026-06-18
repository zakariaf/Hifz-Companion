// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Graduation/lapse/manualLock properties over generated inputs (06 §5). Pure
// `package:glados`, no clock, no fixed lucky seed — rely on shrinking. These
// seed the full §7.12 register that E04-T11 generalizes.

import 'package:engine/engine.dart';
import 'package:glados/glados.dart';

import 'support/fixtures.dart';

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());

  // INV-3 seed — a lapse demotes. PRD §7.7; science 03 §4: Again sets S back and
  // re-derives a weaker phase; SR may only make a page MORE frequent. (The
  // "revised more often" guarantee is delivered by the collapsed S — the
  // interval — not by targetR, which is stakes-tiered and rises for a far page
  // that stays far.)
  Glados2<int, int>(any.intInRange(1, 200), any.intInRange(0, 365))
      .test('Again ⇒ S\' ≤ S ∧ track\' ≤ track ∧ weakFlag set', (sInt, gap) {
    final before = testCard(
      stabilityDays: sInt.toDouble(), // track defaults to far
      lastReviewedDay: day(0),
    );
    final after = engine.onReview(
      before,
      ReviewInput(grade: ReviewGrade.again, source: GradeSource.teacher),
      day(gap),
      weakLineCount: 0,
    );
    expect(after.stabilityDays, lessThanOrEqualTo(before.stabilityDays));
    final afterRank = trackStrength(after.track);
    final beforeRank = trackStrength(before.track);
    expect(afterRank, lessThanOrEqualTo(beforeRank));
    expect(after.isWeak, isTrue);
  });

  // manualLock freezes graduation — the teacher's authority is never overridden
  // by the math, for any grade.
  Glados<int>(any.intInRange(0, ReviewGrade.values.length))
      .test('a pinned card keeps its track for any grade', (gi) {
    // track defaults to far; S=3 would demote a non-pinned card.
    final pinned = testCard(stabilityDays: 3, hasManualLock: true);
    final after = updateGraduation(
      pinned,
      ReviewGrade.values[gi],
      GradeSource.teacher,
      inRecentWindow: false,
    );
    expect(after.track, ReviewTrack.far);
  });

  // Determinism — graduation is a pure function of its inputs.
  test('updateGraduation is pure: identical inputs → identical Card', () {
    final c = testCard(track: ReviewTrack.newPage, stabilityDays: 20);
    Card graduate() => updateGraduation(
          c,
          ReviewGrade.easy,
          GradeSource.teacher,
          inRecentWindow: false,
        );
    expect(graduate(), graduate());
  });
}
