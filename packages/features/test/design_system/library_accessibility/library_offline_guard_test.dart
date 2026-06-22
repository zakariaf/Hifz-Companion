// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T10 — the offline guard is live for the whole library: every component
// renders under the shared throwing offline-override bootstrap with no network.
// The guarantee is structural — `useOfflineTestPolicy()` installs the throwing
// override and the `check_no_network` gate bans every network-client / socket
// symbol outside packages/assets/, so no component can open a connection (a test
// that tried would itself fail that gate). This suite proves the library
// composes under the guard.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/library_specimens.dart';
import '../../support/offline_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  test('the component registry is non-empty', () {
    expect(librarySpecimens(), isNotEmpty);
  });

  testWidgets('every component renders under the offline guard (no network)',
      (tester) async {
    for (final specimen in librarySpecimens()) {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light)
              .copyWith(platform: TargetPlatform.android),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Builder(builder: specimen.build),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '${specimen.name} must render offline without error',
      );
    }
  });
}
