// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The cold-start → first-day journey (E11-T09), end to end through the real
// HifzApp on the real Drift/SQLite stack: a fresh device lands on onboarding;
// the captured placement commits through the single seedColdStart transaction
// (coldStartCard per held page); the active profile flips ONLY after the durable
// commit; the router lands on Today with real engine-selected due pages; grading
// one routes through the write path and the queue re-emits with that page
// rescheduled out. The per-step UI is widget-tested in packages/features; here we
// drive the capture controller programmatically to exercise commit → real DB →
// first day. The radio stays off (a throwing HttpOverrides). The real reference
// pack is E11-T04's bundled install; a minimal fixture stands in so a held juz
// expands to real page cards.

import 'package:app/app.dart';
import 'package:composition/composition.dart';
import 'package:data/testing.dart';
import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:features/features.dart'
    show
        CyclePreset,
        OnboardingScreen,
        PageCard,
        TodayScreen,
        onboardingControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  useOfflineTestPolicy();

  testWidgets('cold start → seed commit → Today → grade re-emits',
      (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    // The real reference pack is E11-T04's bundled install; seed a minimal
    // fixture so juz 1 expands to real page cards (the card → page foreign key).
    await seedReferenceFixture(
      handle,
      pagesByJuz: const {
        1: [1, 2, 3],
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(handle),
          todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 22)),
        ],
        child: const HifzApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. A fresh device is held at onboarding by the redirect guard.
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // 2. Capture a held + rated juz and a named cycle, then commit. (The per-step
    //    UI taps are covered by the widget suites; the journey drives the
    //    controller to exercise the commit → real-DB → first-day path.)
    final container = ProviderScope.containerOf(
      tester.element(find.byType(OnboardingScreen)),
    );
    final ctrl = container.read(onboardingControllerProvider(null).notifier)
      ..setLocale(const Locale('fa'))
      ..toggleJuz(1)
      ..setJuzConfidence(1, JuzConfidence.solid)
      ..setCyclePreset(CyclePreset.weeklyKhatm)
      ..setDailyBudget(30);
    await ctrl.commitAndBuildFirstDay();
    await tester.pumpAndSettle();

    // 3. The seed committed, the profile flipped, and the guard landed on Today
    //    with real engine-selected due pages.
    expect(find.byType(TodayScreen), findsOneWidget);
    final pagesBefore = tester.widgetList(find.byType(PageCard)).length;
    expect(pagesBefore, greaterThan(0));

    // 4. Grade the first due page Good → it routes through the single write path,
    //    the queue re-emits, and the rescheduled page leaves today's list.
    await tester.tap(find.byKey(const ValueKey('grade.good')).first);
    await tester.pumpAndSettle();
    final pagesAfter = tester.widgetList(find.byType(PageCard)).length;
    expect(pagesAfter, lessThan(pagesBefore));
  });
}
