// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E08-T07 (A1): the PR-blocking contrast gate. textContrastGuideline measures
// rendered foreground/background, so it loads the REAL bundled UI fonts (never
// Ahem, which mis-measures) and runs over the shell chrome per appearance and
// once more at 200% text scale. Golden lane (pinned OS). No master image — the
// guideline asserts the floor, it does not compare pixels.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_audit.dart';

void main() {
  useOfflineTestPolicy();

  setUpAll(loadRealUiFonts);

  // The chrome appearances the shell renders (Light/Sepia/Dark/Night live in
  // E06; the floor is asserted over each rendered surface).
  const appearances = [
    MihrabAppearance.light,
    MihrabAppearance.sepia,
    MihrabAppearance.dark,
    MihrabAppearance.night,
  ];

  for (final appearance in appearances) {
    testWidgets('${appearance.name}: shell chrome clears the contrast floor', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(780, 1688);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpShellUnderTest(
        tester,
        locale: const Locale('ar'),
        appearance: appearance,
      );
      await auditContrast(tester);
    });
  }

  testWidgets('contrast holds at 200% text scale', (tester) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(780, 1688);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      shellChrome(
        locale: const Locale('ckb'),
        textScaler: const TextScaler.linear(2.0),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await auditContrast(tester);
  });
}
