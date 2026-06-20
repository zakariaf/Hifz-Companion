// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../design_system/theme/motion_tokens.dart';
import '../design_system/theme/reduced_motion.dart';

/// Substitutes an **instant cut or cross-fade** for a non-essential reveal
/// transition when the OS Reduce Motion preference is set, and otherwise plays
/// the surface's own calm cross-fade (design-system 09 §9, 06 §5).
///
/// The reduce-motion flag is read **only** through [motionReduced] (E06-T07's
/// single centralized OS-flag read) — this widget never reads the OS reduce-
/// motion preference itself. When reduced, the swap is an instant cut
/// (`Duration.zero`, the transition builder passes the child straight through);
/// when not reduced, it is a calm `FadeTransition` at the [MotionTokens]
/// duration/curve.
///
/// **The fallback is always plainer-or-equal to the animated path** — only a cut
/// or a cross-fade of an already-calm surface, never a slide, scale, overshoot,
/// or any celebratory motion (PRD R3, C6). There is no `celebrate`/`emphasized`
/// tier in the motion vocabulary to reach for, and this widget must not invent
/// one as a "nicer" fallback; the collapse is not overridable per call. Suppress
/// only the *visual* motion — a reader-relevant state change still fires its
/// `announceState` (E08-T02) independently.
///
/// Hand it a plain [child]; it never touches, reflows, or re-typesets a muṣḥaf
/// glyph (the immutable page is E05's). Supply a distinct [Key] per state so the
/// switch is detected.
class ReduceMotionSwitcher extends StatelessWidget {
  /// Wraps [child]; an explicit [duration] overrides the [MotionTokens] medium
  /// rung for the cross-fade (the reduced path is always instant regardless).
  const ReduceMotionSwitcher({required this.child, this.duration, super.key});

  /// The current surface; its [Key] identity drives the reveal.
  final Widget child;

  /// The cross-fade duration when motion is allowed; defaults to the
  /// [MotionTokens] medium rung.
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final reduced = motionReduced(context);
    final motion = Theme.of(context).extension<MotionTokens>()!;
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : (duration ?? motion.durationMedium),
      switchInCurve: motion.curveStandard,
      switchOutCurve: motion.curveStandard,
      transitionBuilder: (child, animation) => reduced
          // Instant cut — no fade frame; the OS flag always wins.
          ? child
          // Calm cross-fade only — never a slide, scale, or celebratory curve.
          : FadeTransition(opacity: animation, child: child),
      child: child,
    );
  }
}
