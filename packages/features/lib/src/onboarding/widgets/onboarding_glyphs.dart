// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The shared miḥrāb *state glyphs* the cold-start surfaces draw: an eight-point
/// zellige star (filled / hollow / dashed) and a dashed ring. Each is a
/// **redundant, non-colour** carrier of a held/confidence state alongside its
/// text label (SC 1.4.1) — never the sole signal, never a reward or an alarm.
///
/// Purely decorative: it draws no Quran glyph, carries no state, and names no
/// number. Callers pass a token-sourced [color] and [size]; the geometry is the
/// glyph's own coordinate math (design-system 03 §8 zellige motif family).
enum MihrabGlyphKind {
  /// A solid eight-point star — a held / Solid juz.
  filledStar,

  /// A hollow eight-point star — a Shaky juz (calm, un-emphasised).
  outlineStar,

  /// A dashed eight-point star — a Rusty juz (a warm-clay hint, never red).
  dashedStar,

  /// A dashed ring — an un-held juz (a calm absence, never "missing" / "0%").
  dashedRing,
}

/// Draws one [kind] glyph in [color] within a [size]×[size] box.
class MihrabGlyph extends StatelessWidget {
  /// Creates the glyph.
  const MihrabGlyph({
    required this.kind,
    required this.color,
    required this.size,
    super.key,
  });

  /// Which state glyph to draw.
  final MihrabGlyphKind kind;

  /// The token-sourced ink (a `ColorScheme` role or a `MihrabColors` tint).
  final Color color;

  /// The square edge (a `SpacingTokens` value).
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _MihrabGlyphPainter(kind: kind, color: color),
        ),
      );
}

/// The eight-point zellige-star outline centred at [center] — [outerRadius] to
/// each point, [innerRadius] to each notch. Shared by the glyphs and the faint
/// header/banner watermark so the star motif is drawn one way everywhere.
Path eightPointStarPath(Offset center, double outerRadius, double innerRadius) {
  const points = 8;
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = (i * math.pi / points) - math.pi / 2;
    final point = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

class _MihrabGlyphPainter extends CustomPainter {
  const _MihrabGlyphPainter({required this.kind, required this.color});

  final MihrabGlyphKind kind;
  final Color color;

  // The glyph's own coordinate math (a decorative motif, not a layout size).
  static const double _strokeWidth = 2;
  static const double _innerRatio = 0.46;
  static const double _ringRatio = 0.86;
  static const double _dashLength = 3.4;
  static const double _dashGap = 2.6;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final star =
        eightPointStarPath(center, radius, radius * _innerRatio);
    switch (kind) {
      case MihrabGlyphKind.filledStar:
        canvas.drawPath(
          star,
          Paint()
            ..color = color
            ..isAntiAlias = true,
        );
      case MihrabGlyphKind.outlineStar:
        canvas.drawPath(star, _stroke());
      case MihrabGlyphKind.dashedStar:
        _drawDashed(canvas, star);
      case MihrabGlyphKind.dashedRing:
        _drawDashed(
          canvas,
          Path()
            ..addOval(Rect.fromCircle(center: center, radius: radius * _ringRatio)),
        );
    }
  }

  Paint _stroke() => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  void _drawDashed(Canvas canvas, Path source) {
    final paint = _stroke();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + _dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_MihrabGlyphPainter old) =>
      old.kind != kind || old.color != color;
}
