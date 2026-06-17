// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import 'placeholder_providers.dart';

/// A placeholder feature View: a dumb [ConsumerWidget] that watches its 1:1
/// ViewModel and resolves its one visible string through [AppLocalizations] —
/// never a hardcoded literal. The real feature screens are authored in the
/// feature epics.
class PlaceholderScreen extends ConsumerWidget {
  /// Creates the placeholder screen.
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Establish the View→ViewModel dependency (1:1). The placeholder does not
    // yet branch on the state; E07 binds real reactive state here.
    ref.watch(placeholderViewModelProvider);
    return Scaffold(
      body: Center(child: Text(l10n.appTitle)),
    );
  }
}
