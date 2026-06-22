// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Skip(
  'E07 spine journey: the onboarding flow it drives (coverage→confidence→Done) '
  'is rebuilt by E11-T01 into the full §12.1 sequence; the cold-start→first-day '
  'journey is re-established over the full flow in E11-T09.',
)
library;

// The E07 walking-skeleton spine, end to end through the real HifzApp: a fresh
// device lands on onboarding → marks a held juz Solid → the seed commits through
// the single write path → the active profile flips and the router lands on Today
// with real engine-selected due pages → grading one routes through the write
// path and the queue re-emits with that page rescheduled out. The radio stays
// off (a throwing HttpOverrides); every step is addressed by a stable widget
// identifier. The real reference pack is the E11 install; a minimal fixture
// stands in so a held juz expands to real page cards.

import 'package:app/app.dart';
import 'package:composition/composition.dart';
import 'package:data/testing.dart';
import 'package:engine/engine.dart' show CalendarDate;
import 'package:features/features.dart'
    show OnboardingScreen, PageCard, TodayScreen;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:l10n/l10n.dart';

import '../test/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  useOfflineTestPolicy();

  testWidgets('seed → Today → grade → the queue re-emits', (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    // The real reference pack is E11's install; seed a minimal fixture so juz 1
    // expands to real page cards (the card → page foreign key).
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
          todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 19)),
        ],
        child: const HifzApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. A fresh device is held at onboarding by the redirect guard.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );

    // 2. Coverage: hold juz 1 (the first grid cell), then continue.
    await tester.tap(
      find
          .descendant(of: find.byType(GridView), matching: find.byType(InkWell))
          .first,
    );
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(FilledButton, l10n.onboardingContinue));
    await tester.pumpAndSettle();

    // 3. Confidence: rate it Solid, then commit the seed.
    await tester.tap(find.text(l10n.confidenceSolid));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, l10n.onboardingDone));
    await tester.pumpAndSettle();

    // 4. The seed committed, the profile flipped, and the guard landed on Today
    //    with real engine-selected due pages.
    expect(find.byType(TodayScreen), findsOneWidget);
    final pagesBefore = tester.widgetList(find.byType(PageCard)).length;
    expect(pagesBefore, greaterThan(0));

    // 5. Grade the first due page Good → it routes through the single write path,
    //    the queue re-emits, and the rescheduled page leaves today's list.
    await tester.tap(find.byKey(const ValueKey('grade.good')).first);
    await tester.pumpAndSettle();
    final pagesAfter = tester.widgetList(find.byType(PageCard)).length;
    expect(pagesAfter, lessThan(pagesBefore));
  });
}
