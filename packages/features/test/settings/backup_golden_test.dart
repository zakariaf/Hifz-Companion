// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E17-T08/T09 — per-locale (ar/fa/ckb) RTL goldens of the backup card + erase
// entry on the REAL bundled UI font (Vazirmatn): the calm flat chrome, the
// ownership + honesty copy, no cloud/sync chrome. The Linux golden lane verifies;
// masters regenerate via the `[update-goldens]` lane (never blessed by CI).

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart' show a11yLocales, loadRealUiFonts;

void main() {
  setUpAll(loadRealUiFonts);

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    testWidgets('backup card ($code)', (tester) async {
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(420, 1100) * 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
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
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/backup_card__$code.png'),
      );
    });
  }
}
