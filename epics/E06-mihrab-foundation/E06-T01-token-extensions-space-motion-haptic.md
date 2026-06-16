# E06-T01 — SpacingTokens, MotionTokens & HapticTokens ThemeExtensions with copyWith/lerp + unit tests

| | |
|---|---|
| **Epic** | [E06 — Mihrab Design Foundation](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E01 |
| **Skills** | eng-write-to-coding-standards, eng-write-dart-test |

## Goal

Three immutable `ThemeExtension`s live in the `features` package theme folder and carry the non-colour token families the whole design system reads through the theme tree: `SpacingTokens` (`space1`…`space8`, the 4dp-step-on-8dp-grid scale), `MotionTokens` (`durationShort`=150ms, `durationMedium`=250ms, `curveStandard`, with **no celebrate tier**), and `HapticTokens` (exactly the three pulses `selection`/`confirm`/`warning`, with **no success/reward pulse**). Each is `final`, carries `///` docs on every public member, implements `copyWith` and `lerp` correctly, and is read only via `Theme.of(context).extension<T>()` — never a global constant or a raw value in a widget. A test-first `package:test` unit suite pins every token value and proves `lerp` interpolates (durations/spacing) and threshold-switches (the discrete haptic enum / curve) as Flutter's theme-transition machinery requires.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/05-layout-spacing-touch.md` §1 | The exact spacing scale to pin: `space1`=4 · `space2`=8 · `space3`=12 · `space4`=16 (default padding / compact edge margin) · `space5`=20 · `space6`=24 · `space7`=32 · `space8`=48; defined **once** in `SpacingTokens extends ThemeExtension<SpacingTokens>`, read as `Theme.of(context).extension<SpacingTokens>()!.space4`; no widget hardcodes a raw dp |
| `docs/design-system/06-motion-and-haptics.md` §1 | `motion.duration.short`=150ms (`Durations.short3`), `motion.duration.medium`=250ms (`Durations.medium1`), `motion.curve.standard`=`Curves.fastOutSlowIn`; short/medium rungs only — never `long`/`extralong` for routine UI; all `motion.*` values live in one typed `ThemeExtension`, read as `…extension<MotionTokens>()!.durationMedium`; identical across fa/ckb/ar (timing is direction-agnostic) |
| `docs/design-system/06-motion-and-haptics.md` §2 | **No celebrate tier exists.** There is no `motion.celebrate.*` token, no confetti, no "success" animation tier — this is the single non-negotiable of that file; the absence is the enforcement, so this task introduces no such field even as a stub |
| `docs/design-system/06-motion-and-haptics.md` §4 | The exact three-pulse vocabulary to pin: `haptic.selection` → `HapticFeedback.selectionClick()`; `haptic.confirm` → `HapticFeedback.lightImpact()`; `haptic.warning` → `HapticFeedback.lightImpact()` (paired with a warning state). **No success/reward haptic.** Each pulse always accompanies an on-screen change and never repeats/escalates; carries no language or direction (identical across all locales) |
| `docs/design-system/02-material-and-platform-foundations.md` §9 | The token-store mechanism: M3 roles live in `ThemeData`; every bespoke family lives in a `ThemeExtension` with `copyWith`/`lerp`; read only through `Theme.of(context).extension<T>()`; no scattered constants — one auditable source of truth (the colour extension is the sibling E06-T02, the four `ThemeData` are wired in E06-T06) |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | Effective Dart casing (`SpacingTokens`, `durationMedium`, file `spacing_tokens.dart`); full-word unit-bearing names (`durationShort`, not `dShort`; `space4`, never `s4`); immutable value types — `final` fields, `const` constructor, `copyWith`; `///` on every public member; the REUSE SPDX header (`GPL-3.0-or-later`) on every file; no `print`/network/AI path; no user-facing string in Dart |
| Skill `eng-write-dart-test` (+ `template.dart`) | These are pure presentation value types, so the suite is **`package:test`-style** `test()`/`group()`/`expect()` under the package `test/`; `closeTo(expected, 1e-6)` for any interpolated double; the throwing `HttpOverrides` offline-guard bootstrap stays installed; REUSE SPDX header; full-word names in tests too |
| CLAIMS register | **None.** No user-facing number, copy, or factual claim ships here — these are internal dp/ms/enum tokens with no on-screen text; the science-screen / CLAIMS path (E19) is not touched |
| Siblings: E06-T02, E06-T06, E06-T07 | T02 authors the parallel `MihrabColors` extension (same `copyWith`/`lerp` pattern, the warning semantic with no success/danger) — keep the file/test shape consistent; T06 composes all extensions into the four `ThemeData` and is the **only** task that registers these in `extensions: [...]` (registration is NOT this task); T07's reduce-motion helper and `pageTurn` transition *consume* `MotionTokens` — this task only defines the durations/curve they read |

## Implementation notes

TEST-FIRST: write the value-pinning and `lerp` suite below **before** the extension bodies. The exact `space1`…`space8` numbers, the 150/250 durations, the `fastOutSlowIn` curve, the three haptic mappings, and the `lerp` midpoint expectations must exist and fail before the fields are filled in — a wrong dp or a dropped pulse is then a red test, not a silent drift.

1. **Files** (one primary type per file, in the `features` umbrella package theme folder):
   - `packages/features/lib/src/theme/spacing_tokens.dart`
   - `packages/features/lib/src/theme/motion_tokens.dart`
   - `packages/features/lib/src/theme/haptic_tokens.dart`
   Re-export the three from a `packages/features/lib/src/theme/tokens.dart` barrel (and onward through `lib/features.dart`) so E06-T06 imports one symbol set. No new package, no engine/data dependency — these are Flutter presentation types (`material`/`services` only).

2. **`SpacingTokens`** — `@immutable class SpacingTokens extends ThemeExtension<SpacingTokens>`. Eight `final double` fields `space1`…`space8`; a `const SpacingTokens({required …})` constructor and a `const SpacingTokens.standard()` (or a `static const standard`) that pins `4, 8, 12, 16, 20, 24, 32, 48` per 05 §1. `copyWith` takes eight nullable doubles and falls back to `this.spaceN`. `lerp(SpacingTokens? other, double t)` returns a new `SpacingTokens` with each field `lerpDouble(spaceN, other.spaceN, t) ?? spaceN` (handle `other == null` by returning `this`). `///` each field with its dp value and typical use ("`space4` — 16dp, default card/sheet padding and compact screen edge margin").

3. **`MotionTokens`** — `@immutable class MotionTokens extends ThemeExtension<MotionTokens>`. Fields: `final Duration durationShort` (`Duration(milliseconds: 150)`), `final Duration durationMedium` (`Duration(milliseconds: 250)`), `final Curve curveStandard` (`Curves.fastOutSlowIn`). A `const MotionTokens.standard()` pins these. `copyWith` over the three. `lerp`: interpolate the two durations with `lerpDuration(a, b, t)` (or `Duration(milliseconds: lerpDouble(...).round())`); a `Curve` does not meaningfully interpolate, so `lerp` **threshold-switches** the curve at `t < 0.5 ? curveStandard : other.curveStandard` — document why in a `// why` comment. **Do not add** a `durationLong`, `curveEmphasized`, `celebrate`, or any "success"/reward field — 06 §1 reserves `emphasized`/`long` for the single page→recite hero owned elsewhere, and 06 §2 forbids a celebrate tier outright; the field simply does not exist here.

4. **`HapticTokens`** — model the three pulses as a small `enum HapticPulse { selection, confirm, warning }` plus a `HapticTokens extends ThemeExtension<HapticTokens>` that maps each to its platform call. Keep the *mapping* in the token type (e.g. a `Future<void> fire(HapticPulse pulse)` that switches to `HapticFeedback.selectionClick()` / `lightImpact()` / `lightImpact()`), so widgets call `…extension<HapticTokens>()!.fire(HapticPulse.confirm)` and never reach `HapticFeedback` directly. The three fields/cases are the *entire* surface — **no `success`, no `reward`, no `heavyImpact`, no `vibrate`** (06 §4). `copyWith` returns a token set (these tokens carry no tunable value, so `copyWith`/`lerp` are trivial — `lerp` returns `this` for any `t`, with a `// why` comment: haptics are discrete platform calls, nothing to interpolate). Mark `selection`/`confirm`/`warning` with `///` stating *meaning* and the exact `HapticFeedback` call.

5. **Read path discipline.** None of the three types is exported as a top-level `const` a widget could import directly; the *only* sanctioned read is `Theme.of(context).extension<SpacingTokens>()!` (and siblings). This task does not register them on any `ThemeData` (E06-T06 owns `extensions: [...]`), but the `.standard()` constants exist so T06 and the unit tests can construct them without a `BuildContext`.

6. **Pitfalls to avoid:**
   - A `lerp` that returns `this` for the interpolating families (spacing/motion-duration) — that silently freezes theme transitions; only the discrete families (curve, haptic) legitimately threshold-switch or no-op.
   - Forgetting the `other == null` branch in `lerp` (Flutter passes `null` at the ends of a transition) — return `this`.
   - A bare `Duration(milliseconds: 220)` or `EdgeInsets.all(13)` leaking into a widget instead of a token — out of scope to grep here (that gate is E06-T11), but do not introduce one in this task's own code.
   - Adding a "just in case" `durationLong`/`celebrate`/`success` field — the missing token *is* the enforcement; a stub re-opens the door 06 §2 closed.
   - Reaching `HapticFeedback` from a widget — all tactile calls route through `HapticTokens.fire`.
   - Single-letter or abbreviated field names (`s4`, `dShort`) — full words with the unit implied by the family.

## Acceptance criteria

- [ ] `spacing_tokens.dart`, `motion_tokens.dart`, `haptic_tokens.dart` exist under `packages/features/lib/src/theme/`, each one primary type, each with the REUSE `GPL-3.0-or-later` SPDX header; barrel re-exports them.
- [ ] All three extend `ThemeExtension<Self>`, are `@immutable` with `final` fields and a `const` constructor, and expose a `.standard()` const that pins the audited values.
- [ ] `SpacingTokens.standard()` yields exactly `space1=4, space2=8, space3=12, space4=16, space5=20, space6=24, space7=32, space8=48` (05 §1).
- [ ] `MotionTokens.standard()` yields `durationShort=150ms`, `durationMedium=250ms`, `curveStandard=Curves.fastOutSlowIn` (06 §1); there is **no** `long`/`emphasized`/`celebrate`/`success` field anywhere in the type.
- [ ] `HapticTokens` exposes exactly `selection`→`selectionClick()`, `confirm`→`lightImpact()`, `warning`→`lightImpact()` via a single `fire(HapticPulse)` path; there is **no** success/reward pulse, no `heavyImpact`, no `vibrate` (06 §4).
- [ ] Each type's `copyWith` returns an independent copy with only the named fields overridden; each `lerp` handles `other == null` (returns `this`), interpolates the continuous families, and threshold-switches/no-ops the discrete ones — with a `// why` comment on each non-interpolating branch.
- [ ] Every public member carries a `///` doc; the file passes `dart format --set-exit-if-changed` and `dart analyze --fatal-infos` (incl. `public_member_api_docs`) clean.
- [ ] No raw value, no top-level `const` token, and no `HapticFeedback` call is reachable from a widget except through `Theme.of(context).extension<T>()`; no `print`, no network import, no AI/audio path is introduced.

## Tests

`packages/features/test/theme/spacing_tokens_test.dart`, `motion_tokens_test.dart`, `haptic_tokens_test.dart` (file names mirror sources), **written FIRST**, `package:test`-style (`group`/`test`/`expect`), REUSE SPDX header, run under `flutter test` on the E01 fast CI lane with the throwing-`HttpOverrides` offline guard installed from the shared bootstrap. No `BuildContext`, no `pumpWidget`, no network. Required cases:

- **Spacing values pinned**: `SpacingTokens.standard()` equals `[4,8,12,16,20,24,32,48]` field-by-field (a wrong or off-scale dp fails).
- **Spacing copyWith**: overriding `space4` changes only `space4`; all other fields unchanged; the original is untouched.
- **Spacing lerp**: `a.lerp(b, 0.5)` returns the per-field midpoint (`closeTo(expected, 1e-6)`); `lerp(null, t)` returns a value field-equal to `a`; `t=0`→`a`, `t=1`→`b`.
- **Motion values pinned**: `durationShort == Duration(milliseconds: 150)`, `durationMedium == Duration(milliseconds: 250)`, `curveStandard == Curves.fastOutSlowIn`.
- **Motion has no celebrate/long tier**: a guard test (compile-time by construction + an explicit assertion that the public surface is exactly the three fields) documenting that no `celebrate`/`success`/`long`/`emphasized` member exists — the structural restatement of 06 §2.
- **Motion lerp**: durations interpolate to the rounded-ms midpoint; the curve threshold-switches at `t=0.5`; `lerp(null, t)` returns `this`.
- **Haptic mapping**: `selection`/`confirm`/`warning` map to `selectionClick`/`lightImpact`/`lightImpact` — verified by capturing the `SystemChannels.platform` / `HapticFeedback` method-channel calls via `TestDefaultBinaryMessengerBinding` mock and asserting the exact method + argument fired for each pulse.
- **Haptic surface is exactly three pulses**: `HapticPulse.values` is `[selection, confirm, warning]` (no fourth); no path fires `heavyImpact` or `vibrate`.
- **Haptic lerp/copyWith are no-ops**: `lerp(other, t)` and `copyWith()` return an equivalent token set for any `t` (discrete platform calls, nothing to interpolate).

No golden, widget, integration, or engine-vector test is in scope — these are leaf presentation value types (goldens of the skeleton widgets that *use* them are E06-T11).

## Definition of Done

- [ ] All acceptance criteria met; the three suites are green locally and on the E01 fast CI lane.
- [ ] **Offline / no-network by construction**: no networking import is added; the throwing `HttpOverrides` guard stays installed and green; the token files import only `package:flutter/material.dart`/`services.dart`.
- [ ] **No AI / no microphone**: no ML/ASR/audio path; haptics are discrete `HapticFeedback` calls only, never an audio cue or recognition surface.
- [ ] **Quran text fidelity untouched**: these tokens set distance, time, and touch only — they reference no font, no `TextStyle`, no glyph, and never reach a muṣḥaf/QPC asset; the pipeline wall (E06-T05) is not crossed.
- [ ] **RTL + fa/ckb/ar**: spacing is consumed through `EdgeInsetsDirectional` by callers (this task ships direction-agnostic scalars); motion timing and haptics are identical across all three locales by construction; no string ships, so no ARB entry is needed.
- [ ] **No gamification of worship — by structure**: there is no `motion.celebrate.*` token, no "success"/reward duration or curve, and no success/reward haptic *to reach for*; the absence is asserted by the surface-is-exactly-N tests.
- [ ] **Accessibility contracts honored**: the `space.*` scale carries the 48dp touch-target / ≥8dp-gap values (`touch.min`=48=`space8`, gap=`space2`) callers compose with; reduce-motion consumption is E06-T07's, but `MotionTokens` exposes the durations that helper collapses.
- [ ] **Sect-neutral adab**: no decorative or celebratory token, no reward surface — calm, informative tokens only; reverent ground that serves the page.
- [ ] **Deterministic tests**: every value is pinned with `closeTo(_, 1e-6)` for doubles and exact equality for durations/enums; no wall clock, no `BuildContext`, no randomness; doc comments on all public members; `dart format` + `dart analyze --fatal-infos` clean.
