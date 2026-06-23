// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader scaffold renders E05's MushafPageView behind the redirect guard,
// names the active riwāyah in chrome, and surfaces a calm retry on error — no
// softWrap/fallback-font on the page, no guilt copy. Widget test; the real-font
// glyph golden matrix is E13-T10 (bundle-first: no committed KFGQPC fonts yet).

import 'package:composition/composition.dart'
    show initialActiveProfileProvider, persistenceProvider;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafPager,
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
  final handle = inMemoryPersistenceHandle();
  addTearDown(handle.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        persistenceProvider.overrideWithValue(handle),
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

  testWidgets('embeds the RTL pager for the page and names the riwāyah',
      (tester) async {
    await pumpReader(tester, initialPage: 255);

    final pager = tester.widget<MushafPager>(find.byType(MushafPager));
    expect(pager.entryPage, 255);
    expect(find.text('Test Riwāyah — Test muṣḥaf'), findsOneWidget);
    // The page renderer is E05's, mounted inside the pager (empty page on the
    // bundle-first reference) — the reader adds no fallback font, no width-wrap.
    expect(find.byType(MushafPageView), findsWidgets);
  });

  testWidgets('the reader opens on the default page absent a deep link',
      (tester) async {
    await pumpReader(tester);
    final pager = tester.widget<MushafPager>(find.byType(MushafPager));
    expect(pager.entryPage, 1);
  });

  testWidgets('a build error surfaces a calm retry (no guilt copy)',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await pumpReader(tester, editionThrows: true);

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.commonRetry), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(MushafPager), findsNothing);
  });
}
