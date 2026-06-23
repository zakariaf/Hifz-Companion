// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'glyph_line.dart';
import 'mushaf_line_ref.dart';

/// The dumb, immutable renderer of one **already-verified** muṣḥaf page
/// (engineering 08 §2/§3; PRD R1). It draws each line's opaque glyph codes in
/// that page's dedicated KFGQPC family — the font selection **is** the shaping;
/// the OS shaper is never asked to lay out Quran text.
///
/// No transform, no theme filter, no zoom (that is E05-T09); no overlay/marker
/// (that is E05-T08). It holds no `type.*` token, no inherited `TextStyle`, and
/// never reads `MediaQuery.textScalerOf` — the muṣḥaf is its own pipeline and
/// never reflows with OS text-scale. A missing glyph surfaces as visible tofu
/// (`fontFamilyFallback` is empty), never a silent substitution.
class MushafPageView extends StatelessWidget {
  /// Creates the page view for an already-resolved, verified [glyphPage].
  const MushafPageView({required this.glyphPage, super.key});

  /// The assembled, verified page to draw.
  final ImmutableGlyphPage glyphPage;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _GlyphLayer(glyphPage: glyphPage),
    );
  }
}

class _GlyphLayer extends StatelessWidget {
  const _GlyphLayer({required this.glyphPage});

  final ImmutableGlyphPage glyphPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in glyphPage.lines) buildGlyphLine(line),
      ],
    );
  }
}

/// Draws one muṣḥaf line: the opaque glyph codes in the page's dedicated family,
/// RTL, with **`fontFamilyFallback: const []`** so a missing glyph fails loud as
/// visible tofu instead of being silently re-shaped by a fallback font
/// (engineering 08 §2). No soft-wrap / `TextPainter` line-breaking on Quran
/// text. Visible for the E05-T11 golden harness.
/// Renders a single muṣḥaf line from a plain [MushafLineRef] — the opaque glyph
/// codes drawn in [pageNumber]'s dedicated KFGQPC family (never the OS shaper,
/// never re-typeset). Used where the reader composes lines individually (e.g. the
/// recite flow's reveal-on-tap surface), so the feature layer never names the
/// glyph surface. Width/zoom fitting is the caller's concern.
class MushafGlyphLineView extends StatelessWidget {
  /// Creates the line view for [line] on [pageNumber].
  const MushafGlyphLineView({
    required this.pageNumber,
    required this.line,
    super.key,
  });

  /// The 1-based page the line belongs to (selects the per-page glyph font).
  final int pageNumber;

  /// The line's plain ref (line number, type, opaque glyph string).
  final MushafLineRef line;

  @override
  Widget build(BuildContext context) => buildGlyphLine(
        GlyphLine(
          pageNumber: pageNumber,
          lineNumber: line.lineNumber,
          type: line.lineType,
          glyphCodes: line.textGlyphRef,
        ),
      );
}

@visibleForTesting
Widget buildGlyphLine(GlyphLine line) {
  return Text(
    line.glyphCodes, // opaque QPC codes — NEVER normalise/split/search/log
    textDirection: TextDirection.rtl,
    softWrap: false,
    maxLines: 1,
    style: TextStyle(
      fontFamily:
          qpcFontFamily(line.pageNumber), // the font IS the typeset page
      fontFamilyFallback: const <String>[], // no fallback on the sacred path
    ),
  );
}
