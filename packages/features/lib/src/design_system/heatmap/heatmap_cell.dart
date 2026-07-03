// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

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

/// One retention tile — an 8-fold zellige khatam star (design-system 07 §8, 08) —
/// the leaf the E15 whole-Quran mosaic tile-wall composes 604 times.
///
/// It glazes the star with the calm single-hue ramp (VSUP-muted by confidence)
/// on a hairline limestone tile-bed, encodes its
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
          // The glazed 8-fold zellige khatam star: the ramp/VSUP fill inside the
          // star, on a hairline limestone tile-bed grout edge (08 §5). The star
          // silhouette replaces the plain square; colour still comes from the
          // ramp, so the cell stays "never colour alone" (fill + value + label).
          Positioned.fill(
            child: CustomPaint(
              painter: _ZelligeStarPainter(
                glaze: fill,
                tileBed: scheme.outlineVariant,
              ),
            ),
          ),
          if (data.showDecayTexture)
            Positioned.fill(
              child: ExcludeSemantics(
                child: ClipPath(
                  clipper: const _ZelligeStarClipper(),
                  child: CustomPaint(
                    painter: _DecayTexturePainter(scheme.onSurfaceVariant),
                  ),
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

/// The eight points of the zellige khatam star (the 8-fold Islamic geometric
/// star the mosaic tile-wall is built from) — a fixed geometry constant.
const int _zelligeStarPoints = 8;

/// The star's inner-to-outer radius ratio — the full, calm khatam proportion
/// (a reverent 8-point star, never a spiky burst).
const double _zelligeInnerRadiusRatio = 0.541;

/// The hairline limestone tile-bed stroke that outlines each glazed star — a
/// grout line, deliberately NOT a spacing token (a drawn edge, not a layout
/// distance), mirroring `kMihrabFocusRingWidth`.
const double _zelligeTileBedWidth = 1;

/// Builds the 8-fold khatam star path centred in [size], inset by the tile-bed
/// stroke so the grout edge is never clipped. Shared by the painter and the
/// decay-texture clipper so the geometry lives in exactly one place.
Path _zelligeStarPath(Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final outer = size.shortestSide / 2 - _zelligeTileBedWidth;
  final inner = outer * _zelligeInnerRadiusRatio;
  final path = Path();
  for (var i = 0; i < _zelligeStarPoints * 2; i++) {
    final radius = i.isEven ? outer : inner;
    final angle = -math.pi / 2 + i * math.pi / _zelligeStarPoints;
    final point = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

/// Paints one glazed zellige khatam tile: the [glaze] (the cell's ramp/VSUP fill)
/// inside the 8-fold star, on a hairline [tileBed] limestone grout edge — the
/// star silhouette that reads as a mosaic wall, never a plain square.
class _ZelligeStarPainter extends CustomPainter {
  const _ZelligeStarPainter({required this.glaze, required this.tileBed});

  final Color glaze;
  final Color tileBed;

  @override
  void paint(Canvas canvas, Size size) {
    final star = _zelligeStarPath(size);
    canvas.drawPath(star, Paint()..color = glaze);
    canvas.drawPath(
      star,
      Paint()
        ..color = tileBed
        ..style = PaintingStyle.stroke
        ..strokeWidth = _zelligeTileBedWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ZelligeStarPainter oldDelegate) =>
      oldDelegate.glaze != glaze || oldDelegate.tileBed != tileBed;
}

/// Clips the optional decay hatch to the star silhouette, so the third
/// colour-independent decay channel stays inside the glazed tile and never
/// spills into the limestone bed at the corners.
class _ZelligeStarClipper extends CustomClipper<Path> {
  const _ZelligeStarClipper();

  @override
  Path getClip(Size size) => _zelligeStarPath(size);

  @override
  bool shouldReclip(_ZelligeStarClipper oldClipper) => false;
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
