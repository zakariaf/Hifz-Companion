// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T09 — the destructive-confirm gate: safe Cancel is primary + focused, the
// destructive trigger is a plainer secondary one deliberate step away, eraseAll
// needs a second gesture, the consequence is concrete, completion is quiet, and
// the leaf performs no wipe (reports intent only).

import 'dart:io';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

Future<DestructiveConfirmStrings> _strings(
  DestructiveAction action,
) async {
  final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
  return switch (action) {
    DestructiveAction.eraseAll => DestructiveConfirmStrings(
        consequence: l10n.destructiveEraseAllConsequence,
        confirmLabel: l10n.destructiveEraseAllConfirm,
        cancelLabel: l10n.destructiveKeepData,
        secondConsequence: l10n.destructiveEraseAllSecondConsequence,
        secondConfirmLabel: l10n.destructiveEraseAllSecondConfirm,
      ),
    DestructiveAction.wipeProfile => DestructiveConfirmStrings(
        consequence: l10n.destructiveWipeProfileConsequence,
        confirmLabel: l10n.destructiveWipeProfileConfirm,
        cancelLabel: l10n.destructiveKeepData,
      ),
    DestructiveAction.abortDiscard => DestructiveConfirmStrings(
        consequence: l10n.destructiveAbortConsequence,
        confirmLabel: l10n.destructiveAbortConfirm,
        cancelLabel: l10n.destructiveKeepData,
      ),
  };
}

Widget _host(
  DestructiveAction action,
  DestructiveConfirmStrings strings, {
  VoidCallback? onConfirmed,
  VoidCallback? onCancelled,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: Scaffold(
      body: DestructiveConfirmSheet(
        action: action,
        strings: strings,
        onConfirmed: onConfirmed ?? () {},
        onCancelled: onCancelled ?? () {},
      ),
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets(
      'safe path primary — Cancel is the FilledButton, focus ring on it',
      (tester) async {
    final strings = await _strings(DestructiveAction.eraseAll);
    await tester.pumpWidget(_host(DestructiveAction.eraseAll, strings));
    // Cancel is the filled (primary) button; the destructive is a TextButton.
    expect(
      find.widgetWithText(FilledButton, strings.cancelLabel),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextButton, strings.confirmLabel),
      findsOneWidget,
    );
    expect(find.byType(MihrabFocusRing), findsOneWidget);
  });

  testWidgets('the consequence is concrete (not a bare "Are you sure?")',
      (tester) async {
    final strings = await _strings(DestructiveAction.eraseAll);
    await tester.pumpWidget(_host(DestructiveAction.eraseAll, strings));
    expect(find.text(strings.consequence), findsOneWidget);
  });

  testWidgets('eraseAll needs a second deliberate gesture', (tester) async {
    final strings = await _strings(DestructiveAction.eraseAll);
    var confirms = 0;
    await tester.pumpWidget(
      _host(DestructiveAction.eraseAll, strings, onConfirmed: () => confirms++),
    );
    // First tap on the destructive trigger advances — does NOT confirm.
    await tester.tap(find.widgetWithText(TextButton, strings.confirmLabel));
    await tester.pump();
    expect(confirms, 0);
    expect(find.text(strings.secondConfirmLabel!), findsOneWidget);
    // The second deliberate gesture confirms.
    await tester
        .tap(find.widgetWithText(TextButton, strings.secondConfirmLabel!));
    expect(confirms, 1);
  });

  testWidgets('wipeProfile confirms in one step; Cancel is one tap',
      (tester) async {
    final strings = await _strings(DestructiveAction.wipeProfile);
    var confirms = 0;
    var cancels = 0;
    await tester.pumpWidget(
      _host(
        DestructiveAction.wipeProfile,
        strings,
        onConfirmed: () => confirms++,
        onCancelled: () => cancels++,
      ),
    );
    await tester.tap(find.widgetWithText(TextButton, strings.confirmLabel));
    expect(confirms, 1);
    await tester.tap(find.widgetWithText(FilledButton, strings.cancelLabel));
    expect(cancels, 1);
  });

  testWidgets('quiet completion — no celebration glyph', (tester) async {
    final strings = await _strings(DestructiveAction.eraseAll);
    await tester.pumpWidget(_host(DestructiveAction.eraseAll, strings));
    for (final icon in const [
      Icons.star,
      Icons.celebration,
      Icons.auto_awesome,
    ]) {
      expect(find.byIcon(icon), findsNothing);
    }
  });

  test('the leaf performs no wipe — no data/drift/review_log reference', () {
    for (final base in const [
      'packages/features/lib/src/design_system/components',
      '../../packages/features/lib/src/design_system/components',
    ]) {
      final file = File('$base/destructive_confirm.dart');
      if (!file.existsSync()) continue;
      final src = file.readAsStringSync();
      for (final banned in const [
        'package:engine',
        'package:data',
        'package:drift',
        'review_log',
      ]) {
        expect(
          src.contains(banned),
          isFalse,
          reason: 'must not reference $banned',
        );
      }
      return;
    }
    fail('destructive_confirm.dart not found from ${Directory.current}');
  });

  testWidgets('>=48dp labelled targets (meetsLibraryGuidelines)',
      (tester) async {
    final handle = tester.ensureSemantics();
    final strings = await _strings(DestructiveAction.wipeProfile);
    await tester.pumpWidget(_host(DestructiveAction.wipeProfile, strings));
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });
}
