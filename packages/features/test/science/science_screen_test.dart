// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Non-golden widget coverage for the science screen: it renders the register
// (title, group headers, the grade legend), carries no exclamation/coercion
// copy, keeps its accessibility id, and builds fully under a throwing
// HttpOverrides (offline, no in-app network).

import 'package:composition/composition.dart' show sourceLinkLauncherProvider;
import 'package:composition/testing.dart' show FakeSourceLinkLauncher;
import 'package:features/features.dart'
    show MihrabAppearance, ScienceScreen, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show loadRealUiFonts;
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  Future<void> pumpScreen(WidgetTester tester,
      {Locale locale = const Locale('ar')}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sourceLinkLauncherProvider
              .overrideWithValue(FakeSourceLinkLauncher()),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const Scaffold(body: ScienceScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders title, a group header, and the grade legend',
      (tester) async {
    await pumpScreen(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.scienceTitle), findsWidgets);
    expect(find.text(l10n.scienceGroupA), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('screen.science')),
      findsOneWidget,
    );
    // The grade legend is the last item of a lazy list — scroll it into view.
    final legendTitle = find.text(l10n.certaintyLegendTitle);
    await tester.scrollUntilVisible(
      legendTitle,
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(legendTitle, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('carries no exclamation / coercion copy', (tester) async {
    await pumpScreen(tester);
    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      final data = w.data ?? '';
      expect(data.contains('!'), isFalse);
      expect(data.contains('！'), isFalse);
    }
  });

  testWidgets('mirrors to RTL under Persian (fa)', (tester) async {
    await pumpScreen(tester, locale: const Locale('fa'));
    expect(
      Directionality.of(tester.element(find.byType(ScienceScreen))),
      TextDirection.rtl,
    );
  });

  testWidgets('no gamified iconography on the science surface', (tester) async {
    await pumpScreen(tester);
    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(find.byIcon(Icons.emoji_events), findsNothing);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.byIcon(Icons.celebration), findsNothing);
  });
}
