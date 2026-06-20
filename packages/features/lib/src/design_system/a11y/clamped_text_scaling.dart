// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// The text-scale **ceiling** for a genuinely dense chrome row that cannot stay
/// usable through honest reflow — the one sanctioned cap (design-system 09 §5).
///
/// `2.0` is the WCAG SC 1.4.4 (200%) bar every layout must reach *unclamped*;
/// this ceiling exists only so a dense row that would still clip *past* 200%
/// caps here rather than truncating or overflowing. It is never a value that
/// shrinks large text below the 200% bar.
const double denseRowTextScaleCeiling = 2.0;

/// Caps the OS text scale applied to [child] at [maxScaleFactor] (default the
/// [denseRowTextScaleCeiling]) via `MediaQuery.withClampedTextScaling` — the
/// **only** sanctioned text-scale ceiling in the app.
///
/// This is a *ceiling*, not a disable: scaling is still applied up to the cap.
/// `TextScaler.noScaling` and fixed-pixel fonts on user-facing text are banned
/// (design-system 09 §5; engineering 12 §7). Use it **only** on the smallest
/// dense subtree that provably clips after honest reflow attempts (logical
/// `start`/`end`, `Wrap`/`Flexible`, single-`Text` labels), with a `// why:`
/// comment naming the screen and the binding `ckb` string — never wrap a whole
/// screen (over-clamping is a disable in disguise).
///
/// **Never pass the muṣḥaf reader / any QPC-glyph subtree to this helper.** The
/// glyph layer is excluded from OS scale *entirely* (the E08-T04 scaling-
/// exclusion seam), enlarged only by E13's rendered-layer zoom transform — it is
/// not clamped, because clamping still couples it to OS scale. Serves WCAG SC
/// 1.4.4 / 1.4.10.
class ClampedTextScaling extends StatelessWidget {
  /// Caps [child]'s text scale at [maxScaleFactor] (default
  /// [denseRowTextScaleCeiling]).
  const ClampedTextScaling({
    required this.child,
    this.maxScaleFactor = denseRowTextScaleCeiling,
    super.key,
  });

  /// The subtree whose text scale is capped — a dense chrome row only, never the
  /// muṣḥaf glyph layer.
  final Widget child;

  /// The maximum text-scale factor; scaling still applies up to this ceiling.
  final double maxScaleFactor;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxScaleFactor,
      child: child,
    );
  }
}
