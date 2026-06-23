// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/banners/empty_state.dart';

/// The Today all-done terminal surface (07-components §1; ui-empty-state §2): a
/// single calm closing line in `text.secondary`, composed from the E10 empty-
/// state leaf — informational, never a confetti/streak/badge/exclamation-mark
/// celebration (PRD R3, C6). Nothing here is ever "safe to drop"/"mastered"/
/// "done" — it is the calm close of a finite day, not a score.
class TodayAllDone extends StatelessWidget {
  /// Creates the all-done surface.
  const TodayAllDone({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      model: EmptyStateModel(
        kind: EmptyStateKind.allDone,
        body: l10n.emptyAllDone,
      ),
    );
  }
}
