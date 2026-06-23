// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The jump-to picker resolves a target from the bundled structure (read, never
// computed) and seeks the reader-state store; indices render in locale numerals.
// The per-locale numeral golden is consolidated into T10. Offline.

import 'package:composition/composition.dart' show persistenceProvider;
import 'package:data/data.dart' show PersistenceHandle;
import 'package:data/testing.dart'
    show inMemoryPersistenceHandle, seedReferenceFixture;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafJumpPicker,
        activeEditionProvider,
        mihrabThemeFor,
        mushafReaderStateProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition;

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

Future<ProviderContainer> pumpPicker(
  WidgetTester tester, {
  required PersistenceHandle handle,
  int entryPage = 10,
  Locale locale = const Locale('ar'),
}) async {
  final container = ProviderContainer(
    overrides: [
      persistenceProvider.overrideWithValue(handle),
      activeEditionProvider.overrideWithValue(fakeEdition()),
    ],
  );
  addTearDown(container.dispose);
  // The pager keeps the reader-state store alive in the real app; hold a
  // listener so the autoDispose store survives the picker popping.
  container.listen(mushafReaderStateProvider(entryPage), (_, __) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: MushafJumpPicker(entryPage: entryPage)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  useOfflineTestPolicy();

  testWidgets('a page jump seeks the store to that page (identity)',
      (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    final container = await pumpPicker(tester, handle: handle);

    // Page is the default unit; tap index 3 (ar numeral ٣).
    await tester.tap(find.text('٣'));
    await tester.pumpAndSettle();
    expect(container.read(mushafReaderStateProvider(10)).pageNumber, 3);
  });

  testWidgets('a juz jump resolves the first page from the structure',
      (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    // juz 7 starts on page 130 in the (seeded) structure.
    await seedReferenceFixture(
      handle,
      pagesByJuz: const {
        7: [130, 131],
      },
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    final container = await pumpPicker(tester, handle: handle);

    await tester.tap(find.text(l10n.mushafUnitJuz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('٧')); // juz 7
    await tester.pumpAndSettle();
    expect(container.read(mushafReaderStateProvider(10)).pageNumber, 130);
  });

  testWidgets('indices render in the active locale numeral set (fa)',
      (tester) async {
    final handle = inMemoryPersistenceHandle();
    addTearDown(handle.close);
    await pumpPicker(tester, handle: handle, locale: const Locale('fa'));
    // fa uses Extended Arabic-Indic ۰۱۲ (U+06Fx) — index 1 is ۱, not ١ or 1.
    expect(find.text('۱'), findsWidgets);
    expect(find.text('1'), findsNothing);
  });
}
