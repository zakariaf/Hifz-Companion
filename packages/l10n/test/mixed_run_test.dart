// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T01 — the mixed-run callers every component uses for a "Page N · Juz M"
// headline and a "{n} pages due" count. The load-bearing invariants a native
// reader sees instantly: each numeric token is in the locale digit block (never
// ASCII), each is wrapped in an LRI…PDI isolate (so a count never flips to
// "30 of 7" visually OR in screen-reader order), the page precedes the juz, and
// the ICU plural picks the right Arabic CLDR category while the count still
// renders in Arabic-Indic digits (intl 0.20.x renders the plural count in Latin
// — dart-lang/i18n #197 — so the block is pinned downstream).

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

const _lri = 0x2066; // LEFT-TO-RIGHT ISOLATE (U+2066)
const _pdi = 0x2069; // POP DIRECTIONAL ISOLATE (U+2069)

void main() {
  useOfflineTestPolicy();

  group('localizedPageJuz — page-then-juz, each token isolated, locale digits',
      () {
    test('fa: Extended Arabic-Indic, page precedes juz, each token LRI…PDI',
        () async {
      const fa = Locale('fa');
      final l10n = await AppLocalizations.delegate.load(fa);
      final label =
          localizedPageJuz(page: 253, juz: 13, locale: fa, l10n: l10n);

      expect(label.contains('۲۵۳'), isTrue, reason: 'page in fa digits');
      expect(label.contains('۱۳'), isTrue, reason: 'juz in fa digits');
      expect(label.contains('253'), isFalse, reason: 'no ASCII splice');
      expect(label.contains('13'), isFalse, reason: 'no ASCII splice');
      // Source order is page-then-juz (the no "30 of 7" flip guarantee).
      expect(label.indexOf('۲۵۳'), lessThan(label.indexOf('۱۳')));
      // Exactly the two numeric tokens are isolated — injected, not spliced.
      expect(label.runes.where((r) => r == _lri).length, 2);
      expect(label.runes.where((r) => r == _pdi).length, 2);
    });

    test('ckb: Extended Arabic-Indic (shares fa block)', () async {
      const ckb = Locale.fromSubtags(languageCode: 'ckb');
      final l10n = await AppLocalizations.delegate.load(ckb);
      final label =
          localizedPageJuz(page: 253, juz: 13, locale: ckb, l10n: l10n);
      expect(label.contains('۲۵۳'), isTrue);
      expect(label.contains('۱۳'), isTrue);
      expect(label.contains('253'), isFalse);
    });

    test('ar: Arabic-Indic digit block', () async {
      const ar = Locale('ar');
      final l10n = await AppLocalizations.delegate.load(ar);
      final label =
          localizedPageJuz(page: 253, juz: 13, locale: ar, l10n: l10n);
      expect(label.contains('٢٥٣'), isTrue);
      expect(label.contains('١٣'), isTrue);
      expect(label.contains('253'), isFalse);
    });
  });

  group('localizedPagesDue — locale-shaped count through the ICU plural', () {
    test('ar: the "few" category is chosen AND the count is Arabic-Indic',
        () async {
      const ar = Locale('ar');
      final l10n = await AppLocalizations.delegate.load(ar);
      // 3 → Arabic "few" (3–10): "{count} صفحات مستحقة للمراجعة".
      final few = localizedPagesDue(count: 3, locale: ar, l10n: l10n);
      expect(few.contains('٣'), isTrue, reason: 'count shaped to Arabic-Indic');
      expect(few.contains('3'), isFalse, reason: 'no Latin count leaks (#197)');
      expect(few.contains('صفحات'), isTrue, reason: 'the few-category noun');
    });

    test('ar: the dual ("two") category needs no count digit', () async {
      const ar = Locale('ar');
      final l10n = await AppLocalizations.delegate.load(ar);
      final two = localizedPagesDue(count: 2, locale: ar, l10n: l10n);
      expect(two, isNotEmpty);
      expect(two.contains('2'), isFalse);
      expect(two.contains('صفحتان'), isTrue, reason: 'the dual noun form');
    });

    test('fa: the count renders in Extended Arabic-Indic, never Latin',
        () async {
      const fa = Locale('fa');
      final l10n = await AppLocalizations.delegate.load(fa);
      final out = localizedPagesDue(count: 5, locale: fa, l10n: l10n);
      expect(out.contains('۵'), isTrue);
      expect(out.contains('5'), isFalse);
    });
  });
}
