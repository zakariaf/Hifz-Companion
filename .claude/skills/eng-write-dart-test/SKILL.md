---
name: eng-write-dart-test
description: Write or extend a Dart/Flutter test for the Hifz Companion app — engine unit/golden-vector/property tests, widget tests, RTL and muṣḥaf goldens, or an integration_test journey — to the test-pyramid and coverage policy. Use whenever adding `package:test`/`flutter_test`/`integration_test` coverage, a `glados` invariant property, a `matchesGoldenFile` golden, an `HttpOverrides` offline guard, or pinning the FSRS-style arithmetic with frozen vectors.
---

# eng-write-dart-test

A test in this repo is not a safety net you add later — it is the mechanism that turns each of the eight release-blocking gates (PRD §20) into a check a build either passes or fails. The pure-Dart `engine` is testable by construction (zero I/O, `today` injected), so the product's hardest logic lands at the cheapest tier; the device tier is reserved for the four make-or-break journeys. Two outranking covenants decide what gets tested hardest: **the sacred text is never put at risk** (real-font muṣḥaf goldens, the text-integrity hash) and **the engine may only make a page more frequent, never less** (the trust-clamp property). Every test below traces to `docs/engineering/11-testing-strategy.md` and the style rules in `docs/engineering/03-coding-standards.md`.

This skill places a new or extended test at the right tier of the pyramid (broad pure-Dart base → widget/golden middle → thin `integration_test` apex), wires it to the correct runner (`dart test` for `engine`, `flutter test` elsewhere), pins it deterministically (injected `SerialDay`/`CalendarDate`, no wall clock), tags goldens for the pinned-OS CI job, and keeps it offline by construction (a throwing `HttpOverrides`). Come here to add any coverage; go to the domain skills for the *rules* the test asserts.

## When to use

Use this skill when you:

- add or extend a **unit test** for engine arithmetic, cold-start seeds, the load balancer, `CalendarDate`/`SerialDay` day-math, or a DAO query (`docs/engineering/11-testing-strategy.md` §1, §2);
- pin the FSRS-style arithmetic with a **frozen golden-vector** row — curve, interval inversion, S/D update, trust clamp, or a cold-start seed (`docs/engineering/11-testing-strategy.md` §3);
- encode a PRD §7.12 invariant as a **`glados` property test** with shrinking (INV-1…INV-6) (`docs/engineering/11-testing-strategy.md` §4);
- add a **widget test** for the reveal-on-tap recite/grade flow, the heat-map, the catch-up banner, or the teacher sign-off toggle (`docs/engineering/11-testing-strategy.md` §6);
- capture a **muṣḥaf-fidelity golden** with the real KFGQPC fonts, or an **RTL/layout golden** per `ar`/`fa`/`ckb` locale (`docs/engineering/11-testing-strategy.md` §5, §6);
- write one of the four **`integration_test` journeys** — cold start → first day → review → missed-day catch-up (`docs/engineering/11-testing-strategy.md` §6);
- install or verify the **no-network offline guard** (a throwing `HttpOverrides`, the banned-import scope) in a test bootstrap (`docs/engineering/11-testing-strategy.md` §7).

Do **NOT** use this skill for:

- authoring the engine *rules* a test pins — the curve, trust clamp, tracks, cold-start priors → use **domain-scheduling-engine-rules** (this skill asserts those outputs; it does not define them).
- the SHA-256 asset-pack manifest, the runtime verifier, or the CI text-integrity hashing → use **domain-asset-pack-integrity** (this skill may *call* the hash check in a journey, but the integrity contract lives there).
- the muṣḥaf glyph-rendering / text-fidelity rules a fidelity golden compares against → use **domain-mushaf-text-integrity** (this skill freezes the pixels; that skill defines what correct pixels are).
- the review→persist write path the grading widget/journey drives → use **domain-grading-pipeline**.
- the `pubspec.yaml`, `dev_dependencies`, workspace wiring, or a new package's `test/` skeleton → use **eng-create-package** (it wires `test`/`glados`/`flutter_test`; come back here to author the cases).
- standing up a **new CI job** (a new GitHub Actions step or tag) rather than a test → follow the CI shape in `docs/engineering/11-testing-strategy.md` §8 (the fast / golden / restraint / journeys jobs and the PRD-gate→job mapping); this skill authors the test that a job *runs*, not the job.

## The canonical pattern

### 1. Put the test at the right tier (do not invert the pyramid)
Place mass at the cheapest tier: almost everything is a **unit or property test on `engine`/the DAOs**; widget+golden tests cover screens; `integration_test` is reserved for the **four** make-or-break journeys and nothing else (`docs/engineering/11-testing-strategy.md` §1, table). Anything expressible as `(card, grade, today) → card'` is a unit/property test on `engine`, **never** a widget pump — driving the deterministic core through `pumpWidget` is slower, flakier, and hides which layer broke. Do not grow the journey suite past the four PRD flows without a decision-log amendment (`docs/engineering/11-testing-strategy.md` §1, §6 pitfalls).

### 2. Test the engine with `package:test`, never `flutter_test`
The pure-Dart `engine` package is tested with standalone **`package:test`** — `test()`/`expect()`/`group()`/`setUp()`, files ending `_test.dart` under the package's `test/`, run with `dart test` — and never imports `flutter_test` or needs a widget binding (`docs/engineering/11-testing-strategy.md` §2). The CI engine-purity import gate fails the build if `engine/` imports anything from Flutter (`docs/engineering/03-coding-standards.md` §6, §7.2). Construct `today` as a literal `SerialDay`/`CalendarDate`; nothing in the engine or its test reads a wall clock (`docs/engineering/11-testing-strategy.md` §2).

### 3. Inject `today`; never `DateTime.now()`
Determinism comes from injecting time. The engine takes `today` as its last argument, so engine tests need no clock fakery at all (`docs/engineering/11-testing-strategy.md` §2). `DateTime.now()` is banned anywhere reachable from the engine — the day type is an integer `SerialDay` constructed directly (`docs/engineering/11-testing-strategy.md` §2 pitfalls; `docs/engineering/03-coding-standards.md` §1.1.3 — a `DateTime` named like a day is a review-blocking defect). For the *app layer* around the engine (notification scheduling, "days since" displays), use `clock`/`fake_async` with `withClock(Clock.fixed(...))`, never the real clock.

### 4. Pin the FSRS arithmetic with frozen golden vectors, asserted to tolerance
Pin the math as a committed `(state, grade, elapsed) → (D, S, due offset)` table asserted with `closeTo(expected, 1e-6)` — never `==` on doubles (`docs/engineering/11-testing-strategy.md` §3). Cover every branch: the curve, the interval inversion, both stability branches (success vs lapse), the difficulty update, the trust clamp, and the five cold-start seeds (Solid `D=3,S=60`; Shaky `D=5,S=14`; Rusty `D=7,S=4`) (`docs/engineering/11-testing-strategy.md` §3 table). Vectors are regenerated **only** by an explicit, human-reviewed `--update-vectors` run; CI only ever *verifies*, never blesses (`docs/engineering/11-testing-strategy.md` §3 pitfalls). Name FSRS constants (`DECAY`, `FACTOR`) — never magic numbers (`docs/engineering/03-coding-standards.md` §1.1.1, §4).

### 5. Encode each PRD §7.12 invariant as a `glados` property
Universal claims are property tests, not point fixtures: write a custom generator (`Any` + `combine`) that builds random `(Card, grade-sequence, today)` histories, then assert each invariant over all of them, relying on `glados` shrinking for the minimal counterexample (`docs/engineering/11-testing-strategy.md` §4). The register is **INV-1** `dueAt ≤ cycleCeiling` (the trust clamp), **INV-2** every due FAR/manzil page is in `buildToday`, **INV-3** `Again ⇒ S' ≤ S ∧ track' ≤ track`, **INV-4** two `buildToday` runs are fingerprint-equal (fuzz OFF), **INV-5** a teacher `Again` overrides a prior self `Good`, **INV-6** every memorized card has a finite `dueAt` — the engine can never return "drop"/`null` (`docs/engineering/11-testing-strategy.md` §4 table). Do not pin a lucky fixed seed that hides regressions.

### 6. Muṣḥaf-fidelity goldens: real glyphs, pinned everything, `@Tags(['golden'])`
Load the **real bundled KFGQPC page fonts and UI fonts via `FontLoader`** in `setUpAll` — never the Ahem placeholder, which renders every glyph as a solid square and would defeat the test (`docs/engineering/11-testing-strategy.md` §5). Fix `devicePixelRatio`, `physicalSize`, theme, and disable animations; `await expectLater(finder, matchesGoldenFile('goldens/...'))`. Tag with `@Tags(['golden'])` so the test runs only in the pinned, Linux-only golden CI job (`docs/engineering/11-testing-strategy.md` §5, §8). A dropped or shifted diacritic must change pixels and fail the build — this is the outranking text-fidelity covenant (`docs/engineering/03-coding-standards.md` §8.1 sacred-text checklist). Regenerate masters with `--update-goldens` **locally** only; CI never blesses.

### 7. RTL is asserted by construction, per locale
Pump each key screen under `Directionality(textDirection: TextDirection.rtl)` for `ar`/`fa`/`ckb`, with the locale's numerals and calendar, and golden-capture it per locale — the concrete artifact for gate 5 (`docs/engineering/11-testing-strategy.md` §6). All three languages are RTL by construction; a test must never assume LTR (`docs/engineering/03-coding-standards.md` §1.1.4 sacred-domain terms; `docs/engineering/02-project-structure.md` §2 via testing-strategy §6). RTL/layout goldens *may* use the font-independent strategy (Ahem/colored blocks) so they stay green across contributor machines — that strategy is **forbidden** for fidelity goldens (§6), which assert exact KFGQPC shapes.

### 8. Offline is a test invariant: a throwing `HttpOverrides`
Every test keeps the test binding's default 400-block **and** installs an `HttpOverrides` that *throws* on any connection attempt, so a stray network call is a loud, named failure — not a silent 400 (`docs/engineering/11-testing-strategy.md` §7). Only the single asset-downloader test opts out (it resets `HttpOverrides.global` to a mock in its own `setUp`). Networking imports (`package:http`, `dart:io HttpClient`, `package:dio`) are banned everywhere but the one downloader module by the analyzer (`docs/engineering/03-coding-standards.md` §7.2). The airplane-mode acceptance run proves every post-onboarding screen works with zero network.

### 9. Real stack only in `integration_test`; fakes everywhere else
Widget tests use **in-memory fakes** for the Drift store and asset loader (injected via Riverpod overrides), so they stay fast and headless; only the four `integration_test` journeys run the **real** Drift/SQLite + asset + render stack on an emulator after `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` (`docs/engineering/11-testing-strategy.md` §6). Never let a widget test touch a real database or assets; never `pumpAndSettle()` where an indicator is intentionally indefinite — pump explicit durations (`docs/engineering/11-testing-strategy.md` §6 pitfalls).

### 10. Coverage is published, never a gate; assert behaviour, not lines
Run `flutter test --coverage`, strip generated files (`*.g.dart`, `*.drift.dart`, `*.freezed.dart`, `*/generated/*`) from `lcov.info`, and publish for OSS auditability — but set **no global percentage gate** (`docs/engineering/11-testing-strategy.md` §10). A covered line that asserts nothing is worthless; the engine's invariants (§4) and frozen vectors (§3) are the real bar. A test that exercises a path without an `expect` is a review reject.

### 11. Hold the test itself to the coding standards
Tests obey the same style as production code: full dictionary words and unit-bearing names (`stabilityDays`, not `s`, outside one short transcription scope), Effective Dart casing, `dart format` output, typed `catch` (never bare), no `print`, no `!`/`late` shortcuts on engine/persistence values (`docs/engineering/03-coding-standards.md` §1, §3, §5). Every Dart test file carries the REUSE SPDX header (`GPL-3.0-or-later`) (`docs/engineering/03-coding-standards.md` §4 via 13 §2). A `// dart format off` region is allowed only around a hand-laid vector table where alignment *is* the documentation, with a justifying comment (`docs/engineering/03-coding-standards.md` §3).

## Do / Don't

| Do | Don't |
|---|---|
| Put `(card, grade, today) → card'` logic in a `dart test` unit/property test on `engine` | Drive the engine through `pumpWidget`, or push unit-able logic into a device journey |
| Test `engine` with `package:test` only; construct `today` as a literal `SerialDay` | Import `flutter_test` into `engine`, or read `DateTime.now()` anywhere reachable from it |
| Assert float vectors with `closeTo(expected, 1e-6)`; name `DECAY`/`FACTOR` | Use `==` on doubles, or hard-code magic constants in the vector table |
| Regenerate vectors/goldens with `--update-vectors`/`--update-goldens` locally, reviewed in the diff | Auto-bless vectors or goldens in CI (the gate would assert nothing) |
| Encode each PRD §7.12 invariant as a `glados` property over generated histories | Cover an invariant with one example, or pin a lucky fixed seed that hides regressions |
| Load real KFGQPC fonts via `FontLoader`; pin DPR/size/theme; `@Tags(['golden'])` | Render fidelity goldens with Ahem, or run them on un-pinned/macOS CI |
| Pump key screens under `Directionality.rtl` per `ar`/`fa`/`ckb` with locale numerals | Assume LTR, or test only one locale |
| Keep the throwing `HttpOverrides` installed in the test bootstrap | Rely on the default 400 alone, or let any test but the downloader's reach the network |
| Use in-memory fakes in widget tests; the real Drift/asset stack only in `integration_test` | Let a widget test hit a real DB/assets, or `pumpAndSettle()` an indefinite indicator |
| Add an `expect` that asserts behaviour; publish coverage for transparency | Treat a covered-but-unasserted line as tested, or gate on a coverage percentage |
| Add the REUSE SPDX header; full-word names; typed `catch`; `dart format` clean | Use `print`/`!`/`late`/bare `catch` in a test, or single-letter domain names |

## Checklist

Before the test is done:

- [ ] It lives at the cheapest tier that can assert the behaviour: unit/property on `engine`/DAOs by default; widget for a screen; `integration_test` only for one of the four PRD journeys.
- [ ] An `engine` test imports `package:test` (not `flutter_test`), needs no widget binding, and constructs `today` as a literal `SerialDay`/`CalendarDate` — no `DateTime.now()` anywhere reachable.
- [ ] Frozen FSRS vectors cover the branch under test (curve / interval / success-S / lapse-S / difficulty / trust clamp / a cold-start seed) and assert with `closeTo(_, 1e-6)`; constants are named, not magic.
- [ ] Each relevant PRD §7.12 invariant (INV-1…INV-6) is a `glados` property over a generated `(Card, grades, today)` history; shrinking is relied on, no fixed lucky seed.
- [ ] Muṣḥaf-fidelity goldens load the **real** KFGQPC + UI fonts via `FontLoader` (never Ahem), pin DPR/size/theme, disable animations, are `@Tags(['golden'])`, and `await expectLater(..., matchesGoldenFile(...))`.
- [ ] RTL/layout goldens pump each key screen under `Directionality.rtl` for `ar`/`fa`/`ckb` with per-locale numerals/calendar; the font-independent strategy is used here but never for fidelity goldens.
- [ ] The throwing `HttpOverrides` (offline guard) is installed via the shared bootstrap; only the asset-downloader test opts out and resets it in its own `setUp`.
- [ ] Widget tests use in-memory fakes (Riverpod overrides) for store/assets; the real Drift/SQLite + asset stack appears only in an `integration_test` journey after `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`; no `pumpAndSettle()` on an indefinite indicator.
- [ ] Every test asserts behaviour (a meaningful `expect`); no coverage-percentage gate is introduced; generated files are stripped from any `lcov.info`.
- [ ] Grading/teacher tests respect the covenants: a dropped/altered word is never graded "Good" (sacred-text guard); a teacher sign-off supersedes self-rating (INV-5); nothing implies a page is "safe to drop" (INV-6) — sect-neutral, no streak/score assertions.
- [ ] The test obeys coding standards: REUSE SPDX header, full-word/unit-bearing names, Effective Dart casing, `dart format` clean, typed `catch`, no `print`/`!`/`late` on engine/persistence values.

This skill writes the *checks*, not the *contracts* they enforce. The text-fidelity, sect-neutrality, no-gamification, servant-to-teacher, and privacy non-negotiables are defined in the domain docs/skills below and merely *proven* here — a fidelity golden proves the glyph is untouched, an INV-5 property proves the teacher's verdict wins, the throwing `HttpOverrides` proves the app stayed offline. A test that would weaken any covenant (grading a dropped word "Good", introducing a streak/score assertion, or letting a network call succeed) is itself the bug.

## Files

- `template.dart` — copy-paste scaffolds for each tier: a pure `engine` unit test (`package:test`, injected `today`), a frozen golden-vector table + assertion, a `glados` invariant property, a muṣḥaf-fidelity golden (real `FontLoader`), an RTL/locale golden, a widget test with in-memory Riverpod fakes, an `integration_test` journey, and the throwing-`HttpOverrides` bootstrap. Fill every `// TODO:`.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-scheduling-engine-rules** (the curve/trust-clamp/track rules the vectors and properties assert), **domain-mushaf-text-integrity** (what a correct fidelity-golden pixel is), **domain-asset-pack-integrity** (the SHA-256 hash a journey may call), **domain-grading-pipeline** (the review→persist path a grading widget/journey drives), **eng-create-package** (wires `test`/`glados`/`flutter_test` into the package this test lives in).
