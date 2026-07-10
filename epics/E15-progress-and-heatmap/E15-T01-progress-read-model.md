# E15-T01 — Progress read model: StreamProvider streaming per-page R + min-leaning juz roll-up from the live card set — test-first

| | |
|---|---|
| **Epic** | [E15 — Progress & Heat-map](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E07, E04 |
| **Skills** | eng-create-riverpod-store, domain-scheduling-engine-rules, eng-write-dart-test |

## Goal

The single source of every health number on the Progress surface. A `family`+`autoDispose`-keyed `StreamProvider` in the data/read-model layer watches the live Drift card stream for the active profile and, on each emission, calls the pure E04 engine with the injected `Clock`'s `today` to compute each memorized page's retrievability `R` and its calm decay band, plus the **min-leaning** per-juz roll-up and the raw due-date/weakness data the forecast (E15-T08) and weakest-pages list (E15-T07) consume. Derived health is **never stored** — `R` is recomputed on read so a clock advance never shows stale retention (PRD §10.3) — and the model is a **read-only projection**: it never touches `review_log`, never applies a review, never recomputes `due_at` (the trust clamp ran at write time, eng 06 §6). Never-recited (cold-start-prior-only) and self-rating-only pages carry an explicit uncertainty basis flag (PRD §7.10, §8.1) that T04 renders as VSUP muting and T06 states in words. **Test-first**: the unit suite over a fake card set is written before the model. No widget, no colour token, no grid geometry, no user-facing string — this task ships value types and providers only.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §10.3 | The governing rule: strength roll-ups are **computed from `card.R`, not stored as a separate authority**; juz health uses a **min-leaning** aggregate — one weak page is what fails you in ṣalāh, surface the weakest link |
| `docs/PRD.md` §7.3 | The curve behind every emitted number: `retrievability(t, S) = (1 + FACTOR·t/S)^DECAY`, `R(S,S) = 0.9`; the constants are a starting prior — this model calls the engine's function, never restates them |
| `docs/PRD.md` §7.4, §7.5 | Phase as a function of stability and the per-phase retention targets (New 0.90 / Near 0.94 / Far 0.95–0.97+) that define what strong vs receding vs weak means for a page's decay band |
| `docs/PRD.md` §7.10 | Cold start seeds **conservative priors** — a never-recited page's `R` is an estimate from a juz-level Solid/Shaky/Rusty tap, not a measurement → the model's `estimated` muting basis |
| `docs/PRD.md` §7.12 | The invariants this projection must not break at the chart layer: `due_at` never past the ceiling, never "safe to stop revising", identical inputs → identical output |
| `docs/PRD.md` §8.1 | Self-rating carries `sourceConfidence ≈ 0.5` and alone cannot reach the top retention tier → the `selfRatedOnly` basis flag for pages whose history holds no teacher sign-off |
| `docs/engineering/06-scheduling-engine.md` §3 | The exact engine API to call: `retrievability(elapsedDays, s)` (and `interval(s, targetR)`); the read model imports these — it never re-implements `kDecay`/`kFactor` |
| `docs/engineering/06-scheduling-engine.md` §5 | `phaseOf(card)` / `targetR(card)` and the cold-start seeds (Solid D=3,S=60 · Shaky D=5,S=14 · Rusty D=7,S=4) the fake card set mirrors; the decay-band derivation is E04's, called here |
| `docs/engineering/06-scheduling-engine.md` §6 | The trust clamp (`due_at = min(ideal, ceiling)`) is applied **at write time** by the engine — this model relays the stored `card.dueAt`, it never recomputes or "corrects" a due date |
| `docs/engineering/04-flutter-and-state-patterns.md` §3 | The canonical shape to mirror: `juzHealthProvider = StreamProvider.family<List<JuzHealth>, ProfileId>` over `repo.watchJuzHealth(profile)`; `R` computed on read, no cache layer, no stored `R` column, no background recompute timer — recomputation is event-driven off the write path |
| `docs/engineering/04-flutter-and-state-patterns.md` §4 | The single write path this model stays **out of**: a read-only projection; no DAO write, no `review_log` append/update/delete, ever |
| `docs/engineering/04-flutter-and-state-patterns.md` §5 | `family` keyed by a stable equatable `ProfileId` + `autoDispose` on unmount; never key on a mutable `Card`; never `autoDispose` the DB/engine app-scope singletons |
| `docs/design-system/08-data-visualization.md` §4, §6 | The downstream contract this data feeds: an uncertain estimate must *look* uncertain (VSUP) and the roll-up leans to the weakest page — both require the basis flag and the min-leaning aggregate to exist **in the data**, never improvised in a widget |
| Skill `eng-create-riverpod-store` | Patterns 2/5 (reactive projection = `StreamProvider` over a Drift query, immutable value types, no second cache, `R`/juz health computed on read), 8 (no `DateTime.now()`; the injected `CalendarDate` clock), 9 (`family`+`autoDispose`), 12 (the store holds value types, never rendered words or scores) |
| Skill `domain-scheduling-engine-rules` | The engine is called, never re-derived: purity (no Flutter/IO/clock in the engine; `today` is a parameter) and the never-"safe to drop" posture every consumer inherits from this model |
| Skill `eng-write-dart-test` | §3 (inject `today`, never `DateTime.now()`), §5 (§7.12 invariants as properties where generative), §8 (the throwing `HttpOverrides` offline guard), and the test-first discipline this task is gated on |
| `docs/science/CLAIMS.md` — **C-001**, **C-010** | The decay premise and the power-law `R` behind every number this model emits — the map renders each page's slide down its own curve; both already sourced, nothing new claimed here |
| `docs/science/CLAIMS.md` — **C-019** | The scientific warrant for min-leaning: a strong page never becomes "done" — the aggregate must never let a mean hide the one page that would fail in ṣalāh |
| Sibling **E15-T02** | Mounts the Progress module and wires its ViewModel to these providers via scoped `progress_providers.dart`; it consumes this read model and re-derives nothing |
| Siblings **E15-T04**, **E15-T06** | T04 renders the basis flag as VSUP muting + the band as a ramp token; T06 states `R` as a range in words with its basis — both consume fields produced (test-first) here |
| Sibling **E15-T05** | The **same min-leaning invariant, two layers**: T01 pins test-first that the read model *produces* min-leaning data naming the weakest page(s); T05 pins that the juz tile *renders* the weak link — neither trusts the other to guard it |
| Siblings **E15-T07**, **E15-T08** | Consume the raw weakness ordering and per-day due data exposed here; neither recomputes `R`, `due_at`, or the aggregate |
| Out of scope **E04** / **E03** | E04 owns the math itself (curve, phase/target, band derivation, min-leaning semantics, trust clamp); E03 owns the Drift schema/DAO — this task adds only a read-only watch query over the existing tables |

## Implementation notes

Data-layer only: no widget, no token, no string, no write. The unit suite is written first (red), then the value types + provider make it green.

1. **Tests first.** Write `data/test/progress/progress_read_model_test.dart` (and the roll-up/muting/isolation/read-only cases below) against the intended API over a fake card set + fake clock before any implementation; they must fail meaningfully before the model exists.
2. **Files** (data/read-model layer, below `features`, per `docs/engineering/02-project-structure.md` anatomy): immutable value types — e.g. `PageHealth {pageId, juz, r, decayBand, basis, dueAt}`, `JuzHealth` (the eng-04 §3 name: min-leaning band + weakest page id(s) + its pages), and a snapshot bundling both plus the due-date series T08 counts from — plus the repository watch method and the provider. All immutable (`copyWith`, equatable); never a mutable `Card` handed downstream.
3. **The provider mirrors eng-04 §3 in shape:** `progressHeatmapProvider = StreamProvider.autoDispose.family<…, ProfileId>` watching the card repository's `watchProgressHealth(profile)` (the `watchJuzHealth` shape) and reading `clockProvider` — a committed card change re-emits the Drift stream and the projection recomputes; no cache, no timer, no manual refresh. T02's scoped `progress_providers.dart` re-exports/wires this; it does not re-derive it.
4. **R on read:** for each memorized card, `elapsedDays` = serial-day subtraction of `card.lastReview` from the injected `CalendarDate` today (integer serial days — never a `DateTime` diff), then `engine.retrievability(elapsedDays, s)`; the decay band comes from E04's band derivation (R against the card's `phaseOf`/`targetR` posture). The read model contains **zero curve constants** and **zero band thresholds** of its own.
5. **Min-leaning roll-up via the engine, never locally:** the per-juz aggregate calls E04's min-leaning aggregate over the juz's page set and carries the weakest page id(s) so T05 can badge and T07 can list. A mean/median never appears — not even as an extra "convenience" field; a pretty average field *is* the scoreboard drift (EPIC risk 2).
6. **Muting basis from provenance, not magic:** `basis = estimated` when the card is cold-start-prior-only (never recited, §7.10 calibration pending); `selfRatedOnly` when its history holds no teacher sign-off (§8.1); observed otherwise. The model emits the enum; the VSUP visual (T04) and the range-in-words (T06) are downstream.
7. **`dueAt` is relayed, never recomputed:** the trust clamp ran at write time (eng 06 §6); this model exposes the stored value (for T08's per-day counts and T07's ordering) and a test asserts every exposed `dueAt` is within its cycle ceiling — a §7.12 tripwire, not a correction path.
8. **Read-only by construction:** the watch method lives beside, not inside, the write path; the model imports no DAO write surface and contains no `review_log` mutation (eng-04 §4) — grep-verifiable.
9. **Pitfalls to avoid:** persisting `R`/band/aggregate to a column ("to make the grid fast"); `DateTime.now()` anywhere (the clock is injected; a fresh subscription picks up the new today); re-implementing `kDecay`/`kFactor` or band cutoffs in the data layer; a mean roll-up; recomputing `due_at` in the shell; keying the family on a mutable object; localized words, hex colours, or any streak/score/percent-promise field inside a value type; a background tick recomputing health.

## Acceptance criteria

- [ ] The immutable value types and `progressHeatmapProvider` (`StreamProvider.autoDispose.family` keyed by a stable `ProfileId`) exist in the data/read-model layer; the per-page value carries `{pageId, juz, R, decayBand, basis, dueAt}`; the juz value carries the min-leaning band + weakest page id(s).
- [ ] `R` and the decay band are computed on every read by calling the injected E04 engine with the injected `CalendarDate` today; no `R`, band, or aggregate is ever written to a column; the data layer contains no curve constant and no band threshold (grep-verifiable).
- [ ] The juz roll-up is the engine's **min-leaning** aggregate; no mean/median field exists anywhere in the model.
- [ ] Never-recited and self-rating-only pages carry the uncertainty basis flag; teacher-signed pages do not.
- [ ] `dueAt` is relayed from the stored card, never recomputed; the exposed data is sufficient for T08's per-day due counts and T07's weakness ordering without either recomputing anything.
- [ ] The model is read-only: no DAO write import, no `review_log` append/update/delete (grep + a recording-fake test prove it).
- [ ] No `DateTime.now()`/`Calendar.current` in this task's files; no value type contains a user-facing string, colour, or score-like field.
- [ ] The unit suite was written first and is green; two profiles' streams are isolated by the family key.

## Tests

All `package:test`-tier unit tests over fakes — deterministic, offline by construction, injected `CalendarDate` (never a real clock), written **before** the model (eng-write-dart-test).

- `data/test/progress/progress_read_model_test.dart` — **written first**: over a seeded fake card set and `today = T`, every emitted `R` equals `engine.retrievability(T − lastReview, s)` to `closeTo(_, 1e-6)`; advancing the injected clock to `T+k` and re-reading yields the lower `R` **with zero writes performed** — nothing stale, nothing stored.
- `data/test/progress/juz_rollup_min_leaning_test.dart` — a juz of 19 strong pages + 1 rotting page rolls up to the weak band and names the rotting page id; it is **never** averaged green; an all-strong juz rolls up strong (no false alarm either).
- `data/test/progress/muting_basis_test.dart` — a cold-start-prior-only card (never recited) and a self-rating-only card both emit an uncertain basis; a teacher-signed card does not; the flag flips on the first qualifying review emission.
- `data/test/progress/profile_isolation_test.dart` — two `ProfileId`s seeded with different card sets stream disjoint snapshots; switching the watched key re-resolves with no leakage; `autoDispose` tears the stream down when the last listener unmounts.
- `data/test/progress/read_only_guard_test.dart` — a recording repository double asserts **zero** writes across every emission and clock advance; every exposed `dueAt` is within its cycle ceiling (the §7.12 tripwire).
- Offline guard: the suite runs under a throwing `HttpOverrides` (eng-write-dart-test §8) — the read model can never open a socket. (Widget/golden coverage of what these numbers look like is T03–T06/T10, not here.)

## Definition of Done

- [ ] All acceptance criteria met; the suite above was red before the model existed and is green after, locally and in CI.
- [ ] **Offline / no-network**: a pure projection over the local Drift stream; the throwing-`HttpOverrides` guard passes; nothing here can fetch, sync, or phone home (PRD C1).
- [ ] **No AI / no microphone**: every number is deterministic engine output over human-graded history; no model, no inference, no audio anywhere (PRD C2, R5).
- [ ] **Quran text fidelity (R1)**: this layer renders nothing and touches no glyph, layout, or muṣḥaf asset — it emits value types only.
- [ ] **Never "safe to drop" (§7.12, C-019)**: the roll-up is min-leaning by the engine, pinned test-first; no mean exists; the relayed `dueAt` never exceeds the cycle ceiling (tripwire test); no field of the model can express "done"/"retired"/"safe".
- [ ] **No gamification / no shame (R3, C6)**: the model carries no streak, score, points, rank, or percent-promise field — the data shape itself cannot feed a scoreboard, and every consumer inherits that.
- [ ] **Honest about prediction (§7.10, §8.1)**: the uncertainty basis is first-class in the data, so downstream muting (T04) and range-in-words (T06) are structural, not cosmetic.
- [ ] **RTL + fa/ckb/ar localization**: no user-facing string, numeral, or date is rendered here; the model exposes semantic enums and raw values so every word/number/date is localized downstream through the ARB / `numberFormatFor(locale)` / `CalendarPresenter` paths — no literal in any language leaks from the data layer.
- [ ] **Accessibility**: the per-page value + band + basis triple is exactly what lets every consumer encode redundantly (colour + number + label, SC 1.4.1) — present and pinned here so no downstream surface is forced to colour-only.
- [ ] **Deterministic tests**: injected `CalendarDate` clock and seeded fakes only; identical inputs → identical snapshots; engine purity untouched (it still imports nothing from Flutter/IO and reads no clock).
