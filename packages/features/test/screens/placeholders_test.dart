// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The four non-Today tabs (and Today's interim slot) render an inert calm
// placeholder: a localized title + one reverent body line, with zero interactive
// element in the screen subtree.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // Today is the real queue View (E07-T07) and Muṣḥaf is the real reader (E13);
  // the remaining non-Today tabs are still inert placeholders.
  const screens = <String, Widget>{
    'screen.mutashabihat': MutashabihatScreen(),
    'screen.progress': ProgressScreen(),
    'screen.settings': SettingsScreen(),
  };

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  screens.forEach((identifier, screen) {
    testWidgets('$identifier renders a calm title + body and is inert',
        (tester) async {
      await pumpScreen(tester, screen);
      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

      final root = find.byKey(ValueKey<String>(identifier));
      expect(root, findsOneWidget);
      expect(find.text(l10n.sectionInPreparation), findsOneWidget);

      // Inert: no interactive element anywhere in the screen subtree.
      for (final interactive in <Finder>[
        find.descendant(of: root, matching: find.byType(GestureDetector)),
        find.descendant(of: root, matching: find.byType(InkWell)),
        find.descendant(of: root, matching: find.byType(ButtonStyleButton)),
      ]) {
        expect(interactive, findsNothing);
      }
    });
  });
}
