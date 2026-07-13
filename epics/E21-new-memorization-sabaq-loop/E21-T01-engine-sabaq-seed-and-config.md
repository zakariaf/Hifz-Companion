# E21-T01 — Engine: the sabaq intake primitive + the `newLinesPerDay` config slot (test-first)

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | L (≈1–2 days) |
| **Depends on** | E04 (the `Card`/`CardSeed`/`ReviewTrack` model, `bandForStability`, `EngineConfig`, `coldStartCard` — the seed pattern this mirrors) |
| **Skills** | domain-scheduling-engine-rules, eng-write-engine-golden-vector, eng-write-dart-test |

## Goal

Give the pure engine the two things the feature layer needs to introduce a newly-memorized page into the schedule, page-granular (the resolved E21 design): (1) a pure **`sabaqSeed(pageId, today)`** primitive that produces a `CardSeed` for a page the ḥāfiẓ has **memorized today** — the New (sabaq) track, a conservative under-estimated `(D, S)` prior, and `dueAt == today` so it enters the day immediately for its first consolidating revision; and (2) the reserved **`EngineConfig.newLinesPerDay`** slot (the daily sabaq allotment, default 0 = opt-in) so a later task can pace intake. This is a **seed** act — analogous to `coldStartCard`, it *creates* a card and is never a graduation transition (`updateGraduation` never promotes out of `unmemorized`). No change to the FSRS D/S/R math, the trust clamp, or the graduation gate; the seed's golden vector freezes the prior so it can never silently drift. This task writes **no** repository (E21-T02), no `buildToday`/load-balancer consumption of `newLinesPerDay` (E21-T03), no UI, and no prayer-critical flag (E21-T08).

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §7.8 | `newToday = sabaqLines(new_lines_per_day)` — the daily sabaq allotment this task lands the config field for; a new page enters the New track and is revised old-before-new |
| `docs/PRD.md` §7.4, §6.2 | New/Near/Far are stability-band phases of one card; a new page starts on New (`S < NEAR_MIN_S`) and graduates as it strengthens — the seed must land on New by its `S`, not by a switch |
| `docs/PRD.md` §7.6, §7.10 | Trust clamp (`due = min(ideal, ceiling)`, non-null `due_at` from entry) and conservative priors that deliberately under-estimate strength so the first recitation can only surprise upward — the seed obeys both |
| `docs/PRD.md` §15.1 | `new_lines/day` is a Custom-preset field — the `EngineConfig` field this task adds (units: lines/day; default 0) |
| `packages/engine/lib/src/cold_start.dart` | The exact seed pattern to mirror: a conservative `(D, S)` prior table, track *derived* via `bandForStability`, `dueAt == today`, returns a `CardSeed` with no `profileId`; `sabaqSeed` reuses the most-conservative ("rusty") magnitude `(D 7, S 4)` under its own named prior |
| `packages/engine/lib/src/engine_config.dart:19-22` | The reserved intake slot ("E04-T08/T09 add … intake") this task fills; all fields are named-with-defaults so a new field breaks no construction site |
| `packages/engine/lib/src/build_today.dart:104-106`, `load_balance.dart:74-75` | The deferral this epic answers ("brand-new sabaq intake is the feature layer's job"); T01 provides the primitive, T03 wires the consumption |
| CLAIMS `C-009` | "err early / the penalty for a too-short gap ≪ a too-long gap" — the empirical license for the conservative under-estimating prior |
| Skill `eng-write-engine-golden-vector` | The frozen-vector discipline: the seed prior is pinned as an oracle so any change to it is a deliberate, reviewed edit, never a silent drift |
| Skill `domain-scheduling-engine-rules` | Trust clamp, conservative priors, one-source-of-truth track derivation, "a seed is not a graduation transition" |

## Implementation notes

**TEST-FIRST:** write the sabaq seed golden vector before the primitive. A wrong prior ships a mis-scheduled newly-memorized page straight to a beginner.

1. **`packages/engine/lib/src/sabaq_intake.dart`** — an `extension SabaqIntake on SchedulingEngine` (mirroring `ColdStart`) with `CardSeed sabaqSeed(int pageId, CalendarDate today)`. A private, documented `_sabaqSeedPrior = (d: 7.0, s: 4.0)` (the conservative fresh-sabaq magnitude, matching the cold-start "rusty" prior). `track: bandForStability(_sabaqSeedPrior.s)` (→ `newPage`), `dueAt: today`, `lastReviewedDay: today`. `assert(pageId in 1..604)`. Pure: no clock, no I/O, no randomness.
2. **`EngineConfig.newLinesPerDay`** — `final int newLinesPerDay;`, added to the constructor with `this.newLinesPerDay = 0` and `assert(newLinesPerDay >= 0)`; doc it as lines/day, default 0 (opt-in), mapped from `CycleConfig` by E16 and consumed by E21-T03; update the class-doc "reserved slot" note to say E21-T01 filled it.
3. **Barrel** — export `SabaqIntake` from `packages/engine/lib/engine.dart` (alphabetical, before `scheduling_engine`).
4. **No consumption yet.** `newLinesPerDay` is read by nothing in this task; T03 wires `buildToday`/`loadBalance` to it. The field landing before its consumer is the deliberate task boundary.
5. **Pitfalls:** switching the entry track on anything other than `S` (breaks the one-source-of-truth rule); inventing a novel prior number instead of the reviewed conservative magnitude; a non-null-`due_at` violation; adding a prayer-critical or profileId field here (T08 / T02); consuming `newLinesPerDay` in `buildToday` here (T03); reading a clock.

## Acceptance criteria

- [ ] `packages/engine/lib/src/sabaq_intake.dart` exists; `SchedulingEngine.sabaqSeed(pageId, today)` returns a `CardSeed` on the **New** track with the conservative prior and `dueAt == lastReviewedDay == today`; the entry track is `bandForStability(S)`, never switched; `pageId` bounds are asserted; the function is pure (verifiable by grep: no clock/IO/RNG).
- [ ] `EngineConfig.newLinesPerDay` exists (int, default 0, `assert(>= 0)`), documented as the opt-in sabaq allotment mapped from `CycleConfig` and consumed by E21-T03; the existing fields keep their defaults; `SabaqIntake` is exported from the barrel.
- [ ] The sabaq seed golden vector is written **first** and pins the exact `(D, S, track, dueAt)`; the full engine suite (golden vectors + `glados` invariants) stays green — the new primitive and config field perturb no existing vector.

## Tests

- `packages/engine/test/vectors/sabaq_seed_vectors_test.dart` (**written first**): the frozen `(D 7, S 4, newPage)` oracle; `dueAt == today`, `lastReviewedDay == today`, never `unmemorized`, `due_at` non-null; track derived from `S` and strictly `< kNearMinS`; `D ∈ [1,10]`, `S ≥ kMinStability`; page bounds 1..604 (0 and 605 assert); determinism (identical inputs → identical seed). Pure `package:test`, no clock (`today` is a `CalendarDate` literal).
- `packages/engine/test/engine_config_test.dart`: `newLinesPerDay` defaults to 0 (pure maintenance / opt-in), carries a positive value, asserts loudly on a negative, and leaves the other config defaults intact.

## Definition of Done

- [ ] All acceptance criteria met; the golden vector was written first and is green; `dart analyze` on `engine` is clean and the full `dart test` engine suite passes.
- [ ] **Engine untouched where it must be:** no change to the FSRS D/S/R math, the trust clamp, `onReview`, or the graduation gate; intake is a pure *seed* (`sabaqSeed`), never a new transition; existing golden vectors are byte-identical.
- [ ] **Conservative priors / never "safe to drop":** the seed under-estimates strength (`S = 4 < NEAR_MIN_S`), enters on the most-revised New track with `due_at = today ≤ any ceiling`, and implies nothing "safe to stop revising" (C-009; PRD §7.6, §7.10, §7.12).
- [ ] **Offline / pure / deterministic:** no clock, socket, model, or randomness anywhere in `sabaq_intake.dart` or the config; the engine-purity gate stays green.
- [ ] **Opt-in / no unsourced number:** `newLinesPerDay` defaults to 0 (the app ships as pure maintenance); this task surfaces no user-facing pacing number (there is no registered CLAIMS row for one).
- [ ] **Deterministic tests:** pure functions over fixed `CalendarDate` literals; the frozen seed oracle makes any prior change a loud, deliberate failure; all gates stay green.
