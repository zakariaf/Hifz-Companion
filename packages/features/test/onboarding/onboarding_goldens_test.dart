// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
@Tags(['golden'])
library;

// E11-T10 — the consolidated per-locale (ar/fa/ckb) golden proof of the
// onboarding step surfaces on the REAL bundled UI font (Vazirmatn, never Ahem):
// RTL geometry (start→end), locale numerals on juz/budget, the named edition and
// named cycle, the calm un-held coverage cell, and ckb wrapping (not truncating)
// its longer transcreations. No muṣḥaf glyph is rendered — chrome only. The
// Linux golden lane verifies; masters regenerate via `--update-goldens` (the
// `[update-goldens]` CI lane), never blessed by CI.

import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/confidence_step.dart';
import 'package:features/src/onboarding/widgets/coverage_capture_grid.dart';
import 'package:features/src/onboarding/widgets/cycle_preset_step.dart';
import 'package:features/src/onboarding/widgets/welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../a11y/_a11y_test_bootstrap.dart';

void main() {
  useOfflineTestPolicy();
  setUpAll(loadRealUiFonts);

  final surfaces = <String, Widget>{
    'welcome': WelcomeStep(onContinue: () {}),
    'coverage': CoverageCaptureGrid(
      heldJuz: const {1, 2, 5, 13},
      onToggle: (_) {},
    ),
    'confidence': ConfidenceStep(
      heldJuz: const {1, 2},
      confidence: const {1: JuzConfidence.solid},
      onPick: (_, __) {},
      memorizedOn: const {},
      today: CalendarDate.ymd(2026, 6, 22),
      calendarSystem: kDefaultCalendarSystem,
      onSetMemorized: (_, __) {},
      onClearMemorized: (_) {},
    ),
    'cycle_preset': const CyclePresetStep(
      selected: CyclePreset.weeklyKhatm,
      pureCycleEnabled: false,
      budgetMinutes: 30,
      customCycle: null,
      onPresetSelected: _ignorePreset,
      onPureCycleChanged: _ignoreBool,
      onBudgetChanged: _ignoreInt,
      onCustomChanged: _ignoreCustom,
    ),
  };

  for (final locale in a11yLocales) {
    final code = locale.languageCode;
    for (final entry in surfaces.entries) {
      testWidgets('onboarding ${entry.key} ($code)', (tester) async {
        tester.view.devicePixelRatio = 2.0;
        tester.view.physicalSize = const Size(420, 920);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: hifzLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: mihrabThemeFor(MihrabAppearance.light),
            home: Scaffold(body: SafeArea(child: entry.value)),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/onboarding_${entry.key}__$code.png'),
        );
      });
    }
  }
}

void _ignorePreset(CyclePreset _) {}
void _ignoreBool(bool _) {}
void _ignoreInt(int _) {}
void _ignoreCustom(CustomCycleConfig _) {}
