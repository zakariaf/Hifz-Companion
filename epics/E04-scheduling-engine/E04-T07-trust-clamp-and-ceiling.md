# E04-T07 — The trust clamp and cycle ceiling, with pure-cycle mode

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E04-T05 |
| **Skills** | domain-scheduling-engine-rules, eng-write-engine-golden-vector |

## Goal

`trustClamp(card, today)` and `cycleCeilingDays(card, config)` exist in the pure-Dart `engine/` package exactly as engineering 06 §6 specifies, and `onReview` ends with `next.copyWith(dueAt: trustClamp(next, today))` so the clamp is the **final** step of every review. `trustClamp` returns the **earlier** of `idealDue` (`today + interval(card.s, targetR(card))`) and `ceilingDue` (`today + cycleCeilingDays(card, config)`) — `min`, never `max` — so the SR math may only ever pull a page *forward*, never let it drift past the user's chosen cycle. `cycleCeilingDays` is a pure function of `card + config`: Far → `config.farCycleDays`, Near → `config.nearCeilingDays` (never longer than the far cycle), and `config.pureCycleMode` short-circuits to a fixed `farCycleDays` rotation with SR ordering off and zero pull-forward. `EngineConfig` carries the named cycle, the FSRS weights, and the tunable cycle constants. After this task, no memorized card can receive a null or unbounded `dueAt`, and no code path implies a page is "safe to drop." This is the single most-tested line in the engine, so it is built test-first behind INV-1.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/06-scheduling-engine.md` §6 (the trust clamp) | The verbatim Dart: `SerialDay trustClamp(Card card, SerialDay today)` computing `idealDue = today.addDays(interval(card.s, targetR(card)))` and `ceilingDue = today.addDays(cycleCeilingDays(card, config))`, returning `idealDue.value <= ceilingDue.value ? idealDue : ceilingDue` (the **earlier** date); `int cycleCeilingDays(Card card, EngineConfig config)` with the `pureCycleMode → farCycleDays` short-circuit and the `phaseOf` switch (Far/default → `farCycleDays`, Near → `nearCeilingDays`); and the four refusals — never `max`, never a non-deterministic ceiling, never exempt a page, never "safe to drop" |
| `docs/engineering/06-scheduling-engine.md` §4 (review update, line 269) | The exact wiring: `onReview` returns `next.copyWith(dueAt: trustClamp(next, today))` as its last statement — the clamp runs *after* `updateGraduation`, on the already-graduated card, so the ceiling reflects the post-review `phaseOf` |
| `docs/engineering/06-scheduling-engine.md` §8 (determinism, weights) | `EngineConfig.weights` length is asserted at `SchedulingEngine` construction (`assert(config.weights.length == kFsrsWeightCount)`); the ceiling must depend on nothing non-deterministic; `targetR` and `interval` are the §3/§5 functions this task *calls* (owned by E04-T03/T05), never re-derives |
| `docs/PRD.md` §7.6 (the trust clamp — the whole design in one rule) | `card.due_at = min(ideal_due, ceiling_due)` — "SR may only make it MORE frequent"; every page guaranteed re-recited at least once per chosen cycle "no matter what the math says"; the algorithm's only freedom is to pull a weak page forward; "this is the 'nothing decays silently' contract, in code" |
| `docs/PRD.md` §7.11 (pure-cycle / conservative mode) | For maximally traditional users/ulama who distrust reordering: a setting that runs **fixed-rotation only** — SR ordering off, zero pull-forward — turning the app into a faithful traditional tracker; the clamp is the mechanism that makes this a one-flag change |
| `docs/PRD.md` §7.12 (engine invariants) | "A memorized page's `due_at` is **never** later than its cycle ceiling"; "The engine never displays or implies 'this page is safe to stop revising'" — the two invariants this task makes structurally true |
| Skill `domain-scheduling-engine-rules` (+ `template.dart`) | Rules 16–18: `due_at = min(ideal_due, ceiling_due)` is the earlier date always; `cycleCeilingDays` is a pure function of card + config and `pureCycleMode` is a one-flag fixed rotation; never `max`, never exempt a page, never null/infinite `dueAt`, never "safe to drop". The Do/Don't rows "`due_at = min(...)` — the earlier date, always" / "`max(...)`; exempt any page from its ceiling; mark a page 'safe to drop'" |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | INV-1 as a `glados` property over generated `(Card, ReviewInput, today)` histories: `out.dueAt.value − today.value ≤ cycleCeilingDays(out, config)` for **every** memorized card after **every** review, with the covenant restated in a comment (`// PRD §7.6: SR may only make a page MORE frequent`); constants referenced by name (`cycleCeilingDays`, `targetR`, `farCycleDays`, `nearCeilingDays`); shrinking relied on, no fixed lucky seed; ceiling-anchor golden rows asserted with integer equality (day counts are integers) |
| `docs/science/CLAIMS.md` C-016 | The user-facing guarantee this rule *is*: "Every page is guaranteed a revision at least once per cycle you choose — the app can only revise it *more* often, never less" → `due_at = min(ideal_due, ceiling_due)`; "this, not a probability, is the retention guarantee" (PRD §7.6, §7.12). This task implements the engine invariant behind C-016; the science-screen row itself is E19 — invent no new citation |
| `docs/science/CLAIMS.md` C-014 | The user-facing claim behind `pureCycleMode`: "The traditional revision cycle already *is* spaced repetition; the app only re-orders within it … pure-cycle mode turns the reordering fully off." Caveat: MUST NOT present the algorithm as superseding the teacher or tradition (PRD R6, §7.11). The pure-cycle flag is the code that honors this |
| `docs/science/CLAIMS.md` C-009, C-017 | C-009 (cost asymmetry: too-early costs minutes, too-late can lose it) is the empirical *license* for clamping forward and never past the ceiling; C-017 (no global 0.99) is why near-100% comes from this ceiling, not from a retention target. Cited as the rationale these field semantics trace to — no number is rendered by this task |
| Siblings: E04-T02, E04-T03, E04-T05, E04-T08, E04-T11 | T02 supplies `Card` (non-nullable `dueAt`), `Track`, and `Card.copyWith`; T03 supplies `interval(s, targetR)` the clamp calls; **T05 (this task's dependency)** supplies `phaseOf(card)` and `targetR(card)` that `cycleCeilingDays`/`trustClamp` consume — the ceiling switches on the *post-graduation* phase; T08's `buildToday` reads `config.pureCycleMode` to turn SR ordering off (this task only sets the ceiling/flag; ordering is T08); T11 owns the broader §7.12 property suite — this task lands INV-1 and the ceiling-anchor vectors as its test-first core |

## Implementation notes

TEST-FIRST: the trust clamp is the engine's covenant in code and "the single most-tested line." Write the INV-1 property and the ceiling-anchor golden rows below **before** `trustClamp`/`cycleCeilingDays` exist, and watch a deliberately-inverted `max` stub fail INV-1 (then delete the stub). Correctness here is non-negotiable; the `min`-vs-`max` direction is the exact silent-decay failure the product exists to prevent.

1. **Files** (in the package scaffolded by E04-T01): `packages/engine/lib/src/trust_clamp.dart` for `trustClamp` + `cycleCeilingDays`, and the `EngineConfig` fields land in `packages/engine/lib/src/engine_config.dart` (extend the existing config type if E04-T01 created it; otherwise add it here). Re-export from the `packages/engine/lib/engine.dart` barrel. The `onReview` last-line wiring is an edit to the existing `packages/engine/lib/src/on_review.dart` (E04-T04). Every file carries the REUSE SPDX header (`GPL-3.0-or-later`).

2. **`trustClamp`** (engineering 06 §6, verbatim shape):
   ```dart
   /// Clamp the SR-ideal next-due to the cycle ceiling: the EARLIER date, always.
   /// PRD §7.6 — SR may only make a page MORE frequent, never push it past the cycle.
   SerialDay trustClamp(Card card, SerialDay today) {
     final idealDue = today.addDays(interval(card.s, targetR(card)));   // what the math wants
     final ceilingDue = today.addDays(cycleCeilingDays(card, config));  // what tradition promises
     return idealDue.value <= ceilingDue.value ? idealDue : ceilingDue; // min, never max
   }
   ```
   `interval` and `targetR` are E04-T03/T05 functions — call them, do not re-derive. `addDays` is `SerialDay` integer arithmetic (E02). The covenant comment lives at the `return`.

3. **`cycleCeilingDays`** — a pure function of `card + config`, no clock, no profile lookup, no I/O:
   ```dart
   /// The per-card ceiling, from the chosen named cycle (PRD §15.1) and the page's track.
   int cycleCeilingDays(Card card, EngineConfig config) {
     if (config.pureCycleMode) return config.farCycleDays;  // §7.11: fixed rotation only
     switch (phaseOf(card)) {
       case Track.far:  return config.farCycleDays;          // e.g. 7 (weekly khatm) or 30
       case Track.near: return config.nearCeilingDays;       // recent-juz window cap
       default:         return config.farCycleDays;          // never longer than the far cycle
     }
   }
   ```
   `phaseOf` is E04-T05. The default branch (New/Unmemorized) returns `farCycleDays` so the ceiling is *never longer* than the far cycle — there is no looser ceiling than the cycle anywhere. Assert the data invariant at construction or here: `assert(config.nearCeilingDays <= config.farCycleDays)` so Near is never a looser ceiling than Far.

4. **`EngineConfig`** — immutable, `const` constructor, all `final`. It carries the named cycle, the weights, and the tunable cycle constants:
   `final List<double> weights;` (the FSRS-4.5 vector, length asserted `== kFsrsWeightCount` at `SchedulingEngine` construction — E04-T10) · `final int farCycleDays;` (the far/manzil ceiling, e.g. 7 for a weekly khatm or 30 for one-juz-a-day) · `final int nearCeilingDays;` (the recent-juz window cap, `≤ farCycleDays`) · `final bool pureCycleMode;` (default `false`; `true` runs fixed rotation only). `///`-document each. Store the *named cycle* as data the UI maps to a preset (E16/`ui-cycle-preset-picker`) — this type holds day-count integers, **not** a "retention %" or a target-R dial (rule 13; C-017). No clock, no profile id, no locale in `EngineConfig`.

5. **Wire the clamp as the final step of `onReview`** (engineering 06 §4, line 269): the last statement is `return next.copyWith(dueAt: trustClamp(next, today));`, where `next` is the already-graduated card from `updateGraduation` (E04-T05). The clamp runs **after** graduation so `cycleCeilingDays` switches on the *post-review* `phaseOf(next)` — a card that just graduated New→Near gets the Near ceiling, not the old one. This is a one-line edit; do not reorder any earlier step.

6. **Pure-cycle is a ceiling concern only here.** In pure-cycle mode `cycleCeilingDays` returns `farCycleDays` regardless of phase, so a clamped `idealDue` can never exceed the fixed rotation. Turning SR *ordering* and *pull-forward* off is `buildToday`'s job (E04-T08, which reads `config.pureCycleMode`); this task sets the ceiling and the flag, and asserts the ceiling behaves under it. Do not add ordering logic here.

7. **Pitfalls to avoid**: `max` where `min` belongs — `due_at = max(...)` would push a page *past* its ceiling, the silent-decay failure (rule 16; INV-1 catches it); returning `idealDue` when it is *later* than `ceilingDue` (the comparison is `idealDue <= ceilingDue ? idealDue : ceilingDue` — equal goes to ideal harmlessly, both are the same day); a `nearCeilingDays > farCycleDays` config slipping through (assert it); reading `phaseOf` on the *pre*-graduation card (wire the clamp after `updateGraduation`); special-casing "this juz is clearly solid" to lengthen or skip the ceiling (rule 18 — never exempt a page); lengthening a ceiling toward `kMaxInterval`/infinity or returning a sentinel "drop" (no "safe to drop" path exists — PRD §7.12); putting a clock, `Random`, profile lookup, or any I/O inside `cycleCeilingDays` (it is pure — rule 17); inlining `7`/`30` as a literal at a call site (those are `config.farCycleDays`); spelling drift on a sacred term in a doc comment (`muṣḥaf`, `juz`, `manzil` — one fixed transliteration).

## Acceptance criteria

- [ ] `trust_clamp.dart` exists under `packages/engine/lib/src/` with `trustClamp(Card, SerialDay) → SerialDay` and `cycleCeilingDays(Card, EngineConfig) → int`, re-exported from the `engine.dart` barrel; each carries the REUSE SPDX header.
- [ ] `trustClamp` returns the **earlier** of `idealDue` and `ceilingDue` (`idealDue.value <= ceilingDue.value ? idealDue : ceilingDue`) — verifiably `min`, never `max`; the covenant is restated in a why-comment at the `return`.
- [ ] `cycleCeilingDays` is a pure function of `card + config` (no clock, no `Random`, no profile lookup, no I/O): `pureCycleMode` short-circuits to `farCycleDays`; otherwise Far/default → `farCycleDays`, Near → `nearCeilingDays`; and `nearCeilingDays ≤ farCycleDays` is asserted so Near is never looser than Far.
- [ ] `EngineConfig` carries `weights`, `farCycleDays`, `nearCeilingDays`, and `pureCycleMode` (default `false`), all `final`, with a `const` constructor and `///` docs; it holds no retention-%, no target-R dial, no clock, no locale.
- [ ] `onReview` ends with `next.copyWith(dueAt: trustClamp(next, today))`, applied to the already-graduated card from `updateGraduation`, so the ceiling reflects the post-review `phaseOf`.
- [ ] No memorized card (`track != Track.unmemorized`) can emerge from `onReview` with a null or unbounded `dueAt`, and no code path lengthens a ceiling toward infinity, retires a page, or returns a "drop" sentinel.
- [ ] The `engine/` dependency line stays `meta` (+ `models`) — no `drift`, `flutter`, `dart:io`, `DateTime`, or runtime `fsrs` — verifiable by grep and the E04-T01 purity gate; every public declaration has a `///` doc; `dart format` and `dart analyze --fatal-infos` are clean.

## Tests

`packages/engine/test/trust_clamp_test.dart` (unit + ceiling-anchor vectors) and the INV-1 property in `packages/engine/test/vectors/invariants_test.dart` (shared with E04-T11), `package:test` + `package:glados` — pure Dart, no `flutter_test`, no widget binding, no fonts, no network. `today` is a constructed `SerialDay` literal (`day(130)`); elapsed and day counts are integer arithmetic; no `DateTime`, no clock. Written FIRST where they pin the covenant:

- **INV-1 — the trust clamp (the covenant, test-first)**: a `glados2(anyCard, anyReview)` property over generated `(Card, ReviewInput, today)` histories asserting, for **every memorized card** after `onReview`, `out.dueAt.value − today.value ≤ cycleCeilingDays(out, config)`. The covenant is named in a comment (`// PRD §7.6: SR may only make a page MORE frequent`); no fixed lucky seed; rely on shrinking for the minimal counterexample. A deliberately-inverted `max` stub must fail this before the real `min` is written.
- **`min`, never `max` (direction)**: when `idealDue < ceilingDue` the clamp returns `idealDue` (SR pulled forward); when `idealDue > ceilingDue` it returns `ceilingDue` (ideal clamped down); when equal it returns the same day. Three explicit cases with hand-computed `SerialDay` literals.
- **Ceiling-anchor golden rows** (integer day counts, asserted with `==`): `cycleCeilingDays` for a Far card → `config.farCycleDays`; a Near card → `config.nearCeilingDays`; a New/Unmemorized card → `config.farCycleDays` (never looser than Far); each pinned for at least two configs (e.g. weekly-khatm `farCycleDays = 7` and one-juz-a-day `farCycleDays = 30`).
- **Pure-cycle mode**: with `pureCycleMode: true`, `cycleCeilingDays` returns `farCycleDays` for **every** phase (Far, Near, New); the clamped `dueAt` never exceeds the fixed rotation regardless of how large the SR `idealDue` is (feed a high-`S` card whose `idealDue` would otherwise land weeks out).
- **Far-S page is still clamped**: a strong Far card whose `interval(s, targetR)` exceeds `farCycleDays` comes back with `dueAt = today + farCycleDays`, never the longer SR interval — the guarantee holds for the strongest page.
- **Post-graduation ceiling**: a card that graduates New→Near inside `onReview` is clamped to the Near ceiling (the clamp reads the post-`updateGraduation` phase), not the pre-review phase.
- **Config invariant**: constructing an `EngineConfig` with `nearCeilingDays > farCycleDays` trips the `assert` in debug (`throwsA(isA<AssertionError>())`); a valid config (`nearCeilingDays ≤ farCycleDays`) constructs.
- **Purity / offline guard** (complements the E04-T01 banned-import grep gate): `trust_clamp.dart` and `engine_config.dart` import no `dart:io`/`flutter`/`drift` and reference no `DateTime`/`Random` — `cycleCeilingDays` is deterministic and airplane-mode-safe by construction.

(No widget/integration test — `engine/` renders nothing. The anchor vectors are integer day counts, so they assert with `==`, not `closeTo`; the float `closeTo(_, 1e-6)` tolerance applies to the curve/interval rows in E04-T03, which this task only *calls*.)

## Definition of Done

- [ ] All acceptance criteria met; both suites green under `dart test` in the `engine/` package locally and in CI (PRD §20 gates 3 and 4); the test-first INV-1 property existed and failed against an inverted `max` stub before the `min` clamp was written.
- [ ] **The trust-clamp covenant (non-negotiable)**: `due_at = min(ideal_due, ceiling_due)` — no `max` where `min` belongs; no memorized card has a null/unbounded `dueAt`; no code path retires a page or implies "safe to drop"; INV-1 (`dueAt − today ≤ cycleCeilingDays`) holds for every memorized card (PRD §7.6, §7.12; CLAIMS C-016; domain-scheduling-engine-rules rules 16–18).
- [ ] **Offline / no-network**: `trust_clamp.dart`/`engine_config.dart` open no socket and link no http/analytics SDK; the `engine/` dependency line stays `meta` (+ `models`) — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone**: the clamp consumes only `Card` + injected `today` + `EngineConfig` constants — no model, optimizer, ASR, or audio anywhere; the FSRS weights are *used*, never *fitted* (PRD C2, R5; engineering 06 §8).
- [ ] **Determinism**: `cycleCeilingDays` and `trustClamp` are pure — no `DateTime.now()`, no `Random`, no I/O, no profile lookup; `today` is a `SerialDay` and the ceiling is integer arithmetic; identical inputs → byte-identical `dueAt` (the `onReview is pure` property holds) (PRD §7.12; engineering 06 §1, §6).
- [ ] **Quran text fidelity**: N/A by construction — this task computes a day-count ceiling on a page *id*, never touches muṣḥaf glyphs or layout and cannot reflow or re-typeset sacred text. The boundary is stated, not assumed (PRD R1).
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — `trustClamp`/`cycleCeilingDays` emit an opaque `SerialDay`/`int` and no user-facing string; no locale, numeral, or calendar logic leaks into `engine/` (those live in E02 and the fa/ckb/ar UI that renders a next-due date).
- [ ] **Accessibility**: N/A by construction — `engine/` renders no widget; a11y lives wherever the next-due date and cycle preset are displayed (E12/E15/E16).
- [ ] **Sect-neutral adab**: no streak/score/badge/shame surface; the cycle is a *named tradition* a teacher recognizes, never a retention slider or a verdict the app issues; pure-cycle mode honors ulama who distrust reordering — the algorithm never presents itself as superseding the teacher or the tradition (PRD R3, R6, §7.11; CLAIMS C-014).
- [ ] **No unsourced number**: this task renders no number; the field semantics trace to already-graded CLAIMS rows (C-016 the guarantee, C-014 pure-cycle, C-009 the cost-asymmetry license, C-017 no global 0.99) and no citation or CLAIMS id is invented (domain-claims-register-and-science-screen).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on every public API; the covenant is restated as a why-comment at the `min` return; `dart format` and `dart analyze --fatal-infos` clean; no `print`/`debugPrint`; no `!`/`late`/`dynamic` used to dodge the non-null `dueAt` honesty (eng-write-to-coding-standards §4, §5, §7).
