// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T07 — the cycle-preset picker: five NAMED presets (no slider/target_R/
// D-S-R/percentage anywhere), a Pure-cycle FIDELITY toggle, quiet M3 selection,
// and writes-nothing (emits choices only).

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

const _region = kDefaultTermSetRegion;

List<SettingsOption<CyclePreset>> presetOptions(AppLocalizations l10n) => [
      SettingsOption(
        value: CyclePreset.weeklyKhatm,
        label: l10n.cycleWeeklyKhatm(_region),
      ),
      SettingsOption(
        value: CyclePreset.oneJuzPerDay,
        label: l10n.cycleOneJuzPerDay(_region),
      ),
      SettingsOption(
        value: CyclePreset.halfJuzPerDay,
        label: l10n.cycleHalfJuzPerDay(_region),
      ),
      SettingsOption(
        value: CyclePreset.twoJuzPerDay,
        label: l10n.cycleTwoJuzPerDay(_region),
      ),
      SettingsOption(
        value: CyclePreset.custom,
        label: l10n.cycleCustom(_region),
        disclosure: true,
      ),
    ];

Widget _host({
  CyclePreset selected = CyclePreset.weeklyKhatm,
  bool pureCycle = false,
  ValueChanged<CyclePreset>? onPreset,
  ValueChanged<bool>? onPure,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light)
        .copyWith(platform: TargetPlatform.android),
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          body: CyclePresetPicker(
            presets: presetOptions(l10n),
            selected: selected,
            onPresetSelected: onPreset ?? (_) {},
            pureCycleEnabled: pureCycle,
            onPureCycleChanged: onPure ?? (_) {},
            pureCycleLabel: l10n.cyclePureMode(_region),
            pureCycleSubtitle: l10n.cyclePureModeSubtitle,
          ),
        );
      },
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('NO slider / target_R / D-S-R / retention % anywhere',
      (tester) async {
    await tester.pumpWidget(_host());
    expect(find.byType(Slider), findsNothing);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final value = t.data ?? '';
      expect(RegExp(r'\d+\s*%').hasMatch(value), isFalse);
      expect(RegExp(r'target_?R|\bD/S/R\b').hasMatch(value), isFalse);
    }
  });

  testWidgets('tapping a preset fires onPresetSelected; widget writes nothing',
      (tester) async {
    final picked = <CyclePreset>[];
    await tester.pumpWidget(_host(onPreset: picked.add));
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.tap(find.text(l10n.cycleOneJuzPerDay(_region)));
    expect(picked, [CyclePreset.oneJuzPerDay]);
  });

  testWidgets('toggling Pure-cycle fires onPureCycleChanged(true)',
      (tester) async {
    final pure = <bool>[];
    await tester.pumpWidget(_host(onPure: pure.add));
    await tester.tap(find.byType(Switch));
    expect(pure, [true]);
  });

  testWidgets('the Custom row carries a disclosure chevron', (tester) async {
    await tester.pumpWidget(_host());
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
  });

  testWidgets('rows are a radiogroup with selected value + focus ring',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(selected: CyclePreset.halfJuzPerDay));
    await tester.pump();
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(
      tester.getSemantics(find.text(l10n.cycleHalfJuzPerDay(_region))),
      isSemantics(isSelected: true, isInMutuallyExclusiveGroup: true),
    );
    expect(find.byType(MihrabFocusRing), findsWidgets);
    handle.dispose();
  });

  testWidgets('no celebration on selection — no sparkle/scale glyph',
      (tester) async {
    await tester.pumpWidget(_host());
    for (final icon in const [
      Icons.star,
      Icons.celebration,
      Icons.auto_awesome,
    ]) {
      expect(find.byIcon(icon), findsNothing);
    }
  });

  testWidgets('>=48dp labelled targets (meetsLibraryGuidelines)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });
}
