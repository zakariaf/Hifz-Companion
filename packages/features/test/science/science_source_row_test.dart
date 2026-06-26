// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Non-golden widget coverage for the science source row: the grade survives as
// TEXT (never a star/percentage/colour-only), the [TRAD] row shows its
// needs-review note, the external link routes through the callback with NO
// in-app network (throwing HttpOverrides), and the row reflows at 200% text.

import 'package:features/features.dart' show MihrabAppearance, mihrabThemeFor;
import 'package:features/src/science/claim_row.dart';
import 'package:features/src/science/claims_register.dart';
import 'package:features/src/science/widgets/science_source_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show loadRealUiFonts;
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  ClaimRow claim(String id) => claimsRegister.firstWhere((r) => r.id == id);

  Future<AppLocalizations> l10nFor(Locale l) => AppLocalizations.delegate.load(l);

  Future<void> pumpRow(
    WidgetTester tester, {
    required ClaimRow row,
    Locale locale = const Locale('ar'),
    void Function(String url)? onOpen,
    double textScale = 1.0,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: ListView(
            children: [
              ScienceSourceRow(
                claim: row,
                initiallyExpanded: true,
                onOpenSource: onOpen ?? (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('[MA] grade is conveyed as words, never a star/percentage',
      (tester) async {
    final l10n = await l10nFor(const Locale('ar'));
    await pumpRow(tester, row: claim('C-006')); // [MA]
    // The grade reads as a confidence phrase (text), not colour/stars.
    expect(find.text(l10n.certaintyMaPhrase), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);
    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      final data = w.data ?? '';
      expect(data.contains('%'), isFalse, reason: 'no retention percentage');
      expect(data.contains('★'), isFalse, reason: 'no star rating');
    }
  });

  testWidgets('[TRAD] row shows its needs-scholarly-review note', (tester) async {
    final l10n = await l10nFor(const Locale('ar'));
    await pumpRow(tester, row: claim('C-035')); // [TRAD] decay hadith
    expect(find.text(l10n.scienceNeedsReview), findsOneWidget);
    expect(find.text(l10n.certaintyTradPhrase), findsWidgets);
  });

  testWidgets('tapping a source link routes through the callback, no network',
      (tester) async {
    final opened = <String>[];
    final row = claim('C-006');
    await pumpRow(tester, row: row, onOpen: opened.add);
    // The throwing HttpOverrides (offline policy) is installed; a tap must not
    // open a socket — it hands the URL to the injected launcher callback.
    await tester.tap(find.byIcon(Icons.open_in_new).first);
    await tester.pump();
    expect(opened, isNotEmpty);
    expect(opened.first, row.sources.first.url);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reflows at 200% text scale with no overflow (ckb, the longest)',
      (tester) async {
    await pumpRow(
      tester,
      row: claim('C-041'), // the longest claim (no-streaks/guilt)
      locale: const Locale('ckb'),
      textScale: 2.0,
    );
    expect(tester.takeException(), isNull);
  });
}
