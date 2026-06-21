// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show ReviewGrade, ReviewTrack;
import 'package:l10n/l10n.dart' show AppLocalizations;

/// The region key used when no `cycle_config` region preset is set yet — it
/// selects the `other` branch of every term-set `select`. The persisted region
/// preset and the Settings term-set picker are E16's; this layer consumes
/// whatever `String` region key the active config exposes, falling through to
/// `other` when unset (engineering 12 §5; design 12 §6).
const String kDefaultTermSetRegion = 'other';

/// The active term-set's traditional grade VERB for [grade] under [region]
/// (PRD §6.3: again→"needed help", hard→"minor mistakes", good→"recited clean",
/// easy→"effortless"). Derived at the feature boundary every render — the verb
/// is never stored. The engine signal ([ReviewGrade]) is unchanged: only the
/// surface word swaps with the term-set; nothing in `/engine` localizes.
String gradeVerb(AppLocalizations l10n, ReviewGrade grade, String region) =>
    switch (grade) {
      ReviewGrade.again => l10n.gradeAgainVerb(region),
      ReviewGrade.hard => l10n.gradeHardVerb(region),
      ReviewGrade.good => l10n.gradeGoodVerb(region),
      ReviewGrade.easy => l10n.gradeEasyVerb(region),
    };

/// The active term-set's track label for [track] under [region] — the classical
/// sabaq/sabqi/manzil vocabulary, swappable as data. `unmemorized` shares the
/// New-lesson label. Far-revision varies by region (manzil vs dhor); the rest
/// fall through to `other`.
String trackLabel(AppLocalizations l10n, ReviewTrack track, String region) =>
    switch (track) {
      ReviewTrack.newPage ||
      ReviewTrack.unmemorized =>
        l10n.trackNewSabaq(region),
      ReviewTrack.near => l10n.trackNearSabqi(region),
      ReviewTrack.far => l10n.trackFarManzil(region),
    };
