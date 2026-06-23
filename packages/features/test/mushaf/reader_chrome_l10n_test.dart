// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader chrome localizes for fa/ckb/ar: every interactive control carries a
// localized label (the SemanticsTester gate), indices render in the locale digit
// block, and the ckb reader-chrome values are canonical-encoded. The muṣḥaf
// itself is identical across locales (only chrome localizes). Offline.

import 'package:composition/composition.dart'
    show initialActiveProfileProvider, persistenceProvider;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafChrome,
        mihrabThemeFor,
        mushafReaderStateProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition, ProfileId;

import '../test_setup.dart';

MushafEdition fakeEdition() => MushafEdition(
      mushafId: 'kfgqpc_hafs_madani_v2',
      riwayah: 'Ḥafṣ ʿan ʿĀṣim',
      displayName: 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf',
      pageCount: 604,
      lineCount: 15,
      textSha256: '',
      layoutSha256: '',
      fontSha256: const <int, String>{},
    );

Future<void> pumpReaderChrome(WidgetTester tester, Locale locale) async {
  final handle = inMemoryPersistenceHandle();
  addTearDown(handle.close);
  final container = ProviderContainer(
    overrides: [
      persistenceProvider.overrideWithValue(handle),
      initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
    ],
  );
  addTearDown(container.dispose);
  container.listen(mushafReaderStateProvider(1), (_, __) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(body: MushafChrome(edition: fakeEdition(), page: 1)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  useOfflineTestPolicy();

  group('every interactive reader control is labelled (≥48 dp)', () {
    for (final locale in const [Locale('ar'), Locale('fa'), Locale('ckb')]) {
      testWidgets('labelled tap targets — ${locale.languageCode}',
          (tester) async {
        await pumpReaderChrome(tester, locale);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      });
    }
  });

  group('indices render in the active locale numeral block', () {
    test('fa/ckb emit Extended Arabic-Indic ۰; ar emits Arabic-Indic ٠', () {
      // fa/ckb → U+06F0-range (۰۱۲); ar → U+0660-range (٠١٢); never ASCII.
      expect(formatLocaleNumber(const Locale('fa'), 253), contains('۲'));
      expect(formatLocaleNumber(const Locale('ckb'), 253), contains('۲'));
      expect(formatLocaleNumber(const Locale('ar'), 253), contains('٢'));
      for (final locale in const [Locale('fa'), Locale('ckb'), Locale('ar')]) {
        final formatted = formatLocaleNumber(locale, 604);
        expect(
          RegExp(r'[0-9]').hasMatch(formatted),
          isFalse,
          reason: 'no ASCII digit in $locale: "$formatted"',
        );
      }
    });
  });
}
