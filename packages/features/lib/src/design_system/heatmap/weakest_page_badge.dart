// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// A calm marker that a juz roll-up tile carries a weakest page (design-system
/// 08 §6) — the visible half of the min-leaning roll-up: one weak page must be
/// able to surface at the chart layer, never averaged away (C-019).
///
/// It is a quiet dot in [color] (the heat ramp's weak step or a neutral) —
/// **never** an alarm-red or an exclamation. Decorative; the spoken
/// "weakest page N" lives in the cell's merged `Semantics`.
class WeakestPageBadge extends StatelessWidget {
  /// Creates a badge tinted [color] (the caller passes a calm ramp/neutral step).
  const WeakestPageBadge({required this.color, super.key});

  /// The calm marker color (never an alarm token).
  final Color color;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Container(
      width: space.space2,
      height: space.space2,
      decoration: ShapeDecoration(color: color, shape: const CircleBorder()),
    );
  }
}
