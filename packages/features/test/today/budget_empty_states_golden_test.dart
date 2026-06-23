// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E12-T04 — per-locale (ar/fa/ckb) goldens of the honest budget-feedback line,
// the calm all-done close, and the silent-resume body, on the REAL bundled UI
// font: RTL geometry, no red/alarm fill, no celebration, ckb reflow. Linux
// golden lane verifies; masters regenerate via `--update-goldens`.

import 'package:features/features.dart'
    show
        BudgetFeedbackLine,
        MihrabAppearance,
        TodayAllDone,
        TodaySilentResume,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  Future<void> pump(WidgetTester tester, Locale locale, Widget child) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(420, 600) * 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: SafeArea(child: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  final surfaces = <String, Widget>{
    'budget': BudgetFeedbackLine(
      onRaiseBudget: () {},
      onLengthenCycle: () {},
      onPauseNewSabaq: () {},
    ),
    'all_done': const TodayAllDone(),
    'silent_resume': const TodaySilentResume(child: TodayAllDone()),
  };

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    for (final entry in surfaces.entries) {
      testWidgets('today ${entry.key} ($code)', (tester) async {
        await pump(tester, locale, entry.value);
        await expectLater(
          find.byType(Scaffold),
          // `today_es_*` (empty-states) — distinct from today_golden_test's
          // `today_all_done`/`today_loading` (same dir) to avoid a master clash.
          matchesGoldenFile('goldens/today_es_${entry.key}__$code.png'),
        );
      });
    }
  }
}
