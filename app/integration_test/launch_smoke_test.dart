// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:app/app.dart';
import 'package:app/placeholder/placeholder_screen.dart';
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
  // — those land with their feature epics; a fifth needs a decision-log
  // amendment.
  testWidgets('the app launches to the placeholder shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HifzApp()));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderScreen), findsOneWidget);
  });
}
