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
    // Lines render at their natural glyph-advance width (every QPC page line is
    // justified to the same width by the font). `IntrinsicWidth` bounds the
    // column to the widest line so the sūrah-header band can stretch to the
    // page's text width, while the frame still scales the whole column
    // uniformly; a surah's short last line is centred by its text alignment.
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in glyphPage.lines) buildGlyphLine(line),
        ],
      ),
    );
  }
}

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
  if (line.type == LineType.surahName) {
    return _SurahHeaderBand(name: line.headerText, pageNumber: line.pageNumber);
  }
  return Text(
    line.glyphCodes, // opaque QPC codes — NEVER normalise/split/search/log
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.center,
    softWrap: false,
    maxLines: 1,
    style: TextStyle(
      fontFamily:
          qpcFontFamily(line.pageNumber), // the font IS the typeset page
      fontFamilyFallback: const <String>[], // no fallback on the sacred path
    ),
  );
}

/// The sūrah-name header band: a plain hairline frame, one line tall, with the
/// sūrah name lettered in the ambient UI text style (chrome, resolved from the
/// read-only `surah` table — never a Quran glyph, never re-typeset text). It
/// inherits the ambient ink colour so the reader's theme filter treats it like
/// the glyphs. A header whose name is unknown (bundle-first, or a reference
/// without the `surah` table) keeps its blank line so the layout never shifts.
class _SurahHeaderBand extends StatelessWidget {
  const _SurahHeaderBand({required this.name, required this.pageNumber});

  final String? name;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    // Size the band to the page's own line height so the layout holds: an
    // empty run in the page font measures one glyph line.
    final lineStyle = TextStyle(
      fontFamily: qpcFontFamily(pageNumber),
      fontFamilyFallback: const <String>[],
    );
    final ink = DefaultTextStyle.of(context).style.color;
    final text = name;
    return Stack(
      alignment: Alignment.center,
      children: [
        Text('', style: lineStyle, textDirection: TextDirection.rtl),
        if (text != null)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: ink ?? const Color(0xFF000000)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    text,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
