# references — domain-scheduling-engine-rules

The precise governing sections. Reference these by number in code review and commit messages; never re-state a constant or invent a number here.

## Primary engine spec

`docs/engineering/06-scheduling-engine.md`

- **§1 Vendored FSRS arithmetic, not a dependency** — the engine is pure Dart, zero I/O: no Flutter import, no `DateTime.now()`, no `Random`, no DB; `today` is an injected `SerialDay`. One stateless façade `SchedulingEngine(config)` with `onReview` / `coldStartCard` / `buildToday`. dart-fsrs is a test-only cross-check oracle, never a runtime dependency. Take: what `engine/` may and may not touch, and the façade signatures.
- **§2 The page card and its derived line overlay** — one card = one muṣḥaf page (604 cards); line state is a *lazy* diagnosis-only overlay, never a second scheduling granularity; a memorized card's `dueAt` is never null (asserted at construction). Take: the `Card` / `ReviewInput` value types and the no-null-`dueAt` invariant.
- **§3 The forgetting curve and the interval** — `kDecay = -0.5`, `kFactor = pow(0.9, 1/kDecay) - 1` (= 19/81) in one place, `R(S,S)=0.9`; interval is the closed-form inverse `(s/kFactor)·(targetR^(1/kDecay)−1)` clamped `[1, kMaxInterval]`, **never fuzzed**; the tier-multiplier table (0.448·S at 0.95, 0.266·S at 0.97, ~11× at 0.99). Take: the two formulas, the single-place constants, and the no-fuzz rule.
- **§4 The review update: lapse vs success, and the sacred-text guard** — one deterministic path: `nextDifficulty`, `stabilityOnSuccess`, `postLapseStability` (clamped `≤ S`); the sacred-text guard caps grade at `Hard` on a missed/altered word; `kSelfConfidence` (0.5) scales the applied S gain vs teacher 1.0; the `(11−D)` weak-line/interference channel; `errorLines` apply at full strength regardless of source. Take: the ordered update path and the three Hifz-specific guards.
- **§5 Phases, graduation, stakes-tiered retention, cold start** — `phaseOf` from `S` (`kNearMinS` 9, `kFarMinS` 60), `manualLock` wins; graduation sign-off + window gated and predictable; `targetR` tiers (0.90 / 0.94 / 0.95 / 0.97+); the conservative `_coldStartSeed` table and `coldStartCard` (every held page `dueAt = today`, optional stale-time decay). Take: the phase function, the retention tiers, and the cold-start seeds — never invent a threshold.
- **§6 The trust clamp — the whole engine in one rule** — `trustClamp` returns `min(idealDue, ceilingDue)` (the earlier date, always); `cycleCeilingDays` is pure (no clock, no I/O); `pureCycleMode` is a one-flag fixed rotation; we refuse `max`, refuse exempting any page, refuse "safe to drop." Take: the clamp as a test-enforced invariant and the four refusals.
- **§7 Building the day: visible tradition, invisible ordering** — `buildToday` assembles by cycle and orders by SR (manzil → near → new); FAR/manzil mandatory (never dropped); `loadBalance` with `kHardFloorR` (0.85) safe-slip and the calm overflow banner; `expandMutashabihat` masses siblings; missed-day catch-up re-spreads, peak-smoothing ±1–2 days within the ceiling. Take: the day-assembly order, the mandatory-manzil rule, and the catch-up/peak-smoothing behavior.
- **§8 Determinism, weights, and golden test vectors** — `kFsrsWeightCount` (19; 21 for FSRS-6) with `assert(weights.length == …)`; `kDefaultWeights45` documented as flashcard averages; the anchor golden-vector table (curve identity, interval identity, tier multipliers, lapse-never-grows); the dart-fsrs cross-check vector (`enableFuzzing: false`); the five `glados` invariants (clamp, lapse-shrinks-S, purity, sacred-text guard, manzil-never-dropped). Take: the constants block, the anchor vectors, and the invariants to assert.

## Supporting science (the "why" behind the math)

`docs/science/03-spaced-repetition-algorithms.md`

- **§2–§3** — Leitner/SM-2 are the right metaphor and the multiplicative-interval insight but the wrong engine (one slip nukes a 15-line page; no model of *how overdue*). Take: why a lapse is a stability shrink + difficulty bump localized to erring lines, never a box reset.
- **§4** — the two-component (S, R) model is the minimum state to reason about how overdue a page is; retrieval raises stability *more when R is low* (the "review-when-weak pays most" property), so the day is ordered weakest-first. Take: the justification for weakest-first ordering and for a lapse demoting the phase.
- **§5** — FSRS chosen because it is the only model that is *both* a true two-component model *and* open, local, auditable — preconditions for a no-AI, no-backend ṣadaqah app; constants are a *prior* the engine never depends on for safety. Take: why FSRS, and that accuracy buys efficiency, not safety.
- **§6** — half-life regression's lesson (fit from logs) without its model; fit only global curve constants, on the power-law curve, with no per-page learned features (one user's sparse log over-fits). Take: the limits on any future weight-fitting.
- **§7** — desired retention is the one knob, set *for* the user by phase and stakes, never a slider; the cycle ceiling, not the number, is the guarantee. Take: the no-slider rule and the clamp-is-the-promise rule.
- **§8** — what no SR algorithm gives: interference (mutashābihāt), serial recall (the page unit), and lumpy partial knowledge; each is an explicit extension on top of FSRS. Take: why the page is the unit and why interference is a built extension, not a tuned parameter.

`docs/science/06-overlearning-and-lifelong-retention.md`

- **§3** — successive relearning (spaced re-recall to criterion) is the durable mechanism, and it *overrides* how a page was first learned — so conservative under-estimated cold-start priors carry no long-term penalty. Take: the license for "converge on real grades, no calibration grind."
- **§4** — drive pages to *automaticity* (fluency), not bare accuracy, before graduating; treat `Easy` as the automaticity signal and `Hard` (correct-but-effortful) as not-yet-automatic. Take: fluency gates graduation, not correctness.
- **§5** — "forgotten" is not "gone": a timely re-recitation is cheap (savings), a late one expensive; the trust clamp keeps every page in the cheap-savings zone. Frame a lapse as "needs reactivation," never "lost." Take: why the cycle ceiling is economically necessary, not just spiritual.
- **§6** — deep, spaced ḥifẓ reaches a decades-long permastore plateau *that still slopes* — so keep a non-null `dueAt` forever and never imply a page is finished. Take: the honesty basis for "never safe to drop."
- **§7** — near-100% comes from the cycle ceiling + stakes-tiered retention, not a literal 0.99 (≈11× the workload). Take: the retention-tier rationale and the refusal of a global 0.99.
- **§8** — prefer wider spacing over massed sessions in every quota decision; peak-smoothing nudges within the ceiling rather than massing. Take: the load-balancer's spacing-over-cramming bias.

## PRD anchors

`docs/PRD.md` §7–§8 — the domain model the engine implements: §7.1 page unit, §7.2 per-card state, §7.3 curve constants, §7.4 phase/graduation, §7.5 retention tiers, §7.6 trust clamp, §7.7 review update, §7.8 building the day, §7.9 load balance + catch-up, §7.10 cold start, §7.11 pure-cycle mode, §7.12 invariants, §8.1–§8.3 self vs teacher grading and the no-audio/no-AI boundary. Take: the field names and rule numbers — never invent one.

## CLAIMS the engine encodes

`docs/science/CLAIMS.md` — every user-facing number the engine surfaces (retention targets, cycle guarantee, "needs reactivation" framing, permastore plateau honesty) must already be a graded row here. Do not invent an id or a citation; register first via **domain-claims-register-and-science-screen**.

## Sibling skills

- **eng-datemath-and-serialday** — the `SerialDay` value type and integer day arithmetic (Hijri/Jalālī/Gregorian) the engine's `today` and `addDays` rely on.
- **eng-persistence-and-drift** — the one-transaction Drift/SQLite write that persists updated cards and the append-only `review_log`.
- **eng-quran-data-and-immutable-rendering** — the 604-page corpus and the mutashābihāt dataset that seeds interference links.
- **domain-claims-register-and-science-screen** — register any new user-facing number before the engine emits it.
- **ui-recite-and-grade-flow** — the reveal-on-tap flow that normalizes `(grade, errorLines, source)` before it reaches the engine.
- **ui-today-revision-list** / **ui-retention-heatmap** / **ui-catchup-banner** — the RTL fa/ckb/ar surfaces that render the day plan, the decay heat-map, and the catch-up banner.
- **eng-write-dart-test** — the `package:test` golden-vector + `glados` property-test harness.
- **eng-add-ci-check** — the banned-import grep gate (no `DateTime.now()` / `Random` / networking in `engine/`).
