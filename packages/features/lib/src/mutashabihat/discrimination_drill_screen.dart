// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/spacing_tokens.dart';
import 'discrimination_drill_view_model.dart';
import 'widgets/drill_branch_view.dart';
import 'widgets/drill_progress_strip.dart';

/// The discrimination-drill View (E14-T08): iterates the **whole** confusable
/// group A→B→… back-to-back in one session — no spacing, interstitial, or
/// unrelated page between siblings — each branch hidden → reveal-on-tap → anchor.
///
/// A dumb `ConsumerWidget` reading exactly one controller and rendering the calm
/// loading/error/data shells; it composes E05's immutable page, logs no swap,
/// reads no `DateTime.now()`, and shows no score/streak/confetti.
class DiscriminationDrillScreen extends ConsumerWidget {
  /// Creates the drill for confusable [groupId].
  const DiscriminationDrillScreen({required this.groupId, super.key});

  /// The confusable group being drilled (the controller's family key).
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(discriminationDrillControllerProvider(groupId));
    return KeyedSubtree(
      key: const ValueKey<String>('screen.mutashabihat.drill'),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.navMutashabihat)),
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: FilledButton(
              onPressed: () => ref.invalidate(
                discriminationDrillControllerProvider(groupId),
              ),
              child: Text(l10n.commonRetry),
            ),
          ),
          data: (s) => s.isComplete
              ? _DrillComplete(message: l10n.mutashabihatDrillComplete)
              : _DrillActive(groupId: groupId, state: s),
        ),
      ),
    );
  }
}

/// The active drill: the calm position strip, the active branch, and — once the
/// branch is anchored — a single quiet "next sibling" advance (back-to-back, no
/// interstitial). No score, no streak, no celebration.
class _DrillActive extends ConsumerWidget {
  const _DrillActive({required this.groupId, required this.state});

  final String groupId;
  final DiscriminationDrillState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final controller =
        ref.read(discriminationDrillControllerProvider(groupId).notifier);
    return Column(
      children: [
        DrillProgressStrip(
          position: state.activeIndex + 1,
          total: state.members.length,
        ),
        Expanded(
          child: DrillBranchView(
            // Key by index so advancing to the next sibling rebuilds the branch.
            key: ValueKey<int>(state.activeIndex),
            member: state.activeMember,
            phase: state.activePhase,
            onReveal: controller.reveal,
            onShowAnchor: controller.showAnchor,
          ),
        ),
        if (state.activePhase == BranchPhase.anchored)
          Padding(
            padding: EdgeInsetsDirectional.all(space.space4),
            child: FilledButton(
              onPressed: controller.next,
              child: Text(l10n.mutashabihatDrillNext),
            ),
          ),
      ],
    );
  }
}

/// The calm terminal surface after the last sibling — one closing line, never a
/// celebration, never "cured"/"safe to drop". The app-bar back returns quietly
/// to the trainer.
class _DrillComplete extends StatelessWidget {
  const _DrillComplete({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: space.space4),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).commonBack),
            ),
          ],
        ),
      ),
    );
  }
}
