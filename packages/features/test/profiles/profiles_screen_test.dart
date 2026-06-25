// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T09: the active-profile switcher. It lists the device's profiles with the
// active one marked by shape + label (not colour alone), and tapping a profile
// re-scopes the app by flipping activeProfileProvider — every read model watches
// it. The offline guard proves the switch opens no socket (sharing is
// export/import, never a transfer). Faked ProfileRepository; real Mihrab fonts.

import 'package:composition/composition.dart'
    show activeProfileProvider, initialActiveProfileProvider, profileRepositoryProvider;
import 'package:features/features.dart' show MihrabAppearance, ProfilesScreen, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../settings/fake_profiles.dart';
import '../support/offline_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  Future<AppLocalizations> l10nAr() =>
      AppLocalizations.delegate.load(const Locale('ar'));

  Future<void> pump(WidgetTester tester) {
    final fake = FakeProfileRepository([fakeProfile('p1'), fakeProfile('p2')]);
    return tester.pumpWidget(
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
          home: const Scaffold(body: ProfilesScreen()),
        ),
      ),
    );
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(ProfilesScreen)));

  testWidgets('lists the profiles, the add button, and the active marker',
      (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    final l10n = await l10nAr();
    expect(find.text(isolate('name-p1')), findsOneWidget);
    expect(find.text(isolate('name-p2')), findsOneWidget);
    expect(find.text(l10n.profilesAddButton), findsOneWidget);
    // Exactly one profile is marked active (p1), by label not colour alone.
    expect(find.text(l10n.profilesActiveLabel), findsOneWidget);
  });

  testWidgets('tapping a profile re-scopes the active profile (opens no socket)',
      (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(activeProfileProvider),
        const ProfileId('p1'));

    await tester.tap(find.text(isolate('name-p2')));
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(activeProfileProvider),
        const ProfileId('p2'));
  });
}
