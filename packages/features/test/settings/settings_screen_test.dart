// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T01: the grouped Settings scaffold renders its five section headers
// (Display · Cycle · Profiles · Backup · About) on the one-handed template,
// keeps the `screen.settings` a11y id the shell journey addresses, mirrors to
// RTL under fa, and shows no gamified/scoreboard surface. Offline guard
// installed; real Mihrab UI fonts for honest layout.

import 'package:features/features.dart'
    show MihrabAppearance, SettingsScreen, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../support/offline_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  Future<AppLocalizations> l10nAr() =>
      AppLocalizations.delegate.load(const Locale('ar'));

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
  }) =>
      tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: hifzLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: mihrabThemeFor(MihrabAppearance.light),
            // The screen is a tab body; HomeShell supplies the Scaffold in-app.
            home: const Scaffold(body: SettingsScreen()),
          ),
        ),
      );

  testWidgets('renders the five grouped section headers', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    final l10n = await l10nAr();
    expect(find.text(l10n.settingsSectionDisplay), findsOneWidget);
    expect(find.text(l10n.settingsSectionCycle), findsOneWidget);
    expect(find.text(l10n.settingsSectionProfiles), findsOneWidget);
    expect(find.text(l10n.settingsSectionBackup), findsOneWidget);
    expect(find.text(l10n.settingsSectionAbout), findsOneWidget);
  });

  testWidgets('keeps the screen.settings accessibility id', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('screen.settings')),
      findsOneWidget,
    );
  });

  testWidgets('no gamified/scoreboard iconography', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(find.byIcon(Icons.emoji_events), findsNothing);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.byIcon(Icons.celebration), findsNothing);
  });

  testWidgets('mirrors to RTL under a Persian (fa) locale', (tester) async {
    await pump(tester, locale: const Locale('fa'));
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(SettingsScreen))),
      TextDirection.rtl,
    );
  });
}
