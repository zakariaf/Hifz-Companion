// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T06 (written first — the audit IS the deliverable): a chip with color +
// shape + label passes; a color-only chip fails; stripping either non-color
// channel (the shape/visual or the label) fails. If this did not fail the
// negative fixtures, the gate would assert nothing.

import 'package:features/features.dart'
    show ChipState, MihrabAppearance, StateChip, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '_a11y_test_bootstrap.dart';
import 'redundant_encoding_audit.dart';

Future<void> _pump(WidgetTester tester, Widget chip) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(
        body: Center(child: chip),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  useOfflineTestPolicy();

  testWidgets('a color + shape + label chip passes the audit', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const StateChip(state: ChipState.weak));
    assertStateChipRedundancy(tester, find.byType(StateChip));
    handle.dispose();
  });

  testWidgets('a color-only chip fails the audit', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      Container(
        key: const Key('colorOnly'),
        width: 40,
        height: 24,
        color: const Color(0xFF00FF00),
      ),
    );
    expect(
      () =>
          assertStateChipRedundancy(tester, find.byKey(const Key('colorOnly'))),
      throwsA(isA<TestFailure>()),
    );
    handle.dispose();
  });

  testWidgets('stripping the shape/visual channel fails the audit', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    // A labeled color box but no icon/text/paint — label present, visual absent.
    await _pump(
      tester,
      Semantics(
        label: 'weak',
        child: Container(
          key: const Key('labelOnly'),
          width: 40,
          height: 24,
          color: const Color(0xFF00FF00),
        ),
      ),
    );
    expect(
      () =>
          assertStateChipRedundancy(tester, find.byKey(const Key('labelOnly'))),
      throwsA(isA<TestFailure>()),
    );
    handle.dispose();
  });

  testWidgets('stripping the label channel fails the audit', (tester) async {
    final handle = tester.ensureSemantics();
    // An icon with its semantics excluded — visual present, label absent.
    await _pump(
      tester,
      Container(
        key: const Key('iconNoLabel'),
        width: 40,
        height: 24,
        color: const Color(0xFF00FF00),
        child: const ExcludeSemantics(child: Icon(Icons.eco_outlined)),
      ),
    );
    expect(
      () => assertStateChipRedundancy(
        tester,
        find.byKey(const Key('iconNoLabel')),
      ),
      throwsA(isA<TestFailure>()),
    );
    handle.dispose();
  });
}
