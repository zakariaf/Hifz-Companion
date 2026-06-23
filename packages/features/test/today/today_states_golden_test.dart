// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E12-T09 — per-locale (ar/fa/ckb) goldens of every Today state on the REAL
// bundled UI font: loading skeleton, populated Far→Near→New, calm all-done,
// catch-up banner, and the honest budget-feedback line. Over in-memory Riverpod
// fakes (the controller's session set to each variant). RTL geometry, locale
// numerals, ckb reflow. Linux golden lane verifies; masters regenerate via
// `--update-goldens`.

import 'dart:async';

import 'package:composition/composition.dart';
import 'package:features/features.dart'
    show
        MihrabAppearance,
        TodayCatchUp,
        TodayScreen,
        TodaySession,
        mihrabThemeFor,
        pageJuzProvider,
        todaySessionProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  final populated = TodaySession(
    far: [dueFar(253), dueFar(120)],
    near: [dueNear(45)],
    newSabaq: [dueNew(8)],
  );
  final budget = TodaySession(far: [dueFar(253), dueFar(120)], budgetOverflow: true);
  final catchUp = TodaySession(
    far: [dueFar(253)],
    catchUp: TodayCatchUp(missedDays: 3, planDays: 5, items: [dueFar(253), dueNear(45)]),
  );

  final states = <String, Stream<TodaySession>>{
    'populated': Stream<TodaySession>.value(populated),
    'all_done': Stream<TodaySession>.value(const TodaySession.empty()),
    'catch_up': Stream<TodaySession>.value(catchUp),
    'budget_feedback': Stream<TodaySession>.value(budget),
  };

  Future<void> pump(
    WidgetTester tester,
    Locale locale,
    Stream<TodaySession> session,
  ) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(420, 1100) * 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(kTestProfile),
          todayProvider.overrideWithValue(kToday),
          pageJuzProvider.overrideWith((ref) async => const <int, int>{}),
          todaySessionProvider.overrideWith((ref) => session),
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
    await tester.pumpAndSettle();
  }

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('today loading ($code)', (tester) async {
      final controller = StreamController<TodaySession>();
      addTearDown(controller.close);
      await pump(tester, locale, controller.stream);
      await tester.pump();
      await expectLater(
        find.byType(TodayScreen),
        matchesGoldenFile('goldens/today_state_loading__$code.png'),
      );
    });

    for (final entry in states.entries) {
      testWidgets('today ${entry.key} ($code)', (tester) async {
        await pump(tester, locale, entry.value);
        await expectLater(
          find.byType(TodayScreen),
          matchesGoldenFile('goldens/today_state_${entry.key}__$code.png'),
        );
      });
    }
  }
}
