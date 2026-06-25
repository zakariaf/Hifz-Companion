// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E16-T12 — per-locale (ar/fa/ckb) RTL goldens of the Settings Display group
// (language / theme / calendar / term-set / muṣḥaf pickers) and the active-profile
// switcher, on the REAL bundled UI font (Vazirmatn, never Ahem): RTL geometry,
// the calm flat chrome, selection by shape+label. The Linux golden lane verifies;
// masters regenerate via `--update-goldens` (the `[update-goldens]` CI lane),
// never blessed by CI. (ckb is the longest transcreation — the reflow stress.)

import 'package:composition/composition.dart'
    show
        cycleConfigRepositoryProvider,
        initialActiveProfileProvider,
        persistenceProvider,
        profileRepositoryProvider,
        todayProvider;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:features/features.dart'
    show
        DisplaySettingsSection,
        MihrabAppearance,
        ProfilesScreen,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show CalendarDate, ProfileId;

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';
import 'fake_profiles.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  Future<void> pump(WidgetTester tester, Locale locale, Widget body) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(420, 1500) * 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(handle),
          profileRepositoryProvider.overrideWithValue(
            FakeProfileRepository([
              fakeProfile('p1'),
              fakeProfile('p2'),
            ]),
          ),
          cycleConfigRepositoryProvider.overrideWithValue(
            FakeCycleConfigRepository([fakeCycleConfig('p1')]),
          ),
          initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
          todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 25)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: Scaffold(body: body),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('display settings group ($code)', (tester) async {
      await pump(
        tester,
        locale,
        const SingleChildScrollView(child: DisplaySettingsSection()),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_display__$code.png'),
      );
    });

    testWidgets('profile switcher ($code)', (tester) async {
      await pump(tester, locale, const ProfilesScreen());
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/profiles_switcher__$code.png'),
      );
    });
  }
}
