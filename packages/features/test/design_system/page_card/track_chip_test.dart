// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T03 — the track chip: non-interactive, color AND text (never colour
// alone), a tradition-tied family per track, NEVER alarm-red for any track, and
// ckb's longer terms wrap rather than truncate.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/offline_test_bootstrap.dart';

Widget _host(
  Widget child, {
  MihrabAppearance appearance = MihrabAppearance.light,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: mihrabThemeFor(appearance),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

ShapeDecoration _chipDecoration(WidgetTester tester) {
  final box = tester.widget<Container>(
    find.descendant(
      of: find.byType(TrackChip),
      matching: find.byType(Container),
    ),
  );
  return box.decoration! as ShapeDecoration;
}

void main() {
  useOfflineTestPolicy();

  testWidgets('non-interactive — no tap/focus node of its own', (tester) async {
    await tester.pumpWidget(
      _host(const TrackChip(family: TrackFamily.far, label: 'منزل')),
    );
    expect(
      find.descendant(
        of: find.byType(TrackChip),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(TrackChip),
        matching: find.byType(GestureDetector),
      ),
      findsNothing,
    );
  });

  testWidgets('color AND text — every family pairs a label with its family',
      (tester) async {
    for (final family in TrackFamily.values) {
      await tester.pumpWidget(
        _host(TrackChip(family: family, label: 'لیبڵ')),
      );
      expect(find.text('لیبڵ'), findsOneWidget, reason: 'the term-set label');
      expect(
        _chipDecoration(tester).color,
        isNotNull,
        reason: 'a color family',
      );
    }
  });

  testWidgets(
      'far is the calm green maintenance family (a role, not a literal)',
      (tester) async {
    await tester.pumpWidget(
      _host(const TrackChip(family: TrackFamily.far, label: 'منزل')),
    );
    final scheme = Theme.of(tester.element(find.byType(TrackChip))).colorScheme;
    expect(_chipDecoration(tester).color, scheme.primaryContainer);
  });

  testWidgets('no family resolves to the warning/danger token (no alarm-red)',
      (tester) async {
    for (final family in TrackFamily.values) {
      await tester.pumpWidget(_host(TrackChip(family: family, label: 'x')));
      final colors = Theme.of(tester.element(find.byType(TrackChip)))
          .extension<MihrabColors>()!;
      expect(
        _chipDecoration(tester).color,
        isNot(colors.semanticWarning),
        reason: 'a track chip is never a warning/alarm surface',
      );
    }
  });

  testWidgets('ckb longer term wraps — no ellipsis truncation', (tester) async {
    await tester.pumpWidget(
      _host(
        const TrackChip(
          family: TrackFamily.far,
          label: 'پێداچوونەوەی دوورەدەستی مەنزیل',
        ),
      ),
    );
    final text = tester.widget<Text>(
      find.descendant(of: find.byType(TrackChip), matching: find.byType(Text)),
    );
    expect(text.overflow, isNot(TextOverflow.ellipsis));
  });
}
