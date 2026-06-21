// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../state/mihrab_state_layer.dart';
import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';
import 'heat_level.dart';
import 'heatmap_cell_data.dart';
import 'weakest_page_badge.dart';

/// The single-hue ramp color for [level] (design-system 08 §2) — resolved from
/// the E06 `MihrabColors` tokens by name, never an inline hex and never a hue
/// axis. `strong` is the calm base green; `faded` is the muted neutral end.
Color heatRampColor(MihrabColors colors, HeatLevel level) => switch (level) {
      HeatLevel.strong => colors.heatmapStrong,
      HeatLevel.good => colors.heatmapGood,
      HeatLevel.fair => colors.heatmapFair,
      HeatLevel.weak => colors.heatmapWeak,
      HeatLevel.faded => colors.heatmapFaded,
    };

/// The VSUP-muted fill for [data] (design-system 08 §4) — the named blend rule a
/// reviewer can read, not a per-widget alpha:
///
/// - a **never-recited** page renders at the faded neutral, regardless of an
///   optimistic prior;
/// - otherwise the ramp color is blended toward the faded neutral by
///   `(1 - sourceConfidence)`, so a self-rating-only cell (`≈ 0.5`) reads less
///   saturated than a teacher-confirmed one (`1.0`);
/// - a single self-rating (`confidence < 1.0`) can **never** resolve to the most-
///   saturated `strong` anchor — it is demoted toward `good` (the engine's
///   conservative priors, honoured at the chart layer).
Color heatFillFor(MihrabColors colors, HeatmapCellData data) {
  if (!data.everReviewed) return colors.heatmapFaded;
  final base = heatRampColor(colors, data.level);
  final confidence = data.sourceConfidence.clamp(0.0, 1.0);
  final muted = Color.lerp(colors.heatmapFaded, base, confidence)!;
  if (confidence < 1.0 && data.level == HeatLevel.strong) {
    return Color.lerp(colors.heatmapGood, muted, 0.5)!;
  }
  return muted;
}

/// One retention square (design-system 07 §8, 08) — the leaf the E15 whole-Quran
/// grid composes 604 times.
///
/// It paints the calm single-hue ramp (VSUP-muted by confidence), encodes its
/// state **three ways** (fill + a locale-numeral value/range + a plain label,
/// plus an optional decay texture), and carries the **min-leaning** juz roll-up
/// with its weakest-page badge at the logical start. Domain-blind: it renders the
/// supplied [HeatmapCellData] (it recomputes no `R`/aggregate), draws no Quran
/// glyph, shows no raw D/S/R or crisp percentage, and is never a streak/score/
/// scoreboard tile.
class HeatmapCell extends StatelessWidget {
  /// Creates a cell for [data]; [onTap] makes it a drill-through button.
  const HeatmapCell({required this.data, this.onTap, super.key});

  /// The display-only data to render.
  final HeatmapCellData data;

  /// Optional drill action (E15 opens the page-detail sheet here).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final colors = Theme.of(context).extension<MihrabColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final fill = heatFillFor(colors, data);

    final swatch = SizedBox(
      width: space.space8,
      height: space.space8,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: fill,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.all(
                    Radius.circular(space.space2),
                  ),
                ),
              ),
            ),
          ),
          if (data.showDecayTexture)
            Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _DecayTexturePainter(scheme.onSurfaceVariant),
                ),
              ),
            ),
          if (data.isJuzRollUp && data.weakestPageId != null)
            PositionedDirectional(
              start: space.space1,
              top: space.space1,
              child: ExcludeSemantics(
                child: WeakestPageBadge(color: colors.heatmapWeak),
              ),
            ),
        ],
      ),
    );

    // Value + label live UNDER the swatch on `surface`, so their contrast is the
    // audited onSurface-on-surface floor, not a varying on-fill ratio (08 §5).
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        SizedBox(height: space.space1),
        Text(
          isolateLtr(data.localizedValue),
          style: text.labelSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          data.label,
          style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );

    final weakest = data.isJuzRollUp && data.weakestPageId != null
        ? l10n.heatmapWeakestPage(localeDigits(data.weakestPageId!, locale))
        : null;

    Widget cell = ConstrainedBox(
      constraints:
          BoxConstraints(minWidth: space.space8, minHeight: space.space8),
      child: weakest == null ? body : Semantics(label: weakest, child: body),
    );

    final tap = onTap;
    if (tap != null) {
      cell = MihrabFocusRing(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: tap,
            overlayColor: MihrabStateLayer.overlayColor(scheme.onSurface),
            child: cell,
          ),
        ),
      );
    }
    return MergeSemantics(child: cell);
  }
}

/// A restrained third colour-independent channel for the decaying end — a faint
/// diagonal hatch, never a glyph or an alarm (design-system 08 §5).
class _DecayTexturePainter extends CustomPainter {
  const _DecayTexturePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DecayTexturePainter oldDelegate) =>
      oldDelegate.color != color;
}
