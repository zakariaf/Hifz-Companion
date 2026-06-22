// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T03 — the decay indicator: the same fact three ways (ramp colour + glyph +
// label), a muted-neutral decaying end (never red/amber), no number, and
// STRUCTURALLY no "safe to drop"/"mastered" level (C-019).

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

  testWidgets('each level pairs the right ramp colour with the right glyph',
      (tester) async {
    final colors = mihrabColorsFor(MihrabAppearance.light);
    final cases = <DecayLevel, (Color, IconData)>{
      DecayLevel.solid: (colors.heatmapStrong, Icons.circle),
      DecayLevel.holding: (colors.heatmapFair, Icons.contrast),
      DecayLevel.needsRevision: (colors.heatmapWeak, Icons.circle_outlined),
    };
    for (final entry in cases.entries) {
      await tester.pumpWidget(
        _host(DecayIndicator(level: entry.key, label: 'l')),
      );
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(DecayIndicator),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.icon, entry.value.$2, reason: '${entry.key} glyph');
      expect(icon.color, entry.value.$1, reason: '${entry.key} ramp colour');
    }
  });

  testWidgets('the swatch stays small (<= space.4)', (tester) async {
    await tester.pumpWidget(
      _host(const DecayIndicator(level: DecayLevel.solid, label: 'l')),
    );
    final space = Theme.of(tester.element(find.byType(DecayIndicator)))
        .extension<SpacingTokens>()!;
    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(DecayIndicator),
        matching: find.byType(Icon),
      ),
    );
    expect(icon.size, lessThanOrEqualTo(space.space4));
  });

  testWidgets(
      'the decaying end is a muted neutral, never the warning/alarm token',
      (tester) async {
    await tester.pumpWidget(
      _host(const DecayIndicator(level: DecayLevel.needsRevision, label: 'l')),
    );
    final colors = Theme.of(tester.element(find.byType(DecayIndicator)))
        .extension<MihrabColors>()!;
    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(DecayIndicator),
        matching: find.byType(Icon),
      ),
    );
    expect(icon.color, colors.heatmapWeak);
    expect(icon.color, isNot(colors.semanticWarning));
  });

  testWidgets(
      'the label is spoken (color-independent), the glyph is decorative',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const DecayIndicator(level: DecayLevel.needsRevision, label: 'needs'),
      ),
    );
    // The meaning rides on a glyph + the spoken label, never colour alone.
    assertColorIndependent(tester, icons: const [Icons.circle_outlined]);
    expect(
      tester.getSemantics(find.byType(DecayIndicator)),
      isSemantics(label: 'needs'),
    );
    handle.dispose();
  });
}
