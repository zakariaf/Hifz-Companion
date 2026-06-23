// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E12-T03 — per-locale (ar/fa/ckb) golden of the populated daily-session list on
// the REAL bundled UI font (Vazirmatn): the three sections in Far → Near → New
// order with localized term-set headers, locale-numeral page identity, RTL
// geometry (leading cluster at start, chevron at end), and ckb's longer headers
// reflowing. No muṣḥaf glyph is rendered. Linux golden lane verifies; masters
// regenerate via `--update-goldens`.

import 'package:features/features.dart'
    show DailySessionList, MihrabAppearance, TodaySession, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;
import '../test_setup.dart';
import 'today_fixtures.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  final session = TodaySession(
    far: [dueFar(253), dueFar(120)],
    near: [dueNear(45)],
    newSabaq: [dueNew(8)],
  );

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    testWidgets('daily session list ($code)', (tester) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(420, 1100) * 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: Scaffold(
            body: SafeArea(
              child: DailySessionList(
                session: session,
                juzOf: (pageId) => (pageId ~/ 20) + 1,
                onOpen: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DailySessionList),
        matchesGoldenFile('goldens/daily_session_list__$code.png'),
      );
    });
  }
}
