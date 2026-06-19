// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:app/app.dart';
import 'package:composition/composition.dart';
import 'package:data/testing.dart';
import 'package:features/features.dart' show OnboardingScreen;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // The shell now boots through the router + redirect guard, which reads the
  // persistence boundary (coreVerifiedProvider) — so HifzApp is pumped with the
  // in-memory handle. A fresh store has no profile, so the guard lands on
  // onboarding (R1: no shell, no Quran, before a profile exists).
  Widget bootedApp() {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    return ProviderScope(
      overrides: [persistenceProvider.overrideWithValue(handle)],
      child: const HifzApp(),
    );
  }

  testWidgets('a fresh device boots to onboarding', (tester) async {
    await tester.pumpWidget(bootedApp());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('direction is RTL by construction for ar/fa/ckb', (tester) async {
    // One handle reused across locales (a fresh handle per iteration trips
    // drift's multiple-instance heuristic).
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    final app = ProviderScope(
      overrides: [persistenceProvider.overrideWithValue(handle)],
      child: const HifzApp(),
    );

    for (final Locale locale in const <Locale>[
      Locale('ar'),
      Locale('fa'),
      Locale('ckb'),
    ]) {
      tester.platformDispatcher.localesTestValue = <Locale>[locale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Onboarding (outside the ShellRoute) renders under the app-wide
      // Directionality; read direction from its Scaffold context.
      final BuildContext context = tester.element(find.byType(Scaffold).first);
      expect(
        Directionality.of(context),
        TextDirection.rtl,
        reason: 'locale $locale must render right-to-left',
      );
    }
  });

  test('supported locales are exactly ar/fa/ckb', () {
    expect(
      AppLocalizations.supportedLocales
          .map((locale) => locale.languageCode)
          .toSet(),
      <String>{'ar', 'fa', 'ckb'},
    );
  });
}
