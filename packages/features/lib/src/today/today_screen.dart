// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../a11y/reduce_motion_substitution.dart';
import '../design_system/banners/empty_state.dart';
import 'today_providers.dart';
import 'widgets/session_skeleton.dart';
import 'widgets/today_retry_view.dart';

/// The Today tab: a **dumb** View over the 1:1 [todayControllerProvider]
/// (04 §1.3). It reads exactly one controller and renders its four calm states —
/// `loading` skeleton, `error` retry, the calm all-done close, and the populated
/// day — never calling the engine, never sorting/capping/load-balancing, never
/// reading `DateTime.now()`. The grouped Far → Near → New list (E12-T03), the
/// budget-feedback line (E12-T04), and the catch-up banner (E12-T05) fill the
/// `populated` / catch-up slots this scaffold lays out.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(todayControllerProvider);

    // Each state carries a distinct key so the calm content cross-fade (instant
    // under the OS Reduce Motion flag, E08-T05) is detected on transition.
    final content = session.when(
      loading: () => const SessionSkeleton(key: ValueKey<String>('today.loading')),
      error: (error, _) => TodayRetryView(
        key: const ValueKey<String>('today.error'),
        message: l10n.commonRetry,
        onRetry: () => ref.invalidate(todayControllerProvider),
      ),
      data: (data) => data.isEmpty
          ? EmptyState(
              key: const ValueKey<String>('today.allDone'),
              model: EmptyStateModel(
                kind: EmptyStateKind.allDone,
                body: l10n.emptyAllDone,
              ),
            )
          : const _TodayDayPlaceholder(key: ValueKey<String>('today.populated')),
    );

    return Semantics(
      identifier: 'screen.today',
      container: true,
      label: l10n.todaySemanticTitle,
      explicitChildNodes: true,
      child: SafeArea(child: ReduceMotionSwitcher(child: content)),
    );
  }
}

/// The populated-day slot. E12-T03 replaces this placeholder with the finite,
/// budget-capped Far → Near → New session list assembling the E10 page cards.
class _TodayDayPlaceholder extends StatelessWidget {
  const _TodayDayPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n.todaySemanticTitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
