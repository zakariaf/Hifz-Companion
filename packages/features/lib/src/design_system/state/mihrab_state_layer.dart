// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// The WCAG 2.2 SC 2.4.11 minimum visible focus-indicator thickness (2dp). An
/// accessibility constant the focus ring owns — deliberately NOT a spacing token
/// (it is the focus *appearance* floor, not layout distance).
const double kMihrabFocusRingWidth = 2;

/// The explicit interaction states every Mihrab interactive leaf declares
/// (design-system 07 §6). A leaf draws each state from [MihrabStateLayer] so the
/// whole library shares one M3-correct, non-celebratory feedback model.
enum MihrabInteractionState {
  /// Idle and interactive — no state-layer overlay.
  enabled,

  /// Held / actively pressed — the M3 pressed state layer (functional, quiet).
  pressed,

  /// Non-interactive and *waiting, not error* — the role is dimmed, no overlay.
  disabled,

  /// Keyboard / switch-access focus — the M3 focus state layer plus the visible
  /// [MihrabFocusRing] (SC 2.4.7).
  focused,

  /// Chosen in a single/multi-select control — the M3 selected state layer.
  selected,
}

/// The shared Material 3 interaction-state model (design-system 07 §6): every
/// interactive leaf's pressed/focused/selected feedback is an **M3 state-layer
/// overlay over a `ColorScheme` role color** — never an ad-hoc per-component
/// opacity or a bespoke hue, and never a glow/scale/sparkle reward tier (those
/// tokens do not exist in Mihrab; adab — state feedback is functional and quiet).
abstract final class MihrabStateLayer {
  /// M3 pressed state-layer opacity (10%).
  static const double pressedOpacity = 0.10;

  /// M3 focused state-layer opacity (10%).
  static const double focusedOpacity = 0.10;

  /// M3 hovered state-layer opacity (8%).
  static const double hoveredOpacity = 0.08;

  /// M3 selected state-layer opacity (10%).
  static const double selectedOpacity = 0.10;

  /// M3 disabled-content opacity (38%) — the role is faded, never recolored.
  static const double disabledOpacity = 0.38;

  /// The standard M3 overlay [WidgetStateProperty] tinted with [onColor] (the
  /// role's on-color), for a `ButtonStyle.overlayColor` / `InkWell.overlayColor`
  /// so leaves consume the model through ordinary M3 plumbing. `enabled` and
  /// `disabled` resolve to no overlay (`Colors.transparent`).
  static WidgetStateProperty<Color?> overlayColor(Color onColor) =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.transparent;
        if (states.contains(WidgetState.pressed)) {
          return onColor.withValues(alpha: pressedOpacity);
        }
        if (states.contains(WidgetState.focused)) {
          return onColor.withValues(alpha: focusedOpacity);
        }
        if (states.contains(WidgetState.hovered)) {
          return onColor.withValues(alpha: hoveredOpacity);
        }
        if (states.contains(WidgetState.selected)) {
          return onColor.withValues(alpha: selectedOpacity);
        }
        return Colors.transparent;
      });

  /// The overlay color for a single explicit [state] — the pure mapping the
  /// tests assert: `enabled`/`disabled` → transparent; `pressed`/`focused`/
  /// `selected` → the on-color at its calm M3 opacity. Never a bright bespoke
  /// hue and never a scale/glow tier.
  static Color overlayFor(MihrabInteractionState state, Color onColor) =>
      switch (state) {
        MihrabInteractionState.enabled ||
        MihrabInteractionState.disabled =>
          Colors.transparent,
        MihrabInteractionState.pressed =>
          onColor.withValues(alpha: pressedOpacity),
        MihrabInteractionState.focused =>
          onColor.withValues(alpha: focusedOpacity),
        MihrabInteractionState.selected =>
          onColor.withValues(alpha: selectedOpacity),
      };

  /// The disabled dim applied to a [role] color — *waiting, not error*: the role
  /// is faded to [disabledOpacity], never recolored to a warning hue (07 §6).
  /// Disabled adds no state layer; it only dims.
  static Color dimmedRole(Color role) =>
      role.withValues(alpha: disabledOpacity);
}

/// A WCAG 2.2 SC 2.4.7/2.4.11 focus ring: a [kMihrabFocusRingWidth]-thick
/// outline in `ColorScheme.outline`, shown when the wrapped subtree holds focus.
///
/// The ring is a full, symmetric outline, so it **follows the component and
/// favors no physical side** (RTL-correct by construction); its corner radius is
/// the `space2` spacing token. Painting the border in a [DecoratedBox] adds no
/// layout, so focusing causes no reflow (deterministic goldens).
class MihrabFocusRing extends StatefulWidget {
  /// Wraps [child] with a focus-tracking outline; [borderRadius] overrides the
  /// default `space2` all-corner radius.
  const MihrabFocusRing({required this.child, this.borderRadius, super.key});

  /// The subtree whose focus drives the ring.
  final Widget child;

  /// Optional corner radius (defaults to a `space2`-radius on all corners).
  final BorderRadiusGeometry? borderRadius;

  @override
  State<MihrabFocusRing> createState() => _MihrabFocusRingState();
}

class _MihrabFocusRingState extends State<MihrabFocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final radius = widget.borderRadius ??
        BorderRadiusDirectional.all(Radius.circular(space.space2));
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (value) => setState(() => _focused = value),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: _focused
                ? BorderSide(
                    color: scheme.outline,
                    width: kMihrabFocusRingWidth,
                  )
                : BorderSide.none,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Wraps [child] with the [Semantics] flags an interactive leaf announces for
/// [states] so its state is conveyed non-visually (07 §6; SC 4.1.2): the
/// enabled flag tracks `disabled`, and `selected` is set only when chosen.
Widget mihrabStateSemantics({
  required Set<MihrabInteractionState> states,
  required Widget child,
}) =>
    Semantics(
      enabled: !states.contains(MihrabInteractionState.disabled),
      selected: states.contains(MihrabInteractionState.selected) ? true : null,
      child: child,
    );
