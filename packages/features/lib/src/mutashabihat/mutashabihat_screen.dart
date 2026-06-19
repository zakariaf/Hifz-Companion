// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../shell/section_placeholder.dart';

/// The Mutashābihāt (similar-verses) tab. An inert placeholder for the walking
/// skeleton — the discrimination-drill trainer arrives in E14.
class MutashabihatScreen extends StatelessWidget {
  /// Creates the Mutashābihāt placeholder.
  const MutashabihatScreen({super.key});

  @override
  Widget build(BuildContext context) => SectionPlaceholder(
        title: AppLocalizations.of(context)!.navMutashabihat,
        identifier: 'screen.mutashabihat',
      );
}
