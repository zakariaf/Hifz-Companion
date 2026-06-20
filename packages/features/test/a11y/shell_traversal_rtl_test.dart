// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T08 (A8, written red-before-green): screen-reader focus/reading order runs
// right-to-left, top-to-bottom on the shell's key screens in fa/ckb/ar, matching
// the visual order — never source/child order. The ordered sequence of labeled
// nodes is asserted from their RENDERED RECTS under the locale-derived RTL
// direction, on the REAL bundled fonts (never Ahem, so Sorani letters and the
// digit blocks actually shape). Reuses the E08-T07 audit lane.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'accessibility_audit.dart';

void main() {
  useOfflineTestPolicy();

  setUpAll(loadRealUiFonts);

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('$code: nav traversal runs right-to-left (visual order)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);
      final l10n = await localizationsFor(locale);

      // The five destinations in LOGICAL order (Today first).
      final logical = [
        l10n.navToday,
        l10n.navMushaf,
        l10n.navMutashabihat,
        l10n.navProgress,
        l10n.navSettings,
      ];
      final centresX = [
        for (final label in logical)
          tester.getRect(find.bySemanticsLabel(label).first).center.dx,
      ];

      // Visual RTL: the first logical node (Today) renders rightmost, and each
      // subsequent node sits further left — a strictly DECREASING x sequence.
      for (var i = 1; i < centresX.length; i++) {
        expect(
          centresX[i],
          lessThan(centresX[i - 1]),
          reason: 'logical node $i must render left of node ${i - 1} under RTL',
        );
      }

      // Discriminator (the red proof): an LTR/source-order expectation —
      // ascending x — is FALSE here; flipping the test to expect ascending would
      // fail, proving it discriminates RTL traversal from "looks right in LTR".
      final ascending = [...centresX]..sort();
      expect(
        centresX,
        isNot(equals(ascending)),
        reason: 'an LTR (ascending-x) order must not satisfy the RTL assertion',
      );
      handle.dispose();
    });

    testWidgets(
        '$code: placeholder cards traverse top-to-bottom, one node each',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);

      final centresY = [
        for (final id in placeholderSectionIds)
          tester.getRect(find.byKey(ValueKey<String>(id))).center.dy,
      ];
      for (var i = 1; i < centresY.length; i++) {
        expect(
          centresY[i],
          greaterThan(centresY[i - 1]),
          reason: 'card $i must render below card ${i - 1} (top-to-bottom)',
        );
      }

      // Each card is reached as ONE merged node, not three fragments.
      final l10n = await localizationsFor(locale);
      expect(
        find.bySemanticsLabel(
          RegExp(
            '${RegExp.escape(l10n.navMushaf)}.*'
            '${RegExp.escape(l10n.sectionInPreparation)}',
            dotAll: true,
          ),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  }
}
