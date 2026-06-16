# E04 — Scheduling Engine

THE CORE. Build the pure-Dart, deterministic FSRS-style DSR engine that decides which muṣḥaf pages a ḥāfiẓ revises today, in what order, and when each is next due — the page card with Difficulty/Stability/Retrievability, the three sabaq/sabqi/manzil lifecycle tracks, phase graduation, stakes-tiered retention, cold-start seeding, the budget-aware load balancer, and above every line of math the TRUST CLAMP (`due_at = min(SR-ideal, cycle ceiling)`; manzil un-skippable; never "safe to drop"). The package imports no Flutter, opens no database, reads no clock and consumes no randomness — "today" is injected as a `SerialDay` — and every rule is pinned by frozen golden vectors and `glados` property tests encoding the PRD §7.12 invariants.

## Why this epic exists

A ḥāfiẓ carries 600+ pages that decay **invisibly**; the dominant failure mode in this category is silent loss — a juz rots between revisions and nobody notices until it is gone (PRD §2). Spreadsheets and paper can record the past but cannot decide what to revise *today*, warn *before* a page rots, or keep the daily load survivable after missed days (PRD §2). This engine is the product's one intellectual core and its covenant in code: **nothing the user has memorized ever decays silently** (engineering 06 §7; PRD §7.12). It dresses an FSRS-style DSR scheduler in the traditional sabaq/sabqi/manzil workflow and — above all the math — clamps every page's next-due date to the user's chosen cycle ceiling so the algorithm may only ever pull a page *forward*, never let it drift past the cycle, and never marks a memorized page "done" (engineering 06 §6; PRD §7.6; CLAIMS C-016).

Three hard constraints shape every line. The engine must be **pure and deterministic** — no `DateTime.now()`, no `Random`, no I/O — so identical inputs yield an identical schedule and the whole thing is golden-testable, which also removes the DST `+1 day ≠ +24h` off-by-one a `DateTime`-based engine would carry (engineering 06 §1, §8; PRD §7.12, §19.3). There is **no AI and no audio**: the engine consumes a normalized `(grade, errorLines, source)` signal produced by a human (self-rating or teacher sign-off), and the FSRS weight vector is *used*, never *fitted* — we ship no optimizer because we ship no telemetry (PRD C2; engineering 06 §1, §8). And **text fidelity is existential**: a dropped or altered sacred word is never "Good" — the sacred-text guard caps such a grade at `Hard` before any arithmetic runs (PRD R1, §7.7; engineering 06 §4). The FSRS curve is trained on flashcard recognition, not hifz, so the engine never lets the probability target *be* the guarantee — the cycle ceiling is (engineering 06 §3, §6; science 06 §7; CLAIMS C-025). Building this engine first, behind frozen vectors and invariant properties, means every feature epic downstream extends a covenant that is already mechanically proven, instead of discovering a clamp-direction or graduation bug in a ḥāfiẓ's live schedule.

## Scope

### In scope

- The pure-Dart `engine/` package: a workspace member depending on `meta` (+ the `models` value types) and nothing else — no Flutter, no `dart:io`/`dart:ui`, no clock, no RNG (engineering 06 §1; engineering 02 §3.3).
- The `Card` value type (page id 1..604, `D ∈ [1,10]`, `S` in days, `track`, non-null `dueAt` for every memorized card, `reps`, `lapses`, `weakFlag`, `signoffs`, `manualLock`, `prayerCritical`) and the `ReviewInput` grading signal it consumes (PRD §7.2; engineering 06 §2).
- The FSRS-4.5 forgetting curve and closed-form interval inverse: `kDecay = -0.5`, `kFactor` *computed* from `kDecay` (= 19/81), in exactly one place, never fuzzed (PRD §7.3; engineering 06 §3; CLAIMS C-010).
- `onReview` — the one deterministic update path: sacred-text guard → source-confidence scaling → lapse/success stability + difficulty branches → weak-line difficulty channel → graduation → trust clamp (PRD §7.7; engineering 06 §4).
- `phaseOf` (three tracks as three phases of one card, derived from `S`), predictable sign-off-gated graduation, and `targetR` stakes-tiered retention (0.90/0.94/0.95/0.97+) (PRD §7.4, §7.5; engineering 06 §5; CLAIMS C-024).
- `coldStartCard` — conservative under-estimated Solid/Shaky/Rusty seeds with optional stale-time decay, every held page `dueAt = today` (PRD §7.10; engineering 06 §5; CLAIMS C-009).
- `trustClamp` + `cycleCeilingDays` — `due_at = min(ideal_due, ceiling_due)`, the earlier date always; pure-cycle mode as a one-flag fixed rotation (PRD §7.6, §7.11; engineering 06 §6; CLAIMS C-016, C-014).
- `buildToday` + `loadBalance` — tradition shapes the day (manzil → near → new), SR only orders and pulls forward, mutashābihāt siblings massed into one session, manzil mandatory, missed-day catch-up re-spread with a calm overflow banner signal, bounded peak-smoothing (PRD §7.8, §7.9; engineering 06 §7; CLAIMS C-042).
- The named FSRS-4.5 weight vector and constants stored as data with a length assert; the published default documented as a flashcard population average (PRD §7.3; engineering 06 §8).
- Frozen golden vectors (`engine/test/vectors/`) and the six `glados` invariant properties encoding PRD §7.12 — the inputs to PRD §20 release gates 3 and 4 (engineering 06 §8; engineering 11 §3, §4).

### Out of scope

- What a stored `dueAt` *means* as a calendar day, serial-day arithmetic, the injected `today` boundary, and Hijri/Jalālī/Gregorian conversion → **E02 calendar-and-date-core** (engineering 07).
- Persisting `Card`/`review_log` in one transaction, the append-only log, lazy line-block creation, the at-rest DB → **E03 models-and-persistence** (engineering 05).
- The reveal-on-tap recite flow that *normalizes* `(grade, errorLines, source)` and writes `review_log` before the engine sees it → **E12 today-and-recite-grade** (PRD §8; domain-grading-pipeline).
- The immutable muṣḥaf glyph corpus and the scholar-reviewed mutashābihāt dataset that *seeds* the confusion links the balancer reads → **E05 quran-data-and-rendering** (engineering 08).
- How the day plan, retention heat-map, and catch-up banner are *displayed* (locale, numerals, RTL) → **E12 today-and-recite-grade**, **E15 progress-and-heatmap**, **E11 onboarding-and-cold-start**.
- Registering any user-facing number the engine surfaces (cycle length, "needs reactivation" copy) as a graded CLAIMS row and the science screen → **E19 science-screen-and-claims**.
- The CI banned-import grep gate and the golden-vector/property CI job wiring → **E01 repo-scaffold-and-ci** (the gate scripts; this epic supplies the tests they run).

## Dependencies

### Depends on

- **E02 calendar-and-date-core** — the `SerialDay` value type and integer day arithmetic the engine consumes; `today` is injected as a `SerialDay`, "elapsed days" is `today.value − card.lastReview.value`, plain integer subtraction (engineering 06 §1; engineering 07).
- **E03 models-and-persistence** — the `models` value-type package the `Card`/`ReviewInput` types live in or mirror, and the `card`/`review_log` schema shape the engine's value types correspond to (no Drift symbol crosses into `engine/`) (engineering 06 §2; engineering 05 §2).

### Enables

- **E11 onboarding-and-cold-start** (drives `coldStartCard` to seed the first day), **E12 today-and-recite-grade** (renders `buildToday`'s plan and feeds `onReview` the normalized grade), **E14 mutashabihat-trainer** (the `(11−D)` interference channel and sibling-massing the dataset feeds), **E15 progress-and-heatmap** (computes per-juz/per-page health from `card` retrievability), **E16 settings-profiles-teacher** (the named cycle preset + pure-cycle toggle that set `EngineConfig`), **E19 science-screen-and-claims** (the engine rules whose CLAIMS rows the science screen renders).

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes from it |
|---|---|---|
| Engine specification | docs/engineering/06-scheduling-engine.md §1–§8 | The full canonical spec: vendored FSRS-4.5 arithmetic, the page card, curve/interval, the `onReview` update path, phases/graduation/cold-start, the trust clamp, `buildToday`/`loadBalance`, weights + golden vectors |
| Product engine requirements | docs/PRD.md §7 (§7.1–§7.12), §6.2–§6.3, §8 | The page unit, per-card state, the curve constants, phase thresholds, retention tiers, the trust clamp rule, day-building, load balancing, cold start, pure-cycle mode, and the §7.12 invariant register |
| SR algorithm science | docs/science/03-spaced-repetition-algorithms.md §4–§8 | Why FSRS (two-component, open, local, auditable), the lapse-demotes mechanism, stakes over workload-minimization, pure-cycle convergence, the `(11−D)` interference channel |
| Lifelong retention science | docs/science/06-overlearning-and-lifelong-retention.md §3, §4, §6, §7, §8 | Fluency (Easy) gates graduation, conservative cold-start priors, the permastore still slopes (never "safe to drop"), stakes-tiered retention not global 0.99, spacing over massing in catch-up |
| Engine rules checklist | .claude/skills/domain-scheduling-engine-rules | The 23-rule purity/determinism/clamp checklist every `engine/` change is reviewed against; the Do/Don't table; the trust-clamp covenant |
| Golden-vector harness | .claude/skills/eng-write-engine-golden-vector | The frozen `FsrsVector` oracle-table + `closeTo(_, 1e-6)` shape, the curve anchors, the cold-start seed rows, and the six `glados` INV-1…INV-6 properties |
| Grading signal contract | .claude/skills/domain-grading-pipeline | The `ReviewInput(grade, errorLines, source, missedOrAlteredWord)` shape the engine consumes, the sacred-text guard, and the source-confidence split |
| Package scaffold | .claude/skills/eng-create-package | The pure-Dart `engine/` manifest: `resolution: workspace`, deps `meta` only, one `lib/engine.dart` barrel, `dart test` + `glados`, the audit-minimal dependency line that *is* the purity proof |
| Claims behind every number | docs/science/CLAIMS.md (C-009, C-010, C-011, C-012, C-014, C-016, C-017, C-023, C-024, C-025, C-034, C-036, C-039, C-040, C-042) | The graded, sourced rows behind the curve constants, stability growth, the cost-asymmetry that licenses the clamp, the cycle-ceiling guarantee, fluency graduation, and the no-promise honesty rule |

## Deliverables

- [ ] `packages/engine/` scaffolded as a pure-Dart workspace member: deps `meta` (+ `models`) only, `lib/engine.dart` barrel over `lib/src/`, `dart test` + `glados` wired, REUSE SPDX headers, passing `dart pub get` and the engine-purity grep gate.
- [ ] `Card` and `ReviewInput` value types with a non-nullable `dueAt` for every memorized card asserted at construction; `Track`, `Grade`, `Source`, `JuzConfidence` enums.
- [ ] Curve + interval: `kDecay`/`kFactor` (computed) in one place, `retrievability(...)`, `interval(...)` clamped `[1, kMaxInterval]`, no fuzzing, `0.2346`/`19/81` as no literal.
- [ ] `onReview` — the one deterministic update path with the sacred-text guard, source-confidence-scaled stability, both stability branches (post-lapse clamped `≤ S`), the difficulty update, the weak-line `(11−D)` channel, graduation, and the trust clamp, in order.
- [ ] `phaseOf`, predictable sign-off-gated `updateGraduation`, and `targetR` stakes-tiered retention (0.90/0.94/0.95/0.97+ for prayer-critical/weak/lapsed).
- [ ] `coldStartCard` with the conservative Solid/Shaky/Rusty seed table, optional stale-time decay, every held page `dueAt = today`.
- [ ] `trustClamp` + `cycleCeilingDays` returning the earlier of ideal/ceiling; `pureCycleMode` as a one-flag fixed rotation; `EngineConfig` carrying the named cycle, weights, and tunable constants.
- [ ] `buildToday` + `loadBalance`: manzil → near → new ordering, mandatory manzil with a calm overflow signal, urgency-ordered Near with above-floor deferral, mutashābihāt sibling massing, missed-day re-spread, bounded `±1–2 day` peak-smoothing (no RNG).
- [ ] Named FSRS-4.5 weight vector + constants as data with `assert(weights.length == kFsrsWeightCount)`, the default commented as a flashcard population average.
- [ ] Frozen golden vectors in `engine/test/vectors/` (curve anchors, both stability branches, Hard/Easy multipliers, the five cold-start seeds) asserted `closeTo(_, 1e-6)`, computed from independent oracles.
- [ ] The six `glados` invariant properties (INV-1…INV-6) over generated `(Card, grade-sequence, today)` histories, each restating its covenant in a comment.

## Definition of Done

- [ ] **Offline / no-network:** `engine/` opens no socket, links no `http`/analytics/ads/backend SDK, and works entirely in airplane mode; the package's dependency line is `meta` (+ `models`) only — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio:** no ASR, no ML, no on-device model, no optimizer; the engine *uses* a fixed weight vector and never *fits* one; the grade is produced by a human upstream (PRD C2; engineering 06 §8).
- [ ] **Determinism:** no `DateTime.now()`, no `Random`, no I/O reachable from `engine/`; `today` is injected as a `SerialDay`, elapsed is integer subtraction; `onReview`/`coldStartCard`/`buildToday` are pure — identical inputs → byte-identical output (the `onReview is pure` property holds) (PRD §7.12; engineering 06 §1, §8).
- [ ] **Text fidelity:** the sacred-text guard caps a `missedOrAlteredWord` grade at `Hard` before any math; the `dropped word is never Good` property holds (PRD R1, §7.7).
- [ ] **The trust-clamp covenant:** `due_at = min(ideal_due, ceiling_due)`; no `max` where `min` belongs; no memorized card has a null/infinite `dueAt`; no code path retires a page or implies "safe to drop"; the `due_at never exceeds the cycle ceiling` property holds for every memorized card (PRD §7.6, §7.12; CLAIMS C-016).
- [ ] **Manzil un-skippable:** FAR/manzil due items always appear in `buildToday`'s plan; overflow surfaces as a calm honest banner signal, never a drop or a red shame-pile; the `FAR due items always appear in the plan` property holds (PRD §7.9).
- [ ] **No magic numbers / no global 0.99:** `kFactor` is computed from `kDecay`; retention is stakes-tiered via `targetR`, never a global 0.99 and never a user-facing slider; every constant is referenced by name (PRD §7.5; engineering 06 §3, §8; CLAIMS C-017).
- [ ] **Tests:** golden vectors + the six `glados` invariants run green under `dart test engine/`, computed from the FSRS definition and `dart-fsrs` (`enableFuzzing: false`) as independent oracles — never from the engine under test; these are PRD §20 gates 3 and 4 (engineering 06 §8; engineering 11 §3, §4).
- [ ] **RTL + fa/ckb/ar localization:** N/A *by construction* — the engine is locale-blind serial-integer arithmetic emitting opaque page ids and day counts; no locale, numeral, or calendar logic leaks into `engine/` (those belong to E02 and the fa/ckb/ar UI layer). The boundary is asserted, not assumed.
- [ ] **Accessibility:** N/A by construction — `engine/` renders no widget; accessibility lives wherever the day plan is displayed (E11/E12/E15).
- [ ] **Sect-neutral adab:** no streak, score, badge, or shame surface; nothing implies a madhhab/sect ruling; graduation is framed as strengthening, a lapse as "needs reactivation," never failure (PRD R3, C6; CLAIMS C-042).
- [ ] **No unsourced number:** every user-facing number the engine emits is already a graded CLAIMS row; no citation or CLAIMS id is invented (domain-claims-register-and-science-screen; CLAIMS C-009…C-016).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on every public API; passes the analyzer/lint config.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E04-T01 | [Scaffold the pure-Dart engine package and its purity boundary](E04-T01-engine-package-scaffold.md) | S | E02, E03 |
| E04-T02 | [Card and ReviewInput value types with the non-null dueAt invariant](E04-T02-card-and-review-input-types.md) | M | E04-T01 |
| E04-T03 | [FSRS-4.5 forgetting curve and closed-form interval, with anchor golden vectors](E04-T03-curve-and-interval.md) | M | E04-T02 |
| E04-T04 | [The onReview update path: sacred-text guard, lapse/success branches, weak-line channel](E04-T04-onreview-update-path.md) | L | E04-T03 |
| E04-T05 | [Phases, sign-off-gated graduation, and stakes-tiered retention targets](E04-T05-phases-graduation-retention.md) | M | E04-T04 |
| E04-T06 | [Cold-start seeding: conservative Solid/Shaky/Rusty priors + stale-time decay](E04-T06-cold-start-seeding.md) | M | E04-T05 |
| E04-T07 | [The trust clamp and cycle ceiling, with pure-cycle mode](E04-T07-trust-clamp-and-ceiling.md) | M | E04-T05 |
| E04-T08 | [buildToday: tradition-shaped day, SR ordering, mutashābihāt sibling massing](E04-T08-build-today.md) | L | E04-T07 |
| E04-T09 | [The budget-aware load balancer and graceful missed-day catch-up](E04-T09-load-balancer-and-catchup.md) | L | E04-T08 |
| E04-T10 | [The FSRS weight vector and engine constants as data with a length assert](E04-T10-weights-and-constants.md) | S | E04-T03 |
| E04-T11 | [The six glados §7.12 invariant property tests over generated histories](E04-T11-invariant-property-tests.md) | M | E04-T07, E04-T09, E04-T10 |

## Risks

- **`max` where `min` belongs in the clamp.** A single inverted comparison lets the math push a page *past* its ceiling — the exact silent-decay failure the product exists to prevent. *Mitigation:* the trust clamp is the single most-tested line; INV-1 (`due_at − today ≤ cycleCeilingDays`) is a `glados` property checked exhaustively over generated histories, and the covenant is restated in a comment at the assertion (engineering 06 §6; eng-write-engine-golden-vector).
- **Probability target creeping in as the guarantee.** Treating FSRS retention as validated for hifz and letting it *be* the promise re-introduces silent decay, since the curve is flashcard-trained, not hifz-fitted. *Mitigation:* the ceiling is the promise, the curve a prior; retention is stakes-tiered, never a global 0.99; every "why FSRS" claim ships with the flashcard-recognition caveat (engineering 06 §3; science 06 §7; CLAIMS C-025, C-017).
- **A clock, RNG, or I/O leaking into `engine/`.** A stray `DateTime.now()`, an interval fuzz, or a DB read would break determinism and the DST-immunity guarantee, and golden tests would no longer be meaningful. *Mitigation:* the package depends on `meta` (+`models`) only; the CI banned-import grep gate (E01) forbids `DateTime.now()`/`Random`/`dart:io`; the determinism property (INV-4) fails loudly if randomness returns (engineering 06 §1, §8).
- **Fixtures that agree with a bug.** Vectors generated by the engine under test cannot catch a wrong constant or an off-by-one weight index. *Mitigation:* anchor vectors come from the FSRS *definition* (curve/interval identities) and from `dart-fsrs` (`enableFuzzing: false`) as an independent oracle; regeneration is a reviewed `--update-vectors` flag, never an auto-bless in CI (engineering 06 §8; engineering 11 §3).
- **Dropping manzil or dumping a backlog to "fit the budget."** Cutting dhor or returning a red overdue pile would betray the core covenant and the no-shame adab rule. *Mitigation:* FAR/manzil due items are mandatory (INV-2), overflow is a calm banner signal, catch-up re-spreads lowest-R and prayer-critical first; both encoded as properties and reviewed against domain-scheduling-engine-rules (engineering 06 §7; PRD §7.9; CLAIMS C-042).
- **A 19-vs-21 weight-length mismatch silently mis-scheduling.** Feeding a 19-vector into 21-weight code (or vice versa, post-FSRS-6) corrupts every interval with no error. *Mitigation:* `assert(weights.length == kFsrsWeightCount)` at construction fails loudly; `kDecay`/`kFactor` kept computed so an FSRS-6 bump is one reviewed re-freeze (engineering 06 §8).
- **Self-rating vaulting a page to a long interval.** A noisy or over-generous self-grade could lengthen an interval a teacher would not endorse. *Mitigation:* `Source.self_` scales the applied stability gain by `kSelfConfidence`, self-rating alone cannot reach the prayer-critical tier, and a teacher sign-off (conf 1.0) always supersedes — pinned by INV-5 (engineering 06 §4; CLAIMS C-021).

## References

- docs/PRD.md — §6.2–§6.3 (tracks, grade scale), §7.1–§7.12 (the engine, in full), §8 (the grading signal it consumes), §19.1/§19.3 (pure-Dart, deterministic, offline), §20 gates 3–4 (golden vectors + invariants)
- docs/engineering/06-scheduling-engine.md — §1 (vendored FSRS, purity), §2 (page card), §3 (curve/interval), §4 (review update + sacred-text guard), §5 (phases/graduation/retention/cold-start), §6 (trust clamp), §7 (build day + load balance), §8 (determinism, weights, golden vectors)
- docs/science/03-spaced-repetition-algorithms.md — §4 (lapse demotes), §5 (why FSRS — two-component, open, local), §6 (no optimizer/telemetry), §7 (pure-cycle convergence), §8 (the (11−D) interference channel)
- docs/science/06-overlearning-and-lifelong-retention.md — §3 (conservative cold-start), §4 (fluency gates graduation), §6 (permastore still slopes; never "safe to drop"), §7 (stakes-tiered, not global 0.99), §8 (spacing over massing in catch-up)
- docs/science/CLAIMS.md — C-009, C-010, C-011, C-012, C-014, C-016, C-017, C-023, C-024, C-025, C-034, C-036, C-039, C-040, C-042
- docs/engineering/11-testing-strategy.md — §3 (frozen oracle vectors, tight tolerance, reviewed regeneration), §4 (INV register as `glados` properties, shrinking, fuzz OFF)
- docs/engineering/02-project-structure.md — §1.1 (workspace member), §3.1/§3.3 (dependency matrix; the engine's `meta`-only line), §5 (boundary gates)
- docs/engineering/07-dates-calendars-and-correctness.md — the `SerialDay` value type and integer day arithmetic the engine consumes (owned by E02)
- .claude/skills/domain-scheduling-engine-rules/SKILL.md — the engine purity/determinism/clamp rule checklist
- .claude/skills/eng-write-engine-golden-vector/SKILL.md — the golden-vector + `glados` invariant harness (INV-1…INV-6)
- .claude/skills/domain-grading-pipeline/SKILL.md — the `ReviewInput` contract and sacred-text guard the engine consumes
- .claude/skills/eng-create-package/SKILL.md — the pure-Dart `engine/` package scaffold and audit-minimal dependency boundary
