// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The daily-session list renders the controller's pre-built day as three fixed-
// order sliver sections (Far → Near → New), assembles the E10 page-card rows,
// opens the recite route on a one-tap row, omits empty sections, and announces
// one "Revise today" Semantics container. RTL by geometry; no engine in the View.

import 'dart:io';

import 'package:engine/engine.dart' show ReviewTrack;
import 'package:features/features.dart'
    show DailySessionList, MihrabAppearance, TodaySession, mihrabThemeFor;
import 'package:features/src/l10n/term_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();

  Future<void> pumpList(
    WidgetTester tester,
    TodaySession session, {
    void Function(int pageId)? onOpen,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: DailySessionList(
            session: session,
            juzOf: (pageId) => (pageId ~/ 20) + 1,
            onOpen: onOpen ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the three sections in Far → Near → New order', (t) async {
    await pumpList(
      t,
      TodaySession(far: [dueFar(10)], near: [dueNear(20)], newSabaq: [dueNew(30)]),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    final farY = t.getTopLeft(find.text(trackLabel(l10n, ReviewTrack.far, kDefaultTermSetRegion))).dy;
    final nearY = t.getTopLeft(find.text(trackLabel(l10n, ReviewTrack.near, kDefaultTermSetRegion))).dy;
    final newY = t.getTopLeft(find.text(trackLabel(l10n, ReviewTrack.newPage, kDefaultTermSetRegion))).dy;
    expect(farY, lessThan(nearY));
    expect(nearY, lessThan(newY));
  });

  testWidgets('an empty section renders no orphan header', (t) async {
    await pumpList(t, TodaySession(far: [dueFar(10)], newSabaq: [dueNew(30)]));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(
      find.text(trackLabel(l10n, ReviewTrack.near, kDefaultTermSetRegion)),
      findsNothing,
    );
  });

  testWidgets('a one-tap row opens the recite route with its page id', (t) async {
    int? opened;
    await pumpList(t, TodaySession(far: [dueFar(10)]), onOpen: (p) => opened = p);
    expect(opened, isNull);
    await t.tap(find.byKey(const ValueKey<int>(10)));
    await t.pumpAndSettle();
    expect(opened, 10);
  });

  testWidgets('exposes one "Revise today" Semantics container', (t) async {
    await pumpList(t, TodaySession(far: [dueFar(10)]));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.bySemanticsLabel(l10n.todaySemanticTitle), findsOneWidget);
  });

  test('the list widgets call no engine schedule method and read no clock', () {
    for (final path in const <String>[
      'lib/src/today/widgets/daily_session_list.dart',
      'lib/src/today/widgets/session_section.dart',
    ]) {
      // Strip line/doc comments — the guard checks code, not prose.
      final code = File(path)
          .readAsLinesSync()
          .map((l) => l.contains('//') ? l.substring(0, l.indexOf('//')) : l)
          .join('\n');
      expect(code.contains('buildToday'), isFalse, reason: '$path calls buildToday');
      expect(code.contains('loadBalance'), isFalse, reason: '$path calls loadBalance');
      expect(code.contains('DateTime.now'), isFalse, reason: '$path reads DateTime.now');
    }
  });
}
