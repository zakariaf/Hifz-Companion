// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T04 — the heat-map cell's rule surface across fa/ckb/ar × the four
// appearances on the real bundled fonts, plus a 200% reflow pass: the muted
// frames are visibly less saturated than the strong frame, and the juz roll-up
// frame shows the weakest-page badge at the start. Reuses pumpComponentMatrix —
// no re-implemented loop. Linux lane only.

import 'package:features/features.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

ComponentSpecimen _spec(
  String name,
  HeatLevel level, {
  bool everReviewed = true,
  double confidence = 1,
  bool isJuzRollUp = false,
  int? weakestPageId,
  bool tappable = false,
}) =>
    ComponentSpecimen(
      name: name,
      build: (context) {
        final l10n = AppLocalizations.of(context);
        final locale = Localizations.localeOf(context);
        return HeatmapCell(
          data: HeatmapCellData(
            level: level,
            localizedValue: everReviewed
                ? formatLocaleNumber(locale, 85)
                : l10n.decayNeedsRevision,
            label: level == HeatLevel.strong
                ? l10n.decaySteady
                : l10n.decayNeedsRevision,
            everReviewed: everReviewed,
            sourceConfidence: confidence,
            isJuzRollUp: isJuzRollUp,
            weakestPageId: weakestPageId,
          ),
          onTap: tappable ? () {} : null,
        );
      },
    );

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'heatmap_cell',
      specimens: [
        _spec('strong', HeatLevel.strong),
        _spec('good', HeatLevel.good),
        _spec('fair', HeatLevel.fair),
        _spec('weak', HeatLevel.weak),
        _spec('faded', HeatLevel.faded),
        _spec('muted_never_reviewed', HeatLevel.strong, everReviewed: false),
        _spec('muted_self_rating_only', HeatLevel.strong, confidence: 0.5),
        _spec(
          'juz_rollup_with_weak_badge',
          HeatLevel.weak,
          isJuzRollUp: true,
          weakestPageId: 253,
        ),
        _spec('tappable', HeatLevel.good, tappable: true),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('heat-map cell rule surface across locale × appearance',
      (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
