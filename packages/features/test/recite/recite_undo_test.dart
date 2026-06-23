// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// (written first) submitGrade commits one review through the single write path;
// undoLastGrade appends a SECOND corrective outcome restoring the prior card —
// the prior row is never mutated (append-only).

import 'package:engine/engine.dart' show ReviewGrade;
import 'package:features/features.dart' show reciteControllerProvider;
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();

  test('submit commits once; undo appends a corrective restoring the prior card',
      () async {
    final cards = StubCards(reciteCard());
    final reviews = RecordingReviews();
    final container = reciteContainer(cards: cards, reviews: reviews);
    addTearDown(container.dispose);
    final controller = container.read(reciteControllerProvider(42).notifier);

    controller.revealNextLine();
    final handle = await controller.submitGrade(ReviewGrade.good);
    expect(handle, isNotNull);
    expect(reviews.outcomes.length, 1);

    await controller.undoLastGrade();

    // Append-only: a SECOND outcome was committed (never an in-place edit), and
    // it restores the prior card state.
    expect(reviews.outcomes.length, 2);
    expect(reviews.outcomes.last.cardUpdate.pageId, 42);
    expect(
      reviews.outcomes.last.cardUpdate.stabilityDays,
      reciteCard().stabilityDays,
    );
    // The corrective row records the undone grade as an audit entry.
    expect(reviews.outcomes.last.logRow.grade, ReviewGrade.good);
  });
}
