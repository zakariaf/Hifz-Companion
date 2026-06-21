// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T03 (written first): a clipped button or truncated label at 200% is a
// visible WCAG 1.4.4/1.4.10 defect. Pump the dense shell rows — the page-card
// (track · page · decay) and the four-level grade band — at 200% and an
// AX-extreme scale in each of fa/ckb/ar (ckb the binding longest-string case)
// and assert ZERO RenderFlex/overflow exceptions. This fails on a clipping
// layout before the reflow/clamp fix lands.

import 'package:engine/engine.dart'
    show CalendarDate, Card, ReviewGrade, ReviewTrack;
import 'package:features/features.dart'
    show MihrabAppearance, PageCard, mihrabThemeFor;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

const _locales = [Locale('fa'), Locale('ckb'), Locale('ar')];
// 2.0 = the WCAG 1.4.4 (200%) bar; 3.2 = an iOS AX-extreme size.
const _scales = [2.0, 3.2];

Card _card() => Card(
      profileId: const ProfileId('p1'),
      pageId: 134,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 30,
      lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
      dueAt: CalendarDate.ymd(2026, 6, 19),
      isWeak: true,
    );

Future<void> _pumpAtScale(
  WidgetTester tester,
  Locale locale,
  double scale,
) async {
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        // PageCard lives in a scrolling ListView in production (TodayScreen),
        // so vertical growth scrolls; this asserts there is no *horizontal*
        // overflow / RenderFlex break under scale.
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              children: [PageCard(card: _card(), onGrade: (_) async {})],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  useOfflineTestPolicy();

  for (final locale in _locales) {
    for (final scale in _scales) {
      final code = locale.languageCode;
      testWidgets('page-card + grade band reflow at ${scale}x ($code)', (
        tester,
      ) async {
        await _pumpAtScale(tester, locale, scale);
        expect(
          tester.takeException(),
          isNull,
          reason: 'no RenderFlex/overflow at ${scale}x in $code',
        );
        // The four grade buttons stay present (no row collapse/clip).
        for (final g in ReviewGrade.values) {
          expect(
            find.byKey(ValueKey<String>('grade.${g.wireValue}')),
            findsOneWidget,
          );
        }
      });
    }
  }
}
