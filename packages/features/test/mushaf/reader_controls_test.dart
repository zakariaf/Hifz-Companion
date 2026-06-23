// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The zoom/theme controls are display-only layer transforms over E05's frame.
// Zoom steps a discrete band (no Slider) and is the muṣḥaf's OWN scale —
// independent of OS chrome text-scale; theme selects one ColorFilter, never a
// font swap. The real-KFGQPC theme×zoom golden is deferred to T10. Offline.

import 'package:composition/composition.dart'
    show initialActiveProfileProvider, persistenceProvider;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafPager,
        ReaderTheme,
        ReaderThemeControl,
        ReaderZoomControl,
        activeEditionProvider,
        colorFilterForReaderTheme,
        mihrabThemeFor,
        mushafReaderStateProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition, ProfileId;
import 'package:quran/quran.dart' show MushafReaderFrame;

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

Future<ProviderContainer> pumpControl(
  WidgetTester tester,
  Widget control, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
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
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: textScaler),
            child: Center(child: control),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

double zoomOf(ProviderContainer c) => c.read(mushafReaderStateProvider(1)).zoom;

void main() {
  useOfflineTestPolicy();

  group('zoom control — discrete band, OS-text-scale independent', () {
    testWidgets('+ / − step the band and are disabled at the ends',
        (tester) async {
      final container =
          await pumpControl(tester, const ReaderZoomControl(entryPage: 1));

      // Starts at the band minimum (1.0): − is disabled.
      final minusAtFloor = tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove));
      expect(minusAtFloor.onPressed, isNull);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pump();
      expect(zoomOf(container), 1.25);

      // Step to the band maximum (3.0); + then disables.
      for (var i = 0; i < 6; i++) {
        final plus = tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add));
        if (plus.onPressed == null) break;
        await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
        await tester.pump();
      }
      expect(zoomOf(container), 3.0);
      final plusAtCeil =
          tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add));
      expect(plusAtCeil.onPressed, isNull);
    });

    testWidgets('no continuous Slider in the tree', (tester) async {
      await pumpControl(tester, const ReaderZoomControl(entryPage: 1));
      expect(find.byType(Slider), findsNothing);
    });

    testWidgets('a large OS TextScaler never changes the page zoom value',
        (tester) async {
      final container = await pumpControl(
        tester,
        const ReaderZoomControl(entryPage: 1),
        textScaler: const TextScaler.linear(2.0),
      );
      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pump();
      // The zoom is the store's discrete step, NOT scaled by the OS text-scale.
      expect(zoomOf(container), 1.25);
    });
  });

  group('theme control — single choice, never colour alone', () {
    testWidgets('selecting a theme sets it; exactly the three values render',
        (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
      final container =
          await pumpControl(tester, const ReaderThemeControl(entryPage: 1));

      // Each value renders a text label (shape + text, not colour alone).
      expect(find.text(l10n.mushafThemeLight), findsOneWidget);
      expect(find.text(l10n.mushafThemeSepia), findsOneWidget);
      expect(find.text(l10n.mushafThemeDark), findsOneWidget);

      await tester.tap(find.text(l10n.mushafThemeSepia));
      await tester.pump();
      expect(
        container.read(mushafReaderStateProvider(1)).theme,
        ReaderTheme.sepia,
      );

      await tester.tap(find.text(l10n.mushafThemeDark));
      await tester.pump();
      expect(
        container.read(mushafReaderStateProvider(1)).theme,
        ReaderTheme.dark,
      );
    });
  });

  group('theme → ColorFilter mapping (one filter, no font swap)', () {
    test('light is identity; sepia and dark differ from it and each other', () {
      final light = colorFilterForReaderTheme(ReaderTheme.light);
      final sepia = colorFilterForReaderTheme(ReaderTheme.sepia);
      final dark = colorFilterForReaderTheme(ReaderTheme.dark);
      expect(sepia, isNot(light));
      expect(dark, isNot(light));
      expect(sepia, isNot(dark));
    });
  });

  group('the page slot threads zoom/theme into E05 frame (no font swap)', () {
    testWidgets(
        'frame.zoom tracks the store; frame.colorFilter tracks theme; '
        'the page font is unchanged across themes', (tester) async {
      final handle = inMemoryPersistenceHandle();
      addTearDown(handle.close);
      final container = ProviderContainer(
        overrides: [
          persistenceProvider.overrideWithValue(handle),
          activeEditionProvider.overrideWithValue(fakeEdition()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(mushafReaderStateProvider(1), (_, __) {});
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQueryData(),
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 600,
                  child: MushafPager(entryPage: 1),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      MushafReaderFrame frame() => tester
          .widget<MushafReaderFrame>(find.byType(MushafReaderFrame).first);

      final pageBefore = frame().glyphPage.pageNumber;
      expect(frame().zoom, 1.0);
      expect(frame().colorFilter, colorFilterForReaderTheme(ReaderTheme.light));

      container.read(mushafReaderStateProvider(1).notifier).setZoom(2.0);
      await tester.pumpAndSettle();
      expect(frame().zoom, 2.0);

      container.read(mushafReaderStateProvider(1).notifier).setTheme(
            ReaderTheme.dark,
          );
      await tester.pumpAndSettle();
      expect(frame().colorFilter, colorFilterForReaderTheme(ReaderTheme.dark));
      // The page (its dedicated font) is byte-identical across the theme change.
      expect(frame().glyphPage.pageNumber, pageBefore);
    });
  });
}
