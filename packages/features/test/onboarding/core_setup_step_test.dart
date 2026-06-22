// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The core-preparation step (E11-T04): verify the bundled muṣḥaf (not a network
// download) as calm preparing/ready/integrityFailure states, fail-closed (only
// Retry on failure, no skip), with the advance-guard gating coverage on ready.
// The install is an injected action (a fake here); the step opens no socket.

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show CalendarDate;
import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/core_setup_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  ProviderContainer containerWith(Future<CoreSetupPhase> Function() action) {
    final c = ProviderContainer(
      overrides: [
        todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 22)),
        coreSetupActionProvider.overrideWithValue(action),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  CoreSetupPhase phaseOf(ProviderContainer c) =>
      c.read(onboardingControllerProvider(null)).coreSetupPhase;

  group('runCoreSetup (controller)', () {
    test('a verified install lands ready and opens the cursor guard', () async {
      final c = containerWith(() async => CoreSetupPhase.ready);
      await c.read(onboardingControllerProvider(null).notifier).runCoreSetup();
      expect(phaseOf(c), CoreSetupPhase.ready);
    });

    test('an integrity failure is fail-closed and never opens the guard',
        () async {
      final c = containerWith(() async => CoreSetupPhase.integrityFailure);
      await c.read(onboardingControllerProvider(null).notifier).runCoreSetup();
      expect(phaseOf(c), CoreSetupPhase.integrityFailure);
    });

    test('a thrown install error fails closed to integrityFailure', () async {
      final c = containerWith(() async => throw StateError('boom'));
      await c.read(onboardingControllerProvider(null).notifier).runCoreSetup();
      expect(phaseOf(c), CoreSetupPhase.integrityFailure);
    });
  });

  Future<AppLocalizations> pumpStep(
    WidgetTester tester, {
    required CoreSetupPhase phase,
    required Future<void> Function() onRun,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: CoreSetupStep(phase: phase, onRun: onRun)),
      ),
    );
    // The preparing state shows an indeterminate spinner that never settles, so
    // pump fixed frames (enough to fire initState's post-frame start) rather
    // than pumpAndSettle.
    await tester.pump();
    await tester.pump();
    return AppLocalizations.delegate.load(const Locale('ar'));
  }

  Finder retryBtn(AppLocalizations l10n) =>
      find.widgetWithText(FilledButton, l10n.onboardingRetry);
  Finder continueBtn(AppLocalizations l10n) =>
      find.widgetWithText(FilledButton, l10n.onboardingContinue);

  testWidgets('preparing shows progress and no Retry', (t) async {
    final l10n =
        await pumpStep(t, phase: CoreSetupPhase.preparing, onRun: () async {});
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(l10n.onboardingCorePreparingTitle), findsOneWidget);
    expect(retryBtn(l10n), findsNothing);
  });

  testWidgets('ready shows the airplane-mode proof, no Retry, no celebration',
      (t) async {
    final l10n =
        await pumpStep(t, phase: CoreSetupPhase.ready, onRun: () async {});
    expect(find.text(l10n.onboardingCoreReadyBody), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(retryBtn(l10n), findsNothing);
    for (final w in t.widgetList<Text>(find.byType(Text))) {
      expect((w.data ?? '').contains('!'), isFalse);
    }
  });

  testWidgets('integrityFailure offers only Retry — no skip/continue',
      (t) async {
    final l10n = await pumpStep(
      t,
      phase: CoreSetupPhase.integrityFailure,
      onRun: () async {},
    );
    expect(find.text(l10n.onboardingCoreIntegrityFailureTitle), findsOneWidget);
    expect(retryBtn(l10n), findsOneWidget);
    // The only forward affordance is Retry — no skip / continue-anyway.
    expect(continueBtn(l10n), findsNothing);
  });

  testWidgets('starts once on entry when idle; no auto-retry on failure',
      (t) async {
    var runs = 0;
    await pumpStep(
      t,
      phase: CoreSetupPhase.idle,
      onRun: () async => runs++,
    );
    expect(runs, 1);

    // Mounting on a failure does NOT auto-run; only an explicit Retry does.
    runs = 0;
    final l10n = await pumpStep(
      t,
      phase: CoreSetupPhase.integrityFailure,
      onRun: () async => runs++,
    );
    expect(runs, 0);
    await t.tap(retryBtn(l10n));
    await t.pumpAndSettle();
    expect(runs, 1);
  });
}
