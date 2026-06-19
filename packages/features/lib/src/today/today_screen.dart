// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show Card;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/spacing_tokens.dart';
import 'today_providers.dart';

/// The Today tab: the engine-selected due pages (Far → Near → New) for the
/// active profile, a dumb View over the reactive [todayQueueProvider]. A
/// committed review re-emits the stream and rebuilds the list — there is no
/// manual refresh. The rich page-card row + the one-tap grade are E07-T08; this
/// task renders the queue, the calm empty state, and a calm retry.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final queue = ref.watch(todayQueueProvider);
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
              : _TodayList(cards: cards),
        ),
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.cards});

  final List<Card> cards;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final numerals =
        numberFormatFor(Localizations.localeOf(context).languageCode);
    return ListView.builder(
      padding: EdgeInsetsDirectional.all(space.space3),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        // Minimal placeholder row; E07-T08 replaces it with the page card
        // (track chip + decay indicator + one-tap grade).
        return ListTile(
          key: ValueKey<int>(card.pageId),
          title: Text(numerals.format(card.pageId)),
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
