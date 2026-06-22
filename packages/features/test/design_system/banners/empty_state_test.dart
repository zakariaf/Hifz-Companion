// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T08 — the empty-state family: firstRun (calm fact + one gentle invitation),
// allDone (one calm line, no celebration), silentResume (NOTHING — no greeting,
// no day-count, the absence of a reproach).

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/offline_test_bootstrap.dart';
import 'catch_up_banner_test.dart' show assertNoBannedPhrase;

Widget _host(EmptyStateModel model) => MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(body: Center(child: EmptyState(model: model))),
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('firstRun shows the fact + exactly one gentle next step',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    final tapped = <bool>[];
    await tester.pumpWidget(
      _host(
        EmptyStateModel(
          kind: EmptyStateKind.firstRun,
          body: l10n.emptyFirstRunBody,
          actionLabel: l10n.emptyFirstRunAction,
          onAction: () => tapped.add(true),
        ),
      ),
    );
    expect(find.text(l10n.emptyFirstRunBody), findsOneWidget);
    expect(find.text(l10n.emptyFirstRunAction), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    await tester.tap(find.text(l10n.emptyFirstRunAction));
    expect(tapped, [true]);
    assertNoBannedPhrase(tester);
  });

  testWidgets('allDone is one calm line, no celebration', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.pumpWidget(
      _host(
        EmptyStateModel(kind: EmptyStateKind.allDone, body: l10n.emptyAllDone),
      ),
    );
    expect(find.text(l10n.emptyAllDone), findsOneWidget);
    final scheme =
        Theme.of(tester.element(find.byType(EmptyState))).colorScheme;
    expect(
      tester.widget<Text>(find.text(l10n.emptyAllDone)).style?.color,
      scheme.onSurfaceVariant,
    );
    expect(find.byType(FilledButton), findsNothing);
    for (final icon in const [
      Icons.star,
      Icons.celebration,
      Icons.auto_awesome,
    ]) {
      expect(find.byIcon(icon), findsNothing);
    }
    assertNoBannedPhrase(tester);
  });

  testWidgets('silentResume renders nothing — no greeting, no day-count',
      (tester) async {
    await tester.pumpWidget(
      _host(const EmptyStateModel(kind: EmptyStateKind.silentResume)),
    );
    // No text node at all — the welcome-back face is the absence of a reproach.
    expect(find.byType(Text), findsNothing);
    expect(find.byType(SizedBox), findsWidgets); // the shrink
  });
}
