// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../a11y/semantics.dart';
import '../a11y/clamped_text_scaling.dart';
import '../theme/mihrab_colors.dart';
import '../theme/motion_tokens.dart';
import '../theme/spacing_tokens.dart';

/// The five-tab curved bottom navigation — Today · Muṣḥaf · Mutashābihāt ·
/// Progress · Settings, declared in that **logical** order (design-system 05
/// §3; 02 §1). The active tab lifts into a green circle that floats out of a
/// gold-edged notch in the bar surface; the notch glides to the tapped tab in
/// one calm motion. Every tab keeps its label (a11y — colour is never the sole
/// cue: the active tab is marked by the lifted circle, the filled icon, the
/// green tint, and the heavier label together).
///
/// RTL by construction (fa/ckb/ar): the tabs are a logical-order `Row`, so under
/// `Directionality.rtl` Today renders at the trailing/right edge, and the notch
/// is placed from the **visual** slot so it tracks the same tab. A dumb View:
/// selection is the [selectedIndex] + [onDestinationSelected] index callback
/// only — no `go_router`, `Navigator`, or store (that seam is E07).
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
    // why: the curved bar is a fixed-height (62dp) component that cannot reflow;
    // cap the five nav labels so the longest (ckb mutashābihāt) stays within the
    // bar at large OS text scale instead of overflowing it (E08-T03/T07; the one
    // sanctioned clamp site in the shell). Icons + tap targets keep full size,
    // and the label is supplementary to the icon. A no-op at normal scale.
    return ClampedTextScaling(
      maxScaleFactor: navLabelTextScaleCeiling,
      child: _CurvedNavBar(
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

// Component geometry (not design tokens): the bar-body height, the floating
// circle radius, and how deep the notch dips to cradle it. Tuned so the tap row
// clears the 48dp floor (05 §4).
const double _barHeight = 62;
const double _circleR = 27;
const double _notchDepth = 20;

class _CurvedNavBar extends StatelessWidget {
  const _CurvedNavBar({
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
    final n = items.length;
    // Logical index → on-screen slot (RTL mirrors the row, so Today lands last).
    final visualSlot = isRtl ? n - 1 - selectedIndex : selectedIndex;
    final target = (visualSlot + 0.5) / n;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: target),
      duration: motion.durationMedium,
      curve: motion.curveStandard,
      child: SizedBox(
        height: _barHeight,
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
      ),
      builder: (context, loc, row) {
        return SizedBox(
          height: _barHeight + _circleR,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final centerX = loc * w;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomPaint(
                      size: Size(w, _barHeight),
                      painter: _NavPainter(
                        centerX: centerX,
                        fill: scheme.surfaceContainer,
                        edge: colors.accentGold,
                      ),
                    ),
                  ),
                  Align(alignment: Alignment.bottomCenter, child: row),
                  Align(
                    alignment: Alignment(_alignX(centerX, w), -1),
                    child: _Bubble(
                      icon: items[selectedIndex].selectedIcon,
                      fill: scheme.primary,
                      onFill: scheme.onPrimary,
                      shadow: scheme.shadow,
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

  // Map a pixel centre to the Alignment-x that puts the bubble's centre there,
  // accounting for the bubble's own width (exact, edges included).
  double _alignX(double centerX, double w) {
    const d = _circleR * 2;
    if (w <= d) return 0;
    return (2 * (centerX - _circleR) / (w - d)) - 1;
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
    // The localized label + button role live on the merged Semantics node; the
    // visual Text below is excluded so the tab reads as one node, not "Today
    // Today" (E08-T02; design-system 09 §7).
    return labeled(
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: space.space1,
            children: [
              // The active tab's in-row icon is hidden — the floating bubble
              // carries it — but kept in the layout so every label stays on one
              // baseline.
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
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.icon,
    required this.fill,
    required this.onFill,
    required this.shadow,
  });

  final IconData icon;
  final Color fill;
  final Color onFill;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _circleR * 2,
      height: _circleR * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: onFill),
    );
  }
}

class _NavPainter extends CustomPainter {
  _NavPainter({required this.centerX, required this.fill, required this.edge});

  final double centerX;
  final Color fill;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = centerX;
    const half = _circleR * 1.7; // notch mouth half-width
    const ctrl = _circleR * 0.95; // bezier control spread
    final top = Path()
      ..moveTo(0, 0)
      ..lineTo(cx - half, 0)
      ..cubicTo(cx - ctrl, 0, cx - ctrl, _notchDepth, cx, _notchDepth)
      ..cubicTo(cx + ctrl, _notchDepth, cx + ctrl, 0, cx + half, 0)
      ..lineTo(w, 0);
    final body = Path.from(top)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(body, Paint()..color = fill);
    canvas.drawPath(
      top,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_NavPainter old) =>
      old.centerX != centerX || old.fill != fill || old.edge != edge;
}
