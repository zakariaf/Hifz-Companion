// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../test_setup.dart';

Widget _host(TextDirection direction, Widget child, {Locale? locale}) {
  return MaterialApp(
    locale: locale ?? const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: Directionality(
      textDirection: direction,
      child: Align(alignment: Alignment.bottomCenter, child: child),
    ),
  );
}

// Each tab keeps its outlined icon in the layout (the active one only fades to
// opacity 0), so an icon's centre is a reliable proxy for its tab's position.
double _iconX(WidgetTester tester, IconData icon) =>
    tester.getCenter(find.byIcon(icon)).dx;

MihrabNavigationBar _bar() =>
    MihrabNavigationBar(selectedIndex: 0, onDestinationSelected: (_) {});

void main() {
  useOfflineTestPolicy();

  testWidgets('RTL: Today sits at the trailing/right edge, Settings at left', (
    tester,
  ) async {
    await tester.pumpWidget(_host(TextDirection.rtl, _bar()));
    await tester.pumpAndSettle();

    final today = _iconX(tester, Icons.wb_sunny_outlined);
    final settings = _iconX(tester, Icons.settings_outlined);
    expect(today, greaterThan(settings));
  });

  testWidgets('LTR mirrors: Today sits at the left edge', (tester) async {
    await tester.pumpWidget(_host(TextDirection.ltr, _bar()));
    await tester.pumpAndSettle();

    final today = _iconX(tester, Icons.wb_sunny_outlined);
    final settings = _iconX(tester, Icons.settings_outlined);
    expect(today, lessThan(settings));
  });

  testWidgets('the active tab lifts into the filled bubble', (tester) async {
    await tester.pumpWidget(_host(TextDirection.rtl, _bar()));
    await tester.pumpAndSettle();

    // Today is selected: its filled icon shows once (in the floating bubble),
    // and the other four render their outlined icons.
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    for (final icon in const [
      Icons.menu_book_outlined,
      Icons.compare_arrows_outlined,
      Icons.grid_view_outlined,
      Icons.settings_outlined,
    ]) {
      expect(find.byIcon(icon), findsOneWidget);
    }
  });

  testWidgets('selection is a plain index callback — no route push', (
    tester,
  ) async {
    final observer = _CountingObserver();
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        navigatorObservers: [observer],
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: MihrabNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (i) => tapped = i,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    observer.pushes = 0; // ignore MaterialApp's initial home-route push

    await tester.tap(find.byIcon(Icons.grid_view_outlined)); // Progress (idx 3)
    await tester.pumpAndSettle();
    expect(tapped, 3);
    expect(observer.pushes, 0); // tapping a tab pushes no real route
  });

  testWidgets('the tab row clears the 48dp touch floor', (tester) async {
    await tester.pumpWidget(_host(TextDirection.rtl, _bar()));
    await tester.pumpAndSettle();
    // The tappable cell is as tall as the bar body; assert that floor.
    final cell = tester.getSize(
      find.ancestor(
        of: find.byIcon(Icons.settings_outlined),
        matching: find.byType(GestureDetector),
      ),
    );
    expect(cell.height, greaterThanOrEqualTo(48));
  });

  testWidgets('ckb longer labels lay out without overflow', (tester) async {
    const ckb = Locale('ckb');
    await tester.pumpWidget(_host(TextDirection.rtl, _bar(), locale: ckb));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // Five tabs present (their outlined icons, the active one faded but laid out)
    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}

class _CountingObserver extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}
