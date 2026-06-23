// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The RTL paged navigator: its paging direction is Directionality-derived (never
// hardcoded), it bounds to the edition's pageCount, and it binds to the reader-
// state store both ways (store → controller, swipe → setPage) with no engine
// write. The real-KFGQPC no-mirror golden is deferred to T10 (no committed
// fonts). Widget tests over the in-memory (empty) reference; offline.

import 'package:composition/composition.dart' show persistenceProvider;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:features/features.dart'
    show MushafPager, activeEditionProvider, mushafReaderStateProvider;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show MushafEdition;

import '../test_setup.dart';

int pageViewItemCount(WidgetTester tester) {
  final delegate = tester
      .widget<PageView>(find.byType(PageView))
      .childrenDelegate as SliverChildBuilderDelegate;
  return delegate.childCount!;
}

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

Future<ProviderContainer> pumpPager(
  WidgetTester tester, {
  required int entryPage,
  TextDirection direction = TextDirection.rtl,
}) async {
  final handle = inMemoryPersistenceHandle();
  addTearDown(handle.close);
  final container = ProviderContainer(
    overrides: [
      persistenceProvider.overrideWithValue(handle),
      activeEditionProvider.overrideWithValue(fakeEdition()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: Center(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MushafPager(entryPage: entryPage),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  useOfflineTestPolicy();

  group('paging direction is Directionality-derived, never hardcoded', () {
    testWidgets('RTL reverses the page-turn direction', (tester) async {
      await pumpPager(tester, entryPage: 10);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.reverse, isTrue);
    });

    testWidgets('forced LTR does not reverse', (tester) async {
      await pumpPager(tester, entryPage: 10, direction: TextDirection.ltr);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.reverse, isFalse);
    });
  });

  group('bounds come from the edition, never a hardcoded 604', () {
    testWidgets(
        'itemCount is the edition pageCount; one full page per viewport',
        (tester) async {
      await pumpPager(tester, entryPage: 10);
      expect(pageViewItemCount(tester), 604);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.viewportFraction, 1.0);
    });

    testWidgets('an out-of-range incoming page is clamped to 1..pageCount',
        (tester) async {
      final container = await pumpPager(tester, entryPage: 10);
      // Force an out-of-range page through the store; the controller seek is
      // clamped to the last page (604) — it never seeks past the edition.
      container.read(mushafReaderStateProvider(10).notifier).setPage(9999);
      await tester.pumpAndSettle();
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.page!.round(), 603); // index 603 = page 604
    });
  });

  group('binds to the reader-state store both ways (display-only)', () {
    testWidgets('the controller opens on the entry page', (tester) async {
      await pumpPager(tester, entryPage: 10);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.initialPage, 9); // index 9 = page 10
    });

    testWidgets('a landed page turn writes back through setPage only',
        (tester) async {
      final container = await pumpPager(tester, entryPage: 10);
      // Simulate a settled swipe onto page 15 (the PageView reports the index).
      tester.widget<PageView>(find.byType(PageView)).onPageChanged!(14);
      await tester.pump();
      expect(container.read(mushafReaderStateProvider(10)).pageNumber, 15);
    });

    testWidgets('an external page change drives the controller (jump-to seam)',
        (tester) async {
      final container = await pumpPager(tester, entryPage: 10);
      container.read(mushafReaderStateProvider(10).notifier).setPage(200);
      await tester.pumpAndSettle();
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller!.page!.round(), 199); // index 199 = page 200
    });
  });
}
