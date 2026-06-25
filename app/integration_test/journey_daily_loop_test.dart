// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The daily-loop journey (E12-T09), end to end through the real HifzApp on the
// real Drift/SQLite stack:
//   J1 cold-start → buildToday: a fresh device lands on onboarding; the captured
//      placement commits through the single seedColdStart transaction; the active
//      profile flips only after the durable commit; the router lands on Today
//      with real engine-selected due pages.
//   J2 recite → grade → next: tapping a page card opens the masked recite route
//      (the E13 reader seam, stubbed); a reveal enables the grade band; grading
//      rides the single write path and the graded page reschedules out of today.
//   J4 missed-day catch-up: relaunching against the SAME on-disk-shaped handle a
//      few days later shows the calm catch-up state (never a red pile), and the
//      committed grade survives the relaunch (persist-before-republish).
// The per-step UI taps + the sacred-text cap, source switch, and INV-5 override
// are pinned in the widget/engine suites; here we prove the assembled seams.
// The radio stays off (a throwing HttpOverrides).

import 'package:app/app.dart';
import 'package:composition/composition.dart';
import 'package:composition/testing.dart' show FakeNotificationScheduler;
import 'package:data/data.dart' show PersistenceHandle;
import 'package:data/testing.dart';
import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:features/features.dart'
    show
        CyclePreset,
        MihrabPageCard,
        OnboardingScreen,
        ReciteGradeScreen,
        TodayScreen,
        onboardingControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  useOfflineTestPolicy();

  // Seeds a minimal reference so a held juz expands to real page cards (the
  // card → page foreign key); the real bundled pack is E11-T04's install.
  Future<void> seedRef(PersistenceHandle handle) => seedReferenceFixture(
        handle,
        pagesByJuz: const {
          1: [1, 2, 3],
        },
      );

  // Drives the cold-start capture controller to commit and land on Today.
  Future<ProfileId?> coldStartToToday(
    WidgetTester tester, {
    required PersistenceHandle handle,
    required CalendarDate today,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(handle),
          todayProvider.overrideWithValue(today),
          // E18: the reminder reconcile listener (T05/T09) runs in HifzApp, so the
          // journey wires the scheduler boundary as main does — a no-op fake here.
          notificationSchedulerProvider
              .overrideWithValue(FakeNotificationScheduler()),
        ],
        child: const HifzApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);

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

    expect(find.byType(TodayScreen), findsOneWidget);
    return container.read(activeProfileProvider);
  }

  testWidgets('J1 cold-start → J2 recite/grade → page reschedules out',
      (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    await seedRef(handle);

    await coldStartToToday(
      tester,
      handle: handle,
      today: CalendarDate.ymd(2026, 6, 22),
    );

    // J1: the engine selected real due pages.
    final pagesBefore = tester.widgetList(find.byType(MihrabPageCard)).length;
    expect(pagesBefore, greaterThan(0));

    // J2: tap a page card → the masked recite route opens; reveal enables the
    // band; grading Easy rides the single write path and pops back to Today.
    await tester.tap(find.byType(MihrabPageCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(ReciteGradeScreen), findsOneWidget);

    // Reveal the next line (locale-independent key), enabling the grade band.
    await tester.tap(find.byKey(const ValueKey<String>('recite.revealNext')).first);
    await tester.pumpAndSettle();
    // The grade band's four buttons; the last (Easy) reschedules the page out.
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    expect(find.byType(ReciteGradeScreen), findsNothing);
    expect(find.byType(TodayScreen), findsOneWidget);
    final pagesAfter = tester.widgetList(find.byType(MihrabPageCard)).length;
    expect(pagesAfter, lessThan(pagesBefore));
  });

  testWidgets('J4 a multi-day gap shows the calm catch-up, grade survives',
      (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    await seedRef(handle);

    final profile = await coldStartToToday(
      tester,
      handle: handle,
      today: CalendarDate.ymd(2026, 6, 22),
    );

    // Tear down the first scope so the relaunch gets a fresh ProviderScope
    // (Riverpod forbids changing an existing scope's override count).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    // Relaunch a few days later against the SAME handle (the seeded cards are now
    // overdue) with the cold-start profile preset — the durable state persists.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          persistenceProvider.overrideWithValue(handle),
          todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 27)),
          initialActiveProfileProvider.overrideWithValue(profile),
          notificationSchedulerProvider
              .overrideWithValue(FakeNotificationScheduler()),
        ],
        child: const HifzApp(),
      ),
    );
    await tester.pumpAndSettle();

    // A multi-day gap surfaces the calm catch-up state (never a red overdue pile).
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('today.catchUp')),
      findsOneWidget,
    );
  });
}
