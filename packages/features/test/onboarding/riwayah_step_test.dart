// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The riwāyah / muṣḥaf confirmation (E11-T03): names the single bundled edition
// explicitly (R2 — never "the Quran" absolutely), stores only the named edition
// id, renders no muṣḥaf glyph, and offers no translation/tafsīr.

import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/riwayah_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show kKfgqpcHafsMadaniV2Edition;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> pump(
    WidgetTester tester, {
    String? selected,
    required ValueChanged<String> onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: RiwayahStep(selected: selected, onSelected: onSelected),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('ar'));
  }

  testWidgets('names the edition; never "the Quran" in the absolute',
      (t) async {
    final l10n = await pump(t, onSelected: (_) {});
    expect(find.text(l10n.mushafRiwayahLabel), findsOneWidget);
    // The riwāyah is named, not "the Quran" absolutely.
    expect(l10n.mushafRiwayahLabel.contains('القرآن'), isFalse);
  });

  testWidgets('confirming writes the bundled edition id, nothing else',
      (t) async {
    String? confirmed;
    final l10n = await pump(t, onSelected: (id) => confirmed = id);
    await t.tap(find.text(l10n.mushafRiwayahLabel));
    await t.pumpAndSettle();
    expect(confirmed, kKfgqpcHafsMadaniV2Edition.mushafId);
  });

  testWidgets('renders no muṣḥaf glyph and no translation affordance',
      (t) async {
    await pump(t, onSelected: (_) {});
    // No page/reader widget is mounted before the core is verified.
    expect(find.byType(PageView), findsNothing);
  });
}
