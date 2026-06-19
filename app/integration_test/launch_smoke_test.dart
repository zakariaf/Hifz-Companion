// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:app/app.dart';
import 'package:composition/composition.dart';
import 'package:data/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The launch path performs no fetch, but keep the network blocked anyway.
  useOfflineTestPolicy();

  // A launch-succeeds smoke test only. This is explicitly NOT one of the four
  // PRD journeys (J1 cold start / J2 review / J3 teacher sign-off / J4 catch-up)
  // — the full seed → Today → grade spine journey lands in E07-T10.
  testWidgets('the app launches to onboarding on a fresh device',
      (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [persistenceProvider.overrideWithValue(handle)],
        child: const HifzApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('onboarding-stub')), findsOneWidget);
  });
}
