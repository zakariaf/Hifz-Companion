// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The calm group-position strip ("branch i of n", E14-T08) — informational
/// only, in the locale numeral set, bidi-isolated. Never a score, streak, or
/// progress-bar-to-a-reward; it simply tells the ḥāfiẓ where they are in the
/// contrasting group.
class DrillProgressStrip extends StatelessWidget {
  /// Creates the strip for the 1-based [position] within [total] members.
  const DrillProgressStrip({
    required this.position,
    required this.total,
    super.key,
  });

  /// The 1-based index of the active branch.
  final int position;

  /// The number of members in the group.
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);
    // A calm centered glazed-tile chip marking the position in the group; not a
    // progress-bar-to-a-reward, just where the ḥāfiẓ is.
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        vertical: space.space3,
        horizontal: space.space4,
      ),
      child: Center(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: scheme.primaryContainer,
            shape: const StadiumBorder(),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: space.space4,
              vertical: space.space2,
            ),
            child: Text(
              l10n.mutashabihatDrillProgress(
                isolateLtr(localeDigits(position, locale)),
                isolateLtr(localeDigits(total, locale)),
              ),
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ),
        ),
      ),
    );
  }
}
