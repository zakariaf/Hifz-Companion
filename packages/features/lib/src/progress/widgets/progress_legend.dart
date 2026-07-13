// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/heatmap/heat_level.dart';
import '../../design_system/heatmap/heatmap_cell.dart' show heatRampColor;
import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import 'zellige_star_glyph.dart';

/// The calm Progress legend (redesign §8 gap: the heat-map had no on-screen key):
/// three glaze steps of the single-hue retention ramp, each keyed by a zellige
/// star swatch AND a plain word, so the tile-wall is read by shape + colour +
/// label — never colour alone (08-data-visualization §5). It is a quiet key, not
/// a score, a scale, or a legend of alarms; the words reuse the same band labels
/// the tiles speak.
class ProgressLegend extends StatelessWidget {
  /// Creates the tile-wall legend.
  const ProgressLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadiusDirectional.all(Radius.circular(space.space4)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space4),
        child: Wrap(
          spacing: space.space5,
          runSpacing: space.space3,
          children: [
            _LegendChip(
              color: heatRampColor(colors, HeatLevel.strong),
              label: l10n.progressBandStrong,
            ),
            _LegendChip(
              color: heatRampColor(colors, HeatLevel.fair),
              label: l10n.progressBandFair,
            ),
            _LegendChip(
              color: heatRampColor(colors, HeatLevel.faded),
              label: l10n.progressBandFaded,
            ),
          ],
        ),
      ),
    );
  }
}

/// One legend entry: a tile-bedded star swatch beside its plain word, merged into
/// a single node so the screen reader speaks the word once (the swatch is mute).
class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: ZelligeStarGlyph(
              color: color,
              size: space.space4,
              outline: scheme.outlineVariant,
            ),
          ),
          SizedBox(width: space.space2),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
