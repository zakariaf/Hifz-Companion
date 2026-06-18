// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Immutable muṣḥaf rendering for Hifz Companion: the per-page KFGQPC glyph
/// renderer and the coordinate-overlay painter.
///
/// Glyph-font selection and glyph-code drawing (never the OS shaper, never
/// parsing the glyph string as Arabic text) and the overlay painter are authored
/// in E05. Geometry arrives as plain value types, so this package has no local
/// dependency and golden-tests in isolation.
library;

export 'src/page_geometry.dart';
export 'src/quran_page_placeholder.dart';
export 'src/render/assemble_page.dart' show MushafLayout, assemblePage;
export 'src/render/glyph_line.dart'
    show GlyphLine, ImmutableGlyphPage, LayoutWord, LineType, qpcFontFamily;
export 'src/render/mushaf_overlay_painter.dart'
    show MushafOverlayPainter, OverlayStyle;
export 'src/render/mushaf_page_navigator.dart' show MushafPageNavigator;
export 'src/render/mushaf_page_view.dart' show MushafPageView;
export 'src/render/mushaf_reader_frame.dart' show MushafReaderFrame;
export 'src/render/overlay_marker.dart'
    show OverlayKind, OverlayMarker, WordRef;
