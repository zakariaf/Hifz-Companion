// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T07 shared audit harness: the stock Flutter guideline matchers run over
// the real E07 shell chrome (MihrabNavigationBar + the four placeholder cards,
// the same widgets HomeShell composes). Tap-target + label audits are
// font-independent (fast lane); the contrast audit needs the real bundled fonts
// (golden lane). Downward-only — l10n + the a11y helpers + the shell harness; no
// engine/drift/http. The throwing-HttpOverrides offline guard is installed via
// the bootstrap.

import 'package:flutter_test/flutter_test.dart';

export '_a11y_test_bootstrap.dart';

/// Asserts the shell meets the Android 48×48 dp and iOS 44×44 pt touch floors and
/// that every tappable node is labeled. Enable semantics first.
Future<void> auditTapTargets(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

/// Asserts every tappable node carries a localized label (the stock Flutter
/// guideline). The explicit per-nav semantics-tree walk lives in the label test.
Future<void> auditLabels(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

/// Asserts rendered text clears the WCAG contrast floor (≥4.5:1 / ≥3:1 large).
/// Needs the real bundled fonts loaded (golden lane), or it mis-measures.
Future<void> auditContrast(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}
