// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E12-T01 — the Today tab is the rightmost = home child of the single
// ShellRoute: the router's initialLocation `/today` resolves to TodayScreen, and
// navigating away then back via the localized Today nav label returns to it.
// Verified over the real routerProvider (E07-T03/T04), not redefined here.

import 'package:app/composition/router.dart';
import 'package:composition/composition.dart';
import 'package:data/testing.dart';
import 'package:features/features.dart'
    show MihrabAppearance, MihrabNavigationBar, TodayScreen, mihrabThemeFor;
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
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    final container = ProviderContainer(
      overrides: [
        persistenceProvider.overrideWithValue(handle),
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

  testWidgets('initialLocation /today resolves to TodayScreen', (t) async {
    final router = await pumpShell(t, const Locale('ar'));
    expect(location(router), '/today');
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('navigating away then tapping Today returns home', (t) async {
    final router = await pumpShell(t, const Locale('ar'));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    await t.tap(
      find.descendant(
        of: find.byType(MihrabNavigationBar),
        matching: find.text(l10n.navProgress),
      ),
    );
    await t.pumpAndSettle();
    expect(location(router), '/progress');

    await t.tap(
      find.descendant(
        of: find.byType(MihrabNavigationBar),
        matching: find.text(l10n.navToday),
      ),
    );
    await t.pumpAndSettle();
    expect(location(router), '/today');
    expect(find.byType(TodayScreen), findsOneWidget);
  });
}
