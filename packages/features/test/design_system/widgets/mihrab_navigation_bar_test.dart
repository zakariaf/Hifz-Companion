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
    home: Directionality(textDirection: direction, child: child),
  );
}

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

    // Five destinations declared in logical order; RTL flips the geometry.
    expect(find.byType(NavigationDestination), findsNWidgets(5));
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
        home: MihrabNavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (i) => tapped = i,
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

  testWidgets('the nav clears the 48dp touch floor', (tester) async {
    await tester.pumpWidget(_host(TextDirection.rtl, _bar()));
    await tester.pumpAndSettle();
    final h = tester.getSize(find.byType(NavigationBar)).height;
    expect(h, greaterThanOrEqualTo(48));
  });

  testWidgets('ckb longer labels lay out without overflow', (tester) async {
    const ckb = Locale('ckb');
    await tester.pumpWidget(_host(TextDirection.rtl, _bar(), locale: ckb));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
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
