# E04-T11 — The six glados §7.12 invariant property tests over generated histories

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E04-T07, E04-T09, E04-T10 |
| **Skills** | eng-write-engine-golden-vector, domain-scheduling-engine-rules, eng-write-dart-test |

## Goal

`packages/engine/test/invariants_test.dart` exists and encodes the **full PRD §7.12 invariant register** — INV-1…INV-6 — as six `glados` properties over generated `(Card, grade-sequence, today)` histories, run via `any.scheduleCase` (a `cardSeed` + a `listWithLengthInRange(0, 200, gradedReview)` + a `serialDayInRange(0, 3650)`). Each property folds its random grade sequence onto its card with the injected `today`, asserts one covenant for **all** generated histories, and restates that covenant in a comment at the assertion (`// PRD §7.6: SR may only make a page MORE frequent`). No fixed lucky seed is pinned — the suite relies on `glados`'s shrinking to report the minimal counterexample. After this task the six covenants are machine-checked across the whole input space: INV-1 trust clamp (`dueAt − today ≤ cycleCeilingDays` for every memorized card), INV-2 manzil never dropped (every due FAR page appears in `buildToday`'s plan), INV-3 a lapse demotes (`Again ⇒ S' ≤ S ∧ track' ≤ track`), INV-4 determinism (two `buildToday` runs fingerprint-equal, fuzz OFF), INV-5 teacher `Again` overrides a prior self `Good`, INV-6 every memorized card has a finite non-null `dueAt` (never "safe to drop"). This suite **is** PRD §20 gate 4.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/11-testing-strategy.md` §4 (invariants as property tests) | The verbatim spec this task implements: the `AnySchedule on Any` extension with `scheduleCase => combine3(any.cardSeed, any.listWithLengthInRange(0, 200, any.gradedReview), any.serialDayInRange(0, 3650), ScheduleCase.new)`; the `replay`/`replayAll` fold helpers; the six `Glados<ScheduleCase>(any.scheduleCase).test(...)` bodies; the full INV register table (INV-1…INV-6); and the three refusals — INV-6 is **not** copy-grep alone (the non-nullable `dueAt` type forecloses it; the property asserts a finite due day for every memorized card), no fixed lucky seed, never skip the determinism property |
| `docs/engineering/06-scheduling-engine.md` §8 (determinism, weights, golden vectors) | The `glados` property list as executable §7.12 rules: the trust-clamp property (`out.dueAt.value − today.value ≤ cycleCeilingDays(out, config)`), `Again shrinks S`, `onReview is pure`, `dropped word is never Good`, `FAR due items always appear in the plan`; that anchor fixtures come from an independent oracle, **never** the engine under test; that fuzzing stays OFF so the determinism property holds; constants referenced by name |
| `docs/PRD.md` §7.12 (engine invariants — must always hold) | The five covenant sentences this task makes mechanically true: a memorized page's `due_at` is never later than its cycle ceiling (INV-1); FAR/manzil due items are never silently dropped (INV-2); the engine never implies a page is "safe to stop revising" (INV-6); a teacher sign-off always supersedes self-rating and algorithmic state (INV-5); all math is pure Dart, deterministic, identical inputs → identical schedule (INV-4) — plus the lapse-demotes mechanism (INV-3) from §7.7 |
| `docs/PRD.md` §20 gate 4 | "Invariant tests (§7.12) as property-based checks" — this suite is literally that release-blocking gate; it runs in the `fast` CI job alongside the golden vectors (gate 3) |
| `docs/science/03-spaced-repetition-algorithms.md` §4 | The lapse-demotes mechanism behind INV-3: `Again` genuinely sets `S` back and naturally demotes the phase — never grows stability or promotes a track |
| `docs/science/06-overlearning-and-lifelong-retention.md` §6 | The "permastore plateau still slopes" basis for INV-6: a mature page keeps a non-null due date *forever*; there is no state that means "stop revising this" |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | The canonical pattern (item 6–10): an invariant is a `glados` property over generated histories with shrinking; encode the **full** INV register; let `glados` explore broadly and rely on shrinking, no lucky seed; name the covenant in a comment at INV-1/INV-6; reference every scheduling constant by name (`cycleCeilingDays`, `targetR`, `kFarMinS`, `kSelfConfidence`); never let the engine under test generate its own fixtures. The `template.dart` `scheduleCase` generator + the six property bodies are the starting point |
| Skill `domain-scheduling-engine-rules` | The rules these properties assert, by number: 16–18 (the clamp = `min`, `cycleCeilingDays` pure, never "safe to drop") → INV-1/INV-6; 8 (a lapse demotes, `postLapseStability ≤ s`) → INV-3; 9 (teacher source 1.0 supersedes self) → INV-5; 19 (manzil un-skippable) → INV-2; 2 (pure, deterministic, `today` injected) → INV-4. This task pins the rules; it does not change them — a property that fails reveals an engine bug, not a test to relax |
| Skill `eng-write-dart-test` (§5 + the `glados` template) | Tier placement: this is the broad pure-Dart property base, `package:test` + `package:glados`, `dart test`, no `flutter_test`, no widget binding, no `HttpOverrides` needed (the engine opens no socket); each PRD §7.12 invariant is one `glados` property over a generated `(Card, grades, today)` history; rely on shrinking, no fixed lucky seed; the covenants checklist (a dropped word is never "Good", teacher supersedes self, nothing implies "safe to drop") |
| `docs/science/CLAIMS.md` C-016 | The user-facing guarantee INV-1 enforces in code: "Every page is guaranteed a revision at least once per cycle you choose — the app can only revise it *more* often, never less" → `due_at = min(ideal_due, ceiling_due)`; "this, not a probability, is the retention guarantee." This task renders no number — it pins the engine invariant behind C-016; the science-screen row is E19. Invent no new citation or CLAIMS id |
| `docs/science/CLAIMS.md` C-025 | The honesty claim INV-6 makes structural: "We can't promise you'll never forget a page — lasting retention comes from regular revision, not a magic number"; near-100% is delivered by the cycle ceiling + overlearning, **not** a 0.99 target. INV-6 asserts every memorized card keeps a finite non-null `dueAt` — there is no engine state that means "safe to drop." No number rendered; cited as the rationale these covenants trace to |
| Siblings: E04-T02, E04-T04, E04-T05, E04-T07, E04-T08, E04-T09, E04-T10 | T02 supplies `Card` (non-nullable `dueAt`), `Track`, `Grade`, `Source`; T04 supplies `onReview` (sacred-text guard, lapse/success branches, source-confidence) driving INV-3/INV-5; T05 supplies `phaseOf`/`targetR` the ceiling reads; **T07 (dependency)** supplies `trustClamp`/`cycleCeilingDays` and lands INV-1 + the ceiling-anchor vectors test-first — this task *reuses* that INV-1 property and adds INV-2…INV-6 around it; T08 supplies `buildToday` + `plan.allPageIds` for INV-2 and `plan.fingerprint()` for INV-4; **T09 (dependency)** supplies `loadBalance`/missed-day catch-up whose re-spread must still satisfy INV-1/INV-2; **T10 (dependency)** supplies the named weight vector + constants and `EngineConfig.defaults()` the engine is constructed with. This task is the §7.12 register's home; T07 contributes INV-1 to it |

## Implementation notes

TEST-FIRST is the whole task: these six properties **are** the test artifact. There is no production code to write — the task succeeds when the properties exist, run green over the real engine (T01–T10), and a deliberately-broken engine stub fails the matching property. Write each property to fail first against an inverted stub (a `max`-clamp for INV-1, an `S`-growing lapse for INV-3, a self-wins branch for INV-5, a manzil-dropping `buildToday` for INV-2), confirm the failure shrinks to a minimal counterexample, then delete the stub and watch the real engine pass.

1. **File**: `packages/engine/test/invariants_test.dart` (in the package scaffolded by E04-T01). `package:test/test.dart` + `package:glados/glados.dart` only — no `flutter_test`, no widget binding, no `FontLoader`, no `HttpOverrides`. Construct the engine once: `final engine = SchedulingEngine(EngineConfig.defaults());` (the `defaults()` from E04-T10 with its length-asserted weight vector). The REUSE SPDX header (`GPL-3.0-or-later`) is the first line.

2. **The generator** — one `extension AnySchedule on Any` with `Generator<ScheduleCase> get scheduleCase` (engineering 11 §4, verbatim):
   ```dart
   extension AnySchedule on Any {
     /// A card seed plus a random graded-review sequence and an injected today.
     Generator<ScheduleCase> get scheduleCase => combine3(
           any.cardSeed,                                          // page 1..604, D∈[1,10], S>0, track
           any.listWithLengthInRange(0, 200, any.gradedReview),   // Again/Hard/Good/Easy + errorLines + source
           any.serialDayInRange(0, 3650),                         // today within ~10 years
           ScheduleCase.new,
         );
   }
   ```
   `ScheduleCase` is a tiny immutable test record holding `(CardSeed seed, List<GradedReview> reviews, SerialDay today)` plus `EngineConfig get config => EngineConfig.defaults()`. The custom sub-generators (`cardSeed`, `gradedReview`, `serialDayInRange`) are defined in this file or a shared `packages/engine/test/support/generators.dart`; `serialDayInRange(lo, hi)` maps `any.intInRange(lo, hi)` through `SerialDay.new` so `today` is always a constructed integer day, never a clock read.

3. **The fold helpers** `replay`/`replayAll` apply the grade sequence to the seed card(s) via `onReview` with the injected `today`, returning the post-history `Card` (or the set, for `buildToday`). They live beside the properties; they read no clock and consume no randomness beyond the generated `ScheduleCase`.

4. **INV-1 — the trust clamp** (reuse the T07 property here as the register's first row):
   ```dart
   // INV-1 — the trust clamp. PRD §7.6: SR may only make a page MORE frequent.
   Glados<ScheduleCase>(any.scheduleCase).test('due_at <= cycle ceiling, always', (c) {
     final card = replay(engine, c);
     if (card.track == Track.unmemorized) return;       // ceiling applies only to memorized cards
     expect(card.dueAt.value - c.today.value,
         lessThanOrEqualTo(cycleCeilingDays(card, c.config)));
   });
   ```

5. **INV-2 — manzil never dropped**:
   ```dart
   // INV-2 — FAR/manzil due items are NEVER silently dropped. PRD §7.9.
   Glados<ScheduleCase>(any.scheduleCase).test('FAR due items always appear in the plan', (c) {
     final cards = replayAll(engine, c);
     final plan = engine.buildToday(cards, c.today);
     final dueFar = cards.where((x) => x.track == Track.far && x.dueAt.value <= c.today.value);
     expect(plan.allPageIds, containsAll(dueFar.map((x) => x.pageId)));
   });
   ```

6. **INV-3 — a lapse demotes**: after `replay`, apply one teacher `Again` and assert `after.s <= before.s` **and** `after.track.index <= before.track.index` (never promotes). The `Again` carries `source: Source.teacher` so confidence-scaling can't mask the demotion. `// INV-3 — a lapse demotes. PRD §7.7; science 03 §4: Again sets S back, never grows it.`

7. **INV-4 — determinism (fuzz OFF)**: build the plan twice from the same replayed cards + `today` and assert `plan.fingerprint()` equality. This is the property that keeps "fuzz OFF" honest if a refactor reintroduces `Random`/interval fuzzing. `// INV-4 — identical inputs => byte-identical plan; interval fuzzing is OFF.`

8. **INV-5 — teacher overrides self**: replay, then a self `Good` (`Source.self_`), then a teacher `Again` (`Source.teacher`, `errorLines: [1]`); assert `teacherState.weakFlag` is true and `teacherState.dueAt.value <= selfState.dueAt.value` — the teacher's verdict wins and pulls the page *forward*. `// INV-5 — teacher sign-off supersedes self-rating and prior state. PRD §8.2.`

9. **INV-6 — never "safe to drop"**: over every generated history, assert every memorized card (`track != Track.unmemorized`) has a finite, non-null `dueAt` — `card.dueAt.value` is finite and `card.dueAt.value <= cycleCeilingDays(card, c.config) + c.today.value`. The non-nullable type forecloses `null` at compile time; this property asserts there is no value the engine produces that *means* "stop." `// INV-6 — the permastore still slopes; no memorized page is ever 'safe to drop'. PRD §7.12; science 06 §6.`

10. **Constants by name, no literals**: reference `cycleCeilingDays`, `targetR`, `kFarMinS`, `kSelfConfidence`, `Track.far`, `Grade.again`, `Source.teacher` by name — never inline `0.5`/`60`/a track index integer. A `// dart format off` region is allowed only around an aligned generator table where alignment is the documentation, with a justifying comment.

11. **Pitfalls to avoid**: pinning a fixed `glados` seed that happens to pass and hides a regression (let it explore; rely on shrinking) — engineering 11 §4 refusal; encoding INV-6 as a `grep` for the string "safe to drop" instead of asserting a finite `dueAt` (the type + the property are the proof, not copy-search) — engineering 11 §4 refusal; letting INV-4 silently pass because fuzzing was never on in this build (the property must be able to *fail* if fuzzing returns — assert the fingerprint, not a tautology); generating fixtures from the engine under test (these are properties over *generated* inputs asserted against the engine's covenants, not oracle rows — that distinction is fine; the oracle rule is for E04-T03's golden vectors, not here); importing `flutter_test` or reading `DateTime.now()` (the engine and its tests are pure Dart; `today` is a constructed `SerialDay`); asserting an invariant on one hand-picked card and calling the `∀` proven (every INV must run through `any.scheduleCase`); a `Track.index` comparison that assumes an enum order — confirm `Track` is declared `unmemorized < new < near < far` so `index` is monotone with strength before relying on it in INV-3.

## Acceptance criteria

- [ ] `packages/engine/test/invariants_test.dart` exists, imports `package:test` + `package:glados` only (no `flutter_test`, no widget binding, no fonts, no network), carries the REUSE SPDX header, and runs green under `dart test` in the `engine/` package.
- [ ] An `extension AnySchedule on Any` defines `scheduleCase => combine3(any.cardSeed, any.listWithLengthInRange(0, 200, any.gradedReview), any.serialDayInRange(0, 3650), ScheduleCase.new)`; every property runs over `any.scheduleCase`, and `today` is a constructed `SerialDay` (no `DateTime.now()` anywhere reachable).
- [ ] All six properties are present and named: **INV-1** `due_at <= cycle ceiling` for every memorized card; **INV-2** every due FAR page is in `buildToday`'s plan; **INV-3** `Again ⇒ S' ≤ S ∧ track' ≤ track`; **INV-4** two `buildToday` runs fingerprint-equal; **INV-5** a teacher `Again` overrides a prior self `Good`; **INV-6** every memorized card has a finite non-null `dueAt`.
- [ ] Each property restates its covenant in a comment at the assertion (e.g. `// PRD §7.6: SR may only make a page MORE frequent` at INV-1; the permastore-slope covenant at INV-6).
- [ ] No fixed lucky `glados` seed is pinned; the suite explores broadly and relies on shrinking. Each property was shown to fail (and shrink to a minimal counterexample) against a deliberately-inverted engine stub before passing against the real engine.
- [ ] Every scheduling constant/identifier is referenced by name (`cycleCeilingDays`, `targetR`, `kFarMinS`, `kSelfConfidence`, `Track.far`, `Grade.again`, `Source.teacher`) — no inlined `0.5`/`60`/track-index literal.
- [ ] INV-6 is asserted as a finite non-null `dueAt` over generated histories, **not** as a copy-grep for "safe to drop"; the non-nullable `dueAt` type forecloses the rest.
- [ ] The `engine/` dependency line stays `meta` (+ `models`) + `dev_dependencies: test`, `glados` — verifiable by grep and the E04-T01 purity gate; `dart format` and `dart analyze --fatal-infos` are clean over the test file.

## Tests

This task **is** the test artifact — `packages/engine/test/invariants_test.dart`, `package:test` + `package:glados`, run with `dart test` in the `engine/` package (CI `fast` job; PRD §20 gate 4). Pure Dart: no `flutter_test`, no widget binding, no `FontLoader`, no `HttpOverrides` (the engine opens no socket, so there is nothing to guard — its purity is enforced by the E04-T01 banned-import grep gate, not a runtime override). `today` is a constructed `SerialDay` literal/generated integer; elapsed and day counts are integer arithmetic; no `DateTime`, no clock, no `Random`.

The six properties, each over `any.scheduleCase` with shrinking:

- **INV-1 — trust clamp**: for every memorized card after its replayed history, `card.dueAt.value − today.value ≤ cycleCeilingDays(card, config)`. (Shared with E04-T07, which lands it test-first; this file is its home in the register.) Covenant named at the assertion.
- **INV-2 — manzil never dropped**: for every generated card set, `buildToday(cards, today).allPageIds` `containsAll` the page ids of every due FAR card (`track == Track.far && dueAt.value <= today.value`) — even when the load balancer (E04-T09) defers Near and reduces New, dhor is never cut.
- **INV-3 — a lapse demotes**: after any history, one teacher `Again` yields `after.s ≤ before.s` and `after.track.index ≤ before.track.index` — never grows stability, never promotes a track.
- **INV-4 — determinism (fuzz OFF)**: two `buildToday` runs over the same replayed cards + `today` are `fingerprint`-equal; identical inputs → byte-identical plan. The property fails loudly if interval fuzzing or any `Random` is reintroduced.
- **INV-5 — teacher overrides self**: a self `Good` followed by a teacher `Again` leaves `weakFlag` set and `dueAt` no later than the self-only state — the teacher's verdict supersedes and can only pull the page forward.
- **INV-6 — never "safe to drop"**: every memorized card in every generated history has a finite, non-null `dueAt` bounded by `today + cycleCeilingDays(card, config)` — there is no engine state that means "stop revising this page."

Verification harness for the test-first step: each property is first run against a deliberately-broken stub (`max`-clamp → INV-1 fails and shrinks; `S`-growing lapse → INV-3 fails; manzil-dropping `buildToday` → INV-2 fails; self-wins branch → INV-5 fails; a `Random`-fuzzed interval → INV-4 fails), confirming the property can detect the regression and the counterexample shrinks to a one- or two-review case, before the stub is removed and the real engine passes. No widget, golden, or integration test — `engine/` renders nothing; these are pure property tests.

## Definition of Done

- [ ] All acceptance criteria met; the six-property suite is green under `dart test` in the `engine/` package locally and in CI (PRD §20 gate 4); each property was shown to fail-then-shrink against an inverted stub before passing against the real T01–T10 engine.
- [ ] **The trust-clamp covenant (non-negotiable)**: INV-1 (`dueAt − today ≤ cycleCeilingDays`) holds for every memorized card across all generated histories; the `min`-not-`max` covenant is restated in a comment at the assertion (PRD §7.6, §7.12; CLAIMS C-016; domain-scheduling-engine-rules rules 16–18).
- [ ] **Manzil un-skippable**: INV-2 holds — every due FAR/manzil page appears in `buildToday`'s plan, even under load-balanced catch-up; the property would fail if dhor were ever dropped to fit the budget (PRD §7.9).
- [ ] **Never "safe to drop"**: INV-6 holds — every memorized card keeps a finite non-null `dueAt`; the property asserts a finite due day, not a copy-grep, and the non-nullable type forecloses `null`; nothing implies a page is safe to stop revising (PRD §7.12; CLAIMS C-025; science 06 §6).
- [ ] **Teacher supersedes self**: INV-5 holds — a teacher `Again` overrides a prior self `Good`, sets `weakFlag`, and only pulls the page forward; the sanad-respecting ground truth wins (PRD §8.2; domain-scheduling-engine-rules rule 9).
- [ ] **A lapse demotes**: INV-3 holds — `Again ⇒ S' ≤ S ∧ track' ≤ track`; a forgotten page never earns a longer interval or a promotion (PRD §7.7; science 03 §4).
- [ ] **Offline / no-network**: the test file opens no socket and links no http/analytics SDK; the `engine/` dependency line stays `meta` (+ `models`) with `test`/`glados` as dev deps only — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone**: the properties consume only generated `Card`/`ReviewInput`/`today` — no model, optimizer, ASR, or audio; the FSRS weights are *used*, never *fitted*; the grade is a human signal produced upstream (PRD C2; engineering 06 §8).
- [ ] **Determinism**: INV-4 holds and is the suite's own guard — no `DateTime.now()`, no `Random`, no I/O reachable from the test or the engine; `today` is a constructed `SerialDay`; interval fuzzing stays OFF; identical inputs → byte-identical plan (PRD §7.12; engineering 06 §3, §8).
- [ ] **Quran text fidelity**: N/A by construction — these properties assert day-count and page-id invariants on opaque ids; they never touch muṣḥaf glyphs or layout and cannot reflow or re-typeset sacred text. The boundary is stated, not assumed (PRD R1).
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — the engine and its tests are locale-blind serial-integer arithmetic emitting opaque page ids and day counts; no locale, numeral, calendar, or user-facing string appears in the test (those belong to E02 and the fa/ckb/ar UI that renders the plan).
- [ ] **Accessibility**: N/A by construction — `engine/` and its tests render no widget; accessibility lives wherever the day plan is displayed (E11/E12/E15).
- [ ] **Sect-neutral adab**: the suite introduces no streak, score, badge, or shame surface and asserts none; it pins covenants that keep the engine honest (manzil mandatory, teacher supersedes, never "safe to drop"), never a madhhab/sect ruling (PRD R3; CLAIMS C-025).
- [ ] **No unsourced number**: this task renders no number; the covenants trace to already-graded CLAIMS rows (C-016 the guarantee, C-025 the no-promise honesty) and no citation or CLAIMS id is invented (domain-claims-register-and-science-screen).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); each property names its covenant in a comment; constants are referenced by name (no magic literals); `dart format` and `dart analyze --fatal-infos` clean; no `print`/`debugPrint`; no fixed lucky `glados` seed; shrinking is relied on for the minimal counterexample (eng-write-engine-golden-vector; eng-write-dart-test).
