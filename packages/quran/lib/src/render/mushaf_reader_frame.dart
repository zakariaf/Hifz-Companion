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
        // Scale the whole page (glyph layer + overlay together) uniformly to fill
        // the reader viewport — the QPC glyphs have no inherent point size, so at
        // their natural advance width a page would render tiny and top-aligned.
        // `SizedBox.expand` forces the fit box to the full viewport (a bare
        // FittedBox under loose constraints would just take the child's natural
        // size and not scale); `contain` then keeps the page's aspect and shows it
        // whole. The overlay rides the same transform, so markers stay registered
        // to the glyphs. The user's own [zoom] multiplies on top of this fit.
        child: SizedBox.expand(
          child: FittedBox(
            // Default fit is `contain`: keep the page's aspect, show it whole.
            child: Stack(
              children: [
                MushafPageView(glyphPage: glyphPage),
                if (overlay != null)
                  Positioned.fill(child: CustomPaint(painter: overlay)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
