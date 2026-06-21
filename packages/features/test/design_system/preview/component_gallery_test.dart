// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T02 — the host-less gallery harness: it renders any component's full named
// state set as a labeled list with NO MaterialApp route and NO Riverpod store,
// and it references no engine/date/persistence/quran symbol (a structural
// import-scope check), so a leaf can be previewed in isolation.

import 'dart:io';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/offline_test_bootstrap.dart';

ComponentStateMatrix _fixture() => ComponentStateMatrix(
      component: 'fixture',
      specimens: [
        ComponentSpecimen(
          name: 'one',
          build: (context) => const Text('first'),
        ),
        ComponentSpecimen(
          name: 'two',
          build: (context) => const Text('second'),
        ),
        ComponentSpecimen(
          name: 'three',
          build: (context) => const Text('third'),
        ),
      ],
    );

Widget _bare(Widget child, {TextDirection dir = TextDirection.rtl}) {
  // The minimum context a leaf needs — NO MaterialApp, NO router, NO provider.
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(
      textDirection: dir,
      child: Theme(data: mihrabThemeFor(MihrabAppearance.light), child: child),
    ),
  );
}

void main() {
  useOfflineTestPolicy();

  testWidgets('renders each specimen with its caption, host-less under RTL',
      (tester) async {
    await tester.pumpWidget(_bare(ComponentGallery(matrix: _fixture())));
    await tester.pump();

    // Built with no MaterialApp ancestor at all (truly host-less).
    expect(find.byType(MaterialApp), findsNothing);
    // Every state's caption and its specimen content is present.
    for (final caption in const ['one', 'two', 'three']) {
      expect(find.text(caption), findsOneWidget);
    }
    for (final content in const ['first', 'second', 'third']) {
      expect(find.text(content), findsOneWidget);
    }
  });

  test('the gallery source imports no engine/date/persistence/quran symbol',
      () {
    // Structural: the preview harness must stay domain-blind (epic Out-of-scope).
    for (final base in const [
      'packages/features/lib/src/design_system',
      '../../packages/features/lib/src/design_system',
    ]) {
      final gallery = File('$base/preview/component_gallery.dart');
      final state = File('$base/state/mihrab_state_layer.dart');
      if (!gallery.existsSync()) continue;
      for (final src in [gallery, state]) {
        final text = src.readAsStringSync();
        for (final banned in const [
          'package:engine',
          'package:data',
          'package:drift',
          'package:quran',
          'dart:io',
          'CalendarDate',
        ]) {
          expect(
            text.contains(banned),
            isFalse,
            reason: '${src.path} must not reference $banned',
          );
        }
      }
      return;
    }
    fail('component_gallery.dart not found from ${Directory.current}');
  });
}
