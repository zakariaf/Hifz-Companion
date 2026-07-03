// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';

/// A mihrab-architecture screen header (owner-directed design amendment): a
/// glazed-teal band watermarked with a faint arcade of eight-point zellige
/// stars, from which a limestone-cream *miḥrāb niche* rises — a rounded,
/// gently-pointed arch panel bearing a small muqarnas leaf-trio with a gold
/// point, the [title], and an optional [subtitle]. A terracotta ground-line
/// runs along the band's lower edge.
///
/// Purely decorative chrome — it draws no Quran glyph, carries no state, names
/// no number, and merges into a single heading node for the screen reader.
class MihrabArchHeader extends StatelessWidget {
  /// Creates the header band showing the already-localized [title] and, when
  /// supplied, a quieter already-localized [subtitle] beneath it.
  const MihrabArchHeader({required this.title, this.subtitle, super.key});

  /// The screen title (an already-localized tab name).
  final String title;

  /// An optional secondary line under the title (already localized).
  final String? subtitle;

  // The teal band's content height (below the status-bar safe area).
  static const double _bandHeight = 128;
  // The niche's inset from the band's top edge.
  static const double _nicheTopInset = 10;
  // The niche width as a fraction of the band width, and its ceiling.
  static const double _nicheWidthFraction = 0.52;
  static const double _nicheMaxWidth = 300;
  // The niche outline stroke.
  static const double _nicheOutlineWidth = 2;
  // The terracotta ground-line thickness.
  static const double _terracottaThickness = 5;
  // The muqarnas leaf-trio motif box (design aspect ≈ 70×33).
  static const double _motifWidth = 58;
  static const double _motifHeight = 27;
  // The faint star watermark tiling and opacity.
  static const double _starCell = 44;
  static const double _starOpacity = 0.1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;
    return Semantics(
      header: true,
      container: true,
      child: SizedBox(
        width: double.infinity,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: _bandHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final nicheWidth =
                    math.min(_nicheMaxWidth, width * _nicheWidthFraction);
                final nicheLeft = (width - nicheWidth) / 2;
                final nicheRight = nicheLeft + nicheWidth;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MihrabBandPainter(
                          band: scheme.primary,
                          star: scheme.onPrimary
                              .withValues(alpha: _starOpacity),
                          nicheFill: scheme.surface,
                          nicheOutline: scheme.outlineVariant,
                          terracotta: mihrab.semanticWarning,
                          nicheLeft: nicheLeft,
                          nicheRight: nicheRight,
                          nicheTop: _nicheTopInset,
                          nicheBottom: _bandHeight,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: nicheLeft + space.space3,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: _motifWidth,
                              height: _motifHeight,
                              child: CustomPaint(
                                painter: _MuqarnasMotif(
                                  leaf: scheme.primary,
                                  dot: mihrab.accentGold,
                                ),
                              ),
                            ),
                            SizedBox(height: space.space2),
                            // Shrink-to-fit on one line: a long title (e.g. the
                            // Science screen's) scales down to the niche width
                            // rather than truncating to a broken ellipsis.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                softWrap: false,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (subtitle case final subtitle?) ...[
                              SizedBox(height: space.space1),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// The arch geometry — a straight-sided lower body that curves into a rounded,
// gently-pointed cap.
const double _archShoulderFraction = 0.47;
const double _archCapHeightFraction = 0.15;
const double _archCapWidthFraction = 0.14;

/// Builds the miḥrāb-niche arch outline for the box [left]..[right] ×
/// [top]..[bottom]: vertical sides up to the shoulder, then a cubic sweep to a
/// softly-pointed apex.
Path _archNichePath({
  required double left,
  required double right,
  required double top,
  required double bottom,
}) {
  final width = right - left;
  final height = bottom - top;
  final centerX = (left + right) / 2;
  final shoulderY = top + _archShoulderFraction * height;
  final capHeight = _archCapHeightFraction * height;
  final capWidth = _archCapWidthFraction * width;
  return Path()
    ..moveTo(left, bottom)
    ..lineTo(left, shoulderY)
    ..cubicTo(left, top + capHeight, left + capWidth, top, centerX, top)
    ..cubicTo(right - capWidth, top, right, top + capHeight, right, shoulderY)
    ..lineTo(right, bottom)
    ..close();
}

/// Paints the glazed-teal band: a faint eight-point-star watermark, the
/// terracotta ground-line, and the cream miḥrāb niche with its outline.
class _MihrabBandPainter extends CustomPainter {
  const _MihrabBandPainter({
    required this.band,
    required this.star,
    required this.nicheFill,
    required this.nicheOutline,
    required this.terracotta,
    required this.nicheLeft,
    required this.nicheRight,
    required this.nicheTop,
    required this.nicheBottom,
  });

  final Color band;
  final Color star;
  final Color nicheFill;
  final Color nicheOutline;
  final Color terracotta;
  final double nicheLeft;
  final double nicheRight;
  final double nicheTop;
  final double nicheBottom;

  static const double _starOuterRadius = 11;
  static const double _starInnerRatio = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas
      ..save()
      ..clipRect(bounds);

    // The glazed-teal ground.
    canvas.drawRect(bounds, Paint()..color = band);

    // The faint zellige-star watermark, tiled on a straight grid.
    final starPath =
        _eightPointStar(_starOuterRadius, _starOuterRadius * _starInnerRatio);
    final starPaint = Paint()..color = star;
    const cell = MihrabArchHeader._starCell;
    for (var y = cell / 2; y < size.height + cell; y += cell) {
      for (var x = cell / 2; x < size.width + cell; x += cell) {
        canvas
          ..save()
          ..translate(x, y)
          ..drawPath(starPath, starPaint)
          ..restore();
      }
    }

    // The terracotta ground-line along the band's lower edge.
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - MihrabArchHeader._terracottaThickness,
        size.width,
        MihrabArchHeader._terracottaThickness,
      ),
      Paint()..color = terracotta,
    );

    // The cream niche, rising over the ground-line.
    final niche = _archNichePath(
      left: nicheLeft,
      right: nicheRight,
      top: nicheTop,
      bottom: nicheBottom,
    );
    canvas.drawPath(niche, Paint()..color = nicheFill);
    canvas.drawPath(
      niche,
      Paint()
        ..color = nicheOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = MihrabArchHeader._nicheOutlineWidth
        ..strokeJoin = StrokeJoin.round,
    );

    // A quiet terracotta inner keyline, echoing the arch just inside the edge.
    final inner = _archNichePath(
      left: nicheLeft + 4,
      right: nicheRight - 4,
      top: nicheTop + 4,
      bottom: nicheBottom,
    );
    canvas.drawPath(
      inner,
      Paint()
        ..color = terracotta.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
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
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_MihrabBandPainter old) =>
      old.band != band ||
      old.star != star ||
      old.nicheFill != nicheFill ||
      old.nicheOutline != nicheOutline ||
      old.terracotta != terracotta ||
      old.nicheLeft != nicheLeft ||
      old.nicheRight != nicheRight ||
      old.nicheTop != nicheTop ||
      old.nicheBottom != nicheBottom;
}

/// Paints the stylized muqarnas leaf-trio — three teal petals over two, capped
/// by a single gold point — mapped from its design box (160..230 × 15..48).
class _MuqarnasMotif extends CustomPainter {
  const _MuqarnasMotif({required this.leaf, required this.dot});

  final Color leaf;
  final Color dot;

  // The motif's own coordinate region (matching the concept SVG).
  static const double _regionX = 160;
  static const double _regionY = 15;
  static const double _regionW = 70;
  static const double _regionH = 33;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _regionW;
    final sy = size.height / _regionH;
    canvas
      ..save()
      ..translate(-_regionX * sx, -_regionY * sy)
      ..scale(sx, sy);

    // The three upper petals.
    final topPaint = Paint()..color = leaf.withValues(alpha: 0.95);
    for (final cx in const [171.0, 195.0, 219.0]) {
      canvas.drawPath(_petal(cx, 28), topPaint);
    }

    // The two lower petals, a touch quieter for depth.
    final lowerPaint = Paint()..color = leaf.withValues(alpha: 0.8);
    for (final cx in const [183.0, 207.0]) {
      canvas.drawPath(_petal(cx, 39), lowerPaint);
    }

    // The gold point crowning the trio.
    canvas.drawCircle(const Offset(195, 24), 2.4, Paint()..color = dot);

    canvas.restore();
  }

  // A horizontal leaf/vesica centred at (cx, cy), 22 wide, matching the concept.
  Path _petal(double cx, double cy) => Path()
    ..moveTo(cx - 11, cy)
    ..quadraticBezierTo(cx, cy - 13, cx + 11, cy)
    ..quadraticBezierTo(cx, cy + 9, cx - 11, cy)
    ..close();

  @override
  bool shouldRepaint(_MuqarnasMotif old) => old.leaf != leaf || old.dot != dot;
}
