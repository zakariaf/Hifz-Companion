// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import 'mutashabihat_trainer_view_model.dart';
import 'widgets/confusion_hotspots_view.dart';

/// The Mutashābihāt (similar-verses) trainer tab — the dumb View over the
/// E14-T06 read models (PRD §9.3, §12.4). It reads exactly one controller and
/// renders the calm `loading`/`error`/`data` shells; it composes no drill
/// (E14-T08), draws no anchor overlay (E14-T09), lists no hotspots (E14-T10),
/// and logs no swap (E14-T03).
///
/// RTL is locale-derived (the app-wide `Directionality` is RTL for fa/ckb/ar);
/// the View forces none of its own. It renders no Quran glyph and re-typesets no
/// āyah — an aid to revision, never a scoreboard.
class MutashabihatTrainerScreen extends ConsumerWidget {
  /// Creates the trainer tab.
  const MutashabihatTrainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(mutashabihatTrainerControllerProvider);
    return KeyedSubtree(
      key: const ValueKey<String>('screen.mutashabihat'),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.navMutashabihat)),
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: FilledButton(
              onPressed: () =>
                  ref.invalidate(mutashabihatTrainerControllerProvider),
              child: Text(l10n.commonRetry),
            ),
          ),
          // The personal confusion hotspots ("you keep swapping these two"),
          // each row tapping into its whole-group drill (E14-T10). It carries
          // its own calm empty/loading states.
          data: (_) => const ConfusionHotspotsView(),
        ),
      ),
    );
  }
}
