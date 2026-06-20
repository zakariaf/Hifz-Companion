// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E08-T03: per-locale legibility goldens of the dense Today rows (page-card +
// grade band) at the 200% AA bar and an AX-extreme scale on the REAL bundled
// fonts (never Ahem) — the ckb 200%/AX frames are the binding reflow proof. CI
// verifies, never blesses (--update-goldens local only).

import 'package:engine/engine.dart' show CalendarDate, Card, ReviewTrack;
import 'package:features/features.dart'
    show MihrabAppearance, PageCard, mihrabThemeFor;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId;

import '../a11y/_a11y_test_bootstrap.dart';

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

// 2.0 = the WCAG 1.4.4 (200%) bar; 3.2 = an iOS AX-extreme size.
const _scales = <String, double>{'200': 2.0, 'ax': 3.2};

void main() {
  useOfflineTestPolicy();

  setUpAll(loadRealUiFonts);

  for (final locale in a11yLocales) {
    for (final entry in _scales.entries) {
      final code = locale.languageCode;
      testWidgets('today dense rows @${entry.key} ($code)', (tester) async {
        tester.view.devicePixelRatio = 2.0;
        tester.view.physicalSize = const Size(900, 1600);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: hifzLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: mihrabThemeFor(MihrabAppearance.light),
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(entry.value)),
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

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/today_scale_${entry.key}__$code.png'),
        );
      });
    }
  }
}
