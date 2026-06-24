// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The welcoming first-run / empty Progress state (E15-T09): shown when no page
/// is part of the user's hifz yet. Calm and inviting — it explains the map fills
/// as pages are held and revised. **No** guilt, no "you haven't…", no streak,
/// score, or scoreboard (PRD R3; `domain-adab-and-religious-integrity`).
class ProgressEmptyState extends StatelessWidget {
  /// Creates the empty Progress state.
  const ProgressEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.progressEmptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: space.space3),
            Text(
              l10n.progressEmptyBody,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
