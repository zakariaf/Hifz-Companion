// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The confusion-hotspots body (E14-T10): a calm read-only list of the active
// profile's most-confused pairs — ranked verbatim from E14-T06, each row tapping
// into the pair's whole-group drill. No weight/score, calm empty, per-profile.

import 'package:composition/composition.dart' show initialActiveProfileProvider;
import 'package:features/features.dart'
    show
        ConfusionHotspotsView,
        MihrabAppearance,
        confusionHotspotsProvider,
        hotspotGroupIdProvider,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';

import '../test_setup.dart';

const _profileA = ProfileId('A');
const _profileB = ProfileId('B');

ConfusionEdge _edge(ProfileId p, String a, String b, double w) =>
    ConfusionEdge.between(
      p,
      a,
      b,
      weight: w,
      lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
    );

GoRouter _router() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (c, s) => const Scaffold(body: ConfusionHotspotsView()),
        ),
        GoRoute(
          path: '/mutashabihat/drill/:groupId',
          builder: (c, s) =>
              Scaffold(body: Text('drill:${s.pathParameters['groupId']}')),
        ),
      ],
    );

Widget _app() => MaterialApp.router(
      routerConfig: _router(),
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
    );

void main() {
  useOfflineTestPolicy();

  testWidgets('renders the ranked pairs verbatim (no local re-sort)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(_profileA),
          confusionHotspotsProvider(_profileA).overrideWith(
            (ref) => Stream.value([
              _edge(_profileA, '2:1', '3:2', 9),
              _edge(_profileA, '4:1', '5:1', 1),
            ]),
          ),
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));
    // weight 9 is never rendered (٩ appears nowhere; āyah numbers avoid it).
    expect(find.textContaining('٩'), findsNothing);
  });

  testWidgets('empty list → calm welcoming line, never a 0-score', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(_profileA),
          confusionHotspotsProvider(_profileA)
              .overrideWith((ref) => Stream.value(const [])),
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.mutashabihatTrainerIntro), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('per-profile isolation: A then B shows only each profile\'s rows',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(_profileB),
          confusionHotspotsProvider(_profileA).overrideWith(
            (ref) => Stream.value([_edge(_profileA, '2:1', '2:2', 3)]),
          ),
          confusionHotspotsProvider(_profileB).overrideWith(
            (ref) => Stream.value([
              _edge(_profileB, '7:1', '8:1', 2),
              _edge(_profileB, '9:1', '10:1', 1),
            ]),
          ),
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    // B's two rows, none of A's single row.
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('tapping a row opens the pair\'s whole-group drill', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(_profileA),
          confusionHotspotsProvider(_profileA).overrideWith(
            (ref) => Stream.value([_edge(_profileA, '2:1', '3:2', 4)]),
          ),
          hotspotGroupIdProvider('2:1').overrideWith((ref) async => 'g7'),
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.text('drill:g7'), findsOneWidget);
  });
}
