// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/spacing_tokens.dart';
import 'widgets/settings_section.dart';

/// The Settings tab: a calm, grouped preferences surface (PRD §15) on the
/// one-handed template (design-system 05 §5) — content scrolls in the upper and
/// middle area; rare/destructive actions belong in the hard-to-reach top corner
/// (none exist yet). Grouped into Display · Cycle · Profiles · Backup · About;
/// each section's controls arrive in the E16 tasks that follow this scaffold.
///
/// A **dumb** View (eng-add-feature-module): it draws no Quran glyph, shows no
/// number or score, reads no wall clock, and opens no socket. The `screen.settings`
/// id is kept from the E07 placeholder so the shell journey still addresses it.
class SettingsScreen extends StatelessWidget {
  /// Creates the Settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;

    return Semantics(
      key: const ValueKey<String>('screen.settings'),
      identifier: 'screen.settings',
      container: true,
      label: l10n.navSettings,
      explicitChildNodes: true,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.only(bottom: space.space7),
          children: [
            SettingsSection(
              title: l10n.settingsSectionDisplay,
              children: const [_SectionPlaceholderLine()],
            ),
            SettingsSection(
              title: l10n.settingsSectionCycle,
              children: const [_SectionPlaceholderLine()],
            ),
            SettingsSection(
              title: l10n.settingsSectionProfiles,
              children: const [_SectionPlaceholderLine()],
            ),
            SettingsSection(
              title: l10n.settingsSectionBackup,
              children: const [_SectionPlaceholderLine()],
            ),
            SettingsSection(
              title: l10n.settingsSectionAbout,
              children: const [_SectionPlaceholderLine()],
            ),
          ],
        ),
      ),
    );
  }
}

/// The calm "this section is being prepared" line shown under a section whose
/// real controls land in a later E16 task. Reverent and plain — no number, no
/// claim, no guilt/fear (design-system 01 §1; PRD R3).
class _SectionPlaceholderLine extends StatelessWidget {
  const _SectionPlaceholderLine();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: space.space4,
        end: space.space4,
        bottom: space.space2,
      ),
      child: Text(
        AppLocalizations.of(context).sectionInPreparation,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
