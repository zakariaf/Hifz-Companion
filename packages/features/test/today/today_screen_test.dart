// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The Today View renders the queue's states: a calm empty line when nothing is
// due, and the due pages as a list. Driven by overriding todayQueueProvider so
// no DB/engine is needed.

import 'package:engine/engine.dart' show CalendarDate, Card, ReviewTrack;
import 'package:features/features.dart'
    show MihrabAppearance, TodayScreen, mihrabThemeFor, todayQueueProvider;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

Card dueFar(int pageId) => Card(
      profileId: const ProfileId('p1'),
      pageId: pageId,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 30,
      lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
      dueAt: CalendarDate.ymd(2026, 6, 19),
    );

void main() {
  useOfflineTestPolicy();

  Future<void> pumpToday(WidgetTester tester, List<Card> queue) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayQueueProvider.overrideWith((ref) => Stream.value(queue)),
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
    await tester.pumpAndSettle();
  }

  testWidgets('renders the calm empty line when nothing is due', (t) async {
    await pumpToday(t, const <Card>[]);
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.todayEmpty), findsOneWidget);
  });

  testWidgets('renders one row per due page', (t) async {
    await pumpToday(t, [dueFar(3), dueFar(4)]);
    expect(find.byKey(const ValueKey<int>(3)), findsOneWidget);
    expect(find.byKey(const ValueKey<int>(4)), findsOneWidget);
  });
}
