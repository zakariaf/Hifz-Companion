// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E15 Progress screen: the welcoming empty state on a fresh profile, the
// populated heat-map overview (juz roll-up tiles), and the no-scoreboard adab
// (no streak/trophy/score iconography anywhere). Offline guard installed; real
// Mihrab UI fonts loaded for honest layout.

import 'package:engine/engine.dart' show RetentionBand;
import 'package:features/features.dart'
    show
        HeatmapCell,
        JuzSummary,
        MihrabAppearance,
        PageHealth,
        ProgressOverview,
        ProgressScreen,
        mihrabThemeFor,
        progressHeatmapProvider,
        upcomingLoadProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../support/offline_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  Future<AppLocalizations> l10nAr() =>
      AppLocalizations.delegate.load(const Locale('ar'));

  Future<void> pump(WidgetTester tester, ProgressOverview overview) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressHeatmapProvider.overrideWith((ref) => Stream.value(overview)),
            upcomingLoadProvider.overrideWith((ref) => Stream.value(0)),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: hifzLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: mihrabThemeFor(MihrabAppearance.light),
            // The screen is a tab body; HomeShell supplies the Scaffold in-app.
            home: const Scaffold(body: ProgressScreen()),
          ),
        ),
      );

  testWidgets('a fresh profile (no held pages) shows the welcoming empty state',
      (tester) async {
    await pump(tester, const ProgressOverview.empty());
    await tester.pumpAndSettle();
    final l10n = await l10nAr();
    expect(find.text(l10n.progressEmptyTitle), findsOneWidget);
  });

  testWidgets('a populated overview renders the juz heat-map tiles',
      (tester) async {
    const overview = ProgressOverview(
      juzSummaries: [
        JuzSummary(
          juz: 1,
          rollUp: RetentionBand.weak,
          weakestPageId: 3,
          pages: [
            PageHealth(
              pageId: 1,
              juz: 1,
              memorized: true,
              retrievability: 0.97,
              band: RetentionBand.strong,
              everReviewed: true,
              sourceConfidence: 1,
            ),
            PageHealth(
              pageId: 3,
              juz: 1,
              memorized: true,
              retrievability: 0.72,
              band: RetentionBand.weak,
              everReviewed: true,
              sourceConfidence: 0.5,
            ),
          ],
        ),
      ],
    );
    await pump(tester, overview);
    await tester.pumpAndSettle();
    final l10n = await l10nAr();
    // The overview rendered (heat-map tiles present), not the empty state.
    expect(find.text(l10n.progressEmptyTitle), findsNothing);
    expect(find.byType(HeatmapCell), findsWidgets);
  });

  testWidgets('no scoreboard: no streak/trophy/score iconography', (tester) async {
    await pump(tester, const ProgressOverview.empty());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(find.byIcon(Icons.emoji_events), findsNothing);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.byIcon(Icons.celebration), findsNothing);
  });
}
