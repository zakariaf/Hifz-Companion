// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Widget navigator(TextDirection direction, {int pageCount = 604}) =>
      Directionality(
        textDirection: direction,
        child: MushafPageNavigator(
          pageCount: pageCount,
          currentPage: 1,
          onPageChanged: (_) {},
          pageBuilder: (pageNumber) => Text('page-$pageNumber'),
        ),
      );

  testWidgets(
      'PageView.reverse is true under RTL (page 1→2 turns right-to-left)',
      (tester) async {
    await tester.pumpWidget(navigator(TextDirection.rtl));
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.reverse, isTrue);
  });

  testWidgets('reverse is derived from Directionality, not hardcoded',
      (tester) async {
    await tester.pumpWidget(navigator(TextDirection.ltr));
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.reverse, isFalse);
  });

  testWidgets('the glyph layer is never mirrored/flipped for RTL',
      (tester) async {
    await tester.pumpWidget(navigator(TextDirection.rtl));
    // No flip/mirror transform wraps the page content (only PageView.reverse
    // handles direction). A Transform(flipX) would appear as a Transform widget.
    expect(find.byType(Transform), findsNothing);
  });

  testWidgets('itemCount follows pageCount, never a literal 604',
      (tester) async {
    await tester.pumpWidget(navigator(TextDirection.rtl, pageCount: 548));
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.childrenDelegate.estimatedChildCount, 548);
  });

  testWidgets('a page turn reports the new 1-based page number',
      (tester) async {
    var reported = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MushafPageNavigator(
          pageCount: 604,
          currentPage: 1,
          onPageChanged: (p) => reported = p,
          pageBuilder: (pageNumber) =>
              SizedBox(width: 800, child: Text('page-$pageNumber')),
        ),
      ),
    );
    // Fling toward the next page; reverse=true so swipe left advances.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(reported, 2);
  });
}
