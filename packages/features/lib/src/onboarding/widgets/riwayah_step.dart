// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show kKfgqpcHafsMadaniV2Edition;

import '../../design_system/pickers/settings_picker.dart';
import '../../design_system/theme/spacing_tokens.dart';

/// The riwāyah / muṣḥaf confirmation step (E11-T03): v1 bundles one edition, so
/// this names it explicitly — "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf" (R2), never "the
/// Quran" in the absolute — as a single pre-selected option, and stores only the
/// named edition id. It renders **no** muṣḥaf glyph (the core is not yet
/// verified) and offers no translation/tafsīr. A dumb View composing E10's
/// [SettingsPicker]; it re-typesets nothing and mutates no engine state.
class RiwayahStep extends StatelessWidget {
  /// Creates the step; [selected] is the captured edition id (defaults to the
  /// bundled edition for display), [onSelected] stores the confirmed choice.
  const RiwayahStep({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// The captured edition id, or null before confirmation.
  final String? selected;

  /// Emits the confirmed edition id.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final editionId = kKfgqpcHafsMadaniV2Edition.mushafId;
    return ListView(
      padding: EdgeInsetsDirectional.all(space.space4),
      children: [
        Text(
          l10n.onboardingRiwayahStepTitle,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: space.space2),
        Text(
          l10n.onboardingRiwayahStepBody,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: space.space4),
        SettingsPicker<String>(
          options: [
            SettingsOption(value: editionId, label: l10n.mushafRiwayahLabel),
          ],
          selected: selected ?? editionId,
          onSelected: onSelected,
        ),
      ],
    );
  }
}
