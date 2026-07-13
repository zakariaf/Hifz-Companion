// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../state/mihrab_state_layer.dart';
import '../theme/mihrab_colors.dart';
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
/// Domain-blind: it renders [options] as a wrap of calm mihrab pills (concept
/// 07), marks [selected] with a check glyph **and** a filled teal tile (shape
/// AND colour, never hue alone), and emits the chosen value through [onSelected]
/// — it stores nothing, mutates no instant/`due_at`, re-typesets no glyph, and
/// contains **no `Slider`**. Selection is a quiet M3 state layer, never a reward.
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
    final space = Theme.of(context).extension<SpacingTokens>()!;
    // The wrap flows the pills from the reading-start edge (right in RTL); a
    // long subtitle (e.g. the Hijri civil caveat) wraps within the available
    // width rather than forcing a horizontal overflow.
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: space.space2,
        runSpacing: space.space2,
        children: [
          for (final option in options)
            _pill(context, option, maxWidth: constraints.maxWidth),
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context,
    SettingsOption<T> option, {
    required double maxWidth,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<MihrabColors>()!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final isSelected = option.value == selected;
    final subtitle = option.subtitle;

    final onTile = isSelected ? scheme.onPrimary : scheme.onSurface;
    final subtitleColor =
        isSelected ? scheme.onPrimary : scheme.onSurfaceVariant;
    final radius = BorderRadiusDirectional.all(Radius.circular(space.space6));

    return MihrabFocusRing(
      borderRadius: radius,
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          inMutuallyExclusiveGroup: true,
          selected: isSelected,
          child: InkWell(
            onTap: () => onSelected(option.value),
            customBorder: const StadiumBorder(),
            overlayColor: MihrabStateLayer.overlayColor(onTile),
            child: DecoratedBox(
              // Shape (the check glyph) AND colour (the filled teal tile) both
              // carry selection; an unchosen pill is a light limestone tile with
              // a soft brass rim.
              decoration: ShapeDecoration(
                color: isSelected
                    ? scheme.primary
                    : scheme.surfaceContainerLowest,
                shape: StadiumBorder(
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(
                          color: colors.accentGold.withValues(alpha: 0.55),
                        ),
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: space.space8,
                  minWidth: space.space8,
                  maxWidth: maxWidth,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: space.space4,
                    vertical: space.space2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              option.label,
                              style: text.labelLarge?.copyWith(
                                color: onTile,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: space.space2),
                            Icon(
                              Icons.check,
                              size: space.space4,
                              color: scheme.onPrimary,
                            ),
                          ] else if (option.disclosure) ...[
                            SizedBox(width: space.space1),
                            // Auto-mirrors to the logical end in RTL.
                            Icon(
                              Icons.arrow_forward_ios,
                              size: space.space3,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: space.space1),
                        Text(
                          subtitle,
                          style: text.bodySmall?.copyWith(color: subtitleColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
