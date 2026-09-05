// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// One Settings group (plain redesign, 2026-09-05): a quiet already-localized
/// [title] above a white card on a hairline that holds the group's [children]
/// (pickers, navigation rows, or a placeholder line). No ornament; the title is
/// the only heading node the screen reader announces for the group.
class SettingsSection extends StatelessWidget {
  /// Creates the group for [title] over [children].
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  /// The pre-localized group header.
  final String title;

  /// The group's rows (pickers, navigation rows, or a placeholder line).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: space.space4,
        end: space.space4,
        top: space.space5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: space.space1,
              bottom: space.space2,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          DecoratedBox(
            decoration: ShapeDecoration(
              color: scheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(space.space4),
                side: BorderSide(color: scheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: space.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
