// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The two diagnostic overlay toggles are gated on real per-page data: each is
// enabled ONLY when its overlay would actually paint something — the data (a
// weak `line_block` / a mutashābihāt anchor) AND the bundled per-word geometry
// to place it are both present. Otherwise the control is disabled with an honest
// "nothing to show here" tooltip, never a button that flips a state and paints
// nothing. Bundle-first the data is empty, so both sit disabled today and light
// up by themselves once it lands. Offline; no engine write, no socket.

import 'package:features/features.dart'
    show
        ConfusableAnchor,
        MihrabAppearance,
        ReaderOverlayToggles,
        WeakLineBlock,
        mihrabThemeFor,
        mushafPageGeometryProvider,
        mutashabihatOverlayAvailableProvider,
        pageConfusablesProvider,
        profileWeakLinesProvider,
        weakLineOverlayAvailableProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:quran/quran.dart' show PageGeometry, WordRef;

import '../test_setup.dart';

// A page geometry that can place a box (one word on line 1) — the second half of
// every "available" condition. Not a `const` map: `WordRef` overrides `==`, so
// it cannot be a const-map key (only its elements are const).
PageGeometry _geometryWithWords(int page) => PageGeometry(
      pageNumber: page,
      wordBoxes: {
        const WordRef(lineNumber: 1, position: 1):
            const Rect.fromLTWH(0, 0, 10, 4),
      },
    );

void main() {
  useOfflineTestPolicy();

  group('overlay availability providers', () {
    test('weak-line: needs BOTH geometry and a weak block', () {
      // Empty bundle (the default seams) — no geometry → unavailable.
      final empty = ProviderContainer();
      addTearDown(empty.dispose);
      expect(empty.read(weakLineOverlayAvailableProvider(1)), isFalse);

      // Geometry present but no weak block → still unavailable.
      final noBlock = ProviderContainer(
        overrides: [
          mushafPageGeometryProvider
              .overrideWith((ref, p) => _geometryWithWords(p)),
          profileWeakLinesProvider.overrideWith((ref, p) => const []),
        ],
      );
      addTearDown(noBlock.dispose);
      expect(noBlock.read(weakLineOverlayAvailableProvider(1)), isFalse);

      // A weak block but no geometry to place it → unavailable.
      final noGeometry = ProviderContainer(
        overrides: [
          profileWeakLinesProvider.overrideWith(
            (ref, p) => const [WeakLineBlock(lineStart: 1, lineEnd: 1)],
          ),
        ],
      );
      addTearDown(noGeometry.dispose);
      expect(noGeometry.read(weakLineOverlayAvailableProvider(1)), isFalse);

      // Both present → available.
      final ready = ProviderContainer(
        overrides: [
          mushafPageGeometryProvider
              .overrideWith((ref, p) => _geometryWithWords(p)),
          profileWeakLinesProvider.overrideWith(
            (ref, p) => const [WeakLineBlock(lineStart: 1, lineEnd: 1)],
          ),
        ],
      );
      addTearDown(ready.dispose);
      expect(ready.read(weakLineOverlayAvailableProvider(1)), isTrue);
    });

    test('mutashābihāt: needs BOTH geometry and a dataset anchor', () {
      final empty = ProviderContainer();
      addTearDown(empty.dispose);
      expect(empty.read(mutashabihatOverlayAvailableProvider(1)), isFalse);

      final noAnchor = ProviderContainer(
        overrides: [
          mushafPageGeometryProvider
              .overrideWith((ref, p) => _geometryWithWords(p)),
          pageConfusablesProvider.overrideWith((ref, p) => const []),
        ],
      );
      addTearDown(noAnchor.dispose);
      expect(noAnchor.read(mutashabihatOverlayAvailableProvider(1)), isFalse);

      final ready = ProviderContainer(
        overrides: [
          mushafPageGeometryProvider
              .overrideWith((ref, p) => _geometryWithWords(p)),
          pageConfusablesProvider.overrideWith(
            (ref, p) => const [
              ConfusableAnchor(words: [WordRef(lineNumber: 1, position: 1)]),
            ],
          ),
        ],
      );
      addTearDown(ready.dispose);
      expect(ready.read(mutashabihatOverlayAvailableProvider(1)), isTrue);
    });
  });

  group('ReaderOverlayToggles honest disabled state', () {
    Future<AppLocalizations> l10nAr() =>
        AppLocalizations.delegate.load(const Locale('ar'));

    // Overrides the two availability providers directly so the widget's gating
    // is tested in isolation (the provider logic itself is covered above).
    Future<List<IconButton>> pumpToggles(
      WidgetTester tester, {
      bool weakLineAvailable = false,
      bool mutashabihatAvailable = false,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weakLineOverlayAvailableProvider
                .overrideWith((ref, p) => weakLineAvailable),
            mutashabihatOverlayAvailableProvider
                .overrideWith((ref, p) => mutashabihatAvailable),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: hifzLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: mihrabThemeFor(MihrabAppearance.light),
            home: const Scaffold(body: ReaderOverlayToggles(entryPage: 1)),
          ),
        ),
      );
      // Tree order is weak-line first, mutashābihāt second.
      return tester
          .widgetList<IconButton>(find.byType(IconButton))
          .toList(growable: false);
    }

    testWidgets('both disabled with the "nothing to show" tooltip when empty',
        (tester) async {
      final l10n = await l10nAr();
      final buttons = await pumpToggles(tester);
      expect(buttons, hasLength(2));
      expect(buttons[0].onPressed, isNull);
      expect(buttons[1].onPressed, isNull);
      expect(buttons[0].tooltip, l10n.mushafOverlayUnavailableOnPage);
      expect(buttons[1].tooltip, l10n.mushafOverlayUnavailableOnPage);
    });

    testWidgets('weak-line toggle enables (only) when its data is available',
        (tester) async {
      final l10n = await l10nAr();
      final buttons = await pumpToggles(tester, weakLineAvailable: true);
      expect(buttons[0].onPressed, isNotNull);
      expect(buttons[0].tooltip, l10n.mushafOverlayWeakLines);
      // The mutashābihāt toggle stays honestly disabled.
      expect(buttons[1].onPressed, isNull);
      expect(buttons[1].tooltip, l10n.mushafOverlayUnavailableOnPage);
    });

    testWidgets('mutashābihāt toggle enables (only) when its data is available',
        (tester) async {
      final l10n = await l10nAr();
      final buttons = await pumpToggles(tester, mutashabihatAvailable: true);
      expect(buttons[1].onPressed, isNotNull);
      expect(buttons[1].tooltip, l10n.mushafOverlayMutashabihat);
      expect(buttons[0].onPressed, isNull);
      expect(buttons[0].tooltip, l10n.mushafOverlayUnavailableOnPage);
    });
  });
}
