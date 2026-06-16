---
name: eng-write-engine-golden-vector
description: Write or change a deterministic golden test vector or invariant property test for the Hifz Companion scheduling engine — a frozen `(state, grade, elapsed) → (D, S, due)` row asserted to `closeTo(_, 1e-6)`, plus the `glados` properties that pin every PRD §7.12 invariant (trust clamp never exceeds the cycle ceiling, manzil never dropped, a lapse demotes, teacher overrides, no "safe to drop"). Use whenever pinning the vendored FSRS-style arithmetic, adding or editing `engine/test/vectors/*`, encoding a §7.12 invariant as a property over generated `(Card, grades, today)` histories, or regenerating the frozen oracle table.
---

# eng-write-engine-golden-vector

Pinning the pure-Dart scheduler to known-good outputs. Two complementary artifacts: **golden vectors** — a committed table of `(input state, grade, elapsed days) → (expected D, S, due offset)` rows asserted to a tight float tolerance, the engine equivalent of `matchesGoldenFile` for pixels — and **invariant property tests** — `glados` properties that generate thousands of random review histories and assert the engine's covenants hold for *all* of them. Vectors pin specific points on the curve; properties pin the *rule* across the whole input space.

The whole engine is subordinate to one covenant: **it may only make a page *more* frequent, never less, and never says a page is "safe to drop."** These tests are how that covenant becomes a machine-check that a build either passes or fails. A constant mistyped, a branch reordered, a weight index off-by-one, or a `max` where `min` belongs changes a vector or breaks an invariant and fails CI **before** it can change a ḥāfiẓ's schedule.

## When to use

Use when building or changing:
- a golden-vector row pinning the FSRS arithmetic (curve, interval inversion, both stability branches, difficulty update, the trust clamp) in `engine/test/vectors/`
- the five cold-start seed vectors (Solid `D=3,S=60`→FAR, Shaky `D=5,S=14`→NEAR, Rusty `D=7,S=4`→active)
- a `glados` property encoding a PRD §7.12 invariant (INV-1…INV-6) over generated `(Card, grade-sequence, today)` histories
- the custom `glados` generators (`scheduleCase`, `cardSeed`, `gradedReview`, `serialDayInRange`) those properties run over
- the `--update-vectors` regeneration tool, or a cross-check row pinned against `dart-fsrs` (`enableFuzzing: false`) as an independent oracle

Do NOT use this skill for:
- changing the engine *rule itself* (the curve, the trust-clamp formula, the tracks, cold-start priors) → use **domain-scheduling-engine-rules** (you change a rule there, then come here to pin its test)
- the broader test pyramid — widget tests, `matchesGoldenFile` muṣḥaf/RTL goldens, `integration_test` journeys, the no-network/text-integrity CI gates → use **eng-write-dart-test**
- scaffolding the `engine` package itself, its `pubspec`, or wiring `dev_dependencies: test`/`glados` → use **eng-create-package**
- the grading signal `(grade, error_lines, source)` that *feeds* a vector → use **domain-grading-pipeline**

This skill is the narrow point of **eng-write-dart-test** §3–§4: the engine's deterministic vectors and its invariant properties, nothing else. A test that needs a widget binding, a real database, a font, or the network is the wrong tier — it does not belong in `engine/test/`.

## The canonical pattern

1. **Pure `package:test`, never `flutter_test`.** Vector and property files live under `engine/test/`, end in `_test.dart`, import `package:test/test.dart` (and `package:glados/glados.dart` for properties), and run with `dart test engine/`. No `flutter_test`, no widget binding, no `FontLoader`, no `HttpOverrides` — the engine is pure Dart and so are its tests. `docs/engineering/11-testing-strategy.md` §2 (engine tested with `package:test`); the engine-purity import gate in `docs/engineering/06-scheduling-engine.md` §1 (pure Dart, zero I/O).

2. **`today` is a constructed literal — never a clock.** Every case builds `today` as a `SerialDay` integer (`day(130)`), and elapsed days is `today.value − card.lastReview.value`, plain integer subtraction. Nothing in a vector or property reads `DateTime.now()`; that single wall-clock read would make "identical inputs → identical schedule" untestable. `docs/engineering/11-testing-strategy.md` §2 (injected `today`, no clock fakery); `docs/engineering/06-scheduling-engine.md` §1 (`SerialDay` opaque serial integer, immune to the DST off-by-one).

3. **A golden vector is a frozen oracle row, asserted with `closeTo(_, 1e-6)`.** Each `FsrsVector(d_in, s_in, grade, elapsed, d_out, s_out, notes)` is computed *once* against an independent reference (the FSRS curve/interval identities, or `dart-fsrs` with `enableFuzzing: false` and `kDefaultWeights45`) and committed as a plain Dart data table so the diff is human-readable. Assert `closeTo(expected, 1e-6)`, **never `==`** — `1e-6` is wide enough that benign cross-platform float rounding passes and tight enough that any real arithmetic change fails. `docs/engineering/11-testing-strategy.md` §3 (frozen oracle table, tight tolerance, not equality); `docs/engineering/06-scheduling-engine.md` §8 (anchor vectors + `dart-fsrs` cross-check oracle).

4. **Anchor the curve to its definitional identities.** Two vectors are guaranteed by the FACTOR definition and pin the curve against any accidental edit: `retrievability(S, S) == 0.9` (±1e-9) because `FACTOR` is defined so `R(S,S)=0.9`, and `interval(S, 0.9) == S` because `DECAY = -0.5`. Add the tier multipliers (`interval(100, 0.95) ≈ 45`, `interval(100, 0.97) ≈ 27`) and the lapse clamp (`postLapseStability(d,s,r) ≤ s`, always). `docs/engineering/06-scheduling-engine.md` §3 (curve/interval closed form, `kDecay`/`kFactor` named constants) and §8 (anchor golden-vectors table).

5. **Cover every branch and every cold-start seed.** The vector set must include: an on-time success row (S grows), a lapse row (post-lapse S, `D += kLapseDifficultyBump`, `weakFlag` set), a Hard and an Easy row (the `w[15]`/`w[16]` multipliers), and one row per cold-start seed asserting the exact `(D, S, track)` prior so onboarding can never silently drift. `docs/engineering/06-scheduling-engine.md` §4 (lapse vs success update path, sacred-text guard) and §5 (cold-start seed table); `docs/engineering/11-testing-strategy.md` §3 (cold-start seed vectors pin PRD §7.10).

6. **An invariant is a `glados` property over generated histories, with shrinking.** Each PRD §7.12 invariant is a universal `∀` claim, so it is a `Glados<ScheduleCase>(any.scheduleCase).test(...)` that folds a random grade-sequence onto a random card with an injected `today` and asserts the rule. On failure `glados` shrinks to the minimal counterexample — usually a one- or two-review case a human can reason about. `docs/engineering/11-testing-strategy.md` §4 (invariants as `glados` properties, shrinking); `docs/PRD.md` §7.12 (the five invariants); `docs/engineering/06-scheduling-engine.md` §8 (the property list).

7. **Encode the full INV register.** The six properties, each citing its covenant: **INV-1** `card.dueAt − today ≤ cycleCeilingDays(card, config)` for every memorized card (the **trust clamp**); **INV-2** every due FAR/manzil page appears in `buildToday(...)`'s plan (**manzil never dropped**); **INV-3** `Again ⇒ S' ≤ S ∧ track' ≤ track` (**a lapse demotes**); **INV-4** two `buildToday` runs are fingerprint-equal (**determinism, fuzz OFF**); **INV-5** a teacher `Again` overrides a prior self `Good` for that page (**teacher supersedes**); **INV-6** every memorized card has a finite non-null `dueAt` (**never "safe to drop"** — also foreclosed by the non-nullable type). `docs/engineering/11-testing-strategy.md` §4 (INV register table); `docs/engineering/06-scheduling-engine.md` §6 (trust clamp = `min`, never `max`) and §2 (`dueAt` non-nullable for a memorized card).

8. **Never let the engine under test generate its own fixtures.** Anchor vectors come from the FSRS *definition* (curve/interval identities) and from `dart-fsrs` as an independent oracle, so a fixture cannot "agree with a bug." Regeneration is a local, explicit `dart run tool/gen_vectors.dart --update-vectors` whose output a human reads in the PR diff; CI only ever *verifies* — an auto-bless would make the gate assert nothing (the same failure mode as `--update-goldens` in CI). `docs/engineering/11-testing-strategy.md` §3 (regenerate only by reviewed flag; refuse auto-bless); `docs/engineering/06-scheduling-engine.md` §8 (refuse fixtures generated by the engine under test).

9. **Determinism is itself a property — keep fuzzing OFF.** Every reference scheduler fuzzes long intervals by default, which would break INV-4. The determinism property is what keeps "fuzz OFF" honest if a future refactor reintroduces randomness; any due-date declumping belongs in the testable `loadBalance` peak-smoothing (`±1–2 days`, bounded by the ceiling), never hidden RNG. Do not pin one lucky `glados` seed that happens to pass — let it explore and rely on shrinking. `docs/engineering/06-scheduling-engine.md` §3 (interval fuzzing refused) and §7 (peak smoothing, not RNG); `docs/engineering/11-testing-strategy.md` §4 (refuse a fixed seed that hides regressions).

10. **Name the covenant at its assertion, and the constants by name.** A property asserting a covenant restates it in a comment (`// PRD §7.6: SR may only make a page MORE frequent`); every scheduling constant in a vector is referenced by name (`kLapseDifficultyBump`, `kSelfConfidence`, `kFarMinS`, `targetR`), never as a literal — so an FSRS-6 bump is one reviewed re-freeze, not a magic-number patch. `docs/engineering/06-scheduling-engine.md` §8 (no inlined weight vector; constants named) and §1 (no magic numbers — `FACTOR` computed from `DECAY`).

## Do / Don't

| Do | Don't |
|---|---|
| Keep vectors/properties in `engine/test/`, importing `package:test` + `package:glados` only | Pull `flutter_test`, a widget binding, a `FontLoader`, or `HttpOverrides` into an engine test |
| Build `today` as a `SerialDay` literal (`day(130)`); elapsed = integer subtraction | Read `DateTime.now()` or any wall clock anywhere reachable from the engine |
| Assert vector rows with `closeTo(expected, 1e-6)` | Assert engine floats with `==` (benign rounding would fail the suite) |
| Compute each row once from an independent oracle (FSRS identity or `dart-fsrs`, fuzz OFF) | Let the engine under test generate the fixtures it is then asserted against |
| Anchor the curve to `retrievability(S,S)==0.9` and `interval(S,0.9)==S` | Pin only mid-curve points and miss a definitional drift |
| Cover both stability branches + Hard/Easy + each cold-start seed `(D,S,track)` | Pin only the happy "Good" path and leave lapse/seed drift unguarded |
| Encode each §7.12 invariant as a `glados` property over generated histories | Assert an invariant on one hand-picked card and call the `∀` proven |
| Reference constants by name: `kLapseDifficultyBump`, `kSelfConfidence`, `kFarMinS`, `targetR`, `cycleCeilingDays` | Inline `1.0`/`0.5`/`60`/`0.2346` literals at the call site |
| Regenerate vectors only via the reviewed `--update-vectors`; CI verifies | Auto-bless vectors (or goldens) in CI — the gate would assert nothing |
| Let `glados` explore broadly and rely on shrinking for the minimal counterexample | Pin one lucky seed that happens to pass and hides a regression |
| Restate the covenant in a comment at INV-1/INV-6 (`// PRD §7.6: only MORE frequent`) | Leave a clamp/`min` assertion unexplained, or test INV-6 by copy-grep alone |

## Checklist

Before a vector or invariant test is done:

- [ ] File is under `engine/test/`, ends `_test.dart`, imports `package:test` (+ `package:glados` for properties) and runs green under `dart test engine/` — no `flutter_test`, no widget binding, no fonts, no network.
- [ ] `today` is a constructed `SerialDay` literal; elapsed days is integer subtraction; no `DateTime.now()` / `Random` is reachable.
- [ ] Each golden row is a `FsrsVector(...)` computed once from an independent oracle (FSRS curve/interval identity, or `dart-fsrs` with `enableFuzzing: false` + `kDefaultWeights45`), asserted with `closeTo(_, 1e-6)`, never `==`.
- [ ] The two curve anchors are present: `retrievability(S,S) ≈ 0.9` (±1e-9) and `interval(S, 0.9) == S`; plus the tier multipliers and the `postLapseStability ≤ s` clamp.
- [ ] Coverage spans both stability branches (success grows S; lapse applies post-lapse S, `kLapseDifficultyBump`, sets `weakFlag`), the Hard/Easy multipliers, and one row per cold-start seed asserting exact `(D, S, track)`.
- [ ] The §7.12 invariant register is encoded as `glados` properties: INV-1 trust clamp (`dueAt − today ≤ cycleCeilingDays`), INV-2 manzil never dropped, INV-3 `Again ⇒ S'≤S ∧ track'≤track`, INV-4 determinism (fuzz OFF), INV-5 teacher overrides self, INV-6 every memorized card has a finite non-null `dueAt`.
- [ ] Properties run over generated `(Card, grade-sequence, today)` histories via `any.scheduleCase`; no fixed lucky seed; shrinking is relied on for the minimal failing case.
- [ ] Every scheduling constant is referenced by name (`kLapseDifficultyBump`, `kSelfConfidence`, `kFarMinS`, `targetR`, `cycleCeilingDays`); no inlined `0.5`/`60`/`0.2346`.
- [ ] The trust clamp covenant is named in a comment at INV-1 (`// PRD §7.6: SR may only make a page MORE frequent`); INV-6 is asserted as a finite `dueAt`, not a copy-grep.
- [ ] No "safe to drop" path is introduced: nothing lengthens a ceiling to infinity, retires a page, or returns `null`/"drop" for a memorized card — adab/integrity invariant holds (PRD §7.12, R1, R3).
- [ ] Vectors were regenerated (if at all) only via the human-reviewed `--update-vectors`; the diff is readable and CI only verifies — no auto-bless.

These tests are not gold-plating: gate 3 (engine golden vectors) and gate 4 (invariant property tests) of the PRD §20 release contract are exactly this skill's output. The vectors are the engine's `matchesGoldenFile`; the properties are the covenant — text fidelity and the "nothing decays silently" promise — made mechanically enforceable. An RTL/locale concern never reaches this tier: the engine is locale-blind serial-integer arithmetic; presentation lives above it.

## Files

- `template.dart` — copy-paste starting point: the frozen `FsrsVector` oracle table + its `closeTo(_, 1e-6)` assertion loop, the curve anchors, the cold-start seed rows, and the six `glados` invariant properties with their `scheduleCase` generator. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-scheduling-engine-rules** (defines the curve, trust clamp, tracks, and cold-start priors these vectors and properties assert — change the rule there, pin its test here), **eng-write-dart-test** (the full test pyramid this skill is the engine-vector point of), **eng-create-package** (scaffolds the `engine` package and wires `dev_dependencies: test`/`glados`), **domain-grading-pipeline** (owns the `(grade, error_lines, source)` signal a vector feeds the engine), **domain-mutashabihat-system** (the `(11−D)` difficulty-bump channel an interference vector can pin).
