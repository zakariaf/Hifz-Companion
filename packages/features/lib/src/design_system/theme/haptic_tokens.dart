// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The three tactile pulses Mihrab allows (design-system 06 §4). There is no
/// success/reward pulse, no `heavyImpact`, no `vibrate` — the absence is the
/// enforcement of "no gamification of worship."
enum HapticPulse {
  /// A light tick on a discrete selection (a chip, a segment).
  selection,

  /// A gentle confirmation that an action committed.
  confirm,

  /// Accompanies a warning state (always with an on-screen change).
  warning,
}

/// Routes every tactile pulse through the theme so widgets never call
/// `HapticFeedback` directly; read via
/// `Theme.of(context).extension<HapticTokens>()` (06 §4).
@immutable
class HapticTokens extends ThemeExtension<HapticTokens> {
  /// Creates the standard haptic token set.
  const HapticTokens.standard();

  /// Fires the platform haptic for [pulse]. Each pulse accompanies an on-screen
  /// change and never repeats or escalates.
  Future<void> fire(HapticPulse pulse) {
    return switch (pulse) {
      HapticPulse.selection => HapticFeedback.selectionClick(),
      HapticPulse.confirm => HapticFeedback.lightImpact(),
      HapticPulse.warning => HapticFeedback.lightImpact(),
    };
  }

  @override
  HapticTokens copyWith() => const HapticTokens.standard();

  // Haptics are discrete platform calls — there is nothing to interpolate.
  @override
  HapticTokens lerp(ThemeExtension<HapticTokens>? other, double t) => this;
}
