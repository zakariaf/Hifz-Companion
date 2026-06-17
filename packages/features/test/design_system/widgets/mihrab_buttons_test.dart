// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  test('FilledButton + SegmentedButton themes clear the 48dp touch floor', () {
    final filled = mihrabFilledButtonTheme().style!.minimumSize!.resolve({});
    final segmented =
        mihrabSegmentedButtonTheme().style!.minimumSize!.resolve({});
    expect(filled, const Size(48, 48));
    expect(segmented, const Size(48, 48));
  });

  test('the grade-band tall variant is ≥56dp tall', () {
    final tall = mihrabTallFilledButtonStyle().minimumSize!.resolve({});
    expect(tall!.height, greaterThanOrEqualTo(56));
    expect(tall.width, greaterThanOrEqualTo(48));
  });

  test('the Mihrab label style is zero letter-spacing on the Vazirmatn face',
      () {
    final theme = mihrabThemeFor(MihrabAppearance.light);
    expect(theme.textTheme.labelLarge?.letterSpacing, 0);
    expect(theme.textTheme.bodyLarge?.letterSpacing, 0);
    expect(theme.textTheme.labelLarge?.fontFamily, 'Vazirmatn');
  });

  testWidgets('no Badge surface appears with a styled FilledButton', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: FilledButton(onPressed: () {}, child: const Icon(Icons.check)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Badge), findsNothing);
    final h = tester.getSize(find.byType(FilledButton)).height;
    expect(h, greaterThanOrEqualTo(48));
  });
}
