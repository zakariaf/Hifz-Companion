// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The catch-up banner renders the engine's pre-built re-spread in the order
// empathy → honest fact → plan → choice, keeps every FAR/manzil row, stays calm
// (no red/alarm, no greeting), and ends in three user-owned choices that fire
// their callbacks (start/adjust/defer) — the View computes no spread.

import 'package:engine/engine.dart' show Card;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MihrabPageCard,
        TodayCatchUp,
        TodayCatchUpBanner,
        mihrabThemeFor;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  Future<({int start, int adjust, int defer})> pump(
    WidgetTester tester,
    TodayCatchUp catchUp,
  ) async {
    final counts = <String, int>{'start': 0, 'adjust': 0, 'defer': 0};
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: TodayCatchUpBanner(
            catchUp: catchUp,
            juzOf: (pageId) => (pageId ~/ 20) + 1,
            onStart: () => counts['start'] = counts['start']! + 1,
            onAdjust: () => counts['adjust'] = counts['adjust']! + 1,
            onDefer: () => counts['defer'] = counts['defer']! + 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (start: counts['start']!, adjust: counts['adjust']!, defer: counts['defer']!);
  }

  TodayCatchUp plan({List<Card>? items}) => TodayCatchUp(
        missedDays: 3,
        planDays: 5,
        items: items ?? [dueFar(10), dueFar(11)],
      );

  testWidgets('renders empathy → fact → plan → choice in order', (t) async {
    await pump(t, plan());
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    final empathyY = t.getTopLeft(find.text(l10n.catchUpEmpathy)).dy;
    final factY = t.getTopLeft(find.text(l10n.catchUpMissedDays(3))).dy;
    final choiceY = t.getTopLeft(find.text(l10n.catchUpStartPlan)).dy;
    expect(empathyY, lessThan(factY));
    expect(factY, lessThan(choiceY));
  });

  testWidgets('renders every FAR row from the plan, on a calm surface', (t) async {
    await pump(t, plan(items: [dueFar(10), dueFar(11), dueFar(12)]));
    // All three plan rows render (the engine's order, none elided).
    expect(find.byType(MihrabPageCard), findsNWidgets(3));
    // Calm register — no error/alarm iconography.
    expect(find.byIcon(Icons.warning), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);
  });

  testWidgets('the three user-owned choices fire their callbacks', (t) async {
    final counts = await pumpAndTap(t, plan());
    expect(counts, (start: 1, adjust: 1, defer: 1));
  });

  testWidgets('greets nothing — no welcome-back chrome', (t) async {
    await pump(t, plan());
    for (final w in t.widgetList<Text>(find.byType(Text))) {
      expect((w.data ?? '').toLowerCase().contains('welcome'), isFalse);
    }
  });
}

Future<({int start, int adjust, int defer})> pumpAndTap(
  WidgetTester tester,
  TodayCatchUp catchUp,
) async {
  final counts = <String, int>{'start': 0, 'adjust': 0, 'defer': 0};
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(
        body: TodayCatchUpBanner(
          catchUp: catchUp,
          juzOf: (pageId) => 1,
          onStart: () => counts['start'] = counts['start']! + 1,
          onAdjust: () => counts['adjust'] = counts['adjust']! + 1,
          onDefer: () => counts['defer'] = counts['defer']! + 1,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
  await tester.tap(find.text(l10n.catchUpStartPlan));
  await tester.tap(find.text(l10n.catchUpAdjust));
  await tester.tap(find.text(l10n.catchUpDefer));
  await tester.pumpAndSettle();
  return (start: counts['start']!, adjust: counts['adjust']!, defer: counts['defer']!);
}
