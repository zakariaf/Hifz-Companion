// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// R6 / INV-5 (the override, at the engine seam this epic feeds): a teacher Again
// on a page just self-graded Good is authoritative — it demotes the page despite
// the prior self-Good. The full assembled write-path override is exercised by the
// T09 journey; the universal property lives in engine/invariants_test.

import 'package:engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  final engine = SchedulingEngine(EngineConfig.defaults());

  test('a teacher Again overrides a prior self Good — the page is demoted', () {
    final card0 = dueFar(10);
    final afterSelfGood = engine.onReview(
      card0,
      ReviewInput(grade: ReviewGrade.good, source: GradeSource.self),
      kToday,
      weakLineCount: 0,
    );
    final afterTeacherAgain = engine.onReview(
      afterSelfGood,
      ReviewInput(grade: ReviewGrade.again, source: GradeSource.teacher),
      kToday,
      weakLineCount: 0,
    );

    // The teacher Again is authoritative: it shrinks stability (a lapse) and
    // never leaves the page at the prior self-Good strength.
    expect(
      afterTeacherAgain.stabilityDays,
      lessThan(afterSelfGood.stabilityDays),
    );
    expect(afterTeacherAgain.lapses, greaterThan(afterSelfGood.lapses));
  });
}
