// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The reader's display theme for the muṣḥaf layer (engineering 08 §5). It
/// selects which **`ColorFilter`** E05's `MushafReaderFrame` applies over the
/// already-rendered glyph layer — sepia/dark is a colour filter, **never** a
/// per-theme font swap and **never** a re-typeset of the sacred text.
///
/// This is the single source of truth for the reader theme: E05's frame
/// consumes the resolved `ColorFilter` (token-agnostic by design), and the
/// `ReaderTheme` → `ColorFilter` mapping from Mihrab tokens has its one home in
/// the reader controls (E13-T06). The reader-state store (E13-T02) carries this
/// value; nothing here touches a glyph, a `TextStyle`, or OS text-scale.
enum ReaderTheme {
  /// The default paper-on-light reading surface (identity colour filter).
  light,

  /// A warm sepia reading surface (a colour filter over the glyph layer).
  sepia,

  /// A dark reading surface (a colour filter — never a darker font).
  dark,
}
