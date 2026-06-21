// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T02 — proves the reusable golden scaffold itself is deterministic,
// RTL-correct, real-font (Vazirmatn, never Ahem), and reflow-safe BEFORE any
// component depends on it: pumpComponentMatrix over a small reference specimen
// set produces the fa/ckb/ar × Light/Sepia/Dark/Night matrix plus the 200%
// pass. These are scaffold reference frames, not a shipped component. Pinned
// Linux golden lane only; masters regenerate via local --update-goldens.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden_matrix.dart';
import '../support/offline_test_bootstrap.dart';

ComponentStateMatrix _reference() => ComponentStateMatrix(
      component: 'scaffold_reference',
      specimens: [
        ComponentSpecimen(
          name: 'enabled',
          build: (context) =>
              FilledButton(onPressed: () {}, child: const Text('بەڵێ')),
        ),
        ComponentSpecimen(
          name: 'disabled',
          build: (context) =>
              const FilledButton(onPressed: null, child: Text('ناچالاک')),
        ),
        ComponentSpecimen(
          name: 'focused',
          build: (context) => MihrabFocusRing(
            child: Focus(
              autofocus: true,
              child: FilledButton(onPressed: () {}, child: const Text('فۆکەس')),
            ),
          ),
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();

  setUpAll(loadMihrabUiFonts);

  testWidgets('the golden scaffold renders its reference matrix',
      (tester) async {
    await pumpComponentMatrix(tester, matrix: _reference());
  });
}
