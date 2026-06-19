// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The page card: the page number, a non-interactive track chip, a calm decay
// indicator (a distinct glyph + a screen-reader label, not colour alone), and
// the one-tap grade band that reports the chosen grade.

import 'dart:async';

import 'package:engine/engine.dart'
    show CalendarDate, Card, ReviewGrade, ReviewTrack;
import 'package:features/features.dart'
    show MihrabAppearance, PageCard, mihrabThemeFor;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

Card farCard({bool isWeak = false}) => Card(
      profileId: const ProfileId('p1'),
      pageId: 42,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 30,
      lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
      dueAt: CalendarDate.ymd(2026, 6, 19),
      isWeak: isWeak,
    );

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> pumpCard(
    WidgetTester tester,
    Card card,
    Future<void> Function(ReviewGrade) onGrade,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: PageCard(card: card, onGrade: onGrade)),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('ar'));
  }

  testWidgets('renders the track chip, page number, and four grade buttons',
      (t) async {
    final l10n = await pumpCard(t, farCard(), (_) async {});

    expect(find.text(l10n.trackFarLabel), findsOneWidget);
    expect(find.byKey(const ValueKey('grade.again')), findsOneWidget);
    expect(find.byKey(const ValueKey('grade.hard')), findsOneWidget);
    expect(find.byKey(const ValueKey('grade.good')), findsOneWidget);
    expect(find.byKey(const ValueKey('grade.easy')), findsOneWidget);
  });

  testWidgets('tapping a grade reports the chosen grade', (t) async {
    final taps = <ReviewGrade>[];
    await pumpCard(t, farCard(), (g) async => taps.add(g));

    await t.tap(find.byKey(const ValueKey('grade.good')));
    await t.pumpAndSettle();
    expect(taps, [ReviewGrade.good]);
  });

  testWidgets('a weak page exposes the calm decay label (not colour alone)',
      (t) async {
    final l10n = await pumpCard(t, farCard(isWeak: true), (_) async {});
    expect(find.bySemanticsLabel(l10n.decayNeedsRevision), findsOneWidget);
  });

  testWidgets('the band is disabled while a grade is in flight (no double grade)',
      (t) async {
    final taps = <ReviewGrade>[];
    final gate = Completer<void>();
    await pumpCard(t, farCard(), (g) async {
      taps.add(g);
      await gate.future; // hold the write in flight
    });

    await t.tap(find.byKey(const ValueKey('grade.good')));
    await t.pump(); // _submitting becomes true
    // A second rapid tap (any grade) must be ignored while committing.
    await t.tap(find.byKey(const ValueKey('grade.again')));
    await t.pump();
    expect(taps, [ReviewGrade.good]);

    gate.complete();
    await t.pumpAndSettle();
  });
}
