// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader is "no dashboard": the words dominate, controls recede to edge
// bands that calmly fade on a tap/timer, the riwāyah is ALWAYS named, and no
// gamification/celebration/piety-gate ever sits on the page. R1/R3 are
// release-blocking. Offline.

import 'dart:io';

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

Future<void> pumpChrome(
  WidgetTester tester, {
  bool disableAnimations = false,
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
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: MushafChrome(edition: fakeEdition(), page: 1),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AnimatedOpacity controlsLayer(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(
      find.byKey(const ValueKey<String>('reader.controls')),
    );

void main() {
  useOfflineTestPolicy();

  testWidgets('the riwāyah is always named; no dashboard widget on the page',
      (tester) async {
    await pumpChrome(tester);
    // R2: the named edition is on screen.
    expect(find.text('Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf'), findsOneWidget);

    // No gamification / status-display surface anywhere on the reader.
    for (final widget in tester.allWidgets) {
      final type = widget.runtimeType.toString();
      expect(type.contains('Confetti'), isFalse, reason: 'no confetti: $type');
    }
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final value = text.data ?? '';
      expect(value.contains('%'), isFalse, reason: 'no percentage: "$value"');
      expect(
        RegExp(r'streak|score|mastered', caseSensitive: false).hasMatch(value),
        isFalse,
        reason: 'no streak/score/mastered: "$value"',
      );
    }
  });

  testWidgets('a tap on the page toggles the controls; they return on a tap',
      (tester) async {
    await pumpChrome(tester);
    expect(controlsLayer(tester).opacity, 1.0); // visible on entry

    // A tap on the page interior (center, the base layer) recedes the controls.
    await tester.tapAt(tester.getCenter(find.byType(MushafChrome)));
    await tester.pumpAndSettle();
    expect(controlsLayer(tester).opacity, 0.0);

    // Another tap returns them.
    await tester.tapAt(tester.getCenter(find.byType(MushafChrome)));
    await tester.pump();
    expect(controlsLayer(tester).opacity, 1.0);
  });

  testWidgets('shown controls auto-hide on the calm timer', (tester) async {
    await pumpChrome(tester);
    // Hide then re-show to arm the auto-hide timer.
    await tester.tapAt(tester.getCenter(find.byType(MushafChrome)));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.byType(MushafChrome)));
    await tester.pump();
    expect(controlsLayer(tester).opacity, 1.0);

    // Past the auto-hide delay they fade back out.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(controlsLayer(tester).opacity, 0.0);
  });

  testWidgets('reduce-motion snaps the fade (zero duration)', (tester) async {
    await pumpChrome(tester, disableAnimations: true);
    expect(controlsLayer(tester).duration, Duration.zero);
  });

  test('the chrome source carries no gamification/haptic/audio symbol', () {
    final file = [
      File('lib/src/mushaf/widgets/mushaf_chrome.dart'),
      File('packages/features/lib/src/mushaf/widgets/mushaf_chrome.dart'),
    ].firstWhere((f) => f.existsSync());
    final source = file.readAsStringSync();
    for (final banned in const [
      'Confetti',
      'HapticFeedback',
      'SystemSound',
      'AudioPlayer',
      'streak',
      'DateTime.now',
    ]) {
      expect(
        source.contains(banned),
        isFalse,
        reason: 'no "$banned" on the page',
      );
    }
  });
}
