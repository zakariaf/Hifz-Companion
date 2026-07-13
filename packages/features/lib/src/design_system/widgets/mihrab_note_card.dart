// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';

/// The tone of a [MihrabNoteCard]'s tile keyline (design-system 03 §2/§6).
enum MihrabNoteTone {
  /// A reverent green/teal keyline — framing, reassurance, honest disclosure.
  calm,

  /// A warm terracotta keyline — a plain responsibility/tradeoff statement
  /// (the one bespoke warm accent), never an alarm state.
  warm,
}

/// A calm mihrab "note" panel: a softly-tinted surface with a colored keyline
/// along the logical **start** edge (the tile edge that mirrors for RTL) and an
/// optional leading [icon]. It carries an honest framing/disclosure line in the
/// ḥāfiẓ's frame — the science intro, the no-cloud backup tradeoff, the reminder
/// privacy line.
///
/// Purely display chrome (design-system 02 §5; 03 §6): it formats no number,
/// reads no provider, and never signals a warning/alarm — the [warm] tone is the
/// one bespoke terracotta accent, paired with text, never colour alone.
class MihrabNoteCard extends StatelessWidget {
  /// Creates a note panel showing the already-localized [text].
  const MihrabNoteCard({
    required this.text,
    this.icon,
    this.tone = MihrabNoteTone.calm,
    super.key,
  });

  /// The already-localized disclosure/framing line.
  final String text;

  /// An optional leading glyph (e.g. a privacy shield), at the logical start.
  final IconData? icon;

  /// The keyline tone (calm green/teal by default; warm terracotta).
  final MihrabNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final mihrab = theme.extension<MihrabColors>()!;

    final edge =
        tone == MihrabNoteTone.warm ? mihrab.semanticWarning : scheme.primary;
    final tint = edge.withValues(alpha: 0.1);
    final iconData = icon;

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(space.space5)),
      child: ColoredBox(
        color: tint,
        child: Stack(
          children: [
            // The content sizes the panel; its start inset clears the keyline.
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                space.space5,
                space.space4,
                space.space4,
                space.space4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (iconData != null) ...[
                    Icon(
                      iconData,
                      color: edge,
                      size: theme.textTheme.bodyLarge?.fontSize,
                    ),
                    SizedBox(width: space.space2),
                  ],
                  Expanded(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            // The tile keyline along the logical start (right under RTL).
            PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              width: space.space1,
              child: ColoredBox(color: edge),
            ),
          ],
        ),
      ),
    );
  }
}
