// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

import 'heat_level.dart';

/// The display-only data a [HeatmapCell] renders — only what the cell draws,
/// never anything it would compute (design-system 08).
///
/// It carries **no** `card.R`/D/S/`due_at`/`DateTime`/store handle: the [level]
/// (page band, or the juz **min-leaning** roll-up) is classified upstream, and
/// [localizedValue] / [label] arrive already localized. The two VSUP inputs
/// ([everReviewed], [sourceConfidence]) are read to choose the muted blend,
/// never written or recomputed.
@immutable
class HeatmapCellData {
  /// Creates the data for one heat-map cell (page or juz roll-up).
  const HeatmapCellData({
    required this.level,
    required this.localizedValue,
    required this.label,
    required this.everReviewed,
    required this.sourceConfidence,
    this.isJuzRollUp = false,
    this.weakestPageId,
    this.showDecayTexture = false,
  });

  /// The engine-classified band (page) or min-leaning roll-up (juz).
  final HeatLevel level;

  /// The retrievability value or range, already formatted in locale numerals
  /// (e.g. "۸۰–۹۰٪" or "estimated — not yet recited"); never ASCII, never `R`.
  final String localizedValue;

  /// The transcreated plain band label ("strong" / "softening" /
  /// "ready for revision"), already resolved from an `AppLocalizations` key.
  final String label;

  /// Whether the page has ever been recited — a never-recited page renders muted
  /// regardless of an optimistic prior (VSUP, 08 §4).
  final bool everReviewed;

  /// The confidence of the recent grades driving the muting: self ≈ 0.5,
  /// teacher = 1.0. A self-only cell cannot reach the most-saturated tier.
  final double sourceConfidence;

  /// Whether this is a juz roll-up tile (shows the weakest-page badge).
  final bool isJuzRollUp;

  /// The weakest page in the juz the badge names (null on a page cell, or when
  /// no weak link exists).
  final int? weakestPageId;

  /// Whether to paint the optional decay texture (a third colour-independent
  /// channel) on the decaying end.
  final bool showDecayTexture;
}
