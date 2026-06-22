// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T10 — the library-wide accessibility + honesty gate (fast lane). It runs
// EVERY shipped component through meetsLibraryGuidelines (A1/A6/A7) across the
// four appearances (Sepia included) and sweeps the whole library for the
// cross-cutting honesty invariants no single-component test can guarantee: no
// leaked retention number, no gamification glyph, RTL by construction.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/library_specimens.dart';
import '../../support/offline_test_bootstrap.dart';

Widget _host(
  ComponentSpecimen specimen, {
  required MihrabAppearance appearance,
  required Locale locale,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    // Force the Material switches so the gate is platform-stable (Switch.adaptive
    // would render a CupertinoSwitch on the macOS dev host).
    theme:
        mihrabThemeFor(appearance).copyWith(platform: TargetPlatform.android),
    home: Scaffold(
      body: SingleChildScrollView(child: Builder(builder: specimen.build)),
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  test('every shipped component is registered — a missing one fails the build',
      () {
    final names = librarySpecimens().map((s) => s.name).toSet();
    expect(librarySpecimens(), isNotEmpty);
    for (final component in expectedLibraryComponents) {
      expect(
        names.contains(component),
        isTrue,
        reason: '$component is not registered in librarySpecimens()',
      );
    }
  });

  group('A1/A6/A7 — meetsLibraryGuidelines over the whole library', () {
    for (final specimen in librarySpecimens()) {
      for (final appearance in MihrabAppearance.values) {
        testWidgets('${specimen.name} @ ${appearance.name} (ckb)',
            (tester) async {
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(
            _host(
              specimen,
              appearance: appearance,
              locale: const Locale('ckb'),
            ),
          );
          await tester.pumpAndSettle();
          await meetsLibraryGuidelines(tester);
          handle.dispose();
        });
      }
    }
  });

  group('cross-cutting honesty / no-gamification sweep (PRD §7.12; R3, C6)',
      () {
    for (final specimen in librarySpecimens()) {
      testWidgets('${specimen.name} leaks no number / gamifies nothing',
          (tester) async {
        await tester.pumpWidget(
          _host(
            specimen,
            appearance: MihrabAppearance.light,
            locale: const Locale('ar'),
          ),
        );
        await tester.pumpAndSettle();
        for (final t in tester.widgetList<Text>(find.byType(Text))) {
          final value = t.data ?? '';
          expect(value.contains('%'), isFalse, reason: '${specimen.name}: %');
          expect(value.contains('٪'), isFalse, reason: '${specimen.name}: ٪');
          expect(value.contains('!'), isFalse, reason: '${specimen.name}: !');
        }
        for (final icon in const [
          Icons.star,
          Icons.emoji_events,
          Icons.celebration,
          Icons.local_fire_department,
          Icons.auto_awesome,
        ]) {
          expect(
            find.byIcon(icon),
            findsNothing,
            reason: '${specimen.name}: no gamification glyph',
          );
        }
      });
    }
  });

  group('RTL by construction (A8) across fa/ckb/ar', () {
    for (final locale in const [Locale('fa'), Locale('ckb'), Locale('ar')]) {
      testWidgets('the library composes RTL (${locale.languageCode})',
          (tester) async {
        final specimen = librarySpecimens().first;
        await tester.pumpWidget(
          _host(specimen, appearance: MihrabAppearance.light, locale: locale),
        );
        await tester.pumpAndSettle();
        expect(
          Directionality.of(tester.element(find.byType(MihrabPageCard))),
          TextDirection.rtl,
        );
      });
    }
  });
}
