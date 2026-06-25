// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// A calm Settings group: a quiet localized [title] header over its [children]
/// rows, on the `space.*` grid with logical insets so it mirrors for fa/ckb/ar
/// unchanged (design-system 05 §section spacing; 07 §6 grouping).
///
/// Domain-blind: it shows only the pre-localized [title] and whatever rows the
/// caller supplies — it formats no number, reads no provider, and persists
/// nothing. The E16 picker/profile tasks fill each section's [children]; the
/// scaffold (E16-T01) seeds them with a single calm "in preparation" line.
class SettingsSection extends StatelessWidget {
  /// Creates a settings group titled [title] containing [children].
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
    final space = theme.extension<SpacingTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Quiet section gap above the header (start/end logical insets).
          padding: EdgeInsetsDirectional.only(
            start: space.space4,
            end: space.space4,
            top: space.space6,
            bottom: space.space2,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        ...children,
      ],
    );
  }
}
