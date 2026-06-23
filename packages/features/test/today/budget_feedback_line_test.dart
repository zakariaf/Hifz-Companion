// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The honest budget-feedback line: one calm informational line + three
// autonomy-supportive choices that navigate (never mutate), on a flat surface
// with no red/alarm. The FAR section stays fully present alongside it.

import 'package:composition/composition.dart';
import 'package:features/features.dart'
    show
        BudgetFeedbackLine,
        MihrabAppearance,
        TodayScreen,
        TodaySession,
        mihrabThemeFor,
        pageJuzProvider,
        todaySessionProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> l10nAr() =>
      AppLocalizations.delegate.load(const Locale('ar'));

  testWidgets('renders one calm line + three ≥48dp choices, no alarm', (t) async {
    var raise = 0;
    var lengthen = 0;
    var pause = 0;
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: BudgetFeedbackLine(
            onRaiseBudget: () => raise++,
            onLengthenCycle: () => lengthen++,
            onPauseNewSabaq: () => pause++,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final l10n = await l10nAr();

    expect(find.text(l10n.budgetOverflowLine), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);

    for (final key in const <String>['budget.raise', 'budget.lengthen', 'budget.pause']) {
      final size = t.getSize(find.byKey(ValueKey<String>(key)));
      expect(size.height, greaterThanOrEqualTo(48.0), reason: '$key < 48dp');
    }

    await t.tap(find.byKey(const ValueKey<String>('budget.raise')));
    await t.tap(find.byKey(const ValueKey<String>('budget.lengthen')));
    await t.tap(find.byKey(const ValueKey<String>('budget.pause')));
    expect([raise, lengthen, pause], [1, 1, 1]);
  });

  testWidgets('overflow shows the line WITH the Far section still present',
      (t) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(kTestProfile),
          todayProvider.overrideWithValue(kToday),
          pageJuzProvider.overrideWith((ref) async => const <int, int>{}),
          todaySessionProvider.overrideWith(
            (ref) => Stream.value(
              TodaySession(far: [dueFar(10), dueFar(11)], budgetOverflow: true),
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const Scaffold(body: TodayScreen()),
        ),
      ),
    );
    await t.pumpAndSettle();
    final l10n = await l10nAr();

    // The budget line renders, and every seeded Far row is still present.
    expect(find.text(l10n.budgetOverflowLine), findsOneWidget);
    expect(find.byKey(const ValueKey<int>(10)), findsOneWidget);
    expect(find.byKey(const ValueKey<int>(11)), findsOneWidget);
  });
}
