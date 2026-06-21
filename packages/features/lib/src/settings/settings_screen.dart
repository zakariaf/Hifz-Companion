// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../shell/section_placeholder.dart';

/// The Settings tab. An inert placeholder for the walking skeleton — the
/// settings, profiles, and teacher surfaces arrive in E16.
class SettingsScreen extends StatelessWidget {
  /// Creates the Settings placeholder.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => SectionPlaceholder(
        title: AppLocalizations.of(context).navSettings,
        identifier: 'screen.settings',
      );
}
