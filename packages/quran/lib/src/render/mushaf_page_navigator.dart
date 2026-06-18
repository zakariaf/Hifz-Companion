// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// The RTL-aware page navigator (engineering 08 §3; eng-rtl-and-bidi-layout): a
/// `PageView` whose **`reverse`** is derived from `Directionality.of(context)`,
/// so page 1→2 advances right-to-left in RTL — while each rendered glyph layer
/// keeps its own `TextDirection.rtl` and the **glyphs are never mirrored,
/// flipped, rotated, or reflected**. The page-turn direction mirrors; the sacred
/// content does not.
///
/// A swipe rebuilds with a **new `pageNumber` → new geometry/font** only (a
/// different page from [pageBuilder]); nothing is re-typeset or reflowed. The
/// page bound is [pageCount] (from the edition, never a literal `604`).
class MushafPageNavigator extends StatefulWidget {
  /// Creates the navigator over `1..pageCount`, starting at [currentPage],
  /// building each page with [pageBuilder] and reporting turns via
  /// [onPageChanged].
  const MushafPageNavigator({
    required this.pageCount,
    required this.currentPage,
    required this.pageBuilder,
    required this.onPageChanged,
    super.key,
  });

  /// The number of pages in the edition (`1..pageCount`).
  final int pageCount;

  /// The 1-based page to open on.
  final int currentPage;

  /// Builds the (verified) page widget for a 1-based page number.
  final Widget Function(int pageNumber) pageBuilder;

  /// Called with the new 1-based page number when the page turns.
  final ValueChanged<int> onPageChanged;

  @override
  State<MushafPageNavigator> createState() => _MushafPageNavigatorState();
}

class _MushafPageNavigatorState extends State<MushafPageNavigator> {
  late final PageController _controller =
      PageController(initialPage: widget.currentPage - 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      // Derived, never hardcoded: the page-turn direction mirrors in RTL.
      reverse: Directionality.of(context) == TextDirection.rtl,
      itemCount: widget.pageCount,
      onPageChanged: (index) => widget.onPageChanged(index + 1),
      itemBuilder: (context, index) => widget.pageBuilder(index + 1),
    );
  }
}
