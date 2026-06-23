// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart'
    show
        ImmutableGlyphPage,
        MushafOverlayPainter,
        MushafReaderFrame,
        OverlayKind,
        OverlayStyle;

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../mushaf_page_source.dart';
import '../mushaf_providers.dart';
import '../overlay_markers.dart';
import '../overlay_providers.dart';
import '../reader_color_filter.dart';

/// Pages the reader through the muṣḥaf right-to-left without ever re-shaping a
/// glyph (PRD §11.2, §12.3). A `PageView.builder` whose `reverse` is derived
/// from `Directionality.of(context)` (so page 1→2 advances right-to-left in
/// fa/ckb/ar), bound to the E13-T02 reader-state store both ways:
///
/// - **state → controller:** an external `pageNumber` change (jump-to,
///   deep-link, restore) is observed with `ref.listen` (so the seek runs
///   *outside* build) and drives `_controller.jumpToPage`, guarded so a
///   store-driven seek does not re-seek;
/// - **controller → state:** a settled swipe writes the landed page back through
///   `setPage` only — and only when it actually differs, breaking the
///   seek→onPageChanged→setPage echo.
///
/// Each page is a pure `pageNumber` rebuild: the dedicated `QPC_P###` font, the
/// bundled QUL geometry, and the overlay coordinates are *re-selected* per page
/// by E05 — never mirrored, reordered, re-flowed, or re-rendered. RTL lives in
/// the paging direction only, never in the glyph layer. Paging is display-only:
/// it mutates no card, appends no `review_log`, and re-derives no `due_at`. The
/// `StatefulWidget` exists solely to own and dispose the `PageController`.
class MushafPager extends ConsumerStatefulWidget {
  /// Creates the pager for the reader opened at [entryPage] (the reader-state
  /// store's family key it binds to).
  const MushafPager({required this.entryPage, super.key});

  /// The page the reader was opened on — the reader-state store's family key.
  final int entryPage;

  @override
  ConsumerState<MushafPager> createState() => _MushafPagerState();
}

class _MushafPagerState extends ConsumerState<MushafPager> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    final initialPage =
        ref.read(mushafReaderStateProvider(widget.entryPage)).pageNumber;
    _controller = PageController(initialPage: initialPage - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = ref.watch(activeEditionProvider).pageCount;

    // State → controller: drive the page on an external change only. Using
    // `listen` (not `watch`) runs the seek after build, so jumpToPage never
    // re-enters the build that requested it; the guard avoids re-seeking the
    // page the controller already shows.
    ref.listen<int>(
      mushafReaderStateProvider(widget.entryPage)
          .select((state) => state.pageNumber),
      (_, next) {
        final target = next.clamp(1, pageCount) - 1;
        if (_controller.hasClients && _controller.page?.round() != target) {
          _controller.jumpToPage(target);
        }
      },
    );

    // RTL is the *only* knob the pager turns: it flips the paging/gesture
    // direction, never the page content. Derived, never hardcoded.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return PageView.builder(
      controller: _controller,
      reverse: isRtl,
      itemCount: pageCount,
      onPageChanged: (index) {
        final page = index + 1;
        final notifier =
            ref.read(mushafReaderStateProvider(widget.entryPage).notifier);
        // Write back only a *user* page turn; a store-driven seek re-reports
        // the page the store already holds (skip it — no echo, no write loop).
        if (ref.read(mushafReaderStateProvider(widget.entryPage)).pageNumber !=
            page) {
          notifier.setPage(page);
        }
      },
      itemBuilder: (context, index) =>
          _MushafPageSlot(pageNumber: index + 1, entryPage: widget.entryPage),
    );
  }
}

/// One page slot: it watches the verified glyph layout for [pageNumber] and
/// draws E05's immutable page inside the reader frame. While the (offline)
/// reference read resolves — and on the bundle-first empty reference — it shows
/// a calm blank rather than a spinner over the sacred surface; the page is never
/// dressed up.
class _MushafPageSlot extends ConsumerWidget {
  const _MushafPageSlot({required this.pageNumber, required this.entryPage});

  final int pageNumber;
  final int entryPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(mushafPageProvider(pageNumber));
    return page.maybeWhen(
      data: (glyphPage) => _PageFrame(
        glyphPage: glyphPage,
        pageNumber: pageNumber,
        entryPage: entryPage,
      ),
      orElse: () => const SizedBox.expand(),
    );
  }
}

/// The reader frame around one page: E05's `MushafReaderFrame` applies the zoom
/// (the reader's own scale, T02) and the theme colour filter (identity here;
/// E13-T06 maps sepia/dark) over the glyph layer, with the toggleable weak-line
/// + mutashābihāt overlay painted by E05 from coordinate refs only (E13-T05).
class _PageFrame extends ConsumerWidget {
  const _PageFrame({
    required this.glyphPage,
    required this.pageNumber,
    required this.entryPage,
  });

  final ImmutableGlyphPage glyphPage;
  final int pageNumber;
  final int entryPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mushafReaderStateProvider(entryPage));
    final geometry = ref.watch(mushafPageGeometryProvider(pageNumber));
    final markers = overlayMarkers(
      pageNumber: pageNumber,
      weakLineVisible: state.isWeakLineOverlayVisible,
      mutashabihVisible: state.isMutashabihatOverlayVisible,
      weakLines: ref.watch(profileWeakLinesProvider(pageNumber)),
      confusables: ref.watch(pageConfusablesProvider(pageNumber)),
      geometry: geometry,
    );
    return MushafReaderFrame(
      glyphPage: glyphPage,
      // The reader's own zoom (T02), independent of OS chrome text-scale, and
      // the theme's single ColorFilter (T06) — both layer transforms in E05's
      // frame; one font per page, no re-flow.
      zoom: state.zoom,
      colorFilter: colorFilterForReaderTheme(state.theme),
      overlay: markers.isEmpty
          ? null
          : MushafOverlayPainter(
              markers: markers,
              geometry: geometry,
              style: _overlayStyle(context),
            ),
    );
  }
}

/// The calm, diagnostic look of the overlay markers — token colours by name
/// (a low-alpha warning fill for a weak line, a low-alpha gold for an anchor),
/// never a red shame mark, glow, or ornament over an āyah (adab §3).
OverlayStyle _overlayStyle(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.extension<MihrabColors>()!;
  final space = theme.extension<SpacingTokens>()!;
  return OverlayStyle(
    fillColors: {
      OverlayKind.weakLine: colors.semanticWarning.withValues(alpha: 0.18),
      OverlayKind.mutashabihAnchor: colors.accentGold.withValues(alpha: 0.18),
    },
    cornerRadius: space.space1,
  );
}
