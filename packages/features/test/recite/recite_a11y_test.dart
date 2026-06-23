// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Accessibility: the disabled grade band reads as waiting; each revealed line is
// a labelled stumble toggle with a ≥48dp hit-area, under RTL.

import 'package:features/features.dart'
    show
        MihrabAppearance,
        ReciteGradeBand,
        ReciteSurface,
        mihrabThemeFor,
        reciteControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();

  testWidgets('disabled band reads as waiting (not broken)', (t) async {
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: reciteContainer(
          cards: StubCards(reciteCard()),
          reviews: RecordingReviews(),
        ),
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: Scaffold(body: ReciteGradeBand(pageId: 42, onGrade: (_) {})),
        ),
      ),
    );
    await t.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.gradeBandWaitingHint), findsOneWidget);
  });

  testWidgets('a revealed line is a labelled stumble toggle ≥48dp', (t) async {
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
          home: const Scaffold(body: ReciteSurface(pageId: 42)),
        ),
      ),
    );
    container.read(reciteControllerProvider(42).notifier).revealNextLine();
    await t.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    final label =
        l10n.reciteStumbleLineLabel(localeDigits(1, const Locale('ar')));
    final finder = find.bySemanticsLabel(label);
    expect(finder, findsOneWidget);
    expect(t.getSize(finder.first).height, greaterThanOrEqualTo(48.0));
  });
}
