// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T05 — the teacher sign-off toggle's {off, on} states across fa/ckb/ar ×
// the four appearances + a 200% reflow pass; the off frame is the canonical
// default. Reuses pumpComponentMatrix. Linux lane only.

import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'teacher_signoff_toggle',
      specimens: [
        ComponentSpecimen(
          name: 'off',
          build: (context) =>
              TeacherSignoffToggle(teacherPresent: false, onChanged: (_) {}),
        ),
        ComponentSpecimen(
          name: 'on',
          build: (context) =>
              TeacherSignoffToggle(teacherPresent: true, onChanged: (_) {}),
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('teacher sign-off toggle states across locale × appearance',
      (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
