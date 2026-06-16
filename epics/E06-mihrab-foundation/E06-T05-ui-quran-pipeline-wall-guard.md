# E06-T05 — The pipeline wall: build-time guard that no UI-type path reaches a QPC/Quran asset (test-first)

| | |
|---|---|
| **Epic** | [E06 — Mihrab Design Foundation](EPIC.md) |
| **Size** | S (≈half a day) |
| **Depends on** | E06-T04 |
| **Skills** | eng-write-to-coding-standards, eng-add-ci-check, eng-write-dart-test |

## Goal

A build-time guard proves, mechanically, that the `type.*`/`TextTheme` UI pipeline and the immutable muṣḥaf glyph pipeline share no `TextStyle`, metric, or shaper: no UI-font path can reach a QPC/Quran asset, and no Quran-glyph reference appears in UI type code. The guard is a new analyzer-scoped `avoid-banned-imports` entry plus a symbol-level grep gate `tool/check_pipeline_wall.sh`, both wired into CI, with a deliberate-violation fixture that the guard MUST reject. This is the structural restatement of the "two pipelines, one rule" guarantee (design-system 04 §1; PRD R1) — complementing E05's runtime refusal-to-render and E01's `check_quran_isolation.sh` from the other side of the wall: E01/E05 keep glyph handling *inside* `quran`; this task keeps the UI type system *out of* it.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/04-typography.md` §1 ("Two pipelines, one rule") | The exact guarantee to make structural: the Quran and the interface "live in two separate rendering pipelines that share no `TextStyle`, no metrics, and no shaper"; `type.family.ui`/`type.family.uiFallback` "are never passed to the muṣḥaf reader or any overlay painter"; "A build-time check asserts no Quran asset path is ever routed through a `TextStyle`/UI shaper, complementing the runtime refusal-to-render guard." This task lands exactly that build-time check |
| `docs/design-system/04-typography.md` §1 anti-patterns | The four "we will never" lines the guard enforces by construction: never render Quran text through the UI font/OS shaper; never treat the QPC fonts as a `type.*` token or expose them to the theme; never let a UI font-size change reach the page |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §1, §5 | The symbols the wall must keep out of UI type code: `quran`'s `qpcFontFamily(pageNumber)` family-name function, the `glyph_page.dart` library / `GlyphPage` value type, `glyphCodes` (opaque QPC V2 codepoints, "NEVER parsed as Arabic text"), and the per-page `FontLoader`/`loadFontFromList` registration path. §5 "we refuse to let the muṣḥaf leak into a generic 'Arabic text' style … a shared `TextStyle` that pulled the muṣḥaf into the shaped path would defeat the entire decision" — the exact leak this guard catches |
| `docs/engineering/02-project-structure.md` §5 (banned-import block) | The existing `avoid-banned-imports` entry #3 (`paths: ['(?!packages/quran/).*\.dart']`, `deny: ['package:quran/src/glyph_page.dart']`) and `tool/check_quran_isolation.sh`. This task adds the **complementary** entry and grep — scoped to the UI type files in `features`/`app` — so the wall is enforced from both sides; same DCM mechanism, same `tool/`-grep belt-and-suspenders pattern, run identically locally and in CI |
| Skill `eng-add-ci-check` (+ `template.yml`) | Map the gate to PRD §20 gate 6 (the no-network / banned-import structural gate this extends); pin `subosito/flutter-action@v2` to the README `flutter-version`; the gate is itself code held to the standards (REUSE SPDX header, typed errors, `dart format` clean, no `print` of user data); a red gate is release-blocking, never `continue-on-error`; the gate stays locale/madhhab-blind — it checks import/symbol topology, never interprets bytes |
| Skill `eng-write-dart-test` (+ `template.dart`) | Test-first: the deliberate-violation fixture and the assertion that the guard fails on it are written and red before the guard passes; the guard's own unit coverage runs under `dart test`/`flutter analyze`; the throwing-`HttpOverrides` offline bootstrap stays installed; full-word names, typed `catch`, REUSE SPDX header on every test file |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | The grep gate script obeys the standards: REUSE SPDX header (`GPL-3.0-or-later`), full-word identifiers, `set -euo pipefail`, exits non-zero on any hit with a `PRD R1`/`design-system 04 §1` message; no `// ignore:` on a §7.2 architecture gate is permitted on the wall's lints |
| CLAIMS ids | **None.** This task ships no user-facing number, copy, or claim — it is a structural guard over import/symbol topology, presentation-only by construction |
| Sibling: E06-T04 (dependency) | T04 builds the UI type pipeline this task walls off: `type.family.ui` = Vazirmatn, `type.family.uiFallback` = Estedad, the six-step `TextTheme`, the `type.*` token files. The guard's `paths` scope is exactly the files T04 lands; the wall is meaningless before they exist, which is why T04 is the hard dependency |
| Siblings: E06-T06, E06-T08, E06-T09 | T06 composes the four `ThemeData` (roles + extensions + `TextTheme`) and wires the appearance switcher; T08/T09 add the skeleton widgets. All of these consume `type.*`/`TextTheme` and must stay on the UI side of the wall — the guard's `paths` scope grows to cover their files as they land, and the deliberate-violation fixture protects against a future "render this ayah in a nice card" PR routing a Quran string through `TextTheme` |
| Cross-epic: E01 `check_quran_isolation.sh`; E05 runtime refusal | E01 owns the glyph-isolation gate (glyph handling only inside `quran`) and E05 owns the runtime refusal-to-render on the sacred path (no `fontFamilyFallback`, no OS shaper). This task is the third leg: a static guard that the UI type pipeline never reaches into `quran`'s glyph surface. It does not duplicate or replace either — it cites them as the complementary halves of the same R1 guarantee |

## Implementation notes

**TEST-FIRST (correctness-critical, R1):** write the deliberate-violation fixture and the meta-test that asserts the guard rejects it FIRST; both must exist and be red (the guard not yet present, or the violation not yet caught) before the guard is implemented. A guard with no failing case proves nothing — this is the §1 "build-time check" made real, not a green check that asserts nothing.

1. **The banned-import entry (analyzer half).** Add a new `avoid-banned-imports` entry to the root `analysis_options.yaml`, scoped to the UI type files, denying any import of the `quran` glyph surface:
   ```yaml
   # 5. Pipeline wall: the UI type system never reaches the muṣḥaf glyph pipeline.
   - paths:
       - 'packages/features/lib/src/.*/(theme|tokens|type)/.*\.dart'
       - 'app/lib/(app|composition)/.*\.dart'
     deny:
       - 'package:quran/src/glyph_page.dart'
       - 'package:quran/src/qpc_font.dart'
     message: >-
       UI type (type.*/TextTheme over Vazirmatn/Estedad) shares no TextStyle,
       metric, or shaper with the muṣḥaf glyph pipeline (design-system 04 §1; PRD R1).
       The muṣḥaf is rendered glyph-only by packages/quran — never the UI font.
   ```
   This is the mirror of entry #3 (which bans glyph handling *outside* `quran`); together they wall the same boundary from both sides. Confirm the exact denied library names against the symbols E05 lands in `quran` (`qpcFontFamily`, `GlyphPage`); the `quran` public barrel deliberately does not re-export the glyph surface, so the deny list targets the `src/` libraries directly.

2. **The grep gate (symbol half).** Add `tool/check_pipeline_wall.sh` — a `set -euo pipefail` script that greps the UI-type file set and exits non-zero on any hit of a Quran-glyph symbol an import ban alone could miss (a string `fontFamily: qpcFontFamily(...)`, a `GlyphPage`/`glyphCodes` reference, a `FontLoader`/`loadFontFromList` call, or the literal `QPC_P` family prefix). Belt-and-suspenders, exactly like `check_engine_purity.sh`/`check_quran_isolation.sh`:
   ```bash
   # tool/check_pipeline_wall.sh  (exits non-zero on any hit)
   # SPDX-License-Identifier: GPL-3.0-or-later
   set -euo pipefail
   ! grep -rnE "qpcFontFamily|GlyphPage|glyphCodes|QPC_P[0-9]|loadFontFromList|FontLoader" \
       packages/features/lib/src app/lib \
     || { echo "pipeline wall violated — UI type code references the muṣḥaf glyph pipeline (PRD R1; design-system 04 §1)"; exit 1; }
   ```
   Keep the script locale/madhhab-blind — it matches symbol topology, never interprets text bytes. Match the README/PRD-gate→job table: this extends gate 6 (the no-network / banned-import structural gate), so it joins the same `restraint`-tier CI job and runs before push.

3. **The deliberate-violation fixture.** Place a `// dart format off`-free fixture under `test/fixtures/pipeline_wall/` (NOT under `lib/`, so it never ships) that does the forbidden thing once: a widget that builds a `TextStyle(fontFamily: qpcFontFamily(1))` / imports `package:quran/src/glyph_page.dart`. A meta-test asserts the guard rejects this fixture — e.g. shells out to `flutter analyze` over the fixture path and `tool/check_pipeline_wall.sh`, expecting a non-zero exit and the R1 message. This is the "deliberate violation must fail the guard" requirement; the fixture is committed, the guard's catch of it is the proof.

4. **No production behavior changes.** This task adds zero runtime code, zero widgets, zero tokens — it adds two CI gates (one analyzer entry, one grep script), one fixture, and the meta-tests. The UI type pipeline (T04) and the muṣḥaf pipeline (E05) are unchanged; the guard only *asserts* their separation. Resist scope creep into composing `ThemeData` (T06) or widgets (T08/T09).

5. **Pitfalls to avoid:**
   - **A green check that asserts nothing.** If no fixture ever trips the guard, the gate is decorative. The meta-test that the deliberate violation *fails* the guard is the load-bearing test — write it first.
   - **Scoping `paths` too narrowly.** The guard must cover every file that handles `type.*`/`TextTheme` — the T04 token files AND the T06 `ThemeData` composition AND the `app/` shell wiring — or a leak slips through an unscoped file. Widen the `paths` scope as T06/T08/T09 land; note this in their tasks.
   - **Banning the wrong symbol.** Deny the `quran` *glyph* surface (`glyph_page.dart`, `qpcFontFamily`, `GlyphPage`), not all of `package:quran` — `features` legitimately consumes `quran`'s value types for the reader. The wall is between the UI *type system* and the *glyph* pipeline, not between `features` and `quran` wholesale.
   - **`// ignore:` on the wall lint.** Forbidden — this is a §7.2 architecture gate (PRD R1), not a style lint; an ignore would silently reopen the wall.
   - **Letting the fixture ship.** The deliberate violation lives under `test/fixtures/`, never `lib/`, or the guard would flag the app's own source forever.
   - **Floating the SDK on the CI job.** Pin `subosito/flutter-action@v2` to the README `flutter-version` so `flutter analyze`'s rule resolution is deterministic.

## Acceptance criteria

- [ ] A new `avoid-banned-imports` entry in the root `analysis_options.yaml` scopes to the UI-type file set (`features` theme/tokens/type dirs + `app` shell) and denies the `quran` glyph surface (`glyph_page.dart` / `qpc_font.dart`), with an R1 / design-system 04 §1 `message`.
- [ ] `tool/check_pipeline_wall.sh` exists, carries the REUSE SPDX header, uses `set -euo pipefail`, greps the UI-type file set for the Quran-glyph symbols (`qpcFontFamily`, `GlyphPage`, `glyphCodes`, `QPC_P[0-9]`, `loadFontFromList`, `FontLoader`), and exits non-zero with the R1 message on any hit.
- [ ] A committed deliberate-violation fixture under `test/fixtures/pipeline_wall/` performs the forbidden act once (a `TextStyle(fontFamily: qpcFontFamily(...))` and/or an import of `package:quran/src/glyph_page.dart`); it lives outside any `lib/` so it never ships.
- [ ] A meta-test proves the guard REJECTS the fixture: `flutter analyze` over the fixture path and/or `tool/check_pipeline_wall.sh` returns non-zero and surfaces the R1 message; with the fixture removed/corrected, both pass.
- [ ] Both gates are wired into the same CI tier as the other structural bans (gate 6, the `restraint`/no-network job), pinned-SDK, and are release-blocking (no `continue-on-error`); the PRD-gate→job mapping table reflects the addition.
- [ ] The guard is symbol/import-topology only — locale/madhhab-blind, no byte interpretation, no user-facing string, no CLAIMS id.
- [ ] `flutter analyze --fatal-infos`, `dart format`, and the existing gates (`check_quran_isolation.sh`, `check_no_network.sh`, `check_engine_purity.sh`) stay green with the new gate and fixture included.

## Tests

All test files carry the REUSE SPDX header (`GPL-3.0-or-later`), keep the shared throwing-`HttpOverrides` offline bootstrap installed (no network in any path), and use full-word, unit-bearing names.

- **`tool/test/check_pipeline_wall_test.dart`** (or a Bash assertion under `tool/test/`, run under the `restraint` job) — the meta-test for the grep gate:
  - **Rejects the violation (test-first, must be red first):** running `tool/check_pipeline_wall.sh` against a tree containing the deliberate-violation fixture exits non-zero and emits the R1 message.
  - **Passes the clean tree:** running it against the real `packages/features/lib/src` + `app/lib` (no violation) exits zero.
  - **Catches each banned symbol independently:** one case per symbol (`qpcFontFamily`, `GlyphPage`, `glyphCodes`, `QPC_P0`, `loadFontFromList`, `FontLoader`) confirms each trips the gate, so removing any one regex is caught.
- **`packages/features/test/theme/pipeline_wall_analyzer_test.dart`** — the analyzer-entry meta-test:
  - **Deny entry rejects the violation:** `flutter analyze` over the deliberate-violation fixture reports the `avoid-banned-imports` diagnostic with the R1 message; assert on the diagnostic, not exit code alone.
  - **Legitimate `quran` value-type import is allowed:** a fixture that imports a non-glyph `quran` value type from the public barrel passes — proving the wall is between the UI type system and the *glyph* surface, not `features`↔`quran` wholesale.
- **`test/fixtures/pipeline_wall/ui_text_routes_quran_violation.dart`** — the committed deliberate violation: a minimal widget that routes a QPC family through a `TextStyle` and/or imports the glyph library. Documented in a `///`-comment as an intentional negative fixture so a future reader does not "fix" it.
- **Offline/no-network guard:** the meta-tests touch no socket; the throwing-`HttpOverrides` bootstrap remains installed and the dependency allow-list is unchanged (no new dep introduced).

## Definition of Done

- [ ] **Offline / no-network by construction:** the task adds no dependency and no network path; the throwing-`HttpOverrides` bootstrap and the dependency allow-list stay green; the new gate joins the structural-bans (gate 6) job ([PRD C1, §17, §20](../../docs/PRD.md)).
- [ ] **No AI / no microphone:** no ML/ASR/audio path is touched; the guard is static import/symbol analysis only ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **Quran text fidelity — the wall holds (non-negotiable, R1):** the UI type pipeline (`type.*`/`TextTheme` over Vazirmatn/Estedad) shares no `TextStyle`, metric, or shaper with the muṣḥaf glyph pipeline; the build-time guard proves no UI-font path reaches a QPC/Quran asset and no Quran-glyph reference appears in UI type code; the deliberate-violation fixture fails the guard ([PRD R1](../../docs/PRD.md); [design-system 04 §1](../../docs/design-system/04-typography.md)). The guard complements, and does not duplicate, E05's runtime refusal and E01's `check_quran_isolation.sh`.
- [ ] **RTL + fa/ckb/ar:** no user-facing string is added; the guard is locale-agnostic and does not touch the ARB pipeline (N/A by construction, stated explicitly so the absence is intentional).
- [ ] **Accessibility:** N/A by construction — no widget, no interactive surface is added.
- [ ] **Sect-neutral adab:** the gate is locale/madhhab-blind — it inspects import/symbol topology, never interprets or favors any reading of the text; it reinforces reverence by keeping the muṣḥaf out of the shaped UI path ([design-system 04 §1](../../docs/design-system/04-typography.md); PRD R1).
- [ ] **Deterministic tests:** the meta-tests are deterministic (fixed fixture inputs, no wall clock, no `DateTime.now()`), the SDK is pinned on the CI job so `flutter analyze` resolution is stable, and CI only verifies — it never auto-blesses the guard.
- [ ] **Coding standards:** the grep gate and every test file carry the REUSE SPDX header, use full-word names, typed `catch`, `dart format` clean, no `print` of user data, and no `// ignore:` on the wall's lints ([eng-write-to-coding-standards](../../.claude/skills/eng-write-to-coding-standards/SKILL.md) §4, §6, §7.2).
- [ ] **Tests green:** the deliberate-violation meta-test (written first, red first), the clean-tree pass, and the per-symbol cases all run on the E01 CI lanes and pass on this task's PR.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
