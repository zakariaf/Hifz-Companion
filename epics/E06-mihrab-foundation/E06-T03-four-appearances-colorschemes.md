# E06-T03 — The four ColorSchemes from one green seed (Light · Sepia · Dark · Night) + appearance selection

| | |
|---|---|
| **Epic** | [E06 — Mihrab Design Foundation](EPIC.md) |
| **Size** | M (≈1–2 days) |
| **Depends on** | E06-T02 |
| **Skills** | eng-write-to-coding-standards, eng-write-dart-test |

## Goal

A single file in the design-system subtree exposes exactly four audited `ColorScheme`s — **Light**, **Sepia**, **Dark**, **Night** — each built by `ColorScheme.fromSeed(seedColor: <one calm desaturated Quran-green>, brightness:, contrastLevel:)` and then having its audited roles pinned to the values in [design-system 03 §7](../../docs/design-system/03-color-and-themes.md): Light is the positive-polarity default; Sepia is warm paper at positive polarity; Dark uses the off-black `#121413` surface, desaturated, never pure `#000000`; Night is Dark warmed *and* luminance-reduced with no sleep claim. Alongside the schemes, a `MihrabAppearance` enum and a pure resolver decide which scheme is active: the user setting defaults to **follow-system** (mapping system light→Light, system dark→Dark) and exposes **Sepia** and **Night** as explicit overrides. Dynamic (wallpaper) color is refused — the one fixed seed is the floor and the ceiling. This task ships the schemes, the appearance model, and the resolver only; composing them into `ThemeData` and wiring the switcher into the shell is **E06-T06**, the WCAG re-audit fixture is **E06-T10**, and `MihrabColors` (the bespoke reader/heat-map roles) is consumed from **E06-T02**, not re-defined here.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/03-color-and-themes.md` §3 | The four-appearance set, the positive-polarity daytime default, follow-system for Light/Dark with Sepia/Night explicit, and the **no sleep claim** for Night — the appearance table (when / polarity / token behaviour) is the spec for the enum and resolver |
| `docs/design-system/03-color-and-themes.md` §4 | Dark/Night use an off-black `#121413` surface (never pure black) and desaturated, lighter accent tones (Dark `accent.green` `#6FC2A8`, not the Light `#1F6E5A`); surface containers step up in *tone*, not overlay opacity |
| `docs/design-system/03-color-and-themes.md` §7 | The exact audited per-appearance role values to pin: `bg.primary`/`surface.container`, `text.primary`/`secondary`/`tertiary`, `accent.green`, `text.on-accent`, `semantic.warning` for Light · Sepia · Dark · Night — these are the hex anchors this task transcribes (one place in the codebase a hex may appear) |
| `docs/design-system/02-material-and-platform-foundations.md` §2 | The mechanism: one seed → `ColorScheme.fromSeed(seedColor:, brightness:, contrastLevel:)`; role-to-token mapping (`bg.primary`→`surface`, `text.primary`→`onSurface`, `text.secondary`→`onSurfaceVariant`, `accent.green`→`primary`, `text.on-accent`→`onPrimary`); never a raw `Color(0xFF…)` or hand-picked tonal tone *in a widget* — the schemes are the one sanctioned definition site |
| `docs/design-system/02-material-and-platform-foundations.md` §8 | **Dynamic color is refused**: no `dynamic_color` dependency, no `DynamicColorBuilder`; the designed seed is the only palette source on every device and OS version |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | Immutable values with `const` ctors; `enum MihrabAppearance` with full-word members; `///` on every public API; one fixed transliteration for sacred terms; unit-in-name discipline (`contrastLevelStandard`, not `cl`); the REUSE `GPL-3.0-or-later` SPDX header on every file; no `print`/network/AI path; the audited hex transcription carries a citation comment back to 03 §7 |
| Skill `eng-write-dart-test` (+ `template.dart`) | These schemes are correctness-critical color values → **TEST-FIRST**: a `flutter_test` unit suite pinning each pinned role to its 03 §7 hex, plus a pure-Dart resolver suite over an injected `Brightness` (no `MediaQuery`/wall clock); the throwing `HttpOverrides` offline bootstrap; full-word names; SPDX header |
| CLAIMS register | **None.** This task ships no user-facing number or copy. The "comfort, not sleep" stance is a *guardrail on copy E06 never writes* (Night's name/description is owned by E09 strings + E19 science screen); assert here only that no scheme or enum carries a sleep/eye-health string |
| Sibling **E06-T02** | Consumes its `MihrabColors` extension for the bespoke reader-surface/heat-map/decay/warning roles per appearance — this task pins only the **M3 `ColorScheme` roles**, never re-declares a bespoke token; the per-appearance `MihrabColors` instance is paired with each scheme at composition time (E06-T06) |
| Sibling **E06-T06** | Composes the four `ThemeData` (these schemes + the T01/T02 extensions + the T04 `TextTheme`) and wires the appearance switcher into the app shell — construction and persistence of the setting are **NOT** this task |
| Sibling **E06-T10** | The contrast-audit fixture re-runs the WCAG 2.2 AA tables on these pinned roles per appearance and fails CI on regression — this task makes the audited values *exist*; T10 *guards* them |

## Implementation notes

**TEST-FIRST (correctness-critical color values):** write the role-pinning unit suite and the resolver suite below *before* the scheme bodies. The "pinned role equals the 03 §7 hex" assertions and the follow-system resolution cases must exist and fail before the schemes and resolver are implemented; a colour value is a defect class the same way an off-by-one date is.

1. **File & package.** `packages/features/lib/src/design_system/theme/mihrab_color_schemes.dart` (the design-system subtree of the `features` umbrella per [arch 01 layer 3](../../docs/engineering/01-architecture-overview.md); E06's design system lives inside `features`). One library, public API: the four `ColorScheme` getters/constants, the seed, the `MihrabAppearance` enum, and the resolver. No Drift, no `dart:io`, no network import — this is presentation data only.

2. **The one seed.** A single `const Color mihrabSeedGreen` — the calm desaturated Quran-green from which all four tonal palettes are generated (03 §1/§2: one desaturated green, low chroma). It carries a `///` doc and a citation comment to 03 §2. It is the **only** seed; there is no per-appearance seed.

3. **The four builders.** One private builder per appearance returning a pinned `ColorScheme`:
   - Start from `ColorScheme.fromSeed(seedColor: mihrabSeedGreen, brightness: …, contrastLevel: <named const>)` — keep `tonalSpot` (the default, pastel/calm; 02 §2). Expose `contrastLevel` via a named constant (`contrastLevelStandard = 0.0`) so low-vision tuning is one edit, not magic.
   - **Light** — `Brightness.light`; pin `surface`←`#F3F6F1`, `surfaceContainer`←`#E7ECE4`, `onSurface`←`#1A211E`, `onSurfaceVariant`←`#46514B`, `primary`←`#1F6E5A`, `onPrimary`←`#FFFFFF` (03 §7). Positive polarity (dark-on-light) — the daytime default.
   - **Sepia** — `Brightness.light` (positive polarity, warm paper); pin `surface`←`#F3EAD8`, `onSurface`←`#2B2620`, `onSurfaceVariant`←`#5A5042`, `primary`←`#1C6450`. Warm low-chroma background, `onSurface` still ≥4.5:1 (T10 verifies).
   - **Dark** — `Brightness.dark`; pin `surface`←`#121413` (off-black, **never** `#000000`), `surfaceContainer`←`#1E211F`, `onSurface`←`#E6EAE3`, `onSurfaceVariant`←`#A7B0A8`, `primary`←`#6FC2A8` (lighter/lower-chroma so it does not vibrate), `onPrimary`←`#0C140F` (03 §4/§7).
   - **Night** — `Brightness.dark`; pin `surface`←`#14110C` (Dark warmed: shifted toward warm, **and** luminance-reduced vs Dark), `onSurface`←`#D8CBB2`, `onSurfaceVariant`←`#A89A80`, `primary`←`#7FB48C`. No sleep/eye-health semantics anywhere near it.
   - Use `colorScheme.copyWith(...)` to pin roles onto the generated scheme — do **not** hand-build a 30-field `ColorScheme(...)`; let `fromSeed` derive the unpinned roles, override only the audited ones (02 §2 "roles, not hex, in widgets" — this file is the sanctioned hex site, and the citation comment says so). Map `text.tertiary` where the role exists (`onSurfaceVariant` is already taken by `text.secondary`; `text.tertiary` is a `MihrabColors` token owned by E06-T02, *not* an M3 role — do not invent an M3 slot for it here).
   - `semantic.warning` (`#8A5A00` Light / `#E8B23C` Dark, 03 §6/§7) is a `MihrabColors` token (E06-T02), **not** an M3 `error` role — do not map it onto `colorScheme.error`. There is intentionally no `success`/`danger` for routine state; assert that nothing in this file constructs one.

4. **`MihrabAppearance` enum.** `enum MihrabAppearance { light, sepia, dark, night }` with a `///` per member naming when each is for (03 §3 table), and a getter `Brightness brightnessOf` returning `Brightness.light` for `light`/`sepia` and `Brightness.dark` for `dark`/`night`. Each member maps to its `ColorScheme` via a `colorSchemeFor(MihrabAppearance)` pure function (or a member getter) — total, never throwing (coding-standards §5.2).

5. **The appearance *setting* and the resolver.** Model the user choice as a separate `sealed`/enum `AppearanceSetting { followSystem, light, sepia, dark, night }` (follow-system is a distinct state from the explicit `light`/`dark`, per 03 §3: default is follow-system, Sepia/Night are explicit). A **pure** resolver `MihrabAppearance resolveAppearance(AppearanceSetting setting, Brightness platformBrightness)` returns: `followSystem` → `MihrabAppearance.light` when `platformBrightness == Brightness.light`, else `MihrabAppearance.dark`; every explicit setting → its matching appearance. `platformBrightness` is **injected as a parameter** (the caller reads `MediaQuery.platformBrightnessOf(context)` at the E06-T06 boundary) — this function reads no `MediaQuery` and no clock, so it is unit-testable with literals (eng-write-dart-test §2/§3). The default constant is `AppearanceSetting.followSystem`.

6. **Refuse dynamic color (02 §8).** No `import 'package:dynamic_color/...'`, no `DynamicColorBuilder`, no wallpaper path. The seed is fixed. A grep-able absence; T11's token-discipline check and the E01 dependency allow-list keep `dynamic_color` out of the workspace.

7. **Pitfalls to avoid:**
   - Re-deriving Sepia/Night from Light's roles (a passing Light pair proves nothing about a warm/dim re-tone — 03 §7); each appearance pins its own audited values.
   - Shipping a pure-black (`#000000`) Dark/Night surface for OLED "savings" (03 §4 anti-pattern).
   - Mapping `semantic.warning` to `colorScheme.error`, or adding a `success`/`danger` M3 role (no such routine-state semantic exists — 03 §6).
   - Collapsing follow-system into the plain `light`/`dark` settings (loses the "respect the OS" state — 03 §3).
   - Any sleep/eye-strain/health string, comment, or member doc on Night (03 §3: comfort, not a sleep claim).
   - A raw `Color(0xFF…)` anywhere *outside* this one definition file, or a hand-picked tonal tone (`primary40`) instead of a role override (02 §2).
   - Reading `MediaQuery`/`DateTime.now()` inside the resolver — inject `Brightness`; keep it pure.

## Acceptance criteria

- [ ] `mihrab_color_schemes.dart` exists in `packages/features/lib/src/design_system/theme/`; it imports `package:flutter/material.dart` only (no Drift, no `dart:io`, no network, no `dynamic_color`), verifiable by grep over the file.
- [ ] Exactly one `const Color mihrabSeedGreen` (a desaturated green); all four schemes are generated from it via `ColorScheme.fromSeed` — no second seed, no `dynamic_color`/`DynamicColorBuilder`.
- [ ] Four `ColorScheme`s — Light, Sepia, Dark, Night — each with `brightness` per the 03 §3 table (Light/Sepia `light`; Dark/Night `dark`) and an explicit named `contrastLevel`.
- [ ] Every pinned role equals its 03 §7 audited hex exactly: Light/Sepia/Dark/Night `surface`, `onSurface`, `onSurfaceVariant`, `primary`, and (where 03 §7 lists them) `surfaceContainer`/`onPrimary` — pinned via `copyWith`, with a citation comment to 03 §7.
- [ ] Dark and Night `surface` are off-black/warm-dim (`#121413` / `#14110C`), never `#000000`; Dark `primary` is the lighter `#6FC2A8` (not the Light `#1F6E5A`).
- [ ] `MihrabAppearance` enum has `{ light, sepia, dark, night }`, a `///` per member, and a `brightnessOf` mapping (`light`/`sepia`→light, `dark`/`night`→dark); `colorSchemeFor` is total (never throws).
- [ ] `AppearanceSetting` includes a distinct `followSystem` plus the four explicit appearances; the default is `followSystem`.
- [ ] `resolveAppearance(setting, platformBrightness)` is pure, takes `Brightness` as a parameter (no `MediaQuery`, no clock), and resolves `followSystem` to Light/Dark by platform brightness and each explicit setting to its appearance.
- [ ] No `success`/`danger` M3 role is constructed; `semantic.warning` is **not** mapped onto `colorScheme.error`; no sleep/eye-health string or comment appears anywhere near Night.
- [ ] Every public declaration carries a `///` doc; the file carries the REUSE `GPL-3.0-or-later` SPDX header; `dart format --set-exit-if-changed` and `dart analyze --fatal-infos` are clean.

## Tests

All tests are `flutter_test` (these are `ColorScheme`/`Color`/`Brightness` values, not pure-`engine` arithmetic), under `packages/features/test/design_system/theme/`, written **FIRST**, each carrying the REUSE SPDX header and installing the shared throwing-`HttpOverrides` offline bootstrap (eng-write-dart-test §8) so a stray network call is a named failure.

`mihrab_color_schemes_test.dart` — role-pinning suite (the audit-anchor proof):
- **Pinned roles equal 03 §7**: for each appearance, `expect(scheme.surface, const Color(0xFF…))`, `…onSurface`, `…onSurfaceVariant`, `…primary`, and the listed `surfaceContainer`/`onPrimary` — one assertion per audited cell, values transcribed from 03 §7 (this suite is the regression tripwire when a contributor "tidies" a hex; T10 then re-derives the *ratios*).
- **Brightness per appearance**: Light/Sepia → `Brightness.light`; Dark/Night → `Brightness.dark`.
- **Dark/Night are never pure black**: `expect(darkScheme.surface, isNot(const Color(0xFF000000)))` and the same for Night; Dark `primary` equals `#6FC2A8` (the re-toned, non-vibrating accent), distinct from Light `primary`.
- **One seed only**: all four schemes are constructed from `mihrabSeedGreen` (assert the seed constant is the sole `fromSeed` argument via a small refl%-free check — e.g. a documented single call site, or assert `mihrabSeedGreen` is a desaturated green by HSV saturation `< 0.5`).
- **No forbidden semantic**: a guard asserting the file constructs no `success`/`danger` role and that `warning` is not routed through `colorScheme.error` (assert `errorScheme`/`onError` are the `fromSeed`-derived defaults, untouched).

`appearance_resolver_test.dart` — pure resolver suite (no widget pump, literals only):
- **Follow-system maps by platform brightness**: `resolveAppearance(AppearanceSetting.followSystem, Brightness.light) == MihrabAppearance.light`; `… Brightness.dark == MihrabAppearance.dark`.
- **Explicit overrides win regardless of platform**: `sepia`/`night`/`light`/`dark` each resolve to their appearance for *both* platform brightnesses (Sepia/Night are explicit, not system-derived — 03 §3).
- **Default is follow-system**: the default constant equals `AppearanceSetting.followSystem`.
- **`brightnessOf` totality**: every `MihrabAppearance` returns a `Brightness`; `colorSchemeFor` returns a non-null scheme for every member (totality, no throw).

No golden in this task — the four-appearance × three-locale skeleton goldens are **E06-T11**, and the WCAG ratio re-audit is **E06-T10**; this suite pins the *values*, those tasks pin the *pixels* and the *ratios*. Offline guard: every test runs under the throwing `HttpOverrides`; none reaches the network (no font fetch, no `dynamic_color`).

## Definition of Done

- [ ] All acceptance criteria met; both suites green locally and on the E01 `flutter test` lane.
- [ ] **Offline / no-network by construction:** no network path, no `google_fonts` runtime fetch, no `dynamic_color`; the schemes are pure in-binary data; the throwing `HttpOverrides` is installed in both suites and nothing reaches the network ([PRD C1](../../docs/PRD.md); 02 §8).
- [ ] **No AI / no microphone:** no ML/ASR/audio path; the schemes, enum, and resolver are presentation-only with no recognition surface ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **Quran text fidelity — wall untouched:** this task defines surrounding *surface* roles only; no glyph, no `TextStyle`, no QPC asset is referenced; reader surfaces transform the rendered glyph layer's backdrop, never the glyph text ([PRD R1](../../docs/PRD.md); 02 §3, 03 §4). The UI-type↔muṣḥaf pipeline wall is E06-T04/T05.
- [ ] **RTL + fa/ckb/ar:** color carries no direction — the four schemes are identical under `Directionality.rtl` for fa/ckb/ar; no user-facing string is introduced (appearance labels are E09 ARB keys, not hardcoded here).
- [ ] **Accessibility:** every pinned text/accent pair is sourced from the audited 03 §7 values that clear WCAG 2.2 AA (text/accent ≥4.5:1) per appearance; `contrastLevel` is exposed (named const) so low-vision users can push past the floor; the independent re-audit gate is E06-T10.
- [ ] **Sect-neutral adab + calm enforced:** one desaturated green seed; no `success`/celebration/alarm-red role exists; Dark/Night never pure black; **Night carries no sleep claim** (no sleep/eye-health string or comment) ([design-system 03 §3, §6](../../docs/design-system/03-color-and-themes.md)).
- [ ] **Token discipline:** raw hex appears in exactly this one definition file (the sanctioned site, with a 03 §7 citation comment) and nowhere in a widget; schemes are read downstream via `Theme.of(context).colorScheme`, never re-declared.
- [ ] **Deterministic tests:** the resolver suite uses injected `Brightness` literals (no `MediaQuery`, no `DateTime.now()`); the role suite asserts exact `Color` equality; both are reproducible on any contributor machine and in CI.
- [ ] Coding standards: REUSE SPDX header; full-word/unit-bearing names; `///` on all public APIs; `dart format` + `dart analyze --fatal-infos` clean; no `print`, no `!`/`late`/`dynamic` shortcuts.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
