// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// The large-title header every top-level tab draws for itself in the plain
/// redesign (2026-09-05): an optional quiet caption row with trailing actions
/// (the Settings gear), then the already-localized [title] in `displaySmall`.
/// No band, no ornament — the title is the header. Announced as one heading.
class PlainScreenHeader extends StatelessWidget {
  /// Creates the header for [title], with an optional [caption] line and
  /// trailing [actions] (icon buttons) on the caption row.
  const PlainScreenHeader({
    required this.title,
    this.caption,
    this.actions = const <Widget>[],
    super.key,
  });

  /// The screen title (an already-localized tab name).
  final String title;

  /// A quiet already-localized caption above the title (a date, a count).
  final String? caption;

  /// Trailing actions on the caption row — kept to icon buttons.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final captionText = caption;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: space.space5,
        end: space.space3,
        top: space.space2,
        bottom: space.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (captionText != null || actions.isNotEmpty)
            Row(
              children: <Widget>[
                Expanded(
                  child: captionText == null
                      ? const SizedBox.shrink()
                      : Text(
                          captionText,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                ),
                ...actions,
              ],
            ),
          Semantics(
            header: true,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: space.space2),
              child: Text(title, style: theme.textTheme.displaySmall),
            ),
          ),
        ],
      ),
    );
  }
}
