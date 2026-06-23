// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Both overlays default OFF (a clean page first). Flipping the weak-line toggle
// feeds the expected coordinate markers to E05's MushafOverlayPainter — no
// engine write, no socket. Geometry/refs are fixtures (bundle-first the real
// data is empty). The real-font on/off golden rows live in T10. Offline.

import 'package:composition/composition.dart'
    show initialActiveProfileProvider, persistenceProvider;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafPager,
        WeakLineBlock,
        activeEditionProvider,
        mihrabThemeFor,
        mushafPageGeometryProvider,
        mushafReaderStateProvider,
        profileWeakLinesProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition, ProfileId;
import 'package:quran/quran.dart'
    show
        MushafOverlayPainter,
        MushafReaderFrame,
        OverlayKind,
        PageGeometry,
        WordRef;

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

// A page geometry with two words on line 1 (so a weak line 1 has refs to mark).
PageGeometry fixtureGeometry(int pageNumber) => PageGeometry(
      pageNumber: pageNumber,
      wordBoxes: {
        const WordRef(lineNumber: 1, position: 1):
            const Rect.fromLTWH(0, 0, 10, 4),
        const WordRef(lineNumber: 1, position: 2):
            const Rect.fromLTWH(12, 0, 10, 4),
      },
    );

Future<ProviderContainer> pumpPager(WidgetTester tester) async {
  final handle = inMemoryPersistenceHandle();
  addTearDown(handle.close);
  final container = ProviderContainer(
    overrides: [
      persistenceProvider.overrideWithValue(handle),
      initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
      activeEditionProvider.overrideWithValue(fakeEdition()),
      mushafPageGeometryProvider
          .overrideWith((ref, pageNumber) => fixtureGeometry(pageNumber)),
      profileWeakLinesProvider.overrideWith(
        (ref, pageNumber) => const [WeakLineBlock(lineStart: 1, lineEnd: 1)],
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(mushafReaderStateProvider(1), (_, __) {});
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: const Scaffold(body: MushafPager(entryPage: 1)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

MushafOverlayPainter? overlayOf(WidgetTester tester) {
  final frame =
      tester.widget<MushafReaderFrame>(find.byType(MushafReaderFrame).first);
  return frame.overlay;
}

void main() {
  useOfflineTestPolicy();

  testWidgets('both overlays default off — no painter on first build',
      (tester) async {
    await pumpPager(tester);
    expect(overlayOf(tester), isNull);
  });

  testWidgets('flipping the weak-line toggle feeds weak-line markers',
      (tester) async {
    final container = await pumpPager(tester);
    container
        .read(mushafReaderStateProvider(1).notifier)
        .toggleWeakLineOverlay();
    await tester.pumpAndSettle();

    final painter = overlayOf(tester);
    expect(painter, isNotNull);
    final weak =
        painter!.markers.where((m) => m.kind == OverlayKind.weakLine).single;
    // The whole weak line 1 (both words) is marked — coordinate refs only.
    expect(weak.words, const [
      WordRef(lineNumber: 1, position: 1),
      WordRef(lineNumber: 1, position: 2),
    ]);
  });
}
