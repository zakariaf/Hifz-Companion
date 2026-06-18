// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:models/models.dart';

import 'constants.dart';
import 'curve.dart';
import 'juz_confidence.dart';
import 'phases.dart';
import 'scheduling_engine.dart';

/// The conservative cold-start seed table (06 §5; PRD §7.10) — the engine's
/// under-estimated prior `(D, S)` for one held page, keyed by the user's per-juz
/// self-assessment. Every value lives here, no literal at a call site; the entry
/// track is *derived* from `S` (via [bandForStability]), never switched on
/// confidence, so the table and the phase thresholds stay one source of truth.
const Map<JuzConfidence, ({double d, double s})> _coldStartSeed = {
  JuzConfidence.solid: (d: 3.0, s: 60.0), // → FAR / manzil
  JuzConfidence.shaky: (d: 5.0, s: 14.0), // → NEAR
  JuzConfidence.rusty: (d: 7.0, s: 4.0), // → active revision (NEW)
};

/// Cold-start seeding on the engine façade.
extension ColdStart on SchedulingEngine {
  /// Seeds a fresh [CardSeed] for one **held** page from a per-juz [confidence]
  /// (06 §5; PRD §7.10). Pure: identical inputs → identical seed.
  ///
  /// Returns a [CardSeed] (no `profileId` — the cold-start repository binds it,
  /// E03-T08), with the conservative `(D, S)` prior from the seed table, the
  /// entry track derived from the (possibly decayed) `S`, and `dueAt == today`
  /// so the first weeks review every held page once (PRD §7.10 step 5). Priors
  /// deliberately **under**-estimate strength so the first real recitation can
  /// only surprise upward; coverage capture (which pages are held) is the
  /// caller's job — this never returns an unmemorized seed.
  ///
  /// When [memorizedOn] is known, `S` is aged toward the prior implied by the
  /// forgetting curve at that age (PRD §7.10 step 3): a juz finished long ago
  /// decays into active revision ("needs reactivation"). The age multiplier is
  /// clamped to `≤ 1` so a known date can only ever *decay* the seed, never
  /// inflate it — preserving the conservative-under-estimate rule and leaving a
  /// just-memorized page at exactly the seed.
  CardSeed coldStartCard(
    int pageId,
    JuzConfidence confidence,
    CalendarDate today, {
    CalendarDate? memorizedOn,
  }) {
    assert(pageId >= 1 && pageId <= 604, 'pageId is a muṣḥaf page 1..604');
    final seed = _coldStartSeed[confidence]!;
    var s = seed.s;
    if (memorizedOn != null) {
      final ageDays = today.epochDay - memorizedOn.epochDay;
      // Normalize retrievability(age) to the R(S,S)=0.9 baseline, then clamp the
      // multiplier to ≤ 1 so the prior can only decay, never inflate (rule 15).
      final decay = min(1.0, retrievability(ageDays, seed.s) / 0.9);
      s = max(kMinStability, seed.s * decay);
    }
    return CardSeed(
      pageId: pageId,
      track: bandForStability(s),
      difficulty: seed.d,
      stabilityDays: s,
      lastReviewedDay: today,
      dueAt: today, // every held page due now → first weeks review each once
    );
  }
}
