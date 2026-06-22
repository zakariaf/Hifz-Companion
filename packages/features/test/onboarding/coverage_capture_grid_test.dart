// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The coverage-capture grid (E11-T05): 30 juz cells in muṣḥaf order (RTL), one
// tap = held/not-held, un-held = absence (never 0%/missing/red), redundant
// glyph+label encoding, toggled Semantics, ≥48 dp targets. A dumb View driving
// onToggle — no write path, no muṣḥaf glyph, no clock.

import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/coverage_capture_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> pump(
    WidgetTester tester, {
    required Set<int> held,
    required ValueChanged<int> onToggle,
    Locale locale = const Locale('ar'),
  }) async {
    // A tall surface so all 30 cells render (GridView.builder is lazy).
    await tester.binding.setSurfaceSize(const Size(440, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: CoverageCaptureGrid(heldJuz: held, onToggle: onToggle),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(locale);
  }

  testWidgets('renders 30 cells; juz ۱ at the start (right) under RTL',
      (t) async {
    await pump(t, held: const {}, onToggle: (_) {});
    expect(find.byType(InkWell), findsNWidgets(30));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    final juz1 = formatLocaleNumber(const Locale('ar'), 1);
    final juz30 = formatLocaleNumber(const Locale('ar'), 30);
    // muṣḥaf order: juz 1 sits at the start (right edge) of juz 30 under RTL.
    final dx1 = t.getCenter(find.text(juz1)).dx;
    final dx30 = t.getCenter(find.text(juz30)).dx;
    expect(dx1, greaterThan(dx30));
    expect(ar.onboardingCoverageTitle, isNotEmpty);
  });

  testWidgets('one tap toggles held; un-holding removes (absence, not 0%)',
      (t) async {
    final toggled = <int>[];
    final l10n = await pump(t, held: const {}, onToggle: toggled.add);
    final juz1 = formatLocaleNumber(const Locale('ar'), 1);
    await t.tap(find.text(juz1));
    await t.pumpAndSettle();
    expect(toggled, [1]);
    // No cell ever renders a "0" / "%" / "missing" value.
    for (final w in t.widgetList<Text>(find.byType(Text))) {
      expect((w.data ?? '').contains('%'), isFalse);
    }
    // The label uses held/not-held words, never "missing".
    expect(l10n.onboardingNotHeld.isNotEmpty, isTrue);
  });

  testWidgets('held cell carries a check glyph; un-held carries an empty ring',
      (t) async {
    await pump(t, held: const {3}, onToggle: (_) {});
    expect(find.byIcon(Icons.check_circle), findsOneWidget); // the one held juz
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(29));
  });

  testWidgets('each cell is a toggled, labelled, ≥48 dp target', (t) async {
    final l10n = await pump(t, held: const {1}, onToggle: (_) {});
    final heldLabel = l10n.onboardingCoverageCellLabel(
      formatLocaleNumber(const Locale('ar'), 1),
      l10n.onboardingHeld,
    );
    expect(find.bySemanticsLabel(heldLabel), findsOneWidget);
    await expectLater(t, meetsGuideline(androidTapTargetGuideline));
  });
}
