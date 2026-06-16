# E04-T01 — Scaffold the pure-Dart engine package and its purity boundary

| | |
|---|---|
| **Epic** | [E04 — Scheduling Engine](EPIC.md) |
| **Size** | S (≈half a day) |
| **Depends on** | E02 (calendar-and-date-core — the `SerialDay`/`CalendarDate` value type the engine consumes), E03 (models-and-persistence — the `models` value-type package) |
| **Skills** | eng-create-package, domain-scheduling-engine-rules |

## Goal

`packages/engine/` exists as a pure-Dart pub-workspace member whose `pubspec.yaml` is the entire purity audit: `resolution: workspace`, `environment: sdk: ^3.6.0`, dependencies `meta` (+ the `models` value types) and **nothing else** — no `flutter`, no `dart:io`/`dart:ui`, no clock, no RNG, no `dependency_overrides`. A single `lib/engine.dart` barrel sits over a private `lib/src/` tree, `dev_dependencies` are `test` + `glados`, and every Dart file carries the REUSE SPDX header. The skeleton resolves under `dart pub get` in the workspace and passes the engine-purity grep gate — the audit-minimal dependency line *is* the proof that this package can never read a clock, open a database, or render a widget. No scheduling math is authored in this task; this is the boundary, not the logic.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/06-scheduling-engine.md` §1 | The engine is **vendored FSRS arithmetic, not a dependency**: a pure-Dart package with zero I/O — imports no Flutter, opens no DB, reads no clock, consumes no randomness; one stateless `SchedulingEngine(config)` façade whose methods are pure functions of their arguments and the injected `today`; `today` is a `SerialDay` (owned by E02), elapsed-days is integer subtraction. We never link `dart-fsrs` at runtime (read it only as a test oracle). This task creates the package that hosts all of it (logic lands in T02–T11). |
| `docs/engineering/02-project-structure.md` §1.1 | The pub-workspace contract: add `- packages/engine` to the root `pubspec.yaml` `workspace:` list and put `resolution: workspace` in the member manifest (modern successor to `path:`/`dependency_overrides` — the analyzer resolves the whole graph in one context, so an undeclared import is an analysis error). One committed lockfile at the root; no per-package `pubspec.lock`. `environment: sdk: ^3.6.0` on every member. |
| `docs/engineering/02-project-structure.md` §3.3 | The exemplar `engine` manifest: **`engine` depends on `meta` (+ `models`) only** — the absence of any `flutter`/`dart:io`/clock line is itself the audit evidence; `provider`/`get_it`/Bloc are analyzer-banned; the pure package declares `dev_dependencies: test` + `glados` and runs under plain `dart test` (no widget binding). |
| `docs/engineering/02-project-structure.md` §5 | The boundary gates this manifest must satisfy: `dart pub get` resolves with no clash and **no `dependency_overrides`**, the DCM `avoid-banned-imports` lint passes, and the `tool/check_*.sh` greps pass — `check_engine_purity.sh` is the one that reads this tree for `package:flutter` / `dart:io` / `dart:ui` / `DateTime.now()` / `DateTime.timestamp()` / `Random`. (The gate *scripts* are wired in E01; this task supplies a tree they pass.) |
| Skill `eng-create-package` (+ `template.dart` Block A, C, D, E) | The canonical pure-package scaffold: `packages/<name>/` lower_snake_case noun, `resolution: workspace`, `sdk: ^3.6.0`, one `lib/engine.dart` barrel exporting **only** the stable API over private `lib/src/`, the audit-minimal `meta`(+`models`) dependency line, `test`+`glados` dev-deps, **no `utils/`/`helpers/`/`common/`/`core/` junk-drawer folder**, the REUSE SPDX header on every file, and the boundary-gate checklist. Copy Block A verbatim as the manifest starting point. |
| Skill `domain-scheduling-engine-rules` (rules 1–2, checklist row 1) | The purity covenant this boundary must make true: one stateless pure façade; `engine/` imports no Flutter, opens no DB, contains no `DateTime.now()`/`Random`; `today` is injected as a `SerialDay`. This task asserts the boundary; T02–T11 fill in the math the boundary protects. |
| CLAIMS ids | **None.** This task ships no user-facing number, string, or methodology claim — it is a manifest + empty barrel. The CLAIMS rows behind curve constants, retention tiers, and cold-start seeds (C-009, C-010, C-014, C-016, C-017, C-024, C-025, C-042) attach to the *logic* tasks (T03–T10), not here. |
| Siblings: E04-T02 … E04-T11 | T02 adds `Card`/`ReviewInput` value types + enums into `lib/src/` and the barrel; T03 the curve/interval; T04 `onReview`; T05 phases/graduation/retention; T06 cold start; T07 the trust clamp; T08 `buildToday`; T09 the load balancer; T10 the weight vector + constants; T11 the six `glados` invariants. **All eleven depend on this scaffold existing first** — this task creates the package, the barrel, the `lib/src/` and `test/vectors/` directories, and the dependency boundary they all live inside. |

## Implementation notes

This is a scaffold task, not a correctness-critical math task — there are no golden vectors here. The verifiable end state is "the empty package resolves and passes the purity gate," proven by a smoke test plus a grep. Do not author any scheduling logic, value type, or constant; those are T02+.

1. **Place the package and wire the workspace.** Create `packages/engine/`. Add `- packages/engine` to the root `pubspec.yaml` `workspace:` list (create the root workspace manifest if E01 has not, but prefer to depend on it — coordinate so this task only *adds the member line*). Do **not** check in `packages/engine/pubspec.lock`; the one committed lock is at the repo root (02 §1.1).

2. **Author `packages/engine/pubspec.yaml`** — copy `eng-create-package` `template.dart` **Block A** (the PURE package), filling:
   ```yaml
   name: engine
   description: Pure-Dart Hifz scheduling engine — no Flutter, no I/O, "today" injected as a SerialDay.
   publish_to: none
   resolution: workspace
   environment:
     sdk: ^3.6.0
   dependencies:
     meta: ^1.15.0          # @immutable on the value types T02 adds — annotations only
     models:                # the shared value-type package (E03); engine mirrors card/review_log shapes
       path: ../models
   dev_dependencies:
     test: ^1.25.0          # plain `dart test` — NOT flutter_test
     glados: ^1.1.0         # property tests for the §7.12 invariants (T11)
   ```
   Deliberately declare **no** `flutter`, **no** `flutter:` environment line, **no** `http`/`dio`/`crypto`, **no** `drift`/`sqlite3`, **no** `google_fonts`, **no** `provider`/`get_it`/Bloc, and **no** `dependency_overrides`. The empty-but-`meta`(+`models`) line is the whole purity audit (02 §3.3; eng-create-package §4). Keep the manifest one screen long.

3. **Public barrel `packages/engine/lib/engine.dart`** — copy template Block C. SPDX header, then `library;`, then a doc comment stating this is the engine's stable API surface. Leave the body as documented placeholder exports the sibling tasks fill in (e.g. a comment block listing the planned `export 'src/...' show ...;` lines for `SchedulingEngine`, `Card`, `ReviewInput`, `Track`, `Grade`, `Source`, `EngineConfig`). The barrel must never re-export a `lib/src/` internal that callers should not depend on. Until T02 lands, an empty-but-documented barrel that still `dart analyze`s clean is correct.

4. **Private `lib/src/` tree.** Create `packages/engine/lib/src/` with a single placeholder unit so the package compiles and the analyzer has a target — e.g. `lib/src/engine_base.dart` (SPDX header + a doc comment marking it as the home of the `SchedulingEngine` façade T04 authors). **No `utils/`/`helpers/`/`common/`/`core/` folder** (eng-create-package §7). Do not create the curve/clamp/cold-start files here — T03/T06/T07 own those file names.

5. **Test scaffold.** Create `packages/engine/test/` and the frozen-vector home `packages/engine/test/vectors/` (an empty directory with a `.gitkeep` or a placeholder header file is fine — T03/T06 populate it). Add `packages/engine/test/purity_smoke_test.dart` (Block E shape, `package:test`): a trivial test that imports `package:engine/engine.dart` and asserts the barrel loads, plus — critically — it serves as the file the offline guard rides on (see Tests). The smoke test is what makes "`dart test engine/` runs green on an empty package" a checkable acceptance, not a claim.

6. **REUSE SPDX header on every Dart file** (`pubspec.yaml` is YAML and is covered by the repo `.reuse/dep5`, but every `.dart` file gets the two-line header verbatim):
   ```dart
   // SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
   // SPDX-License-Identifier: GPL-3.0-or-later
   ```
   `reuse lint` is release-blocking (13 §2). Apply it to `engine.dart`, `engine_base.dart`, and `purity_smoke_test.dart`.

7. **Pitfalls to avoid:**
   - Adding `flutter:` to `environment` or `dependencies` "to borrow a matcher" — pulls the whole framework and breaks the purity grep (use `test`, never `flutter_test`, in a pure package — eng-create-package §6).
   - A stray `import 'dart:io'` / `dart:ui` / `DateTime.now()` / `DateTime.timestamp()` / `Random` anywhere under `lib/` — even in a placeholder file. `today` is **always** a `SerialDay` parameter (domain-scheduling-engine-rules rule 2).
   - Using `path:`/`dependency_overrides` instead of `resolution: workspace`, or committing `packages/engine/pubspec.lock` (02 §1.1).
   - Re-exporting a `lib/src/` internal from the barrel, or letting any test import another package's `lib/src/` (02 §4).
   - A `utils/`/`helpers/`/`common/`/`core/` folder (eng-create-package §7).
   - Declaring a speculative dependency "for later" — an unused edge is a review reject; add `models` only because T02's value types need it, nothing more.
   - Authoring scheduling math, constants, or value types here — that is T02–T11; this PR is the manifest, the barrel, the directories, and the SPDX headers only.

## Acceptance criteria

- [ ] `packages/engine/` exists with `pubspec.yaml`, `lib/engine.dart`, at least one `lib/src/*.dart`, `test/purity_smoke_test.dart`, and a `test/vectors/` directory.
- [ ] `packages/engine` is listed in the root `pubspec.yaml` `workspace:` list; the manifest declares `resolution: workspace` and `environment: sdk: ^3.6.0`; no `packages/engine/pubspec.lock` is committed.
- [ ] `dependencies:` is exactly `meta` (+ `models`) — **no** `flutter`, **no** `flutter:` environment line, **no** `dart:io`/`dart:ui`, **no** `http`/`crypto`/`drift`/`sqlite3`/`google_fonts`/`provider`/`get_it`/Bloc, and **no** `dependency_overrides` (verifiable by reading the one-screen manifest).
- [ ] `dev_dependencies:` is exactly `test` + `glados`.
- [ ] `dart pub get` resolves the workspace with no version clash and no `dependency_overrides`.
- [ ] `dart test` (run for the `engine` package) is green on the empty scaffold (the smoke test passes).
- [ ] The engine-purity grep (`tool/check_engine_purity.sh` — or the equivalent `grep -REn 'package:flutter|dart:io|dart:ui|DateTime\.now|DateTime\.timestamp|\bRandom\b' packages/engine/lib`) finds **zero** hits.
- [ ] `lib/engine.dart` is the only public library; it exports only the (currently placeholder) stable API and re-exports no `lib/src/` internal; everything else is under `lib/src/`.
- [ ] No `utils/`/`helpers/`/`common/`/`core/` folder exists in the package.
- [ ] Every `.dart` file carries the two-line REUSE SPDX header (`GPL-3.0-or-later`); `reuse lint` passes for the new files; the package passes the analyzer/lint config with no warnings.

## Tests

`packages/engine/test/purity_smoke_test.dart` — `package:test` (plain `dart test`, **no** widget binding, no `flutter_test`), runs under both timezone pins in CI to prove the package carries no hidden clock. Required cases:

- **Barrel loads:** `import 'package:engine/engine.dart';` and a trivial `expect(true, isTrue)` — proves the public library resolves and the package compiles as a workspace member. (Replaced/extended by real API tests in T02+; here it gates "the empty scaffold builds and tests green.")
- **Offline / no-network guard:** install a throwing `HttpOverrides` (or assert via the test that the package opens no socket) so that, the moment any sibling task accidentally introduces a network call, the suite fails loudly rather than silently reaching out (eng-create-package §6; engineering 06 §1). Since the engine declares no `http`/`dio` dependency, this guard should never trip — that is the point.

Grep/gate (run locally and in CI, not a Dart test): the engine-purity grep over `packages/engine/lib` returns no `package:flutter` / `dart:io` / `dart:ui` / `DateTime.now()` / `DateTime.timestamp()` / `Random` hit. `test/vectors/` is created empty (a placeholder header file or `.gitkeep`); the frozen `(state, grade, elapsed) → (D, S, due)` golden vectors that live there are authored by T03/T06 — none in this task.

No golden vectors, no `glados` properties, no widget/integration tests in this task — those attach to the logic (T03–T11). The §7.12 invariant property tests (the six `glados` properties) are T11.

## Definition of Done

- [ ] All acceptance criteria met; `dart pub get` + `dart test engine/` green locally and in CI under both TZ pins.
- [ ] **Offline / no-network:** `packages/engine/` declares no `http`/`dio`/analytics/ads/backend SDK and opens no socket; the dependency line is `meta` (+`models`) only — verifiable by grep; the smoke suite's throwing `HttpOverrides` guard is in place (PRD C1; engineering 06 §1).
- [ ] **No AI / no audio / no microphone:** the package declares no ASR, ML, on-device-model, or optimizer dependency, and requests no microphone or audio permission — by construction it is value-type arithmetic with no I/O surface (PRD C2; engineering 06 §8).
- [ ] **Determinism boundary:** no `DateTime.now()`, no `DateTime.timestamp()`, no `Random`, no `dart:io`/`dart:ui`, no `package:flutter` reachable from `packages/engine/` — `today` will be injected as a `SerialDay` when the logic lands; the purity grep finds zero hits (PRD §7.12; engineering 06 §1, §8; domain-scheduling-engine-rules rule 2).
- [ ] **Quran text fidelity:** N/A by construction — this scaffold renders no Quran text and touches no glyph corpus (that lives in the `quran` package, E05); the boundary that keeps the engine text-blind is asserted, not assumed.
- [ ] **RTL + fa/ckb/ar localization:** N/A by construction — the engine is locale-blind serial-integer arithmetic emitting opaque page ids and day counts; the scaffold declares no `l10n.yaml`/`flutter_gen`/`intl`/`google_fonts` and surfaces no string, so no locale/numeral/calendar logic can leak in (those belong to E02 and the fa/ckb/ar UI layer) (engineering 02 §6; EPIC DoD).
- [ ] **Accessibility:** N/A by construction — `engine/` renders no widget; accessibility lives wherever the day plan is displayed (E11/E12/E15).
- [ ] **Sect-neutral adab:** N/A by construction — the scaffold introduces no copy, streak, score, badge, or shame surface and implies no madhhab/sect ruling; it is a manifest and an empty barrel (PRD R3, C6).
- [ ] **Deterministic tests:** the smoke suite uses no hidden clock and no RNG; identical runs are byte-identical; it runs under plain `dart test` (no widget binding) (engineering 11; EPIC DoD).
- [ ] Every Dart file carries the REUSE SPDX header (`GPL-3.0-or-later`); `reuse lint` passes; the package passes the analyzer/lint config; the manifest passes the DCM `avoid-banned-imports` lint and the `tool/check_*.sh` boundary greps (engineering 13 §2; engineering 02 §5).
