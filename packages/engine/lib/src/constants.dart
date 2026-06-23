// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The engine's scalar constants and FSRS weight vector, in exactly one place
/// (06 §8). Every scheduling call site references these **by name** — a literal
/// `36500`/`0.5`/`0.15` at a call site is a review failure (eng-write-engine-
/// golden-vector pattern 10) — so an FSRS-6 bump is one reviewed re-freeze.
///
/// `kDecay`/`kFactor` deliberately do **not** live here — they are the curve
/// constants in `curve.dart`, kept computed so FSRS-6 is the one-line
/// `kDecay = -w[20]` change. This file holds plain `const` data and imports
/// nothing.
///
/// E04-T03 seeds this with the two constants `curve.dart` references
/// (`kMaxInterval`, `kFsrsWeightCount`); E04-T05 adds the phase/retention
/// thresholds and E04-T10 adds the FSRS tunables and `kDefaultWeights45`.
library;

/// Number of FSRS weights this engine expects: 19 for FSRS-4.5/5; 21 for
/// FSRS-6 (which adds `w19` and the trainable curve decay `w20`).
///
/// The weight vector's length is asserted `== this` at construction (06 §8): a
/// 19-vs-21 mismatch must fail **loudly**, not silently mis-schedule every
/// interval. The FSRS-6 path is `kDecay = -w[20]` in `curve.dart`, this count
/// → 21, and a reviewed re-freeze of `kDefaultWeights45` — no structural change.
const int kFsrsWeightCount = 19;

/// Interval ceiling in days (~100 years) — matches the reference scheduler
/// clamps. `interval(...)` (E04-T03) clamps its result to `[1, kMaxInterval]`,
/// so a near-perfect page still returns `≥ 1` day: no arithmetic path can ever
/// imply a page is "safe to drop" (06 §3, §8; PRD §7.12).
const int kMaxInterval = 36500;

/// Stability floor (days). A card's `S` is never driven below this — a forgotten
/// page still keeps a finite, positive stability (06 §8).
const double kMinStability = 0.1;

/// Source-confidence weight for a self-rating; a teacher sign-off is `1.0`.
///
/// Scales the **applied stability gain** only (06 §4) — a noisy self-grade
/// moves `S` less, so it cannot vault a page to a long interval, and self-rating
/// alone cannot reach the prayer-critical tier (PRD §8.1, §8.2).
const double kSelfConfidence = 0.5;

/// Difficulty bump added to `D` on a lapse (Again), clamped to `[1, 10]`
/// (PRD §7.7; 06 §4).
const double kLapseDifficultyBump = 1.0;

/// Difficulty contribution per chronically-weak line, into `D` — the `(11−D)`
/// interference channel turns higher `D` into a shorter interval automatically,
/// with no parallel scheduler (06 §4).
const double kWeakLineFactor = 0.15;

/// Difficulty contribution per unit of logged `confusion_edge.weight`, into `D`
/// on **every** member of a confusable group when a wrong-branch swap is logged
/// (PRD §9.2; science 05 §4; CLAIMS C-029).
///
/// A swap bumps `D` on the whole group through the **same** `D` channel as the
/// weak-line factor, so the `(11−D)` term in `stabilityOnSuccess` turns the
/// higher `D` into a shorter interval at each member's next review — no bespoke
/// frequency override, no parallel scheduler. The bump is `D += this × weight`,
/// clamped to `[1, 10]`, so a heavily-confused pair cannot push `D` out of
/// range. Tunable code constant, **never** a user-facing slider; flagged for
/// scholarly/owner confirmation.
const double kConfusionDifficultyBump = 0.5;

/// Load-balance deferral floor: a Near page whose predicted `R` is **above**
/// this may slip a day; a page at or below it is promoted to mandatory.
/// Manzil/FAR is never deferred (PRD §7.9; 06 §7).
const double kHardFloorR = 0.85;

/// Estimated minutes to revise one muṣḥaf page — the load balancer's budget
/// unit (PRD §7.9). A flat per-page estimate for E04; a richer per-difficulty /
/// per-line model is a future refinement.
const int kEstMinutesPerPage = 2;

/// Phase threshold (days): below this stability a memorized page is still
/// solidifying — the New phase (06 §5; PRD §7.4).
const double kNearMinS = 9.0;

/// Phase threshold (days): at or above this stability a page joins the
/// maintenance bulk — the Far/manzil phase (06 §5; PRD §7.4).
const double kFarMinS = 60.0;

/// Teacher sign-offs required (with fluency) to graduate New → Near.
///
/// PRD §7.4 specifies "*N* teacher/self sign-offs" without fixing N. Chosen
/// default: **1**, counting **teacher** sign-offs only (a self review does not
/// increment the count, matching `Card.signoffs`). Promotion to the less-
/// frequent Near track is thus a teacher's confirmation — the conservative,
/// servant-to-the-teacher reading; a self-only user's New pages stay maximally
/// revised, which errs safe. Tunable; flagged for scholarly confirmation.
const int kGraduationSignoffs = 1;

/// Stakes-tiered retention target — New phase: cheap re-exposure while building
/// (PRD §7.5; 06 §5). Tunable code constants, **never** a user-facing slider.
const double kNewTargetR = 0.90;

/// Stakes-tiered retention target — Near phase (PRD §7.5; 06 §5).
const double kNearTargetR = 0.94;

/// Stakes-tiered retention target — ordinary Far/manzil page (PRD §7.5; 06 §5).
const double kFarTargetR = 0.95;

/// Stakes-tiered retention target — a prayer-critical, weak, or previously-
/// lapsed Far page: a higher floor, never a global 0.99 (PRD §7.5; 06 §5;
/// CLAIMS C-017, C-040).
const double kCriticalTargetR = 0.97;

/// Published FSRS-4.5 default weights (`w0…w18`), shipped as the engine's PRIOR
/// only.
///
/// These are a **flashcard-population average**, not a hifz-fitted parameter set
/// (PRD §7.3; CLAIMS C-010, C-025). The engine ships **no optimizer**: it
/// collects and uploads no review telemetry (PRD C1/C2; science 03 §6), so there
/// is nothing to fit on. The guarantee is the §6 cycle ceiling, never these
/// numbers. The vector's length is asserted `== kFsrsWeightCount` where a config
/// first enters the engine (`SchedulingEngine`). This is the one place the
/// vector appears; every weight read goes through `config.weights[index]` with
/// the index named by its FSRS role at the read site.
const List<double> kDefaultWeights45 = [
  0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, 1.54575,
  0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, 2.9898, 0.51655, //
  0.6621,
];
