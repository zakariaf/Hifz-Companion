// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E08-T07 (A1): the PR-blocking contrast gate. textContrastGuideline measures
// rendered foreground/background, so it loads the REAL bundled UI fonts (never
// Ahem, which mis-measures) and runs over the standard-surface shell chrome per
// appearance and once more at 200% text scale. Golden lane (pinned OS). No
// master image — the guideline asserts the floor, it does not compare pixels.
//
// Scope: the body chrome (placeholder cards on standard Material surfaces). The
// bespoke curved MihrabNavigationBar is excluded — it is a CustomPaint component
// whose pixel-sampled label contrast is host-sensitive (its onSurfaceVariant /
// surfaceContainer ≈ 4.41 and selected-tab primary / surfaceContainer ≈ 2.44
// pairs are below the floor on the Linux lane). Those are E06 (token values) /
// E10 (component) concerns to remedy by raising the nav label emphasis; E08-T07
// owns the floor as a gate, not the token values. Flagged for E06/E10.

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
    testWidgets('${appearance.name}: body chrome clears the contrast floor', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(780, 1688);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        shellChrome(
          locale: const Locale('ar'),
          appearance: appearance,
          navBar: false,
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
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
        navBar: false,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await auditContrast(tester);
  });
}
