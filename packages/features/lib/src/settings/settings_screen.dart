// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/spacing_tokens.dart';
import '../design_system/widgets/mihrab_card.dart';
import 'widgets/backup_settings_section.dart';
import 'widgets/cycle_settings_section.dart';
import 'widgets/display_settings_section.dart';
import 'widgets/reminders_settings_section.dart';
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
            const DisplaySettingsSection(),
            const CycleSettingsSection(),
            const RemindersSettingsSection(),
            SettingsSection(
              title: l10n.settingsSectionProfiles,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.symmetric(horizontal: space.space4),
                  child: MihrabCard(
                    title: l10n.profilesManageSubtitle,
                    leading: Icons.people_outline,
                    // Literal path (kProfilesPath lives in the profiles feature,
                    // which Settings must not import sideways).
                    onTap: () => context.go('/settings/profiles'),
                  ),
                ),
              ],
            ),
            const BackupSettingsSection(),
            SettingsSection(
              title: l10n.settingsSectionAbout,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.symmetric(horizontal: space.space4),
                  child: MihrabCard(
                    title: l10n.scienceTitle,
                    leading: Icons.science_outlined,
                    // Literal path (kSciencePath lives in the science feature,
                    // which Settings must not import sideways).
                    onTap: () => context.go('/settings/science'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
