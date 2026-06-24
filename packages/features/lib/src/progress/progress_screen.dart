// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import 'progress_view_model.dart';
import 'widgets/progress_empty_state.dart';
import 'widgets/progress_overview_view.dart';

/// The Progress tab: a **dumb** View over the 1:1 [progressControllerProvider]
/// (04 §1.3). It renders the streamed [ProgressOverview] — the whole-Quran
/// retention heat-map — and never calls the engine, never recomputes `R`/the
/// roll-up, never reads `DateTime.now()`, and opens no socket. It draws no Quran
/// glyph (the visualization layer is glyph-free; PRD R1). A first-run profile
/// with no held pages gets the welcoming empty state; otherwise the overview
/// (juz roll-up grid + weakest-pages list + upcoming-load forecast). No streak,
/// score, or scoreboard anywhere (PRD R3).
class ProgressScreen extends ConsumerWidget {
  /// Creates the Progress screen.
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(progressControllerProvider);

    final content = overview.when(
      loading: () => const Center(
        key: ValueKey<String>('progress.loading'),
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (_, __) => _ProgressRetry(
        key: const ValueKey<String>('progress.error'),
        onRetry: () => ref.invalidate(progressControllerProvider),
      ),
      data: (data) => data.hasMemorizedPages
          ? ProgressOverviewView(
              key: const ValueKey<String>('progress.overview'),
              overview: data,
            )
          : const ProgressEmptyState(key: ValueKey<String>('progress.empty')),
    );

    return Semantics(
      // The key the shell/redirect tests find this destination by (kept from the
      // E07 placeholder); the identifier is the screen-reader container id.
      key: const ValueKey<String>('screen.progress'),
      identifier: 'screen.progress',
      container: true,
      label: l10n.navProgress,
      explicitChildNodes: true,
      child: SafeArea(child: content),
    );
  }
}

/// A calm retry when the read model errors — no alarm, just an offer to retry.
class _ProgressRetry extends StatelessWidget {
  const _ProgressRetry({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
    );
  }
}
