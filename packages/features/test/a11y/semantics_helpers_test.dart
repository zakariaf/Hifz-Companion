// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Written first (E08-T02): the label/role/merge/exclude wrappers assert against
// the semantics tree — labeled exposes label/hint + the button/header flags;
// mergedItem collapses a two-Text child into one composed node; decoration
// produces no readable label.

import 'package:features/features.dart' show decoration, labeled, mergedItem;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_a11y_test_bootstrap.dart';

Widget _host(Widget child) => Directionality(
      textDirection: TextDirection.rtl,
      child: Center(child: child),
    );

void main() {
  useOfflineTestPolicy();

  testWidgets('labeled exposes label + hint + the button role', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        labeled(
          button: true,
          label: 'Today',
          hint: 'Opens the daily revision',
          child: GestureDetector(
            onTap: () {},
            child: const SizedBox(width: 80, height: 60),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(SizedBox)),
      isSemantics(
        label: 'Today',
        hint: 'Opens the daily revision',
        isButton: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('labeled marks a section title as a header', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        labeled(
          header: true,
          label: 'Far',
          child: const SizedBox(width: 80, height: 30),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(SizedBox)),
      isSemantics(label: 'Far', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('mergedItem collapses two Text children into one phrase', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        mergedItem(
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Muṣḥaf'), Text('being prepared')],
          ),
        ),
      ),
    );
    // The merged node carries both runs as one label, not two fragment nodes.
    expect(
      find.bySemanticsLabel(RegExp('Muṣḥaf.*being prepared', dotAll: true)),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('decoration produces no readable label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(decoration(child: const Text('ornament'))),
    );
    expect(
      find.bySemanticsLabel('ornament'),
      findsNothing,
      reason: 'decoration must be excluded from the semantics tree',
    );
    handle.dispose();
  });
}
