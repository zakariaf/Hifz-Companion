// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T06 — the seven-grade × three-locale golden matrix proving the neutral
// (non-traffic-light) styling is identical across grades, plus a legend frame
// with no star key; the ckb (longest) transcreation reflows at 200%. Reuses
// pumpComponentMatrix. Linux lane only.

import 'package:features/features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

ComponentSpecimen _grade(String name, EvidenceGrade grade) => ComponentSpecimen(
      name: name,
      build: (context) => CertaintyLabel(
        grade: grade,
        strings: CertaintyStrings.of(AppLocalizations.of(context)),
      ),
    );

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'certainty_label',
      specimens: [
        _grade('ma', EvidenceGrade.ma),
        _grade('rct', EvidenceGrade.rct),
        _grade('exp', EvidenceGrade.exp),
        _grade('cs', EvidenceGrade.cs),
        _grade('obs', EvidenceGrade.obs),
        _grade('text', EvidenceGrade.text),
        _grade('trad', EvidenceGrade.trad),
        ComponentSpecimen(
          name: 'legend',
          build: (context) {
            final l10n = AppLocalizations.of(context);
            return CertaintyLegend(
              strings: CertaintyStrings.of(l10n),
              title: l10n.certaintyLegendTitle,
            );
          },
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('certainty label seven-grade matrix + legend', (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
