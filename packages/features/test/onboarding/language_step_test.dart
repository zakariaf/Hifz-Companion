// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The language pick (E11-T03): a single-select over fa/ckb/ar endonyms that
// applies live as a display transform. The leaf View only takes selected +
// onSelected (no engine/due_at/instant reachable); the screen re-localizes its
// subtree to the captured locale.

import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/language_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> pumpLeaf(
    WidgetTester tester, {
    Locale? selected,
    required ValueChanged<Locale> onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: LanguageStep(selected: selected, onSelected: onSelected),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('ar'));
  }

  testWidgets('renders the three endonyms; no Slider', (t) async {
    final l10n = await pumpLeaf(t, onSelected: (_) {});
    expect(find.text(l10n.languageNameFa), findsOneWidget);
    expect(find.text(l10n.languageNameCkb), findsOneWidget);
    expect(find.text(l10n.languageNameAr), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('tapping a language routes through onSelected only', (t) async {
    Locale? picked;
    final l10n = await pumpLeaf(t, onSelected: (l) => picked = l);
    await t.tap(find.text(l10n.languageNameFa));
    await t.pumpAndSettle();
    expect(picked, const Locale('fa'));
  });

  testWidgets('live display transform: picking ckb re-localizes the chrome',
      (t) async {
    await t.pumpWidget(
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
    await t.pumpAndSettle();
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    final ckb = await AppLocalizations.delegate.load(const Locale('ckb'));

    // Drive the cursor to the language step.
    final container = ProviderScope.containerOf(
      t.element(find.byType(OnboardingScreen)),
    );
    container.read(onboardingControllerProvider(null).notifier).next();
    await t.pumpAndSettle();

    // The title shows the inherited (ar) value before a pick.
    expect(find.text(ar.onboardingLanguageStepTitle), findsOneWidget);

    // Pick Central Kurdish → the whole subtree re-localizes to ckb.
    await t.tap(find.text(ckb.languageNameCkb));
    await t.pumpAndSettle();
    expect(find.text(ckb.onboardingLanguageStepTitle), findsOneWidget);
  });
}
