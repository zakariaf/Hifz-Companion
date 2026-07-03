// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T01: the grouped Settings scaffold renders its section headers (Display ·
// Cycle · Reminders [E18-T06] · Profiles · Backup · About) on the one-handed
// template, keeps the `screen.settings` a11y id the shell journey addresses,
// mirrors to RTL under fa, and shows no gamified/scoreboard surface. Offline
// guard installed; real Mihrab UI fonts for honest layout.

import 'package:composition/composition.dart'
    show
        cycleConfigRepositoryProvider,
        notificationSchedulerProvider,
        profileRepositoryProvider;
import 'package:composition/testing.dart' show FakeNotificationScheduler;
import 'package:features/features.dart'
    show MihrabAppearance, SettingsFocus, SettingsScreen, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../support/offline_test_bootstrap.dart';
import 'fake_profiles.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  Future<AppLocalizations> l10nAr() =>
      AppLocalizations.delegate.load(const Locale('ar'));

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
    SettingsFocus? focus,
    Size viewport = const Size(1200, 4000),
  }) {
    // A roomy default viewport renders every section; a focus test passes a
    // phone-sized viewport to put the Cycle group below the fold.
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(
      ProviderScope(
        // The Display group reads the profile/preference seam; no active
        // profile is selected, so it renders the calm defaults.
        overrides: [
          profileRepositoryProvider
              .overrideWithValue(FakeProfileRepository([])),
          cycleConfigRepositoryProvider
              .overrideWithValue(FakeCycleConfigRepository()),
          // E18-T06 mounts the reminder section here; it reads the scheduler
          // boundary (the permission status), so wire a no-op fake.
          notificationSchedulerProvider
              .overrideWithValue(FakeNotificationScheduler()),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          // The screen is a tab body; HomeShell supplies the Scaffold in-app.
          home: Scaffold(body: SettingsScreen(focus: focus)),
        ),
      ),
    );
  }

  testWidgets('renders the grouped preference sections', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    final l10n = await l10nAr();
    // The mihrab restyle splits Display into per-preference niche cards.
    expect(find.text(l10n.settingsLanguageLabel), findsOneWidget);
    expect(find.text(l10n.settingsThemeLabel), findsOneWidget);
    expect(find.text(l10n.settingsCalendarLabel), findsOneWidget);
    expect(find.text(l10n.settingsSectionCycle), findsOneWidget);
    expect(find.text(l10n.settingsSectionReminders), findsOneWidget);
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

  group('SettingsFocus.fromQuery (the budget deep-link contract)', () {
    test('maps "cycle" → cycle, everything else → null', () {
      expect(SettingsFocus.fromQuery('cycle'), SettingsFocus.cycle);
      expect(SettingsFocus.fromQuery(null), isNull);
      expect(SettingsFocus.fromQuery(''), isNull);
      expect(SettingsFocus.fromQuery('display'), isNull);
    });
  });

  testWidgets('focus: cycle scrolls the Cycle group into view', (tester) async {
    // A phone-sized viewport leaves the tall Display group filling the screen,
    // so the Cycle group starts below the fold (the deep-link must reveal it).
    await pump(
      tester,
      focus: SettingsFocus.cycle,
      viewport: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    final l10n = await l10nAr();
    // Cycle is revealed near the top of the viewport...
    expect(
      tester.getTopLeft(find.text(l10n.settingsSectionCycle)).dy,
      lessThan(200),
    );
    // ...and the Language card it sat above has scrolled above the fold, proving
    // the list genuinely moved (not a trivially-already-at-top pass).
    expect(
      tester.getTopLeft(find.text(l10n.settingsLanguageLabel)).dy,
      lessThan(0),
    );
  });
}
