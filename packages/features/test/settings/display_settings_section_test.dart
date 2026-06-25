// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T03: the Display settings group — the language (fa/ckb/ar) and theme
// (light/sepia/dark) pickers. Each selection persists per-profile through the
// PreferencesWriter (the active profile's locale column / settings_json).
// ProfileRepository is faked; offline guard installed; real Mihrab fonts.

import 'package:composition/composition.dart'
    show initialActiveProfileProvider, profileRepositoryProvider;
import 'package:features/features.dart'
    show DisplaySettingsSection, MihrabAppearance, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId, ProfileLocale;

import '../support/offline_test_bootstrap.dart';
import 'fake_profiles.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  Future<AppLocalizations> l10nAr() =>
      AppLocalizations.delegate.load(const Locale('ar'));

  Future<FakeProfileRepository> pump(
    WidgetTester tester, {
    Map<String, Object?>? settings,
    ProfileLocale locale = ProfileLocale.fa,
  }) async {
    final fake = FakeProfileRepository(
      [fakeProfile('p1', settings: settings, locale: locale)],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fake),
          initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const Scaffold(
            body: SingleChildScrollView(child: DisplaySettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return fake;
  }

  testWidgets('renders the language and theme pickers with their labels',
      (tester) async {
    await pump(tester);
    final l10n = await l10nAr();
    expect(find.text(l10n.settingsLanguageLabel), findsOneWidget);
    expect(find.text(l10n.settingsThemeLabel), findsOneWidget);
    expect(find.text(l10n.languageNameFa), findsOneWidget);
    expect(find.text(l10n.appearanceSepia), findsOneWidget);
  });

  testWidgets('choosing a theme persists it through the writer', (tester) async {
    final fake = await pump(tester);
    final l10n = await l10nAr();
    await tester.tap(find.text(l10n.appearanceDark));
    await tester.pumpAndSettle();
    expect(fake.store['p1']!.settings?['appearance'], 'dark');
  });

  testWidgets('choosing a language persists the profile locale', (tester) async {
    final fake = await pump(tester);
    final l10n = await l10nAr();
    await tester.tap(find.text(l10n.languageNameAr));
    await tester.pumpAndSettle();
    expect(fake.store['p1']!.locale, ProfileLocale.ar);
  });

  testWidgets('no Slider anywhere in the display pickers', (tester) async {
    await pump(tester);
    expect(find.byType(Slider), findsNothing);
  });
}
