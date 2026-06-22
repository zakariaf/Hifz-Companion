// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The per-juz confidence rater (E11-T06): one Solid/Shaky/Rusty pick per held
// juz (muṣḥaf order), honest self-report, single-select. The no-leak invariant
// is load-bearing: no D/S/R, no interval, no readiness % ever renders; the View
// passes JuzConfidence only and seeds nothing.

import 'package:engine/engine.dart' show JuzConfidence;
import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/confidence_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> pump(
    WidgetTester tester, {
    required Set<int> held,
    Map<int, JuzConfidence> confidence = const {},
    void Function(int, JuzConfidence)? onPick,
    Locale locale = const Locale('ar'),
  }) async {
    await tester.binding.setSurfaceSize(const Size(440, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: mihrabThemeFor(MihrabAppearance.light),
        home: Scaffold(
          body: ConfidenceStep(
            heldJuz: held,
            confidence: confidence,
            onPick: onPick ?? (_, __) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(locale);
  }

  Finder juzRow(AppLocalizations l10n, int n) =>
      find.text(l10n.juzLabel(formatLocaleNumber(const Locale('ar'), n)));

  testWidgets('one row per held juz; un-held juz never appear', (t) async {
    final l10n = await pump(t, held: const {1, 5});
    expect(juzRow(l10n, 1), findsOneWidget);
    expect(juzRow(l10n, 5), findsOneWidget);
    expect(juzRow(l10n, 2), findsNothing);
  });

  testWidgets('single-select capture; replaces, never accumulates', (t) async {
    final picks = <(int, JuzConfidence)>[];
    final l10n = await pump(
      t,
      held: const {1},
      onPick: (j, c) => picks.add((j, c)),
    );
    await t.tap(find.text(l10n.confidenceSolid));
    await t.pumpAndSettle();
    await t.tap(find.text(l10n.confidenceRusty));
    await t.pumpAndSettle();
    expect(picks, [(1, JuzConfidence.solid), (1, JuzConfidence.rusty)]);
  });

  testWidgets('no D/S/R, no interval, no readiness % renders (no-leak)',
      (t) async {
    const rated = {
      1: JuzConfidence.solid,
      2: JuzConfidence.shaky,
      3: JuzConfidence.rusty,
    };
    await pump(t, held: const {1, 2, 3}, confidence: rated);
    final reDsr = RegExp(r'\b[DSR]\s*[=:]');
    for (final w in t.widgetList<Text>(find.byType(Text))) {
      final s = w.data ?? '';
      expect(s.contains('%'), isFalse, reason: 'no percentage in: $s');
      expect(reDsr.hasMatch(s), isFalse, reason: 'no D/S/R seed in: $s');
      expect(s.contains('!'), isFalse, reason: 'no exclamation in: $s');
    }
  });

  testWidgets('the bias note carries no number (C-009 framing)', (t) async {
    final l10n = await pump(t, held: const {1});
    expect(find.text(l10n.confidenceBiasNote), findsOneWidget);
    expect(RegExp(r'[0-9۰-۹٠-٩]').hasMatch(l10n.confidenceBiasNote), isFalse);
  });
}
