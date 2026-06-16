# E04-T10 — The FSRS weight vector and engine constants as data with a length assert

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | S (≈0.5-1 day) |
| **Depends on** | E04-T03 |
| **Skills** | domain-scheduling-engine-rules, eng-write-engine-golden-vector |

## Goal

The published FSRS-4.5 19-element default weight vector and the named engine constants exist as **data in exactly one place** in the pure-Dart `engine/` package — `kFsrsWeightCount = 19`, `kMinStability`, `kMaxInterval = 36500`, `kSelfConfidence = 0.5`, `kLapseDifficultyBump = 1.0`, `kWeakLineFactor = 0.15`, `kHardFloorR = 0.85`, and `kDefaultWeights45` — never inlined as magic numbers across the code. The `EngineConfig` (or `SchedulingEngine`) constructor runs `assert(weights.length == kFsrsWeightCount)` so a 19-vs-21 (FSRS-6) mismatch fails **loudly** at construction instead of silently mis-scheduling every interval. `kDefaultWeights45` is commented as a flashcard-population *average* — a prior, not a hifz-fitted set — and ships with **no optimizer** (no telemetry to train on). `kDecay`/`kFactor` stay *computed* (from E04-T03), so an FSRS-6 adoption is the one-line `kDecay = -w[20]` change with the count bumped to 21. A test-first vector pins the length assert (a 20-element vector throws) and the exact default vector against `dart-fsrs`' `kDefaultWeights45` as the independent oracle.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §7.3 (The forgetting curve & interval) | The governing honesty rule the constants carry: the FSRS parameters "come from recognition-task research and are a **starting prior only**" — the engine never *depends* on their precision; the §7.6 cycle ceiling is the real guarantee, and they are tunable from the user's own lapse history by plain curve-fitting, **no ML service**. This is why the default weights are commented as a flashcard average, not hifz-fitted, and why no optimizer ships |
| `docs/engineering/06-scheduling-engine.md` §8 (determinism, weights, golden vectors) | The verbatim `const` block this task implements — `kFsrsWeightCount = 19`, `kMinStability = 0.1`, `kMaxInterval = 36500`, `kSelfConfidence = 0.5`, `kLapseDifficultyBump = 1.0`, `kWeakLineFactor = 0.15`, `kHardFloorR = 0.85`, and the exact 19-element `kDefaultWeights45` list; the rationale that "mixing weight-vector lengths silently corrupts every interval" (FSRS-4.5/5 = 19, FSRS-6 = 21 adding `w19`/`w20`), so the length is asserted at load; "FSRS-6 readiness costs one line" via computed `kDecay`/`kFactor`; the refusal to inline the weight vector across the code and the refusal of any optimizer (no telemetry) |
| `docs/engineering/06-scheduling-engine.md` §1 (vendored FSRS, purity) | The `SchedulingEngine(config) : assert(config.weights.length == kFsrsWeightCount)` shape — the length guard lives on the one stateless façade's constructor; the package imports no Flutter, opens no DB, reads no clock, consumes no randomness |
| `docs/engineering/06-scheduling-engine.md` §3 (forgetting curve and interval) | The contract this task must *not* break: `kDecay`/`kFactor` already live in `curve.dart` (E04-T03) as the ONLY place the curve constants live, `kFactor` computed from `kDecay`; this task adds the *weight vector and the named tunables*, references `kMaxInterval` by the name E04-T03's `interval` clamp already uses, and never re-declares `kDecay`/`kFactor` |
| Skill `domain-scheduling-engine-rules` (+ `template.dart`) | Rule 22 — "Weights are data with a length assert; defaults documented as flashcard averages. `assert(weights.length == kFsrsWeightCount)` at construction (19 for FSRS-4.5/5, 21 for FSRS-6); a 19-vs-21 mismatch must fail loudly, not silently mis-schedule. The shipped vector is a flashcard population average, never a hifz-fitted set, and we never ship the optimizer (no telemetry, nothing to train on)." The Do/Don't row "Assert `weights.length == kFsrsWeightCount` … / Inline the weight vector" and the purity rule (rule 2) the constants live inside |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | Pattern 10 — "every scheduling constant is referenced by name (`kLapseDifficultyBump`, `kSelfConfidence`, `kFarMinS`, `targetR`), never as a literal — so an FSRS-6 bump is one reviewed re-freeze"; pattern 8 — the exact default vector is pinned against `dart-fsrs` (`enableFuzzing: false`, `kDefaultWeights45`) as the independent oracle, never the engine under test; pattern 1 — the vector lives under `engine/test/`, `package:test` only, no `flutter_test`/widget binding/network |
| `docs/science/03-spaced-repetition-algorithms.md` §5, §6 | §5 — FSRS chosen because it is the only model that is both two-component *and* open/local/auditable, which is what makes vendoring a fixed published vector legitimate; §6 — **no optimizer/telemetry**: we ship the population-average prior and refuse to fit one, because fitting requires the review history we deliberately never collect or upload (the no-network, no-AI non-negotiables) |
| `docs/science/CLAIMS.md` C-010, C-017, C-025 | C-010 **[TEXT]** — the curve/constants are "a standard, open spaced-repetition curve … constants are a **starting prior**, tunable from the user's own lapse history (no ML, no network)"; C-025 **[OBS]** — "we can't promise you'll never forget … near-100% comes from the cycle ceiling, not a magic number," the caveat every "why FSRS" claim carries; C-017 **[TEXT]** — stakes-tiered targets, never a global 0.99. This task surfaces **no new user-facing number** — the weights and `k*` constants are internal engine data; their *meaning* is glossed on the science screen (E19), which renders these already-graded rows. Invent no citation or CLAIMS id |
| Siblings: E04-T01, E04-T03, E04-T04, E04-T05, E04-T07, E04-T09, E04-T11 | T01 scaffolded the pure-Dart `engine/` package and the banned-import grep gate these constants live behind; **T03 (this task's dependency)** already declares `kDecay`/`kFactor` (computed) in `curve.dart` and its `interval` clamp already references `kMaxInterval` by name — this task supplies that named constant and the weight vector; T04's `onReview` consumes `kSelfConfidence` (source scaling), `kLapseDifficultyBump` (lapse branch), `kWeakLineFactor` (weak-line channel); T05's `targetR` uses the retention tiers; T07's load-balance deferral floor is `kHardFloorR`; T09's `loadBalance` uses `kHardFloorR`; T11's INV register runs over an `EngineConfig` whose `weights.length == kFsrsWeightCount` assert this task installs |

## Implementation notes

TEST-FIRST: the length assert is correctness-critical — a silent 19-vs-21 mismatch corrupts *every* interval the engine emits. Write the two guard cases below **before** wiring the assert: a 19-element vector constructs cleanly, and a 20-element vector throws an `AssertionError` at construction. Both must exist and fail before the constructor guard is added.

1. **File** (in the package scaffolded by E04-T01, beside `curve.dart` from E04-T03): `packages/engine/lib/src/constants.dart` holds `kFsrsWeightCount`, `kMinStability`, `kMaxInterval`, `kSelfConfidence`, `kLapseDifficultyBump`, `kWeakLineFactor`, `kHardFloorR`, and `kDefaultWeights45`. Re-export it from the `packages/engine/lib/engine.dart` barrel (library `hifz_engine`). The file carries the REUSE SPDX header (`GPL-3.0-or-later`) and imports **nothing** — no `dart:math` (that belongs to `curve.dart` for `pow`), no Flutter, no `dart:io`, no `Random`. These are plain `const` data.

2. **The named constants, verbatim engineering 06 §8** — each with a `///` doc naming what it is and the doc/PRD section it implements:
   ```dart
   /// Number of FSRS weights this engine expects. 19 for FSRS-4.5/5; 21 for
   /// FSRS-6 (which adds w19 and the trainable curve decay w20). The weight
   /// vector's length is asserted == this at construction (06 §8): a 19-vs-21
   /// mismatch must fail LOUDLY, not silently mis-schedule every interval.
   const int kFsrsWeightCount = 19;

   /// Stability floor (days). A card's S is never driven below this. (06 §8)
   const double kMinStability = 0.1;

   /// Interval ceiling (days) — ~100 years; matches the reference clamps.
   /// `interval(...)` (E04-T03) clamps to [1, kMaxInterval]. (06 §3 / §8)
   const int kMaxInterval = 36500;

   /// Source-confidence weight for a self-rating; teacher sign-off is 1.0.
   /// Scales the APPLIED stability gain only. (PRD §8.1/§8.2; 06 §4)
   const double kSelfConfidence = 0.5;

   /// Difficulty bump applied on a lapse (Again). (PRD §7.7; 06 §4)
   const double kLapseDifficultyBump = 1.0;

   /// Difficulty contribution per chronically-weak line, into D. (06 §4)
   const double kWeakLineFactor = 0.15;

   /// Load-balance deferral floor: a Near page above this R may be deferred a
   /// day; manzil/FAR is never deferred. (PRD §7.9; 06 §7)
   const double kHardFloorR = 0.85;
   ```
   Every one of these is the single source of truth — `onReview` (T04), `targetR` (T05), `trustClamp`/`interval` (T03/T07), and `loadBalance` (T09) reference them **by name**, never re-inline the literal. A grep for `0.5`/`1.0`/`0.15`/`0.85`/`36500` at a call site is a review failure (pattern 10).

3. **The default weight vector, commented as a flashcard average** (verbatim engineering 06 §8):
   ```dart
   /// Published FSRS-4.5 default weights (w0…w18). Shipped as the engine's
   /// PRIOR only — these are a FLASHCARD-POPULATION AVERAGE, not a hifz-fitted
   /// parameter set (PRD §7.3; CLAIMS C-010, C-025). We ship NO optimizer: we
   /// collect and upload no review telemetry (PRD C1/C2; science 03 §6), so
   /// there is nothing to fit on. The guarantee is the §6 cycle ceiling, never
   /// these numbers. Length is asserted == kFsrsWeightCount at construction.
   const List<double> kDefaultWeights45 = [
     0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, 1.54575,
     0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, 2.9898, 0.51655, 0.6621,
   ];
   ```
   This is the *only* place the vector appears. No other file re-lists weights; no `w[7] = 0.0046`-style literal anywhere in the engine — every weight read goes through `config.weights[index]` with the index named by its FSRS role in a comment at the read site (T04's concern, not this task's).

4. **The length assert lives on the constructor** (engineering 06 §1). `kDefaultWeights45` is the default that `EngineConfig`/`SchedulingEngine` falls back to; a caller may pass a tuned vector, but its length is guarded the same way:
   ```dart
   class SchedulingEngine {
     SchedulingEngine(this.config)
         : assert(
             config.weights.length == kFsrsWeightCount,
             'FSRS weight count mismatch: got ${config.weights.length}, '
             'expected $kFsrsWeightCount (19=FSRS-4.5/5, 21=FSRS-6). '
             'A length mismatch silently mis-schedules every interval — 06 §8.',
           );
     final EngineConfig config;
   }
   ```
   If `EngineConfig` already exists from a sibling task (T07 carries the named cycle + weights + tunables), add the same `assert(weights.length == kFsrsWeightCount)` to *its* construction path instead of duplicating it — there must be exactly one guarded entry point for a weight vector, wherever the vector first enters the engine. Match whichever construction site the dependency-ordered siblings established; do not create a second `EngineConfig`.

5. **`kDecay`/`kFactor` stay where E04-T03 put them.** This task does **not** move, copy, or redeclare the curve constants — `curve.dart` owns `kDecay = -0.5` and `kFactor = pow(0.9, 1/kDecay) - 1`. The FSRS-6 readiness note is the whole point: when FSRS-6 is adopted, the change is `kDecay = -w[20]` (curve.dart) and `kFsrsWeightCount = 21` (constants.dart) and a reviewed re-freeze of `kDefaultWeights45` — *structural code is untouched* because nothing inlined a length or a weight. State that in the `kFsrsWeightCount` doc comment.

6. **No optimizer, by construction.** Ship `kDefaultWeights45` as a `const` and stop. Do **not** add a `fit`/`optimize`/`train` function, a weight-tuning entry point, a "learn from history" hook, or any field that would accumulate review telemetry for fitting — the no-network and no-AI non-negotiables mean there is no data to train on and no place to send it (PRD C1/C2; science 03 §6). Plain per-user curve-fitting from local lapse history (PRD §7.3) is a *future, local, no-ML* possibility owned by a later epic, explicitly out of scope here.

7. **Pitfalls to avoid**: declaring the weight vector or any `k*` constant in more than one file (the exact "inline across the code" refusal — there is one `constants.dart`); re-declaring `kDecay`/`kFactor` here (they live in `curve.dart`; duplicating them defeats the one-line FSRS-6 swap); inlining `36500`/`0.5`/`1.0`/`0.15`/`0.85` at a call site instead of the named constant (grep-checked, pattern 10); shipping the assert as a runtime `if/throw` that a release build *removes* the protection from — it is an `assert` (the §8 spec) **plus** the test that proves a 20-vector throws, so the contract is pinned in tests, not only in debug asserts (note this explicitly if the team wants the guard live in release: lift it to a `throw ArgumentError` at the single construction site, but keep the test); pinning the default vector's values *from* a hand-typed copy you also assert against (a fixture that agrees with a typo — the oracle is `dart-fsrs`' `kDefaultWeights45`, pattern 8); adding a `fit`/optimizer/telemetry hook (rule 22; the no-AI/no-network covenant); importing `dart:math` or anything into `constants.dart` (it is pure data).

## Acceptance criteria

- [ ] `packages/engine/lib/src/constants.dart` exists, re-exported from the `engine.dart` barrel, carrying the REUSE SPDX header; it imports nothing (pure `const` data — no `dart:math`, no Flutter, no `dart:io`, no `Random`).
- [ ] All eight names are declared exactly once and only in `constants.dart`: `kFsrsWeightCount = 19`, `kMinStability = 0.1`, `kMaxInterval = 36500`, `kSelfConfidence = 0.5`, `kLapseDifficultyBump = 1.0`, `kWeakLineFactor = 0.15`, `kHardFloorR = 0.85`, and the 19-element `kDefaultWeights45` matching engineering 06 §8 verbatim.
- [ ] `kDefaultWeights45.length == kFsrsWeightCount` (== 19); the vector's values equal `dart-fsrs`' `kDefaultWeights45` (the independent oracle), not a re-typed copy asserted against itself.
- [ ] The single weight-vector construction site (`SchedulingEngine`/`EngineConfig`) runs `assert(weights.length == kFsrsWeightCount)` with a message naming the 19-vs-21 / FSRS-6 hazard; there is exactly one guarded entry point, not a duplicated assert.
- [ ] Constructing with a 20-element (or any `!= 19`) vector throws an `AssertionError`; constructing with `kDefaultWeights45` (19) succeeds — both proven by test.
- [ ] `kDecay`/`kFactor` are **not** re-declared here (they remain in `curve.dart` from E04-T03); the `kFsrsWeightCount` doc comment states the FSRS-6 path is `kDecay = -w[20]` + count → 21 + a reviewed weight re-freeze, with no structural change.
- [ ] No optimizer / no telemetry surface ships: there is no `fit`/`optimize`/`train` function, no weight-tuning hook, and no field that accumulates review history for fitting — `kDefaultWeights45` is a `const` prior, full stop.
- [ ] The `k*` constants are referenced **by name** at every call site (T03/T04/T05/T07/T09); no `36500`/`0.5`/`1.0`/`0.15`/`0.85` literal appears at a scheduling call site — verifiable by grep.
- [ ] Every public declaration carries a `///` summary-first doc comment; `dart format` and `dart analyze --fatal-infos` are clean; the `engine/` dependency line is unchanged (`meta` + `models`).

## Tests

`packages/engine/test/constants_test.dart` and the frozen oracle table `packages/engine/test/vectors/weights_vectors.dart`, pure `package:test` (no `flutter_test`, no widget binding, no `FontLoader`, no `HttpOverrides` — `engine/` is pure Dart), deterministic, no clock; run with `dart test` in the `engine/` package. All inputs are explicit literals. Written FIRST (the two length-guard cases must fail before the constructor assert exists):

- **Length assert — happy path**: constructing the engine with `kDefaultWeights45` (length 19) succeeds and exposes the 19-weight config. `expect(kDefaultWeights45.length, kFsrsWeightCount)` and `expect(kFsrsWeightCount, 19)`.
- **Length assert — loud failure**: constructing with a 20-element vector (`[...kDefaultWeights45, 0.5]`) throws an `AssertionError` (`expect(() => SchedulingEngine(configWith(twentyWeights)), throwsA(isA<AssertionError>()))`); an 18-element vector (FSRS-pre / truncation) likewise throws — proving a 19-vs-21 mismatch fails loudly, not silently. The assert message mentions `19`/`21`/FSRS-6.
- **Frozen weight-vector oracle** in `vectors/weights_vectors.dart`: the expected 19 values committed as a human-readable `const` table sourced **once** from `dart-fsrs`' `kDefaultWeights45` (`enableFuzzing` irrelevant here — these are static parameters), asserted element-wise with `closeTo(_, 1e-9)` against `engine`'s `kDefaultWeights45`, so a single mistyped weight fails CI. The table header comments name `dart-fsrs` as the oracle (pattern 8 — never the engine under test).
- **Named-constant values**: pin each tunable to its §8 value — `kMinStability == 0.1`, `kMaxInterval == 36500`, `kSelfConfidence == 0.5`, `kLapseDifficultyBump == 1.0`, `kWeakLineFactor == 0.15`, `kHardFloorR == 0.85` — so an accidental edit to the single source of truth fails a test, not a user's schedule.
- **No-literal / single-source guard** (complements the E04-T01 banned-import grep gate): a grep-style check asserts the weight literals (`0.40255`, `15.69105`, …) and the named-constant literals (`36500`, `0.15`, `0.85`) appear in **no source file other than `constants.dart`**, and that `constants.dart` imports nothing — proving the vector is not inlined across the code and is FSRS-6-swappable by a single edit.
- **No-optimizer guard**: a grep-style check asserts no `fit`/`optimize`/`train`/`telemetry` symbol exists in `engine/lib/`, and `constants.dart` exposes only `const` data — the no-AI/no-network covenant in test form.

(No `glados` invariant property is added here — INV-4 determinism and the trust-clamp INV-1 are E04-T11, which runs over an `EngineConfig` carrying this guarded weight vector. No widget/golden-file/integration test — `engine/` renders nothing and opens no socket.)

## Definition of Done

- [ ] All acceptance criteria met; `constants_test.dart` green under `dart test` in the `engine/` package locally and in CI (PRD §20 gate 3 — engine golden vectors); the two length-guard cases existed and failed before the constructor assert was added.
- [ ] **A 19-vs-21 mismatch fails loudly**: `assert(weights.length == kFsrsWeightCount)` is present at the single weight-vector construction site, with a message naming the hazard; a non-19 vector throws — pinned by test (engineering 06 §8; domain-scheduling-engine-rules rule 22).
- [ ] **No magic numbers / one source of truth / FSRS-6-swappable**: the weight vector and all eight `k*` names live only in `constants.dart`; no scheduling call site inlines them; `kDecay`/`kFactor` stay computed in `curve.dart`, so FSRS-6 is `kDecay = -w[20]` + count→21 + a reviewed re-freeze, no structural change (PRD §7.3; engineering 06 §3, §8; domain-scheduling-engine-rules rule 22; eng-write-engine-golden-vector pattern 10).
- [ ] **No AI / no audio / no microphone / no optimizer**: `kDefaultWeights45` ships as a `const` flashcard-average prior; there is no `fit`/`optimize`/`train` function, no telemetry, and no review-history-accumulating field — there is nothing to train on because nothing is collected or uploaded (PRD C2; engineering 06 §8; science 03 §6).
- [ ] **Offline / no-network**: `constants.dart` opens no socket and links no http/analytics SDK — it imports nothing; the `engine/` dependency line stays `meta` (+ `models`) — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **Quran text fidelity**: N/A by construction — this file holds FSRS parameters and floating-point tunables, never muṣḥaf glyphs or layout; nothing here can reflow or re-typeset sacred text. The boundary is stated, not assumed (PRD R1).
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — these constants are locale-blind numbers consumed only by engine arithmetic; no locale, numeral, or calendar logic leaks into `engine/` (those live in E02 and the fa/ckb/ar UI layer; the weights' lay gloss is the science screen, E19).
- [ ] **Accessibility**: N/A by construction — `engine/` renders no widget; a11y lives wherever the schedule and the science screen are displayed (E12/E15/E19).
- [ ] **Sect-neutral adab**: no streak/score/badge/shame surface and no madhhab/sect ruling is introduced; the constants are a transparent, sourced prior — the default is honestly documented as a flashcard average, never presented as a validated hifz parameter set (PRD R3; CLAIMS C-025).
- [ ] **No unsourced number**: the constants surface **no new** user-facing number — they are internal engine data whose *meaning* is glossed by the already-graded **[TEXT]**/**[OBS]** rows C-010, C-017, C-025 on the science screen (E19); no citation or CLAIMS id is invented (domain-claims-register-and-science-screen; CLAIMS C-010, C-017, C-025).
- [ ] **Deterministic tests**: the default vector is pinned against `dart-fsrs`' `kDefaultWeights45` as the independent oracle (never the engine under test), asserted `closeTo(_, 1e-9)`, and any change is a reviewed re-freeze — CI only verifies (engineering 06 §8; eng-write-engine-golden-vector pattern 8).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on every public API; `dart format` and `dart analyze --fatal-infos` clean; no `print`/`debugPrint` (eng-write-to-coding-standards).
