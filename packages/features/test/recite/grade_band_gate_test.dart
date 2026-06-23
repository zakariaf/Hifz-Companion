// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// (written first) the grade band is disabled until ≥1 reveal — it reads as
// WAITING (a calm hint), and a tap before any reveal emits no grade. After one
// reveal it becomes tappable.

import 'package:engine/engine.dart' show ReviewGrade;
import 'package:features/features.dart'
    show MihrabAppearance, ReciteGradeBand, mihrabThemeFor, reciteControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();

  testWidgets('disabled until reveal — waiting hint, no grade emitted', (t) async {
    final graded = <ReviewGrade>[];
    final container = reciteContainer(
      cards: StubCards(reciteCard()),
      reviews: RecordingReviews(),
    );
    addTearDown(container.dispose);

    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: Scaffold(
            body: ReciteGradeBand(pageId: 42, onGrade: graded.add),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    // Hidden: the band reads as waiting, and the buttons are non-tappable.
    expect(find.text(l10n.gradeBandWaitingHint), findsOneWidget);
    for (final b in t.widgetList<FilledButton>(find.byType(FilledButton))) {
      expect(b.onPressed, isNull);
    }
    await t.tap(find.byType(FilledButton).first, warnIfMissed: false);
    await t.pumpAndSettle();
    expect(graded, isEmpty);

    // After one reveal the band is enabled and a tap emits a grade.
    container.read(reciteControllerProvider(42).notifier).revealNextLine();
    await t.pumpAndSettle();
    expect(find.text(l10n.gradeBandWaitingHint), findsNothing);
    expect(
      t.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
      isNotNull,
    );
    await t.tap(find.byType(FilledButton).first);
    await t.pumpAndSettle();
    expect(graded, isNotEmpty);
  });
}
