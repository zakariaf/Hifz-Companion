// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';
import 'page_card_view_data.dart';

/// A tiny decay swatch that encodes the same fact **three ways** (design-system
/// 07 §4; 08 §3): a single-hue lightness-ramp color + a filled/half/hollow glyph
/// + the localized [label] (spoken in the row's merged phrase).
///
/// The decaying end is a **muted neutral** (`color.heatmap.weak`), never
/// red/amber — a most-decayed page reads quiet, not injured; the level derives
/// from `R` but the **number is never shown**, and there is structurally no
/// "safe to drop" / "mastered" level (C-019). Capped at `space.4` so it stays a
/// quiet indicator, not a gauge. The glyph is decorative (`ExcludeSemantics`);
/// [label] carries the meaning non-visually.
class DecayIndicator extends StatelessWidget {
  /// Creates an indicator for [level] with the localized [label].
  const DecayIndicator({required this.level, required this.label, super.key});

  /// The decay band to render.
  final DecayLevel level;

  /// The already-localized calm decay word, spoken in the merged phrase.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MihrabColors>()!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final (color, glyph) = switch (level) {
      DecayLevel.solid => (colors.heatmapStrong, Icons.circle),
      DecayLevel.holding => (colors.heatmapFair, Icons.contrast),
      DecayLevel.needsRevision => (colors.heatmapWeak, Icons.circle_outlined),
    };
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Icon(glyph, color: color, size: space.space4),
      ),
    );
  }
}
