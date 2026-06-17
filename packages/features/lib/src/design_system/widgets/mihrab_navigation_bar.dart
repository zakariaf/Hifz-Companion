// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

/// The five-tab bottom navigation skeleton — Today · Muṣḥaf · Mutashābihāt ·
/// Progress · Settings, declared in that **logical** order (design-system 05
/// §3; 02 §1).
///
/// Under RTL (fa/ckb/ar) the geometry flips so Today (home) renders at the
/// trailing/right edge — a `Directionality` consequence, never a hand-reversed
/// list. A dumb View: selection is the [selectedIndex] + [onDestinationSelected]
/// index callback only — no `go_router`, `Navigator`, or store (that seam is
/// E07). Labels resolve through `l10n.*`; the surface is the M3 default by role.
class MihrabNavigationBar extends StatelessWidget {
  /// Creates the nav skeleton reflecting [selectedIndex].
  const MihrabNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  /// The selected destination's logical index (0 = Today).
  final int selectedIndex;

  /// Called with the tapped destination's logical index. Wired to no route.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.wb_sunny_outlined),
          label: l10n.navToday,
        ),
        NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          label: l10n.navMushaf,
        ),
        NavigationDestination(
          icon: const Icon(Icons.compare_arrows_outlined),
          label: l10n.navMutashabihat,
        ),
        NavigationDestination(
          icon: const Icon(Icons.grid_view_outlined),
          label: l10n.navProgress,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          label: l10n.navSettings,
        ),
      ],
    );
  }
}
