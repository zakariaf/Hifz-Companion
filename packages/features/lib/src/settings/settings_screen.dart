// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../design_system/theme/motion_tokens.dart';
import '../design_system/theme/reduced_motion.dart';
import '../design_system/theme/spacing_tokens.dart';
import '../design_system/widgets/mihrab_card.dart';
import 'widgets/backup_settings_section.dart';
import 'widgets/cycle_settings_section.dart';
import 'widgets/display_settings_section.dart';
import 'widgets/reminders_settings_section.dart';
import 'widgets/settings_section.dart';

/// Which preferences group to reveal when Settings opens — a deep-link target so
/// a caller (e.g. Today's budget-feedback choices, which point the ḥāfiẓ at the
/// control that actually changes their load) lands on the right section instead
/// of the top of the list. Display-only: it scrolls, it never mutates a setting.
enum SettingsFocus {
  /// The Cycle group — named cycle, daily budget, and new-lesson cadence.
  cycle;

  /// Maps the router's `?focus=` query value; an unknown/absent value → null.
  static SettingsFocus? fromQuery(String? value) =>
      value == 'cycle' ? SettingsFocus.cycle : null;
}

/// The Settings tab: a calm, grouped preferences surface (PRD §15) on the
/// one-handed template (design-system 05 §5) — content scrolls in the upper and
/// middle area; rare/destructive actions belong in the hard-to-reach top corner
/// (none exist yet). Grouped into Display · Cycle · Profiles · Backup · About;
/// each section's controls arrive in the E16 tasks that follow this scaffold.
///
/// A **dumb** View (eng-add-feature-module): it draws no Quran glyph, shows no
/// number or score, reads no wall clock, and opens no socket. The `screen.settings`
/// id is kept from the E07 placeholder so the shell journey still addresses it.
/// An optional [focus] scrolls a section into view on open (a deep-link target).
class SettingsScreen extends StatefulWidget {
  /// Creates the Settings screen, optionally scrolled to a [focus] section.
  const SettingsScreen({this.focus, super.key});

  /// The section to reveal on open (a deep-link target), or null for the top.
  final SettingsFocus? focus;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Anchors the Cycle section so a [SettingsFocus] deep-link can reveal it.
  final GlobalKey _cycleSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.focus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealFocus());
    }
  }

  /// Scrolls the focused section to the top of the viewport once it is laid out.
  /// A calm medium glide, collapsed to an instant cut under the OS Reduce Motion
  /// flag (the new scroll position carries the meaning, not the animation).
  void _revealFocus() {
    final target = switch (widget.focus) {
      SettingsFocus.cycle => _cycleSectionKey.currentContext,
      null => null,
    };
    if (target == null || !mounted) return;
    final motion = Theme.of(context).extension<MotionTokens>()!;
    Scrollable.ensureVisible(
      target,
      duration: motionReduced(context) ? Duration.zero : motion.durationMedium,
      curve: motion.curveStandard,
    );
  }

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
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.navSettings)),
        body: SafeArea(
          // A SingleChildScrollView (not a lazy ListView) builds every section
          // eagerly, so a `focus` deep-link can reliably scroll a section below the
          // fold (e.g. Cycle, which sits under the tall Display group) into view —
          // a lazy list would leave that section unbuilt and the scroll a no-op.
          // The bounded ~6-section form pays no real cost for eager layout.
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(bottom: space.space7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DisplaySettingsSection(),
                CycleSettingsSection(key: _cycleSectionKey),
                const RemindersSettingsSection(),
                SettingsSection(
                  title: l10n.settingsSectionProfiles,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: space.space4,
                      ),
                      child: MihrabCard(
                        title: l10n.profilesManageSubtitle,
                        leading: Icons.people_outline,
                        // Literal path (kProfilesPath lives in the profiles
                        // feature, which Settings must not import sideways).
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
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: space.space4,
                      ),
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
        ),
      ),
    );
  }
}
