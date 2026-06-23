// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E12-T05 — per-locale (ar/fa/ckb) golden of the catch-up state on the REAL
// bundled UI font: empathy → honest fact → M-day plan → choices, the engine's
// re-spread rows (incl. a mandatory FAR row), calm surfaceContainer (no red/
// alarm), locale numerals on missed/plan days, ckb reflow. Linux golden lane
// verifies; masters regenerate via `--update-goldens`.

import 'package:features/features.dart'
    show MihrabAppearance, TodayCatchUp, TodayCatchUpBanner, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  final catchUp = TodayCatchUp(
    missedDays: 3,
    planDays: 5,
    items: [dueFar(253), dueNear(45)],
  );

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    testWidgets('catch-up banner ($code)', (tester) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(420, 900) * 2.0;
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
            body: SafeArea(
              child: TodayCatchUpBanner(
                catchUp: catchUp,
                juzOf: (pageId) => (pageId ~/ 20) + 1,
                onStart: () {},
                onAdjust: () {},
                onDefer: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodayCatchUpBanner),
        matchesGoldenFile('goldens/catch_up_banner__$code.png'),
      );
    });
  }
}
