// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// The persistent chrome around the five bottom-nav tabs (Today · Muṣḥaf ·
/// Mutashābihāt · Progress · Settings), hosted by the router's `ShellRoute`.
///
/// Minimal pass-through for E07-T03 (the route table and redirect guard are
/// tested against it); E07-T04 fills in the RTL `MihrabNavigationBar` and the
/// branch switching. It wires only — it computes nothing and renders no Quran
/// text.
class HomeShell extends StatelessWidget {
  /// Wraps the active tab's [child] in the shell chrome.
  const HomeShell({required this.child, super.key});

  /// The currently-selected tab screen, supplied by the `ShellRoute`.
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(body: child);
}
