// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart'
    show MihrabNavigationBar, MihrabScaffold;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The persistent chrome around the three bottom-nav tabs, hosted by the
/// router's `ShellRoute` (04 §6). It wires only: it derives the selected tab
/// from the current location and routes a tap with `context.go` — no imperative
/// `Navigator.push`, no business logic, no Quran glyph, no header (each tab
/// draws its own large title).
///
/// The nav items are declared in logical order Today · Muṣḥaf · Progress; under
/// the app-wide RTL `Directionality` the bar renders Today rightmost as the
/// geometric result — never a manual `.reversed`.
class HomeShell extends StatelessWidget {
  /// Wraps the active tab's [child] in the shell chrome.
  const HomeShell({required this.child, super.key});

  /// The currently-selected tab screen, supplied by the `ShellRoute`.
  final Widget child;

  /// The tab destinations in logical order (index 0 = Today).
  static const List<String> _tabPaths = <String>[
    '/today',
    '/mushaf',
    '/progress',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return MihrabScaffold(
      body: child,
      bottomNavigationBar: MihrabNavigationBar(
        selectedIndex: _selectedIndex(location),
        onDestinationSelected: (index) => context.go(_tabPaths[index]),
      ),
    );
  }

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
