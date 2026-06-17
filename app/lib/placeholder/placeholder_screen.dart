// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// A temporary launch screen that proves the shell wires end to end and that
/// its one visible string is resolved through [AppLocalizations] — never a
/// hardcoded literal. Replaced by the real Today screen and the bottom-nav
/// shell in E07.
class PlaceholderScreen extends StatelessWidget {
  /// Creates the placeholder screen.
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Text(l10n.appTitle),
      ),
    );
  }
}
