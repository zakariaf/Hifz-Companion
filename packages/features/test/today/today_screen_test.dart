// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The dumb Today View renders the controller's calm states — loading skeleton,
// error retry, calm all-done close, and the populated-day slot — driven by
// overriding the upstream todaySessionProvider (never the notifier). No DB/engine.

import 'dart:async';

import 'package:composition/composition.dart';
import 'package:features/features.dart'
    show
        MihrabAppearance,
        TodayScreen,
        TodaySession,
        mihrabThemeFor,
        todaySessionProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  // Drives the controller via the upstream session stream; [withProfile] gates
  // the active-profile branch (false ⇒ activeProfileProvider stays null).
  Future<void> pump(
    WidgetTester tester,
    Stream<TodaySession> sessions, {
    bool withProfile = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (withProfile)
            initialActiveProfileProvider.overrideWithValue(kTestProfile),
          todayProvider.overrideWithValue(kToday),
          todaySessionProvider.overrideWith((ref) => sessions),
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
  }

  testWidgets('loading shows the calm skeleton, not a spinner-of-shame',
      (t) async {
    final controller = StreamController<TodaySession>();
    addTearDown(controller.close);
    await pump(t, controller.stream);
    await t.pump();
    expect(find.byKey(const ValueKey<String>('today.loading')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('error shows the calm retry view', (t) async {
    final controller = StreamController<TodaySession>();
    addTearDown(controller.close);
    await pump(t, controller.stream);
    await t.pump();
    controller.addError(Exception('read failed'));
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey<String>('today.error')), findsOneWidget);
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.commonRetry), findsOneWidget);
  });

  testWidgets('empty day shows the calm all-done close', (t) async {
    await pump(t, Stream<TodaySession>.value(const TodaySession.empty()));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('today.allDone')), findsOneWidget);
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.emptyAllDone), findsOneWidget);
  });

  testWidgets('a non-empty day reaches the populated slot', (t) async {
    await pump(
      t,
      Stream<TodaySession>.value(
        TodaySession(far: [dueFar(3)], near: [dueNear(4)]),
      ),
    );
    await t.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('today.populated')),
      findsOneWidget,
    );
  });

  testWidgets('exposes the "Revise today" Semantics container', (t) async {
    await pump(t, Stream<TodaySession>.value(const TodaySession.empty()));
    await t.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.bySemanticsLabel(l10n.todaySemanticTitle), findsWidgets);
  });

  testWidgets('no active profile resolves to the all-done close', (t) async {
    await pump(
      t,
      Stream<TodaySession>.value(const TodaySession.empty()),
      withProfile: false,
    );
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('today.allDone')), findsOneWidget);
  });
}
