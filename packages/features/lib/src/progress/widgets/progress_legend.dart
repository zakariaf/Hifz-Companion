// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/heatmap/heat_level.dart';
import '../../design_system/heatmap/heatmap_cell.dart' show heatRampColor;
import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';

/// The grid legend (plain redesign): a row of small swatches with the calm
/// band words — the single-hue ramp from strong to faded, plus the outlined
/// not-started tile. Colour is keyed to a word here and to the label inside
/// every tile, so the grid is never colour alone (08 §5; WCAG 1.4.1).
class ProgressLegend extends StatelessWidget {
  /// Creates the legend.
  const ProgressLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: space.space1),
      child: Wrap(
        spacing: space.space4,
        runSpacing: space.space2,
        children: [
          _LegendChip(
            color: heatRampColor(colors, HeatLevel.strong),
            outline: heatRampColor(colors, HeatLevel.strong),
            label: l10n.progressBandStrong,
          ),
          _LegendChip(
            color: heatRampColor(colors, HeatLevel.fair),
            outline: heatRampColor(colors, HeatLevel.fair),
            label: l10n.progressBandFair,
          ),
          _LegendChip(
            color: heatRampColor(colors, HeatLevel.weak),
            outline: heatRampColor(colors, HeatLevel.weak),
            label: l10n.progressBandWeak,
          ),
          _LegendChip(
            color: heatRampColor(colors, HeatLevel.faded),
            outline: scheme.outlineVariant,
            label: l10n.progressNotStarted,
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.outline,
    required this.label,
  });

  final Color color;
  final Color outline;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: space.space2,
        children: [
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(space.space1),
                border: Border.all(color: outline),
              ),
              child: SizedBox(width: space.space3, height: space.space3),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
