// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T06 test-support: the never-color-alone widget-audit. Production code never
// depends on this — it lives in test/. A chip passes only if it conveys its
// state in at least two non-color channels: a non-color visual differentiator
// (an Icon/CustomPaint/Text run) AND a non-empty screen-reader label. A chip
// differentiated by Color alone fails (WCAG SC 1.4.1). E15's heat-map cells and
// E12's cards must call this in their own tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts the chip found by [chip] conveys its state in ≥2 non-color channels:
/// a non-color visual (Icon/CustomPaint/Text) **and** a non-empty semantics
/// label. Fails (throws `TestFailure`) a chip differentiated by `Color` alone.
/// The caller must have semantics enabled (`tester.ensureSemantics()`).
void assertStateChipRedundancy(WidgetTester tester, Finder chip) {
  final hasNonColorVisual = find
      .descendant(
        of: chip,
        matching: find.byWidgetPredicate(
          // `Text` wraps `RichText`; accept either, so a chip refactored to a
          // direct `RichText` still satisfies the non-color visual channel.
          (w) => w is Icon || w is CustomPaint || w is Text || w is RichText,
        ),
      )
      .evaluate()
      .isNotEmpty;
  expect(
    hasNonColorVisual,
    isTrue,
    reason: 'state conveyed by colour alone — add a shape/pattern/text run '
        '(SC 1.4.1)',
  );

  final hasLabel = find
      .descendant(of: chip, matching: find.bySemanticsLabel(RegExp(r'\S')))
      .evaluate()
      .isNotEmpty;
  expect(
    hasLabel,
    isTrue,
    reason: 'state has no screen-reader label — the non-colour channel never '
        'reaches assistive tech (SC 1.4.1)',
  );
}
