# E06-T07 — Reduce-motion helper + directional start→end pageTurn transition (test-first on disableAnimations)

| | |
|---|---|
| **Epic** | [E06 — Mihrab Design Foundation](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E06-T01 |
| **Skills** | eng-write-to-coding-standards, eng-rtl-and-bidi-layout, eng-write-dart-test |

## Goal

Two small presentation primitives live in the `features` theme folder and turn the prose rules of design-system 06 §3/§5 into code every later motion surface reuses. A centralized `motionReduced(context)` helper reads `MediaQuery.of(context).disableAnimations` so any `motion.*` transition can collapse to a cross-fade or instant cut when the OS asks for it — **the OS flag always wins**, no animation plays "because it's subtle." Alongside it, `motion.transition.pageTurn` is a directional slide shaped **start→end in RTL** (the next page enters from the start/right edge, the current page exits toward the end/left), derived from `Directionality.of(context)` so fa, ckb, and ar all advance right-to-left with no per-locale branch — and it too honours the reduce-motion helper. A test-first `flutter_test` widget suite, written before the helper, asserts the cut path under `disableAnimations: true` and the RTL slide direction.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/06-motion-and-haptics.md` §5 | Reduce-motion is honoured **absolutely** — when `MediaQuery.disableAnimations` is set the app substitutes a cross-fade or instant cut and no animation plays through the flag; the read is **centralised in a small helper**; nothing the app animates is information-bearing, so the cut hides no meaning (the SC 2.3.3 "unless essential" carve-out). The helper this task lands is that one centralisation point. |
| `docs/design-system/06-motion-and-haptics.md` §3 | `motion.transition.pageTurn` is a directional slide at `motion.duration.medium` with `motion.curve.standard`; in RTL the **next page enters from the start (right) edge and the current page exits toward the end (left)**, matching a physical muṣḥaf's right-to-left progression. Direction is a *logical* property read from `Directionality`, never a hardcoded left/right, so one transition serves all three locales. Only the page *surface* slides — never re-typeset glyphs (that immutable-page rule is E05's; this task only ships the surface transition). |
| `docs/design-system/06-motion-and-haptics.md` §1 | The transition resolves its duration/curve from `MotionTokens` via `Theme.of(context).extension<MotionTokens>()!.durationMedium` / `.curveStandard` — never a raw `Duration` or bespoke `Curve` in the widget; identical timing across fa/ckb/ar (only direction differs). No `long`/`extralong`/`emphasized` here — the page→recite hero is a different surface owned elsewhere. |
| `docs/design-system/05-layout-spacing-touch.md` §3 | RTL is the layout's geometry, not a mode: directional motion follows the script's native reading geometry; leading sits at start (right), next-affordances at end (left) and mirror automatically. The page-turn's start→end direction is the motion counterpart of this geometry. |
| Skill `eng-rtl-and-bidi-layout` (+ `template.dart`) | Direction is **locale-derived, never a constant**: read `Directionality.of(context)`; never assume `TextDirection.rtl` in logic, never name physical left/right. The page-turn's offsets are expressed start→end and let one `Directionality` flip mirror them; this is the §2 "we refuse to assume RTL in logic" rule applied to motion. No mirroring/numeral/bidi/font logic reaches a muṣḥaf glyph — this task moves only a presentation surface. |
| Skill `eng-write-dart-test` (+ `template.dart`) | TEST-FIRST: the widget suite is written before the helper. Use `flutter_test` (`testWidgets`/`pumpWidget`), pump under explicit `MediaQuery`/`Directionality`, pump explicit durations (never `pumpAndSettle` on an indefinite indicator), keep the throwing-`HttpOverrides` offline guard installed, REUSE SPDX header, full-word names. RTL asserted by construction. |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | Effective Dart casing (`motionReduced`, `pageTurnTransition`, files `reduced_motion.dart` / `page_turn_transition.dart`); full-word names; `///` on every public member; `const`/`final`; REUSE `GPL-3.0-or-later` SPDX header on every file; no `print`/network/AI path; no user-facing string in Dart; RTL structural, not per-widget. |
| Siblings: E06-T01, E06-T06, E06-T08 | T01 defines the `MotionTokens` (`durationMedium`, `curveStandard`, **no celebrate tier**) this transition *consumes* — it does not redefine them; T06 registers `MotionTokens` in the four `ThemeData` `extensions: [...]` so `Theme.of(context).extension<MotionTokens>()` resolves at runtime; T08's `MihrabScaffold`/`NavigationBar` skeleton and (later, E07/E05) the reader page advance are the first consumers of `pageTurnTransition` and `motionReduced`. |
| CLAIMS | None — this is presentation-only motion plumbing; no on-screen number, methodology copy, or factual claim is introduced, so no CLAIMS id applies. |

## Implementation notes

TEST-FIRST: write the widget suite below (the `disableAnimations: true` cut case and the RTL slide-direction case) **before** the helper and transition bodies; both cases must exist and fail before `motionReduced` / `pageTurnTransition` are implemented.

1. **Files** (one primary type/helper per file, in the `features` umbrella package theme folder; `material`/`widgets` imports only — no engine/data dependency):
   - `packages/features/lib/src/theme/reduced_motion.dart` — the centralized helper.
   - `packages/features/lib/src/theme/page_turn_transition.dart` — the directional transition.
   Re-export both through the existing `packages/features/lib/src/theme/tokens.dart` barrel (and onward via `lib/features.dart`) so consumers import one symbol set, consistent with E06-T01.
2. **The reduce-motion helper.** `bool motionReduced(BuildContext context) => MediaQuery.of(context).disableAnimations;` — one `///`-documented top-level function (or a `MotionReduced` extension on `BuildContext`), the **single** place `disableAnimations` is read in the design system. Document the contract: the OS flag always wins; callers that animate must branch on this and substitute a cross-fade/instant cut (06 §5). Do **not** read `MediaQuery.maybeOf` and silently default to "animate" — absent `MediaQuery` is a programmer error in this tree, surfaced via the framework's own assertion.
3. **The directional page-turn.** A widget (e.g. `PageTurnTransition` wrapping an `AnimatedSwitcher`, or a function returning the M3 shared-axis / `SlideTransition` builder) whose incoming child slides from **start** to centre and outgoing child exits toward **end**. Express the slide with **direction-relative** offsets: read `Directionality.of(context)`; the start edge is `Offset(+1, 0)` in RTL (right) and `Offset(-1, 0)` in LTR — derive it from `TextDirection`, never hardcode a sign. Pull `durationMedium` and `curveStandard` from `Theme.of(context).extension<MotionTokens>()!`; no literal `Duration`/`Curve`.
4. **Wire the helper into the transition.** Inside `pageTurnTransition`, if `motionReduced(context)` is true, replace the slide with a cross-fade (`AnimatedSwitcher` with a `FadeTransition` builder) or, where a fade still reads as motion, an instant cut (swap with `Duration.zero`). This is the canonical example every other animated surface copies; the collapse is not optional and not overridable per-call (06 §5).
5. **No celebration, no hero here.** This task ships exactly the reduce-motion collapse and the routine directional page-turn. No `motion.celebrate.*`, no confetti, no `curveEmphasized`/`durationLong` page→recite hero (a different surface), no success/reward affordance — those tiers do not exist (06 §2; EPIC DoD). Resist adding them.
6. **The glyph layer is untouched.** Only the page *surface* (a box/child) slides; this task never re-typesets, reflows, mirrors, or reshapes muṣḥaf glyphs — the immutable-page rule belongs to E05/`quran` and the transition is handed a plain child here (06 §3; eng-rtl-and-bidi-layout §9).
7. **Pitfalls to avoid:** hardcoding a left→right slide or a physical `Offset(-1,0)` for "next" (breaks RTL — derive from `Directionality`); reading `disableAnimations` ad-hoc in feature widgets instead of through the one helper (defeats centralisation); pulling a raw `Duration(milliseconds: 250)`/`Curves.fastOutSlowIn` instead of the `MotionTokens` fields (token-discipline violation E06-T11 greps for); calling `pumpAndSettle()` over an `AnimatedSwitcher` in the cut test (assert no in-between frame instead); adding `MediaQuery.maybeOf` fall-throughs that animate when the flag is unknown.

## Acceptance criteria

- [ ] `reduced_motion.dart` and `page_turn_transition.dart` exist under `packages/features/lib/src/theme/`, each one primary type/helper, each carrying the REUSE `GPL-3.0-or-later` SPDX header; both re-exported through the `tokens.dart` barrel.
- [ ] `motionReduced(context)` returns `MediaQuery.of(context).disableAnimations` and is the only place in the design system that reads `disableAnimations` (verifiable by grep: no other `disableAnimations` reference in `packages/features/lib/`).
- [ ] `pageTurnTransition` slides the entering child **from start (right) toward centre and the exiting child toward end (left) in RTL**, with the directions deriving from `Directionality.of(context)` (LTR is the mirror) — no hardcoded `left`/`right` or fixed-sign `Offset`.
- [ ] The transition resolves its duration and curve from `Theme.of(context).extension<MotionTokens>()!.durationMedium` / `.curveStandard` — no literal `Duration` or `Curve` in either file.
- [ ] When `motionReduced(context)` is true, `pageTurnTransition` collapses to a cross-fade or instant cut — no slide frame is rendered; the collapse cannot be overridden per call.
- [ ] No `celebrate`/`emphasized`/`long`/success/reward field, curve, or branch appears in either file.
- [ ] Every public member carries a `///` doc; `dart format` and `dart analyze --fatal-infos` clean; no `print`/network/AI path; no user-facing string hardcoded.

## Tests

`packages/features/test/theme/page_turn_transition_test.dart` and `packages/features/test/theme/reduced_motion_test.dart` (file names mirror sources), **written FIRST**, `flutter_test` (`testWidgets`), REUSE `GPL-3.0-or-later` SPDX header, run under `flutter test` on the E01 fast CI lane with the throwing-`HttpOverrides` offline guard installed from the shared bootstrap. Each screen is pumped under an explicit `MediaQuery` and `Directionality` wired to a `Theme` carrying `MotionTokens.standard()` in `extensions:` — no real DB, no assets, no network, no wall clock. Required cases:

- **Reduce-motion cut (the headline test):** pump `pageTurnTransition` between two distinguishable children under `MediaQuery(data: MediaQueryData(disableAnimations: true))`; trigger the child swap; pump a single small frame and assert the outgoing child is gone and the incoming child is fully present with **no intermediate slid/half-opacity frame** — proving the cut path, not a sped-up slide.
- **Reduce-motion vs. animated parity:** the same swap under `disableAnimations: false` renders an in-between (partially-offset or partially-faded) frame at `durationMedium / 2`, confirming the two paths genuinely differ.
- **RTL slide direction:** under `Directionality(TextDirection.rtl)` and `disableAnimations: false`, capture the incoming child's offset mid-transition and assert it enters **from the start/right** (positive-x toward centre) and the outgoing child exits **toward the end/left** — the start→end-in-RTL shape of 06 §3.
- **LTR mirrors:** the identical setup under `TextDirection.ltr` enters from the opposite side, proving the direction is `Directionality`-derived, not hardcoded.
- **Tokens are honoured:** the transition's duration equals `MotionTokens.standard().durationMedium` and its curve equals `.curveStandard` (assert via the resolved animation, not a literal), proving no raw value leaked in.
- **Helper unit behaviour:** `motionReduced(context)` returns `true`/`false` exactly tracking the pumped `disableAnimations` value.

CI lanes unchanged: the E01 fast lane runs these (no `Date()`, no networking symbols, throwing-`HttpOverrides` green); the four-appearance × three-locale skeleton goldens that exercise this transition land in E06-T11.

## Definition of Done

- [ ] All acceptance criteria met; both suites green locally and on the E01 fast CI lane; the reduce-motion-cut and RTL-direction cases were written and failing before the implementation.
- [ ] **Offline / no-network by construction:** no networking import added; the throwing-`HttpOverrides` guard stays installed and green; both files import only `package:flutter/material.dart`/`widgets.dart`.
- [ ] **No AI / no microphone:** no ML/ASR/audio path; this is presentation-only motion plumbing with no recognition surface.
- [ ] **Quran text fidelity — the glyph layer is untouched:** only a presentation surface slides; no muṣḥaf glyph is re-typeset, reflowed, mirrored, or reshaped by this transition (the immutable page is E05's; this task hands the transition a plain child).
- [ ] **RTL + fa/ckb/ar:** the page-turn direction is `Directionality`-derived (start→end in RTL); no physical `left`/`right`, no fixed-sign offset; identical timing across all three locales (only direction differs); the RTL and LTR direction cases prove it.
- [ ] **Accessibility — reduce-motion honoured absolutely:** `MediaQuery.disableAnimations` collapses the transition to a cross-fade/instant cut through the one centralized helper; the OS flag always wins; nothing animated is information-bearing, so the cut hides no meaning (06 §5; SC 2.3.3 carve-out). The full per-locale reduce-motion audit program is E08's; this task lands the mechanism it audits.
- [ ] **No gamification of worship by structure:** no `celebrate`/`emphasized`/`long`/success/reward tier, curve, or branch exists in either file; the page-turn is informative, never a flourish (06 §2).
- [ ] **Sect-neutral adab:** the motion is calm and informative; no decorative or celebratory surface ships; the transition serves the page, never competes with it.
- [ ] **Deterministic tests:** fixed `MediaQuery`/`Directionality`/`MotionTokens` inputs, explicit pumped durations (no `pumpAndSettle` on an indefinite indicator), no wall clock, no socket; token discipline holds (no raw `Duration`/`Curve`); REUSE SPDX header and full-word names on every file.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
