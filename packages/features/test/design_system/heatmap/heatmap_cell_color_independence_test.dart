// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T04 — the hard color-independence gate §4 makes for THIS component (A3):
// the five-step ramp must read by lightness alone (so the order survives
// grayscale AND a deuteranope's hue loss), every cell must still carry its text
// value + label, and the strong glance anchor must clear the 3:1 non-text floor.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  for (final appearance in MihrabAppearance.values) {
    test(
        'the ramp is monotonic in luminance — reads without hue '
        '(${appearance.name})', () {
      final colors = mihrabColorsFor(appearance);
      final luminance = [
        for (final level in HeatLevel.values)
          relativeLuminance(heatRampColor(colors, level)),
      ];
      // The ramp is strictly MONOTONIC in luminance — increasing on the light
      // appearances (strong = dark green → faded = light neutral) and decreasing
      // on dark/night (strong = light green → faded = dark neutral). Either way
      // the magnitude order reads by lightness alone, so it survives grayscale
      // AND a deuteranope's hue loss (A3).
      var increasing = true;
      var decreasing = true;
      for (var i = 1; i < luminance.length; i++) {
        if (luminance[i] <= luminance[i - 1]) increasing = false;
        if (luminance[i] >= luminance[i - 1]) decreasing = false;
      }
      expect(
        increasing || decreasing,
        isTrue,
        reason: 'the ramp must be strictly monotonic in luminance '
            '(${appearance.name}): $luminance',
      );
    });

    test(
        'the strong glance anchor clears the 3:1 non-text floor '
        '(${appearance.name})', () {
      final colors = mihrabColorsFor(appearance);
      final scheme = colorSchemeFor(appearance);
      expect(
        contrastRatio(colors.heatmapStrong, scheme.surface),
        greaterThanOrEqualTo(3),
        reason: '${appearance.name}: heatmap.strong vs surface must clear 3:1',
      );
    });
  }

  testWidgets('every ramp step still carries its text value + label',
      (tester) async {
    for (final level in HeatLevel.values) {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: Scaffold(
            body: Center(
              child: HeatmapCell(
                data: HeatmapCellData(
                  level: level,
                  localizedValue: '٨٠٪',
                  label: 'L-${level.name}',
                  everReviewed: true,
                  sourceConfidence: 1,
                ),
              ),
            ),
          ),
        ),
      );
      // The meaning rides on the text value + label, never colour alone (A3).
      assertColorIndependent(tester, labels: ['L-${level.name}']);
    }
  });
}
