// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

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
    final text = Theme.of(context).textTheme;

    // A `SwitchListTile` (not a custom Row + `MergeSemantics`) so the WHOLE row
    // is one ≥48dp tap target with correct merged semantics — a screen-reader
    // double-tap toggles it (the Switch is non-directional, never mirrored).
    return SwitchListTile.adaptive(
      value: teacherPresent,
      onChanged: onChanged,
      title: Text(l10n.teacherSignoffLabel, style: text.titleMedium),
      subtitle: Text(
        l10n.teacherSignoffSupporting,
        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
