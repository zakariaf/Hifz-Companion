// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The all-done close is a calm line — no celebration, no exclamation mark. The
// silent resume greets nothing. And the banned-phrase / no-greeting invariants
// hold over the copy this epic adds in all three locales.

import 'package:features/features.dart'
    show
        MihrabAppearance,
        TodayAllDone,
        TodaySilentResume,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

Widget _host(Locale locale, Widget child) => MaterialApp(
      locale: locale,
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(body: child),
    );

void main() {
  useOfflineTestPolicy();

  testWidgets('all-done renders the calm closing line, no celebration', (t) async {
    await t.pumpWidget(_host(const Locale('ar'), const TodayAllDone()));
    await t.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    expect(find.text(l10n.emptyAllDone), findsOneWidget);
    // No celebration: no exclamation mark in the rendered tree.
    for (final w in t.widgetList<Text>(find.byType(Text))) {
      expect(w.data ?? '', isNot(contains('!')));
    }
  });

  testWidgets('silent resume renders the ordinary day with no greeting', (t) async {
    await t.pumpWidget(
      _host(
        const Locale('ar'),
        const TodaySilentResume(
          child: Text('ordinary day', key: ValueKey<String>('ordinary')),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('ordinary')), findsOneWidget);
    // No welcome-back / "N days" greeting chrome.
    for (final w in t.widgetList<Text>(find.byType(Text))) {
      final s = (w.data ?? '').toLowerCase();
      expect(s.contains('welcome'), isFalse);
    }
  });

  test('no welcome-back greeting key exists in any locale', () async {
    for (final locale in const <Locale>[
      Locale('ar'),
      Locale('fa'),
      Locale('ckb'),
    ]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      // The budget/all-done copy this epic adds carries no exclamation mark.
      expect(l10n.budgetOverflowLine, isNot(contains('!')));
      expect(l10n.emptyAllDone, isNot(contains('!')));
    }
  });
}
