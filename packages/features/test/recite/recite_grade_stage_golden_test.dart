// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E12-T09 — per-locale (ar/fa/ckb) goldens of the recite/grade stages on the REAL
// bundled UI font: hidden (band disabled, "reveal to grade"), revealing (a line
// revealed + a stumble overlay), grading (band enabled, four verbs in RTL order),
// signed-off (teacher toggle on). Over the STUB reader seam — the masked-vs-
// revealed glyph-fidelity golden on the real KFGQPC page font is DEFERRED to E13
// (the stub renders calm placeholder lines, no glyph). Linux golden lane
// verifies; masters regenerate via `--update-goldens`.

import 'package:engine/engine.dart' show ReviewGrade;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        ReciteGradeBand,
        ReciteSurface,
        mihrabThemeFor,
        reciteControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  // Drives the controller into the named stage.
  void driveStage(ProviderContainer container, String stage) {
    final c = container.read(reciteControllerProvider(42).notifier);
    switch (stage) {
      case 'hidden':
        break;
      case 'revealing':
        c
          ..revealNextLine()
          ..revealNextLine()
          ..toggleStumbleLine(1);
      case 'grading':
        c
          ..revealNextLine()
          ..revealNextLine()
          ..revealNextLine();
      case 'signed_off':
        c
          ..revealNextLine()
          ..setTeacherPresent(present: true);
    }
  }

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    for (final stage in const ['hidden', 'revealing', 'grading', 'signed_off']) {
      testWidgets('recite $stage ($code)', (tester) async {
        tester.view.devicePixelRatio = 2.0;
        tester.view.physicalSize = const Size(420, 1000) * 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = reciteContainer(
          cards: StubCards(reciteCard()),
          reviews: RecordingReviews(),
        );
        addTearDown(container.dispose);
        driveStage(container, stage);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              localizationsDelegates: hifzLocalizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: mihrabThemeFor(MihrabAppearance.light),
              home: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: ReciteSurface(pageId: 42)),
                      ReciteGradeBand(
                        pageId: 42,
                        onGrade: (ReviewGrade _) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/recite_${stage}__$code.png'),
        );
      });
    }
  }
}
