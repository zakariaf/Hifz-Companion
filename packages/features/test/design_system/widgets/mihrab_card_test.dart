// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

const _leadingIcon = Icons.menu_book_outlined;

Widget _host(TextDirection direction, Widget child) {
  return MaterialApp(
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  useOfflineTestPolicy();

  testWidgets('RTL: leading sits at start (right), chevron at end (left)', (
    tester,
  ) async {
    final card =
        MihrabCard(title: 'عنوان', leading: _leadingIcon, onTap: () {});
    await tester.pumpWidget(_host(TextDirection.rtl, card));
    await tester.pumpAndSettle();

    final leadingX = tester.getCenter(find.byIcon(_leadingIcon)).dx;
    final chevronX = tester.getCenter(find.byIcon(Icons.arrow_forward_ios)).dx;
    expect(leadingX, greaterThan(chevronX)); // start=right, end=left in RTL
  });

  testWidgets('a tappable card is one ≥48dp hit target firing onTap once', (
    tester,
  ) async {
    var taps = 0;
    final card = MihrabCard(title: 'عنوان', onTap: () => taps++);
    await tester.pumpWidget(_host(TextDirection.rtl, card));
    await tester.pumpAndSettle();

    final h = tester.getSize(find.byType(InkWell)).height;
    expect(h, greaterThanOrEqualTo(48));
    await tester.tap(find.byType(InkWell));
    expect(taps, 1);
  });

  testWidgets('the card is flat with no surfaceTint veil', (tester) async {
    const card = MihrabCard(title: 'عنوان');
    await tester.pumpWidget(_host(TextDirection.rtl, card));
    await tester.pumpAndSettle();
    final rendered = tester.widget<Card>(find.byType(Card));
    expect(rendered.surfaceTintColor, Colors.transparent);
    expect(rendered.elevation, 0);
  });
}
