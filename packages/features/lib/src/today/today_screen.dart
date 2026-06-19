// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show Card, ReviewGrade;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/spacing_tokens.dart';
import 'today_providers.dart';
import 'widgets/page_card.dart';

/// The Today tab: the engine-selected due pages (Far → Near → New) for the
/// active profile, a dumb View over the reactive [todayQueueProvider]. A graded
/// page routes through the single write path ([ReviewRecorder]); the committed
/// review re-emits the stream and the page leaves the list — there is no manual
/// refresh.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final queue = ref.watch(todayQueueProvider);

    Future<void> grade(Card card, ReviewGrade reviewGrade) async {
      final profile = ref.read(activeProfileProvider);
      if (profile == null) return;
      try {
        await ref.read(reviewRecorderProvider).recordReview(
              profile: profile,
              pageId: card.pageId,
              grade: reviewGrade,
              today: ref.read(todayProvider),
            );
      } on Exception {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.commonRetry)),
          );
        }
      }
    }

    return Semantics(
      identifier: 'screen.today',
      explicitChildNodes: true,
      child: SafeArea(
        child: queue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _RetryView(
            message: l10n.commonRetry,
            onRetry: () => ref.invalidate(todayQueueProvider),
          ),
          data: (cards) => cards.isEmpty
              ? _EmptyToday(message: l10n.todayEmpty)
              : _TodayList(cards: cards, onGrade: grade),
        ),
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.cards, required this.onGrade});

  final List<Card> cards;
  final void Function(Card card, ReviewGrade grade) onGrade;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return ListView.builder(
      padding: EdgeInsetsDirectional.all(space.space3),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return PageCard(
          key: ValueKey<int>(card.pageId),
          card: card,
          onGrade: (grade) => onGrade(card, grade),
        );
      },
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _RetryView extends StatelessWidget {
  const _RetryView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: space.space3,
        children: [
          FilledButton(onPressed: onRetry, child: Text(message)),
        ],
      ),
    );
  }
}
