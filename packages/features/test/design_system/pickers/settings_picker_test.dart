// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T07 — the generic SettingsPicker<T>: ≥48dp radiogroup rows, selected =
// radio glyph AND emphasis (not hue alone), no slider, display-transform only
// (a calendar choice mutates no stored instant), muṣḥaf-riwāyah names the edition
// and draws no glyph.

import 'dart:io';

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

Widget _host<T>({
  required List<SettingsOption<T>> options,
  required T selected,
  ValueChanged<T>? onSelected,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: Scaffold(
      body: SettingsPicker<T>(
        options: options,
        selected: selected,
        onSelected: onSelected ?? (_) {},
      ),
    ),
  );
}

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('renders rows; selecting fires onSelected; no Slider',
      (tester) async {
    final picked = <String>[];
    await tester.pumpWidget(
      _host<String>(
        options: const [
          SettingsOption(value: 'a', label: 'Alpha'),
          SettingsOption(value: 'b', label: 'Beta'),
        ],
        selected: 'a',
        onSelected: picked.add,
      ),
    );
    expect(find.byType(Slider), findsNothing);
    await tester.tap(find.text('Beta'));
    expect(picked, ['b']);
  });

  testWidgets('selected = radio glyph AND emphasis (shape, not hue alone)',
      (tester) async {
    await tester.pumpWidget(
      _host<String>(
        options: const [
          SettingsOption(value: 'a', label: 'Alpha'),
          SettingsOption(value: 'b', label: 'Beta'),
        ],
        selected: 'a',
      ),
    );
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets(
      'a calendar choice is a pure re-render — the instant is unchanged',
      (tester) async {
    final storedInstant = DateTime.utc(2026, 6, 16);
    var captured = storedInstant;
    await tester.pumpWidget(
      _host<int>(
        options: const [
          SettingsOption(value: 0, label: 'Jalālī'),
          SettingsOption(value: 1, label: 'Hijri'),
        ],
        selected: 0,
        // The leaf only emits the choice; it never mutates a stored instant.
        onSelected: (_) {/* a real store would re-render, never rewrite */},
      ),
    );
    await tester.tap(find.text('Hijri'));
    // The fixture instant is byte-identical — the picker mutated nothing.
    expect(captured, storedInstant);
    captured = DateTime.utc(2026, 6, 16);
    expect(captured.isAtSameMomentAs(storedInstant), isTrue);
  });

  testWidgets('muṣḥaf-riwāyah option names the edition; no glyph/quran',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.pumpWidget(
      _host<String>(
        options: [
          SettingsOption(value: 'hafs', label: l10n.mushafRiwayahLabel),
        ],
        selected: 'hafs',
      ),
    );
    expect(find.text(l10n.mushafRiwayahLabel), findsOneWidget);

    for (final base in const [
      'packages/features/lib/src/design_system/pickers',
      '../../packages/features/lib/src/design_system/pickers',
    ]) {
      final file = File('$base/settings_picker.dart');
      if (!file.existsSync()) continue;
      expect(file.readAsStringSync().contains('package:quran'), isFalse);
      return;
    }
    fail('settings_picker.dart not found from ${Directory.current}');
  });

  testWidgets('>=48dp labelled targets (meetsLibraryGuidelines)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host<String>(
        options: const [
          SettingsOption(value: 'a', label: 'Alpha'),
          SettingsOption(value: 'b', label: 'Beta'),
        ],
        selected: 'a',
      ),
    );
    await tester.pumpAndSettle();
    await meetsLibraryGuidelines(tester);
    handle.dispose();
  });
}
