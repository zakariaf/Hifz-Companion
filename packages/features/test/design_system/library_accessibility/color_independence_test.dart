// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T10 — the A3 color-independence gate, library-wide. The heat ramp must read
// by LIGHTNESS alone (the channel that survives both grayscale and a deuteranope's
// hue loss), with the number + label as the non-visual channel. The teeth check
// proves a hue-coded (traffic-light) ramp FAILS the gate.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

bool _isMonotonic(List<double> values) {
  var increasing = true;
  var decreasing = true;
  for (var i = 1; i < values.length; i++) {
    if (values[i] <= values[i - 1]) increasing = false;
    if (values[i] >= values[i - 1]) decreasing = false;
  }
  return increasing || decreasing;
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  for (final appearance in MihrabAppearance.values) {
    test(
        'the heat ramp is strictly monotonic in luminance (${appearance.name})',
        () {
      final colors = mihrabColorsFor(appearance);
      final luminance = [
        for (final level in HeatLevel.values)
          relativeLuminance(heatRampColor(colors, level)),
      ];
      expect(
        _isMonotonic(luminance),
        isTrue,
        reason: 'the ramp must read by lightness alone (grayscale + CVD): '
            '$luminance',
      );
    });
  }

  test('teeth — a hue-coded (red→green) traffic-light ramp FAILS the gate', () {
    // The exact thing A3 forbids: meaning carried by hue, with yellow brightest
    // so luminance rises then falls — not monotonic, so the gate rejects it.
    const trafficLight = [
      Color(0xFFD32F2F), // red
      Color(0xFFF57C00), // orange
      Color(0xFFFBC02D), // yellow (brightest)
      Color(0xFF689F38), // green
      Color(0xFF2E7D32), // dark green
    ];
    final luminance = [for (final c in trafficLight) relativeLuminance(c)];
    expect(
      _isMonotonic(luminance),
      isFalse,
      reason: 'a hue-coded ramp must not pass the luminance-monotonicity gate',
    );
  });

  testWidgets(
      'the heat-map cell carries its number + label (non-visual channel)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: const Scaffold(
          body: Center(
            child: HeatmapCell(
              data: HeatmapCellData(
                level: HeatLevel.weak,
                localizedValue: '٨٥',
                label: 'LABEL',
                everReviewed: true,
                sourceConfidence: 1,
              ),
            ),
          ),
        ),
      ),
    );
    // Hue removed, the cell still reads from its value + label.
    assertColorIndependent(tester, labels: const ['LABEL']);
    expect(find.textContaining('٨٥'), findsWidgets);
  });
}
