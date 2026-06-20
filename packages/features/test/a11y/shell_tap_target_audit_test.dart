// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T07 (A6): the PR-blocking tap-target gate. Every interactive shell control
// meets the Android 48×48 dp and iOS 44×44 pt floors and is labeled, in each of
// ar/fa/ckb. Fast lane (font-independent). A sub-floor control would fail —
// proven in E08-T10.

import 'package:flutter_test/flutter_test.dart';

import 'accessibility_audit.dart';

void main() {
  useOfflineTestPolicy();

  for (final locale in a11yLocales) {
    testWidgets('${locale.languageCode}: shell meets the touch-target floors', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);
      await auditTapTargets(tester);
      handle.dispose();
    });
  }
}
