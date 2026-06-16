# 06 — Scheduling Engine

This document specifies Hifz Companion's revision engine: the pure-Dart, FSRS-style scheduler that decides *which muṣḥaf pages a ḥāfiẓ revises today, in what order, and when each is next due*. It is the core intellectual property of the product ([PRD §7](../PRD.md)) and the one place where memory science, the traditional sabaq / sabqi / manzil workflow, and the "nothing decays silently" covenant meet in code. Everything here applies the *Decision log: Scheduling engine* entry (README decision 4) and is grounded in the evidence dossier [research/fsrs-and-sr-implementations.md](research/fsrs-and-sr-implementations.md), which read every FSRS formula, constant, and reference implementation below from a primary source and verified each URL resolves.

The boundaries are deliberate and load-bearing. This engine is a **pure-Dart package with zero I/O**: it imports no Flutter, opens no database, reads no clock, and consumes no randomness. It receives plain value objects — a list of `Card` states, a `CycleConfig`, and an injected `today` — and returns plain value objects — updated cards and an ordered day plan — which `/data` ([05-persistence-and-encryption.md](05-persistence-and-encryption.md)) then persists in one transaction. What a stored "due date" *means* as a calendar day, and all integer day arithmetic, belong to [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md); the engine treats days as opaque serial integers. Grading inputs (self vs teacher sign-off) are normalized by the recite flow ([PRD §8](../PRD.md)) before they reach the engine. The mutashābihāt dataset that seeds interference links is owned by [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md). This doc owns the arithmetic and the policy on top of it, nothing else.

One rule governs everything below, and it is the second of the README's two outranking rules: **the engine may only make a page *more* frequent, never less, and never says a page is "safe to drop."** Every line of math in this document is subordinate to that clamp. The FSRS curve is a *prior*, not a promise; the cycle ceiling ([§6](#6-the-trust-clamp-the-whole-engine-in-one-rule)) is the promise.

## At a glance

| Concern | Decision |
|---|---|
| Algorithm | Vendored **FSRS-4.5 arithmetic** (power-law curve, interval, S/D updates), not the `fsrs` pub package ([open-spaced-repetition: FSRS](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler)) |
| Curve constants | `DECAY = -0.5`, `FACTOR = 0.9^(1/DECAY) − 1 = 19/81 ≈ 0.2346`, defined so `R(S,S) = 0.9` ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)) |
| Scheduled unit | **One card = one muṣḥaf page** (604 cards); line state is a derived overlay, created lazily ([PRD §7.1](../PRD.md)) |
| State per card | `D ∈ [1,10]`, `S` (days), `track`, `due_at`, `reps`, `lapses`, `weak_flag`, … ([PRD §7.2](../PRD.md)) |
| Interval fuzzing | **OFF** — every reference scheduler fuzzes by default; that breaks determinism ([dart-fsrs](https://github.com/open-spaced-repetition/dart-fsrs)) |
| Determinism | No `DateTime.now()`, no RNG, no I/O; `today` injected — identical inputs ⇒ identical schedule ([PRD §7.12](../PRD.md)) |
| The guarantee | `due_at = min(ideal_due, ceiling_due)` — the trust clamp; SR may only pull a page *forward* ([PRD §6.1, §7.6](../PRD.md)) |
| Retention target | Stakes-tiered by phase (New 0.90 → Far 0.95, 0.97+ for prayer-critical/weak) — never a global 0.99 ([PRD §7.5](../PRD.md)) |
| Weights | 19-element FSRS-4.5 vector stored as data with a length assert; FSRS-6-ready (decay from `w20`) ([Expertium](https://expertium.github.io/Algorithm.html)) |
| Tests | `package:test` golden vectors + `glados` property tests for every §7.12 invariant ([11-testing-strategy.md](11-testing-strategy.md)) |

---

## 1. The engine is vendored FSRS arithmetic, not a dependency

### Decision

The scheduling math is the **~30 lines of FSRS-4.5 arithmetic — the power-law forgetting curve, the interval inversion, and the stability/difficulty update branches — reimplemented directly in the pure-Dart `engine/` package**, cross-checked against `dart-fsrs` and Borretti's "100 lines" walkthrough but taking **neither as a runtime dependency** (*Decision log: Scheduling engine*). The trust clamp, stakes-tiered retention, cold-start seeds, mutashābihāt difficulty bumps, and the daily load balancer are Hifz-specific policy layered *on top of* that one deterministic update path — they are not FSRS, and no off-the-shelf scheduler has them.

### Rationale

- **FSRS is open, MIT-licensed, and reimplementable with zero runtime dependency.** The reference repo, py-fsrs, ts-fsrs, rs-fsrs, and dart-fsrs are all MIT; there is no patent, no service, and no SDK to call ([open-spaced-repetition: FSRS](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler); [dart-fsrs](https://github.com/open-spaced-repetition/dart-fsrs)). For a *ṣadaqah*, offline app we can vendor the equations with no network and no licensing risk — exactly the README's "no AI — local arithmetic only" value.
- **FSRS is the most accurate open SR algorithm benchmarked**, which justifies it as the backbone over SM-2's fixed ease ratios: on the open `srs-benchmark` (~349.9M reviews / 9,999 collections), FSRS-6 scores log-loss 0.3460 / RMSE(bins) 0.0653 and FSRS-4.5 scores 0.3624 / 0.0764, each generation strictly improving on the last and all beating classic SM-2 ([srs-benchmark](https://github.com/open-spaced-repetition/srs-benchmark)).
- **The `fsrs` pub package is not drop-in for us.** dart-fsrs's `Card` is a *flashcard* with Learning / Review / Relearning states and minute-level learning steps, it ports py-fsrs, and it pulls a wall-clock `DateTime.now()` internally ([dart-fsrs](https://github.com/open-spaced-repetition/dart-fsrs)). Our card is a muṣḥaf page with an injected `today` and no minute timers. Owning the arithmetic is what makes the engine "pure Dart, zero I/O, deterministic" ([PRD §19.3](../PRD.md)) and lets us insert the trust clamp inside the one update path.
- **The scheduling core is tiny and side-effect-free.** The curve, interval, two stability branches, and one difficulty update are the self-contained, dependency-free function set Borretti demonstrates in ~100 lines with `elapsed_days` passed in — nothing touches I/O, a clock, or randomness once fuzz is off ([Borretti, "Implementing FSRS in 100 Lines," 2025](https://borretti.me/article/implementing-fsrs-in-100-lines)).

### Specification

The engine package exposes one stateless façade. Every method is a pure function of its arguments and the injected `today`; none reads a clock or a database.

```dart
// engine/  — pure Dart, no flutter import, no I/O, no DateTime.now(), no Random
library hifz_engine;

/// The single public surface. Construct once with immutable config; call freely.
class SchedulingEngine {
  SchedulingEngine(this.config)
      : assert(config.weights.length == kFsrsWeightCount); // §8 — length guard

  final EngineConfig config;

  /// Apply one graded review to a card. Pure: (card, grade, today) -> new card.
  Card onReview(Card card, ReviewInput review, SerialDay today);

  /// Seed a fresh card from a cold-start self-assessment. Pure. (§5)
  Card coldStartCard(int pageId, JuzConfidence confidence, SerialDay today,
      {SerialDay? memorizedOn});

  /// Build today's ordered, budget-capped day plan. Pure: (cards, today) -> plan. (§7)
  DayPlan buildToday(List<Card> cards, SerialDay today);
}
```

`SerialDay` is the proleptic-Gregorian serial-day integer owned by [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md). The engine never constructs a `DateTime`; "elapsed days" is `today.value - card.lastReview.value`, plain integer subtraction, which is immune to the DST "+1 day ≠ +24h" off-by-one that a `DateTime`-based engine would carry ([Dart: DateTime class](https://api.dart.dev/dart-core/DateTime-class.html)).

### Pitfalls / what we refuse

- **We refuse a runtime dependency on `fsrs` (dart-fsrs).** Its flashcard `Card`, learning-step minute timers, and internal `DateTime.now()` are at odds with the page-card model and the injected-`today` determinism requirement ([PRD §7.12, §19.3](../PRD.md); [dart-fsrs](https://github.com/open-spaced-repetition/dart-fsrs)). We read it as a cross-check oracle in tests (§8), never link it.
- **We refuse to ship the optimizer.** FSRS's weight-training code needs PyTorch / Burn and per-user review logs; we ship no telemetry, so there is nothing to train on and nothing to train with. The engine *uses* a fixed weight vector; it never *fits* one. The scheduler-vs-optimizer split is consistent across the FSRS ecosystem ([awesome-fsrs](https://github.com/open-spaced-repetition/awesome-fsrs)).
- **We refuse magic numbers.** `0.2346` never appears literally; `FACTOR` is *computed* from `DECAY` so the FSRS-6 upgrade is a one-line change (§8).

---

## 2. Data model: the page card and its derived line overlay

### Decision

**One card is one muṣḥaf page** — 604 scheduled cards for the standard Madani muṣḥaf ([PRD §7.1, §7.2](../PRD.md)). Sub-page (line) state is a **derived overlay**, created *lazily* only for a page that repeatedly lapses, used solely to (a) localize a weak spot and (b) seed mutashābihāt links — never as a second scheduling granularity. The card's `unit` is a parameter, not a hardcode, so a non-15-line layout can plug in later (R2).

### Rationale

- **Huffaz recite in flow.** A whole page is recited in one breath-chain; you cannot "show" line 4 without lines 1–3 as the running cue, because serial recall is order-dependent and chained ([RESEARCH-FINDINGS §3](../../research/RESEARCH-FINDINGS.md)). Scheduling the page matches recitation and keeps the card count comprehensible (604, not 6,236 ayāt or ~9,000 lines).
- **But a page is lumpy.** A ḥāfiẓ may own 13 lines and stumble on 2. Modeling page-level D/S for scheduling *plus* a per-line weak-spot overlay for diagnosis means "the page carries the schedule, the line carries the diagnosis" ([RESEARCH-FINDINGS §7](../../research/RESEARCH-FINDINGS.md)) — a clean failure does not lengthen an interval that hides two rotting lines.
- **Lazy line-blocks keep the model cheap.** We do not carry thousands of fragments for the 95% of pages that are fine; a `line_block` is created only when a page repeatedly breaks ([PRD §7.1, §10.2](../PRD.md)).

### Specification

The engine's value types mirror the `card` and `review_log` schema in [05-persistence-and-encryption.md §2](05-persistence-and-encryption.md) but carry no persistence concerns. `D`, `S`, `track`, and the audit fields are exactly [PRD §7.2](../PRD.md).

```dart
enum Track { unmemorized, near, far, newLesson } // NEW | NEAR | FAR | UNMEMORIZED
enum Grade { again, hard, good, easy }            // FSRS G ∈ {1,2,3,4} — §4
enum Source { self_, teacher }                     // sourceConfidence: self 0.5, teacher 1.0

/// The scheduled unit. Immutable; onReview returns a new instance.
class Card {
  final int pageId;          // 1..604 — the scheduling key
  final Track track;
  final double d;            // Difficulty [1,10]
  final double s;            // Stability (days for R to fall to 0.9)
  final SerialDay? lastReview;
  final SerialDay dueAt;     // next-due CEILING — NEVER null for a memorized card
  final int reps;
  final int lapses;
  final bool weakFlag;
  final int signoffs;        // teacher sign-offs counted toward graduation
  final bool manualLock;     // teacher pinned this page into a track
  final bool prayerCritical; // Fātiḥa, last juz, Mulk, Kahf, Yāsīn, … → higher floor
  // line overlay is held separately (lazily) and referenced by pageId.
}

/// Normalized grading signal from the recite flow (PRD §8). Same shape, all sources.
class ReviewInput {
  final Grade grade;
  final List<int> errorLines;   // 1-based line indices the user stumbled on; may be empty
  final Source source;
  final bool missedOrAlteredWord; // sacred-text guard: forces grade ≤ Hard — §4
}
```

The invariant `dueAt != null` for every memorized card (`track != unmemorized`) is the data-model expression of "nothing decays silently": a memorized page without a ceiling date is unrepresentable. This is asserted at construction and property-tested (§8).

### Pitfalls / what we refuse

- **We refuse ayah- or word-level scheduling.** Carding individual verses breaks the serial-recall cue chain and explodes the queue to an infeasible 6,236 cards ([RESEARCH-FINDINGS §3](../../research/RESEARCH-FINDINGS.md)). The line overlay is *diagnosis only*; the scheduler mutates the page and nothing finer.
- **We refuse a nullable `due_at` on a memorized card.** A page with `track != unmemorized` and `dueAt == null` would be a page with no ceiling — silently droppable. The constructor rejects it.
- **We refuse to roll page health up into stored state.** Per-juz / per-ḥizb health is computed from `card` retrievability with a min-leaning aggregate ([PRD §10.3](../PRD.md)), never persisted as a competing authority.

---

## 3. The forgetting curve and the interval

### Decision

The memory model is **FSRS-4.5's power-law forgetting curve** with `DECAY = -0.5` and `FACTOR = 19/81`, and intervals are the **closed-form inversion** of that curve to a target retention. Both `DECAY` and `FACTOR` are named constants in one place, with `FACTOR` *computed* from `DECAY` (*Decision log: Scheduling engine*).

### Rationale

- **The constants are the published FSRS-4.5 form, verbatim.** The algorithm wiki states `R(t,S) = (1 + FACTOR · t/S)^DECAY`, `DECAY = -0.5`, `FACTOR = 19/81`, defined so `R(S,S) = 0.9` ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)); py-fsrs repeats `FACTOR = 0.9^(1/DECAY) − 1` as a module constant ([py-fsrs DeepWiki](https://deepwiki.com/open-spaced-repetition/py-fsrs/5-the-fsrs-algorithm)). The PRD §7.3 already hard-codes exactly these, so the engine is aligned to the published curve by construction.
- **The interval is closed-form, so the retention/cost tradeoff is computable, not guessed.** From the same wiki, `I(r,S) = (S/FACTOR) · (r^(1/DECAY) − 1)` ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)). At `DECAY = -0.5` this gives `I = S` exactly when `r = 0.9`, and shrinks by a fixed multiplier as `r` rises — the basis of stakes-tiered retention (§5).
- **Two properties make this curve right for hifz.** Stability *compounds* multiplicatively, so each on-time review roughly multiplies the safe interval (why old juz can land on a monthly manzil); and the `e^{w10·(1−R)}` term in the stability update encodes the spacing / desirable-difficulty effect — reviewing when R is lower yields a larger stability gain ([RESEARCH-FINDINGS §3](../../research/RESEARCH-FINDINGS.md)).
- **The accuracy figures are flashcard-recognition, not hifz.** We carry this honestly: FSRS is the right mathematical *backbone*, not a validated hifz model — which is why the §6 trust clamp, not the probability target, is the real guarantee ([research/fsrs-and-sr-implementations.md §5.2](research/fsrs-and-sr-implementations.md)).

### Specification

```dart
import 'dart:math';

/// FSRS-4.5 curve constants — the ONLY place these live. §8 keeps them swappable.
const double kDecay = -0.5;
final double kFactor = pow(0.9, 1 / kDecay) - 1; // = 19/81 ≈ 0.23456790…

/// Retrievability: probability of recall after [elapsedDays] given stability [s].
/// R(t,S) = (1 + FACTOR·t/S)^DECAY ;  R(S,S) = 0.9 by definition of FACTOR.
double retrievability(int elapsedDays, double s) =>
    pow(1 + kFactor * elapsedDays / s, kDecay).toDouble();

/// Days until R falls to [targetR]. Closed-form inverse of the curve. NEVER fuzzed.
/// I(r,S) = (S/FACTOR)·(r^(1/DECAY) − 1) ;  I(S, 0.9) = S.
int interval(double s, double targetR) =>
    ((s / kFactor) * (pow(targetR, 1 / kDecay) - 1)).round().clamp(1, kMaxInterval);
```

The closed form means the per-page cost of each retention tier is exact arithmetic, not a fitted estimate. Because `DECAY = -0.5`, every interval is a pure multiple of the `r = 0.90` interval (`I₀.₉ = S`):

| Target retention `r` | Interval as multiple of S | ≈ review-frequency vs 0.90 | PRD §7.5 phase |
|---|---|---|---|
| 0.90 | 1.000 · S | 1.0× (baseline) | New (cheap re-exposure) |
| 0.94 | 0.567 · S | ~1.8× | Near |
| 0.95 | 0.448 · S | ~2.2× | Far (ordinary) |
| 0.97 | 0.266 · S | ~3.8× | Far prayer-critical / weak |
| 0.99 | 0.087 · S | ~11.5× | (deliberately avoided globally) |

These multipliers are directly computable inside the engine, so a future Progress screen could honestly show the load cost of any tier; they also reproduce the PRD §7.5 caution that "0.99 everywhere is ~11× the 0.90 workload — infeasible for 604 pages" ([Expertium, Retention](https://expertium.github.io/Retention.html)).

### Pitfalls / what we refuse

- **We refuse interval fuzzing.** Every reference scheduler adds random fuzz to long intervals by default (`enableFuzzing: true` in dart-fsrs), making a 50-day interval land at 49–51 — identical inputs produce *different* schedules ([dart-fsrs](https://github.com/open-spaced-repetition/dart-fsrs)). That breaks the §7.12 "identical inputs → identical schedule" invariant, so fuzzing is off. Any due-date declumping happens in our own `loadBalance` peak-smoothing (§7), where it is testable and bounded by the cycle ceiling — never via hidden RNG.
- **We refuse FSRS's "optimal retention."** FSRS can simulate load to find the workload-minimizing retention ([fsrs4anki: The optimal retention](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention)); for sacred text the target is set by *stakes*, not workload-minimization, so we override it and tier by sacredness (§5).
- **We refuse to let the probability target *be* the guarantee.** The curve is a prior; "nothing rots" comes from the §6 clamp.

---

## 4. The review update: lapse vs success, and the sacred-text guard

### Decision

On every graded review the engine runs **one deterministic update path** ([PRD §7.7](../PRD.md)): the FSRS difficulty and stability update, scaled by source confidence, with two Hifz-specific guards — a **sacred-text guard** that caps the grade when a word was missed or altered, and a **weak-line difficulty channel** that absorbs interference and localized weakness without a parallel scheduler.

### Rationale

- **The S and D formulas are the published FSRS forms.** Stability on a successful review: `S'_r = S · (1 + e^{w8} · (11−D) · S^{−w9} · (e^{w10·(1−R)} − 1) · hard · easy)`; post-lapse stability: `S'_f = w11 · D^{−w12} · ((S+1)^{w13} − 1) · e^{w14·(1−R)}`, with FSRS clamping `S'_f ≤ S` so a lapse never grows stability; difficulty mean-reverts toward the "Good" anchor ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm); [Expertium](https://expertium.github.io/Algorithm.html)). This is precisely the PRD §7.7 lapse/success branches expressed with FSRS's fitted form.
- **The `(11−D)` factor is the interference channel for free.** Higher difficulty → smaller stability gain → shorter interval. So raising a mutashābihāt-confused page's `D` automatically shortens its interval *through the same equation* — no special-case scheduler ([RESEARCH-FINDINGS §3](../../research/RESEARCH-FINDINGS.md); [research/fsrs-and-sr-implementations.md §6](research/fsrs-and-sr-implementations.md)). This keeps the interference subsystem inside the one golden-tested update path.
- **A dropped or altered word in sacred text is never "Good."** This is the engineering expression of R1: the recite flow's error positions can only *lower* a self-rated grade, never raise it ([PRD §7.7, §8.3](../PRD.md)).
- **Self-rating is noisy, so it moves state less.** Teacher sign-off (`sourceConfidence = 1.0`) is the *sanad*-respecting ground truth; self-rating (`≈ 0.5`) scales the *applied stability gain* down so an over-generous self-grade cannot vault a page to a long interval ([PRD §8.1, §8.2](../PRD.md)). The grade-to-G map (Again 1, Hard 2, Good 3, Easy 4) is exactly dart-fsrs's `Rating` ([dart-fsrs](https://github.com/open-spaced-repetition/dart-fsrs)).
- **The same-day sub-model (w17–w18) is out of scope.** Those two weights are FSRS-5's short-term stability adjustment for multiple reviews within one day; maintenance reviews a page at most once per day, so that sub-model and the `learningSteps`/`relearningSteps` minute timers are omitted — which removes the only clock-sensitive code path and reinforces determinism ([Expertium](https://expertium.github.io/Algorithm.html); [research/fsrs-and-sr-implementations.md §3.4, §7](research/fsrs-and-sr-implementations.md)).

### Specification

The two stability branches and the difficulty update, as pure functions of their arguments (`w` is the stored weight vector — §8):

```dart
/// Stability after a SUCCESSFUL review (G ≥ Good). FSRS S'_r.
/// hard = w[15] when grade == Hard else 1.0 ; easy = w[16] when grade == Easy else 1.0.
double stabilityOnSuccess(double d, double s, double r, double hard, double easy) =>
    s * (1 + exp(w[8]) * (11 - d) * pow(s, -w[9]) *
        (exp(w[10] * (1 - r)) - 1) * hard * easy);

/// Stability after a LAPSE (G == Again). FSRS S'_f, clamped so a lapse never grows S.
double postLapseStability(double d, double s, double r) {
  final sf = w[11] * pow(d, -w[12]) * (pow(s + 1, w[13]) - 1) * exp(w[14] * (1 - r));
  return min(sf.toDouble(), s).clamp(kMinStability, double.infinity);
}

/// Difficulty mean-reverts toward the "Good" anchor D0(3). FSRS D'.
double nextDifficulty(double d, Grade g) {
  final deltaD = -w[6] * (g.index + 1 - 3);          // g.index+1 = G ∈ {1..4}
  final dPrime = d + deltaD * (10 - d) / 9;            // linear-damping form
  final reverted = w[7] * initialDifficulty(Grade.good) + (1 - w[7]) * dPrime;
  return reverted.clamp(1.0, 10.0);
}
```

The full review update, applying the sacred-text guard, source confidence, the lapse/success split, the weak-line difficulty channel, and the §6 trust clamp in order ([PRD §7.7](../PRD.md)):

```dart
Card onReview(Card card, ReviewInput rv, SerialDay today) {
  final elapsed = card.lastReview == null ? 0 : today.value - card.lastReview!.value;
  final r = elapsed == 0 ? 1.0 : retrievability(elapsed, card.s);

  // Sacred-text guard: a missed/added/swapped word is NEVER "Good".  R1.
  var grade = rv.missedOrAlteredWord && rv.grade.index > Grade.hard.index
      ? Grade.hard
      : rv.grade;

  final conf = rv.source == Source.teacher ? 1.0 : kSelfConfidence; // 1.0 vs 0.5
  double d = nextDifficulty(card.d, grade);
  double s;
  int lapses = card.lapses;
  bool weak = card.weakFlag;

  if (grade == Grade.again) {                         // ---- lapse branch ----
    lapses += 1;
    d = (d + kLapseDifficultyBump).clamp(1.0, 10.0);  // PRD §7.7: D += ~1.0
    s = postLapseStability(card.d, card.s, r);
    weak = true;                                       // maybeSplitIntoLineBlocks() in /data
  } else {                                            // ---- success branch ----
    final hard = grade == Grade.hard ? w[15] : 1.0;
    final easy = grade == Grade.easy ? w[16] : 1.0;
    final raw = stabilityOnSuccess(card.d, card.s, r, hard, easy);
    final gain = (raw - card.s) * conf;               // noisy self-rating moves S LESS
    s = card.s + gain;
    if ((grade == Grade.good || grade == Grade.easy) && rv.errorLines.isEmpty) {
      weak = false;
    }
  }

  // Weak-line difficulty channel: each chronically weak line bumps D, which the
  // (11−D) factor turns into a shorter interval automatically. PRD §7.7, §9.2.
  d = (d + kWeakLineFactor * weakLineCount(card.pageId)).clamp(1.0, 10.0);

  var next = card.copyWith(
    d: d, s: max(s, kMinStability), lastReview: today,
    reps: card.reps + 1, lapses: lapses, weakFlag: weak,
  );
  next = updateGraduation(next, grade, rv.source);    // §5 — sign-off gated, predictable
  return next.copyWith(dueAt: trustClamp(next, today)); // §6 — the guarantee
}
```

A worked trace appears in the test vectors (§8). Note that `errorLines` (localization) and any confusion-edge updates are applied at **full strength regardless of source** — even a self-reported "I swapped these two" is valuable graph data; only the *magnitude of the S move* is confidence-scaled ([RESEARCH-FINDINGS §7](../../research/RESEARCH-FINDINGS.md)).

### Pitfalls / what we refuse

- **We refuse Leitner-style all-or-nothing demotion.** A single stumbled line must not reset an otherwise-solid page to box 1; the graded, position-aware signal feeds a continuous stability update so one weak line does not nuke 14 good ones ([RESEARCH-FINDINGS §3](../../research/RESEARCH-FINDINGS.md)).
- **We refuse to let self-rating reach the top tier alone.** Self-rated `Good` moves S less, and a page cannot enter the highest prayer-critical retention tier without at least one teacher sign-off ([PRD §8.1](../PRD.md)).
- **We refuse to grow stability on a lapse.** `postLapseStability` is clamped `≤ S`; a forgotten page never gets a *longer* interval than it had ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)).
- **We refuse same-day minute scheduling.** No `learningSteps`, no `Duration`-from-now timers; the active-memorizer NEW track is a repeat-until-sign-off loop (§7), not FSRS learning steps.

---

## 5. Phases, graduation, stakes-tiered retention, and cold start

### Decision

The three traditional tracks are **not three algorithms** — they are **three lifecycle phases of one page card**, derived from the card's stability band ([PRD §6.2, §7.4](../PRD.md)). Graduation is **age-and-rating driven, predictable, and sign-off gated** (a teacher can anticipate it), never a hidden FSRS jump. Each phase carries its own **stakes-tiered retention target**. A new ḥāfiẓ is onboarded by **seeding conservative priors and converging on real grades** — no calibration grind.

### Rationale

- **The tradition's tracks are empirical approximations of one forgetting process at different stability ranges.** Modeling them as one DSR card removes the hand-off ambiguity that plagues separate-queue trackers ("when *exactly* does a page leave sabqi?") — the answer is a continuous `S` value, not a hand-maintained calendar ([RESEARCH-FINDINGS §7](../../research/RESEARCH-FINDINGS.md)). Huffaz still *see* three labeled buckets; the engine has one source of truth.
- **Graduation must be predictable to a teacher.** New → Near also requires *N* sign-offs; Near → Far requires crossing `FAR_MIN_S` *and* falling outside the recent-juz window. A lapse shrinks S and naturally demotes the card — "a forgotten manzil page rejoins active revision," exactly the tradition ([PRD §7.4](../PRD.md)). `manualLock` lets a teacher pin a page regardless of the math ([PRD §7.2, §7.4](../PRD.md)).
- **Retention is tiered by stakes, never global.** New 0.90 (cheap re-exposure while building) → Near 0.94 → Far 0.95 ordinary, **0.97+ for prayer-critical / weak / previously-lapsed pages** ([PRD §7.5](../PRD.md)). Reserving high R for mature pages (large S) makes near-100% retention bounded and affordable, instead of the infeasible ~11× load of a global 0.99 (§3 table).
- **Cold start seeds priors, it does not fake precision.** Nobody can grade 604 pages on day one and there is no history, so the user marks coverage (fast juz-level taps), rates each held juz Solid / Shaky / Rusty, and the engine seeds initial (D, S); priors deliberately *under*-estimate strength so the first real recitation can only surprise upward ([PRD §7.10](../PRD.md)). This is the hand-set version of FSRS's own `S₀(G) = w_{G-1}` initial-stability shape ([research/fsrs-and-sr-implementations.md §3.1](research/fsrs-and-sr-implementations.md)). Real grades dominate within ~2–3 weeks.

### Specification

Phase is a pure function of stability and state ([PRD §7.4](../PRD.md)):

```dart
const double kNearMinS = 9.0;   // < 9 days  → still solidifying (NEW)
const double kFarMinS  = 60.0;  // ≥ 60 days → maintenance bulk (FAR)

Track phaseOf(Card c) {
  if (c.track == Track.unmemorized) return Track.unmemorized;
  if (c.manualLock) return c.track;                 // teacher pin wins over the math
  if (c.s < kNearMinS) return Track.newLesson;      // still solidifying
  if (c.s < kFarMinS) return Track.near;
  return Track.far;
}

/// Stakes-tiered retention target. Far escalates for prayer-critical / weak / lapsed.
double targetR(Card c) {
  switch (phaseOf(c)) {
    case Track.newLesson:   return 0.90;
    case Track.near:        return 0.94;
    case Track.far:
      return (c.prayerCritical || c.weakFlag || c.lapses > 0) ? 0.97 : 0.95;
    case Track.unmemorized: return 0.95; // unreachable; defensive default
  }
}
```

Cold-start seeds, conservative by design ([PRD §7.10](../PRD.md)):

| Per-juz confidence | Seed `D` | Seed `S` (days) | Enters phase |
|---|---|---|---|
| **Solid** | 3 | 60 | FAR / manzil |
| **Shaky** | 5 | 14 | NEAR |
| **Rusty** | 7 | 4 | active revision (NEW/NEAR) |

```dart
const _coldStartSeed = {
  JuzConfidence.solid: (d: 3.0, s: 60.0),
  JuzConfidence.shaky: (d: 5.0, s: 14.0),
  JuzConfidence.rusty: (d: 7.0, s: 4.0),
};

Card coldStartCard(int pageId, JuzConfidence c, SerialDay today, {SerialDay? memorizedOn}) {
  final seed = _coldStartSeed[c]!;
  var s = seed.s;
  // Optional stale-time decay: if we know WHEN a juz was memorized, age S from that date
  // so a juz finished years ago is treated as needing reactivation. PRD §7.10 step 3.
  if (memorizedOn != null) {
    final ageDays = today.value - memorizedOn.value;
    // shrink S toward the prior implied by current retrievability at that age
    s = max(kMinStability, s * retrievability(ageDays, seed.s) / 0.9);
  }
  final card = Card.memorized(
    pageId: pageId, track: phaseOfSeed(s), d: seed.d, s: s, lastReview: today, reps: 0,
  );
  // Calibration: every held page is due now so the first weeks review each once. §7.10 step 5.
  return card.copyWith(dueAt: today);
}
```

### Pitfalls / what we refuse

- **We refuse three parallel algorithms.** Separate sabaq/sabqi/manzil engines reintroduce the hand-off bugs that plague Al-Muhaffiz-style trackers; there is one card, one update path, one source of truth ([RESEARCH-FINDINGS §7](../../research/RESEARCH-FINDINGS.md)).
- **We refuse a hidden graduation jump.** Graduation is gated on stability *and* sign-offs *and* the recent-juz window; a teacher must be able to predict it ([PRD §7.4](../PRD.md)).
- **We refuse a global 0.99.** It is ~11× the 0.90 workload across 604 pages — infeasible within any daily budget (§3); high R is reserved for stakes ([PRD §7.5](../PRD.md)).
- **We refuse optimistic cold-start priors.** Under-estimating strength means the first recitation can only surprise upward; over-estimating risks silently skipping a page the user has actually lost ([PRD §7.10](../PRD.md)).

---

## 6. The trust clamp — the whole engine in one rule

### Decision

On every review the engine computes the SR-ideal next interval, then **clamps it to the user's chosen cycle ceiling**: `due_at = min(ideal_due, ceiling_due)` ([PRD §6.1, §7.6](../PRD.md)). The algorithm's *only* freedom is to pull a page **forward**; it can never let a page drift past the cycle. This is the README's second outranking rule, in code.

### Rationale

- **This is the product's covenant.** Every page is *guaranteed* to be re-recited at least once per chosen cycle (every 7 or 30 days, etc.), no matter what the math computes ([PRD §7.6, §7.12](../PRD.md)). The FSRS curve is trained on flashcard recognition, not hifz, so we never let it *be* the guarantee — the ceiling is ([research/fsrs-and-sr-implementations.md §5.2](research/fsrs-and-sr-implementations.md)).
- **It reproduces the 7-manzil / 30-juz tradition as a hard floor, not a hope.** With a Far target near 0.95–0.97 and grown S, each page's natural interval already lands in the weeks-to-month range; the cycle preset acts as a *ceiling* on that interval so the schedule can never drift looser than the user's spiritual comfort allows ([RESEARCH-FINDINGS §7](../../research/RESEARCH-FINDINGS.md); [PRD §15.1](../PRD.md)).
- **Pure-cycle mode is the conservative limit.** For maximally traditional users/ulama who distrust any reordering, a setting runs fixed-rotation only — SR ordering off, zero pull-forward — and the app becomes a faithful tracker with smart load-balancing and catch-up, nothing more ([PRD §7.11](../PRD.md)). The clamp is the mechanism that makes this a one-flag change.

### Specification

```dart
SerialDay trustClamp(Card card, SerialDay today) {
  final idealDue = today.addDays(interval(card.s, targetR(card)));      // what the math wants
  final ceilingDue = today.addDays(cycleCeilingDays(card, config));     // what tradition promises
  // SR may only make a page MORE frequent: take the EARLIER of the two.
  return idealDue.value <= ceilingDue.value ? idealDue : ceilingDue;
}

/// The per-card ceiling, from the chosen named cycle (PRD §15.1) and the page's track.
int cycleCeilingDays(Card card, EngineConfig config) {
  if (config.pureCycleMode) return config.farCycleDays;   // §7.11: fixed rotation only
  switch (phaseOf(card)) {
    case Track.far:  return config.farCycleDays;           // e.g. 7 (weekly khatm) or 30
    case Track.near: return config.nearCeilingDays;        // recent-juz window cap
    default:         return config.farCycleDays;           // never longer than the far cycle
  }
}
```

The clamp is the single most-tested line in the engine. The property "for every memorized card, after `onReview`, `card.dueAt.value − today.value ≤ cycleCeilingDays(card, config)`" is an invariant checked exhaustively by `glados` (§8).

### Pitfalls / what we refuse

- **We refuse `max` where `min` belongs.** `due_at = max(...)` would let the math push a page *past* its ceiling — the exact silent-decay failure the product exists to prevent. The clamp takes the *earlier* date, always.
- **We refuse a ceiling that depends on anything non-deterministic.** `cycleCeilingDays` is a pure function of the card and the config; no clock, no profile lookup, no I/O.
- **We refuse to ever exempt a page from the ceiling** — not for performance, not for budget, not for "this juz is clearly solid." A memorized page without a ceiling does not exist in this engine.
- **We refuse to tell a ḥāfiẓ a page is "safe to drop."** No code path lengthens a ceiling to infinity, marks a page as retired, or surfaces such a suggestion ([PRD §7.12](../PRD.md)).

---

## 7. Building the day: visible tradition, invisible ordering

### Decision

The daily plan is **assembled by tradition and ordered by SR** ([PRD §7.8, §7.9](../PRD.md)): the chosen cycle defines the *shape* of the day (which Far/manzil pages are covered today), SR only *orders* within that shape and *pulls weak pages forward*, mutashābihāt siblings are *interleaved into the same session*, and a **load balancer** fits the day into the user's time budget — deferring safely, never silently dropping manzil, and **re-spreading after missed days** instead of dumping a red overdue pile.

### Rationale

- **Manzil is un-skippable.** Dropping dhor is the documented #1 cause of loss, so Far/manzil due items are mandatory — the balancer may defer Near and reduce New, but never drop manzil ([PRD §7.9, §7.12](../PRD.md); [RESEARCH-FINDINGS §1](../../research/RESEARCH-FINDINGS.md)).
- **Old before new.** Recitation order is manzil → near → new, exactly as the day is recited aloud to a teacher ([PRD §7.8](../PRD.md); [RESEARCH-FINDINGS §1](../../research/RESEARCH-FINDINGS.md)).
- **Interference is cured by massing, not spacing.** When a page in a mutashābihāt group is due, its sibling(s) are pulled into the *same* session back-to-back so the brain practices discrimination; spacing them apart worsens confusion ([PRD §9.2](../PRD.md); [RESEARCH-FINDINGS §3](../../research/RESEARCH-FINDINGS.md)). This is the one place the engine *adds* a not-yet-due card — and it is additive contrast, never a dropped review.
- **Missed-day catch-up is a headline feature, not an edge case.** After a gap the engine re-flows the backlog over several days, most-decayed and prayer-critical first — "you missed 3 days; here is a 5-day catch-up plan that still completes your cycle" — directly fixing the "overwhelming pile" complaint that kills competitor apps ([PRD §7.9](../PRD.md); [RESEARCH-FINDINGS §2](../../research/RESEARCH-FINDINGS.md)).
- **Peak smoothing lives here, not in RNG.** Declumping due dates is bounded `±1–2 days` within the ceiling for above-floor pages — testable and explicit, the deterministic replacement for FSRS's interval fuzz (§3) ([PRD §7.9](../PRD.md)).

### Specification

```dart
DayPlan buildToday(List<Card> cards, SerialDay today) {
  final memorized = cards.where((c) => c.track != Track.unmemorized).toList();
  // R is recomputed per card; no clock, today is injected.
  double rOf(Card c) =>
      c.lastReview == null ? 1.0 : retrievability(today.value - c.lastReview!.value, c.s);

  // FAR (manzil): the cycle guarantees full coverage; SR only orders + pulls forward.
  final far = memorized.where((c) => phaseOf(c) == Track.far).toList();
  final cycleSlice = farCycleSliceForToday(far, today, config);   // tradition: e.g. 1 juz
  final pullFwd = far.where((c) =>
      rOf(c) < retentionFloor(c) && !cycleSlice.contains(c)).toList();
  final farToday = expandMutashabihat(
      sortByWeakestR([...cycleSlice, ...pullFwd], rOf));

  // NEAR: literal recent-juz window, weakest-first.
  final nearToday = sortByWeakestR(
      memorized.where((c) =>
          phaseOf(c) == Track.near && inRecentWindow(c, config)).toList(), rOf);

  // NEW: today's + yesterday's sabaq, repeated to sign-off (active memorizers only).
  final newToday = sabaqLines(config.newLinesPerDay);

  // Recited OLD before NEW: manzil → near → new.
  final day = [...farToday, ...nearToday, ...newToday];
  return loadBalance(day, config.dailyBudgetMinutes, today, rOf);
}
```

The load balancer, with mandatory manzil, urgency-ordered Near, safe deferral above a hard floor, and graceful catch-up ([PRD §7.9](../PRD.md)):

```dart
DayPlan loadBalance(List<Card> day, int budgetMin, SerialDay today, double Function(Card) rOf) {
  var budget = budgetMin;
  final scheduled = <Card>[];

  // 1. FAR/manzil due items are MANDATORY — schedule even if they overflow → gentle warn.
  for (final c in day.where((c) => phaseOf(c) == Track.far)) {
    scheduled.add(c); budget -= estMinutes(c);
  }
  final overflow = budget < 0; // surfaced as a calm banner, never a drop. PRD §7.9

  // 2. NEAR by urgency (targetR − R, descending); defer low-urgency only above the floor.
  final near = day.where((c) => phaseOf(c) == Track.near).toList()
    ..sort((a, b) => (targetR(b) - rOf(b)).compareTo(targetR(a) - rOf(a)));
  for (final c in near) {
    if (estMinutes(c) <= budget) { scheduled.add(c); budget -= estMinutes(c); }
    else if (rOf(c) > kHardFloorR) { /* safe slip: defer within ceiling, ±1 day */ }
    else { scheduled.add(c); budget -= estMinutes(c); } // crossed floor → promote, cannot defer
  }

  // 3. NEW only if budget remains AND yesterday's sabaq is consolidated.
  // 4. Peak smoothing: nudge above-floor pages ±1–2 days within their ceiling to flatten spikes.
  return DayPlan(items: orderForRecitation(scheduled), budgetOverflow: overflow);
}
```

`const double kHardFloorR = 0.85;` — a Near page may slip a day only while its predicted R stays above this floor; a page crossing it is promoted to mandatory and can no longer be deferred ([PRD §7.9](../PRD.md)).

### Pitfalls / what we refuse

- **We refuse to drop a manzil due item to fit the budget.** When mandatory manzil overflows the budget, the app surfaces an honest banner ("your scope needs ~X min/day; you've set Y" — raise budget / lengthen cycle / pause new sabaq) and never silently lets pages rot ([PRD §7.9, §12.2](../PRD.md)).
- **We refuse to dump a backlog.** After a gap the balancer re-spreads over N days, lowest-R and prayer-critical first — re-spread, never shame ([PRD §7.9](../PRD.md)).
- **We refuse to space mutashābihāt siblings apart.** For confusable pages, massed contrast in one session is the cure; the queue assembler pulls linked pages together even if not individually due ([PRD §9.2](../PRD.md)).
- **We refuse a guilt or shame surface.** No red overdue pile, no streak punishment; the plan is calm and finite ([PRD §12.2, R3](../PRD.md)).

---

## 8. Determinism, weights, and golden test vectors

### Decision

The engine is **deterministic by construction** — no clock, no RNG, no I/O, `today` injected — so identical inputs yield an identical schedule ([PRD §7.12](../PRD.md)). The FSRS weight vector and its version are **stored as data with a length assert**, never inlined as magic numbers. Correctness is pinned by **golden test vectors** and **`glados` property tests** that encode every §7.12 invariant ([11-testing-strategy.md](11-testing-strategy.md)).

### Rationale

- **The pure engine is the fastest, most stable test tier.** A pure-Dart package "contains pure business logic with no Flutter or framework dependencies, making it the easiest layer to test" and runs on `dart test` without a widget binding ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages); [Flutter: unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)). Determinism makes golden fixtures meaningful — a drift in any formula fails CI.
- **Mixing weight-vector lengths silently corrupts every interval.** FSRS-4.5/5 ships 19 weights (`w0…w18`); FSRS-6 ships 21, adding `w19` (a stability-saturation term, role analogous to `w9`) and `w20` (the trainable curve decay, default 0.2 vs the fixed 0.5 we use) ([FSRS-6 PR #3929, ankitects/anki](https://github.com/ankitects/anki/pull/3929)). Feeding a 19-vector into 21-weight code, or vice versa, is a silent schedule-corrupting bug class, so the version and length are asserted at load ([Expertium](https://expertium.github.io/Algorithm.html); [research/fsrs-and-sr-implementations.md §4](research/fsrs-and-sr-implementations.md)).
- **FSRS-6 readiness costs one line.** Keeping `DECAY` and `FACTOR` as computed constants means adopting FSRS-6 later is `DECAY = -w[20]` with `FACTOR` re-derived — no structural change ([FSRS-6 PR #3929, ankitects/anki](https://github.com/ankitects/anki/pull/3929)).
- **The defaults are flashcard population averages, documented as such.** The FSRS-4.5 19-weight default is a published vector; we ship it as the prior but record that it is a flashcard average, not a hifz-fitted parameter set ([research/fsrs-and-sr-implementations.md §4.1, §4.3](research/fsrs-and-sr-implementations.md)).

### Specification

```dart
const int kFsrsWeightCount = 19;          // FSRS-4.5/5 ; 21 for FSRS-6 (decay = -w20)
const double kMinStability = 0.1;
const int kMaxInterval = 36500;           // ~100 years; matches reference clamps
const double kSelfConfidence = 0.5;       // teacher = 1.0  (PRD §8.1/§8.2)
const double kLapseDifficultyBump = 1.0;  // PRD §7.7
const double kWeakLineFactor = 0.15;      // per chronically-weak line, into D
const double kHardFloorR = 0.85;          // load-balance deferral floor (PRD §7.9)

/// Published FSRS-4.5 default weights. Shipped as the prior; flashcard averages, not hifz-fit.
const List<double> kDefaultWeights45 = [
  0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, 1.54575,
  0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, 2.9898, 0.51655, 0.6621,
]; // length asserted == kFsrsWeightCount at construction.
```

**Anchor golden vectors** — these are guaranteed by the FACTOR definition and pin the curve against any accidental edit ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)):

| Test | Input | Expected | Source of truth |
|---|---|---|---|
| Curve identity | `retrievability(10, 10.0)` | `0.9` (±1e-9) | `R(S,S) = 0.9` by FACTOR definition |
| Interval identity | `interval(10.0, 0.9)` | `10` | `I(S, 0.9) = S` at `DECAY = -0.5` |
| Tier multiplier | `interval(100.0, 0.95)` | `45` (≈ 0.448·S, rounded) | §3 closed-form multiplier |
| Tier multiplier | `interval(100.0, 0.97)` | `27` (≈ 0.266·S, rounded) | §3 closed-form multiplier |
| Lapse never grows | `postLapseStability(d,s,r) ≤ s` | always true | FSRS clamp `S'_f ≤ S` |

**Cross-check vector:** pin one full review sequence against `dart-fsrs` run with `enableFuzzing: false` and `kDefaultWeights45`, so any divergence in our copy of the S/D formulas fails CI — the engineering analogue of the PRD §20 gate "scheduler outputs match pinned fixtures" ([dart-fsrs](https://github.com/open-spaced-repetition/dart-fsrs)).

**Invariant property tests** (`glados`), each a §7.12 rule made executable:

```dart
// 1. The trust clamp holds for EVERY memorized card after EVERY review.
glados2(anyCard, anyReview).test('due_at never exceeds the cycle ceiling', (card, rv) {
  final out = engine.onReview(card, rv, today);
  expect(out.dueAt.value - today.value, lessThanOrEqualTo(cycleCeilingDays(out, config)));
});

// 2. A lapse demotes (never promotes) a card's stability.
glados2(anyMemorizedCard, anyLapse).test('Again shrinks S', (card, rv) {
  expect(engine.onReview(card, rv, today).s, lessThanOrEqualTo(card.s));
});

// 3. Determinism: identical inputs → byte-identical output.
glados2(anyCard, anyReview).test('onReview is pure', (card, rv) {
  expect(engine.onReview(card, rv, today), equals(engine.onReview(card, rv, today)));
});

// 4. The sacred-text guard: a missed/altered word never yields a Good/Easy outcome.
glados(anyCardWithWordError).test('dropped word is never Good', (rv) {
  expect(appliedGrade(rv).index, lessThanOrEqualTo(Grade.hard.index));
});

// 5. Manzil is never dropped from a built day.
glados(anyCardSet).test('FAR due items always appear in the plan', (cards) {
  final plan = engine.buildToday(cards, today);
  for (final c in cards.where(isFarDue)) { expect(plan.contains(c), isTrue); }
});
```

### Pitfalls / what we refuse

- **We refuse `DateTime.now()` or `Random` anywhere in `engine/`.** A CI banned-import / grep gate forbids both in the package, the same mechanism that bans networking imports (*Decision log: No networking beyond asset download*; [03-coding-standards.md](03-coding-standards.md)). `today` is always injected.
- **We refuse to inline the weight vector across the code.** It lives in one `const` (or loaded from `app_meta`), with `assert(weights.length == kFsrsWeightCount)` at construction; a 19-vs-21 mismatch must fail loudly, not silently mis-schedule.
- **We refuse fixtures generated by the engine under test.** Anchor vectors come from the FSRS definition (curve/interval identities) and from `dart-fsrs` as an independent oracle, so a fixture cannot "agree with a bug" ([11-testing-strategy.md](11-testing-strategy.md)).
- **We refuse to treat the probability target as validated for hifz.** Every "why FSRS" claim is paired with the caveat that these are flashcard-recognition results; the guarantee is the clamp ([research/fsrs-and-sr-implementations.md §5.2](research/fsrs-and-sr-implementations.md)).

---

## References

- Open Spaced Repetition. *Free Spaced Repetition Scheduler* (reference repo; DSR model; MIT license; reimplementable with no runtime dependency). https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler
- Open Spaced Repetition. *The Algorithm* (awesome-fsrs wiki) — power-law curve `R(t,S)=(1+FACTOR·t/S)^DECAY`, `DECAY=-0.5`, `FACTOR=19/81`; interval `I(r,S)=(S/FACTOR)(r^(1/DECAY)−1)`; `S₀(G)=w_{G-1}`, `D₀(G)=w₄−e^(w₅(G−1))+1`; stability-growth `S'_r` and post-lapse `S'_f` formulas. https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm
- Open Spaced Repetition. *py-fsrs (The FSRS Algorithm, DeepWiki)* — `FACTOR = 0.9^(1/DECAY) − 1`; `retrievability=(1+FACTOR·elapsed/stability)^DECAY`; `next_interval=(stability/FACTOR)(desired_retention^(1/DECAY)−1)` clamped `[1, maximum_interval]`. https://deepwiki.com/open-spaced-repetition/py-fsrs/5-the-fsrs-algorithm
- Open Spaced Repetition. *dart-fsrs* — Dart scheduler (MIT); `Scheduler/Card/Rating{Again,Hard,Good,Easy}/ReviewLog`; Learning/Review/Relearning card states; `enableFuzzing` default on (disable for determinism); "Port from py-fsrs@6fd0857". https://github.com/open-spaced-repetition/dart-fsrs
- Open Spaced Repetition. *awesome-fsrs* — implementation landscape by language; the scheduler-vs-optimizer split. https://github.com/open-spaced-repetition/awesome-fsrs
- Open Spaced Repetition. *srs-benchmark* — open benchmark (~349.9M reviews / 9,999 collections); FSRS-6 log-loss 0.3460 / RMSE(bins) 0.0653, FSRS-4.5 0.3624 / 0.0764; FSRS generations beat classic SM-2. https://github.com/open-spaced-repetition/srs-benchmark
- Open Spaced Repetition. *The optimal retention* (fsrs4anki wiki) — desired retention as the workload-vs-knowledge tradeoff (which hifz overrides with stakes-tiered targets). https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention
- Expertium. *A technical explanation of FSRS* — weight-group roles; same-day sub-model (w17–w19); FSRS-6 `w20` trainable decay; log-loss training; ~700M reviews / ~10k users. https://expertium.github.io/Algorithm.html
- Expertium. *Retention* — the retention/workload cost curve (raising desired retention multiplies review load). https://expertium.github.io/Retention.html
- ankitects/anki. *Feat/FSRS-6* (PR #3929) — FSRS-6 adds the 21st parameter (trainable decay); shipped in Anki since v25.07. https://github.com/ankitects/anki/pull/3929
- Borretti, F. (2025-01-10). *Implementing FSRS in 100 Lines* — deterministic minimal reference: `F=19/81`, `C=-0.5`; curve, interval, S/D updates; 19-weight default array. https://borretti.me/article/implementing-fsrs-in-100-lines
- Dart team. *DateTime class — dart:core* (instant, not date; no internationalization; adding a Duration is not adding calendar days across DST). https://api.dart.dev/dart-core/DateTime-class.html
- Flutter (Google). *Developing packages & plugins* (a pure-Dart package has no framework dependency and is the easiest layer to test). https://docs.flutter.dev/packages-and-plugins/developing-packages
- Flutter (Google). *An introduction to unit testing.* https://docs.flutter.dev/cookbook/testing/unit/introduction
- Hifz Companion. *Engineering README — tech-decision log* (Decision 4: Scheduling engine). [README.md](README.md)
- Hifz Companion. *FSRS in Practice — research note.* [research/fsrs-and-sr-implementations.md](research/fsrs-and-sr-implementations.md)
- Hifz Companion. *Product Requirements Document* (§6–§10 domain model, engine, schema). [PRD.md](../PRD.md)
- Hifz Companion. *Deep Research Findings* (§1 methodology, §3 SR science, §7/§8 engine designs). [RESEARCH-FINDINGS.md](../../research/RESEARCH-FINDINGS.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
