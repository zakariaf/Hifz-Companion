// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T06 — the OUTPUT CODEPOINTS are the whole point: a Persian reader shown
// ٤٥٦ (Arabic-Indic) instead of ۴۵۶ (Extended Arabic-Indic) is a defect invisible
// to a reviewer skimming Dart, caught only by asserting the digit block. The
// guarantee is formatLocaleNumber (intl 0.20.x renders `ar` in Latin and ignores
// `-u-nu-arab`, so the block is pinned downstream — dart-lang/i18n #197).

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

const _extendedZero = 0x06F0; // ۰ .. ۹  (U+06F0–U+06F9) — fa, ckb
const _extendedNine = 0x06F9;
const _arabicZero = 0x0660; // ٠ .. ٩  (U+0660–U+0669) — ar
const _arabicNine = 0x0669;
const _asciiZero = 0x30;
const _asciiNine = 0x39;

bool _allIn(String s, int lo, int hi) => s.runes
    .where((r) => r != 0x2C && r != 0x66C) // skip a grouping separator
    .every((r) => r >= lo && r <= hi);

bool _hasAny(String s, int lo, int hi) =>
    s.runes.any((r) => r >= lo && r <= hi);

void main() {
  useOfflineTestPolicy();

  group('exact digit block per locale (the load-bearing case)', () {
    test(
        'fa renders only Extended Arabic-Indic (U+06F0..), no Arabic-Indic/ASCII',
        () {
      const fa = Locale('fa');
      for (final n in const [1234567890, 456, 0, 7]) {
        final out = formatLocaleNumber(fa, n);
        expect(
          _allIn(out, _extendedZero, _extendedNine),
          isTrue,
          reason: 'fa $n => "$out" must be Extended Arabic-Indic only',
        );
        expect(_hasAny(out, _arabicZero, _arabicNine), isFalse);
        expect(_hasAny(out, _asciiZero, _asciiNine), isFalse);
      }
      // The visibly-distinct 4/5/6 (the #197/Eastern-Arabic distinction).
      expect(formatLocaleNumber(fa, 456), '۴۵۶');
    });

    test('ckb renders only Extended Arabic-Indic (shares fa)', () {
      const ckb = Locale.fromSubtags(languageCode: 'ckb');
      final out = formatLocaleNumber(ckb, 456);
      expect(out, '۴۵۶');
      expect(_allIn(out, _extendedZero, _extendedNine), isTrue);
    });

    test('ar renders only Arabic-Indic (U+0660..), no Extended/ASCII', () {
      const ar = Locale('ar');
      for (final n in const [1234567890, 456, 0, 7]) {
        final out = formatLocaleNumber(ar, n);
        expect(
          _allIn(out, _arabicZero, _arabicNine),
          isTrue,
          reason: 'ar $n => "$out" must be Arabic-Indic only',
        );
        expect(_hasAny(out, _extendedZero, _extendedNine), isFalse);
        expect(_hasAny(out, _asciiZero, _asciiNine), isFalse);
      }
      expect(formatLocaleNumber(ar, 456), '٤٥٦');
    });
  });

  test(
      'the explicit block pin defeats intl\'s inconsistent bare-locale default',
      () {
    // Bare `ar` via intl renders Latin (456) — the pin must win.
    expect(formatLocaleNumber(const Locale('ar'), 456), isNot('456'));
    expect(formatLocaleNumber(const Locale('fa'), 456), isNot('456'));
  });

  test('fallback is ASCII for an unsupported locale', () {
    expect(formatLocaleNumber(const Locale('en'), 7), '7');
  });

  group('localeDigits — the grouping-suppressed index shaper', () {
    test('fa/ckb render Extended Arabic-Indic only, ar Arabic-Indic only', () {
      expect(localeDigits(456, const Locale('fa')), '۴۵۶');
      expect(
        localeDigits(456, const Locale.fromSubtags(languageCode: 'ckb')),
        '۴۵۶',
      );
      expect(localeDigits(456, const Locale('ar')), '٤٥٦');
    });

    test('a 3-digit muṣḥaf page index carries no thousands separator', () {
      // 604 is the largest muṣḥaf page; the output is digits only.
      final out = localeDigits(604, const Locale('fa'));
      expect(out, '۶۰۴');
      expect(
        out.runes.every((r) => r >= _extendedZero && r <= _extendedNine),
        isTrue,
        reason: 'no grouping separator slipped into an index',
      );
    });

    test('grouping is suppressed above a thousand (unlike formatLocaleNumber)',
        () {
      // localeDigits is the INDEX shaper: 1000 → ۱۰۰۰, no separator. The general
      // formatLocaleNumber groups (۱٬۰۰۰) — the two have distinct jobs.
      expect(localeDigits(1000, const Locale('fa')), '۱۰۰۰');
      expect(
        formatLocaleNumber(const Locale('fa'), 1000).runes.length,
        greaterThan(localeDigits(1000, const Locale('fa')).runes.length),
      );
    });

    test('no ASCII for a supported locale; passes through when unsupported',
        () {
      expect(localeDigits(7, const Locale('fa')), '۷');
      expect(localeDigits(7, const Locale('en')), '7');
    });
  });

  test('format -> isolate -> inject round-trips with bidi + the ARB key',
      () async {
    const fa = Locale('fa');
    final token = isolateLtr(formatLocaleNumber(fa, 23));
    final l10n = await AppLocalizations.delegate.load(fa);
    final label = l10n.juzLabel(token);
    expect(label.contains('۲۳'), isTrue); // Extended digits survive
    expect(label.contains(token), isTrue); // injected, not spliced
    // bracketed by LRI (U+2066) … PDI (U+2069)
    expect(token.runes.first, 0x2066);
    expect(token.runes.last, 0x2069);
  });
}
