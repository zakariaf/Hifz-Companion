// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

import 'reader_theme.dart';

/// The smallest zoom the reader allows — the page fits the viewport at `1.0`
/// (the muṣḥaf is laid out full-page, so the floor is "no shrink").
const double kReaderMinZoom = 1.0;

/// The largest zoom the reader allows — a generous magnification for tired eyes
/// without ever re-flowing the printed line breaks (it is a uniform scale).
const double kReaderMaxZoom = 4.0;

/// The immutable presentation state of the muṣḥaf reader chrome (E13 EPIC,
/// Deliverable #2): *what the reader is looking at and how it is shown* — the
/// current [pageNumber], the muṣḥaf's own [zoom], the reader [theme], and the
/// two overlay-visibility toggles.
///
/// **Display-only by construction.** It carries no card, no `due_at`, no
/// scheduling math, no glyph, no `TextStyle`, and no overlay *refs* (which
/// words a marker covers is decided elsewhere — weak-line refs from the active
/// profile's card/line-block state in T05, mutashābihāt refs from the
/// confusables dataset). It names a page; it never grades one. [zoom] is the
/// muṣḥaf's own scale — independent of OS chrome text-scale (typography 04 §1) —
/// and [theme] selects E05's `ColorFilter`, never a per-theme font.
@immutable
class MushafReaderState {
  /// Creates a reader state from explicit values (prefer [MushafReaderState.initial]).
  const MushafReaderState({
    required this.pageNumber,
    required this.zoom,
    required this.theme,
    required this.isWeakLineOverlayVisible,
    required this.isMutashabihatOverlayVisible,
  });

  /// The calm initial state for the reader opened at [pageNumber]: no zoom,
  /// light theme, both overlays hidden.
  const MushafReaderState.initial(this.pageNumber)
      : zoom = 1.0,
        theme = ReaderTheme.light,
        isWeakLineOverlayVisible = false,
        isMutashabihatOverlayVisible = false;

  /// The 1-based muṣḥaf page currently shown (lower bound 1; the upper bound is
  /// the active edition's `pageCount`, enforced by the navigator — never a
  /// hardcoded `604` here, R2 swappability).
  final int pageNumber;

  /// The uniform magnification of the rendered glyph layer (`1.0` = fit). It is
  /// the muṣḥaf's own zoom — never `MediaQuery.textScaler` (typography 04 §1).
  final double zoom;

  /// The reader display theme selecting E05's `ColorFilter` (eng-08 §5).
  final ReaderTheme theme;

  /// Whether the weak-line diagnostic overlay is shown (refs owned by T05).
  final bool isWeakLineOverlayVisible;

  /// Whether the mutashābihāt-anchor overlay is shown (refs owned by T05/T14).
  final bool isMutashabihatOverlayVisible;

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  MushafReaderState copyWith({
    int? pageNumber,
    double? zoom,
    ReaderTheme? theme,
    bool? isWeakLineOverlayVisible,
    bool? isMutashabihatOverlayVisible,
  }) =>
      MushafReaderState(
        pageNumber: pageNumber ?? this.pageNumber,
        zoom: zoom ?? this.zoom,
        theme: theme ?? this.theme,
        isWeakLineOverlayVisible:
            isWeakLineOverlayVisible ?? this.isWeakLineOverlayVisible,
        isMutashabihatOverlayVisible:
            isMutashabihatOverlayVisible ?? this.isMutashabihatOverlayVisible,
      );

  @override
  bool operator ==(Object other) =>
      other is MushafReaderState &&
      other.pageNumber == pageNumber &&
      other.zoom == zoom &&
      other.theme == theme &&
      other.isWeakLineOverlayVisible == isWeakLineOverlayVisible &&
      other.isMutashabihatOverlayVisible == isMutashabihatOverlayVisible;

  @override
  int get hashCode => Object.hash(
        pageNumber,
        zoom,
        theme,
        isWeakLineOverlayVisible,
        isMutashabihatOverlayVisible,
      );
}
