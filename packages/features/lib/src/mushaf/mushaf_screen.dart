// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show activeProfileProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import 'mushaf_providers.dart';
import 'mushaf_view_model.dart';
import 'widgets/mushaf_chrome.dart';

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

/// The reader scaffold: E13-T08's no-dashboard chrome — the page dominates and
/// the controls recede to auto-hiding edge bands, with the riwāyah/edition label
/// always named (R2). RTL is the ambient locale direction; the reader sets no
/// hardcoded `Directionality`.
class _ReaderScaffold extends StatelessWidget {
  const _ReaderScaffold({required this.state, required this.page});

  final MushafReaderScaffoldState state;
  final int page;

  @override
  Widget build(BuildContext context) {
    // RTL is locale-derived (the app-wide Directionality is RTL for fa/ckb/ar);
    // the glyph layer forces its own RTL inside E05's MushafPageView and the
    // pager derives its paging direction from context — the reader sets no
    // hardcoded Directionality of its own.
    return KeyedSubtree(
      key: const ValueKey<String>('screen.mushaf'),
      // Key the chrome by the entry page so a new deep-link (e.g. /mushaf?page=1
      // → /mushaf?page=300) recreates the pager — its PageController is seeded
      // once in initState, so a static key would strand it on the first page.
      child: MushafChrome(
        key: ValueKey<int>(page),
        edition: state.edition,
        page: page,
      ),
    );
  }
}
