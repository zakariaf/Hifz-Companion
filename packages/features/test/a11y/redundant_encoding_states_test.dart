// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T06: every state chip carries color + a DISTINCT shape + a localized
// label, in each of fa/ckb/ar; no two states are told apart by color alone (the
// shape glyph varies across states); the decay/weak labels carry no
// "safe to drop"/streak/score copy.

import 'package:features/features.dart'
    show ChipState, MihrabAppearance, StateChip, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '_a11y_test_bootstrap.dart';
import 'redundant_encoding_audit.dart';

String _expectedLabel(AppLocalizations l10n, ChipState state) =>
    switch (state) {
      ChipState.trackSabaq => l10n.trackNewLabel,
      ChipState.trackSabqi => l10n.trackNearLabel,
      ChipState.trackManzil => l10n.trackFarLabel,
      ChipState.due => l10n.stateDue,
      ChipState.weak => l10n.stateWeak,
      ChipState.signOff => l10n.stateSignedOff,
      ChipState.decay => l10n.decayNeedsRevision,
    };

Future<void> _pumpChip(
  WidgetTester tester,
  Locale locale,
  ChipState state,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      home: Scaffold(body: Center(child: StateChip(state: state))),
    ),
  );
  await tester.pump();
}

void main() {
  useOfflineTestPolicy();

  for (final locale in a11yLocales) {
    final code = locale.languageCode;

    testWidgets('$code: every state carries shape + localized label + passes', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final l10n = await localizationsFor(locale);
      for (final state in ChipState.values) {
        await _pumpChip(tester, locale, state);
        // Color + shape + label: a distinct icon and the localized term.
        expect(
          find.descendant(
            of: find.byType(StateChip),
            matching: find.byType(Icon),
          ),
          findsOneWidget,
          reason: '$state needs a non-color shape glyph',
        );
        expect(find.text(_expectedLabel(l10n, state)), findsOneWidget);
        assertStateChipRedundancy(tester, find.byType(StateChip));
      }
      handle.dispose();
    });
  }

  testWidgets('no two states share the same shape glyph', (tester) async {
    final seen = <IconData>{};
    for (final state in ChipState.values) {
      await _pumpChip(tester, const Locale('ar'), state);
      final icon = tester
          .widget<Icon>(
            find.descendant(
              of: find.byType(StateChip),
              matching: find.byType(Icon),
            ),
          )
          .icon!;
      expect(seen.add(icon), isTrue, reason: '$state reuses a shape glyph');
    }
    expect(seen, hasLength(ChipState.values.length));
  });
}
