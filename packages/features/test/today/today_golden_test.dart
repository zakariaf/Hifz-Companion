// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E12-T01 — per-locale (ar/fa/ckb) goldens of the Today scaffold's calm shells
// (loading skeleton + empty all-done close) on the REAL bundled UI font
// (Vazirmatn, never Ahem): RTL geometry, the calm surfaceContainerLow skeleton,
// and the all-done closing line with no celebration. The Linux golden lane
// verifies; masters regenerate via `--update-goldens` (the `[update-goldens]`
// CI lane), never blessed by CI. (The populated list / catch-up / recite stage
// goldens land with their surfaces in E12-T03/T05/T07/T09.)

import 'dart:async';

import 'package:engine/engine.dart' show Card;
import 'package:features/features.dart'
    show MihrabAppearance, TodayScreen, mihrabThemeFor, todayQueueProvider;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:composition/composition.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  Future<void> pump(
    WidgetTester tester,
    Locale locale,
    Stream<List<Card>> queue,
  ) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(420, 1000) * 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(kTestProfile),
          todayProvider.overrideWithValue(kToday),
          todayQueueProvider.overrideWith((ref) => queue),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const Scaffold(body: TodayScreen()),
        ),
      ),
    );
  }

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('today loading shell ($code)', (tester) async {
      final controller = StreamController<List<Card>>();
      addTearDown(controller.close);
      await pump(tester, locale, controller.stream);
      await tester.pump();
      await expectLater(
        find.byType(TodayScreen),
        matchesGoldenFile('goldens/today_loading__$code.png'),
      );
    });

    testWidgets('today all-done shell ($code)', (tester) async {
      await pump(tester, locale, Stream<List<Card>>.value(const <Card>[]));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(TodayScreen),
        matchesGoldenFile('goldens/today_all_done__$code.png'),
      );
    });
  }
}
