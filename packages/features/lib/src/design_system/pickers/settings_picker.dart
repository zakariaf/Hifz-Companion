// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../state/mihrab_state_layer.dart';
import '../theme/spacing_tokens.dart';

/// One mutually-exclusive choice in a [SettingsPicker] — display data only.
@immutable
class SettingsOption<T> {
  /// Creates an option for [value] labelled [label] (with optional [subtitle]).
  const SettingsOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.disclosure = false,
  });

  /// The value emitted when this option is chosen.
  final T value;

  /// The already-localized primary label.
  final String label;

  /// An optional already-localized secondary line.
  final String? subtitle;

  /// Whether to show a trailing disclosure chevron (e.g. the "Custom" row that
  /// opens a sub-editor owned by the feature layer).
  final bool disclosure;
}

/// The generic single-choice Settings pattern (design-system 07 §6; ui-settings-
/// picker) — a radiogroup of ≥48dp rows for one mutually-exclusive, **display-
/// only** preference (language / calendar / numerals / term-set / theme /
/// muṣḥaf-riwāyah).
///
/// Domain-blind: it renders [options], marks [selected] with a radio glyph **and**
/// filled-emphasis label (shape AND colour, never hue alone), and emits the chosen
/// value through [onSelected] — it stores nothing, mutates no instant/`due_at`,
/// re-typesets no glyph, and contains **no `Slider`**. Selection is a quiet M3
/// state layer, never a reward.
class SettingsPicker<T> extends StatelessWidget {
  /// Creates a picker over [options] with the current [selected] value.
  const SettingsPicker({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// The mutually-exclusive options.
  final List<SettingsOption<T>> options;

  /// The currently selected value.
  final T selected;

  /// Emits the chosen value; the single output of the picker.
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [for (final option in options) _row(context, option)],
    );
  }

  Widget _row(BuildContext context, SettingsOption<T> option) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final isSelected = option.value == selected;
    final subtitle = option.subtitle;

    return MihrabFocusRing(
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          selected: isSelected,
          child: InkWell(
            onTap: () => onSelected(option.value),
            overlayColor: MihrabStateLayer.overlayColor(scheme.onSurface),
            child: Container(
              constraints: BoxConstraints(minHeight: space.space8),
              color: isSelected ? scheme.surfaceContainerHighest : null,
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: space.space4,
                vertical: space.space2,
              ),
              child: Row(
                children: [
                  // Shape (filled vs hollow) AND colour carry selection.
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color:
                        isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  SizedBox(width: space.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.label,
                          style: text.bodyLarge?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: space.space1),
                          Text(
                            subtitle,
                            style: text.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (option.disclosure) ...[
                    SizedBox(width: space.space2),
                    // Auto-mirrors to the logical end in RTL.
                    Icon(
                      Icons.arrow_forward_ios,
                      size: space.space4,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
