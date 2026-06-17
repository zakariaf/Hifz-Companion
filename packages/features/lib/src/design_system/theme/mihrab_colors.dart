// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// The bespoke colour families Material 3 does not name (design-system 03):
/// the single-hue, monotonic-in-luminance heat-map ramp, the calm track-chip
/// and decay tints, the warm reader surfaces, and the one semantic token
/// (`semanticWarning`).
///
/// There is deliberately **no** `semanticSuccess` and **no** `semanticDanger`:
/// green is reverent ground, never reward, and decay is never alarm-red
/// (PRD R3/C6; 03 §2/§6). Read only via
/// `Theme.of(context).extension<MihrabColors>()`.
@immutable
class MihrabColors extends ThemeExtension<MihrabColors> {
  /// Creates a bespoke colour set for one appearance.
  const MihrabColors({
    required this.heatmapStrong,
    required this.heatmapGood,
    required this.heatmapFair,
    required this.heatmapWeak,
    required this.heatmapFaded,
    required this.trackChipSurface,
    required this.trackChipText,
    required this.decayCalm,
    required this.readerSurfaceSepia,
    required this.readerSurfaceNight,
    required this.semanticWarning,
    required this.accentGold,
  });

  /// Heat-map: high retention (the calm green anchor). 03 §5.
  final Color heatmapStrong;

  /// Heat-map: solid retention. 03 §5.
  final Color heatmapGood;

  /// Heat-map: softening. 03 §5.
  final Color heatmapFair;

  /// Heat-map: decaying (a muted neutral, never alarm-red). 03 §5.
  final Color heatmapWeak;

  /// Heat-map: most-decayed / un-reviewed (muted neutral). 03 §5.
  final Color heatmapFaded;

  /// The non-interactive sabaq/sabqi/manzil track-chip surface (calm, green
  /// family — never three saturated category colours). 03 §2.
  final Color trackChipSurface;

  /// The track-chip label colour. 03 §2.
  final Color trackChipText;

  /// The per-page decay indicator tint — neutral/green family, never an alarm
  /// state. 03 §6.
  final Color decayCalm;

  /// The warm-paper reader backdrop for the Sepia appearance. 03 §3.
  final Color readerSurfaceSepia;

  /// The warm-dim reader backdrop for the Night appearance. 03 §4.
  final Color readerSurfaceNight;

  /// The only semantic token — a rare asset-integrity / checksum notice, paired
  /// with an icon and text. Never a comment on the user's revision. 03 §6.
  final Color semanticWarning;

  /// A muted gold/brass secondary accent for quiet ornament (the hero rule, a
  /// section marker) — reverent, low-chroma, never a reward or alert. A proposed
  /// Mihrab amendment to docs/design-system 03 (pending re-audit in E06-T10).
  final Color accentGold;

  @override
  MihrabColors copyWith({
    Color? heatmapStrong,
    Color? heatmapGood,
    Color? heatmapFair,
    Color? heatmapWeak,
    Color? heatmapFaded,
    Color? trackChipSurface,
    Color? trackChipText,
    Color? decayCalm,
    Color? readerSurfaceSepia,
    Color? readerSurfaceNight,
    Color? semanticWarning,
    Color? accentGold,
  }) {
    return MihrabColors(
      heatmapStrong: heatmapStrong ?? this.heatmapStrong,
      heatmapGood: heatmapGood ?? this.heatmapGood,
      heatmapFair: heatmapFair ?? this.heatmapFair,
      heatmapWeak: heatmapWeak ?? this.heatmapWeak,
      heatmapFaded: heatmapFaded ?? this.heatmapFaded,
      trackChipSurface: trackChipSurface ?? this.trackChipSurface,
      trackChipText: trackChipText ?? this.trackChipText,
      decayCalm: decayCalm ?? this.decayCalm,
      readerSurfaceSepia: readerSurfaceSepia ?? this.readerSurfaceSepia,
      readerSurfaceNight: readerSurfaceNight ?? this.readerSurfaceNight,
      semanticWarning: semanticWarning ?? this.semanticWarning,
      accentGold: accentGold ?? this.accentGold,
    );
  }

  @override
  MihrabColors lerp(ThemeExtension<MihrabColors>? other, double t) {
    if (other is! MihrabColors) return this;
    return MihrabColors(
      heatmapStrong: Color.lerp(heatmapStrong, other.heatmapStrong, t)!,
      heatmapGood: Color.lerp(heatmapGood, other.heatmapGood, t)!,
      heatmapFair: Color.lerp(heatmapFair, other.heatmapFair, t)!,
      heatmapWeak: Color.lerp(heatmapWeak, other.heatmapWeak, t)!,
      heatmapFaded: Color.lerp(heatmapFaded, other.heatmapFaded, t)!,
      trackChipSurface:
          Color.lerp(trackChipSurface, other.trackChipSurface, t)!,
      trackChipText: Color.lerp(trackChipText, other.trackChipText, t)!,
      decayCalm: Color.lerp(decayCalm, other.decayCalm, t)!,
      readerSurfaceSepia:
          Color.lerp(readerSurfaceSepia, other.readerSurfaceSepia, t)!,
      readerSurfaceNight:
          Color.lerp(readerSurfaceNight, other.readerSurfaceNight, t)!,
      semanticWarning: Color.lerp(semanticWarning, other.semanticWarning, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
    );
  }
}
