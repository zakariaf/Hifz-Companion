// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
@Skip('RTL/layout masters land in E08/E09')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  // The RTL / layout golden harness. DORMANT in E01 — E08/E09 own the per-locale
  // RTL masters. Each case pumps a screen under
  // Directionality(textDirection: TextDirection.rtl) for ar/fa/ckb with locale
  // numerals, then matchesGoldenFile(...). No master pixel is committed here.
  testWidgets('Today renders RTL with locale numerals for ar/fa/ckb', (
    tester,
  ) async {
    // E08/E09: pump under Directionality.rtl per locale and compare to the
    // per-locale RTL master.
  });
}
