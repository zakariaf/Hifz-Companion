// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The discrimination-drill real-font fidelity golden matrix (E14-T12). It
// renders the DiscriminationDrillView for one fixed confusable group across the
// choreography states — sibling hidden → revealed → anchor highlight, and the
// next sibling back-to-back — under Directionality.rtl for ar / fa / ckb,
// loading the REAL bundled KFGQPC per-page fonts + UI fonts via FontLoader
// (never Ahem, which draws solid squares and would silently pass a re-typeset
// āyah, a shifted diacritic, or a moved anchor box).
//
// DEFERRED (bundle-first): the ~40–55 MB KFGQPC TTF page fonts and the per-word
// page geometry are not committed yet (the core asset pack lands with E05's
// verified bundle; see E05-T11 + the bundle-core decision). Without the real
// fonts a fidelity golden cannot be authored — the page renders blank and the
// anchor resolves to no box (empty geometry) — and Ahem is forbidden on the
// sacred surface, so this matrix is scaffolded and SKIPPED until the fonts +
// geometry land. The drill's behaviour (reveal-on-tap state machine, whole-group
// order, no isolated sibling), the anchor Rect resolver, and the transcreated
// chrome are meanwhile proven by the widget/unit suites in E14-T08/T09/T11.
//
// To enable when the assets land: remove `skip`, FontLoader-load the real
// KFGQPC page font(s) + the fa/ckb/ar UI fonts in setUpAll, feed the drill page
// geometry provider real per-word boxes, pin DPR/physicalSize/theme, disable
// animations, inject a fixed today, seed the read models from in-memory fakes,
// and regenerate masters locally with --update-goldens (reviewed, never blessed
// in CI). The anchor frame is the load-bearing fidelity check: the highlight Rect
// must sit on the distinguishing word over rendered glyphs, never re-typeset text
// (PRD R1, §11.2; science 05 §6; C-028/C-029).
@Tags(['golden'])
@Skip(
  'deferred: real KFGQPC page fonts + per-word geometry land with the asset '
  'pack (E05-T11); fidelity goldens forbid Ahem — enable when committed.',
)
library;

import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  // The matrix rows, named for their eventual master files under
  // goldens/drill/<state>_<locale>.png — captured per locale [ar, fa, ckb]
  // under Directionality.rtl, the muṣḥaf glyph layer byte-identical across
  // locales while only the chrome mirrors:
  //
  //   hidden_<locale>.png       — sibling A concealed (reveal-on-tap surface)
  //   revealed_<locale>.png     — after the reveal tap (pump motion.short), the
  //                               immutable glyph page, still no anchor
  //   anchor_<locale>.png       — the anchor Rect over the distinguishing word
  //   next_sibling_<locale>.png — sibling B back-to-back, no interstitial
  //
  // each: await expectLater(find.byType(DiscriminationDrillScreen),
  //         matchesGoldenFile('goldens/drill/<state>_<locale>.png'));
}
