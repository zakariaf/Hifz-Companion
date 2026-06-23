// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show Card, ReviewTrack;
import 'package:flutter/material.dart' hide Card;
import 'package:l10n/l10n.dart';

import '../../design_system/page_card/page_card.dart';
import '../../design_system/page_card/page_card_view_data.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../../l10n/term_set.dart';

/// One section of the daily-session list — a quiet localized term-set header in
/// `type.title` and its E10 page-card rows (07-components §1). The feature layer
/// maps each `Card` of this section's [track] into the domain-blind
/// [PageCardViewData]; the row is one ≥48dp tap into the recite route, with no
/// Quran glyph and no D/S/R on it. Returns a sliver group so the parent
/// `CustomScrollView` keeps the three sections in their fixed order. An empty
/// section is never rendered (the parent omits it) — there is no orphan header.
class SessionSection extends StatelessWidget {
  /// Creates the section for [track] over its already-ordered [pages].
  const SessionSection({
    required this.track,
    required this.pages,
    required this.juzOf,
    required this.onOpen,
    this.region = kDefaultTermSetRegion,
    super.key,
  });

  /// The phase this section renders (drives the header term + the chip family).
  final ReviewTrack track;

  /// The section's pages, in the engine's recitation order (never re-sorted).
  final List<Card> pages;

  /// Resolves the 1-based juz for a page id (reference metadata, injected).
  final int Function(int pageId) juzOf;

  /// Opens the recite route for the tapped page.
  final void Function(int pageId) onOpen;

  /// The active term-set region for the header + chip vocabulary.
  final String region;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final header = switch (track) {
      ReviewTrack.far => l10n.sectionFarManzil(region),
      ReviewTrack.near => l10n.sectionNearSabqi(region),
      ReviewTrack.newPage => l10n.sectionNewSabaq(region),
      ReviewTrack.unmemorized => l10n.sectionNewSabaq(region),
    };

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsetsDirectional.only(
            top: space.space6,
            start: space.space4,
            end: space.space4,
            bottom: space.space2,
          ),
          sliver: SliverToBoxAdapter(
            child: Semantics(
              header: true,
              child: Text(header, style: theme.textTheme.titleMedium),
            ),
          ),
        ),
        SliverList.separated(
          itemCount: pages.length,
          separatorBuilder: (_, __) => SizedBox(height: space.space2),
          itemBuilder: (context, index) {
            final card = pages[index];
            return Padding(
              key: ValueKey<int>(card.pageId),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: space.space4,
              ),
              child: MihrabPageCard(
                data: _viewData(card, l10n),
                onOpen: () => onOpen(card.pageId),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Maps a domain [Card] of this section into the domain-blind view data the
  /// E10 leaf takes. Decay is read from persisted card flags only — never a
  /// re-computed `R` in the View (PRD §7.12: no D/S/R on a row, never a number).
  PageCardViewData _viewData(Card card, AppLocalizations l10n) {
    final family = switch (track) {
      ReviewTrack.far => TrackFamily.far,
      ReviewTrack.near => TrackFamily.near,
      ReviewTrack.newPage => TrackFamily.neww,
      ReviewTrack.unmemorized => TrackFamily.neww,
    };
    final decay = card.isWeak
        ? DecayLevel.needsRevision
        : (card.lapses > 0 ? DecayLevel.holding : DecayLevel.solid);
    final decayLabel = switch (decay) {
      DecayLevel.needsRevision => l10n.decayNeedsRevision,
      DecayLevel.holding => l10n.decayHolding,
      DecayLevel.solid => l10n.decaySteady,
    };
    final state = card.hasManualLock
        ? CardState.locked
        : (card.isWeak ? CardState.weak : CardState.dueToday);
    return PageCardViewData(
      page: card.pageId,
      juz: juzOf(card.pageId),
      track: family,
      trackLabel: trackLabel(l10n, track, region),
      decay: decay,
      decayLabel: decayLabel,
      state: state,
    );
  }
}
