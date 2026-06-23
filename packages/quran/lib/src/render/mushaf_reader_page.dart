// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'glyph_line.dart';
import 'mushaf_line_ref.dart';
import 'mushaf_overlay_painter.dart';
import 'mushaf_reader_frame.dart';

/// Assembles one muṣḥaf page from plain [MushafLineRef]s and renders it inside
/// E05's [MushafReaderFrame] (the uniform [zoom] `Transform.scale` + the theme
/// [colorFilter], with an optional coordinate [overlay]). The immutable glyph
/// page is built **here, inside the `quran` package** — so the feature layer
/// never names the glyph surface (`ImmutableGlyphPage`/`glyphCodes`) and the
/// "two pipelines, one rule" wall stays intact (design-system 04 §1; PRD R1).
///
/// The assembly is a pure re-selection: each ref's opaque `textGlyphRef` becomes
/// a line's glyph codes, drawn straight by the page's dedicated KFGQPC font;
/// nothing is re-shaped, re-typeset, or reflowed.
class MushafReaderPage extends StatelessWidget {
  /// Creates the page for [pageNumber] from [lines], framed by [zoom] /
  /// [colorFilter] with an optional [overlay].
  const MushafReaderPage({
    required this.pageNumber,
    required this.lines,
    required this.zoom,
    required this.colorFilter,
    this.overlay,
    super.key,
  });

  /// The 1-based muṣḥaf page being rendered.
  final int pageNumber;

  /// The page's line refs in line order.
  final List<MushafLineRef> lines;

  /// The reader's own uniform zoom (never OS text-scale).
  final double zoom;

  /// The theme colour filter over the whole rendered layer.
  final ColorFilter colorFilter;

  /// The coordinate overlay painter, or null for a plain reading page.
  final MushafOverlayPainter? overlay;

  @override
  Widget build(BuildContext context) {
    final glyphPage = ImmutableGlyphPage(
      pageNumber: pageNumber,
      lines: [
        for (final ref in lines)
          GlyphLine(
            pageNumber: pageNumber,
            lineNumber: ref.lineNumber,
            type: ref.lineType,
            glyphCodes: ref.textGlyphRef,
          ),
      ],
    );
    return MushafReaderFrame(
      glyphPage: glyphPage,
      zoom: zoom,
      colorFilter: colorFilter,
      overlay: overlay,
    );
  }
}
