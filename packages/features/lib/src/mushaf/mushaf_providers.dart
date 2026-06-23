// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart'
    show MushafEdition, ProfileId, kKfgqpcHafsMadaniV2Edition;

import 'mushaf_reader_state.dart';
import 'mushaf_view_model.dart';
import 'reader_theme.dart';

/// The active muṣḥaf edition the reader names and renders (R2). v1 ships the one
/// bundled edition — KFGQPC Ḥafṣ ʿan ʿĀṣim, Madani 15-line; **E16
/// settings-profiles-teacher** overrides this provider when the user swaps the
/// `mushaf_id` triple. Defined here (scoped to the reader feature) rather than
/// global: the reader is the only surface that reads the active edition today.
final activeEditionProvider = Provider<MushafEdition>(
  (ref) => kKfgqpcHafsMadaniV2Edition,
);

/// The 1:1 reader view-model provider — `family`-keyed by the active
/// [ProfileId] (T05's weak-line refs key on it) and `autoDispose` (the heavy
/// reader is released with its screen). The dumb `MushafReaderScreen` reads
/// exactly this; tests drive it by overriding the injected providers
/// ([activeEditionProvider]), never the notifier.
final mushafReaderViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<MushafReaderViewModel, MushafReaderScaffoldState, ProfileId>(
  MushafReaderViewModel.new,
);

/// The reader-chrome presentation store — `family`-keyed by the entry page
/// (the deep-link-resolved page that seeds it) and `autoDispose` (reader chrome
/// state is bounded to the open reader screen and must not leak across reader
/// sessions). It is the single source of presentation truth for the chrome:
/// current page, zoom, theme, and the two overlay-visibility toggles.
///
/// **Display-only by construction (E13 epic DoD):** every command is a pure,
/// synchronous, total `copyWith` rebuild. Not one reaches a repository/DAO/
/// engine, opens a `db.transaction`, appends a `review_log`, re-derives a
/// `due_at`, or reads `DateTime.now()` — the store owns *what the reader looks
/// at and how it is shown*, nothing about *what the page is worth*.
final mushafReaderStateProvider = NotifierProvider.autoDispose
    .family<MushafReaderNotifier, MushafReaderState, int>(
  MushafReaderNotifier.new,
);

/// The reader-chrome notifier over one immutable [MushafReaderState]. Seeded at
/// the [entryPage] (never a clock, never recomputed); its commands are pure
/// state rebuilds (no I/O, no engine, no persistence) — the single-write-path
/// rule is satisfied here *by absence*.
class MushafReaderNotifier extends Notifier<MushafReaderState> {
  /// Creates the notifier for the reader opened at [entryPage] (the family key).
  MushafReaderNotifier(this.entryPage);

  /// The page the reader was opened on — the seed for [build].
  final int entryPage;

  @override
  MushafReaderState build() => MushafReaderState.initial(entryPage);

  /// Shows page [pageNumber] (1-based). Total: the bound is an `assert` (in-app
  /// navigation, not an I/O boundary), never a `throw`; the navigator already
  /// keeps it within the edition's `pageCount`.
  void setPage(int pageNumber) {
    assert(pageNumber >= 1, 'pageNumber must be ≥ 1, got $pageNumber');
    state = state.copyWith(pageNumber: pageNumber);
  }

  /// Sets the uniform [zoom] scale — the muṣḥaf's own zoom, **never**
  /// `MediaQuery`/`textScaler` (typography 04 §1). Total: bounds are `assert`s.
  void setZoom(double zoom) {
    assert(
      zoom.isFinite && zoom >= kReaderMinZoom && zoom <= kReaderMaxZoom,
      'zoom must be finite within [$kReaderMinZoom, $kReaderMaxZoom], got $zoom',
    );
    state = state.copyWith(zoom: zoom);
  }

  /// Selects the reader [theme]; the value is handed to E05's `ColorFilter`
  /// frame downstream — no font swap, no re-flow (eng-08 §5).
  void setTheme(ReaderTheme theme) => state = state.copyWith(theme: theme);

  /// Flips the weak-line overlay's visibility only (it owns no refs).
  void toggleWeakLineOverlay() => state = state.copyWith(
        isWeakLineOverlayVisible: !state.isWeakLineOverlayVisible,
      );

  /// Flips the mutashābihāt-anchor overlay's visibility only (it owns no refs).
  void toggleMutashabihatOverlay() => state = state.copyWith(
        isMutashabihatOverlayVisible: !state.isMutashabihatOverlayVisible,
      );
}
