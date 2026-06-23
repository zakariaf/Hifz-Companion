// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The recite View is dumb: it contains no scheduling math and never caps the
// grade. It forwards a Good + missed-word tap UNCAPPED to the pipeline, which
// caps it to Hard downstream (E12-T06) — proven through the recorder.

import 'dart:io';

import 'package:engine/engine.dart' show ReviewGrade;
import 'package:features/features.dart' show reciteControllerProvider;
import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();

  test('no engine schedule / cap symbol in the recite source', () {
    final dir = Directory('lib/src/recite');
    final banned = <String>[
      'onReview',
      'buildToday',
      'loadBalance',
      'trustClamp',
      'DateTime.now',
    ];
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final code = file
          .readAsLinesSync()
          .map((l) => l.contains('//') ? l.substring(0, l.indexOf('//')) : l)
          .join('\n');
      for (final symbol in banned) {
        expect(
          code.contains(symbol),
          isFalse,
          reason: '${file.path} references $symbol',
        );
      }
    }
  });

  test('a Good + missed-word tap is forwarded uncapped, capped downstream',
      () async {
    final reviews = RecordingReviews();
    final container =
        reciteContainer(cards: StubCards(reciteCard()), reviews: reviews);
    addTearDown(container.dispose);
    final controller = container.read(reciteControllerProvider(42).notifier);

    controller.revealNextLine();
    controller.toggleStumbleLine(3); // raises missedOrAlteredWord
    await controller.submitGrade(ReviewGrade.good); // the widget does NOT cap

    // The pipeline applied the sacred-text cap — the persisted grade is Hard.
    expect(reviews.outcomes.single.logRow.grade, ReviewGrade.hard);
    expect(reviews.outcomes.single.logRow.errorLineIndices, [3]);
  });
}
