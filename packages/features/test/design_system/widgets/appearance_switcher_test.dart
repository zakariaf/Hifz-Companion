// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../test_setup.dart';

Widget _host(Widget child) {
  return MaterialApp(
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  useOfflineTestPolicy();

  testWidgets('renders five segments; selecting another emits onChanged', (
    tester,
  ) async {
    AppearanceSetting? chosen;
    final switcher = AppearanceSwitcher(
      selected: AppearanceSetting.followSystem,
      onChanged: (s) => chosen = s,
    );
    await tester.pumpWidget(_host(switcher));
    await tester.pumpAndSettle();

    final segmented = tester.widget<SegmentedButton<AppearanceSetting>>(
      find.byType(SegmentedButton<AppearanceSetting>),
    );
    expect(segmented.segments.length, 5);
    expect(segmented.selected, {AppearanceSetting.followSystem});

    final l10n = AppLocalizations.of(
      tester.element(find.byType(AppearanceSwitcher)),
    )!;
    await tester.tap(find.text(l10n.appearanceSepia));
    await tester.pumpAndSettle();
    expect(chosen, AppearanceSetting.sepia);
  });

  testWidgets('a narrow width reflows to a radio group, same callback', (
    tester,
  ) async {
    AppearanceSetting? chosen;
    final switcher = AppearanceSwitcher(
      selected: AppearanceSetting.light,
      onChanged: (s) => chosen = s,
    );
    await tester.pumpWidget(_host(SizedBox(width: 200, child: switcher)));
    await tester.pumpAndSettle();

    expect(find.byType(SegmentedButton<AppearanceSetting>), findsNothing);
    expect(find.byType(RadioListTile<AppearanceSetting>), findsNWidgets(5));

    final l10n = AppLocalizations.of(
      tester.element(find.byType(AppearanceSwitcher)),
    )!;
    await tester.tap(find.text(l10n.appearanceNight));
    await tester.pumpAndSettle();
    expect(chosen, AppearanceSetting.night);
  });
}
