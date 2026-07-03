// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart'
    show MihrabArchHeader, MihrabNavigationBar, MihrabScaffold;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

/// The persistent chrome around the five bottom-nav tabs, hosted by the router's
/// `ShellRoute` (04 §6). It wires only: it derives the selected tab from the
/// current location and routes a tap with `context.go` — no imperative
/// `Navigator.push`, no business logic, no Quran glyph.
///
/// The nav items are declared in logical order Today · Muṣḥaf · Mutashābihāt ·
/// Progress · Settings; under the app-wide RTL `Directionality` the bar renders
/// Today rightmost as the geometric result — never a manual `.reversed`.
class HomeShell extends StatelessWidget {
  /// Wraps the active tab's [child] in the shell chrome.
  const HomeShell({required this.child, super.key});

  /// The currently-selected tab screen, supplied by the `ShellRoute`.
  final Widget child;

  /// The tab destinations in logical order (index 0 = Today).
  static const List<String> _tabPaths = <String>[
    '/today',
    '/mushaf',
    '/mutashabihat',
    '/progress',
    '/settings',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final header = _headerFor(location, AppLocalizations.of(context));
    // Reuse the design-system scaffold (calm body + a MihrabNavigationBar slot)
    // rather than re-assembling Scaffold + nav here. The four content tabs get a
    // mihrab arch header; the Muṣḥaf reader keeps its own riwāyah chrome and
    // pushed sub-routes carry their own AppBars, so both are left header-less.
    return MihrabScaffold(
      body: header == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MihrabArchHeader(
                  title: header.title,
                  subtitle: header.subtitle,
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: MihrabNavigationBar(
        selectedIndex: _selectedIndex(location),
        onDestinationSelected: (index) => context.go(_tabPaths[index]),
      ),
    );
  }

  /// The arch-header title + subtitle for a top-level content tab, or null for
  /// the reader and pushed sub-routes (which supply their own chrome).
  /// Exact-match, so a sub-path like `/settings/profiles` is left header-less.
  ({String title, String subtitle})? _headerFor(
    String location,
    AppLocalizations l10n,
  ) =>
      switch (location) {
        '/today' => (title: l10n.navToday, subtitle: l10n.headerSubtitleToday),
        '/mutashabihat' => (
            title: l10n.navMutashabihat,
            subtitle: l10n.headerSubtitleMutashabihat,
          ),
        '/progress' => (
            title: l10n.navProgress,
            subtitle: l10n.headerSubtitleProgress,
          ),
        '/settings' => (
            title: l10n.navSettings,
            subtitle: l10n.headerSubtitleSettings,
          ),
        _ => null,
      };

  /// The tab whose path is the longest prefix of [location] (so a sub-path under
  /// a tab keeps that tab selected); defaults to Today.
  int _selectedIndex(String location) {
    var selected = 0;
    var longest = -1;
    for (var index = 0; index < _tabPaths.length; index++) {
      final path = _tabPaths[index];
      final matches = location == path || location.startsWith('$path/');
      if (matches && path.length > longest) {
        selected = index;
        longest = path.length;
      }
    }
    return selected;
  }
}
