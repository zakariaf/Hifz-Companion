// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show Card, ReviewTrack;
import 'package:flutter/material.dart' hide Card;
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';
import '../../l10n/term_set.dart';
import '../today_session.dart';
import 'session_section.dart';

/// The populated Today: a single finite, budget-capped `CustomScrollView` that
/// **visibly ends**, grouped into three sliver sections in the fixed recitation
/// order **Far (manzil) → Near (sabqi) → New (sabaq)** (PRD §7.8; 07-components
/// §1). It renders only the controller's pre-built day — it never sorts, caps,
/// re-balances, calls the engine, or reads a wall clock. RTL is the
/// geometry (logical insets only); a single `Semantics` container announces
/// "Revise today" with the three ordered section groups. An empty section
/// renders nothing.
class DailySessionList extends StatelessWidget {
  /// Creates the list over the pre-built [session]; [juzOf] resolves a page's
  /// juz (reference metadata) and [onOpen] opens the recite route.
  const DailySessionList({
    required this.session,
    required this.juzOf,
    required this.onOpen,
    this.region = kDefaultTermSetRegion,
    super.key,
  });

  /// The pre-built, grouped, capped day.
  final TodaySession session;

  /// Resolves the 1-based juz for a page id.
  final int Function(int pageId) juzOf;

  /// Opens the recite route for the tapped page.
  final void Function(int pageId) onOpen;

  /// The active term-set region for the section + chip vocabulary.
  final String region;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;

    // The order is structurally fixed: a const-ordered list the View iterates,
    // so the three sections can never be permuted or made user-reorderable.
    final sections = <(ReviewTrack, List<Card>)>[
      (ReviewTrack.far, session.far),
      (ReviewTrack.near, session.near),
      (ReviewTrack.newPage, session.newSabaq),
    ];

    return Semantics(
      container: true,
      label: l10n.todaySemanticTitle,
      explicitChildNodes: true,
      child: CustomScrollView(
        slivers: <Widget>[
          for (final (track, pages) in sections)
            if (pages.isNotEmpty)
              SessionSection(
                track: track,
                pages: pages,
                juzOf: juzOf,
                onOpen: onOpen,
                region: region,
              ),
          SliverPadding(
            padding: EdgeInsetsDirectional.only(bottom: space.space6),
          ),
        ],
      ),
    );
  }
}
