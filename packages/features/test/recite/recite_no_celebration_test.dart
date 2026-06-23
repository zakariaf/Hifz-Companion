// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Committing a grade fires only haptic.confirm (lightImpact) — never a success
// or heavy haptic, no confetti/streak. The Good path is the same code path as
// Again. Driven through the real screen over a minimal router.

import 'package:features/features.dart'
    show MihrabAppearance, ReciteGradeScreen, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();

  testWidgets('a committed grade fires only the calm confirm haptic', (t) async {
    final haptics = <String>[];
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String? ?? 'vibrate');
        }
        return null;
      },
    );
    addTearDown(
      () => t.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final router = GoRouter(
      initialLocation: '/today',
      routes: <RouteBase>[
        GoRoute(
          path: '/today',
          builder: (_, __) => const Scaffold(body: Text('today')),
        ),
        GoRoute(
          path: '/r/:id',
          builder: (c, s) =>
              ReciteGradeScreen(pageId: int.parse(s.pathParameters['id']!)),
        ),
      ],
    );

    await t.pumpWidget(
      UncontrolledProviderScope(
        container: reciteContainer(
          cards: StubCards(reciteCard()),
          reviews: RecordingReviews(),
        ),
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
        ),
      ),
    );
    router.push('/r/42');
    await t.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    // Reveal a line so the band enables, then commit a grade.
    await t.tap(find.bySemanticsLabel(l10n.reciteRevealHint).first);
    await t.pumpAndSettle();
    haptics.clear();
    await t.tap(find.byType(FilledButton).first);
    await t.pumpAndSettle();

    // Only the calm confirm — never a heavy/medium success haptic.
    expect(haptics, contains('HapticFeedbackType.lightImpact'));
    expect(haptics, isNot(contains('HapticFeedbackType.heavyImpact')));
    expect(haptics, isNot(contains('HapticFeedbackType.mediumImpact')));
  });
}
