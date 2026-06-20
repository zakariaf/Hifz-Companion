// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T07 (A7): the PR-blocking label gate. labeledTapTargetGuideline proves
// every tappable node is labeled; the explicit semantics-tree walk proves each
// nav destination's label is the LOCALIZED ARB value (not an English literal)
// and a button — defence in depth, in each of ar/fa/ckb. Fast lane.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_audit.dart';

void main() {
  useOfflineTestPolicy();

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('$code: every tappable node is labeled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);
      await auditLabels(tester);
      handle.dispose();
    });

    testWidgets('$code: each nav label is the localized ARB value + a button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);
      final l10n = await localizationsFor(locale);
      final ar = await localizationsFor(const Locale('ar'));

      for (final label in [
        l10n.navToday,
        l10n.navMushaf,
        l10n.navMutashabihat,
        l10n.navProgress,
        l10n.navSettings,
      ]) {
        expect(
          tester.getSemantics(find.bySemanticsLabel(label).first),
          isSemantics(label: label, isButton: true),
        );
      }

      // In a non-ar build the labels are truly localized, not the ar template.
      if (code != 'ar') {
        expect(l10n.navMushaf, isNot(equals(ar.navMushaf)));
        expect(find.bySemanticsLabel(ar.navMushaf), findsNothing);
      }
      handle.dispose();
    });
  }
}
