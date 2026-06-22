// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T05 — the grade band's renderable states across fa/ckb/ar × the four
// appearances + a 200% reflow pass: enabled (the four verbs, RTL, no celebration)
// and disabled (the calm waiting hint, not an error). The pressed/focused states
// are interaction-driven and asserted in grade_band_test (forcing them in a
// static multi-frame golden is fragile). Reuses pumpComponentMatrix. Linux lane.

import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'grade_band',
      specimens: [
        ComponentSpecimen(
          name: 'enabled',
          build: (context) => GradeBand(enabled: true, onGrade: (_) {}),
        ),
        ComponentSpecimen(
          name: 'disabled',
          build: (context) => GradeBand(enabled: false, onGrade: (_) {}),
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('grade band states across locale × appearance', (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
