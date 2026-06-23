// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The masked surface reveals exactly the next line on a tap (no teleprompter)
// and toggles a stumble mark on a revealed line (raising missedOrAlteredWord).

import 'package:features/features.dart'
    show MihrabAppearance, ReciteSurface, mihrabThemeFor, reciteControllerProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';
import 'recite_test_harness.dart';

void main() {
  useOfflineTestPolicy();

  testWidgets('reveals exactly the next line (no teleprompter), marks stumbles',
      (t) async {
    final container = reciteContainer(
      cards: StubCards(reciteCard()),
      reviews: RecordingReviews(),
    );
    addTearDown(container.dispose);

    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const Scaffold(body: ReciteSurface(pageId: 42)),
        ),
      ),
    );
    await t.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));

    // Hidden initially — nothing revealed.
    expect(container.read(reciteControllerProvider(42)).revealedLineCount, 0);

    // One reveal tap reveals exactly ONE line (no auto-reveal ahead).
    await t.tap(find.bySemanticsLabel(l10n.reciteRevealHint).first);
    await t.pumpAndSettle();
    expect(container.read(reciteControllerProvider(42)).revealedLineCount, 1);

    // Tapping the now-revealed line 1 marks a stumble + raises the guard flag.
    final lineLabel =
        l10n.reciteStumbleLineLabel(localeDigits(1, const Locale('ar')));
    await t.tap(find.bySemanticsLabel(lineLabel).first);
    await t.pumpAndSettle();
    var state = container.read(reciteControllerProvider(42));
    expect(state.stumbleLines.contains(1), isTrue);
    expect(state.missedOrAlteredWord, isTrue);

    // A second tap un-marks it.
    await t.tap(find.bySemanticsLabel(lineLabel).first);
    await t.pumpAndSettle();
    state = container.read(reciteControllerProvider(42));
    expect(state.stumbleLines.contains(1), isFalse);
    expect(state.missedOrAlteredWord, isFalse);
  });
}
