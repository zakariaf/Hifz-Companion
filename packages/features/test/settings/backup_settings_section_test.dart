// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E17-T08/T09 — the backup card + erase gate: NO cloud/sync/account chrome, the
// optional-encryption protective default, and the two-step erase whose SAFE
// cancel is primary and whose eraser fires only on the second confirm.

import 'package:composition/composition.dart'
    show LocalStoreEraser, localStoreEraserProvider;
import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

class _FakeEraser implements LocalStoreEraser {
  int calls = 0;

  @override
  Future<void> eraseEverything() async => calls++;
}

Future<AppLocalizations> _pump(
  WidgetTester tester, {
  LocalStoreEraser? eraser,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (eraser != null) localStoreEraserProvider.overrideWithValue(eraser),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: BackupSettingsSection()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return AppLocalizations.delegate.load(const Locale('ar'));
}

void main() {
  testWidgets('the backup card shows NO cloud / sync / account chrome', (tester) async {
    final l10n = await _pump(tester);
    for (final icon in <IconData>[
      Icons.cloud,
      Icons.cloud_outlined,
      Icons.cloud_upload,
      Icons.cloud_done,
      Icons.sync,
      Icons.account_circle,
    ]) {
      expect(find.byIcon(icon), findsNothing);
    }
    expect(find.text(l10n.backupExportAction), findsOneWidget);
    expect(find.text(l10n.backupImportAction), findsOneWidget);
    expect(find.text(l10n.eraseAllDataAction), findsOneWidget);
    expect(find.text(l10n.backupNoBackupYet), findsOneWidget);
  });

  testWidgets('the export sheet defaults encryption ON + states the tradeoff', (tester) async {
    final l10n = await _pump(tester);
    await tester.tap(find.text(l10n.backupExportAction));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    expect(find.text(l10n.backupNoRecoveryTradeoff), findsOneWidget);
  });

  testWidgets('toggling encryption OFF reveals the readable-by-anyone note', (tester) async {
    final l10n = await _pump(tester);
    await tester.tap(find.text(l10n.backupExportAction));
    await tester.pumpAndSettle();
    expect(find.text(l10n.backupUnencryptedReadable), findsNothing);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text(l10n.backupUnencryptedReadable), findsOneWidget);
  });

  testWidgets('erase: the safe Cancel is primary; the eraser fires only on the 2nd confirm',
      (tester) async {
    final eraser = _FakeEraser();
    final l10n = await _pump(tester, eraser: eraser);

    await tester.tap(find.text(l10n.eraseAllDataAction));
    await tester.pumpAndSettle();
    // The SAFE keep-my-data is the visually-primary FilledButton.
    expect(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text(l10n.eraseKeepData),
      ),
      findsOneWidget,
    );
    // Step 1 — the destructive trigger does not erase yet.
    await tester.tap(find.text(l10n.eraseConfirmFirst));
    await tester.pumpAndSettle();
    expect(eraser.calls, 0);
    // Step 2 — the deliberate second gesture fires the erase.
    await tester.tap(find.text(l10n.eraseConfirmSecond));
    await tester.pumpAndSettle();
    expect(eraser.calls, 1);
  });
}
