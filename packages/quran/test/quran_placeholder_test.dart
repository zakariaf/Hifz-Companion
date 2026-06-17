// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart';

void main() {
  testWidgets('placeholder muṣḥaf page builds RTL from value-type geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: QuranPagePlaceholder(geometry: PageGeometry(pageNumber: 1)),
      ),
    );

    expect(find.byType(QuranPagePlaceholder), findsOneWidget);
  });
}
