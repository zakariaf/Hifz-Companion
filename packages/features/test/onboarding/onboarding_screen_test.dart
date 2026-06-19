// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The cold-start capture flow: a juz-coverage grid (continue gated on a
// selection), then a per-held-juz Solid/Shaky/Rusty rater (done gated on a
// rating). No persistence is touched until commit, so the capture flow needs no
// repository override.

import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/coverage_grid.dart';
import 'package:features/src/onboarding/widgets/juz_confidence_rater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('ar'));
  }

  Finder firstJuzCell() => find
      .descendant(of: find.byType(CoverageGrid), matching: find.byType(InkWell))
      .first;

  bool isEnabled(WidgetTester tester, String label) =>
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, label))
          .onPressed !=
      null;

  testWidgets('coverage first; continue is gated on a selection', (t) async {
    final l10n = await pumpOnboarding(t);

    expect(find.byType(CoverageGrid), findsOneWidget);
    expect(find.byType(JuzConfidenceRater), findsNothing);
    expect(isEnabled(t, l10n.onboardingContinue), isFalse);

    // Hold a juz → continue enables.
    await t.tap(firstJuzCell());
    await t.pumpAndSettle();
    expect(isEnabled(t, l10n.onboardingContinue), isTrue);
  });

  testWidgets('advancing shows the rater; done is gated on a rating',
      (t) async {
    final l10n = await pumpOnboarding(t);

    await t.tap(firstJuzCell());
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, l10n.onboardingContinue));
    await t.pumpAndSettle();

    expect(find.byType(JuzConfidenceRater), findsOneWidget);
    expect(isEnabled(t, l10n.onboardingDone), isFalse);

    // Rate the held juz → done enables.
    await t.tap(find.text(l10n.confidenceSolid));
    await t.pumpAndSettle();
    expect(isEnabled(t, l10n.onboardingDone), isTrue);
  });
}
