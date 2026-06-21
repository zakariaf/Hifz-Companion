// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../theme/spacing_tokens.dart';

/// The on-device teacher (talaqqī) sign-off toggle (design-system 07 §7) — a
/// labelled `Switch.adaptive` ("Teacher present"), **off by default**, with
/// autonomy-supportive copy ("for your teacher to confirm").
///
/// Servant-to-the-teacher, never commanding. Domain-blind: it emits only
/// [onChanged] — it writes no `review_log`, sets no `source`/confidence, draws no
/// badge, and switches no profile (all E12 / domain-grading-pipeline).
class TeacherSignoffToggle extends StatelessWidget {
  /// Creates the toggle; [teacherPresent] is the current value (default off).
  const TeacherSignoffToggle({
    required this.teacherPresent,
    required this.onChanged,
    super.key,
  });

  /// Whether a teacher is present (the canonical default is false).
  final bool teacherPresent;

  /// Emits the new value; the single output of the toggle.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    return MergeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: space.space8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.teacherSignoffLabel, style: text.titleMedium),
                  SizedBox(height: space.space1),
                  Text(
                    l10n.teacherSignoffSupporting,
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(width: space.space3),
            // The Switch is non-directional and never mirrored.
            Switch.adaptive(value: teacherPresent, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
