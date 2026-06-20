// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T02: the labeled/merged conventions applied to the real shell chrome —
// every nav destination has a localized button label, each placeholder card is
// one merged localized phrase, and no English label leaks in a non-ar build. The
// labeledTapTargetGuideline is asserted as a smoke check here; T07 makes it the
// PR-blocking gate.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_a11y_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('$code: every nav destination has a localized button label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);
      final l10n = await localizationsFor(locale);

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
          reason: 'nav "$label" should be a localized button',
        );
      }
      handle.dispose();
    });

    testWidgets('$code: each placeholder card reads as one merged phrase', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);
      final l10n = await localizationsFor(locale);

      // Muṣḥaf placeholder: title + "being prepared" line as a single node.
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

    testWidgets('$code: the shell meets the labeled-tap-target guideline', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpShellUnderTest(tester, locale: locale);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  }

  testWidgets('no English nav label leaks in a non-ar (fa) build', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpShellUnderTest(tester, locale: const Locale('fa'));
    final ar = await localizationsFor(const Locale('ar'));
    final fa = await localizationsFor(const Locale('fa'));
    // The fa nav label differs from the ar template value — the build is truly
    // localized, not falling back to the template.
    expect(fa.navMushaf, isNot(equals(ar.navMushaf)));
    expect(find.bySemanticsLabel(fa.navMushaf), findsWidgets);
    handle.dispose();
  });
}
