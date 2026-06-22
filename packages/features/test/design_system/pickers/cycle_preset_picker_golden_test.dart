// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T07 — the cycle-preset picker across fa/ckb/ar × the four appearances +
// 200% reflow: a selected preset, Pure-cycle on, and the Custom disclosure row;
// the ckb (longest) transcreation reflows without clipping. Linux lane only.

import 'package:features/features.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';
import 'cycle_preset_picker_test.dart' show presetOptions;

CyclePresetPicker _picker(
  BuildContext context, {
  required CyclePreset selected,
  required bool pure,
}) {
  final l10n = AppLocalizations.of(context);
  return CyclePresetPicker(
    presets: presetOptions(l10n),
    selected: selected,
    onPresetSelected: (_) {},
    pureCycleEnabled: pure,
    onPureCycleChanged: (_) {},
    pureCycleLabel: l10n.cyclePureMode(kDefaultTermSetRegion),
    pureCycleSubtitle: l10n.cyclePureModeSubtitle,
  );
}

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'cycle_preset_picker',
      specimens: [
        ComponentSpecimen(
          name: 'weekly_selected',
          build: (context) =>
              _picker(context, selected: CyclePreset.weeklyKhatm, pure: false),
        ),
        ComponentSpecimen(
          name: 'half_selected',
          build: (context) => _picker(
            context,
            selected: CyclePreset.halfJuzPerDay,
            pure: false,
          ),
        ),
        ComponentSpecimen(
          name: 'pure_on',
          build: (context) =>
              _picker(context, selected: CyclePreset.weeklyKhatm, pure: true),
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('cycle preset picker across locale × appearance', (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
