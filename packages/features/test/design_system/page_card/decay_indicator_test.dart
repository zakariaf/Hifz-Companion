// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T03 — the decay indicator: the same fact redundantly (a coloured 8-point
// star + label), no number, and STRUCTURALLY no "safe to drop"/"mastered" level
// (C-019). Concept-02 redesign: the ready-for-revision end carries the palette's
// calm terracotta accent (`semanticWarning`), the holding end the teal heat ramp.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

Widget _host(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  useOfflineTestPolicy();

  test(
      'the decay scale has exactly three levels — no "safe to drop"/"mastered"',
      () {
    expect(DecayLevel.values, hasLength(3));
    expect(
      DecayLevel.values.map((e) => e.name).toSet(),
      {'solid', 'holding', 'needsRevision'},
    );
  });

  Text labelOf(WidgetTester tester) => tester.widget<Text>(
        find.descendant(
          of: find.byType(DecayIndicator),
          matching: find.byType(Text),
        ),
      );

  testWidgets('each level pairs the right hue with the star + label',
      (tester) async {
    final colors = mihrabColorsFor(MihrabAppearance.light);
    // solid/holding share the calm teal heat ramp; ready-for-revision is the
    // warm terracotta accent (the label word, not the hue, splits solid/holding).
    final cases = <DecayLevel, Color>{
      DecayLevel.solid: colors.heatmapStrong,
      DecayLevel.holding: colors.heatmapStrong,
      DecayLevel.needsRevision: colors.semanticWarning,
    };
    for (final entry in cases.entries) {
      await tester.pumpWidget(
        _host(DecayIndicator(level: entry.key, label: 'l')),
      );
      // The star (an 8-point CustomPaint, never `Icons.star`) and the label
      // share the band hue.
      expect(
        labelOf(tester).style?.color,
        entry.value,
        reason: '${entry.key} hue',
      );
      expect(
        labelOf(tester).style?.fontWeight,
        FontWeight.bold,
        reason: '${entry.key} label is bold so the low-chroma hue clears AA',
      );
    }
  });

  testWidgets('the star stays small (<= space.4)', (tester) async {
    await tester.pumpWidget(
      _host(const DecayIndicator(level: DecayLevel.solid, label: 'l')),
    );
    final space = Theme.of(tester.element(find.byType(DecayIndicator)))
        .extension<SpacingTokens>()!;
    final star = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(DecayIndicator),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(star.size.shortestSide, lessThanOrEqualTo(space.space4));
  });

  testWidgets('the ready-for-revision end is the calm terracotta accent',
      (tester) async {
    await tester.pumpWidget(
      _host(const DecayIndicator(level: DecayLevel.needsRevision, label: 'l')),
    );
    final colors = Theme.of(tester.element(find.byType(DecayIndicator)))
        .extension<MihrabColors>()!;
    // A warm clay (the concept's shared accent), never a saturated alarm-red.
    expect(labelOf(tester).style?.color, colors.semanticWarning);
  });

  testWidgets(
      'the label is spoken (color-independent), the star is decorative',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const DecayIndicator(level: DecayLevel.needsRevision, label: 'needs'),
      ),
    );
    // The meaning rides on the star + the spoken label, never colour alone.
    assertColorIndependent(tester, labels: const ['needs']);
    expect(
      tester.getSemantics(find.byType(DecayIndicator)),
      isSemantics(label: 'needs'),
    );
    handle.dispose();
  });
}
