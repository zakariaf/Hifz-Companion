// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The trainer landing View (E14-T07): a dumb ConsumerWidget that reads one
// controller and renders the calm loading/error/data shells. The controller is
// exercised by faking the E14-T06 read-model providers (never the Notifier).

import 'dart:async';

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

MaterialApp _app() => MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: const MutashabihatTrainerScreen(),
    );

void main() {
  useOfflineTestPolicy();

  testWidgets('data (empty) renders the calm aid-to-revision landing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(null),
          mutashabihGroupsProvider
              .overrideWith((ref) async => const <MutashabihGroup>[]),
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.mutashabihatTrainerIntro), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('error renders a calm retry, never a spinner-of-shame', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(null),
          mutashabihGroupsProvider.overrideWith(
            (ref) => Future<List<MutashabihGroup>>.error(StateError('boom')),
          ),
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(find.text(l10n.commonRetry), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading renders a calm indicator', (tester) async {
    final pending = Completer<List<MutashabihGroup>>();
    addTearDown(() => pending.complete(const []));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(null),
          mutashabihGroupsProvider.overrideWith((ref) => pending.future),
        ],
        child: _app(),
      ),
    );
    await tester.pump(); // do not settle — stay in the pending state

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
