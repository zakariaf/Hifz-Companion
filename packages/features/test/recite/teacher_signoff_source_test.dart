// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The "Teacher present" toggle changes ONLY the verdict's source (self → teacher)
// for the same grade + the same stumble lines — it never changes the chosen
// grade or the revealed/stumble state, and the commit rides the existing single
// write path (no new write method).

import 'package:engine/engine.dart' show GradeSource, ReviewGrade;
import 'package:features/features.dart' show reciteControllerProvider;
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();

  test('toggling teacher-present changes only the source, not the verdict',
      () async {
    final reviews = RecordingReviews();
    final container =
        reciteContainer(cards: StubCards(reciteCard()), reviews: reviews);
    addTearDown(container.dispose);
    final controller = container.read(reciteControllerProvider(42).notifier);

    controller.revealNextLine();
    final before = container.read(reciteControllerProvider(42));

    controller.setTeacherPresent(present: true);
    final after = container.read(reciteControllerProvider(42));

    // Only the source flag changed — the revealed/stumble state is identical.
    expect(after.teacherPresent, isTrue);
    expect(after.revealedLineCount, before.revealedLineCount);
    expect(after.stumbleLines, before.stumbleLines);

    await controller.submitGrade(ReviewGrade.good);

    // Exactly one commit through the existing write path, source = teacher, and
    // the chosen verdict is unchanged (no missed word ⇒ no cap).
    expect(reviews.outcomes.length, 1);
    final log = reviews.outcomes.single.logRow;
    expect(log.source, GradeSource.teacher);
    expect(log.grade, ReviewGrade.good);
  });

  test('with the toggle off the source is self', () async {
    final reviews = RecordingReviews();
    final container =
        reciteContainer(cards: StubCards(reciteCard()), reviews: reviews);
    addTearDown(container.dispose);
    final controller = container.read(reciteControllerProvider(42).notifier);

    controller.revealNextLine();
    await controller.submitGrade(ReviewGrade.good);
    expect(reviews.outcomes.single.logRow.source, GradeSource.self);
  });
}
