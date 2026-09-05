// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../a11y/clamped_text_scaling.dart';
import '../state/mihrab_state_layer.dart';
import '../theme/spacing_tokens.dart';

/// The three-destination bottom navigation bar — Today · Muṣḥaf · Progress —
/// in the plain redesign (2026-09-05 owner amendment): a flat bar on the
/// `surfaceContainer` fill with a hairline top edge, an outlined/filled icon
/// pair and a label per tab, the selected tab tinted `primary` **and** carried
/// by the filled icon + heavier label (never colour alone). No ornament, no
/// motion. Settings lives behind the gear on each tab, not in the bar.
///
/// The items are declared in logical order (index 0 = Today); under the
/// app-wide RTL `Directionality` Today lands rightmost as the row geometry —
/// never a manual `.reversed`.
class MihrabNavigationBar extends StatelessWidget {
  /// Creates the bar reflecting [selectedIndex].
  const MihrabNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  /// The selected destination's logical index (0 = Today).
  final int selectedIndex;

  /// Called with the tapped destination's logical index.
  final ValueChanged<int> onDestinationSelected;

  /// The number of destinations the bar renders.
  static const int destinationCount = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final items = <_NavItem>[
      _NavItem(Icons.wb_sunny_outlined, Icons.wb_sunny, l10n.navToday),
      _NavItem(Icons.menu_book_outlined, Icons.menu_book, l10n.navMushaf),
      _NavItem(Icons.grid_view_outlined, Icons.grid_view, l10n.navProgress),
    ];
    // why: the bar is a fixed-height component that cannot reflow; cap the nav
    // labels so the longest stays within the bar at large OS text scale (the
    // one sanctioned clamp site in the shell, E08-T03/T07). Icons + tap targets
    // keep full size, and the label is supplementary to the icon.
    return ClampedTextScaling(
      maxScaleFactor: navLabelTextScaleCeiling,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: space.space8 + space.space3,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _Tab(
                      item: items[i],
                      selected: i == selectedIndex,
                      onTap: () => onDestinationSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final tint = selected ? scheme.primary : scheme.onSurfaceVariant;
    // One merged Semantics node per tab: the localized label, the button role,
    // and the selected state. The visible Text is excluded so the tab reads as
    // one node, not "Today Today" (E08-T02; design-system 09 §7).
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        // Self-contained: the ink needs a Material ancestor even when the bar
        // is hosted outside a Scaffold (tests, the gallery).
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            onTap: onTap,
            containedInkWell: true,
            highlightShape: BoxShape.rectangle,
            overlayColor: MihrabStateLayer.overlayColor(scheme.onSurface),
            child: ExcludeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: space.space1,
                children: [
                  Icon(selected ? item.selectedIcon : item.icon, color: tint),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tint,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
