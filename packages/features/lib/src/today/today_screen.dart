// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../a11y/reduce_motion_substitution.dart';
import '../recite/recite_route.dart';
import 'today_providers.dart';
import 'today_session.dart';
import 'widgets/budget_feedback_line.dart';
import 'widgets/daily_session_list.dart';
import 'widgets/session_skeleton.dart';
import 'widgets/today_all_done.dart';
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
          ? const TodayAllDone(key: ValueKey<String>('today.allDone'))
          : _TodayDay(
              key: const ValueKey<String>('today.populated'),
              session: data,
            ),
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

/// The populated-day slot: the finite, budget-capped Far → Near → New session
/// list (E12-T03). Resolves each row's juz from the bundled reference and opens
/// the recite route on a row tap. The budget-feedback line (E12-T04) and the
/// catch-up banner (E12-T05) fill their slots here in later tasks.
class _TodayDay extends ConsumerWidget {
  const _TodayDay({required this.session, super.key});

  final TodaySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final juz = ref.watch(pageJuzProvider);
    return juz.when(
      loading: () => const SessionSkeleton(),
      error: (_, __) => TodayRetryView(
        message: l10n.commonRetry,
        onRetry: () => ref.invalidate(pageJuzProvider),
      ),
      data: (juzMap) {
        final list = DailySessionList(
          session: session,
          juzOf: (pageId) => juzMap[pageId] ?? 0,
          onOpen: (pageId) => context.push(reciteLocation(pageId)),
        );
        // The honest budget-feedback line sits above the still-complete day —
        // FAR/manzil is never dropped to fit (E12-T04). The choices deep-link to
        // the E16-owned settings (a single settings surface until E16 splits it).
        if (!session.budgetOverflow) return list;
        void toSettings() => context.push('/settings');
        return Column(
          children: <Widget>[
            BudgetFeedbackLine(
              onRaiseBudget: toSettings,
              onLengthenCycle: toSettings,
              onPauseNewSabaq: toSettings,
            ),
            Expanded(child: list),
          ],
        );
      },
    );
  }
}
