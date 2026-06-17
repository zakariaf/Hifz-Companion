// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';

import 'constants.dart';

/// The three traditional tracks as three lifecycle phases of ONE card, derived
/// from stability — never three algorithms (06 §5; PRD §7.4). `phaseOf` is the
/// read model; `updateGraduation` is the predictable, sign-off-gated write gate.

/// The stability band a memorized page falls in, by the §5 thresholds
/// (`< kNearMinS` → New, `< kFarMinS` → Near, else Far).
///
/// The single source of the band logic: `phaseOf` and `updateGraduation` derive
/// the phase of a live card from it, and `coldStartCard` (E04-T06) derives a
/// fresh seed's entry track from it — so the seed table and the phase thresholds
/// can never drift apart.
ReviewTrack bandForStability(double s) {
  if (s < kNearMinS) return ReviewTrack.newPage;
  if (s < kFarMinS) return ReviewTrack.near;
  return ReviewTrack.far;
}

/// The strength rank of a track (weakest → strongest): unmemorized < new < near
/// < far. Used for the demotion/promotion comparison.
///
/// The `models` `ReviewTrack` is declared in wire-token order (`newPage`,
/// `near`, `far`, `unmemorized`), so its `index` is **not** monotone with
/// strength (unmemorized would sort highest). This explicit rank is the single
/// source of the strength order the engine compares on, so no code relies on the
/// enum's declaration order.
int trackStrength(ReviewTrack track) => switch (track) {
      ReviewTrack.unmemorized => 0,
      ReviewTrack.newPage => 1,
      ReviewTrack.near => 2,
      ReviewTrack.far => 3,
    };

/// The page's phase, derived from stability `S` and state (06 §5; PRD §7.4).
///
/// An unmemorized card is unmemorized; a `manualLock` (teacher pin) returns the
/// card's stored `track` regardless of `S`; otherwise the band is read from `S`
/// (`< kNearMinS` → New, `< kFarMinS` → Near, else Far). No stored `phase`
/// field — one source of truth.
ReviewTrack phaseOf(Card c) {
  if (c.track == ReviewTrack.unmemorized) return ReviewTrack.unmemorized;
  if (c.hasManualLock) return c.track; // teacher pin wins over the math
  return bandForStability(c.stabilityDays);
}

/// The stakes-tiered retention target for a card (06 §5; PRD §7.5).
///
/// New 0.90 (cheap re-exposure while building) → Near 0.94 → Far 0.95 ordinary,
/// escalating to 0.97 for a prayer-critical, weak, or previously-lapsed Far
/// page. Never a global 0.99, never a user-facing slider — high R is reserved
/// for mature, stakes-critical pages and made affordable by their large `S`.
double targetR(Card c) => switch (phaseOf(c)) {
      ReviewTrack.newPage => kNewTargetR,
      ReviewTrack.near => kNearTargetR,
      ReviewTrack.far => (c.isPrayerCritical || c.isWeak || c.lapses > 0)
          ? kCriticalTargetR
          : kFarTargetR,
      ReviewTrack.unmemorized => kFarTargetR, // unreachable; defensive default
    };

/// The predictable, sign-off-gated graduation gate (06 §5; PRD §7.4).
///
/// Called by `onReview` **after** the S/D update and **before** the trust clamp,
/// on a card whose `S` already reflects this review. It keeps the stored `track`
/// in step with the phase `S` warrants, with one deliberate asymmetry: a
/// promotion to a less-frequent band is *held back* until its gate is satisfied;
/// a demotion follows `S` down immediately.
///
/// - A teacher review increments `signoffs` (a self review does not — `signoffs`
///   is a teacher/talaqqī count). This is the only place `signoffs` grows.
/// - `manualLock` freezes graduation entirely — the teacher's pin stands.
/// - **Demotion** (the post-review band is weaker than the stored track): set the
///   track to that band at once — a lapse rejoins active revision (no gate).
/// - **New → Near**: requires fluency (`Easy`) AND `signoffs >= kGraduationSignoffs`
///   — a correct-but-effortful `Hard` never promotes (fluency gates graduation,
///   CLAIMS C-024).
/// - **Near → Far**: requires fluency AND `S >= kFarMinS` AND the page is outside
///   the recent-juz window ([inRecentWindow] is injected by the caller; the pure
///   engine owns no juz map).
///
/// Never promotes the track *above* the band `S` warrants, and never promotes on
/// a lapse — so `Again ⇒ track' ≤ track` (INV-3). Total: asserts, never throws.
Card updateGraduation(
  Card c,
  ReviewGrade grade,
  GradeSource source, {
  required bool inRecentWindow,
}) {
  final newSignoffs =
      source == GradeSource.teacher ? c.signoffs + 1 : c.signoffs;
  if (c.hasManualLock) return c.copyWith(signoffs: newSignoffs);
  if (c.track == ReviewTrack.unmemorized) {
    return c.copyWith(signoffs: newSignoffs);
  }

  final sBand = bandForStability(c.stabilityDays);
  final fluent = grade == ReviewGrade.easy;
  var track = c.track;

  if (trackStrength(sBand) < trackStrength(track)) {
    // Demotion: a lapse shrank S; the stored track follows S down — no gate.
    track = sBand;
  } else if (trackStrength(sBand) > trackStrength(track)) {
    // Promotion is gated, predictable, and fluency-driven — never a hidden jump,
    // and at most ONE band per review (the `else if` keeps a page from skipping
    // the Near/sabqi consolidation phase straight to Far in a single review).
    if (track == ReviewTrack.newPage &&
        trackStrength(sBand) >= trackStrength(ReviewTrack.near) &&
        fluent &&
        newSignoffs >= kGraduationSignoffs) {
      track = ReviewTrack.near;
    } else if (track == ReviewTrack.near &&
        trackStrength(sBand) >= trackStrength(ReviewTrack.far) &&
        fluent &&
        !inRecentWindow) {
      track = ReviewTrack.far;
    }
  }
  return c.copyWith(track: track, signoffs: newSignoffs);
}
