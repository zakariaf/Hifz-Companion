// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The teacher-sourced marker renders shape + label (never color alone) on a
// teacher-signed row; a self-sourced row shows no marker. The marker copy
// credits the teacher (no app-as-authority), with no exclamation/celebration.

import 'package:engine/engine.dart' show Card, CalendarDate, ReviewTrack;
import 'package:features/features.dart'
    show
        DailySessionList,
        MihrabAppearance,
        TeacherSourcedMarker,
        TodaySession,
        mihrabThemeFor;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

Card signedFar(int pageId) => Card(
      profileId: kTestProfile,
      pageId: pageId,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 200,
      lastReviewedDay: CalendarDate.ymd(2026, 4, 1),
      dueAt: kToday,
      signoffs: 1,
    );

void main() {
  useOfflineTestPolicy();

  Future<void> pumpList(WidgetTester tester, TodaySession session) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: DailySessionList(
            session: session,
            juzOf: (_) => 1,
            onOpen: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a teacher-signed row shows the marker with its label', (t) async {
    await pumpList(t, TodaySession(far: [signedFar(10)]));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.byType(TeacherSourcedMarker), findsOneWidget);
    expect(find.text(l10n.stateSignedOff), findsOneWidget);
    // Shape + label, not color alone: a glyph accompanies the label.
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });

  testWidgets('a self-sourced row shows no marker', (t) async {
    await pumpList(t, TodaySession(far: [dueFar(10)]));
    expect(find.byType(TeacherSourcedMarker), findsNothing);
  });

  test('the sign-off copy credits the teacher, never the app', () async {
    for (final locale in const <Locale>[
      Locale('ar'),
      Locale('fa'),
      Locale('ckb'),
    ]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final s in <String>[
        l10n.stateSignedOff,
        l10n.teacherSignoffLabel,
        l10n.teacherSignoffSupporting,
      ]) {
        expect(s.contains('!'), isFalse);
        final lower = s.toLowerCase();
        expect(lower.contains('approved'), isFalse);
        expect(lower.contains('passed'), isFalse);
      }
    }
  });
}
