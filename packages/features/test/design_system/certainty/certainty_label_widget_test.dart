// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T06 — the neutral badge: one identical container for every grade (the
// non-traffic-light guard), strength carried by TEXT with a Semantics prefix,
// non-interactive (no tap/focus), and the legend with no star key.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

Widget _host(
  Widget Function(CertaintyStrings strings, AppLocalizations l10n) build, {
  MihrabAppearance appearance = MihrabAppearance.light,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(appearance),
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(body: build(CertaintyStrings.of(l10n), l10n));
      },
    ),
  );
}

Color _fill(WidgetTester tester) {
  final box = tester.widget<Container>(
    find.descendant(
      of: find.byType(CertaintyLabel),
      matching: find.byType(Container),
    ),
  );
  return (box.decoration! as ShapeDecoration).color!;
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('renders the phrase as text with a Semantics prefix',
      (tester) async {
    await tester.pumpWidget(
      _host((s, l10n) => CertaintyLabel(grade: EvidenceGrade.ma, strings: s)),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.certaintyMaPhrase), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '${l10n.certaintyEvidencePrefix}${l10n.certaintyMaPhrase}',
      ),
      findsWidgets,
    );
  });

  testWidgets('non-interactive — no tap target, no focus ring', (tester) async {
    await tester.pumpWidget(
      _host((s, l10n) => CertaintyLabel(grade: EvidenceGrade.trad, strings: s)),
    );
    expect(
      find.descendant(
        of: find.byType(CertaintyLabel),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    expect(find.byType(MihrabFocusRing), findsNothing);
  });

  testWidgets('one neutral container — same fill for ma, obs, and trad',
      (tester) async {
    await tester.pumpWidget(
      _host((s, l10n) => CertaintyLabel(grade: EvidenceGrade.ma, strings: s)),
    );
    final maFill = _fill(tester);
    await tester.pumpWidget(
      _host((s, l10n) => CertaintyLabel(grade: EvidenceGrade.obs, strings: s)),
    );
    expect(_fill(tester), maFill, reason: 'never colour-by-grade');
    await tester.pumpWidget(
      _host((s, l10n) => CertaintyLabel(grade: EvidenceGrade.trad, strings: s)),
    );
    expect(_fill(tester), maFill, reason: 'trad is not a special colour');
  });

  testWidgets('the legend lists every distinct phrase, no star key',
      (tester) async {
    await tester.pumpWidget(
      _host(
        (s, l10n) =>
            CertaintyLegend(strings: s, title: l10n.certaintyLegendTitle),
      ),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.certaintyLegendTitle), findsOneWidget);
    for (final phrase in [
      l10n.certaintyMaPhrase,
      l10n.certaintyRctExpPhrase,
      l10n.certaintyCsPhrase,
      l10n.certaintyObsPhrase,
      l10n.certaintyTextPhrase,
      l10n.certaintyTradPhrase,
    ]) {
      expect(find.text(phrase), findsOneWidget);
    }
    expect(find.textContaining('★'), findsNothing);
  });

  testWidgets('meetsLibraryGuidelines — labeled + text contrast',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host((s, l10n) => CertaintyLabel(grade: EvidenceGrade.obs, strings: s)),
    );
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });
}
