// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' show MushafGlyphLineView;

import '../mushaf/mushaf_page_source.dart' show mushafPageProvider;
import 'reader_surface.dart';

/// The production [ReciteReaderSurface] backed by E13's real KFGQPC glyph
/// rendering over the verified bundled core. Injected at the app root (overriding
/// the [StubReciteReaderSurface] default) now that the bundled assets are present.
///
/// It composes one line at a time from the read-only reference projection
/// ([mushafPageProvider]) so the recite flow masks, reveals, and overlays the
/// immutable glyph layer without ever re-typesetting it (PRD R1). The glyph
/// drawing lives in `quran` ([MushafGlyphLineView]); this layer only fits a line
/// to the row width and never names the glyph surface.
class RealReciteReaderSurface implements ReciteReaderSurface {
  /// Creates the real surface.
  const RealReciteReaderSurface();

  @override
  int lineCount(int pageId) => 15; // the Madani muṣḥaf is 15 lines per page.

  @override
  Widget buildLine(BuildContext context, int pageId, int lineIndex) =>
      _ReciteGlyphLine(pageId: pageId, lineIndex: lineIndex);
}

class _ReciteGlyphLine extends ConsumerWidget {
  const _ReciteGlyphLine({required this.pageId, required this.lineIndex});

  final int pageId;
  final int lineIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(mushafPageProvider(pageId));
    return page.maybeWhen(
      data: (lines) {
        if (lineIndex < 0 || lineIndex >= lines.length) {
          // Pages with fewer than 15 lines leave the trailing rows empty.
          return const SizedBox.shrink();
        }
        // Scale the natural-size glyph line down to fit the row width; never up
        // (BoxFit.scaleDown), and never reflow the sacred text.
        return SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: MushafGlyphLineView(
              pageNumber: pageId,
              line: lines[lineIndex],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
