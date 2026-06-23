// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader's real-font fidelity golden matrix (E13-T10). It renders the
// assembled reader page across ReaderTheme.{light,sepia,dark} × {overlays off,
// overlays on} × {base zoom, one zoom step} under an RTL Directionality, loading
// the REAL bundled KFGQPC per-page fonts + UI fonts via FontLoader (never Ahem,
// which draws solid squares and would silently pass a corrupted page).
//
// DEFERRED (bundle-first): the ~40–55 MB KFGQPC TTF page fonts are not committed
// yet (the core asset pack lands with E05's verified download / build-time
// bundle; see E05-T11 + the bundle-core decision). Without the real fonts a
// fidelity golden cannot be authored — the page renders blank and Ahem is
// forbidden here — so this matrix is scaffolded and SKIPPED until the fonts
// land. The reader meanwhile inherits E05's 604-page visual-diff coverage and
// adds NO re-rendered reference set of its own (the epic DoD).
//
// To enable when the fonts land: remove `skip`, load the real fonts in
// setUpAll via FontLoader, pin DPR/physicalSize/theme, disable animations, and
// regenerate masters locally with --update-goldens (reviewed, never blessed in
// CI). The structural chrome (theme/zoom/overlay frame, riwāyah label, no
// dashboard) is already proven by the widget suites in E13-T05/T06/T07/T08.
@Tags(['golden'])
@Skip(
  'deferred: real KFGQPC page fonts land with the asset pack (E05-T11); '
  'fidelity goldens forbid Ahem — enable when the fonts are committed.',
)
library;

import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // The matrix rows, named for their eventual master files:
  //   reader_p001_{light,sepia,dark}_zoom{100,120}_overlays_{off,on}.png
  // each: await expectLater(find.byType(MushafReaderScreen),
  //         matchesGoldenFile('goldens/mushaf/reader_...png'));
  testWidgets(
    'real-font reader page matrix (light/sepia/dark × overlays × zoom)',
    (tester) async {},
  );
}
