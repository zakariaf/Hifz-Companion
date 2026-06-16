# E04-T06 — Cold-start seeding: conservative Solid/Shaky/Rusty priors + stale-time decay

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E04-T05 |
| **Skills** | domain-scheduling-engine-rules, eng-write-engine-golden-vector |

## Goal

`coldStartCard(pageId, confidence, today, {memorizedOn})` exists as a pure function in `packages/engine/lib/src/cold_start.dart`, seeding a fresh `Card` from a per-juz self-assessment using the conservative under-estimated seed table — Solid `(D 3, S 60)` → FAR, Shaky `(D 5, S 14)` → NEAR, Rusty `(D 7, S 4)` → active — with optional stale-time decay that ages `S` from a known memorization date through the existing forgetting curve. Every held page is returned `dueAt = today` so the first weeks review each once; un-held pages are never passed in and stay `UNMEMORIZED`. Priors deliberately under-estimate strength so the first real recitation can only surprise upward. One frozen golden vector per seed asserts the exact `(D, S, track)` prior, so onboarding can never silently drift.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/06-scheduling-engine.md` §5 (cold start) | The canonical `coldStartCard` body: the `_coldStartSeed` map, the stale-time decay formula `s = max(kMinStability, s * retrievability(ageDays, seed.s) / 0.9)`, `phaseOfSeed(s)` for the entry track, `Card.memorized(... reps: 0)`, and the closing `copyWith(dueAt: today)`. The three "what we refuse" cold-start pitfalls. |
| `docs/PRD.md` §7.10 (cold start, the make-or-break onboarding) | The five-step rule set: (1) coverage capture — un-held pages stay `UNMEMORIZED`; (2) per-juz Solid/Shaky/Rusty → the exact `(D, S)` seeds and their entry phases; (3) optional stale-time decay from a memorization date; (4) the conservative-bias rule (under-estimate so the first recitation can only surprise upward); (5) convergence — every held page due now so each is reviewed once early. |
| `docs/science/06-overlearning-and-lifelong-retention.md` §3 (successive relearning) | The license for under-estimated priors: faithful re-recitation *attenuates* how a page was first learned, so the maintenance loop dominates within ~2–3 weeks **regardless of the seed** — direct evidence that conservative cold-start carries no long-term penalty and "no calibration grind" is correct. |
| `docs/science/CLAIMS.md` C-009 | The only user-facing claim this task touches: *"Reviewing a page a little too early costs minutes; too late can lose it — so we err early."* [EXP]. The cost asymmetry is the empirical license for under-estimating strength at cold start. This task surfaces no number to the user; the seed values themselves are engine internals, not a science-screen claim. |
| Skill `domain-scheduling-engine-rules` (+ `template.dart`) | Rule 15 (conservative under-estimated priors, every held page `dueAt = today`, no calibration grind) and rule 18 (a memorized card without a non-null `dueAt ≤ ceiling` is unrepresentable). Purity rules 1–2: pure function of its arguments and the injected `today`, no clock, no I/O. |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | The cold-start seed-vector pattern: one frozen row per seed asserting exact `(D, S, track)` (Solid `D=3,S=60`→FAR, Shaky `D=5,S=14`→NEAR, Rusty `D=7,S=4`→active), under `engine/test/vectors/`, computed from the seed table as the oracle, asserted `closeTo(_, 1e-6)` for floats and `==` for the discrete `track`. The decay row anchored to the curve identity. |
| Siblings: E04-T02, E04-T03, E04-T05 | T02 supplies `JuzConfidence { solid, shaky, rusty }`, the `Card.memorized(...)` constructor, `copyWith`, and the `Track` enum this builds on. T03 supplies `retrievability(...)` (the curve) the stale-time decay calls. T05 supplies `phaseOf`/the phase thresholds (`kNearMinS`, `kFarMinS`) and `targetR` — `phaseOfSeed` reuses those exact thresholds. The seed constants and `coldStartCard` are THIS task. |

## Implementation notes

TEST-FIRST: cold-start seeding is correctness-critical (an over-estimated or drifted prior can silently skip a page the user has actually lost — the exact failure the engine exists to prevent). Write the five seed golden vectors and the decay vector below **before** the `coldStartCard` body; each must exist and fail against a stub before the function is implemented.

1. **File**: `packages/engine/lib/src/cold_start.dart`, re-exported from the `packages/engine/lib/engine.dart` barrel. REUSE SPDX header (`GPL-3.0-or-later`). Pure Dart only — imports `dart:math` (`max`), the curve (`retrievability` from T03), `Card`/`JuzConfidence`/`Track` (T02), and the phase thresholds (T05); no Flutter, no `dart:io`, no `DateTime.now()`, no `Random`.

2. **The seed table** — exactly the engineering 06 §5 / PRD §7.10 values, as a named `const` map keyed by `JuzConfidence`, every number referenced by name, no literal at a call site:
   ```dart
   const _coldStartSeed = {
     JuzConfidence.solid: (d: 3.0, s: 60.0),  // → FAR / manzil
     JuzConfidence.shaky: (d: 5.0, s: 14.0),  // → NEAR
     JuzConfidence.rusty: (d: 7.0, s: 4.0),   // → active revision (NEW/NEAR)
   };
   ```
   Do **not** inline these in `coldStartCard`; the entry phase is *derived* from `S` via `phaseOfSeed`, never hard-coded per confidence, so the seed table and the phase thresholds stay the single source of truth.

3. **`phaseOfSeed(double s)`** — a small private helper that maps a seed (or post-decay) `S` to its entry `Track` using the **same** `kNearMinS`/`kFarMinS` thresholds T05 defined for `phaseOf` (`S < kNearMinS` → New, `< kFarMinS` → Near, else Far). Do not duplicate the threshold constants; import them. This is why Solid `S=60` lands FAR, Shaky `S=14` lands NEAR, and Rusty `S=4` lands NEW/active — the band, not a switch on confidence.

4. **Stale-time decay (optional `memorizedOn`)** — when `memorizedOn != null`, age `S` toward the prior implied by the forgetting curve at that age, per engineering 06 §5 / PRD §7.10 step 3:
   ```dart
   final ageDays = today.value - memorizedOn.value;   // integer subtraction — no DateTime
   s = max(kMinStability, s * retrievability(ageDays, seed.s) / 0.9);
   ```
   `ageDays` is plain `SerialDay` integer subtraction (immune to the DST off-by-one). `kMinStability` is the floor (an existing engine constant from T05/T10); a juz finished years ago decays toward `kMinStability` and re-enters active revision, exactly "needs reactivation." Re-derive the entry track from the *decayed* `s` (call `phaseOfSeed(s)` after decay, not before).

5. **Construction + the calibration due-date**: build the card with `Card.memorized(pageId: pageId, track: phaseOfSeed(s), d: seed.d, s: s, lastReview: today, reps: 0)`, then `return card.copyWith(dueAt: today)`. Every held page is due *now* so the engine's first weeks review each once (PRD §7.10 step 5) — this is the one place a freshly seeded card's `dueAt` is `today` rather than the SR-ideal. `reps: 0` (no review history yet); `lapses` defaults to 0; `weakFlag`/`prayerCritical`/`manualLock` default false.

6. **Coverage capture is the caller's job, not this function's.** `coldStartCard` is only ever called for a *held* page; un-held pages stay `UNMEMORIZED` and are never passed in (that wiring is E11 onboarding). This function never returns an `UNMEMORIZED` card and never decides coverage — keep it a pure seed-one-held-page transform.

7. **Pitfalls to avoid**:
   - Over-estimating a prior (e.g. seeding Rusty too high) — violates rule 15 and the conservative-bias rule; the first recitation must only ever surprise *upward*.
   - Hard-coding the entry `track` per confidence instead of deriving it from `S` — drifts the moment a threshold changes; always go through `phaseOfSeed`.
   - Skipping `copyWith(dueAt: today)` and letting the SR-ideal set the due date — breaks the "every held page reviewed once early" calibration pass.
   - Decaying `S` below `kMinStability` (forgetting the `max(...)` floor), or computing `ageDays` with `DateTime` instead of `SerialDay` subtraction.
   - Inlining `60`/`14`/`4`/`0.9` as literals at a call site, or duplicating `kNearMinS`/`kFarMinS` instead of importing them.
   - Treating the seed values as a user-facing claim — they are engine internals; only C-009's "err early" framing is a science-screen row, registered elsewhere (E19).

## Acceptance criteria

- [ ] `cold_start.dart` exists under `packages/engine/lib/src/`, is re-exported from the barrel, and the package still imports no Flutter, no `dart:io`, and contains no `DateTime.now()`/`Random` (verifiable by the engine-purity grep over `packages/engine/lib`).
- [ ] `coldStartCard(int pageId, JuzConfidence confidence, SerialDay today, {SerialDay? memorizedOn})` is a pure function — identical inputs → byte-identical `Card`; no clock, no RNG, no I/O reachable.
- [ ] The seed table is the named `const _coldStartSeed` map with exactly Solid `(d: 3.0, s: 60.0)`, Shaky `(d: 5.0, s: 14.0)`, Rusty `(d: 7.0, s: 4.0)`; no seed literal appears at a call site.
- [ ] With `memorizedOn == null`: Solid → `(D 3, S 60, track FAR)`, Shaky → `(D 5, S 14, track NEAR)`, Rusty → `(D 7, S 4, track NEW)`, each with `dueAt == today`, `reps == 0`, and entry track derived from `S` via `phaseOfSeed` (not switched on confidence).
- [ ] With a `memorizedOn` in the past: `S` is aged via `max(kMinStability, s * retrievability(ageDays, seed.s) / 0.9)`, never below `kMinStability`; a long-stale juz decays into active revision; `ageDays` is `SerialDay` integer subtraction.
- [ ] Every returned card has a non-null `dueAt` (== `today`) and `track != unmemorized`; the function never returns an `UNMEMORIZED` card and never makes a coverage decision.
- [ ] Every public declaration carries a `///` doc comment; the conservative-bias rule (priors under-estimate, surprise upward) and the calibration `dueAt = today` line each carry a why-comment citing PRD §7.10; the file passes the analyzer/lint config.

## Tests

`packages/engine/test/vectors/cold_start_vectors_test.dart` (pure `package:test`, no `flutter_test`, no widget binding, no fonts, no network), runs green under `dart test` over `packages/engine/`. `today` is a constructed `SerialDay` literal (e.g. `day(1000)`); `memorizedOn` is another literal; elapsed is integer subtraction. Required cases, written FIRST:

- **Three seed golden vectors (no decay)** — one `FsrsVector`-style row per confidence asserting the exact prior: Solid → `D closeTo(3.0, 1e-6)`, `S closeTo(60.0, 1e-6)`, `track == Track.far`; Shaky → `(5.0, 14.0, Track.near)`; Rusty → `(7.0, 4.0, Track.newLesson)`. Floats `closeTo(_, 1e-6)`, the discrete `track` `==`. The seed table is the oracle; these freeze PRD §7.10 so onboarding can never silently drift.
- **Calibration due-date** — for all three confidences, `card.dueAt == today` and `card.reps == 0` (every held page reviewed once early, §7.10 step 5).
- **Stale-time decay anchor** — `memorizedOn == today` (age 0) leaves `S` unchanged at the seed (because `retrievability(0, S)/0.9 == 1`), pinning the decay formula's identity at age 0; a `memorizedOn` years before `today` shrinks `S` below the seed and re-derives a lower (more active) track; the decayed `S` is never below `kMinStability`.
- **Conservative-bias regression** — assert each seed `S` is at or below a faithful-recall prior bound (the rows are the only authority on these numbers); a future edit that *raises* a seed fails the frozen vector loudly.
- **Determinism** — `coldStartCard(...)` called twice with identical arguments returns equal cards (no hidden clock/RNG); this is the cold-start slice of the engine-wide `coldStartCard is pure` invariant the E04-T11 `glados` property will generalize.
- **Offline/no-network guard**: N/A by construction — the engine test tier imports `package:test`/`package:glados` only and reaches no socket; the package's `meta`-only dependency line is the proof (epic DoD, E01 banned-import gate).

Vectors are regenerated, if ever, only via the reviewed `--update-vectors` flag; CI only verifies — no auto-bless.

## Definition of Done

- [ ] All acceptance criteria met; the cold-start vector suite is green locally and under `dart test packages/engine/` in CI (PRD §20 gate 3 — engine golden vectors).
- [ ] **Offline / no-network:** `cold_start.dart` opens no socket and links no `http`/analytics/backend SDK; the engine package's dependency line stays `meta` (+ `models`) only — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone:** the seed is a human self-assessment (`JuzConfidence`) consumed as data; no ASR, no ML, no optimizer, no on-device model, nothing fitted (PRD C2; engineering 06 §8).
- [ ] **Determinism:** no `DateTime.now()`, no `Random`, no I/O reachable; `today`/`memorizedOn` are injected `SerialDay`s, `ageDays` is integer subtraction; identical inputs → byte-identical `Card` (PRD §7.12; engineering 06 §1, §8).
- [ ] **Quran text fidelity:** N/A by construction — cold-start operates on opaque page ids and `(D, S)` priors only; it never reads, reflows, or alters sacred text (the muṣḥaf corpus is E05).
- [ ] **The trust-clamp / "never safe to drop" covenant:** every returned card has a finite non-null `dueAt` (== `today`) and `track != unmemorized`; no path produces a null/infinite `dueAt`, retires a page, or implies a page is "safe to drop"; priors *under*-estimate so the engine errs toward over-review, never toward silently skipping a lost page (PRD §7.10, §7.12; CLAIMS C-009).
- [ ] **RTL + fa/ckb/ar localization:** N/A by construction — `cold_start.dart` is locale-blind serial-integer/float arithmetic emitting opaque page ids and day counts; no locale, numeral, or calendar logic leaks into `engine/` (the onboarding confidence picker and its fa/ckb/ar strings are E11).
- [ ] **Accessibility:** N/A by construction — the engine renders no widget; accessibility lives where the cold-start flow is displayed (E11 onboarding).
- [ ] **Sect-neutral adab:** no streak, score, badge, or shame surface; the seed values are framed internally as conservative priors and a stale juz as "needs reactivation," never as failure or a madhhab/sect ruling (PRD R3, C6).
- [ ] **No unsourced number:** the seed table is an engine internal (engineering 06 §5 / PRD §7.10), not a user-facing claim; the only user-facing claim touched is the registered C-009 "err early" framing — no citation or CLAIMS id is invented (domain-claims-register-and-science-screen).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on the public API; analyzer/lint config passes.
