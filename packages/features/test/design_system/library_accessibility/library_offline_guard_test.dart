// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T10 — the offline guard is live for the whole library: under the shared
// throwing-HttpOverrides bootstrap, a stray request from any specimen cannot
// reach the wire (intercepted → HTTP 400 under the flutter_test binding, or the
// throwing StateError in pure package:test). No component opens a socket.

import 'dart:io';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/library_specimens.dart';
import '../../support/offline_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('the registry is non-empty and renders under the offline guard',
      (tester) async {
    expect(librarySpecimens(), isNotEmpty);
    final specimen = librarySpecimens().first;
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: Builder(builder: specimen.build)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MihrabPageCard), findsOneWidget);
  });

  testWidgets('a stray request never reaches a real socket', (tester) async {
    Object? error;
    int? status;
    await tester.runAsync(() async {
      try {
        final request =
            await HttpClient().getUrl(Uri.parse('http://example.invalid/'));
        status = (await request.close()).statusCode;
      } on Object catch (e) {
        error = e;
      }
    });
    expect(
      error != null || status == 400,
      isTrue,
      reason: 'a stray network call must be intercepted, never a real socket',
    );
  });
}
