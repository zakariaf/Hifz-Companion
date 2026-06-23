// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E14-T12 offline guard (fast job): the whole trainer path — a full
// reveal→anchor→next-sibling drill cycle and the hotspots surface — completes
// with ZERO connection attempts. The shared throwing HttpOverrides turns any
// socket into a loud named StateError; the trainer reads only the bundled
// dataset + the local confusion_edge graph (in-memory fakes here).

import 'package:composition/composition.dart' show initialActiveProfileProvider;
import 'package:features/features.dart'
    show
        ConfusionHotspotsView,
        DiscriminationDrillScreen,
        DrillBranchView,
        MihrabAppearance,
        confusionHotspotsProvider,
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

const _profile = ProfileId('A');

MutashabihGroupView _group() => const MutashabihGroupView(
      groupId: 'g1',
      type: MutashabihType.nearIdentical,
      noteKey: null,
      members: [
        MutashabihMemberView(
          ayahId: '2:1',
          pageNumber: 1,
          distinguishingWordIndices: [0],
        ),
        MutashabihMemberView(
          ayahId: '2:2',
          pageNumber: 2,
          distinguishingWordIndices: [1],
        ),
      ],
    );

ConfusionEdge _edge(String a, String b, double w) => ConfusionEdge.between(
      _profile,
      a,
      b,
      weight: w,
      lastConfusedAt: CalendarDate.ymd(2026, 6, 17),
    );

Widget _wrap(Widget home) => MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: home,
    );

void main() {
  useOfflineTestPolicy(); // any socket → loud StateError

  testWidgets('a full drill reveal→anchor→next cycle opens no socket', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mutashabihGroupProvider('g1').overrideWith((ref) async => _group()),
          drillPageLinesProvider
              .overrideWith((ref, page) async => <MushafLineRef>[]),
          drillAnchorWordsProvider.overrideWith(
            (ref) => (member) => const [WordRef(lineNumber: 1, position: 1)],
          ),
        ],
        child: _wrap(const DiscriminationDrillScreen(groupId: 'g1')),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    // Sibling A: reveal → anchor → next.
    await tester.tap(find.text(l10n.mutashabihatDrillReveal));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.byType(DrillBranchView)));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MushafReaderPage>(find.byType(MushafReaderPage)).overlay,
      isNotNull,
    );
    await tester.tap(find.text(l10n.mutashabihatDrillNext));
    await tester.pumpAndSettle();

    // No socket was ever opened (the throwing override was never hit).
    expect(tester.takeException(), isNull);
  });

  testWidgets('the hotspots surface opens no socket', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialActiveProfileProvider.overrideWithValue(_profile),
          confusionHotspotsProvider(_profile).overrideWith(
            (ref) => Stream.value([_edge('2:1', '3:2', 4)]),
          ),
        ],
        child: _wrap(const Scaffold(body: ConfusionHotspotsView())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
