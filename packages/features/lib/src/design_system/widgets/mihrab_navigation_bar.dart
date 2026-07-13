// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../a11y/clamped_text_scaling.dart';
import '../theme/mihrab_colors.dart';
import '../theme/motion_tokens.dart';
import '../theme/reduced_motion.dart';
import '../theme/spacing_tokens.dart';

/// The five-tab bottom navigation — Today · Muṣḥaf · Mutashābihāt · Progress ·
/// Settings, declared in that **logical** order (design-system 05 §3; 02 §1),
/// drawn as a mosque **arcade**: five arches on a limestone bar. The active tab
/// sits under a lit arch — its silhouette filled with the glazed-teal primary
/// and lit by a tiny gold hanging lamp — while the other four rest as quiet arch
/// outlines. The lit arch glides to the tapped tab in one calm motion. Every tab
/// keeps its label (a11y — colour is never the sole cue: the active tab is
/// marked by the filled arch, the filled icon, the teal tint, and the heavier
/// label together).
///
/// RTL by construction (fa/ckb/ar): the tabs are a logical-order `Row`, so under
/// `Directionality.rtl` Today renders at the trailing/right edge, and the lit
/// arch is placed from the **visual** slot so it tracks the same tab. A dumb
/// View: selection is the [selectedIndex] + [onDestinationSelected] index
/// callback only — no `go_router`, `Navigator`, or store (that seam is E07).
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
    final l10n = AppLocalizations.of(context);
    final items = <_NavItem>[
      _NavItem(Icons.wb_sunny_outlined, Icons.wb_sunny, l10n.navToday),
      _NavItem(Icons.menu_book_outlined, Icons.menu_book, l10n.navMushaf),
      _NavItem(
        Icons.compare_arrows_outlined,
        Icons.compare_arrows,
        l10n.navMutashabihat,
      ),
      _NavItem(Icons.grid_view_outlined, Icons.grid_view, l10n.navProgress),
      _NavItem(Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];
    // why: the arcade is a fixed-height (62dp) component that cannot reflow; cap
    // the five nav labels so the longest (ckb mutashābihāt) stays within the bar
    // at large OS text scale instead of overflowing it (E08-T03/T07; the one
    // sanctioned clamp site in the shell). Icons + tap targets keep full size,
    // and the label is supplementary to the icon. A no-op at normal scale.
    return ClampedTextScaling(
      maxScaleFactor: navLabelTextScaleCeiling,
      child: _Arcade(
        items: items,
        selectedIndex: selectedIndex,
        onSelected: onDestinationSelected,
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

// Component geometry (not design tokens): the bar-body height and the arch
// silhouette that frames each tab. Tuned so the icon sits inside the arch, the
// label rests on the limestone below it, and the tap row clears the 48dp floor
// (05 §4).
const double _barHeight = 62;
// The pointed arch springs from _archBaseY, rises through vertical jambs, and
// meets at a cusp at _archApexY. _archHalfWidth keeps the arch narrower than a
// slot so daylight shows between neighbouring arches (an arcade, not a wall).
const double _archApexY = 5;
const double _archBaseY = 40;
const double _archJambTop = 28;
const double _archHalfWidth = 21;
const double _archStroke = 1.4;
// The gold hanging lamp inside the lit arch, and the box the lit icon floats in.
const double _lampDrop = 11;
const double _lampRadius = 2.2;
const double _floatIconBox = 34;
const double _floatIconY = 20;
const double _floatIconSize = 22;

class _Arcade extends StatelessWidget {
  const _Arcade({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<MihrabColors>()!;
    final motion = Theme.of(context).extension<MotionTokens>()!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final reduced = motionReduced(context);
    final n = items.length;
    // Logical index → on-screen slot (RTL mirrors the row, so Today lands last).
    final visualSlot = isRtl ? n - 1 - selectedIndex : selectedIndex;
    final target = (visualSlot + 0.5) / n;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: target),
      // The lit arch glides at the medium rung; under reduce-motion it is an
      // instant cut (06 §5 — the OS flag always wins).
      duration: reduced ? Duration.zero : motion.durationMedium,
      curve: motion.curveStandard,
      child: Row(
        children: [
          for (var i = 0; i < n; i++)
            Expanded(
              child: _Tab(
                item: items[i],
                selected: i == selectedIndex,
                space: space,
                scheme: scheme,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
      builder: (context, loc, row) {
        return SizedBox(
          height: _barHeight,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final litCenterX = loc * w;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ArcadePainter(
                        litCenterX: litCenterX,
                        count: n,
                        barFill: scheme.surfaceContainer,
                        archOutline: scheme.outlineVariant,
                        archFill: scheme.primary,
                        lamp: colors.accentGold,
                      ),
                    ),
                  ),
                  Positioned.fill(child: row!),
                  // The lit tab's icon rides on the gliding teal arch (so a white
                  // icon is always over the fill, never a moment on bare
                  // limestone); the in-row copy of it is faded but kept for the
                  // shared label baseline.
                  Positioned(
                    left: litCenterX - _floatIconBox / 2,
                    top: _floatIconY - _floatIconBox / 2,
                    width: _floatIconBox,
                    height: _floatIconBox,
                    child: Center(
                      child: Icon(
                        items[selectedIndex].selectedIcon,
                        size: _floatIconSize,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.space,
    required this.scheme,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final SpacingTokens space;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tint = selected ? scheme.primary : scheme.onSurfaceVariant;
    // One merged Semantics node per tab: the localized label, the button role,
    // and the selected state (colour is never the sole cue). The visual Text is
    // excluded so the tab reads as one node, not "Today Today" (E08-T02;
    // design-system 09 §7).
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: space.space1,
              children: [
                // The active tab's in-row icon is hidden — the arch's floating
                // icon carries it — but kept in the layout so every label stays
                // on one baseline.
                Opacity(
                  opacity: selected ? 0 : 1,
                  child: Icon(item.icon, color: tint),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium?.copyWith(
                    color: tint,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

class _ArcadePainter extends CustomPainter {
  _ArcadePainter({
    required this.litCenterX,
    required this.count,
    required this.barFill,
    required this.archOutline,
    required this.archFill,
    required this.lamp,
  });

  final double litCenterX;
  final int count;
  final Color barFill;
  final Color archOutline;
  final Color archFill;
  final Color lamp;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // The limestone bar body + a hairline cornice separating nav from content.
    canvas.drawRect(Offset.zero & size, Paint()..color = barFill);
    final outline = Paint()
      ..color = archOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = _archStroke;
    canvas.drawLine(Offset.zero, Offset(w, 0), outline);

    // The quiet arch outlines, one per slot; the lit slot is overdrawn below.
    final slot = w / count;
    for (var i = 0; i < count; i++) {
      canvas.drawPath(_arch((i + 0.5) * slot), outline);
    }

    // The lit arch: the same silhouette closed along its base and filled teal,
    // with a small gold lamp hung from its apex.
    canvas.drawPath(
      _arch(litCenterX)..close(),
      Paint()..color = archFill,
    );
    const lampY = _archApexY + _lampDrop;
    canvas.drawLine(
      Offset(litCenterX, _archApexY + 1),
      Offset(litCenterX, lampY - _lampRadius),
      Paint()
        ..color = lamp
        ..strokeWidth = 1,
    );
    canvas.drawCircle(Offset(litCenterX, lampY), _lampRadius, Paint()..color = lamp);
  }

  // A pointed (two-centred) arch silhouette centred at [cx]: up the vertical
  // jambs, then two quadratics meeting at a cusp at the apex. Open at the base —
  // `close()` adds the base line only for the filled variant.
  Path _arch(double cx) {
    final left = cx - _archHalfWidth;
    final right = cx + _archHalfWidth;
    return Path()
      ..moveTo(left, _archBaseY)
      ..lineTo(left, _archJambTop)
      ..quadraticBezierTo(left, _archApexY, cx, _archApexY)
      ..quadraticBezierTo(right, _archApexY, right, _archJambTop)
      ..lineTo(right, _archBaseY);
  }

  @override
  bool shouldRepaint(_ArcadePainter old) =>
      old.litCenterX != litCenterX ||
      old.count != count ||
      old.barFill != barFill ||
      old.archOutline != archOutline ||
      old.archFill != archFill ||
      old.lamp != lamp;
}
