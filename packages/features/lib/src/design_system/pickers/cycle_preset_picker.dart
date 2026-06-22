// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';
import 'settings_picker.dart';

/// The named cycle a [CyclePresetPicker] offers (PRD §15.1) — display-blind; the
/// engine's `EngineConfig` fields it maps to are written at the feature layer
/// (E11/E16), never in this leaf.
enum CyclePreset {
  /// 7-Manzil weekly khatm (the full Quran every 7 days).
  weeklyKhatm,

  /// 1 juz/day (a 30-day cycle).
  oneJuzPerDay,

  /// ½ juz/day (a 60-day cycle).
  halfJuzPerDay,

  /// 2 juz/day (a 15-day cycle).
  twoJuzPerDay,

  /// Custom — four bounded fields, edited in a sub-page owned by the feature
  /// layer; this leaf shows the option + a disclosure only.
  custom,
}

/// The named cycle-preset picker (PRD §15.1; ui-cycle-preset-picker) — the
/// visible face of the engine's cycle ceiling rendered as a choice a teacher
/// recognizes, **never a retention slider / `target_R` dial / D-S-R / percentage**.
///
/// Domain-blind: it shows the five named presets (as a [SettingsPicker]
/// radiogroup) plus a Pure-cycle **fidelity** toggle ("follow my cycle exactly —
/// no reordering", C-014), takes display data + callbacks, and emits choices only
/// — it writes no `EngineConfig`/`due_at`, imports no engine/store, and never
/// frames a longer cycle as "safe to drop". Selection is a quiet M3 state layer.
class CyclePresetPicker extends StatelessWidget {
  /// Creates the picker from display data + callbacks.
  const CyclePresetPicker({
    required this.presets,
    required this.selected,
    required this.onPresetSelected,
    required this.pureCycleEnabled,
    required this.onPureCycleChanged,
    required this.pureCycleLabel,
    required this.pureCycleSubtitle,
    super.key,
  });

  /// The five named presets as already-localized options (Custom carries a
  /// disclosure).
  final List<SettingsOption<CyclePreset>> presets;

  /// The currently selected preset.
  final CyclePreset selected;

  /// Emits the chosen preset.
  final ValueChanged<CyclePreset> onPresetSelected;

  /// Whether Pure-cycle (fixed-rotation conservatism) is on.
  final bool pureCycleEnabled;

  /// Emits the new Pure-cycle value.
  final ValueChanged<bool> onPureCycleChanged;

  /// The already-localized Pure-cycle label.
  final String pureCycleLabel;

  /// The already-localized Pure-cycle fidelity subtitle.
  final String pureCycleSubtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsPicker<CyclePreset>(
          options: presets,
          selected: selected,
          onSelected: onPresetSelected,
        ),
        SizedBox(height: space.space3),
        // The Pure-cycle fidelity toggle — mirrors the teacher-toggle treatment.
        MergeSemantics(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.space8),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: space.space4,
                vertical: space.space2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(pureCycleLabel, style: text.titleMedium),
                        SizedBox(height: space.space1),
                        Text(
                          pureCycleSubtitle,
                          style: text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: space.space3),
                  Switch.adaptive(
                    value: pureCycleEnabled,
                    onChanged: onPureCycleChanged,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
