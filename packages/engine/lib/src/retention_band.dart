// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'constants.dart' show kSelfConfidence;

import 'package:models/models.dart' show Card;

/// A page's calm decay band, derived purely from its retrievability `R` — the
/// ordered health level the Progress heat-map renders (08-data-visualization
/// §2; PRD §12.5).
///
/// Cases are ordered **weakest → strongest**, so `.index` is a strength rank
/// and a juz roll-up can lean to the *minimum* band (its weakest page; PRD
/// §10.3) rather than a mean. The display mapping to the Mihrab `color.heatmap.*`
/// ramp lives in the feature layer; this is the engine-owned *semantics*,
/// golden-pinned so the cut-offs never silently drift (the heat-map's honesty
/// depends on them).
enum RetentionBand {
  /// Most decayed, or not yet established — renders at the muted neutral end.
  faded,

  /// Clearly softened / overdue — "ready for revision".
  weak,

  /// Softening, approaching due.
  fair,

  /// Comfortably retained.
  good,

  /// Freshly strong — recently reviewed, well above any target.
  strong,
}

/// Classifies recall probability [r] (0..1) into its calm decay [RetentionBand].
///
/// The cut-offs are deliberate and golden-pinned: `strong` only comfortably
/// above the highest stakes target-R (≥ 0.95), `good` down to 0.90 (around the
/// critical/far targets), `fair` to 0.80, `weak` to 0.70 (decayed past target —
/// "ready for revision"), and `faded` below 0.70 (well decayed). Total: any
/// finite [r] maps to a band; out-of-range values are caught by the comparisons.
/// This is a *display* derivation of `R`, never a schedule — it changes no card.
RetentionBand retentionBand(double r) {
  if (r >= 0.95) return RetentionBand.strong;
  if (r >= 0.90) return RetentionBand.good;
  if (r >= 0.80) return RetentionBand.fair;
  if (r >= 0.70) return RetentionBand.weak;
  return RetentionBand.faded;
}

/// The **min-leaning** juz roll-up band (PRD §10.3, §7.12; 08-data-visualization
/// §6) — the band of the *weakest* page in a juz, **never a mean**.
///
/// One decaying page must be able to colour (or flag) its whole juz, so a
/// strong-average juz can never hide a single rotting page — the silent-decay
/// failure the product exists to prevent. [bands] are the bands of the juz's
/// memorized pages; returns `null` when the juz holds no memorized page (an
/// untouched juz, rendered faded by the caller). This is a deliberate,
/// load-bearing aggregate: do not "improve" it into a mean for a greener map.
RetentionBand? minLeaningBand(Iterable<RetentionBand> bands) {
  RetentionBand? weakest;
  for (final band in bands) {
    if (weakest == null || band.index < weakest.index) weakest = band;
  }
  return weakest;
}

/// The per-page source confidence the VSUP heat-map muting reads (0..1): a page
/// carried by a teacher sign-off is vivid (`1.0`), one carried only by
/// self-rating is muted ([kSelfConfidence] ≈ 0.5; 08-data-visualization §4;
/// PRD §8.1). A page with no real review yet (`reps == 0`, a cold-start prior)
/// is handled separately by the `everReviewed` muting; this reflects the
/// grade *source*, not whether it was reviewed.
double sourceConfidenceOf(Card card) =>
    card.signoffs > 0 ? 1.0 : kSelfConfidence;
