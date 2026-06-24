// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui' show Locale;

import 'package:engine/engine.dart' show RetentionBand;
import 'package:l10n/l10n.dart';

import '../design_system/design_system.dart' show HeatLevel, HeatmapCellData;
import 'progress_overview.dart';

/// Maps the engine's [RetentionBand] (the golden-pinned health semantics) to the
/// E10 display [HeatLevel] — a 1:1 enum bridge so the band math stays in the
/// engine and the ramp colour stays in the design system (downward-only deps).
HeatLevel heatLevelOf(RetentionBand band) => switch (band) {
      RetentionBand.strong => HeatLevel.strong,
      RetentionBand.good => HeatLevel.good,
      RetentionBand.fair => HeatLevel.fair,
      RetentionBand.weak => HeatLevel.weak,
      RetentionBand.faded => HeatLevel.faded,
    };

/// The calm, transcreated band label ("strong" / "softening" / "ready for
/// revision" …) for [band] — resolved from an ARB key, never hard-coded.
String bandLabel(AppLocalizations l10n, RetentionBand band) => switch (band) {
      RetentionBand.strong => l10n.progressBandStrong,
      RetentionBand.good => l10n.progressBandGood,
      RetentionBand.fair => l10n.progressBandFair,
      RetentionBand.weak => l10n.progressBandWeak,
      RetentionBand.faded => l10n.progressBandFaded,
    };

/// The inclusive percentage range (low, high) the band stands for — used by the
/// page-detail sheet to state retrievability as a **range in words**, never a
/// false-precise single percent (08-data-visualization §4).
(int, int) bandRange(RetentionBand band) => switch (band) {
      RetentionBand.strong => (95, 100),
      RetentionBand.good => (90, 95),
      RetentionBand.fair => (80, 90),
      RetentionBand.weak => (70, 80),
      RetentionBand.faded => (0, 70),
    };

/// The display data for one **page** cell. A non-memorized page reads as "not
/// started"; a memorized-but-never-recited page shows no optimistic percent (the
/// VSUP muting carries the uncertainty) — only a confirmed, recited page shows a
/// percentage. Never a raw `R`/D/S.
HeatmapCellData pageCellData(
  AppLocalizations l10n,
  Locale locale,
  PageHealth page,
) {
  final String value;
  final String label;
  if (!page.memorized) {
    value = l10n.progressNoValue;
    label = l10n.progressNotStarted;
  } else if (!page.everReviewed) {
    // A cold-start prior: muted, no optimistic percent, label matches the muting.
    value = l10n.progressNoValue;
    label = l10n.progressBandFaded;
  } else {
    final pct = (page.retrievability * 100).round();
    value = l10n.progressPercent(isolateLtr(localeDigits(pct, locale)));
    label = bandLabel(l10n, page.band);
  }
  return HeatmapCellData(
    level: heatLevelOf(page.band),
    localizedValue: value,
    label: label,
    everReviewed: page.everReviewed,
    sourceConfidence: page.sourceConfidence,
  );
}

/// The display data for one **juz roll-up** tile. The level is the min-leaning
/// roll-up (from the read model); the tile shows the juz number and the weakest
/// page badge. Muted (VSUP) when the juz has no recited page.
HeatmapCellData juzCellData(
  AppLocalizations l10n,
  Locale locale,
  JuzSummary summary,
) {
  final memorized = summary.pages.where((p) => p.memorized).toList();
  final everReviewed = memorized.any((p) => p.everReviewed);
  var sourceConfidence = 1.0;
  for (final p in memorized) {
    if (p.sourceConfidence < sourceConfidence) {
      sourceConfidence = p.sourceConfidence;
    }
  }
  final rollUp = summary.rollUp;
  return HeatmapCellData(
    level: heatLevelOf(rollUp ?? RetentionBand.faded),
    localizedValue: l10n.juzLabel(isolateLtr(localeDigits(summary.juz, locale))),
    label: rollUp == null ? l10n.progressNotStarted : bandLabel(l10n, rollUp),
    everReviewed: everReviewed,
    sourceConfidence: memorized.isEmpty ? 0 : sourceConfidence,
    isJuzRollUp: true,
    weakestPageId: summary.weakestPageId,
  );
}
