// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small decorative eight-point zellige *khatam* star — the same 8-fold
/// silhouette the retention tiles wear (design-system 07 §8), reused as a calm
/// ornament in the Progress legend, the tile-wall section banner, and the
/// weakest-pages rows so the whole surface reads as one mosaic wall.
///
/// Purely decorative: the caller wraps it in `ExcludeSemantics` and the meaning
/// rides an adjacent text label (never colour alone). It draws no Quran glyph and
/// is never an interactive target, a score, or a reward. It recolours only via
/// tokens the caller passes; it names no value of its own.
class ZelligeStarGlyph extends StatelessWidget {
  /// Creates a star glazed [color] at [size]; when [outline] is non-null a
  /// hairline grout edge (the limestone tile-bed) is drawn around it, matching
  /// how a faded tile stays visible by its edge on a cream ground.
  const ZelligeStarGlyph({
    required this.color,
    required this.size,
    this.outline,
    super.key,
  });

  /// The glaze fill (a heat-ramp step or a gold/terracotta accent from tokens).
  final Color color;

  /// The star's box side (pass a `SpacingTokens` step).
  final double size;

  /// An optional hairline grout edge (pass `outlineVariant`); null draws none.
  final Color? outline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ZelligeStarGlyphPainter(glaze: color, edge: outline),
      ),
    );
  }
}

/// The eight points of the khatam star (a fixed geometry constant).
const int _zelligeStarPoints = 8;

/// The inner-to-outer radius ratio — the full, calm khatam proportion (matching
/// the retention tile), never a spiky burst.
const double _zelligeInnerRadiusRatio = 0.541;

/// The hairline grout stroke — a drawn edge, deliberately not a spacing token.
const double _zelligeEdgeWidth = 1;

class _ZelligeStarGlyphPainter extends CustomPainter {
  const _ZelligeStarGlyphPainter({required this.glaze, required this.edge});

  final Color glaze;
  final Color? edge;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.shortestSide / 2 - _zelligeEdgeWidth;
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
    path.close();

    canvas.drawPath(path, Paint()..color = glaze);
    final edgeColor = edge;
    if (edgeColor != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = edgeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _zelligeEdgeWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ZelligeStarGlyphPainter old) =>
      old.glaze != glaze || old.edge != edge;
}
