# 06 — Motion & Haptics

This file owns the **`motion.*`** and **`haptic.*`** token families: every duration, easing curve, transition pattern, and tactile pulse the app is allowed to use. Its governing intent is Pillar 2 — *calm, not cute* ([README](README.md)): motion here is **informative, never celebratory**. It exists to make a state change legible — a page turning, a panel opening, a grade registering — and then to get out of the way, never to delight, reward, or congratulate. It builds directly on the motion ladder fixed in [02-material-and-platform-foundations.md](02-material-and-platform-foundations.md) (which adopts only the short/medium rungs of M3's `Durations` and deliberately *restrains* Material 3 Expressive's spring physics), inherits the spatial direction of page-turns from [05-layout-spacing-touch.md](05-layout-spacing-touch.md), serves the reduce-motion and vestibular-safety requirements enforced in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md), and is bound by the anti-gamification refusal argued in the dossier [`research/calm-non-gamified-design.md`](research/calm-non-gamified-design.md) and forbidden by [PRD R3/C6](../PRD.md). It sets no color (see [03-color-and-themes.md](03-color-and-themes.md)) and no spacing (see [05-layout-spacing-touch.md](05-layout-spacing-touch.md)); it sets only *time, curve, and touch*. The single hardest rule in this file is that there is **no confetti** — no fanfare, no celebratory animation tier, no haptic "success burst" — anywhere in the app, because the muṣḥaf is not a game and a daily act of worship should lower arousal, not spike it.

## At a glance

| Concern | Decision | Token / value | Owner |
|---|---|---|---|
| Duration rungs allowed | short/medium only; never long/extra-long for routine UI | `motion.duration.short`=150ms, `.medium`=250ms | this file |
| Standard easing | M3 standard / `Curves.fastOutSlowIn` | `motion.curve.standard` | this file |
| Emphasized easing | reserved for at most one hero (page → recite) | `motion.curve.emphasized` | this file |
| Spring / overshoot motion | **refused** (M3 Expressive not adopted) | — | this file + [02](02-material-and-platform-foundations.md) |
| Celebratory motion (confetti, fanfare) | **does not exist** | — (no token) | this file + [PRD R3](../PRD.md) |
| Page-turn direction | start→end in RTL (right-to-left advance) | `motion.transition.pageTurn` | this file + [05](05-layout-spacing-touch.md) |
| Reduce-motion behavior | cross-fade or instant-cut; the OS flag always wins | `MediaQuery.disableAnimations` | this file + [09](09-accessibility-and-inclusivity.md) |
| Haptic vocabulary | three light, meaning-bearing pulses only | `haptic.selection`, `haptic.confirm`, `haptic.warning` | this file |
| Haptic on success/reward | **refused** | — (no token) | this file |

---

## 1. Motion is calm and informative: the short/medium ladder, standard easing

**Statement.** Every animation in the app uses M3's **standard easing** at the **short or medium** rung of the duration ladder. Motion communicates a state change (a page advancing, a sheet opening, a grade landing) at a low-arousal speed and then stops. We do not adopt Material 3 Expressive's spring/overshoot physics, we do not chain animations into a "delightful" sequence, and we reserve `emphasized` easing and a single `long` duration for at most one hero transition.

**Evidence.**
- M3 motion is a token system of named **easing** tokens (`standard` for routine UI; `emphasized`, which "draws extra attention at the end of an animation and is usually paired with longer durations," for hero/expanding transitions) plus a duration ladder ([Material 3: Easing & duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs)).
- Flutter exposes the ladder as **`Durations`**: short1–4 = 50/100/150/200ms, medium1–4 = 250/300/350/400ms, long1–4 = 450/500/550/600ms, extralong1–4 = 700/800/900/1000ms ([Flutter: Durations class](https://api.flutter.dev/flutter/material/Durations-class.html)). Short rungs suit small selection/state changes; medium suits component transitions; long/extra-long are full-screen and ambient motion.
- The legacy M2 standard easing is `Curves.fastOutSlowIn`; the emphasized curve is a three-point cubic that overshoots-then-settles (`Curves.easeInOutCubicEmphasized` = `ThreePointCubic(…)`) ([Flutter: ThreePointCubic](https://api.flutter.dev/flutter/animation/ThreePointCubic-class.html); [Flutter animation/curves.dart source](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/animation/curves.dart)).
- Newer **Material 3 Expressive** motion replaces fixed easing/duration with a **spring** model (stiffness + damping), "replacing the duration-based animation system with a new engine grounded in physics" — a bouncier register a reverent app should avoid ([Material 3: Motion overview](https://m3.material.io/styles/motion/overview/how-it-works)).
- Calm design lowers arousal, and emotional arousal is driven by saturation/brightness and motion *energy*, not by hue — so quiet, brief, non-bouncing motion is the low-arousal choice the central pillar demands ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)).
- The measurement-and-restraint ethic behind this is calm technology: "the right amount of technology is the minimum needed to solve the problem," and technology should "require the smallest possible amount of attention" ([Case, *Calm Technology*, 2015](https://calmtech.com/); [Weiser & Brown, 1995](https://calmtech.com/papers/designing-calm-technology.html)).

**In practice.**

| Token | Value (maps to) | Used for |
|---|---|---|
| `motion.duration.short` | 150ms (`Durations.short3`) | reveal-on-tap line reveal, grade-button press feedback, chip state |
| `motion.duration.medium` | 250ms (`Durations.medium1`) | sheet/panel open, list reflow, tab/section change |
| `motion.curve.standard` | `Curves.fastOutSlowIn` / `Easing.standard` | all routine transitions |
| `motion.curve.emphasized` | `Curves.easeInOutCubicEmphasized` | the single page→recite hero only |
| `motion.transition.pageTurn` | medium + standard, directional | muṣḥaf reader page advance (see §3) |

- All `motion.*` values live in one typed `ThemeExtension` (the token-discipline pattern the README assigns to this file and that [05](05-layout-spacing-touch.md) uses for `space.*`), read as `Theme.of(context).extension<MotionTokens>()!.durationMedium`, so a motion retune is a one-file edit and interpolates correctly across theme changes ([Flutter: ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)).
- The **recite/grade flow** ([07-components.md](07-components.md)) is where motion earns its keep: a reveal-on-tap line fades in at `motion.duration.short` with `motion.curve.standard`; the grade registers with the same brief fade to the next item — legible, never animated *at* the user. The grade landing is acknowledged by copy and a quiet state change, never by a celebratory flourish (§5, §6).
- The page→recite transition is the one place `motion.curve.emphasized` with a single `long` duration is permitted, used sparingly to mark the shift from "today's list" into the focused recitation surface — a navigational hero, not a reward.
- RTL/locale: motion timing and easing are direction- and language-agnostic — fa, ckb, and ar share identical `motion.*` values; only *direction* differs (§3). A longer ckb transcreated label reflowing into place uses the same `motion.duration.medium`, so the calm rhythm is identical across all three locales.

**Anti-patterns — we will never:**
- Adopt M3 Expressive spring/overshoot physics, bouncy easing, or any "delightful" motion register on a worship surface ([Material 3: Motion overview](https://m3.material.io/styles/motion/overview/how-it-works); [PRD R3](../PRD.md)).
- Use `long`/`extralong` durations for routine UI, or chain multiple animations into a sequence that holds the user's attention longer than the state change requires ([Case, 2015](https://calmtech.com/)).
- Hardcode a raw `Duration(milliseconds: 220)` or a bespoke `Curve` in a widget; every animation resolves to a `motion.*` token.

---

## 2. Motion never celebrates: no confetti, no fanfare, no reward animation

**Statement.** There is **no celebratory motion anywhere in the app** — no confetti, no fireworks, no bouncing trophy, no pulsing "well done," no animated streak flame. Completing a juz, finishing a khatm, signing off a page, or clearing the day's queue is acknowledged with calm, factual copy and a quiet state change, never with an animation that rewards. This is the single non-negotiable rule of this file. Celebratory motion is not a token we restrained; it is a tier that **does not exist**.

**Evidence.**
- Tangible, expected, performance-contingent rewards reliably *undermine* the intrinsic motivation behind an activity people already value — the overjustification effect, established across 128 controlled experiments — so converting "I revise because it is the Quran" into "I revise for the celebration" is a measurable risk, not a stylistic one ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)).
- *Framing* an activity as a game — even with no underlying mechanics — changes the psychological relationship to it almost as much as full game mechanics do, so cartoon celebration risks trivialising a sacred act independent of any scoring ([Lieberoth, 2015](https://doi.org/10.1177/1555412014559978)).
- Only *informational* feedback preserves intrinsic motivation; feedback experienced as *controlling* (a reward animation that pressures you to keep performing) shifts the locus of causality outward and reduces autonomy ([Cognitive Evaluation Theory overview](https://en.wikipedia.org/wiki/Cognitive_evaluation_theory); [Ryan & Deci, 2000](https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf)).
- The product constraints make this explicit: "no confetti on completing a juz," and progress is a calm, non-shaming surface — never a prize ([PRD R3, C6](../PRD.md)); the calm-design dossier caps celebratory motion at "absent" ([`research/calm-non-gamified-design.md`](research/calm-non-gamified-design.md) §6).

**In practice.**
- There is **no `motion.celebrate.*` token, no confetti widget, and no "success" animation tier.** Reaching a milestone is handled by copy owned by [11-voice-and-tone.md](11-voice-and-tone.md) ("This juz is now in long-cycle revision"), shown with `motion.duration.short` fade — factual acknowledgement, not fanfare ([`research/calm-non-gamified-design.md`](research/calm-non-gamified-design.md) implication 2).
- Clearing the day's queue ends the session; the app does not animate a reward and does not invent a reason to keep the user inside it — the daily session is short, finite, and then *done* ([PRD §12.2](../PRD.md)).
- A teacher sign-off ([PRD §8.2](../PRD.md)) registers with the quiet `haptic.confirm` pulse (§4) and a state change, never a celebratory burst — the *sanad* moment is dignified, not gamified.
- RTL/locale: because there is no celebratory motion at all, there is nothing to mirror or transcreate here for fa/ckb/ar — the refusal is uniform across every locale and every surface.

**Anti-patterns — we will never:**
- Fire confetti, fireworks, fanfare, a bouncing trophy, or any celebratory animation on completing a juz, a khatm, a session, or a sign-off ([PRD R3](../PRD.md); [Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)).
- Animate a streak flame, a level-up, a progress "fill" that congratulates, or any reward surface — none exist ([`research/calm-non-gamified-design.md`](research/calm-non-gamified-design.md)).
- Add a floating action button or hero animation whose purpose is to celebrate rather than to navigate ([05-layout-spacing-touch.md](05-layout-spacing-touch.md) §5).

---

## 3. Page-turns and directional motion read right-to-left

**Statement.** Motion that has a *direction* — the muṣḥaf reader's page advance, a forward/back navigation transition, a shared-axis slide — runs **start→end in RTL**, i.e. the page advances right-to-left, the way fa/ckb/ar (and the Quran) read. Direction is a logical property, never hardcoded left/right, so the same transition serves all three locales correctly without a separate code path.

**Evidence.**
- Material 3's bidirectionality contract is that on LTR↔RTL mirroring, directional components and reading flow "switch sides, with the same specifications for spacing and height as LTR" — mirror the *direction*, keep the *metrics* ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).
- Legibility and natural scanning are governed by familiarity — readers "read best what they read most" — so directional motion must follow the script's native reading geometry, not a flipped Latin one, for these readers to follow it without friction ([Nedeljković et al., 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/)).
- The reader advances pages in RTL order, and the bottom-nav "home" sits at the trailing/rightmost edge — the app's spatial language is RTL by construction ([PRD §12](../PRD.md); [05-layout-spacing-touch.md](05-layout-spacing-touch.md) §3).

**In practice.**
- `motion.transition.pageTurn` is a directional slide at `motion.duration.medium` with `motion.curve.standard`; in the RTL muṣḥaf reader the next page enters from the start (right) edge and the current page exits toward the end (left), matching a physical muṣḥaf's right-to-left page progression ([PRD §11, §12.3](../PRD.md)). The immutable glyph page itself is never re-typeset to animate — only the page *surface* slides (Pillar 1; [PRD R1](../PRD.md)).
- Forward/back navigation between screens uses an M3 shared-axis transition that respects `Directionality`, so the same transition slides the correct way in fa, ckb, and ar with no per-locale branching.
- Icons that imply direction (next/previous chevrons) mirror with the layout; icons whose meaning is absolute (an audio play triangle, a logo) do **not** mirror ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl); [05-layout-spacing-touch.md](05-layout-spacing-touch.md) §3).

**Anti-patterns — we will never:**
- Hardcode a left-to-right page-turn or a physical-direction slide; directional motion derives from `Directionality` and reads start→end ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).
- Animate the muṣḥaf by reflowing or re-typesetting its glyph layer; only the page *surface* moves, never the sacred text ([PRD R1, §11.2](../PRD.md)).
- Ship an "RTL animation mode" bolted onto an LTR-first set of transitions; RTL is the default and only direction.

---

## 4. The haptic vocabulary is tiny, light, and meaning-bearing

**Statement.** The app uses **exactly three** haptic pulses, all light, each tied to a specific *meaning*: `haptic.selection` (a discrete choice was made), `haptic.confirm` (an action was committed), and `haptic.warning` (a gentle caution). Haptics complement an on-screen change; they never fire on their own, never repeat, and never escalate. There is no "success" or "reward" haptic — the tactile channel obeys the same no-celebration rule as motion.

**Evidence.**
- Flutter exposes platform haptics through `HapticFeedback`: `selectionClick()` ("haptic feedback indicating selection changing through discrete values"), `lightImpact()`/`mediumImpact()`/`heavyImpact()` (collision impacts of light/medium/heavy mass), and `vibrate()` (a short vibration) ([Flutter: HapticFeedback class](https://api.flutter.dev/flutter/services/HapticFeedback-class.html)).
- Apple's guidance is to use haptics to *complement* other feedback — "when visual, auditory, and tactile feedback are in harmony, the user experience is more coherent" — and to **match the intensity and sharpness of a haptic to the animation it accompanies** ([Apple HIG: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)).
- Apple also warns explicitly against overuse: a haptic "can feel just right when it happens occasionally, but become tiresome when it plays frequently," and haptics should be applied *consistently* so each conveys a stable meaning ([Apple HIG: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)).
- Haptics are a feedback channel, and overusing any feedback channel competes for the user's scarce calm; the calm-technology ethic of "the minimum needed to solve the problem" applies to touch exactly as to motion ([Case, *Calm Technology*, 2015](https://calmtech.com/)).

**In practice.**

| Token | Maps to | Fires when | Example |
|---|---|---|---|
| `haptic.selection` | `HapticFeedback.selectionClick()` | a discrete, reversible choice is made | tapping a stumble-line during reveal-on-tap; switching a track chip |
| `haptic.confirm` | `HapticFeedback.lightImpact()` | an action is committed | a grade is recorded; a teacher sign-off lands |
| `haptic.warning` | `HapticFeedback.lightImpact()` (paired with a warning state) | a gentle caution | the day's chosen scope cannot fit the time budget ([PRD §12.2](../PRD.md)) |

- Each haptic *always* accompanies an on-screen change at `motion.duration.short`, matching Apple's intensity-to-animation rule: light pulses for light visual changes, nothing heavier ([Apple HIG: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)).
- Haptics are **opt-out** and honour the OS system-haptics setting; when the platform reports haptics disabled, the visual state change alone carries the meaning. They never repeat or buzz to nag.
- RTL/locale: haptics carry no language or direction, so `haptic.*` is identical across fa, ckb, and ar — the tactile vocabulary a user learns transfers unchanged between locales.

**Anti-patterns — we will never:**
- Add a "success," "reward," or "celebration" haptic, or a `heavyImpact`/long `vibrate` burst on completing anything — the no-celebration rule (§2) governs touch as well as motion ([Apple HIG: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics); [PRD R3](../PRD.md)).
- Fire a haptic with no accompanying visual change, repeat a pulse, or escalate intensity to pressure the user ([Apple HIG: Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)).
- Use a haptic to manufacture urgency or guilt (a buzz for a missed day); cautions are gentle, single, and informational only ([`research/calm-non-gamified-design.md`](research/calm-non-gamified-design.md) §5).

---

## 5. Reduce-motion is honoured absolutely: the OS flag always wins

**Statement.** When the operating system requests reduced or disabled animation, the app **obeys without exception**: directional and component motion become a cross-fade or an instant cut, the page→recite hero collapses to a plain transition, and no animation is allowed to play "because it's subtle." Motion is never essential to conveying information in this app — every state it animates is also stated in text or layout — so reduce-motion costs the user nothing.

**Evidence.**
- Flutter surfaces the platform preference as `MediaQueryData.disableAnimations` — "whether the platform is requesting that animations be disabled or reduced as much as possible," sourced from the OS accessibility features ([Flutter: MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)).
- Both platforms expose this preference: iOS has *Reduce Motion*, and Android 13+ has *Remove Animations*, which "removes system animations as you move around the operating system" — beneficial for those sensitive to visual effects, with the animation-duration scale reading 0 when enabled ([Android Developers: motion & accessibility](https://developer.android.com/codelabs/material-motion-android); the `transitionAnimationScale`/`TRANSITION_ANIMATION_SCALE` system setting).
- WCAG 2.2 SC 2.3.3 *Animation from Interactions* (AAA) requires that "motion animation triggered by interaction can be disabled, unless the animation is essential," because "some users experience distraction or nausea from animated content" and "vestibular (inner ear) disorder reactions include dizziness, nausea and headaches" ([W3C: Understanding SC 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)).

**In practice.**
- Every animated transition reads `MediaQuery.of(context).disableAnimations` (centralised in a small helper) and, when true, substitutes a cross-fade or an instant cut: `motion.transition.pageTurn` becomes a fade or cut, the page→recite `motion.curve.emphasized` hero becomes a plain push, and reveal-on-tap appears without a fade ([Flutter: MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html); detailed in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).
- Because nothing the app animates is *information-bearing* — the heat-map, grades, due state, and decay are all conveyed in text/layout, not in motion ([08-data-visualization.md](08-data-visualization.md)) — disabling motion never hides meaning, satisfying the "unless essential" carve-out of SC 2.3.3.
- Haptics are independent of the visual reduce-motion flag and follow the OS *system-haptics* setting instead (§4), so a user can keep tactile confirmation while removing on-screen motion.
- This is verified in the accessibility release checklist: RTL golden screenshots and a reduce-motion pass per locale (fa/ckb/ar) confirm every screen is fully usable with animation off ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md); [PRD §18, §20](../PRD.md)).

**Anti-patterns — we will never:**
- Play an animation through a reduce-motion request, however "subtle" — the OS flag always wins ([W3C: SC 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)).
- Encode information *only* in motion such that disabling animation hides meaning; every animated state is also stated in text or layout ([08-data-visualization.md](08-data-visualization.md)).
- Treat reduce-motion as a degraded experience to apologise for; it is a first-class, fully-functional path tested per locale ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

---

## References

- Apple. *Human Interface Guidelines — Playing haptics* (complement other feedback; match haptic intensity/sharpness to the animation; avoid overuse — "tiresome when it plays frequently"; apply consistently). https://developer.apple.com/design/human-interface-guidelines/playing-haptics
- Android Developers. *Building Beautiful Transitions with Material Motion for Android* / motion & reduced-motion (Android 13 *Remove Animations*; `transitionAnimationScale` / `TRANSITION_ANIMATION_SCALE`; duration scale = 0 when reduced). https://developer.android.com/codelabs/material-motion-android
- Case, A. (2015). *Calm Technology: Principles and Patterns for Non-Intrusive Design.* O'Reilly Media. (Smallest possible attention; the minimum technology needed to solve the problem.) https://calmtech.com/
- Cognitive Evaluation Theory (sub-theory of Self-Determination Theory) — controlling vs. informational aspect of feedback/rewards. https://en.wikipedia.org/wiki/Cognitive_evaluation_theory
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation. *Psychological Bulletin*, 125(6), 627–668. https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- Flutter API. *Durations class* (short/medium/long/extra-long millisecond values). https://api.flutter.dev/flutter/material/Durations-class.html
- Flutter API. *HapticFeedback class* (`selectionClick`, `lightImpact`, `mediumImpact`, `heavyImpact`, `vibrate`). https://api.flutter.dev/flutter/services/HapticFeedback-class.html
- Flutter API. *MediaQueryData.disableAnimations* — "whether the platform is requesting that animations be disabled or reduced as much as possible." https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html
- Flutter API. *ThemeExtension class* (typed motion tokens; `copyWith`/`lerp`; one source of truth). https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Flutter API. *ThreePointCubic class* (the emphasized three-point cubic curve). https://api.flutter.dev/flutter/animation/ThreePointCubic-class.html
- Flutter (source). *animation/curves.dart* (legacy `fastOutSlowIn` standard easing; M3 `Easing` replacements). https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/animation/curves.dart
- Lieberoth, A. (2015). Shallow Gamification: Testing Psychological Effects of Framing an Activity as a Game. *Games and Culture*, 10(3), 229–248. https://doi.org/10.1177/1555412014559978
- Material Design 3. *Bidirectionality & RTL* (mirror direction, keep metrics; directional components switch sides). https://m3.material.io/foundations/layout/bidirectionality-rtl
- Material Design 3. *Easing and duration: tokens & specs* (standard/emphasized easing; the duration ladder). https://m3.material.io/styles/motion/easing-and-duration/tokens-specs
- Material Design 3. *Motion overview / how it works* (Expressive spring motion engine). https://m3.material.io/styles/motion/overview/how-it-works
- Nedeljković, U., Jovančić, K., & Pušnik, N. (2020). You read best what you read most: An eye tracking study. *Journal of Eye Movement Research*, 13(2). https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/
- Ryan, R. M., & Deci, E. L. (2000). Self-Determination Theory and the Facilitation of Intrinsic Motivation, Social Development, and Well-Being. *American Psychologist*, 55(1), 68–78. https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf
- Valdez, P., & Mehrabian, A. (1994). Effects of color on emotions. *Journal of Experimental Psychology: General*, 123(4), 394–409. (Arousal driven by saturation/brightness and motion energy, not hue.) https://psycnet.apa.org/record/1995-08699-001
- Weiser, M., & Brown, J. S. (1995/1996). *Designing Calm Technology.* Xerox PARC. https://calmtech.com/papers/designing-calm-technology.html
- W3C (2023, updated 2024). *Understanding WCAG 2.2 — SC 2.3.3 Animation from Interactions* (motion triggered by interaction can be disabled unless essential; vestibular reactions: dizziness, nausea, headaches). https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html
