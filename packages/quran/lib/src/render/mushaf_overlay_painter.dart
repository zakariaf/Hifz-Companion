// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart' show listEquals, mapEquals;
import 'package:flutter/widgets.dart';

import '../page_geometry.dart';
import 'overlay_marker.dart';

/// The calm, diagnostic look of the overlay markers — the per-kind fill colour
/// and the corner radius. The **values** are owned by the design-system tokens
/// (Mihrab) and wired in by the caller (E05-T09 / E10) **by name**; this painter
/// holds none, so no hex/px literal lives on the sacred path. Colours are calm
/// and diagnostic — never glow, gradient, gold, or celebration over an āyah.
@immutable
class OverlayStyle {
  /// Creates an overlay style mapping each [OverlayKind] to its calm fill colour
  /// and a shared small [cornerRadius].
  const OverlayStyle({required this.fillColors, required this.cornerRadius});

  /// Per-kind fill colour (resolved from Mihrab token names by the caller).
  final Map<OverlayKind, Color> fillColors;

  /// The small, calm corner radius shared by every marker box.
  final double cornerRadius;

  @override
  bool operator ==(Object other) =>
      other is OverlayStyle &&
      other.cornerRadius == cornerRadius &&
      mapEquals(other.fillColors, fillColors);

  @override
  int get hashCode => Object.hash(
        cornerRadius,
        Object.hashAllUnordered(
          fillColors.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );
}

/// Draws every marker as a calm rounded **rectangle over the immutable glyph
/// layer** (engineering 08 §4; PRD R1). It carries **no text**, measures **no**
/// shaped Arabic, re-typesets nothing, and resolves each word's box only from
/// the bundled [geometry] — never from font metrics. It applies no transform or
/// colour filter (zoom/sepia/dark is E05-T09's frame, which transforms the whole
/// glyph+overlay stack uniformly).
class MushafOverlayPainter extends CustomPainter {
  /// Creates the painter for [markers] over [geometry] with [style].
  const MushafOverlayPainter({
    required this.markers,
    required this.geometry,
    required this.style,
  });

  /// The finished markers to paint (the *which-words* decision is E14's).
  final List<OverlayMarker> markers;

  /// The bundled per-word box source the glyph layer shares.
  final PageGeometry geometry;

  /// The calm, token-backed look of the markers.
  final OverlayStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    for (final marker in markers) {
      final color = style.fillColors[marker.kind];
      if (color == null) continue; // an un-styled kind paints nothing
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (final word in marker.words) {
        final box = geometry.wordRect(word.lineNumber, word.position);
        if (box == Rect.zero) continue; // no geometry → nothing to draw
        canvas.drawRRect(
          RRect.fromRectXY(box, style.cornerRadius, style.cornerRadius),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(MushafOverlayPainter oldDelegate) =>
      !listEquals(oldDelegate.markers, markers) ||
      oldDelegate.geometry != geometry ||
      oldDelegate.style != style;
}
