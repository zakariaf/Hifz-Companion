<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# E06-T10 — Contrast-audit fixture: WCAG 2.2 AA tables re-run per appearance, fail CI on regression (test-first)

| | |
|---|---|
| **Epic** | [E06 — Mihrab Design Foundation](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E06-T03 |
| **Skills** | eng-write-dart-test, eng-add-ci-check |

## Goal

A correctness-critical fixture independently recomputes the WCAG 2.2 relative-luminance contrast ratio for every audited token pair, in **all four appearances** (Light · Sepia · Dark · Night), straight from the live `ColorScheme`s and `MihrabColors` instances E06-T03 ships — never copied from the prose table. It asserts the floors of [design-system 03 §7](../../docs/design-system/03-color-and-themes.md): text/accent pairs ≥ **4.5:1**, the heat-map *strong* graphical anchor ≥ **3:1**; and it asserts the deliberately-below-floor heat steps stay below floor (label-carried, never glance-critical). Sepia and Night are re-measured from their own values, never assumed to inherit Light's result. The fixture **fails closed**: any audited pair below its floor, or any new token pair (new appearance, new heat step, new semantic) that is not in the audit registry, fails the test — and the test is wired into E01's `flutter test` fast lane as a release-blocking check so a `color.*` edit that quietly drops a pair under floor cannot merge. E08 later extends this same fixture into the full release accessibility program; this task ships the per-appearance contrast gate only.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/03-color-and-themes.md` §7 | The whole audit contract this fixture *re-derives* (it does not trust the printed numbers): the WCAG relative-luminance formula; the floors — body text/accent **≥4.5:1**, large-text/non-text/graphical **≥3:1**; the **Core tokens — text & accent** table (`text.primary`/`secondary`/`tertiary` on `bg.primary`/`surface.container`, `accent.green` as text/link, `text.on-accent` on the accent fill, `semantic.warning` text) for Light · Sepia · Dark · Night; the **Heat-map ramp** table where `heatmap.strong` must clear 3:1 in each appearance and `good`/`fair`/`weak`/`faded` sit **below** 3:1 *by design*; and the maintenance rule: "re-run on any token change; any new colour pair must be added to these tables before merge." |
| `docs/design-system/03-color-and-themes.md` §3, §4 | Why Sepia/Night are measured independently, not inherited: Sepia is warm low-chroma paper at positive polarity (its `bg.primary` `#F3EAD8` is not Light's), Night is Dark *warmed and luminance-reduced* (`#14110C`, not Dark's `#121413`) — a passing Light pair "proves nothing about its inversion." |
| `docs/design-system/03-color-and-themes.md` §5, §6 | Why `heatmap.good…faded` and `decayCalm` are allowed under 3:1 (number + label carry the value, colour is never the sole channel — SC 1.4.1), and why the only semantic measured is `semantic.warning` (no `success`/`danger` pair exists to audit). The fixture asserts the lower steps stay *intentionally* below floor (a regression that lifts one to a false "anchor" is also caught). |
| `docs/design-system/02-material-and-platform-foundations.md` §9 | The tokens are read through the typed API (`Theme.of(context).colorScheme` / `extension<MihrabColors>()`); the fixture pulls the live scheme/extension values, so it audits *what ships*, not a hand-copied constant — closing the "prose says 5.61, code drifted" gap. |
| Skill `eng-write-dart-test` (+ `template.dart`) | **TEST-FIRST** for correctness-critical values; this is a `flutter_test` suite (operates on `Color`/`ColorScheme`, not `engine` arithmetic, so **not** `package:test`); assert ratios with `closeTo(expected, …)` / threshold `>=`, **never `==` on doubles**; name the WCAG constants (no magic `0.03928`/`0.05`); the throwing `HttpOverrides` offline bootstrap stays installed (no network, no font fetch); REUSE SPDX header; full-word/unit-bearing names. This is the *check*, not the colour contract — 03 §7 owns the floors, this proves them. |
| Skill `eng-add-ci-check` (+ `template.yml`) | Wire the fixture into E01's **fast** `flutter test` job (it needs no real fonts, no device, no pinned-OS golden runner — it is pure luminance math over `Color`s, so it belongs in the cheap fast lane, *not* the `@Tags(['golden'])` Linux golden job); pin `subosito/flutter-action@v2` to the README `flutter-version`; the gate is **required**, never `continue-on-error`; the release job re-runs it. This is an accessibility/contrast gate that supports PRD §18; it is a project-internal correctness gate, not one of the eight PRD §20 release-blockers it must be mapped to — record it in the gate→job table as the design-system contrast check feeding the future E08 accessibility program. |
| CLAIMS ids | **None.** This task ships no user-facing number or copy — the `4.5:1`/`3:1` figures are WCAG 2.2 thresholds (a standard, asserted against), not an on-screen claim. No CLAIMS row is touched; if a reviewer finds a claim-shaped on-screen string here, it is the bug. |
| Sibling **E06-T03** | The dependency: it constructs the four `ColorScheme`s and pins the audited roles (`surface`, `onSurface`, `onSurfaceVariant`, `primary`, `onPrimary`, `surfaceContainer`). This task reads those live schemes and re-derives their ratios. T03 pins the *values* (hex equals 03 §7); T10 pins the *ratios* (luminance math clears the floor). The two are complementary tripwires — a hex typo trips T03, a sub-floor re-tone trips T10. |
| Sibling **E06-T02** | Source of `MihrabColors.heatmapStrong…heatmapFaded`, `decayCalm`, `semanticWarning`, `readerSurfaceSepia/Night` — the graphical-object marks measured against each appearance `bg.primary`. |
| Sibling **E06-T11** | The four-appearance × three-locale skeleton **goldens** and the token-discipline (no-raw-value) grep — pixels and source-text discipline. T10 audits **ratios**, never pixels; the two run on E01's lanes side by side and do not overlap. |
| Sibling **E08** (epic) | Extends this fixture into the release accessibility program (text-scale reflow, reduce-motion per-locale pass, screen-reader labels). T10 ships only the per-appearance contrast gate; the audit *checklist* is E08's. |

## Implementation notes

**TEST-FIRST (correctness-critical):** the task *is* the fixture. Write the failing ratio assertions and the registry-completeness assertion **before** the small luminance helper they force into existence. The "every audited pair clears its floor in every appearance" and "no audited pair is absent from the registry" assertions must exist and fail (or fail to compile against a missing helper) before the helper is implemented — a sub-floor contrast pair is a defect class exactly like an off-by-one date.

1. **Files & package.**
   - Helper: `packages/features/lib/src/design_system/theme/wcag_contrast.dart` — a tiny pure-Dart contrast utility in the same design-system theme subtree T03 uses (`packages/features/lib/src/design_system/theme/`, per [arch 01 layer 3](../../docs/engineering/01-architecture-overview.md)). Public surface: `double relativeLuminance(Color color)` and `double contrastRatio(Color a, Color b)`. It imports `package:flutter/material.dart` only (for `Color`); no Drift, no `dart:io`, no network, no `engine` import.
   - Fixture: `packages/features/test/design_system/theme/contrast_audit_test.dart` (mirrors the source path, eng-write-dart-test §11).

2. **Implement the WCAG formula exactly, with named constants.** `relativeLuminance` linearizes each 8-bit channel: `c/255`, then `c <= LINEAR_THRESHOLD (0.03928) ? c/12.92 : pow((c + 0.055)/1.055, 2.4)`, weighted `0.2126·R + 0.7152·G + 0.0722·B`. `contrastRatio(a, b)` returns `(Lhi + AMBIENT (0.05)) / (Llo + 0.05)` with `Lhi`/`Llo` the larger/smaller luminance. **Name every constant** (`linearThreshold`, `ambient`, the channel weights, the `12.92`/`1.055`/`0.055`/`2.4` gamma terms) — no magic numbers (eng-write-dart-test §4; coding-standards §1.1.1). Read 8-bit channels via the modern `Color` component API; do not assume a specific `int` packing.

3. **Build an audit *registry* as data — one row per 03 §7 cell.** A `const` list of immutable `ContrastCase` records, each: the appearance, a human label (`'text.primary on bg.primary'`), a `foreground` and `background` *resolver* (a function `(ColorScheme, MihrabColors) -> Color` so the case reads the **live** token, never a re-typed hex), the `floor` (4.5 or 3.0), and a `belowFloorByDesign` flag for the lower heat steps. The registry mirrors both 03 §7 sub-tables across all four appearances. This is the single place the audit's *shape* lives; adding an appearance/heat-step/semantic means adding rows here, and the completeness check (note 5) fails until you do.

4. **Drive the fixture from the four live appearances.** For each `MihrabAppearance` (light, sepia, dark, night) obtain its `ColorScheme` via T03's `colorSchemeFor(appearance)` and its paired `MihrabColors` instance (the per-appearance instances T03 attaches — read them through the same source of truth, not a test-local copy). For each registry row of that appearance, resolve foreground/background from the live scheme/extension and compute `contrastRatio`. Assert:
   - text/accent rows: `contrastRatio >= row.floor` (4.5).
   - `heatmap.strong` rows: `contrastRatio >= 3.0`.
   - `belowFloorByDesign` rows (`heatmap.good/fair/weak/faded`, `decayCalm` where applicable): `contrastRatio < 3.0` **and** is below the strong anchor — so a regression that accidentally lifts an atmosphere cell into a false anchor (or sinks the strong anchor below them) is caught, not just a too-low pair.
   - Use a small positive tolerance band on the prose's quoted ratios only as a *sanity cross-check* (e.g. computed Light `text.primary` ≈ 15.05 within ±0.1) — the **gating** assertion is the floor, not the exact transcribed number, so a legitimate re-tone that stays above floor is not a false failure. Assert with `closeTo`/`greaterThanOrEqualTo`, never `==` on a double (eng-write-dart-test §4).

5. **Registry-completeness / fail-on-unaudited-pair guard.** Assert the registry covers every audited 03 §7 cell for every appearance (e.g. each appearance has the expected text/accent rows + the five heat rows + warning) by counting against an expected-cell manifest; a *new* token pair that is not represented makes the count mismatch and the test fail — the machine enforcement of 03 §7's "any new colour pair must be added to these tables before merge." Where feasible, also assert no pinned text/accent role on a scheme is left **unaudited** (every `onSurface`/`onSurfaceVariant`/`primary`/`onPrimary` that T03 pins has at least one registry row), so a future pinned role cannot ship un-measured.

6. **CI wiring (eng-add-ci-check).** This suite runs under the existing `flutter test` invocation in E01's **fast** job — it requires no real fonts (it never renders), no emulator, no pinned-OS golden runner, so it must **not** be tagged `@Tags(['golden'])` and must **not** be routed to the Linux golden job (that would be slower and miss the point — there are no pixels here). Confirm the fast job pins `subosito/flutter-action@v2` to the README `flutter-version` with `channel: stable`; the check is **required** (no `continue-on-error`); add a row to the gate→job mapping table naming it the *design-system contrast audit* (the contrast half of PRD §18, the seed of E08's accessibility program). No new workflow file is needed if the fast job already runs `flutter test` over `packages/features`; if a focused step is added, keep it in the fast lane.

7. **Pitfalls to avoid:**
   - **Re-typing the hex/ratios into the test.** The whole value of the fixture is that it reads the *live* `ColorScheme`/`MihrabColors` and recomputes — copying 03 §7's numbers into `expect(..., 15.05)` would only re-assert the prose, not catch a code drift. Resolve tokens through the live scheme.
   - **Asserting `==` on a computed luminance/ratio.** Floats; use `>=`/`closeTo` with named tolerance.
   - **Assuming Sepia/Night inherit Light.** Each appearance is driven independently from its own scheme — the headline 03 §7 anti-pattern.
   - **Magic gamma/threshold constants.** Name `0.03928`, `0.05`, `12.92`, `1.055`, `2.4`, and the `0.2126/0.7152/0.0722` weights.
   - **Tagging it a golden / routing to the golden job.** It is pure math; the fast lane owns it.
   - **Flipping a `belowFloorByDesign` heat step into a "fix"** by bumping its contrast — those steps are *meant* to be sub-3:1 (number+label carry them); the guard asserts they stay below the anchor, so "raising" one is a regression, not a fix (03 §5/§7).
   - **Auditing only a subset** (skipping `text.on-accent`, `semantic.warning`, or Sepia/Night rows) — the completeness guard exists to stop exactly that.
   - Reaching the network, reading `MediaQuery`/`DateTime.now()`, or touching a glyph/QPC asset — none belong in a pure luminance fixture.

## Acceptance criteria

- [ ] `wcag_contrast.dart` exists in `packages/features/lib/src/design_system/theme/`, exposes `relativeLuminance(Color)` and `contrastRatio(Color, Color)`, imports `package:flutter/material.dart` only, and implements the WCAG 2.2 relative-luminance + contrast formula with **named** constants (no magic gamma/threshold/weight numbers).
- [ ] `contrast_audit_test.dart` drives **all four** appearances (Light · Sepia · Dark · Night) from T03's live `ColorScheme`s and paired `MihrabColors` instances — it reads tokens through the typed API, never a re-typed hex or ratio.
- [ ] Every text/accent pair from 03 §7's Core table clears **≥4.5:1** in every appearance where 03 §7 lists it (`text.primary`/`secondary`/`tertiary` on `bg.primary`/`surface.container`, `accent.green` as text/link, `text.on-accent` on the accent fill, `semantic.warning` text).
- [ ] `heatmap.strong` clears **≥3:1** in Light and Dark (the graphical anchor); the lower steps (`heatmap.good/fair/weak/faded`) are asserted **below 3:1 and below the strong anchor** by design.
- [ ] Sepia and Night are measured from their own scheme/extension values (not inherited from Light/Dark) — a test that swapped Sepia's `bg.primary` for Light's would change a measured ratio.
- [ ] Ratios are asserted with `>=`/`closeTo` against named floors/tolerances; **no `==` on a double**; an optional ±tolerance cross-check against 03 §7's quoted numbers is a sanity check, not the gating assertion.
- [ ] A registry-completeness guard fails the build if any audited 03 §7 cell is missing for any appearance, or if a pinned text/accent role T03 ships has no audit row (the "fail on unaudited new token pair" rule).
- [ ] The fixture runs in E01's **fast** `flutter test` lane (not the `@Tags(['golden'])` golden job), is **required** (no `continue-on-error`), is re-run by the release job, and appears as a row in the gate→job mapping table as the design-system contrast audit.
- [ ] Verified red-first: a locally introduced sub-floor token value (e.g. dropping `Sepia.onSurface` toward its background, not committed) fails the fixture; a locally added but unregistered token pair fails the completeness guard.
- [ ] REUSE `GPL-3.0-or-later` SPDX header on the helper and the test; `dart format --output=none --set-exit-if-changed` and `dart analyze --fatal-infos` clean; `///` on the public helper API; full-word/unit-bearing names.

## Tests

`packages/features/test/design_system/theme/contrast_audit_test.dart` — **`flutter_test`** (operates on `Color`/`ColorScheme`/`MihrabColors`, not `engine` arithmetic, so **not** `package:test`; **not** a golden — no pixels, no `matchesGoldenFile`, no `@Tags(['golden'])`). REUSE header; runs in E01's **fast** lane under `flutter test`; the shared throwing-`HttpOverrides` offline bootstrap stays installed (no network, no font fetch) (eng-write-dart-test §8). Written **FIRST**, before the `wcag_contrast.dart` helper. Required cases:

- **`relativeLuminance` reference values** — pin the helper against WCAG's own worked examples: pure white `#FFFFFF` → `1.0`, pure black `#000000` → `0.0`, mid-grey `#808080` → `closeTo(0.2158, 1e-3)`; and `contrastRatio(white, black) == closeTo(21.0, 1e-3)`. This proves the math before it is trusted to judge the palette.
- **Per-appearance text/accent floor** — parametrized over the registry: for Light · Sepia · Dark · Night, every text/accent row `contrastRatio(fg, bg) >= 4.5` (read from the live scheme/extension), with the failing appearance + pair named in the message.
- **Heat-map anchor & atmosphere** — `heatmap.strong >= 3.0` in Light and Dark; each lower step `< 3.0` **and** `< strong` (the by-design guard).
- **Sepia/Night independence** — assert the Sepia/Night measured ratios are computed from Sepia/Night `bg.primary` (e.g. a guard that the registry's Sepia rows resolve `bg` to the Sepia scheme's `surface`, not Light's) so an inheritance regression is caught.
- **Cross-check vs 03 §7 (sanity, non-gating)** — a handful of representative cells (Light `text.primary` ≈ 15.05, Light `accent.green` ≈ 5.61, Dark `accent.green` ≈ 8.77, `heatmap.strong` Light ≈ 4.59) within ±0.1, documenting that the recompute tracks the prose without making the exact number the gate.
- **Registry completeness / fail-on-unaudited** — the count of audited cells per appearance equals the expected manifest; an injected extra pinned role with no registry row fails; (belt-and-suspenders) every T03-pinned text/accent role has at least one registry row.

Offline / no-network guard: the throwing `HttpOverrides` is active for this suite (no opt-out — only the asset-downloader opts out); no `pumpAndSettle`; no golden master is created (appearance × locale goldens are E06-T11). Deterministic on any contributor machine and in CI — the inputs are `Color` constants, the output is pure arithmetic.

## Definition of Done

- [ ] All acceptance criteria met; the fixture is green locally and in E01's fast `flutter test` lane; it was written before the `wcag_contrast.dart` helper (test-first); red-first verified.
- [ ] **Offline / no-network by construction:** the helper and fixture add no network path and no `google_fonts`/font fetch (they never render); the throwing `HttpOverrides` stays installed and nothing reaches the network; the E01 dependency allow-list stays green ([PRD C1](../../docs/PRD.md)).
- [ ] **No AI / no microphone:** no ML/ASR/audio/microphone path; the fixture is pure luminance arithmetic over `Color`s with no recognition surface ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **Quran text fidelity — wall untouched:** the audit measures surrounding *surface*/text/accent and graphical-mark contrast only; it references no glyph, no `TextStyle`, no QPC asset, and never renders the muṣḥaf — the UI-type↔muṣḥaf wall (E06-T04/T05) is not crossed ([PRD R1](../../docs/PRD.md); design-system 03 §4).
- [ ] **RTL + fa/ckb/ar:** contrast carries no direction — the four appearances yield identical ratios under any `Directionality`, and the fixture introduces no user-facing string (locale labels are E09 ARB keys); the audit holds for the dense fa/ckb/ar UI text 03 §7 measures.
- [ ] **Accessibility — the contrast floor is now machine-enforced:** WCAG 2.2 AA (text/accent ≥4.5:1, graphical anchor ≥3:1) is re-derived per appearance from live tokens, Sepia/Night re-measured not inherited, and any sub-floor or unaudited pair fails CI — the contrast half of PRD §18, handed to E08's accessibility program to extend ([design-system 03 §7](../../docs/design-system/03-color-and-themes.md)).
- [ ] **Sect-neutral adab + calm enforced:** the audit asserts only `semantic.warning` (no `success`/`danger` pair exists to measure) and confirms the heat-map's calm lower steps stay label-carried (colour never the sole channel, SC 1.4.1) — no alarm-red, no reward-green is admitted into the audited set ([design-system 03 §2, §6](../../docs/design-system/03-color-and-themes.md)).
- [ ] **Deterministic tests:** inputs are `Color` constants, outputs pure arithmetic; ratios asserted with named floors/tolerances and `closeTo`/`>=`, never `==` on a double; reproducible on any machine and in CI ([eng-write-dart-test §4](../../.claude/skills/eng-write-dart-test/SKILL.md)).
- [ ] **CI gate is real, not advisory:** the fixture is required (no `continue-on-error`), runs on the pinned-toolchain fast job, is re-run by the release job, and is recorded in the gate→job mapping table as the design-system contrast audit ([eng-add-ci-check](../../.claude/skills/eng-add-ci-check/SKILL.md)).
- [ ] Coding standards: REUSE SPDX header on both files; full-word/unit-bearing names; named WCAG constants (no magic numbers); `///` on the public helper API; `dart format` + `dart analyze --fatal-infos` clean; no `print`, no `!`/`late`/`dynamic` shortcuts.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
