// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
@Skip('muṣḥaf masters land in E05 (fail-closed, never auto-blessed)')
library;

import 'package:flutter_test/flutter_test.dart';

/// Loads the REAL KFGQPC + UI fonts via [FontLoader] — never Ahem, which renders
/// every glyph as a solid square and would defeat a fidelity golden.
///
/// DORMANT in E01: no fonts are bundled and no master images exist yet, so this
/// is a no-op skeleton. E05 fills it: for each bundled family,
/// `FontLoader(family)..addFont(rootBundle.load(fontAssetPath(family)))` then
/// `await loader.load()`, on the pinned Linux golden runner.
Future<void> loadRealFonts() async {
  // E05 wires the FontLoader calls here. Intentionally empty until then.
}

void main() {
  setUpAll(loadRealFonts);

  testWidgets('muṣḥaf page renders pixel-identical to the reference master', (
    tester,
  ) async {
    // E05: pump QuranPagePlaceholder with real geometry at a fixed
    // devicePixelRatio / physicalSize, animations off, then
    //   await expectLater(
    //     find.byType(QuranPagePlaceholder),
    //     matchesGoldenFile('goldens/mushaf/page_001.png'),
    //   );
    // No master pixel is committed or auto-blessed here.
  });
}
