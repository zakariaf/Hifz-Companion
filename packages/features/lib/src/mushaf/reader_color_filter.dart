// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'reader_theme.dart';

/// The single `ColorFilter` E05's `MushafReaderFrame` applies over the whole
/// rendered glyph+overlay layer for a [ReaderTheme] (engineering 08 §5). This is
/// the **one** place `ReaderTheme` becomes a colour transform: there is exactly
/// one font per page, dark/sepia is a colour filter — **never** a per-theme font
/// swap and **never** a "dark font". The filter recolours the rendered layer; it
/// moves no glyph and re-flows nothing.
ColorFilter colorFilterForReaderTheme(ReaderTheme theme) => switch (theme) {
      ReaderTheme.light => _identity,
      ReaderTheme.sepia => _sepia,
      ReaderTheme.dark => _invert,
    };

/// Light leaves the rendered layer untouched.
const ColorFilter _identity = ColorFilter.matrix(<double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// A warm sepia tone over the whole layer (the standard sepia luminance matrix).
const ColorFilter _sepia = ColorFilter.matrix(<double>[
  0.393, 0.769, 0.189, 0, 0, //
  0.349, 0.686, 0.168, 0, 0, //
  0.272, 0.534, 0.131, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// Dark = a colour-inversion of the rendered layer (dark ink → light on dark) —
/// a filter, never a darker font; the glyphs are byte-identical to light.
const ColorFilter _invert = ColorFilter.matrix(<double>[
  -1, 0, 0, 0, 255, //
  0, -1, 0, 0, 255, //
  0, 0, -1, 0, 255, //
  0, 0, 0, 1, 0, //
]);
