// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader scaffold renders E05's MushafPageView behind the redirect guard,
// names the active riwāyah in chrome, and surfaces a calm retry on error — no
// softWrap/fallback-font on the page, no guilt copy. Widget test; the real-font
// glyph golden matrix is E13-T10 (bundle-first: no committed KFGQPC fonts yet).

import 'package:composition/composition.dart' show initialActiveProfileProvider;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafReaderScreen,
        activeEditionProvider,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition, ProfileId;
import 'package:quran/quran.dart' show MushafPageView;

import '../test_setup.dart';

MushafEdition fakeEdition() => MushafEdition(
      mushafId: 'test_edition',
      riwayah: 'Test Riwāyah',
      displayName: 'Test Riwāyah — Test muṣḥaf',
      pageCount: 604,
      lineCount: 15,
      textSha256: '',
      layoutSha256: '',
      fontSha256: const <int, String>{},
    );

Future<void> pumpReader(
  WidgetTester tester, {
  int? initialPage,
  bool editionThrows = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
        if (editionThrows)
          activeEditionProvider
              .overrideWith((ref) => throw StateError('edition unavailable'))
        else
          activeEditionProvider.overrideWithValue(fakeEdition()),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: MushafReaderScreen(initialPage: initialPage)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  useOfflineTestPolicy();

  testWidgets('renders MushafPageView for the page and names the riwāyah',
      (tester) async {
    await pumpReader(tester, initialPage: 255);

    expect(find.byType(MushafPageView), findsOneWidget);
    expect(find.text('Test Riwāyah — Test muṣḥaf'), findsOneWidget);
  });

  testWidgets('the reader opens on the default page absent a deep link',
      (tester) async {
    await pumpReader(tester);
    // The glyph layer is E05's — the reader adds no fallback font and no
    // width-wrap; absent a deep link it lands on the safe default page.
    final pageView = tester.widget<MushafPageView>(find.byType(MushafPageView));
    expect(pageView.glyphPage.pageNumber, 1);
  });

  testWidgets('a build error surfaces a calm retry (no guilt copy)',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await pumpReader(tester, editionThrows: true);

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.commonRetry), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(MushafPageView), findsNothing);
  });
}
