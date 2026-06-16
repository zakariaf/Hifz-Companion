<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# E06-T02 — MihrabColors ThemeExtension: heat-map ramp, track/decay, reader surfaces, the warning semantic — no success/danger token

| | |
|---|---|
| **Epic** | [E06 — Mihrab Design Foundation](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E01 |
| **Skills** | eng-write-to-coding-standards, eng-write-dart-test |

## Goal

`MihrabColors` exists as an immutable `ThemeExtension<MihrabColors>` in the design-system theme home, carrying the bespoke color families Material 3 does not name: the single-hue, monotonic-in-luminance heat-map ramp (`heatmapStrong` → `heatmapFaded`), the track-chip and calm decay tokens, the sepia/night reader-surface tokens, and the one and only semantic token (`semanticWarning`). It implements `copyWith` and `lerp` and is read only through `Theme.of(context).extension<MihrabColors>()`. There is deliberately **no `semanticSuccess`** and **no `semanticDanger`** field — the absence is the enforcement of "green is reverent ground, never reward" and "decay is never alarm-red." The audited hex values for each appearance come verbatim from design-system 03; E06-T03 constructs the four concrete instances and E06-T10 re-audits them. A test-first value/`copyWith`/`lerp` suite pins the field set and the interpolation contract.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/03-color-and-themes.md` §2 | Green is reverent ground, **never** reward: tokens read as states, not trophies (`heatmapStrong`, not `success`); no green-as-celebration, no tint over glyphs. This is *why* there is no `semanticSuccess` field. |
| `docs/design-system/03-color-and-themes.md` §5 | The heat-map ramp: a **sequential single-hue lightness ramp**, `strong → good → fair → weak → faded`, **monotonic in relative luminance**, green receding to muted neutral — never red→green, never an alarm-red. The five tokens this extension carries, with the §5 Light/Dark value tables (e.g. Light `strong #2E7D5B` … `faded #D2D8D2`; Dark `strong #4FB386` … `faded #262B27`). Color is reinforcement, never the sole channel (the redundant number+label is E15's, not this task's). |
| `docs/design-system/03-color-and-themes.md` §6 | The tiny semantic set: **only `semanticWarning`** (§6 table: Light `#8A5A00`, Dark `#E8B23C`, paired with a `warning` icon, used for asset-integrity / checksum notices — a rare technical failure, never a comment on the user's revision). **No `semanticSuccess`, no `semanticDanger`** for routine hifz state. Decay / missed-day / catch-up stay calm neutral/green-family — they are **not** semantic states. |
| `docs/design-system/03-color-and-themes.md` §4 | The reader-surface posture for Dark/Night: off-black `#121413`, desaturated tones, never pure black; surface containers step up by **tone**, not overlay opacity. The sepia/night reader-surface tokens this extension carries transform the surrounding surface, never the glyph layer. |
| `docs/design-system/02-material-and-platform-foundations.md` §9 | The mechanism this task implements: M3 roles live in `ThemeData`/`ColorScheme`; **everything M3 does not name lives in a typed `ThemeExtension<T>` with `copyWith` + `lerp`**, read only via `Theme.of(context).extension<T>()`, never a global `const`. Each bespoke family is owned by **exactly one file** per the README token map. |
| `docs/design-system/02-material-and-platform-foundations.md` §5 | Components are restrained: **no `Badge`/streak/celebration surface**. Restated here as: the extension exposes no token a celebration could reach for — "saved/verified" reads via icon + text in the M3 `primary` (accent green), not a separate success color. |
| `docs/design-system/README.md` (token map) | `color.*` values are owned only by 03; this Dart file is the **single Dart owner** of the `color.heatmap.*`, decay, track-chip, reader-surface, and `color.semantic.warning` families — no other widget hardcodes these hexes (the token-discipline grep, E06-T11, enforces it). |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | The immutable-value-type shape: `final` fields, `const` constructor, hand-written `copyWith`, `///` on the public type and every field, full-word names (`heatmapStrong`, `readerSurfaceSepia`, `semanticWarning` — no `hmStrong`/`bg`), REUSE SPDX header, `dart format` clean, no hardcoded user-facing string, no `print`/network/AI path. |
| Skill `eng-write-dart-test` (+ `template.dart`) | This is presentation/value code (not engine math), so it is a **`flutter_test` widget-binding unit test**, not a `package:test` engine test and not a golden. Test-first for the value contract; assert `lerp` with `closeTo`-style channel checks (no `==` on interpolated doubles); install the throwing `HttpOverrides` offline guard via the shared bootstrap; REUSE header on the test file. |
| CLAIMS ids | **None.** This task ships color *tokens*, not a user-facing factual claim, number, or methodology copy — no CLAIMS row is touched (the science screen and any claim-bearing number are E19; the heat-map's user-facing numbers/labels are E15). If a reviewer finds a claim-shaped string here, it is the bug. |
| Siblings: E06-T01, E06-T03, E06-T10, E06-T11 | **T01** authors the parallel `SpacingTokens`/`MotionTokens`/`HapticTokens` extensions in sibling files (same `copyWith`/`lerp`/value-test shape — match it, do not diverge). **T03** depends on this task: it builds the four concrete `MihrabColors` instances (Light · Sepia · Dark · Night) from the §3/§5/§6 values and attaches each to its `ThemeData`. **T10** re-runs the WCAG audit over these token values per appearance. **T11**'s token-discipline grep proves no widget hardcodes a heat/decay/warning hex outside this file. Constructing the four instances and composing `ThemeData` is **NOT** this task — this task ships the type, its contract, and (optionally) one neutral default instance the tests pump. |

## Implementation notes

TEST-FIRST: write the `MihrabColors` value/`copyWith`/`lerp` suite below **before** the extension body. The field-set assertion (and the deliberate absence of `semanticSuccess`/`semanticDanger`) must exist and fail to compile/pass before the type is implemented — the missing field is a structural guarantee, so a test that would compile if the field were added is the canary.

1. **File**: `packages/features/lib/src/theme/mihrab_colors.dart`, one primary type per file. The design-system theme home is `packages/features/lib/src/theme/` (the shared leaf the `features` umbrella's screens consume; E07 reads it through `Theme.of(context)`). `MihrabColors` is exported from the theme barrel `packages/features/lib/src/theme/theme.dart`, not from a feature-screen library. Do **not** put this in `app/lib/` (the shell computes nothing) and do **not** invent a `utils/`/`common/` folder (banned — project-structure §4).

2. **Type**: `@immutable class MihrabColors extends ThemeExtension<MihrabColors>` with a `const MihrabColors({...})` constructor; every field is `final Color` and `required`. `///`-document the class (one sentence: "the bespoke color families M3 does not name…") and **every** field with its meaning and its owning §.

3. **The exact field set** — and nothing more:
   - **Heat-map ramp (5)**: `heatmapStrong`, `heatmapGood`, `heatmapFair`, `heatmapWeak`, `heatmapFaded` — in this fixed strong→faded order (03 §5). A `///` notes the ramp is monotonic-in-luminance and that the lower steps intentionally sit below the 3:1 graphical floor because number+label carry the value (the audit is T10's; the value rationale is the comment's).
   - **Track chip (1, or a small fixed set)**: the non-interactive sabaq/sabqi/manzil track-chip surface/`on` token(s) — calm, green-family, **never** three saturated "category colors." Carry `trackChipSurface` + `trackChipText` (the chip's *label color*; the localized track name itself is l10n, E09). Keep it minimal — if 03 specifies one neutral chip surface, ship one, not three.
   - **Calm decay (1)**: `decayCalm` — the per-page decay indicator tint, in the neutral/green family per 03 §6; explicitly **not** an alarm-red. A `///` restates: decay is never a semantic/error state.
   - **Reader surfaces (sepia + night)**: `readerSurfaceSepia`, `readerSurfaceNight` — the warm-paper and warm-dim reader backdrops (03 §3/§4) that transform the *surrounding surface*, never the glyph layer (a `///` restates the wall — these are surface tokens, not text styling).
   - **Semantic (1)**: `semanticWarning` only (03 §6).
   - **Deliberately absent**: no `semanticSuccess`, no `semanticDanger`, no `streak*`, no `celebrate*`, no `reward*`. A class-level `///` states the absence is intentional (PRD R3/C6; 03 §2/§6) so a future contributor does not "helpfully" add `semanticSuccess`.

4. **`copyWith`**: hand-written `MihrabColors copyWith({Color? heatmapStrong, …})` returning a new instance with `field ?? this.field` for **every** field. No field omitted (a missing field is a silent-stale-token bug the value test must catch).

5. **`lerp`**: `@override MihrabColors lerp(ThemeExtension<MihrabColors>? other, double t)`. Return `this` when `other is! MihrabColors`. Otherwise interpolate **every** field with `Color.lerp(a, b, t)!` (the `!` is acceptable here only because both operands are non-null `Color`s — it is not an engine/persistence force-unwrap; a `///`/comment notes why). The point of `lerp` per 02 §9 is smooth Light→Sepia→Dark→Night transitions; every field must participate or that appearance crossfade tears.

6. **Values are NOT hardcoded here as the "real" four appearances** — that is T03. This task may ship **one** neutral placeholder/default `const MihrabColors` (e.g. a Light-derived instance) purely so the type compiles, the tests can pump it, and E07 has something to render before T03 lands; mark it clearly as the default the four real instances (T03) replace. The audited per-appearance hexes from 03 §3/§5/§6 are transcribed in T03, re-audited in T10 — do not duplicate the four tables here.

7. **No `Theme.of` lookups, no widgets, no l10n, no engine, no clock** in this file — it is a pure value type. The only import is `package:flutter/material.dart` (for `Color`/`ThemeExtension`/`@immutable`). No `package:http`, no `dart:io`, no Drift, no ML/audio.

8. **Pitfalls to avoid**: adding a `semanticSuccess`/`semanticDanger`/`streak` field "for symmetry" (the absence is the spec — a review reject); omitting a field from `copyWith` or `lerp` (the two classic `ThemeExtension` bugs — both caught by the suite); encoding the decay end as a red/amber/saturated tint (violates 03 §5/§6); shipping three saturated track-category colors instead of one calm chip surface; reading these via a global `const MihrabColorsLight` instead of `Theme.of(context).extension<MihrabColors>()` (defeats theming + the audit); hardcoding any of these hexes in a widget elsewhere (T11's grep fails); putting the four real appearance tables in this file (that is T03's ownership boundary); using `==` on interpolated channels in the `lerp` test.

## Acceptance criteria

- [ ] `packages/features/lib/src/theme/mihrab_colors.dart` exists; `MihrabColors extends ThemeExtension<MihrabColors>`, is `@immutable` with a `const` constructor and all-`final Color` `required` fields; it imports only `package:flutter/material.dart` (grep-verifiable: no `http`/`dart:io`/`drift`/audio import).
- [ ] The field set is **exactly**: `heatmapStrong`, `heatmapGood`, `heatmapFair`, `heatmapWeak`, `heatmapFaded` (ramp, in that order), `trackChipSurface`, `trackChipText`, `decayCalm`, `readerSurfaceSepia`, `readerSurfaceNight`, `semanticWarning` — and **no** `semanticSuccess`, `semanticDanger`, `streak*`, `celebrate*`, or `reward*` field.
- [ ] `copyWith` accepts an optional override for **every** field and returns a new instance with `value ?? this.value` for each; no field is omitted.
- [ ] `lerp` returns `this` when `other` is not a `MihrabColors`, and otherwise interpolates **every** field via `Color.lerp(...)`; no field is left un-interpolated (i.e. snapping mid-transition).
- [ ] The extension is consumed only via `Theme.of(context).extension<MihrabColors>()`; this file exposes no global `const` instance other than the clearly-labelled compile/test default the four real instances (E06-T03) replace.
- [ ] Every `public` declaration (the class and each field) carries a `///` doc comment naming its owning 03 § and (for the ramp/decay/semantic) the calm/no-reward rationale; the deliberate absence of success/danger tokens is documented at the class level; `dart analyze --fatal-infos` is clean.
- [ ] The REUSE SPDX header (`GPL-3.0-or-later`) is present; `dart format --output=none --set-exit-if-changed` reports no change; no user-facing string is hardcoded in the file.

## Tests

`packages/features/test/theme/mihrab_colors_test.dart` (mirrors the source path, eng-write-dart-test §11), **`flutter_test`** (the type uses `Color`/`ThemeExtension` from Material — a widget-binding unit test, not a `package:test` engine test, and not a `@Tags(['golden'])` golden), REUSE header, run under `flutter test` in the fast lane. Fixtures are explicit `MihrabColors(...)` literals with distinct sentinel `Color`s per field — no clock, no DB, no network. The shared throwing-`HttpOverrides` offline bootstrap (E01-T06) stays installed (this is not the downloader test). Required cases, written **FIRST**:

- **Field-set / no-success-token guard**: construct a `MihrabColors`; assert each documented field is readable. The structural guarantee is asserted by *the test itself referencing no `semanticSuccess`/`semanticDanger`/`streak`/`celebrate` getter* — a comment in the file states that adding such a field (which would let a test compile against it) is the regression this absence prevents. (Belt-and-suspenders: E06-T11's token-discipline grep also asserts no `success`/`danger`/`streak`/`celebrate` color identifier exists in the design-system source.)
- **`copyWith` round-trips every field**: `copyWith()` with no args equals the original (all fields preserved); `copyWith(heatmapStrong: x)` changes only `heatmapStrong` and leaves all other fields byte-equal — repeated once per field so an omitted field in `copyWith` fails loudly.
- **`lerp(other, 0)` == `this` and `lerp(other, 1)` == `other`** (per field), and `lerp(null, t) == this`; `lerp(other, 0.5)` interpolates **every** field to `Color.lerp(a, b, 0.5)` — assert per channel (a.r/g/b/a vs expected) so a field left un-lerped (snapping to `a` or `b`) is caught; never `==` on the raw interpolated value where a tolerance is meaningful.
- **Ramp monotonic-in-luminance (sanity, on the default instance)**: compute relative luminance of `heatmapStrong…heatmapFaded` and assert the sequence is monotonic for the shipped default instance — a cheap guard that the default ramp obeys 03 §5 (the per-appearance audit is E06-T10; this is only a smoke check on the placeholder default, skipped if no default is shipped).

Offline / no-network guard: the throwing `HttpOverrides` is active for this suite (no opt-out — only the downloader opts out). No `pumpAndSettle` on an indefinite indicator; no golden master is created here (appearance × locale goldens are E06-T11).

## Definition of Done

- [ ] All acceptance criteria met; the value/`copyWith`/`lerp` suite is green locally and in the E01 fast lane; the suite was written before the type body (test-first).
- [ ] **Offline / no-network by construction**: this file and its test add no network path; the throwing `HttpOverrides` guard stays installed; the E01 dependency allow-list stays green (`features` declares no `http`/`crypto`).
- [ ] **No AI / no microphone**: no ML/ASR/audio/microphone path is introduced; the extension is a pure color value type ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **No gamification of worship — by structure**: `MihrabColors` exposes **no** `semanticSuccess`, `semanticDanger`, `streak*`, `celebrate*`, or `reward*` field; "saved/verified" is left to icon + text in the M3 accent green, and the only red-adjacent token is `semanticWarning` for a genuine asset-integrity failure ([PRD R3/C6](../../docs/PRD.md); design-system 03 §2/§6).
- [ ] **Calm is enforced, not hoped**: the heat-map ramp is single-hue and monotonic-in-luminance (no red→green, no rainbow), and the decay/track tokens are calm neutral/green-family, never alarm-red ([design-system 03 §5/§6](../../docs/design-system/03-color-and-themes.md)).
- [ ] **Quran text fidelity — the wall is respected**: the `readerSurfaceSepia`/`readerSurfaceNight` tokens are surface backdrops only; nothing in this file styles, re-tints, or references a glyph/QPC asset (the muṣḥaf is transformed by the surrounding surface, never by these tokens) ([PRD R1](../../docs/PRD.md); design-system 03 §4, 02 §3).
- [ ] **RTL + fa/ckb/ar**: color carries no direction — these tokens are identical across all three RTL locales; no per-locale or per-direction color is introduced, and no user-facing string is hardcoded (any track-name string is `l10n.*`, owned by E09).
- [ ] **Accessibility**: the token *values* per appearance are not finalized here, but the field set and ramp ordering this task fixes are exactly what E06-T10's WCAG 2.2 AA audit re-runs per appearance; the `decayCalm`/heat lower steps are documented as label-carried (color never the sole channel, SC 1.4.1) ([design-system 03 §7](../../docs/design-system/03-color-and-themes.md)).
- [ ] **Sect-neutral adab**: no green is exposed as a reward/celebration token and no token decorates the muṣḥaf; the families are reverent ground that serves the page ([design-system 03 §2](../../docs/design-system/03-color-and-themes.md)).
- [ ] **Deterministic tests**: the suite uses explicit `MihrabColors` literals with sentinel colors, no clock/DB/network, and asserts `lerp` per channel (no `==` on interpolated doubles); coding standards hold (REUSE header, full-word field names, `///` on public APIs, `dart format`/analyzer clean).
