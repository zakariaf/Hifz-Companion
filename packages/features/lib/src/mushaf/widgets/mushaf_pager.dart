// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' show MushafPageView;

import '../mushaf_page_source.dart';
import '../mushaf_providers.dart';

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
      itemBuilder: (context, index) => _MushafPageSlot(pageNumber: index + 1),
    );
  }
}

/// One page slot: it watches the verified glyph layout for [pageNumber] and
/// draws E05's immutable `MushafPageView`. While the (offline) reference read
/// resolves — and on the bundle-first empty reference — it shows a calm blank
/// rather than a spinner over the sacred surface; the page is never dressed up.
class _MushafPageSlot extends ConsumerWidget {
  const _MushafPageSlot({required this.pageNumber});

  final int pageNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(mushafPageProvider(pageNumber));
    return page.maybeWhen(
      data: (glyphPage) => MushafPageView(glyphPage: glyphPage),
      orElse: () => const SizedBox.expand(),
    );
  }
}
