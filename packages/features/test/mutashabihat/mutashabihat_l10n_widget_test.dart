// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E14-T11: the trainer renders the transcreated value (not a key string) under
// each RTL locale — fa, ckb, ar — exercising the l10n wiring end to end.

import 'package:composition/composition.dart' show initialActiveProfileProvider;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MutashabihatTrainerScreen,
        mihrabThemeFor,
        mutashabihGroupsProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MutashabihGroup;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  for (final code in ['fa', 'ckb', 'ar']) {
    testWidgets('the trainer shows the localized intro in "$code"', (
      tester,
    ) async {
      final locale = Locale.fromSubtags(languageCode: code);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialActiveProfileProvider.overrideWithValue(null),
            mutashabihGroupsProvider
                .overrideWith((ref) async => const <MutashabihGroup>[]),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: hifzLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: mihrabThemeFor(MihrabAppearance.light),
            home: const MutashabihatTrainerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(locale);
      // The resolved value renders — never the bare key, never an empty string.
      expect(find.text(l10n.mutashabihatTrainerIntro), findsOneWidget);
      expect(l10n.mutashabihatTrainerIntro.trim(), isNotEmpty);
      expect(find.text('mutashabihatTrainerIntro'), findsNothing);
    });
  }
}
