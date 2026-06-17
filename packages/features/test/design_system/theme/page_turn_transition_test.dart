// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

const _keyA = Key('page-a');
const _keyB = Key('page-b');

Future<void> _pump(
  WidgetTester tester,
  bool reduced,
  TextDirection direction,
  Key pageKey,
) {
  return tester.pumpWidget(
    _harness(reduced: reduced, direction: direction, pageKey: pageKey),
  );
}

Widget _harness({
  required bool reduced,
  required TextDirection direction,
  required Key pageKey,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Directionality(
      textDirection: direction,
      child: Theme(
        data: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[MotionTokens.standard()],
        ),
        child: Center(
          child: PageTurnTransition(
            child: SizedBox(key: pageKey, width: 100, height: 100),
          ),
        ),
      ),
    ),
  );
}

void main() {
  useOfflineTestPolicy();

  testWidgets('reduce-motion: an instant cut, no slid/faded frame', (
    tester,
  ) async {
    await _pump(tester, true, TextDirection.rtl, _keyA);
    await _pump(tester, true, TextDirection.rtl, _keyB);
    await tester.pump(); // a single frame

    expect(find.byKey(_keyA), findsNothing); // old page already gone
    expect(find.byKey(_keyB), findsOneWidget); // new page fully present
  });

  testWidgets('animated path differs: an in-between frame exists', (
    tester,
  ) async {
    await _pump(tester, false, TextDirection.rtl, _keyA);
    await _pump(tester, false, TextDirection.rtl, _keyB);
    await tester.pump(const Duration(milliseconds: 125)); // mid-transition

    // Both pages are on screen mid-slide — genuinely different from the cut.
    expect(find.byKey(_keyA), findsOneWidget);
    expect(find.byKey(_keyB), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300)); // settle
  });

  testWidgets('RTL: incoming enters from start (right), outgoing exits to end',
      (tester) async {
    await _pump(tester, false, TextDirection.rtl, _keyA);
    await _pump(tester, false, TextDirection.rtl, _keyB);
    await tester.pump(const Duration(milliseconds: 100)); // mid-transition

    final incomingX = tester.getTopLeft(find.byKey(_keyB)).dx;
    final outgoingX = tester.getTopLeft(find.byKey(_keyA)).dx;
    await tester.pump(const Duration(milliseconds: 400)); // settle
    final restingX = tester.getTopLeft(find.byKey(_keyB)).dx;

    expect(incomingX, greaterThan(restingX)); // came in from the right (start)
    expect(outgoingX, lessThan(restingX)); // leaving toward the left (end)
  });

  testWidgets('LTR mirrors: incoming enters from the left', (tester) async {
    await _pump(tester, false, TextDirection.ltr, _keyA);
    await _pump(tester, false, TextDirection.ltr, _keyB);
    await tester.pump(const Duration(milliseconds: 100));

    final incomingX = tester.getTopLeft(find.byKey(_keyB)).dx;
    await tester.pump(const Duration(milliseconds: 400));
    final restingX = tester.getTopLeft(find.byKey(_keyB)).dx;

    expect(incomingX, lessThan(restingX)); // mirror of RTL: from the left
  });
}
