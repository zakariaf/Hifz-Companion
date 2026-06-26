// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// Per-locale (ar/fa/ckb) RTL goldens of the science source row — an [MA] row and
// a [TRAD] row — expanded to show the evidence (named source, the confidence
// grade as words + non-colour glyph, the [TRAD] needs-review note), on the REAL
// bundled UI font (Vazirmatn, never Ahem). The Linux golden lane verifies;
// masters regenerate via the `[update-goldens]` lane, never blessed by CI.
// (ckb is the longest transcreation — the reflow stress.)

import 'package:features/features.dart' show MihrabAppearance, mihrabThemeFor;
import 'package:features/src/science/claim_row.dart';
import 'package:features/src/science/claims_register.dart';
import 'package:features/src/science/widgets/science_source_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  ClaimRow claim(String id) => claimsRegister.firstWhere((r) => r.id == id);

  Future<void> pumpRow(
    WidgetTester tester,
    ClaimRow row,
    Locale locale,
  ) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(420, 900) * 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: ListView(
            children: [
              ScienceSourceRow(
                claim: row,
                initiallyExpanded: true,
                onOpenSource: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in a11yLocales) {
    for (final (name, id) in const [('ma', 'C-006'), ('trad', 'C-035')]) {
      testWidgets('science source row · ${locale.languageCode} · $name golden',
          (tester) async {
        await pumpRow(tester, claim(id), locale);
        await expectLater(
          find.byType(ScienceSourceRow),
          matchesGoldenFile(
            'goldens/science_source_row__${locale.languageCode}__$name.png',
          ),
        );
      });
    }
  }
}
