// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show activeProfileProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/spacing_tokens.dart';
import 'mushaf_providers.dart';
import 'mushaf_view_model.dart';
import 'widgets/jump_picker.dart';
import 'widgets/mushaf_pager.dart';
import 'widgets/reader_theme_control.dart';
import 'widgets/reader_zoom_control.dart';
import 'widgets/riwayah_chrome_label.dart';

/// The Muṣḥaf reader tab — the dumb View over E05's immutable page renderer
/// (PRD §11.2, §12.3). It re-shapes, re-typesets, re-flows, and re-derives
/// **nothing**: it reads one controller, names the active riwāyah in chrome, and
/// hosts the RTL paged navigator (T03) and the jump-to picker (T04).
///
/// RTL is locale-derived — the reader forces no `Directionality` of its own; the
/// glyph layer forces its own RTL inside E05's `MushafPageView`. The overlay
/// toggles (T05), zoom/theme controls (T06), and the full riwāyah chrome +
/// attribution (T07) fill the rest in. Reader state is display-only — the View
/// mutates no card, appends no `review_log`, opens no socket, and surfaces no
/// "done"/score/streak.
class MushafReaderScreen extends ConsumerWidget {
  /// Creates the reader, optionally deep-linked to a [initialPage] / [initialJuz]
  /// / [initialHizb] / [initialSurah] (the juz/ḥizb/sūrah → page resolution is
  /// E13-T04's; here the page param lands directly).
  const MushafReaderScreen({
    this.initialPage,
    this.initialJuz,
    this.initialHizb,
    this.initialSurah,
    super.key,
  });

  /// The deep-linked starting page (1..604), or null for the reader's home page.
  final int? initialPage;

  /// The deep-linked juz (1..30), resolved to a page by T04.
  final int? initialJuz;

  /// The deep-linked ḥizb (1..60), resolved to a page by T04.
  final int? initialHizb;

  /// The deep-linked sūrah (1..114), resolved to a page by T04.
  final int? initialSurah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    // Behind the router's redirect guard a profile always exists; render
    // nothing rather than throw if reached without one.
    if (profile == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final reader = ref.watch(mushafReaderViewModelProvider(profile));
    return reader.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: FilledButton(
          onPressed: () =>
              ref.invalidate(mushafReaderViewModelProvider(profile)),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (state) => _ReaderScaffold(
        state: state,
        // T04 resolves a juz/ḥizb/sūrah deep link to its page from the fixed
        // bundled structure; until then only the direct page param lands.
        page: initialPage ?? state.initialPage,
      ),
    );
  }
}

/// The reader scaffold: the always-named riwāyah chrome (R2 — never "the Quran"
/// absolutely), the overlay toggles, and the jump-to entry above the RTL paged
/// navigator. RTL is the ambient locale direction; the reader sets no hardcoded
/// `Directionality`.
class _ReaderScaffold extends StatelessWidget {
  const _ReaderScaffold({required this.state, required this.page});

  final MushafReaderScaffoldState state;
  final int page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    // RTL is locale-derived (the app-wide Directionality is RTL for fa/ckb/ar);
    // the glyph layer forces its own RTL inside E05's MushafPageView and the
    // pager derives its paging direction from context — the reader sets no
    // hardcoded Directionality of its own.
    final l10n = AppLocalizations.of(context);
    return Column(
      key: const ValueKey<String>('screen.mushaf'),
      children: [
        Padding(
          padding: EdgeInsetsDirectional.all(space.space3),
          child: Row(
            children: [
              // The always-named riwāyah/edition + the About/Credits entry (R2 —
              // never "the Quran" absolutely); chrome, kept apart from the page.
              Expanded(child: RiwayahChromeLabel(edition: state.edition)),
              // Jump-to (juz/ḥizb/sūrah/page); T08 folds it into the edge chrome.
              IconButton(
                onPressed: () => showMushafJumpPicker(context, entryPage: page),
                tooltip: l10n.mushafJumpTitle,
                icon: const Icon(Icons.menu_book_outlined),
              ),
            ],
          ),
        ),
        // The reader controls — theme, zoom, and the diagnostic overlay toggles
        // (default off). All display-only layer transforms; T08 folds them into
        // the auto-hiding edge chrome.
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: space.space3),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: space.space2,
            runSpacing: space.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ReaderThemeControl(entryPage: page),
              ReaderZoomControl(entryPage: page),
              _OverlayToggles(entryPage: page),
            ],
          ),
        ),
        // The RTL paged navigator over E05's immutable page renderer; each page
        // is a pure pageNumber/geometry rebuild, never re-typeset. The store is
        // seeded at this entry page (T02) and the pager binds to it.
        Expanded(child: MushafPager(entryPage: page)),
      ],
    );
  }
}

/// The two diagnostic overlay toggles (weak-line, mutashābihāt). Both default
/// **off** — a clean page first; diagnostics are opt-in, never forced on the
/// sacred surface. Flipping a toggle is display-only (T02): it mutates no card,
/// writes no `review_log`, and shows no badge/count/celebration.
class _OverlayToggles extends ConsumerWidget {
  const _OverlayToggles({required this.entryPage});

  final int entryPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(mushafReaderStateProvider(entryPage));
    final notifier = ref.read(mushafReaderStateProvider(entryPage).notifier);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          isSelected: state.isWeakLineOverlayVisible,
          onPressed: notifier.toggleWeakLineOverlay,
          tooltip: l10n.mushafOverlayWeakLines,
          icon: const Icon(Icons.subject_outlined),
          selectedIcon: const Icon(Icons.subject),
        ),
        IconButton(
          isSelected: state.isMutashabihatOverlayVisible,
          onPressed: notifier.toggleMutashabihatOverlay,
          tooltip: l10n.mushafOverlayMutashabihat,
          icon: const Icon(Icons.compare_arrows_outlined),
          selectedIcon: const Icon(Icons.compare_arrows),
        ),
      ],
    );
  }
}
