// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E09-T04 — the forced-LTR island: a pure-Latin technical token stays LTR even
// while the app chrome around it is RTL.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

void main() {
  useOfflineTestPolicy();

  testWidgets('ForcedLtrText forces LTR inside an RTL host', (tester) async {
    const token = '1.2.0+build';
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl, // the ambient app chrome
        child: ForcedLtrText(token),
      ),
    );

    final tokenContext = tester.element(find.text(token));
    expect(Directionality.of(tokenContext), TextDirection.ltr);
  });
}
