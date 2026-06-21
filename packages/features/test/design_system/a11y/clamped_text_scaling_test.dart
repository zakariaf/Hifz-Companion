// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T03: the clamp helper is a CEILING, not a disable — under a 3.0x OS scale
// the child sees the configured ceiling (still scaled, just bounded); without
// the wrapper the same child sees the full 3.0x; and it never collapses to
// TextScaler.noScaling.

import 'package:features/features.dart'
    show ClampedTextScaling, denseRowTextScaleCeiling;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

const _probe = Key('probe');

double _scaleSeenBy(WidgetTester tester) {
  final context = tester.element(find.byKey(_probe));
  // Probe the effective scale the child sees at a 10pt baseline.
  return MediaQuery.textScalerOf(context).scale(10) / 10;
}

void main() {
  useOfflineTestPolicy();

  testWidgets(
      'caps the child scale at the configured ceiling, still applying it',
      (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(3.0)),
        child: ClampedTextScaling(
          maxScaleFactor: 1.6,
          child: SizedBox(key: _probe),
        ),
      ),
    );

    final clamped = _scaleSeenBy(tester);
    expect(
      clamped,
      closeTo(1.6, 0.001),
      reason: 'scale is bounded to the ceiling, not the full 3.0x',
    );
    expect(
      clamped,
      greaterThan(1.0),
      reason: 'scaling is still applied — not noScaling/disabled',
    );
  });

  testWidgets('without the wrapper the child sees the full 3.0x',
      (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(3.0)),
        child: SizedBox(key: _probe),
      ),
    );
    expect(_scaleSeenBy(tester), closeTo(3.0, 0.001));
  });

  testWidgets('the default ceiling is the named dense-row ceiling', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(3.0)),
        child: ClampedTextScaling(child: SizedBox(key: _probe)),
      ),
    );
    expect(
      _scaleSeenBy(tester),
      closeTo(denseRowTextScaleCeiling, 0.001),
    );
  });
}
