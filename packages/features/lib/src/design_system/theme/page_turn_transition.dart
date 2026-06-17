// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'motion_tokens.dart';
import 'reduced_motion.dart';

/// The routine directional page-turn (design-system 06 §3): the entering page
/// slides in from the **start** edge toward centre while the leaving page exits
/// toward the **end** edge. Direction is read from `Directionality` — in RTL
/// (fa/ckb/ar) the next page enters from the right and the old page leaves to
/// the left, matching a physical muṣḥaf — so one transition serves every locale
/// with no left/right hardcoded.
///
/// Duration and curve come from [MotionTokens]; when [motionReduced] is true the
/// slide collapses to an instant cut (the collapse is not overridable per call,
/// 06 §5). Only the page *surface* moves — the immutable glyph layer (E05) is
/// handed in as a plain [child] and is never re-typeset here.
class PageTurnTransition extends StatelessWidget {
  /// Creates a page-turn around [child]; supply a distinct [Key] per page so the
  /// switch is detected (and the entering/leaving pages can be told apart).
  const PageTurnTransition({required this.child, super.key});

  /// The current page surface. Its [Key] identity drives the transition.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = Theme.of(context).extension<MotionTokens>()!;
    final reduced = motionReduced(context);
    // The start edge in screen-space: +1 (right) in RTL, -1 (left) in LTR.
    final startSign =
        Directionality.of(context) == TextDirection.rtl ? 1.0 : -1.0;
    final incomingKey = child.key;

    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : motion.durationMedium,
      switchInCurve: motion.curveStandard,
      switchOutCurve: motion.curveStandard,
      transitionBuilder: (transitionChild, animation) {
        if (reduced) return transitionChild; // instant cut — no slid frame
        final isIncoming = transitionChild.key == incomingKey;
        // Incoming: start edge -> centre. Leaving: centre -> end edge.
        final tween = isIncoming
            ? Tween<Offset>(begin: Offset(startSign, 0), end: Offset.zero)
            : Tween<Offset>(begin: Offset(-startSign, 0), end: Offset.zero);
        return SlideTransition(
          position: animation.drive(tween),
          child: transitionChild,
        );
      },
      child: child,
    );
  }
}
