// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T04 — the Settings language-preview island renders a sample in the
// PREVIEWED locale's direction, independent of the ambient app direction.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('directionForLocale maps script direction by language subtag', () {
    expect(directionForLocale(const Locale('ar')), TextDirection.rtl);
    expect(directionForLocale(const Locale('fa')), TextDirection.rtl);
    expect(
      directionForLocale(const Locale.fromSubtags(languageCode: 'ckb')),
      TextDirection.rtl,
    );
    expect(directionForLocale(const Locale('en')), TextDirection.ltr);
  });

  testWidgets('preview uses the previewed locale dir, not the ambient one', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl, // ambient app is RTL
        child: Column(
          children: <Widget>[
            LanguagePreview(
              sampleText: 'rtl-sample',
              previewLocale: Locale('fa'),
            ),
            // An LTR sentinel locale: shown LTR even though the app is RTL.
            LanguagePreview(
              sampleText: 'ltr-sample',
              previewLocale: Locale('en'),
            ),
          ],
        ),
      ),
    );

    expect(
      Directionality.of(tester.element(find.text('rtl-sample'))),
      TextDirection.rtl,
    );
    expect(
      Directionality.of(tester.element(find.text('ltr-sample'))),
      TextDirection.ltr,
    );
  });
}
