// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E08-T02: pins the labeled/merged shell chrome the screen reader traverses —
// the five nav destinations + the four inert placeholder cards — per locale on
// the REAL bundled Vazirmatn face (never Ahem), so a missing card, an RTL leak,
// or a Sorani-letter clip changes pixels and fails the pinned Linux golden lane.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_a11y_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();

  setUpAll(loadRealUiFonts);

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    testWidgets('shell chrome golden ($code)', (tester) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(780, 1688);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpShellUnderTest(tester, locale: locale);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/shell_semantics__$code.png'),
      );
    });
  }
}
