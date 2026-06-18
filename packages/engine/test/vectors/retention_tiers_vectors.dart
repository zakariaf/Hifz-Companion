// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Frozen stakes-tiered retention rows (06 §5; PRD §7.5). The interval column is
// the §3 closed-form consequence of each target (computed from the FSRS
// definition, never the engine), so a higher tier is a strictly shorter
// interval — the cost the tiers buy. All < 0.99: never a global maximum.

/// One frozen retention tier: its phase label, target `R`, and the interval the
/// FSRS closed form gives for that target at `S = 100`.
class RetentionTier {
  /// Constructs a tier row.
  const RetentionTier(this.label, this.targetR, this.intervalAt100, this.notes);

  /// The phase / page kind this tier applies to.
  final String label;

  /// The stakes-tiered retention target.
  final double targetR;

  /// `interval(100, targetR)` — the §3 closed-form cost of the tier.
  final int intervalAt100;

  /// Why this tier exists.
  final String notes;
}

/// New → Near → Far-ordinary → Far-critical, each a strictly higher target and
/// thus a strictly shorter interval.
const retentionTiers = <RetentionTier>[
  RetentionTier('New', 0.90, 100, 'cheap re-exposure while building'),
  RetentionTier('Near', 0.94, 56, 'recent-juz window'),
  RetentionTier('Far ordinary', 0.95, 46, 'maintenance bulk'),
  RetentionTier('Far critical', 0.97, 27, 'prayer-critical / weak / lapsed'),
];
