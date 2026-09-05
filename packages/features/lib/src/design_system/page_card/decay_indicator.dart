// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';
import 'page_card_view_data.dart';

/// A tiny decay indicator that encodes the same fact **redundantly** (design-
/// system 07 §4; 08 §3): a plain circle glyph shaped by the retention
/// band **plus** the localized [label] beside it — meaning survives a
/// grayscale / colour-blind render, never colour alone.
///
/// The star hue reads teal for a holding page (the calm green heat-ramp) and a
/// warm terracotta (`semanticWarning`) for a page that is **ready for revision**
/// — a calm *maintenance* framing (the label word is «needs revision»), never an
/// alarm-red / loss / "safe to drop" signal, and there is structurally no
/// "mastered" level (C-019). The level derives from `R` but the **number is
/// never shown**. The star is decorative (the label carries the meaning to the
/// screen reader); capped at `space.4` so it stays a quiet mark, not a gauge.
///
/// Owner-directed design amendment (concept 02 redesign): the decaying end now
/// carries the palette's calm terracotta accent (`semanticWarning`, the same
/// warm clay used by the primary action and the catch-up banner), paired with a
/// large-weight label so the low-chroma hue still clears WCAG contrast. The
/// design-system doc 07 §4 ("a muted neutral") is superseded by this concept.
class DecayIndicator extends StatelessWidget {
  /// Creates an indicator for [level] with the localized [label].
  const DecayIndicator({required this.level, required this.label, super.key});

  /// The decay band to render.
  final DecayLevel level;

  /// The already-localized calm decay word, spoken in the merged phrase.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MihrabColors>()!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    // Teal (from the heat ramp) for a holding page; terracotta for one ready
    // for revision. `solid`/`holding` share the calm green — the label word,
    // not the hue, is the primary channel that tells them apart.
    final color = switch (level) {
      DecayLevel.solid => colors.heatmapStrong,
      DecayLevel.holding => colors.heatmapStrong,
      DecayLevel.needsRevision => colors.semanticWarning,
    };
    // Bold ≥14dp so the low-chroma hue clears the WCAG large-text ratio (3:1);
    // the meaning still rides on the word, never the colour alone.
    final labelStyle = text.labelLarge?.copyWith(
      color: color,
      fontWeight: FontWeight.bold,
    );
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: Size.square(space.space4),
              painter: _DecayDotPainter(level: level, color: color),
            ),
            SizedBox(width: space.space1),
            Flexible(child: Text(label, style: labelStyle)),
          ],
        ),
      ),
    );
  }
}

/// Paints a plain circle glyph whose *shape* carries the level — filled for
/// solid, half-filled for holding, an outline ring for needs-revision — so the
/// meaning survives a grayscale render. Radially symmetric, so it never
/// mirrors in RTL. Purely decorative — the label carries meaning.
class _DecayDotPainter extends CustomPainter {
  const _DecayDotPainter({required this.level, required this.color});

  final DecayLevel level;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 1;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fill = Paint()..color = color;
    switch (level) {
      case DecayLevel.solid:
        canvas.drawCircle(center, radius, fill);
      case DecayLevel.holding:
        canvas.drawCircle(center, radius, stroke);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          math.pi,
          true,
          fill,
        );
      case DecayLevel.needsRevision:
        canvas.drawCircle(center, radius, stroke);
    }
  }

  @override
  bool shouldRepaint(_DecayDotPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.color != color;
}
