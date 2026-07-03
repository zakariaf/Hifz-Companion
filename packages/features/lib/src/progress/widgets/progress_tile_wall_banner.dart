// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import 'zellige_star_glyph.dart';

/// The Progress tile-wall section banner: a glazed-teal plaque watermarked with a
/// faint arcade of eight-point zellige stars and edged in terracotta along its
/// lower rim — the screen's miḥrāb header echoed in miniature — bearing the
/// section title at the reading start and a single gold star at the end.
///
/// Decorative chrome: it names no number, carries no state, draws no Quran glyph,
/// and is never a streak, score, or scoreboard. The star watermark and glyph are
/// excluded from semantics; only the title is spoken.
class ProgressTileWallBanner extends StatelessWidget {
  /// Creates the tile-wall section banner.
  const ProgressTileWallBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mihrab = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;

    return ClipRRect(
      borderRadius: BorderRadiusDirectional.all(Radius.circular(space.space3)),
      child: CustomPaint(
        painter: _TileWallBannerPainter(
          band: scheme.primary,
          star: scheme.onPrimary.withValues(alpha: 0.12),
          terracotta: mihrab.semanticWarning,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            space.space4,
            space.space3,
            space.space4,
            space.space4,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.progressTileWallTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: space.space3),
              ExcludeSemantics(
                child: ZelligeStarGlyph(
                  color: mihrab.accentGold,
                  size: space.space6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the glazed-teal plaque: a faint tiled eight-point-star watermark and a
/// terracotta ground-line along the lower edge (clipped to the rounded rim by the
/// enclosing `ClipRRect`). Mirrors the screen header's band, scaled down.
class _TileWallBannerPainter extends CustomPainter {
  const _TileWallBannerPainter({
    required this.band,
    required this.star,
    required this.terracotta,
  });

  final Color band;
  final Color star;
  final Color terracotta;

  static const double _starCell = 40;
  static const double _starOuterRadius = 10;
  static const double _starInnerRatio = 0.5;
  static const double _terracottaThickness = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas
      ..save()
      ..clipRect(bounds)
      ..drawRect(bounds, Paint()..color = band);

    final starPath =
        _eightPointStar(_starOuterRadius, _starOuterRadius * _starInnerRatio);
    final starPaint = Paint()..color = star;
    for (var y = _starCell / 2; y < size.height + _starCell; y += _starCell) {
      for (var x = _starCell / 2; x < size.width + _starCell; x += _starCell) {
        canvas
          ..save()
          ..translate(x, y)
          ..drawPath(starPath, starPaint)
          ..restore();
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - _terracottaThickness,
        size.width,
        _terracottaThickness,
      ),
      Paint()..color = terracotta,
    );
    canvas.restore();
  }

  Path _eightPointStar(double outer, double inner) {
    const points = 8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = (i * math.pi / points) - math.pi / 2;
      final point = Offset(radius * math.cos(angle), radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_TileWallBannerPainter old) =>
      old.band != band || old.star != star || old.terracotta != terracotta;
}
