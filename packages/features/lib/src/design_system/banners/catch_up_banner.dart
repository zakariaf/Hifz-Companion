// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../page_card/page_card.dart';
import '../page_card/page_card_view_data.dart';
import '../theme/spacing_tokens.dart';

/// The user-owned choices a [CatchUpBanner] offers (voice 11 §4) — hard news
/// ends in options the user owns, never a single mandated fix.
enum CatchUpChoice {
  /// Start the engine's re-spread plan.
  startPlan,

  /// Adjust the plan.
  adjust,

  /// Decide later — blameless.
  defer,
}

/// The engine's already-computed re-spread plan — display data only (the spread,
/// its order, and which items are mandatory are computed by E04, never here).
@immutable
class CatchUpPlan {
  /// Creates a plan over [items] (already ordered most-decayed/prayer-critical
  /// first); [missedDays]/[planDays] are carried for reference.
  const CatchUpPlan({
    required this.missedDays,
    required this.planDays,
    required this.items,
  });

  /// The number of days passed without revision (the honest fact).
  final int missedDays;

  /// The number of days the re-spread plan covers.
  final int planDays;

  /// The plan rows, in the order the engine set (FAR/manzil items mandatory —
  /// never elided to shorten the plan).
  final List<PageCardViewData> items;
}

/// The calm missed-day catch-up banner (voice 11 §4; PRD §7.9) — empathy →
/// honest fact → concrete path → the user's choice.
///
/// Domain-blind: it renders a pre-built [CatchUpPlan] (reusing the page card for
/// each row) and the already-localized [empathy]/[factLine]/[pathLine], and emits
/// a [CatchUpChoice] through [onChoice] — it computes no spread, reads no clock,
/// mutates nothing, opens no socket. Calm `surfaceContainer` (Level 0–1), never a
/// red overdue pile; any decay reads as receding green; never greets the gap,
/// never "you're behind", no streak/celebration.
class CatchUpBanner extends StatelessWidget {
  /// Creates the banner from a pre-built plan + localized copy + a choice sink.
  const CatchUpBanner({
    required this.plan,
    required this.empathy,
    required this.factLine,
    required this.pathLine,
    required this.startLabel,
    required this.adjustLabel,
    required this.deferLabel,
    required this.onChoice,
    super.key,
  });

  /// The engine's pre-built re-spread plan.
  final CatchUpPlan plan;

  /// The already-localized empathy line.
  final String empathy;

  /// The already-localized honest-fact line ("N days passed without revision").
  final String factLine;

  /// The already-localized path line ("a plan over M days that completes...").
  final String pathLine;

  /// The already-localized "start plan" choice label.
  final String startLabel;

  /// The already-localized "adjust" choice label.
  final String adjustLabel;

  /// The already-localized "defer" choice label.
  final String deferLabel;

  /// Emits the user's choice; the single output of the banner.
  final ValueChanged<CatchUpChoice> onChoice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final minTouch = Size(space.space8, space.space8);

    return Card(
      elevation: 0,
      color: scheme.surfaceContainer,
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empathy → fact → path read as one calm announcement.
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(empathy, style: text.bodyLarge),
                  SizedBox(height: space.space2),
                  Text(factLine, style: text.bodyMedium),
                  SizedBox(height: space.space1),
                  Text(
                    pathLine,
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(height: space.space3),
            for (final item in plan.items)
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: space.space2),
                child: MihrabPageCard(data: item, onOpen: () {}),
              ),
            SizedBox(height: space.space3),
            // The choices — user-owned, never a single mandate.
            Wrap(
              spacing: space.space2,
              runSpacing: space.space2,
              children: [
                FilledButton(
                  onPressed: () => onChoice(CatchUpChoice.startPlan),
                  child: Text(startLabel),
                ),
                OutlinedButton(
                  onPressed: () => onChoice(CatchUpChoice.adjust),
                  style: OutlinedButton.styleFrom(minimumSize: minTouch),
                  child: Text(adjustLabel),
                ),
                TextButton(
                  onPressed: () => onChoice(CatchUpChoice.defer),
                  style: TextButton.styleFrom(minimumSize: minTouch),
                  child: Text(deferLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
