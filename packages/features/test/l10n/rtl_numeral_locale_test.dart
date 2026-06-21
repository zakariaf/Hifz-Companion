// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T10 — the font-INDEPENDENT per-locale RTL + numeral aggregation: one frame
// per locale [ar, fa, ckb] exercising every E09 mechanism on real composed
// surfaces, asserted by widget data (codepoints) so it runs OS-independently in
// the fast lane. The pixel-frozen counterpart (real Vazirmatn font, Linux
// masters) is today_rtl_golden_test.dart on the pinned Linux golden lane.

import 'package:engine/engine.dart' show CalendarDate, ReviewGrade, ReviewTrack;
import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

/// One strip exercising the E09 mechanisms, each in a keyed Text so the test can
/// read the rendered string (font-independent).
class _Strip extends StatelessWidget {
  const _Strip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    // Number: format → isolate (LTR, known direction) → inject into the ICU key.
    final juz = l10n.juzLabel(isolateLtr(formatLocaleNumber(locale, 23)));
    final date = isolatedDateLabel(
      CalendarPresenter(CalendarSystem.jalali, locale),
      CalendarDate.ymd(2026, 6, 16),
    );
    return Column(
      children: <Widget>[
        Text(juz, key: const ValueKey('juz')),
        Text(l10n.pagesDue(3), key: const ValueKey('pagesDue')),
        Text(date, key: const ValueKey('date')),
        Text(
          trackLabel(l10n, ReviewTrack.far, 'levant'),
          key: const ValueKey('trackFar'),
        ),
        Text(
          gradeVerb(l10n, ReviewGrade.good, kDefaultTermSetRegion),
          key: const ValueKey('gradeGood'),
        ),
      ],
    );
  }
}

Widget _host(Locale locale) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: hifzLocalizationsDelegates,
      home: const Scaffold(body: _Strip()),
    );

/// Every DIGIT code point in [s] is within [lo]..[hi]. Only actual digit ranges
/// count — ASCII (0x30–0x39), Arabic-Indic (0x0660–0x0669), Extended Arabic-Indic
/// (0x06F0–0x06F9) — so Perso-Arabic LETTERS (e.g. ی U+06CC) are never mistaken
/// for digits.
bool _allDigitsIn(String s, int lo, int hi) {
  for (final r in s.runes) {
    final isDigit = (r >= 0x30 && r <= 0x39) ||
        (r >= 0x0660 && r <= 0x0669) ||
        (r >= 0x06F0 && r <= 0x06F9);
    if (isDigit && (r < lo || r > hi)) return false;
  }
  return true;
}

void main() {
  useOfflineTestPolicy();
  setUpAll(() async => initializeDateFormatting());

  const cases = <(String, int, int)>[
    ('fa', 0x06F0, 0x06F9), // Extended Arabic-Indic
    ('ckb', 0x06F0, 0x06F9),
    ('ar', 0x0660, 0x0669), // Arabic-Indic
  ];

  for (final (code, lo, hi) in cases) {
    group('locale $code', () {
      String dataOf(WidgetTester t, String key) =>
          t.widget<Text>(find.byKey(ValueKey(key))).data!;

      testWidgets('RTL is locale-derived (no hardcoded Directionality)', (
        tester,
      ) async {
        await tester.pumpWidget(_host(Locale(code)));
        await tester.pumpAndSettle();
        expect(
          Directionality.of(tester.element(find.byType(_Strip))),
          TextDirection.rtl,
        );
      });

      testWidgets('number + date render in the locale digit block, no ASCII', (
        tester,
      ) async {
        await tester.pumpWidget(_host(Locale(code)));
        await tester.pumpAndSettle();
        for (final key in const ['juz', 'date']) {
          final s = dataOf(tester, key);
          expect(
            s.runes.any((r) => r >= 0x30 && r <= 0x39),
            isFalse,
            reason: '$code $key has ASCII digits',
          );
          expect(
            _allDigitsIn(s, lo, hi),
            isTrue,
            reason: '$code $key uses the wrong digit block',
          );
        }
      });

      testWidgets('the mixed runs are bidi-isolated', (tester) async {
        await tester.pumpWidget(_host(Locale(code)));
        await tester.pumpAndSettle();
        // The number run is isolated LTR (LRI…); the date run isolated RTL (RLI…).
        expect(dataOf(tester, 'juz').runes, contains(0x2066)); // LRI
        expect(dataOf(tester, 'date').runes.first, 0x2067); // RLI
        expect(dataOf(tester, 'date').runes.last, 0x2069); // PDI
      });

      testWidgets('plural + term-set words render non-empty', (tester) async {
        await tester.pumpWidget(_host(Locale(code)));
        await tester.pumpAndSettle();
        for (final key in const ['pagesDue', 'trackFar', 'gradeGood']) {
          expect(dataOf(tester, key), isNotEmpty);
        }
        // The far-revision term-set word renders the active set's manzil/dhor
        // (exact per-locale values are pinned in term_set_test.dart); the ckb
        // word is canonical Sorani, not the Arabic spelling.
        final farWord = dataOf(tester, 'trackFar');
        expect(farWord, code == 'ckb' ? 'مەنزیل' : 'منزل');
      });
    });
  }
}
