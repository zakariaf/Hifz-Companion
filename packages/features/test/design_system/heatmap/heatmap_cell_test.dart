// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T04 — the heat-map cell: single-hue ramp (never red), VSUP muting, triple-
// redundant encoding, min-leaning juz roll-up + weakest-page badge, and the
// load-bearing honesty negatives — no raw R/percentage, no mean, no scoreboard.

import 'dart:io';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

HeatmapCellData _data({
  HeatLevel level = HeatLevel.good,
  String value = '٨٠–٩٠٪',
  String label = 'LABELWORD',
  bool everReviewed = true,
  double sourceConfidence = 1,
  bool isJuzRollUp = false,
  int? weakestPageId,
  bool showDecayTexture = false,
}) =>
    HeatmapCellData(
      level: level,
      localizedValue: value,
      label: label,
      everReviewed: everReviewed,
      sourceConfidence: sourceConfidence,
      isJuzRollUp: isJuzRollUp,
      weakestPageId: weakestPageId,
      showDecayTexture: showDecayTexture,
    );

Widget _host(HeatmapCellData data, {VoidCallback? onTap}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home:
          Scaffold(body: Center(child: HeatmapCell(data: data, onTap: onTap))),
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  final colors = mihrabColorsFor(MihrabAppearance.light);

  group('ramp — single-hue lightness, by token, never red', () {
    test('each level resolves to its color.heatmap.* token (full confidence)',
        () {
      for (final level in HeatLevel.values) {
        final fill = heatFillFor(colors, _data(level: level));
        expect(fill, heatRampColor(colors, level));
      }
    });

    test('the source references no alarm-red / color.semantic token', () {
      for (final base in const [
        'packages/features/lib/src/design_system/heatmap',
        '../../packages/features/lib/src/design_system/heatmap',
      ]) {
        final cell = File('$base/heatmap_cell.dart');
        if (!cell.existsSync()) continue;
        for (final name in const [
          'heatmap_cell.dart',
          'weakest_page_badge.dart',
        ]) {
          final src = File('$base/$name').readAsStringSync();
          expect(
            src.contains('semantic'),
            isFalse,
            reason: '$name: no semantic/alarm token',
          );
          expect(
            src.contains('Color(0x'),
            isFalse,
            reason: '$name: no inline hex',
          );
        }
        return;
      }
      fail('heatmap source not found from ${Directory.current}');
    });
  });

  group('VSUP muting — confidence drives saturation', () {
    test('a never-recited page is faded regardless of an optimistic level', () {
      expect(
        heatFillFor(
          colors,
          _data(level: HeatLevel.strong, everReviewed: false),
        ),
        colors.heatmapFaded,
      );
    });

    test('a self-only cell is less saturated than a teacher-confirmed one', () {
      final self = heatFillFor(colors, _data(sourceConfidence: 0.5));
      final teacher = heatFillFor(colors, _data());
      expect(self, isNot(teacher));
    });

    test('a single self-rating can never reach the strong anchor', () {
      final fill = heatFillFor(
        colors,
        _data(level: HeatLevel.strong, sourceConfidence: 0.5),
      );
      expect(fill, isNot(colors.heatmapStrong));
    });
  });

  testWidgets('redundant encoding — value AND label, value in locale numerals',
      (tester) async {
    await tester.pumpWidget(_host(_data()));
    expect(find.textContaining('٨٠'), findsOneWidget);
    expect(find.text('LABELWORD'), findsOneWidget);
    final value = tester.widget<Text>(find.textContaining('٨٠')).data!;
    expect(
      RegExp(r'[0-9]').hasMatch(value),
      isFalse,
      reason: 'no ASCII digits',
    );
  });

  testWidgets('decay texture is the third channel only when opted in',
      (tester) async {
    await tester.pumpWidget(_host(_data()));
    final without = find
        .descendant(
          of: find.byType(HeatmapCell),
          matching: find.byType(CustomPaint),
        )
        .evaluate()
        .length;
    await tester.pumpWidget(_host(_data(showDecayTexture: true)));
    final withTexture = find
        .descendant(
          of: find.byType(HeatmapCell),
          matching: find.byType(CustomPaint),
        )
        .evaluate()
        .length;
    expect(withTexture, greaterThan(without));
  });

  group('min-leaning roll-up + weakest-page badge', () {
    testWidgets('juz roll-up renders the supplied level (no mean computed)',
        (tester) async {
      await tester.pumpWidget(
        _host(
          _data(level: HeatLevel.weak, isJuzRollUp: true, weakestPageId: 253),
        ),
      );
      expect(find.byType(WeakestPageBadge), findsOneWidget);
    });

    testWidgets('no badge when there is no weak link', (tester) async {
      await tester.pumpWidget(_host(_data(isJuzRollUp: true)));
      expect(find.byType(WeakestPageBadge), findsNothing);
    });

    testWidgets('the badge sits at the logical start (PositionedDirectional)',
        (tester) async {
      await tester.pumpWidget(
        _host(
          _data(level: HeatLevel.weak, isJuzRollUp: true, weakestPageId: 253),
        ),
      );
      expect(
        find.ancestor(
          of: find.byType(WeakestPageBadge),
          matching: find.byType(PositionedDirectional),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('tappable cell wires the focus ring, with no celebration',
      (tester) async {
    await tester.pumpWidget(_host(_data(), onTap: () {}));
    expect(find.byType(MihrabFocusRing), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(HeatmapCell),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
  });

  testWidgets('no raw number / scoreboard — no bare %, no streak/trophy glyph',
      (tester) async {
    await tester.pumpWidget(_host(_data()));
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(RegExp(r'\d+\s*%').hasMatch(t.data ?? ''), isFalse);
    }
    for (final icon in const [
      Icons.star,
      Icons.emoji_events,
      Icons.local_fire_department,
    ]) {
      expect(find.byIcon(icon), findsNothing);
    }
  });

  testWidgets('merged Semantics carries the label and the weakest page',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(_data(isJuzRollUp: true, weakestPageId: 253)),
    );
    await tester.pump();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.bySemanticsLabel(RegExp('LABELWORD')), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp(l10n.heatmapWeakestPage('٢٥٣'))),
      findsWidgets,
    );
    handle.dispose();
  });

  testWidgets('the cell is a >=48dp labelled tap target', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(_data(), onTap: () {}));
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });
}
