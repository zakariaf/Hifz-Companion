// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show activeProfileProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:quran/quran.dart' show ImmutableGlyphPage, MushafPageView;

import '../design_system/theme/spacing_tokens.dart';
import 'mushaf_providers.dart';
import 'mushaf_view_model.dart';

/// The Muṣḥaf reader tab — the dumb View over E05's immutable page renderer
/// (PRD §11.2, §12.3). It re-shapes, re-typesets, re-flows, and re-derives
/// **nothing**: it reads one controller, names the active riwāyah in chrome, and
/// embeds [MushafPageView] for the current page under an RTL `Directionality`.
///
/// This task lands the navigable scaffold and the riwāyah chrome only. The RTL
/// paged navigator (T03), the jump-to surface (T04), the overlay toggles (T05),
/// and the zoom/theme controls (T06) fill the body in. Reader state is
/// display-only — the View mutates no card, appends no `review_log`, opens no
/// socket, and surfaces no "done"/score/streak.
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
/// absolutely) above E05's immutable [MushafPageView], under an RTL
/// `Directionality`. T03 swaps the single page for the RTL paged navigator.
class _ReaderScaffold extends StatelessWidget {
  const _ReaderScaffold({required this.state, required this.page});

  final MushafReaderState state;
  final int page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Directionality(
      key: const ValueKey<String>('screen.mushaf'),
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.all(space.space3),
            // The named riwāyah/edition — verbatim domain data (R2); T07 builds
            // the full localized chrome + About/Credits attribution.
            child: Text(
              state.edition.displayName,
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              // Bundle-first: the verified reference DB is empty until the core
              // pack installs, so the page assembles to zero lines (a blank
              // page) today; T03 wires the real per-page glyph seam. The render
              // path is E05's and is never relaxed here.
              child: MushafPageView(
                glyphPage: ImmutableGlyphPage(
                  pageNumber: page,
                  lines: const [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
