// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../shell/section_placeholder.dart';

/// The Muṣḥaf tab. An inert placeholder for the walking skeleton — it renders no
/// Quran glyph. The immutable page renderer arrives in E13; the redirect guard
/// keeps the glyph-rendering reader route out of reach until the core pack is
/// verified (PRD R1).
class MushafScreen extends StatelessWidget {
  /// Creates the Muṣḥaf placeholder.
  const MushafScreen({super.key});

  @override
  Widget build(BuildContext context) => SectionPlaceholder(
        title: AppLocalizations.of(context).navMushaf,
        identifier: 'screen.mushaf',
      );
}
