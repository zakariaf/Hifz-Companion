# E08-T05 — Reduce-motion substitution helper honoring MediaQuery.disableAnimations, applied to shell transitions

| | |
|---|---|
| **Epic** | [E08 — Accessibility Foundation](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E06, E07 |
| **Skills** | eng-write-dart-test |

## Goal

A single reusable reduce-motion **substitution** widget exists under `packages/features/lib/src/a11y/` (`reduce_motion_substitution.dart`) — a `ReduceMotionSwitcher`-style wrapper that, when the OS Reduce Motion preference is set, substitutes an **instant cut or a cross-fade** for any *non-essential* motion, and otherwise renders the surface's calm animated transition unchanged. It reads the OS flag only through the **existing E06-T07 `motionReduced(context)` helper** (the one centralized `MediaQuery.disableAnimations` read; this task does not add a second read). It is then applied to the E07 shell's two non-essential motion surfaces — the **calm recite receipt** confirmation and the **banner reveal** (the catch-up note appearing on Today) — so when `disableAnimations` is `true` the state change appears at once with no slide/fade frame. By policy there is **no celebratory or flashing motion anywhere** to substitute, and a substitution may **never re-introduce a removed delight**: the fallback is always plainer than the animation, never a new flourish. A test-first widget suite asserts that under `disableAnimations: true` the substitution emits no intermediate animated frame on each wired surface, and that under `false` the calm animated path still renders.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/09-accessibility-and-inclusivity.md` §9 | The reduce-motion substitution convention this task lands: honor the OS Reduce Motion preference (`MediaQuery.disableAnimations`), substituting an instant/cross-fade state change for any **non-essential** motion — the calm-receipt recite confirmation and banner reveals — "with no celebratory or flashing motion anywhere by policy." §9 banks no-motion as an accessibility win; this task is the mechanism that keeps that win true on the live shell surfaces. The §9 anti-pattern ("add a feature that reintroduces a removed barrier — a flashing celebration, a streak-pressure animation") is exactly what the "substitution never re-introduces a removed delight" rule guards. |
| `docs/design-system/06-motion-and-haptics.md` §5 | Reduce-motion is honored **absolutely** — when `MediaQuery.disableAnimations` is set the app substitutes a cross-fade or instant cut and "no animation is allowed to play 'because it's subtle'"; the read is **centralized in one small helper** (E06-T07's `motionReduced`, which this task reuses, never re-reads); reveal-on-tap and reveal/banner surfaces appear without a fade. Nothing the app animates is information-bearing, so the cut hides no meaning — the SC 2.3.3 "unless essential" carve-out. Haptics follow the OS *system-haptics* setting independently of this visual flag (§4) and are out of scope here. |
| `docs/PRD.md` R3 | Calm, non-gamified worship: no streaks, confetti, flashing, or celebratory motion — the property this substitution must preserve, never undermine. The fallback is calmer than the animation, never a reward affordance. |
| `docs/PRD.md` C6 | No gamification of worship: a reduce-motion substitution may not smuggle in a celebration, badge, or delight; the only legal fallbacks are an instant cut or a cross-fade of an *already-calm* surface. |
| Skill **eng-write-dart-test** (+ `template.dart` — the widget-test scaffold with in-memory Riverpod fakes and the throwing-`HttpOverrides` bootstrap) | **TEST-FIRST**: the widget suite is written before the substitution widget. Use `flutter_test` (`testWidgets`/`pumpWidget`), pump each surface under an explicit `MediaQuery` (`disableAnimations: true`/`false`) and `Directionality`; **pump explicit durations, never `pumpAndSettle` over the substitution** (assert the absence of an in-between frame, §6/§9 pitfalls); keep the throwing-`HttpOverrides` offline guard installed; assert behaviour, never a coverage percentage; REUSE SPDX header; full-word names. |
| Sibling **E06-T07** (dependency E06) | Already ships the **single centralized** `motionReduced(BuildContext) => MediaQuery.of(context).disableAnimations` helper and the directional `pageTurnTransition` (which already collapses under it) in `packages/features/lib/src/theme/`. This task **consumes** `motionReduced` and does **not** re-implement it or add a second `disableAnimations` read; it generalizes the substitution shape beyond the page-turn into a reusable wrapper for the *non-transition* surfaces (receipt, banner) and applies it to the E07 shell. |
| Sibling **E07-T07 / E07-T08** (dependency E07) | T07 ships the live `today` slice (the `TodayScreen`/`TodayController` and the reactive queue); the catch-up **banner** copy/layout is deferred to E12 but the **reveal surface** it animates into rides this substitution. T08 ships the page-card + one-tap grade command; the **calm recite receipt** (the post-grade confirmation, full reveal flow owned by E12) is the second non-essential-motion surface this task wraps on the shell. This task wires the substitution into those surfaces' transitions; it never re-authors the queue, the grade command, or the banner content. |
| Sibling **E08-T02** | Supplies the `Semantics` announce path: a reduced-motion state change ("catch-up plan ready," "page graded") is still **announced** to the screen reader via T02's `announce(...)` in `TextDirection.rtl` — suppressing the *motion* never suppresses the *semantic* state change. This task does not duplicate that path; it ensures the visual substitution and the announce coexist. |
| Siblings **E08-T07 / E08-T10** | T07's PR-blocking audit harness and T10's deliberate-violation sweep adopt this task's reduce-motion assertion as the per-surface check behind the §10 reduce-motion pass; T10 proves the gate bites by flipping one wired surface to animate through the flag (it must then fail). |
| CLAIMS | **None.** This is presentation-only accessibility plumbing — no on-screen number, methodology copy, percentage, or factual claim is introduced, so **no CLAIMS id applies** (recorded explicitly in the PR description, per the E08-T04 precedent). |

## Implementation notes

**TEST-FIRST (correctness-critical — reduce-motion honoring is the release-blocking A-row / SC 2.3.3 carve-out):** write the widget suite below (the `disableAnimations: true` no-frame case per wired surface, and the animated-parity `false` case) **before** the substitution widget body and before wiring it into the shell surfaces. Each case must exist and fail (or, where the path is already plain, *document* the contract as a guarded assertion) before the implementation lands.

1. **File (shared a11y chrome module, not a new package).** Add `packages/features/lib/src/a11y/reduce_motion_substitution.dart` beside E08-T02's `semantics.dart`/`announce.dart` — a widget-layer helper in the `features` umbrella, **downward-only deps**: `package:flutter/material.dart`/`widgets.dart` and the E06-T07 theme barrel only — **no** engine, no drift, no http, no l10n key lookup. Re-export it through the existing `features` a11y/theme barrel so consumers import one symbol set. One primary public type per file.

2. **The substitution widget.** `ReduceMotionSwitcher` (e.g. wrapping an `AnimatedSwitcher`, or a small builder that picks a transition): it takes the surface's normal animated child/transition and, when `motionReduced(context)` is `true`, substitutes either an **instant cut** (swap with `Duration.zero`, no transition builder) or a **cross-fade** (`FadeTransition`) where a fade still reads as calm and information-bearing-free — never a slide, scale, or any motion the flag was set to remove. When `motionReduced(context)` is `false`, it renders the surface's own calm transition unchanged. The reduce-motion read is **delegated to `motionReduced(context)`** (E06-T07) — do **not** write `MediaQuery.of(context).disableAnimations` here; the single centralized read is the convention (E06-T07 AC; ds-06 §5).

3. **The substitution is plainer, never a new delight (the adab rule).** Document in the `///` contract that the fallback path is **always calmer or equal** to the animated path: an instant cut or a cross-fade of an already-calm surface. There is **no** celebratory/flashing/streak motion in the codebase to substitute (E06-T07 carries no `celebrate`/`emphasized`/reward tier), and this widget must not invent one as a "nicer" fallback (ds-09 §9 anti-pattern; PRD R3, C6). The collapse is **not overridable per call** — a surface cannot opt to keep animating through the flag.

4. **Apply to the E07 shell's two non-essential motion surfaces.**
   - **The calm recite receipt** (the post-grade confirmation surface on the shell; the full reveal/receipt flow is E12) — wrap its reveal/confirmation transition in `ReduceMotionSwitcher` so under `disableAnimations` it appears at once.
   - **The banner reveal** (the catch-up note appearing on Today; banner *content* is E12, the *reveal transition* rides here) — wrap its entrance transition so it appears without a slide/fade when motion is reduced.
   The `pageTurnTransition` and nav transitions already collapse via E06-T07 and are **not** re-wrapped here (avoid double-handling); this task owns the *non-transition* reveal surfaces ds-09 §9 names.

5. **Suppressing motion never suppresses the semantic state change.** Where a wrapped surface corresponds to a reader-relevant state change, the E08-T02 `announce(...)` path still fires in `TextDirection.rtl` with the localized message — reduce-motion removes the *visual* animation only, never the announce. This task does not add or duplicate the announce; it ensures the substitution does not gate it.

6. **Pitfalls to avoid:**
   - Adding a second `MediaQuery.disableAnimations` read in feature code instead of calling `motionReduced(context)` — defeats the one-helper centralization (E06-T07 AC greps for exactly one read site).
   - Substituting a "nicer" fallback (a pop, a scale, a sparkle) for a removed animation — re-introduces a delight the flag asked to remove (ds-09 §9; PRD R3/C6).
   - Animating "because the fade is subtle" through the flag — the OS flag always wins (ds-06 §5; SC 2.3.3).
   - Calling `pumpAndSettle()` over the substitution in the cut test (it can mask a one-frame slide) — pump a single explicit small frame and assert no intermediate state instead (eng-write-dart-test §6, §9 pitfalls).
   - Re-wrapping the `pageTurnTransition`/nav transitions that E06-T07 already collapses (double-handling).
   - Reaching for the muṣḥaf glyph layer — this widget only swaps a presentation surface and never touches, reflows, or re-typesets a glyph (E05/`quran` owns the immutable page).

## Acceptance criteria

- [ ] `reduce_motion_substitution.dart` exists under `packages/features/lib/src/a11y/`, carries the REUSE `GPL-3.0-or-later` SPDX header, holds one primary public type (`ReduceMotionSwitcher`), and is re-exported through the `features` barrel; its only imports are `material`/`widgets` and the E06-T07 theme barrel.
- [ ] The widget reads the OS preference **only** through `motionReduced(context)` (E06-T07) — there is **no** other `disableAnimations` reference in this file (verifiable by grep).
- [ ] When `motionReduced(context)` is `true`, the wrapped surface substitutes an **instant cut or cross-fade** with no slide/scale frame; when `false`, the surface's own calm transition renders unchanged; the collapse cannot be overridden per call.
- [ ] No `celebrate`/`emphasized`/`long`/scale/success/reward field, curve, or branch appears in the file; the fallback is always plainer-or-equal to the animated path (no removed delight re-introduced).
- [ ] The substitution is wired into the E07 shell's **calm recite receipt** confirmation transition and the Today **banner reveal** transition; the `pageTurnTransition`/nav transitions (already collapsed by E06-T07) are **not** re-wrapped.
- [ ] Suppressing the visual motion does not suppress the E08-T02 `announce(...)` semantic state change (the announce still fires under `disableAnimations: true` where applicable).
- [ ] Every public member carries a `///` doc; `dart format` and `dart analyze --fatal-infos` clean; no `print`/network/AI path; no user-facing string hardcoded; no CLAIMS id is cited (none applies, recorded in the PR description).

## Tests

`packages/features/test/a11y/reduce_motion_substitution_test.dart` (file mirrors the source), **written FIRST**, `flutter_test` (`testWidgets`), REUSE `GPL-3.0-or-later` SPDX header, run under `flutter test` on the E01 `fast` CI lane with the throwing-`HttpOverrides` offline guard installed from the shared bootstrap. Each surface is pumped under an explicit `MediaQuery` and `Directionality` with E06-T07's `MotionTokens` in `Theme.extensions` — no real DB, no assets, no network, no wall clock. Required cases, written FIRST:

- **Reduce-motion cut — the headline case:** pump `ReduceMotionSwitcher` between two distinguishable children under `MediaQuery(data: MediaQueryData(disableAnimations: true))`; trigger the swap; pump a **single small frame** and assert the outgoing child is gone and the incoming child is fully present with **no intermediate slid/half-opacity frame** — proving the cut path, not a sped-up animation.
- **Animated parity under `disableAnimations: false`:** the same swap renders an in-between (partially-faded) frame at the token mid-duration, confirming the two paths genuinely differ and the calm animated path is intact when motion is allowed.
- **Recite-receipt surface honors the flag:** pump the shell's calm recite-receipt confirmation transition under `disableAnimations: true` and assert the receipt appears at once (no reveal/fade frame); under `false` it animates.
- **Banner reveal surface honors the flag:** pump the Today banner-reveal transition under `disableAnimations: true` and assert the banner appears without a slide/fade frame; under `false` it animates.
- **No removed delight re-introduced:** a guard asserting the substitution emits only a cut/cross-fade — no scale, no overshoot, no celebratory curve — under the flag (the fallback is plainer-or-equal).
- **Announce still fires:** with a fake/recording `SemanticsService` (E08-T02 pattern), assert a wrapped reader-relevant state change still announces its localized message in `TextDirection.rtl` even under `disableAnimations: true` — visual motion suppressed, semantics preserved.
- **Centralized read:** the widget's behaviour tracks the pumped `disableAnimations` value exactly, and the file contains no `disableAnimations` literal (the read is `motionReduced`).
- **Offline guard intact:** the suite makes no network call; the throwing `HttpOverrides` is asserted installed (a stray connection is a loud, named failure, per eng-write-dart-test §8).

CI lanes unchanged: the E01 `fast` lane runs these (no `Date()`, no networking symbols, throwing-`HttpOverrides` green); the per-locale (fa/ckb/ar) reduce-motion golden pass rides E08-T07/E08-T11's appearance×locale golden suite, not this task.

## Definition of Done

- [ ] All acceptance criteria met; the suite is green locally and on the E01 `fast` CI lane; the reduce-motion-cut cases and the two wired-surface cases were written and failing (or documenting an already-plain path as a guarded contract) before the implementation.
- [ ] **Offline / no-network by construction:** no networking import added; the throwing-`HttpOverrides` guard stays installed and green; the file imports only `package:flutter/material.dart`/`widgets.dart` and the E06-T07 theme barrel; the no-network and banned-import gates stay green ([PRD C1, §17](../../docs/PRD.md)).
- [ ] **No AI / no microphone:** no ML/ASR/audio path; this is presentation-only motion plumbing with no recognition surface ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **Quran text fidelity — the glyph layer is untouched:** the substitution swaps only a presentation surface; no muṣḥaf glyph is re-typeset, reflowed, mirrored, or reshaped (the immutable page is E05's; this task is handed a plain child) ([PRD R1](../../docs/PRD.md)).
- [ ] **RTL + fa/ckb/ar localization:** the substitution introduces **no** chrome string of its own; any wrapped surface's labels/announce resolve through E08-T02 + the ARB set so the reader speaks the active locale; the widget is direction-agnostic (an instant cut/cross-fade has no physical-side geometry) and is pumped under `Directionality.rtl` in test ([design-system 09 §7, §8](../../docs/design-system/09-accessibility-and-inclusivity.md)).
- [ ] **Accessibility — reduce-motion honored absolutely:** `MediaQuery.disableAnimations` collapses every wired non-essential surface to an instant cut/cross-fade through the one centralized `motionReduced` helper; the OS flag always wins; nothing animated is information-bearing, so the cut hides no meaning (the SC 2.3.3 "unless essential" carve-out); the §10 reduce-motion pass has a per-surface check behind it ([design-system 09 §9](../../docs/design-system/09-accessibility-and-inclusivity.md); [design-system 06 §5](../../docs/design-system/06-motion-and-haptics.md)).
- [ ] **Sect-neutral adab — no gamification of worship:** the substitution introduces no streak, score, badge, confetti, or celebratory/flashing motion; the fallback is always plainer-or-equal to the calm animation and **never re-introduces a removed delight**; the calm receipt stays calm ([PRD R3, C6](../../docs/PRD.md); domain-adab-and-religious-integrity).
- [ ] **Tests deterministic:** fixed `MediaQuery`/`Directionality`/`MotionTokens` inputs, explicit pumped durations (no `pumpAndSettle` on the substitution), no wall clock, no socket; the suite asserts behaviour (no-frame under the flag, parity without it, announce preserved), never a coverage percentage; no `matchesGoldenFile` master added; REUSE SPDX header and full-word names on every file ([engineering 12 §8](../../docs/engineering/12-localization-rtl-accessibility-impl.md); eng-write-dart-test §10).
- [ ] The substitution reads the OS flag through exactly one helper (E06-T07's `motionReduced`); the PR notes that no CLAIMS id applies.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
