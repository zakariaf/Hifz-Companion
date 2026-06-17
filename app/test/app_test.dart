// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  testWidgets('launches to the placeholder screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HifzApp()));
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
  });

  testWidgets('the one visible string comes from l10n, not a literal',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HifzApp()));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold));
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    expect(find.text(l10n.appTitle), findsOneWidget);
  });

  testWidgets('direction is RTL by construction for ar/fa/ckb', (tester) async {
    for (final Locale locale in const <Locale>[
      Locale('ar'),
      Locale('fa'),
      Locale('ckb'),
    ]) {
      tester.platformDispatcher.localesTestValue = <Locale>[locale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(const ProviderScope(child: HifzApp()));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(Scaffold));
      expect(
        Directionality.of(context),
        TextDirection.rtl,
        reason: 'locale $locale must render right-to-left',
      );
    }
  });

  test('supported locales are exactly ar/fa/ckb', () {
    expect(
      AppLocalizations.supportedLocales
          .map((locale) => locale.languageCode)
          .toSet(),
      <String>{'ar', 'fa', 'ckb'},
    );
  });
}
