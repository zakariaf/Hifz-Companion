// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T10: proof the gate checks SOMETHING, not nothing — a GREEN test that
// asserts the guideline matchers correctly REJECT deliberately-broken throwaway
// stubs and ACCEPT a proper control. The full deliberate-violation procedure
// (breaking the real shell, then reverting) is recorded in README.md; this self-
// test keeps the four-jobs-green DoD while still proving the gate is not vacuous.

import 'package:features/features.dart' show ChipState, StateChip, labeled;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'accessibility_audit.dart';
import 'redundant_encoding_audit.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pump();
}

void main() {
  useOfflineTestPolicy();

  testWidgets('an unlabeled, sub-48dp control is REJECTED by the guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      SizedBox(
        width: 40, // below the 48dp / 44pt floor
        height: 40,
        child: GestureDetector(
          onTap: () {},
          child: const ColoredBox(color: Color(0xFF888888)),
        ),
      ),
    );

    expect(
      (await androidTapTargetGuideline.evaluate(tester)).passed,
      isFalse,
      reason: 'A6: a 40dp target must fail the 48dp guideline',
    );
    expect(
      (await iOSTapTargetGuideline.evaluate(tester)).passed,
      isFalse,
      reason: 'A6: a 40pt target must fail the 44pt guideline',
    );
    expect(
      (await labeledTapTargetGuideline.evaluate(tester)).passed,
      isFalse,
      reason: 'A7: an unlabeled tappable must fail the labeled guideline',
    );
    handle.dispose();
  });

  testWidgets('a proper labeled 48dp control is ACCEPTED (not vacuous)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      labeled(
        button: true,
        label: 'ok',
        child: GestureDetector(
          onTap: () {},
          child: const SizedBox(width: 56, height: 56),
        ),
      ),
    );

    expect((await androidTapTargetGuideline.evaluate(tester)).passed, isTrue);
    expect((await iOSTapTargetGuideline.evaluate(tester)).passed, isTrue);
    expect((await labeledTapTargetGuideline.evaluate(tester)).passed, isTrue);
    handle.dispose();
  });

  testWidgets('a color-only state chip is REJECTED by the redundancy audit', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      Container(
        key: const Key('colorOnly'),
        width: 40,
        height: 24,
        color: const Color(0xFF00AA00),
      ),
    );
    expect(
      () =>
          assertStateChipRedundancy(tester, find.byKey(const Key('colorOnly'))),
      throwsA(isA<TestFailure>()),
      reason:
          'A3/§4: a colour-only state must fail the never-color-alone audit',
    );
    handle.dispose();
  });

  testWidgets('a proper StateChip is ACCEPTED by the redundancy audit', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const StateChip(state: ChipState.due));
    assertStateChipRedundancy(tester, find.byType(StateChip));
    handle.dispose();
  });
}
