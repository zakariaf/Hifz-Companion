// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T03/T04: the Display settings group — language (fa/ckb/ar), theme
// (light/sepia/dark), and calendar (Jalali/Umm-al-Qura/Gregorian) pickers. Each
// selection persists per-profile through the PreferencesWriter. The calendar is
// a pure display transform: switching it re-renders today's preview over the
// SAME injected instant. ProfileRepository is faked; offline guard; real fonts.

import 'package:composition/composition.dart'
    show
        cycleConfigRepositoryProvider,
        initialActiveProfileProvider,
        profileRepositoryProvider,
        todayProvider;
import 'package:features/features.dart'
    show DisplaySettingsSection, MihrabAppearance, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show CalendarDate, ProfileId, ProfileLocale;

import '../support/offline_test_bootstrap.dart';
import 'fake_profiles.dart';

final CalendarDate _fixedToday = CalendarDate.ymd(2026, 6, 25);

void main() {
  useOfflineTestPolicy();
  setUpAll(() async {
    await loadMihrabUiFonts();
    await initializeDateFormatting();
  });

  Future<AppLocalizations> l10nAr() =>
      AppLocalizations.delegate.load(const Locale('ar'));
  Future<AppLocalizations> l10nCkb() =>
      AppLocalizations.delegate.load(const Locale('ckb'));

  String preview(AppLocalizations l10n, CalendarSystem system) =>
      l10n.settingsCalendarToday(
        isolatedDateLabel(
          CalendarPresenter(system, const Locale('ar')),
          _fixedToday,
        ),
      );

  late FakeCycleConfigRepository cycleFake;

  Future<FakeProfileRepository> pump(
    WidgetTester tester, {
    Map<String, Object?>? settings,
    ProfileLocale locale = ProfileLocale.fa,
    Locale uiLocale = const Locale('ar'),
    String? region,
  }) async {
    // A tall viewport so all four pickers fit and stay hit-testable (the
    // term-set picker is the lowest).
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fake = FakeProfileRepository(
      [fakeProfile('p1', settings: settings, locale: locale)],
    );
    cycleFake = FakeCycleConfigRepository(
      [fakeCycleConfig('p1', regionPreset: region)],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fake),
          cycleConfigRepositoryProvider.overrideWithValue(cycleFake),
          initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
          todayProvider.overrideWithValue(_fixedToday),
        ],
        child: MaterialApp(
          locale: uiLocale,
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

  testWidgets('renders the language, theme and calendar pickers', (tester) async {
    await pump(tester);
    final l10n = await l10nAr();
    expect(find.text(l10n.settingsLanguageLabel), findsOneWidget);
    expect(find.text(l10n.settingsThemeLabel), findsOneWidget);
    expect(find.text(l10n.settingsCalendarLabel), findsOneWidget);
    expect(find.text(l10n.languageNameFa), findsOneWidget);
    expect(find.text(l10n.appearanceSepia), findsOneWidget);
    expect(find.text(l10n.calendarJalali), findsOneWidget);
    expect(find.text(l10n.calendarGregorian), findsOneWidget);
  });

  testWidgets('the Hijri option carries the civil-courtesy caveat (adab)',
      (tester) async {
    await pump(tester);
    final l10n = await l10nAr();
    expect(find.text(l10n.calendarUmmAlQura), findsOneWidget);
    expect(find.text(l10n.hijriCivilApproximationCaveat), findsOneWidget);
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

  testWidgets(
      'switching the calendar persists it and re-renders the preview over the '
      'same instant', (tester) async {
    final fake = await pump(tester); // default Jalālī
    final l10n = await l10nAr();

    // The preview shows today in Jalālī; the Gregorian rendering is absent.
    expect(find.text(preview(l10n, CalendarSystem.jalali)), findsOneWidget);
    expect(find.text(preview(l10n, CalendarSystem.gregorian)), findsNothing);

    await tester.tap(find.text(l10n.calendarGregorian));
    await tester.pumpAndSettle();

    // Persisted, and the preview re-rendered the SAME instant in Gregorian.
    expect(fake.store['p1']!.settings?['calendar'], 'gregorian');
    expect(find.text(preview(l10n, CalendarSystem.gregorian)), findsOneWidget);
    expect(find.text(preview(l10n, CalendarSystem.jalali)), findsNothing);
  });

  testWidgets('renders the term-set region options', (tester) async {
    await pump(tester);
    final l10n = await l10nAr();
    expect(find.text(l10n.settingsTermSetLabel), findsOneWidget);
    expect(find.text(l10n.termSetRegionOther), findsOneWidget);
    expect(find.text(l10n.termSetRegionLevant), findsOneWidget);
    expect(find.text(l10n.termSetRegionSubcontinent), findsOneWidget);
  });

  testWidgets('choosing a term-set region persists it through the writer',
      (tester) async {
    await pump(tester);
    final l10n = await l10nAr();
    await tester.tap(find.text(l10n.termSetRegionSubcontinent));
    await tester.pumpAndSettle();
    expect(cycleFake.store['p1']!.regionPreset, 'subcontinent');
  });

  testWidgets('the ckb provisional note shows under Kurdish, not Arabic',
      (tester) async {
    await pump(tester); // Arabic UI — no provisional note.
    final ar = await l10nAr();
    expect(find.text(ar.termSetProvisionalNote), findsNothing);

    await pump(tester, uiLocale: const Locale('ckb'));
    final ckb = await l10nCkb();
    expect(find.text(ckb.termSetProvisionalNote), findsOneWidget);
  });

  testWidgets('no Slider anywhere in the display pickers', (tester) async {
    await pump(tester);
    expect(find.byType(Slider), findsNothing);
  });
}
