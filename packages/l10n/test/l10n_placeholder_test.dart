// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('l10n package stub', () {
    testWidgets('AppLocalizations resolves the placeholder key for ar/fa/ckb', (
      tester,
    ) async {
      for (final Locale locale in const <Locale>[
        Locale('ar'),
        Locale('fa'),
        Locale('ckb'),
      ]) {
        final AppLocalizations l10n = await AppLocalizations.delegate.load(
          locale,
        );
        expect(l10n.appTitle, isNotEmpty, reason: 'locale $locale');
      }
    });

    test('numberFormatFor wires a locale-bound formatter for ar/fa/ckb', () {
      // The path is wired (a locale-bound NumberFormat per locale); E09 owns the
      // finalized native-digit policy. ckb borrows fa's numeral set.
      expect(numberFormatFor('ar').locale, 'ar');
      expect(numberFormatFor('fa').locale, 'fa');
      expect(numberFormatFor('ckb').locale, 'fa');
      expect(numberFormatFor('ar').format(3), isNotEmpty);
    });
    // bidi isolation is owned by bidi_test.dart (E09-T05).
  });
}
