// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The honest budget-feedback line (PRD §12.2, §7.9): one calm informational
/// line shown when the chosen scope can't fit the daily time budget, offering
/// three autonomy-supportive options — raise budget / lengthen cycle / pause new
/// sabaq. It is **information, not an alarm**: a flat surface, `text.secondary`
/// copy, no red/error fill, no alarm icon, no mandate word. FAR/manzil is never
/// dropped — this line is shown **with** the full day still present, never
/// instead of it. The choices navigate (the View wires them to settings); this
/// leaf mutates nothing.
class BudgetFeedbackLine extends StatelessWidget {
  /// Creates the line with its three navigation callbacks.
  const BudgetFeedbackLine({
    required this.onRaiseBudget,
    required this.onLengthenCycle,
    required this.onPauseNewSabaq,
    super.key,
  });

  /// Navigate to the time-budget setting (E16).
  final VoidCallback onRaiseBudget;

  /// Navigate to the cycle-preset setting (E16) — a wider cycle is less daily
  /// work for the same lasting result (CLAIMS C-008).
  final VoidCallback onLengthenCycle;

  /// Navigate to the new-lines/sabaq setting (E16) to defer new memorization.
  final VoidCallback onPauseNewSabaq;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final secondary = theme.colorScheme.onSurfaceVariant;
    final buttonStyle = TextButton.styleFrom(
      minimumSize: Size(0, space.space8),
      alignment: AlignmentDirectional.centerStart,
    );

    return Semantics(
      container: true,
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.budgetOverflowLine,
              style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
            ),
            SizedBox(height: space.space2),
            TextButton(
              key: const ValueKey<String>('budget.raise'),
              style: buttonStyle,
              onPressed: onRaiseBudget,
              child: Text(l10n.budgetRaiseBudget),
            ),
            TextButton(
              key: const ValueKey<String>('budget.lengthen'),
              style: buttonStyle,
              onPressed: onLengthenCycle,
              child: Text(l10n.budgetLengthenCycle),
            ),
            TextButton(
              key: const ValueKey<String>('budget.pause'),
              style: buttonStyle,
              onPressed: onPauseNewSabaq,
              child: Text(l10n.budgetPauseNewSabaq),
            ),
          ],
        ),
      ),
    );
  }
}
