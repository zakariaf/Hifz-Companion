# E04-T03 — FSRS-4.5 forgetting curve and closed-form interval, with anchor golden vectors

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E04-T02 |
| **Skills** | domain-scheduling-engine-rules, eng-write-engine-golden-vector |

## Goal

The FSRS-4.5 power-law forgetting curve and its closed-form interval inverse exist in the pure-Dart `engine/` package exactly as engineering 06 §3 specifies — `retrievability(elapsedDays, s) = (1 + kFactor·t/s)^kDecay` and `interval(s, targetR) = (s/kFactor)·(targetR^(1/kDecay) − 1)` clamped to `[1, kMaxInterval]` — with `kDecay = -0.5` declared in exactly one place and `kFactor` **computed** from `kDecay` (`pow(0.9, 1/kDecay) − 1` = 19/81) so that the literals `0.2346`, `19`, and `81` appear nowhere in the codebase. The interval is the exact inverse and is **never fuzzed**. Both functions are pinned, test-first, by frozen anchor golden vectors taken from the FSRS *definition* as the independent oracle: `retrievability(S, S) == 0.9` (±1e-9), `interval(S, 0.9) == S`, and the stakes-tier multipliers `interval(100, 0.95) ≈ 45` and `interval(100, 0.97) ≈ 27`, each asserted with `closeTo(_, 1e-6)`. These two functions are the arithmetic backbone every later task (`onReview`, retention tiers, the trust clamp) builds on.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §7.3 (The forgetting curve & interval) | The canonical formulas and constants — `DECAY = -0.5`, `FACTOR = 0.9^(1/DECAY) − 1 = 19/81 ≈ 0.2346`, `retrievability(t, S) = (1 + FACTOR·t/S)^DECAY` with `R(S) = 0.9` by definition, `interval(S, R_target) = (S/FACTOR)·(R_target^(1/DECAY) − 1)` — and the governing honesty rule: these come from recognition-task research and are a **starting prior only**; the engine never *depends* on their precision (the §7.6 cycle ceiling is the real guarantee) |
| `docs/engineering/06-scheduling-engine.md` §3 (forgetting curve and interval) | The verbatim Dart shape: `const double kDecay = -0.5;` and `final double kFactor = pow(0.9, 1 / kDecay) - 1;` as the ONLY place the constants live; `retrievability(int elapsedDays, double s)`; `interval(double s, double targetR)` returning `int` via `.round().clamp(1, kMaxInterval)`; the tier-multiplier table (0.90→1.000·S, 0.95→0.448·S ≈ 2.2×, 0.97→0.266·S ≈ 3.8×); and the two refusals — **no interval fuzzing** (breaks the §7.12 identical-inputs invariant) and **the probability target is never the guarantee** |
| `docs/engineering/06-scheduling-engine.md` §8 (determinism, weights, golden vectors) | The anchor golden-vector table this task implements — `retrievability(10, 10.0) → 0.9` (±1e-9), `interval(10.0, 0.9) → 10`, `interval(100.0, 0.95) → 45`, `interval(100.0, 0.97) → 27` — each with its FSRS-definition source of truth; `const int kMaxInterval = 36500;` and `const int kFsrsWeightCount = 19;` as the named constants the clamp/asserts reference (the full weight vector is E04-T10, not this task); the rule that vectors are computed from the FSRS definition / `dart-fsrs` (`enableFuzzing: false`), never from the engine under test |
| Skill `domain-scheduling-engine-rules` (+ `template.dart`) | Rule 4 — "`kDecay`/`kFactor` live in exactly one place, `kFactor` computed from `kDecay`; `0.2346`/`19/81` appears as no literal — that is what makes the FSRS-6 upgrade a one-line `kDecay = -w[20]` change"; rule 5 — "the interval is the closed-form inverse, never fuzzed, clamped `[1, kMaxInterval]`, `I(S,0.9)=S` exactly; declumping is bounded `loadBalance` peak-smoothing, never hidden RNG"; the purity/no-I/O boundary (rule 2) the functions live inside |
| Skill `eng-write-engine-golden-vector` (+ `template.dart`) | Pattern 4 — anchor the curve to its definitional identities (`retrievability(S,S)==0.9` ±1e-9, `interval(S,0.9)==S`) plus the tier multipliers `interval(100,0.95)≈45` / `interval(100,0.97)≈27`; pattern 3 — a golden vector is a frozen oracle row asserted `closeTo(_, 1e-6)`, **never `==`**, computed once against the independent reference; pattern 8 — never let the engine under test generate its own fixtures; the `engine/test/vectors/` location and the `package:test`-only (no `flutter_test`) tier rule |
| `docs/science/CLAIMS.md` C-010 | The single user-facing claim behind the curve — "the app models how recall fades with a standard, open spaced-repetition curve," value/rule `R(t,S) = (1 + (19/81)·t/S)^(−0.5)` so `R = 0.9` exactly when `t = S`, graded **[TEXT]** (algorithm documentation, not an empirical claim), surfaced on the science screen + engine. This task *implements* C-010's arithmetic and invents no new citation; the science-screen gloss is E19. The flashcard-recognition caveat (C-025) rides every "why FSRS" claim — the ceiling, not this curve, is the promise |
| Siblings: E04-T02, E04-T04, E04-T07, E04-T10, E04-T11 | T02 supplies the `Card` (`s` field) and `Grade`/`Source` enums this task's tests construct; T04's `onReview` calls `retrievability`/`interval` inside the lapse/success branches; T07's trust clamp clamps `interval(...)`'s output to the cycle ceiling (the closed form is the SR-ideal it caps); T10 owns the full weight vector + `kMaxInterval`/`kFsrsWeightCount` constants (this task uses them by name, does not redefine them); T11's INV-4 determinism property relies on this interval being fuzz-free |

## Implementation notes

TEST-FIRST: the curve/interval arithmetic is correctness-critical — it is the backbone every downstream rule multiplies onto. Write the anchor-vector suite below **before** the function bodies; the four definitional anchors (`retrievability(S,S)==0.9`, `interval(S,0.9)==S`, `interval(100,0.95)≈45`, `interval(100,0.97)≈27`) must exist and fail before `retrievability`/`interval` are implemented.

1. **File** (in the package scaffolded by E04-T01, beside the value types from E04-T02): `packages/engine/lib/src/curve.dart` holds `kDecay`, `kFactor`, `retrievability`, and `interval`. Re-export it from the `packages/engine/lib/engine.dart` barrel (library `hifz_engine`). The file carries the REUSE SPDX header (`GPL-3.0-or-later`) and `import 'dart:math'` for `pow` only — no Flutter, no `dart:io`, no clock, no `Random`.

2. **The constants, in exactly one place** (`curve.dart`), verbatim engineering 06 §3:
   ```dart
   /// FSRS-4.5 curve constants — the ONLY place these live (06 §3 / §8).
   /// kFactor is COMPUTED from kDecay so 0.2346 / 19 / 81 is never a literal:
   /// an FSRS-6 bump is the one-line change `kDecay = -w[20]` (06 §8).
   const double kDecay = -0.5;
   final double kFactor = pow(0.9, 1 / kDecay) - 1; // = 19/81 ≈ 0.23456790…
   ```
   `kFactor` is a top-level `final` (a `pow` call cannot be `const`), defined so `R(S,S) = 0.9` by construction. **Do not** write `0.2346`, `0.234567…`, `19 / 81`, or a pre-divided literal anywhere — a grep for those is part of the acceptance check.

3. **`retrievability`** — pure, total, integer-elapsed:
   ```dart
   /// Probability of recall after [elapsedDays] given stability [s] (days).
   /// R(t,S) = (1 + kFactor·t/S)^kDecay ; R(S,S) = 0.9 by definition of kFactor.
   double retrievability(int elapsedDays, double s) =>
       pow(1 + kFactor * elapsedDays / s, kDecay).toDouble();
   ```
   `elapsedDays` is the integer `today.value − card.lastReview.value` the caller (E04-T04) computes by plain `SerialDay` subtraction — this function takes the already-computed `int`, never a `DateTime` or a `SerialDay`, and reads no clock. `.toDouble()` because `pow` returns `num`.

4. **`interval`** — the closed-form inverse, clamped, **never fuzzed**:
   ```dart
   /// Days until R falls to [targetR]. Closed-form inverse of the curve. NEVER fuzzed.
   /// I(r,S) = (S/kFactor)·(r^(1/kDecay) − 1) ; I(S, 0.9) = S at kDecay = -0.5.
   int interval(double s, double targetR) =>
       ((s / kFactor) * (pow(targetR, 1 / kDecay) - 1)).round().clamp(1, kMaxInterval);
   ```
   `kMaxInterval` is the named E04-T10 constant (`36500`), referenced by name, never inlined. The result is `int` days. There is **no fuzz parameter, no `Random`, no jitter** — any later declumping is the bounded `loadBalance` peak-smoothing in E04-T09, not here (rule 5; 06 §3 pitfalls).

5. **Why the multipliers fall out** (for the test comments, not extra code): because `kDecay = -0.5`, every interval is a pure multiple of the `r = 0.90` interval (`I₀.₉ = S`): `0.95 → 0.448·S`, `0.97 → 0.266·S`. So `interval(100.0, 0.95)` rounds to `45` and `interval(100.0, 0.97)` rounds to `27` — these are the E04-T05 stakes-tier costs, computed here exactly. Name them in the vector `notes` so a future reviewer sees they are the §3 table, not magic.

6. **No retention-target *policy* in this task.** `interval` takes `targetR` as a parameter; *which* `targetR` a card gets (0.90/0.94/0.95/0.97+) is `targetR(card)` in E04-T05. This task ships only the arithmetic primitive and its anchors — resist pulling tier *selection* forward (the epic's "math is the guarantee" risk).

7. **Pitfalls to avoid**: inlining `0.2346` / `19 / 81` / `0.234567…` anywhere (the exact thing rule 4 forbids — it would defeat the one-line FSRS-6 swap and is grep-checked); adding an `enableFuzzing` flag, a `Random`, or `±1` jitter to `interval` (rule 5 — fuzzing is OFF, declumping is E04-T09's bounded peak-smoothing); asserting vector rows with `==` instead of `closeTo(_, 1e-6)` (benign cross-platform float rounding would fail the suite — eng-write-engine-golden-vector pattern 3); generating the expected vector values *from* `retrievability`/`interval` themselves (a fixture that agrees with a bug — pattern 8: oracle is the FSRS definition); passing a `DateTime`/`SerialDay` into `retrievability` instead of a pre-subtracted `int` (the function is locale- and clock-blind); forgetting the `[1, kMaxInterval]` clamp (a near-perfect page must still return `≥ 1` day — never 0, never "safe to drop"); redeclaring `kMaxInterval`/`kFsrsWeightCount` here instead of referencing the E04-T10 names.

## Acceptance criteria

- [ ] `packages/engine/lib/src/curve.dart` exists, re-exported from the `engine.dart` barrel, carrying the REUSE SPDX header; it imports `dart:math` only (no Flutter, `dart:io`, clock, or `Random`).
- [ ] `kDecay = -0.5` is declared in exactly one place; `kFactor` is **computed** as `pow(0.9, 1 / kDecay) - 1`; the literals `0.2346`, `0.234567`, `19 / 81` (and any pre-divided equivalent) appear **nowhere** in the package — verifiable by grep.
- [ ] `retrievability(int elapsedDays, double s)` returns `(1 + kFactor·elapsedDays/s)^kDecay` as a `double`; it takes a pre-computed integer elapsed-days and reads no clock.
- [ ] `interval(double s, double targetR)` returns `((s/kFactor)·(targetR^(1/kDecay) − 1)).round()` clamped to `[1, kMaxInterval]` as an `int`; there is **no** fuzz parameter, `Random`, or jitter anywhere in its definition.
- [ ] `kMaxInterval` is referenced by name (the E04-T10 constant), not inlined as `36500`.
- [ ] The four definitional anchors hold: `retrievability(10, 10.0) ≈ 0.9` (±1e-9), `interval(10.0, 0.9) == 10`, `interval(100.0, 0.95) ≈ 45` (`closeTo`, 1e-6), `interval(100.0, 0.97) ≈ 27` (`closeTo`, 1e-6) — each computed from the FSRS definition, not from these functions.
- [ ] Every public declaration carries a `///` summary-first doc comment naming the FSRS formula; `dart format` and `dart analyze --fatal-infos` are clean; the `engine/` dependency line is unchanged (`meta` + `models`).

## Tests

`packages/engine/test/curve_test.dart` and the frozen table `packages/engine/test/vectors/curve_vectors.dart`, pure `package:test` (no `flutter_test`, no widget binding, no `FontLoader`, no `HttpOverrides` — the engine is pure Dart), deterministic, no clock; run with `dart test` in the `engine/` package. All inputs are explicit literals (`elapsedDays`, `s`, `targetR`) — no `DateTime`, no "today". Written FIRST (the anchors must fail before the functions exist):

- **Curve identity anchor** (definitional oracle): `retrievability(10, 10.0)` is `closeTo(0.9, 1e-9)` — `R(S,S) = 0.9` holds because `kFactor` is *computed* from `kDecay`; a second case at another `S` (e.g. `retrievability(60, 60.0)`) confirms it holds for all `S`, not one. A monotonic-decay sanity case: `retrievability(20, 10.0) < retrievability(10, 10.0) < retrievability(5, 10.0)`.
- **Interval identity anchor**: `interval(10.0, 0.9) == 10` and `interval(60.0, 0.9) == 60` — `I(S, 0.9) = S` exactly at `kDecay = -0.5`.
- **Tier-multiplier anchors** (the E04-T05 stakes-tier costs, computed from §3): `interval(100.0, 0.95)` is `closeTo(45, 1e-6)` (≈ 0.448·S) and `interval(100.0, 0.97)` is `closeTo(27, 1e-6)` (≈ 0.266·S); a comment names each as the §3 multiplier table row, not a magic number.
- **Frozen oracle table** in `vectors/curve_vectors.dart`: a small `const` list of `(elapsedDays | s, targetR, expected, notes)` rows for the four anchors above, each value computed **once** from the FSRS curve/interval identity (the independent reference), committed as a human-readable Dart table, and asserted in a loop with `closeTo(_, 1e-6)` (never `==`). No row is computed by calling `retrievability`/`interval` (pattern 8 — a fixture must not agree with a bug).
- **Clamp behavior**: `interval(s, targetR)` for a very high `s`/low `targetR` is clamped to `≤ kMaxInterval`; for a near-1.0 `targetR` it is clamped to `≥ 1` (never `0`, never negative) — the floor is the "no page is ever safe to drop" arithmetic.
- **No-fuzz determinism** (lightweight; INV-4 proper lives in E04-T11): two successive `interval(50.0, 0.9)` calls return the *same* `int` — there is no hidden RNG widening the interval.
- **No-literal / purity guard** (complements the E04-T01 banned-import grep gate): a grep-style check asserts `0.2346`/`19 / 81` appear in no source file and that `curve.dart` references no `DateTime`/`dart:io`/`flutter`/`Random` — the arithmetic is airplane-mode-safe and FSRS-6-swappable by construction.

(No `glados` invariant property is added here — INV-4 determinism and the trust-clamp INV-1 are E04-T11, over generated histories. No widget/golden-file/integration test — `engine/` renders nothing.)

## Definition of Done

- [ ] All acceptance criteria met; `curve_test.dart` green under `dart test` in the `engine/` package locally and in CI (PRD §20 gate 3 — engine golden vectors); the four anchor vectors existed and failed before the function bodies were written.
- [ ] **No magic numbers / FSRS-6-swappable**: `kDecay` is declared once, `kFactor` is computed from it, and `0.2346`/`19`/`81` is a literal nowhere — an FSRS-6 adoption is the one-line `kDecay = -w[20]` change (PRD §7.3; engineering 06 §3, §8; domain-scheduling-engine-rules rule 4).
- [ ] **No fuzzing / determinism**: `interval` is the exact closed-form inverse with no `Random`, jitter, or `enableFuzzing` flag; identical inputs → identical output; any declumping is the bounded E04-T09 `loadBalance` peak-smoothing, never hidden RNG (PRD §7.12; engineering 06 §3; domain-scheduling-engine-rules rule 5).
- [ ] **The probability target is never the guarantee**: this task ships the curve as a *prior* only; it sets no retention policy and makes no promise that R is validated for hifz — the cycle ceiling (E04-T07) is the guarantee, and the flashcard-recognition caveat (C-025) stands (PRD §7.3; engineering 06 §3; CLAIMS C-025).
- [ ] **Offline / no-network**: `curve.dart` opens no socket and links no http/analytics SDK; the `engine/` dependency line stays `meta` (+ `models`) plus `dart:math` — verifiable by grep (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone**: the curve consumes a stability `double` and an elapsed `int` produced upstream by a human-graded review; no model, optimizer, ASR, or audio field is reachable (PRD C2; engineering 06 §8).
- [ ] **Quran text fidelity**: N/A by construction — this file holds floating-point arithmetic over a page's stability, never muṣḥaf glyphs or layout; nothing here can reflow or re-typeset sacred text. The boundary is stated, not assumed (PRD R1).
- [ ] **RTL + fa/ckb/ar localization**: N/A by construction — `retrievability`/`interval` emit opaque numbers; no locale, numeral, or calendar logic leaks into `engine/` (those live in E02 and the fa/ckb/ar UI layer that renders a due date / retention figure).
- [ ] **Accessibility**: N/A by construction — `engine/` renders no widget; a11y lives wherever the schedule is displayed (E12/E15).
- [ ] **Sect-neutral adab**: no streak/score/badge/shame surface, no madhhab/sect ruling; the interval floor is `≥ 1` day so no arithmetic path can ever imply a page is "safe to drop" (PRD R3; engineering 06 §6).
- [ ] **No unsourced number**: the one user-facing claim — that recall is modeled by this standard open SR curve — is the already-graded **[TEXT]** row C-010; no citation or CLAIMS id is invented, and the science-screen gloss is deferred to E19 (domain-claims-register-and-science-screen; CLAIMS C-010).
- [ ] **Deterministic tests**: vectors are computed from the FSRS definition as the independent oracle (never from the engine under test), asserted `closeTo(_, 1e-6)`, and regenerated only by a reviewed flag — CI only verifies (engineering 06 §8; eng-write-engine-golden-vector pattern 8).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `///` docs on every public API; `dart format` and `dart analyze --fatal-infos` clean; no `print`/`debugPrint` (eng-write-to-coding-standards).
