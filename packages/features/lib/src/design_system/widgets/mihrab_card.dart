// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// A calm, flat list row (design-system 02 §5; 05 §1/§3) — a dumb View taking
/// only display data the caller has already localized and numeral-formatted.
///
/// It formats no number, date, or page of its own (that is E10's page card).
/// Leading affordance at `start`, an optional trailing chevron at `end` that
/// auto-mirrors in RTL; flat `surfaceContainerLow` with no `surfaceTint`; when
/// [onTap] is set the whole row is one ≥48dp-tall hit target. No badge, streak,
/// or celebratory surface.
class MihrabCard extends StatelessWidget {
  /// Creates a card showing [title] (and optional [subtitle]/[leading]).
  const MihrabCard({
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    super.key,
  });

  /// The primary line — pre-localized display text supplied by the caller.
  final String title;

  /// An optional secondary line — pre-localized display text.
  final String? subtitle;

  /// An optional leading affordance icon, placed at the logical `start`.
  final IconData? leading;

  /// If non-null, the whole row becomes one tappable ≥48dp hit target.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final leadingIcon = leading;
    final subtitleText = subtitle;

    final row = Padding(
      padding: EdgeInsetsDirectional.all(space.space4),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, color: scheme.onSurfaceVariant),
            SizedBox(width: space.space4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium),
                if (subtitleText != null) ...[
                  SizedBox(height: space.space1),
                  Text(
                    subtitleText,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios, // auto-mirrors at the logical end in RTL
              size: space.space4,
              color: scheme.onSurfaceVariant,
            ),
        ],
      ),
    );

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent, // no tint veil (02 §3)
      child: onTap == null
          ? row
          : InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: space.space8),
                child: row,
              ),
            ),
    );
  }
}
