// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The teacher-sourced marker (07-components §4/§7; PRD R6): a calm shape/glyph
/// **plus** a localized accessible label, shown on a card row / log entry whose
/// latest authoritative review was a teacher (talaqqī) sign-off — so self and
/// teacher inputs are never conflated. It is **never** color alone (the
/// redundant-encoding rule), credits the teacher (never the app), and carries no
/// score/badge/celebration. A self-sourced row shows no marker.
class TeacherSourcedMarker extends StatelessWidget {
  /// Creates the marker.
  const TeacherSourcedMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final color = theme.colorScheme.onSurfaceVariant;
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: space.space1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // A shape (not color alone): the verified/sign-off glyph.
            Icon(Icons.verified_outlined, size: space.space5, color: color),
            SizedBox(width: space.space2),
            Flexible(
              child: Text(
                l10n.stateSignedOff,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
