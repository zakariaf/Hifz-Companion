// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The cycle-preset + budget step (E11-T08): named single-select + Pure-cycle
// fidelity toggle + a bounded budget stepper; Custom reveals exactly four bounded
// fields. The central invariants are test-pinned: the preset→farCycleDays mapping
// (7/30/60/15), NO Slider, no target_R/D-S-R/%, and Pure-cycle flips one flag.

import 'package:features/features.dart';
import 'package:features/src/onboarding/widgets/custom_cycle_editor.dart';
import 'package:features/src/onboarding/widgets/cycle_preset_mapping.dart';
import 'package:features/src/onboarding/widgets/cycle_preset_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  group('farCycleDaysFor mapping (test-first)', () {
    test('named presets map exactly; custom carries its own', () {
      expect(farCycleDaysFor(CyclePreset.weeklyKhatm), 7);
      expect(farCycleDaysFor(CyclePreset.oneJuzPerDay), 30);
      expect(farCycleDaysFor(CyclePreset.halfJuzPerDay), 60);
      expect(farCycleDaysFor(CyclePreset.twoJuzPerDay), 15);
      expect(farCycleDaysFor(CyclePreset.custom), isNull);
    });
  });

  Future<AppLocalizations> pump(
    WidgetTester tester, {
    CyclePreset? selected,
    bool pureCycle = false,
    int? budget,
    ValueChanged<CyclePreset>? onPreset,
    ValueChanged<bool>? onPure,
    ValueChanged<int>? onBudget,
  }) async {
    await tester.binding.setSurfaceSize(const Size(440, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: hifzLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Force android so the Pure-cycle SwitchListTile renders a Switch (not
        // CupertinoSwitch) on the macOS test host.
        theme: mihrabThemeFor(MihrabAppearance.light)
            .copyWith(platform: TargetPlatform.android),
        home: Scaffold(
          body: CyclePresetStep(
            selected: selected,
            pureCycleEnabled: pureCycle,
            budgetMinutes: budget,
            customCycle: null,
            onPresetSelected: onPreset ?? (_) {},
            onPureCycleChanged: onPure ?? (_) {},
            onBudgetChanged: onBudget ?? (_) {},
            onCustomChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('ar'));
  }

  testWidgets('named presets render; no Slider, no D/S/R, no %', (t) async {
    await pump(t);
    expect(find.byType(Slider), findsNothing);
    final reDsr = RegExp(r'\b(target_R|[DSR]\s*[=:])');
    for (final w in t.widgetList<Text>(find.byType(Text))) {
      final s = w.data ?? '';
      expect(s.contains('%'), isFalse);
      expect(reDsr.hasMatch(s), isFalse);
    }
  });

  testWidgets('tapping a preset routes through onPresetSelected', (t) async {
    CyclePreset? picked;
    final l10n = await pump(t, onPreset: (p) => picked = p);
    await t.tap(find.text(l10n.cycleOneJuzPerDay(kDefaultTermSetRegion)));
    await t.pumpAndSettle();
    expect(picked, CyclePreset.oneJuzPerDay);
  });

  testWidgets('Pure-cycle toggle flips exactly one flag', (t) async {
    bool? pure;
    final l10n = await pump(t, onPure: (v) => pure = v);
    await t.tap(find.text(l10n.cyclePureMode(kDefaultTermSetRegion)));
    await t.pumpAndSettle();
    expect(pure, isTrue);
  });

  testWidgets('the budget stepper captures via onBudgetChanged', (t) async {
    int? minutes;
    await pump(t, budget: 30, onBudget: (m) => minutes = m);
    await t.tap(find.byIcon(Icons.add));
    await t.pumpAndSettle();
    expect(minutes, 30 + kBudgetStepMinutes);
  });

  testWidgets('Custom reveals exactly four bounded fields', (t) async {
    await pump(t, selected: CyclePreset.custom);
    expect(find.byType(CustomCycleEditor), findsOneWidget);
    expect(find.byType(BoundedStepper), findsNWidgets(4));
  });
}
