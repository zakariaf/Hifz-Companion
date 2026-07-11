// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'phases.dart';
import 'scheduling_engine.dart';

/// The conservative fresh-sabaq seed prior `(D, S)` for a page memorized **today**
/// as new memorization (PRD §7.8; 06 §5). A freshly-memorized page enters
/// **active revision** — the New track — under-estimated so its first recitation
/// can only surprise upward (C-009), and it is revised frequently while it
/// consolidates. The magnitude matches the most-conservative cold-start prior
/// (the "rusty" seed): a just-learned page and a long-decayed one both need
/// frequent revision. Tunable; the sabaq golden vector pins it, so any change is
/// a deliberate, reviewed edit — never a silent drift.
const ({double d, double s}) _sabaqSeedPrior = (d: 7.0, s: 4.0);

/// New-memorization (sabaq) intake on the engine façade — the page-granular
/// intake seam E04 deferred to the feature layer (`build_today.dart`), now owned
/// by E21.
extension SabaqIntake on SchedulingEngine {
  /// Seeds a fresh [CardSeed] for one page the ḥāfiẓ has **newly memorized**
  /// today (PRD §7.8; the page-granular intake of E21). Pure: identical inputs →
  /// identical seed.
  ///
  /// The page enters the New track (sabaq) with the conservative [_sabaqSeedPrior]
  /// and `dueAt == today`, so it appears in today's New section for its first
  /// consolidating revision and is then scheduled by `onReview` like any other
  /// card. Priors deliberately **under**-estimate strength (C-009); the entry
  /// track is *derived* from `S` via [bandForStability], never switched, so this
  /// and the phase thresholds stay one source of truth.
  ///
  /// This is a **seed** act — it creates a card; it is never a graduation
  /// transition (`updateGraduation` never promotes out of `unmemorized`). The
  /// repository binds the `profileId` and persists it through the single write
  /// path (E21-T02); this returns a `CardSeed` only, with no `profileId` and no
  /// prayer-critical flag (that seeding is E21-T08's).
  CardSeed sabaqSeed(int pageId, CalendarDate today) {
    assert(pageId >= 1 && pageId <= 604, 'pageId is a muṣḥaf page 1..604');
    return CardSeed(
      pageId: pageId,
      track: bandForStability(_sabaqSeedPrior.s),
      difficulty: _sabaqSeedPrior.d,
      stabilityDays: _sabaqSeedPrior.s,
      lastReviewedDay: today,
      dueAt: today, // enter the loop now → revised today, then scheduled
    );
  }
}
