// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The shell chrome: five nav destinations in every locale, and a tap routes via
// go_router (typed navigation), updating the selected tab. Pumped over the real
// routerProvider with a verified, profiled device so the shell is reached.

import 'package:app/composition/active_profile_provider.dart';
import 'package:app/composition/app_ready_provider.dart';
import 'package:app/composition/router.dart';
import 'package:features/features.dart'
    show MihrabAppearance, MihrabNavigationBar, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<GoRouter> pumpShell(WidgetTester tester, Locale locale) async {
    final container = ProviderContainer(
      overrides: [
        coreVerifiedProvider.overrideWith((ref) async => true),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
      ],
    );
    addTearDown(container.dispose);
    await container.read(coreVerifiedProvider.future);

    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  String location(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  Finder navLabel(String label) => find.descendant(
        of: find.byType(MihrabNavigationBar),
        matching: find.text(label),
      );

  for (final locale in const <Locale>[
    Locale('ar'),
    Locale('fa'),
    Locale('ckb'),
  ]) {
    testWidgets('renders the five nav destinations under $locale', (t) async {
      await pumpShell(t, locale);
      final l10n = await AppLocalizations.delegate.load(locale);

      expect(find.byType(MihrabNavigationBar), findsOneWidget);
      for (final label in <String>[
        l10n.navToday,
        l10n.navMushaf,
        l10n.navMutashabihat,
        l10n.navProgress,
        l10n.navSettings,
      ]) {
        expect(navLabel(label), findsOneWidget);
      }
    });

    testWidgets('tapping a nav item routes via go_router under $locale',
        (t) async {
      final router = await pumpShell(t, locale);
      final l10n = await AppLocalizations.delegate.load(locale);

      await t.tap(navLabel(l10n.navProgress));
      await t.pumpAndSettle();
      expect(location(router), '/progress');
      expect(find.byKey(const ValueKey('screen.progress')), findsOneWidget);

      await t.tap(navLabel(l10n.navSettings));
      await t.pumpAndSettle();
      expect(location(router), '/settings');
      expect(find.byKey(const ValueKey('screen.settings')), findsOneWidget);
    });
  }
}
