// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/banners/catch_up_banner.dart';
import '../../l10n/term_set.dart';
import '../today_session.dart';
import 'page_card_data.dart';

/// The Today catch-up state (PRD §7.9, §12.2): after a gap, the calm re-spread
/// banner — **empathy → honest fact → concrete M-day plan → the user's choice** —
/// instead of a red overdue pile. It maps the controller's pre-built
/// [TodayCatchUp] (the engine's re-spread, most-decayed first) onto the E10
/// `CatchUpBanner` leaf and the localized copy; it computes no spread, re-sorts
/// nothing, reads no clock, and renders every row the engine put in the plan
/// (FAR/manzil never elided). The three real choices are the View's to wire.
class TodayCatchUpBanner extends StatelessWidget {
  /// Creates the banner over the pre-built [catchUp] plan.
  const TodayCatchUpBanner({
    required this.catchUp,
    required this.juzOf,
    required this.onStart,
    required this.onAdjust,
    required this.onDefer,
    this.region = kDefaultTermSetRegion,
    super.key,
  });

  /// The engine's pre-built catch-up plan (missed days, horizon, ordered rows).
  final TodayCatchUp catchUp;

  /// Resolves the 1-based juz for a page id (reference metadata).
  final int Function(int pageId) juzOf;

  /// Accept the plan and resume into the ordinary day (a calm confirm).
  final VoidCallback onStart;

  /// Adjust the plan's length/budget (deep-link to E16 settings).
  final VoidCallback onAdjust;

  /// Defer — dismiss to the ordinary day, blameless.
  final VoidCallback onDefer;

  /// The active term-set region for the row chip vocabulary.
  final String region;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = CatchUpPlan(
      missedDays: catchUp.missedDays,
      planDays: catchUp.planDays,
      items: [
        for (final card in catchUp.items)
          todayPageCardData(
            card: card,
            track: card.track,
            juz: juzOf(card.pageId),
            l10n: l10n,
            region: region,
          ),
      ],
    );
    return SingleChildScrollView(
      child: CatchUpBanner(
        plan: plan,
        empathy: l10n.catchUpEmpathy,
        factLine: l10n.catchUpMissedDays(catchUp.missedDays),
        pathLine: l10n.catchUpPlanLine(catchUp.planDays),
        startLabel: l10n.catchUpStartPlan,
        adjustLabel: l10n.catchUpAdjust,
        deferLabel: l10n.catchUpDefer,
        onChoice: (choice) => switch (choice) {
          CatchUpChoice.startPlan => onStart(),
          CatchUpChoice.adjust => onAdjust(),
          CatchUpChoice.defer => onDefer(),
        },
      ),
    );
  }
}
