// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T02 — the reusable WCAG gate the per-component tasks and T10 call: the
// meetsLibraryGuidelines set (tap target / labeled / contrast) and the
// assertColorIndependent redundant-encoding check, proven here on reference
// specimens so T03–T10 inherit a working gate rather than re-deriving one. Real
// bundled fonts are loaded so the contrast guideline measures truthfully.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../support/golden_matrix.dart';
import '../support/offline_test_bootstrap.dart';

Widget _refButtons(MihrabAppearance appearance) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ckb'), // the longest transcreation / RTL
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(appearance),
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(onPressed: () {}, child: Text(l10n.gradeGood)),
                const SizedBox(height: 16),
                FilledButton(onPressed: () {}, child: Text(l10n.gradeEasy)),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  useOfflineTestPolicy();

  setUpAll(loadMihrabUiFonts);

  for (final appearance in MihrabAppearance.values) {
    testWidgets(
        'meetsLibraryGuidelines passes on reference (${appearance.name})',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_refButtons(appearance));
      await tester.pumpAndSettle();
      await meetsLibraryGuidelines(tester);
      handle.dispose();
    });
  }

  testWidgets('assertColorIndependent finds the redundant label + glyph',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: const Scaffold(
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline),
                SizedBox(width: 8),
                Text('solid'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // The meaning is carried by a glyph + a label, not color alone — so it
    // survives a grayscale/deuteranope render (the T03/T04 check, exercised).
    assertColorIndependent(
      tester,
      labels: const ['solid'],
      icons: const [Icons.check_circle_outline],
    );
  });
}
