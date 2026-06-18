// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'glyph_line.dart';
import 'mushaf_overlay_painter.dart';
import 'mushaf_page_view.dart';

/// The reader's presentation frame around one page (engineering 08 §5): exactly
/// **one** `Transform.scale` (uniform [zoom], RTL `Alignment.topRight` origin)
/// and exactly **one** `ColorFiltered` ([colorFilter] — sepia/dark is a single
/// filter, **never** a per-theme font) wrapping the combined glyph+overlay
/// `Stack`. The overlay transforms *with* the glyphs because it is inside the
/// wrapped stack.
///
/// Zoom is the reader's **own** value — the frame never reads
/// `MediaQuery.textScalerOf`, so the muṣḥaf enlarges uniformly and printed line
/// breaks never move (PRD §18). No `fontFamily`/`TextStyle` is touched here; the
/// glyph layer (T07) and overlay (T08) own the sacred path.
class MushafReaderFrame extends StatelessWidget {
  /// Creates the frame for [glyphPage], with an optional [overlay], at [zoom]
  /// under [colorFilter].
  const MushafReaderFrame({
    required this.glyphPage,
    required this.zoom,
    required this.colorFilter,
    this.overlay,
    super.key,
  });

  /// The assembled, verified page to draw.
  final ImmutableGlyphPage glyphPage;

  /// The uniform zoom scale (the reader's own value, not OS text-scale).
  final double zoom;

  /// The theme colour filter (light = identity, sepia, dark) — one filter over
  /// the whole layer, resolved from Mihrab tokens by the caller.
  final ColorFilter colorFilter;

  /// The coordinate overlay painter, or null for a plain reading page.
  final MushafOverlayPainter? overlay;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: colorFilter,
      child: Transform.scale(
        scale: zoom,
        alignment: Alignment.topRight,
        child: Stack(
          children: [
            MushafPageView(glyphPage: glyphPage),
            if (overlay != null)
              Positioned.fill(child: CustomPaint(painter: overlay)),
          ],
        ),
      ),
    );
  }
}
