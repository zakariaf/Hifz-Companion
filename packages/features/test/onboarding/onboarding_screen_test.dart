// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The dumb onboarding host (E11-T01): it shows the cursor's step View plus the
// shared chrome (step-progress + back/next), advances/returns by calling the
// capture controller, and touches no persistence (it is pumped with no override,
// so any data read would throw the un-overridden placeholder).

import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/coverage_grid.dart';
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

  Finder stepHost(OnboardingStep step) =>
      find.byKey(ValueKey<String>('onboarding.step.${step.name}'));

  bool continueEnabled(WidgetTester tester, String label) =>
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, label))
          .onPressed !=
      null;

  testWidgets('opens on the welcome step with no Back affordance', (t) async {
    final l10n = await pumpOnboarding(t);
    expect(stepHost(OnboardingStep.welcomePrivacy), findsOneWidget);
    // Back is hidden on the first step; Continue is present.
    expect(find.widgetWithText(TextButton, l10n.onboardingBack), findsNothing);
    expect(continueEnabled(t, l10n.onboardingContinue), isTrue);
  });

  testWidgets('Continue advances the cursor; Back returns without loss',
      (t) async {
    final l10n = await pumpOnboarding(t);

    await t.tap(find.widgetWithText(FilledButton, l10n.onboardingContinue));
    await t.pumpAndSettle();
    // Now on the language step, with a Back affordance.
    expect(stepHost(OnboardingStep.language), findsOneWidget);
    expect(stepHost(OnboardingStep.welcomePrivacy), findsNothing);
    final back = find.widgetWithText(TextButton, l10n.onboardingBack);
    expect(back, findsOneWidget);

    await t.tap(back);
    await t.pumpAndSettle();
    expect(stepHost(OnboardingStep.welcomePrivacy), findsOneWidget);
  });

  testWidgets('the coverage step host composes the live coverage grid',
      (t) async {
    final l10n = await pumpOnboarding(t);
    // The View cannot itself satisfy the language/riwāyah/coreSetup guards
    // (those are sibling steps), so drive the cursor to coverage via the
    // controller, then assert the host→leaf wiring and the grid→controller path.
    final container = ProviderScope.containerOf(
      t.element(find.byType(OnboardingScreen)),
    );
    container.read(onboardingControllerProvider(null).notifier)
      ..next()
      ..setLocale(const Locale('ar'))
      ..next()
      ..confirmMushaf('kfgqpc_hafs_madani_v2')
      ..next()
      ..setCoreSetupPhase(CoreSetupPhase.ready)
      ..next();
    await t.pumpAndSettle();
    expect(find.byType(CoverageGrid), findsOneWidget);
    expect(continueEnabled(t, l10n.onboardingContinue), isFalse);

    // Tapping a cell drives the controller (no local copy) and enables Continue.
    await t.tap(
      find
          .descendant(
            of: find.byType(CoverageGrid),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await t.pumpAndSettle();
    expect(continueEnabled(t, l10n.onboardingContinue), isTrue);
  });
}
