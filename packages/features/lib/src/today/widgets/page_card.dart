// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show Card, ReviewGrade, ReviewTrack;
import 'package:flutter/material.dart' hide Card;
import 'package:l10n/l10n.dart';

import '../../design_system/theme/mihrab_colors.dart';
import '../../design_system/theme/spacing_tokens.dart';

/// One Today row: a muṣḥaf page (number in locale numerals), its non-interactive
/// track chip (sabaq / sabqi / manzil — the classical term-set), a calm decay
/// indicator (a distinct glyph + a screen-reader label, never colour alone), and
/// the one-tap grade band. A domain-blind View: it takes [card] + [onGrade] and
/// renders; the grade flows up to the single write path (E07-T05). No streak,
/// score, or celebration; the page is never marked droppable.
class PageCard extends StatelessWidget {
  /// Creates the row for [card].
  const PageCard({required this.card, required this.onGrade, super.key});

  /// The page card to render.
  final Card card;

  /// Called with the chosen grade when the ḥāfiẓ taps the grade band.
  final void Function(ReviewGrade grade) onGrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final numerals =
        numberFormatFor(Localizations.localeOf(context).languageCode);
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: space.space2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(space.space3),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.all(space.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: space.space3,
            children: [
              Row(
                spacing: space.space2,
                children: [
                  _TrackChip(track: card.track),
                  Expanded(
                    child: Text(
                      l10n.pageNumber(numerals.format(card.pageId)),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  _DecayIndicator(isWeak: card.isWeak),
                ],
              ),
              _GradeBand(onGrade: onGrade),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackChip extends StatelessWidget {
  const _TrackChip({required this.track});

  final ReviewTrack track;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.extension<MihrabColors>()!;
    final space = theme.extension<SpacingTokens>()!;
    final label = switch (track) {
      ReviewTrack.newPage || ReviewTrack.unmemorized => l10n.trackNewLabel,
      ReviewTrack.near => l10n.trackNearLabel,
      ReviewTrack.far => l10n.trackFarLabel,
    };
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: space.space2,
        vertical: space.space1,
      ),
      decoration: BoxDecoration(
        color: colors.trackChipSurface,
        borderRadius: BorderRadius.circular(space.space2),
      ),
      child: Text(
        label,
        style:
            theme.textTheme.labelMedium?.copyWith(color: colors.trackChipText),
      ),
    );
  }
}

class _DecayIndicator extends StatelessWidget {
  const _DecayIndicator({required this.isWeak});

  final bool isWeak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.extension<MihrabColors>()!;
    return Semantics(
      label: isWeak ? l10n.decayNeedsRevision : l10n.decaySteady,
      child: Icon(
        // Glyph (not colour alone) carries the state; the weak tint is the
        // calm decay token — never the semantic-warning alarm colour (03 §6;
        // domain-adab: decay is calm loss-prevention, never alarm).
        isWeak ? Icons.trending_down : Icons.trending_flat,
        color: isWeak ? colors.decayCalm : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _GradeBand extends StatelessWidget {
  const _GradeBand({required this.onGrade});

  final void Function(ReviewGrade grade) onGrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final grades = <(ReviewGrade, String)>[
      (ReviewGrade.again, l10n.gradeAgain),
      (ReviewGrade.hard, l10n.gradeHard),
      (ReviewGrade.good, l10n.gradeGood),
      (ReviewGrade.easy, l10n.gradeEasy),
    ];
    return Row(
      spacing: space.space2,
      children: [
        for (final (grade, label) in grades)
          Expanded(
            child: OutlinedButton(
              key: ValueKey<String>('grade.${grade.wireValue}'),
              onPressed: () => onGrade(grade),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
    );
  }
}
