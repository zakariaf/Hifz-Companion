// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E08-T06: pins the five state chips (track ×3, due, weak, sign-off, decay) per
// locale on the REAL bundled fonts (never Ahem), so the grayscale-surviving
// shape + the localized label/number channels are visible and a recolour or a
// dropped shape changes pixels. Pinned Linux golden lane.

import 'package:features/features.dart'
    show ChipState, MihrabAppearance, StateChip, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '_a11y_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();

  setUpAll(loadRealUiFonts);

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    testWidgets('state chips golden ($code)', (tester) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(600, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  for (final state in ChipState.values) StateChip(state: state),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/state_chips__$code.png'),
      );
    });
  }
}
