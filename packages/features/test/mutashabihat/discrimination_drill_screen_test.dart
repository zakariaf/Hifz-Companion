// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The discrimination-drill View (E14-T08): the calm shells, the hidden →
// reveal-on-tap → anchor choreography over the immutable page, and the
// back-to-back advance. Faked group read model + a fixed fake anchor resolver
// (the real Rect math is E14-T09) + blank bundle-first pages.

import 'dart:async';

import 'package:features/features.dart'
    show
        DiscriminationDrillScreen,
        DrillBranchView,
        MihrabAppearance,
        drillAnchorWordsProvider,
        drillPageLinesProvider,
        mihrabThemeFor,
        mutashabihGroupProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart';
import 'package:quran/quran.dart' show MushafLineRef, MushafReaderPage, WordRef;

import '../test_setup.dart';

MutashabihGroupView _group(int n) => MutashabihGroupView(
      groupId: 'g1',
      type: MutashabihType.nearIdentical,
      noteKey: null,
      members: [
        for (var i = 0; i < n; i++)
          MutashabihMemberView(
            ayahId: '2:${i + 1}',
            pageNumber: i + 1,
            distinguishingWordIndices: const [],
          ),
      ],
    );

Future<AppLocalizations> _ar() =>
    AppLocalizations.delegate.load(const Locale('ar'));

Widget _app() => MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: const DiscriminationDrillScreen(groupId: 'g1'),
    );

// Pages render blank (bundle-first); the fake resolver returns one WordRef so
// the anchor seam yields a non-null overlay once a branch is anchored.
final _blankPages =
    drillPageLinesProvider.overrideWith((ref, page) async => <MushafLineRef>[]);
final _fakeAnchor = drillAnchorWordsProvider.overrideWith(
  (ref) => (member) => const [WordRef(lineNumber: 1, position: 1)],
);

void main() {
  useOfflineTestPolicy();

  testWidgets('error → calm retry (a missing group never throws)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mutashabihGroupProvider('g1').overrideWith((ref) async => null),
          _blankPages,
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text((await _ar()).commonRetry), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading → calm indicator', (tester) async {
    final pending = Completer<MutashabihGroupView?>();
    addTearDown(() => pending.complete(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mutashabihGroupProvider('g1').overrideWith((ref) => pending.future),
          _blankPages,
        ],
        child: _app(),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('data → reveal-on-tap then anchor over the immutable page', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mutashabihGroupProvider('g1').overrideWith((ref) async => _group(2)),
          _blankPages,
          _fakeAnchor,
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await _ar();

    // The position strip shows the calm "1 of 2" in Arabic-Indic numerals.
    expect(find.textContaining('١'), findsWidgets);
    // Hidden: the reveal affordance is shown; the page is composed but occluded.
    expect(find.text(l10n.mutashabihatDrillReveal), findsOneWidget);
    var page = tester.widget<MushafReaderPage>(find.byType(MushafReaderPage));
    expect(page.overlay, isNull); // no anchor before reveal

    // Reveal-on-tap.
    await tester.tap(find.text(l10n.mutashabihatDrillReveal));
    await tester.pumpAndSettle();
    page = tester.widget<MushafReaderPage>(find.byType(MushafReaderPage));
    expect(page.overlay, isNull); // still no anchor immediately after reveal

    // A second tap shows the anchor overlay (the seam is fed only after reveal).
    await tester.tapAt(tester.getCenter(find.byType(DrillBranchView)));
    await tester.pumpAndSettle();
    page = tester.widget<MushafReaderPage>(find.byType(MushafReaderPage));
    expect(page.overlay, isNotNull); // anchor overlay supplied after anchor

    // No celebration/score affordance anywhere.
    expect(find.byIcon(Icons.celebration), findsNothing);
  });

  testWidgets('advancing the whole group reaches the calm complete line', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mutashabihGroupProvider('g1').overrideWith((ref) async => _group(2)),
          _blankPages,
          _fakeAnchor,
        ],
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await _ar();

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text(l10n.mutashabihatDrillReveal)); // reveal
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(find.byType(DrillBranchView)));
      await tester.pumpAndSettle(); // anchor
      await tester.tap(find.text(l10n.mutashabihatDrillNext)); // next
      await tester.pumpAndSettle();
    }
    expect(find.text(l10n.mutashabihatDrillComplete), findsOneWidget);
  });
}
