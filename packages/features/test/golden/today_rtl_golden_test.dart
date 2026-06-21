// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E09-T10 — the per-locale RTL + numeral pixel proof on the REAL bundled UI font
// (Vazirmatn, never Ahem): one frame per locale [ar, fa, ckb] freezing the
// digit block (۴۵۶ fa/ckb, ٤٥٦ ar) on a number AND a date, the bidi-isolated
// "Juz N" mixed run reading start→end (never reordered), and the active term-set
// (track chip + grade verb, ckb clearly provisional). Direction is locale-
// derived (no hardcoded app-root Directionality). No muṣḥaf glyph is rendered —
// chrome only (design 12 §8). CI verifies, never blesses (--update-goldens local
// only). The codepoint assertions live in numerals_test/bidi_test, not here.

import 'package:engine/engine.dart' show CalendarDate, ReviewGrade, ReviewTrack;
import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart';

/// The E09 aggregation strip: every mechanism in one frame.
class _RtlNumeralStrip extends StatelessWidget {
  const _RtlNumeralStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final juz = l10n.juzLabel(isolateLtr(formatLocaleNumber(locale, 23)));
    final date = isolatedDateLabel(
      CalendarPresenter(CalendarSystem.jalali, locale),
      CalendarDate.ymd(2026, 6, 16),
    );
    final theme = Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          Text(juz, style: theme),
          Text(l10n.pagesDue(3), style: theme),
          Text(date, style: theme),
          Text(trackLabel(l10n, ReviewTrack.far, 'levant'), style: theme),
          Text(
            gradeVerb(l10n, ReviewGrade.good, kDefaultTermSetRegion),
            style: theme,
          ),
        ],
      ),
    );
  }
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    testWidgets('rtl + numerals strip ($code)', (tester) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(600, 500);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const Scaffold(body: SafeArea(child: _RtlNumeralStrip())),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(_RtlNumeralStrip),
        matchesGoldenFile('goldens/rtl_numeral_strip__$code.png'),
      );
    });
  }
}
