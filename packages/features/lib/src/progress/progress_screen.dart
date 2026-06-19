// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../shell/section_placeholder.dart';

/// The Progress tab. An inert placeholder for the walking skeleton — the
/// whole-Quran retention heat-map arrives in E15.
class ProgressScreen extends StatelessWidget {
  /// Creates the Progress placeholder.
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => SectionPlaceholder(
        title: AppLocalizations.of(context)!.navProgress,
        identifier: 'screen.progress',
      );
}
