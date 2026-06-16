# 09 — Accessibility & Inclusivity

This file sets Mihrab's accessibility contract: the conformance target, what we promise screen-reader users, how text scaling and low-vision reading work, how every signal survives the loss of color, how RTL is made accessible (not just visible), and the release checklist that gates a build. It owns no design tokens — it *constrains* them: it sets the contrast floor that [03-color-and-themes.md](03-color-and-themes.md) must clear in every theme, the 48dp touch floor that [05-layout-spacing-touch.md](05-layout-spacing-touch.md) implements, the color-independence rule that [08-data-visualization.md](08-data-visualization.md) bakes into the retention heat-map, and the localized semantic labels that [11-voice-and-tone.md](11-voice-and-tone.md) and [12-localization-and-rtl.md](12-localization-and-rtl.md) author and direction. The driving fact is in the dossier ([research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md)): our users recite daily, often quickly, in three RTL scripts, and many are older huffaz with presbyopia or reduced color vision. Accessibility here is *adab* toward the user and toward the muṣḥaf — *iḥsān* is the standard because the work is *lillāh* ([blueprint §5](../_DOC-SET-BLUEPRINT.md)) — and most of it is testable. The locked constraints (offline, no accounts, no telemetry, no AI/audio) are in [`../PRD.md`](../PRD.md); §18 of the PRD is the requirement this file makes precise and citable.

## At a glance

| Concern | Target | Where it lives |
|---|---|---|
| Conformance baseline | **WCAG 2.2 Level AA** (a superset of 2.1) | this file §1 |
| Text contrast | ≥ **4.5:1** (≥ 3:1 large text), all themes | floor here §3 · values in [03](03-color-and-themes.md) |
| Non-text contrast | ≥ **3:1** for heat-map cells, decay marks, control states | floor here §3 · values in [03](03-color-and-themes.md)/[08](08-data-visualization.md) |
| Color-independence | meaning **never** by hue alone (SC 1.4.1) | floor here §4 · applied in [08](08-data-visualization.md) |
| Text scaling | honor OS scale via `TextScaler`, verify to **200%+** | this file §5 |
| Quran legibility | dedicated in-app **zoom**, glyph fonts never OS-scaled | this file §5 · [04](04-typography.md), [PRD §11](../PRD.md) |
| Touch target | ≥ **48×48dp** (Android) / **44×44pt** (iOS) | floor here §6 · built in [05](05-layout-spacing-touch.md) |
| Screen readers | every control a **localized** semantic label, fa/ckb/ar | this file §7 |
| RTL accessibility | focus/reading order = visual order; mirror only directional icons | this file §8 · [12](12-localization-and-rtl.md) |
| Architectural wins | no auth, no mic, no motion-triggers | this file §9 |
| Release gate | automated `meetsGuideline` + manual TalkBack/VoiceOver in-language | this file §10 |

---

## 1. WCAG 2.2 Level AA is the conformance baseline, and we claim 2.2, not 2.1

**Statement.** Mihrab targets **WCAG 2.2 Level AA**, documented as the explicit conformance bar, with the native platform equivalents (Material 3, Apple HIG) applied where mobile differs from the web. We claim 2.2 specifically — not 2.1 — because 2.2 is a strict superset, so the claim is honest and free of regression.

**Evidence.**
- WCAG 2.2 is the current W3C Recommendation (5 October 2023) and is **backwards compatible**: "Content that conforms to WCAG 2.2 also conforms to WCAG 2.0 and WCAG 2.1," and it adds nine new success criteria over 2.1 while keeping every 2.1 requirement ([W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/)).
- The nine additions, with levels, are 2.4.11 / 2.4.12 / 2.4.13 (focus), 2.5.7 Dragging Movements (AA), **2.5.8 Target Size (Minimum) (AA)**, 3.2.6 Consistent Help (A), **3.3.7 Redundant Entry (A)**, **3.3.8 Accessible Authentication (Minimum) (AA)**, and 3.3.9 (AAA) ([W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/); [Vispero: New SC in WCAG 2.2](https://vispero.com/resources/new-success-criteria-in-wcag22/)).
- Native mobile apps are not literally "web content," but WCAG is the de-facto and legally-referenced bar for mobile accessibility, and Flutter publishes its accessibility expectations against the same criteria — contrast, scaling, target size, and screen-reader labelling ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility)).

**In practice.**
- The conformance claim is stated in the [README](README.md) and made measurable in this file: contrast floors (§3), color-independence (§4), text resize (§5), target size (§6), screen-reader labelling (§7), and RTL order (§8) are each a named, gated requirement (§10), not an aspiration.
- The criteria most load-bearing for a touch-first, text-dense RTL reading app are 1.4.1 Use of Color (A), 1.4.3 Contrast Minimum (AA), 1.4.4 Resize Text (AA), 1.4.10 Reflow (AA), 1.4.11 Non-text Contrast (AA), 2.5.8 Target Size (AA), and the 1.3.x / 4.1.2 name-role-value criteria that the Semantics tree satisfies (§7).
- The conformance target is identical across fa, ckb, and ar; nothing about Arabic-script density or RTL relaxes any criterion — RTL only changes *how* a criterion is satisfied (§8), never *whether*.

**Anti-patterns — we will never:**
- Claim "accessible" without naming the standard and level — the claim is "WCAG 2.2 AA," auditable against this file's checklist.
- Treat accessibility as a post-launch backlog; the §10 gates are release-blocking alongside the muṣḥaf-integrity gates ([PRD §20](../PRD.md)).
- Lower the bar for a locale because its layout is "harder"; the standard is script-independent.

---

## 2. The architecture already exempts us from two of the nine new criteria

**Statement.** Two of WCAG 2.2's new success criteria — 3.3.7 Redundant Entry and 3.3.8 Accessible Authentication (Minimum) — are satisfied *by construction*, because the app has no account, no login, and no data re-entry. We state this plainly so reviewers see the floor we start from rather than re-deriving it.

**Evidence.**
- 3.3.7 Redundant Entry and 3.3.8 Accessible Authentication both concern logging in and re-entering previously-supplied information; they exist to remove cognitive-function tests (remembering passwords, transcribing codes, solving CAPTCHAs) from authentication flows ([W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/); [Vispero: New SC in WCAG 2.2](https://vispero.com/resources/new-success-criteria-in-wcag22/)).
- Hifz Companion has **no account and no authentication at all** — a profile is just a display name the user types ([PRD §17](../PRD.md)) — so there is no cognitive-function test to fail and no data the user must re-enter to proceed.

**In practice.**
- Onboarding asks for a name and a few hifz self-assessment taps ([PRD §7.10, §12.1](../PRD.md)); none of it is an authentication challenge, and a profile switch (teacher/halaqa mode) is a tap, never a credential.
- The privacy framing that earns trust ([10-privacy-and-trust-ux.md](10-privacy-and-trust-ux.md)) and this accessibility win share one root cause — *no server, no account* — so the same architectural decision pays in two registers at once.
- This holds equally in fa/ckb/ar: there is no locale where a login, OTP, or CAPTCHA appears, so no locale inherits an authentication barrier.

**Anti-patterns — we will never:**
- Add an account, PIN-lock, or cloud-sync login that would re-introduce 3.3.7/3.3.8 obligations and a cognitive-load barrier ([PRD C1, §17](../PRD.md)).
- Gate any feature behind a code the user must transcribe or a memory test.

---

## 3. Contrast floors are precise numbers, enforced in tokens, in every theme

**Statement.** Text meets a **4.5:1** contrast floor (relaxing to **3:1** only for large text); non-text graphical objects — heat-map cells, decay indicators, chart strokes, and the states of interactive controls — meet **3:1**. These floors are enforced where the values live, in the `color.*` tokens ([03-color-and-themes.md](03-color-and-themes.md)), and re-audited in **every** appearance (Light, Sepia, Dark, Night).

**Evidence.**
- SC 1.4.3 Contrast (Minimum) requires text contrast of at least **4.5:1**, relaxing to **3:1 for large-scale text** — 18pt, or 14pt bold — with exceptions only for logos, inactive components, pure decoration, and invisible text (AA) ([W3C: Contrast Minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)).
- SC 1.4.11 Non-text Contrast requires **3:1** for the visual information needed to identify UI components and states, and for parts of graphics required to understand content — which is exactly the heat-map cells, decay glyphs, and chart strokes ([W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/); [accessibilityassistant.com: WCAG 2.2 contrast](https://accessibilityassistant.com/blog/accessibility-insights/how-to-apply-wcag-22-colour-contrast-accessibility/)).
- Material 3 restates the same numbers for native UI: a **minimum 3:1** for UI component containers alongside the **4.5:1 / 3:1** text floors ([Material 3: Accessibility — designing for structure](https://m3.material.io/foundations/designing/structure)).

**In practice.**
- The floor lives here; the audited values live in [03-color-and-themes.md](03-color-and-themes.md), which re-runs a measured contrast audit per appearance — `color.text.primary` on `color.bg.primary` ≥ 4.5:1, and `color.heatmap.strong` … `color.heatmap.faded` and `color.semantic.warning` ≥ 3:1 against their backgrounds.
- The **Sepia** appearance is audited with extra suspicion: its soft earth tones are the documented place where a calm, low-saturation palette quietly drops below 4.5:1 ([research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md)). A token that fails sepia is fixed in [03](03-color-and-themes.md), never waived.
- Contrast is script-independent, so one audit covers fa/ckb/ar; what changes per locale is string length, not the foreground/background pair — Arabic-script glyphs sit on the same audited surfaces.
- The CI gate is Flutter's `meetsGuideline(textContrastGuideline)` over golden screens in all four appearances (§10).

**Anti-patterns — we will never:**
- Ship a theme where any token pair fails its floor "because it looks calmer"; calm is achieved by lowering saturation within the floor, not by dropping below it ([03-color-and-themes.md](03-color-and-themes.md)).
- Encode the heat-map's weakest, most important signal in a low-contrast cell — the decaying juz must be *more* legible, not less ([08-data-visualization.md](08-data-visualization.md)).
- Rely on a single ad-hoc spot-check; contrast is re-audited per appearance and gated in CI.

---

## 4. Color-independence is a hard requirement for the heat-map, not a nicety

**Statement.** Color is never the *only* visual means of conveying information, indicating a state, or distinguishing an element. The retention heat-map — the emotional heart of the app — therefore carries its meaning in at least two non-color channels as well as hue, so a user who cannot perceive the color still reads it perfectly.

**Evidence.**
- SC 1.4.1 Use of Color (Level A): "Color is not used as the only visual means of conveying information, indicating an action, prompting a response, or distinguishing a visual element." Its intent is explicit — "some users have difficulty perceiving color… many older users do not see color well" ([W3C: Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)).
- The population is significant: red-green color-vision deficiency affects roughly **8% of men (and ~0.5% of women)** of Northern-European descent, with ~95% of deficiencies being red-green ([News-Medical: Color Blindness Prevalence](https://www.news-medical.net/health/Color-Blindness-Prevalence.aspx); [Birch, 2012](https://www.researchgate.net/publication/223985289_Worldwide_prevalence_of_red-green_color_deficiency)). A red→green "weak vs strong page" ramp is the classic 1.4.1 failure — a deuteranope cannot tell a decaying juz from a solid one.
- The honest encoding is a **sequential single-hue lightness ramp**, not a rainbow/jet map; the rainbow colormap introduces false boundaries and is "still considered harmful," so a lightness-ordered single hue is what survives grayscale ([Borland & Taylor, 2007](https://doi.org/10.1109/MCG.2007.323435)).

**In practice.**
- The heat-map ([08-data-visualization.md](08-data-visualization.md)) is a **single-hue green→neutral lightness ramp** (`color.heatmap.strong` … `color.heatmap.faded`), never red↔green, so the signal lives in **lightness** — a channel that survives grayscale and deuteranope simulation — not in hue alone.
- Each cell is **redundantly encoded** three ways: the lightness ramp, a numeric retention % on tap, and the text-based weakest-pages list ([PRD §12.5](../PRD.md)) as a fully non-visual equivalent. A screen-reader user reaches the same facts through the list and per-cell labels (§7) without ever seeing a color.
- Decay is shown as green *receding* to a muted neutral, never an alarming red scoreboard ([03-color-and-themes.md](03-color-and-themes.md), [08-data-visualization.md](08-data-visualization.md)) — honest about decay (Pillar 4) without weaponizing color, and color-independent by the same stroke.
- This is identical in fa/ckb/ar; the numeric retention % renders in the locale digit set (§8), and the weakest-pages list is transcreated per locale ([11-voice-and-tone.md](11-voice-and-tone.md)).

**Anti-patterns — we will never:**
- Signal "weak" vs "strong" by a red/green pair, or by any hue contrast alone — the lightness ramp plus a number plus a list always co-carry the meaning ([PRD §18](../PRD.md)).
- Use color as the sole indicator of a track chip, a due state, or a sign-off state; each pairs color with an icon and a label.
- Ship a heat-map without verifying it in a grayscale / deuteranope simulation (§10).

---

## 5. Two scaling systems, kept deliberately separate: OS text scale for chrome, in-app zoom for the muṣḥaf

**Statement.** All UI chrome — track chips, dates, buttons, settings, the today list — honors the operating system's text-size setting and remains legible and usable to **200% and beyond**. The Quran text is the explicit exception: it is rendered from fixed per-page glyph fonts and is **never** OS-scaled; its legibility is served by a dedicated in-app **zoom** control. The two systems never blur into one.

**Evidence.**
- SC 1.4.4 Resize Text (AA) requires text to resize to **200% without loss of content or functionality**, and SC 1.4.10 Reflow (AA) requires content to reflow without two-dimensional scrolling ([W3C: Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html); [W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/)). Both platforms expose system scaling — iOS Dynamic Type (including five extra "AX" sizes) and Android font scale ([Dept: iOS Dynamic Type](https://engineering.deptagency.com/ios-accessibility-part-1-dynamic-type); [A11Y Project: Text resizing in iOS and Android](https://www.a11yproject.com/posts/text-resizing-in-ios-and-android/)).
- Flutter reads scale via `MediaQuery.textScalerOf(context)` and applies it automatically to `Text`/`RichText`; the modern API is **`TextScaler`**, which replaced the deprecated `textScaleFactor` to support Android 14's **non-linear** font scaling (already-large text scales at a lesser rate so it doesn't blow up) ([Flutter: Deprecate textScaleFactor](https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor); [Flutter: Android 14 non-linear text scaling](https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration)). Where a dense layout truly needs a ceiling, the correct tool is **`MediaQuery.withClampedTextScaling`**, *not* hard-coded sizes or disabled scaling — disabling scaling is itself an accessibility failure ([Flutter: withClampedTextScaling](https://api.flutter.dev/flutter/widgets/MediaQuery/withClampedTextScaling.html)).
- The muṣḥaf is rendered from fixed KFGQPC per-page glyph fonts and is never re-typeset for any visual goal — a single dropped diacritic ends the project ([PRD R1, §11](../PRD.md); [QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)) — so OS text-scaling cannot be applied to it without breaking the sacred-text contract; a zoom transform of the rendered layer is the only correct enlargement.

**In practice.**
- All `type.*` styles ([04-typography.md](04-typography.md)) flow through Flutter's automatic `TextScaler` path; we never read or hard-code a raw font size that would defeat the OS setting. `MediaQuery.withClampedTextScaling` is used *only* where a genuinely dense row would clip, and even then it sets a ceiling rather than disabling scale.
- The **muṣḥaf reader** ([PRD §11.2, §12.3](../PRD.md)) has its own zoom (and night/sepia) control that transforms the *rendered glyph layer*, leaving line and page breaks from the bundled layout untouched. A low-vision ḥāfiẓ enlarges the page without OS scaling ever touching a glyph.
- Every screen is tested at 200% (and the iOS AX sizes) for no clipped buttons, no truncated labels, and no horizontal scroll (SC 1.4.4 / 1.4.10), in all three locales — the ckb transcreation is often the longest string, so it is the binding case for reflow.
- RTL note: scaling and reflow are verified per-locale because a longer Sorani label at 200% is where a fixed-width chip or a two-column row breaks first; the layout is logical start/end so it reflows without a separate codepath ([05-layout-spacing-touch.md](05-layout-spacing-touch.md), [12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Disable, ignore, or silently cap OS text scaling on UI chrome to "protect" a layout; we reflow, paginate, or clamp with a documented ceiling instead.
- OS-scale, re-typeset, or reflow the muṣḥaf glyph layer to make it bigger — only the dedicated zoom transform enlarges it ([PRD R1](../PRD.md)).
- Use the deprecated `textScaleFactor`; all scaling goes through `TextScaler` so Android 14 non-linear scaling is respected.

---

## 6. Touch targets are sized for a fast, daily, one-handed recite flow

**Statement.** Every interactive control is at least **48×48dp** on Android and **44×44pt** on iOS, with comfortable spacing. The recite/grade controls — tapped many times daily, often quickly and one-handed — are made larger still, because the cost of a mis-tap on a sacred-text grade is high. This requirement is set here and built in [05-layout-spacing-touch.md](05-layout-spacing-touch.md).

**Evidence.**
- SC 2.5.8 Target Size (Minimum) (new in 2.2, AA) sets a floor of **24×24 CSS px**, with a spacing exception (an undersized target passes if a 24-px-diameter circle centered on it doesn't intersect a neighbor) ([W3C: Target Size Minimum](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)). The platform conventions we actually build to are stricter: Material 3 / Android **48×48dp** with ≥8dp spacing, Apple HIG / iOS **44×44pt** ([Material 3: Accessibility — designing for structure](https://m3.material.io/foundations/designing/structure); [Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility); [LogRocket: accessible touch target sizes](https://blog.logrocket.com/ux-design/all-accessible-touch-target-sizes/)).
- Flutter ships both as automated test guidelines: `meetsGuideline(androidTapTargetGuideline)` enforces tappable nodes are **at least 48×48 px**, and `meetsGuideline(iOSTapTargetGuideline)` enforces **at least 44×44 px** ([Flutter API: AccessibilityGuideline](https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html)).

**In practice.**
- The four-level grade band (Again / Hard / Good / Easy) and the per-line stumble taps clear `touch.min` (48dp) with `space.2` (8dp) spacing, and the grade band is rendered taller still — the most-tapped, often-rushed surface in the app ([PRD §12.2](../PRD.md); [05-layout-spacing-touch.md](05-layout-spacing-touch.md), [07-components.md](07-components.md)).
- A stumble-line tap maps to a line index; because a glyph line can be visually shorter than 48dp, its *hit area* is padded to ≥48dp while the immutable muṣḥaf glyph is untouched ([PRD §8.1, R1](../PRD.md)).
- Quran zoom and OS text-scale must never shrink a hit area below the floor; this is asserted in the release checklist (§10) via `androidTapTargetGuideline` / `iOSTapTargetGuideline` widget tests.
- Targets are sized identically in fa/ckb/ar — touch size is script-independent — though the *labels* on those targets are localized and bidi-isolated (§7, §8).

**Anti-patterns — we will never:**
- Ship an interactive control below 48×48dp (Android) / 44×44pt (iOS), however small its icon, or place two targets closer than 8dp ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)).
- Put the primary daily action (grade) on a pinpoint icon or behind a long-press; it is large, labeled, and obvious.
- Grow a tap target by reflowing the muṣḥaf glyph layer — only the transparent hit region grows ([PRD R1](../PRD.md)).

---

## 7. Screen readers: every control a localized semantic label, in fa/ckb/ar

**Statement.** TalkBack and VoiceOver users can operate the entire app. Every control — especially every icon-only control — carries a meaningful, **localized** semantic label; multi-part items are merged into one spoken phrase; decoration is excluded; and state changes the reader would otherwise miss are announced in the correct reading direction.

**Evidence.**
- Flutter maintains a **semantics tree** parallel to the widget tree and exposes it to TalkBack and VoiceOver; standard Material/Cupertino widgets populate it automatically, and custom rendering is annotated with the **`Semantics`** widget ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility); [Flutter: Assistive technologies](https://docs.flutter.dev/ui/accessibility/assistive-technologies); [Flutter API: Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html)). The testable rule: "The screen reader should be able to describe all controls on the page when you tap on them, and the descriptions should be intelligible" ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility)).
- `MergeSemantics` collapses a subtree into one spoken node, and `ExcludeSemantics` hides decorative elements ([Flutter API: Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html); [Flutter: Assistive technologies](https://docs.flutter.dev/ui/accessibility/assistive-technologies)).
- For state changes the reader wouldn't otherwise notice, `SemanticsService.announce(message, textDirection)` takes a `TextDirection` precisely so the bridge speaks in the correct reading direction; on Flutter post-v3.35 it is superseded by `sendAnnouncement` ([Flutter API: SemanticsService.announce](https://api.flutter.dev/flutter/semantics/SemanticsService/announce.html)).
- Screen readers also need the correct **language per run** to choose the right pronunciation voice — Flutter exposes `TextSpan.locale` and `MaterialApp.locale` for this ([Flutter: Assistive technologies](https://docs.flutter.dev/ui/accessibility/assistive-technologies)).

**In practice.**
- Every icon-only control — the mirrored back/next arrows, the heat-map cells, the teacher sign-off toggle, the track chips — has a localized label authored in the ARB strings ([11-voice-and-tone.md](11-voice-and-tone.md), [12-localization-and-rtl.md](12-localization-and-rtl.md)); a missing or English-only label is a release blocker alongside the existing ARB-coverage gate ([PRD §20.5](../PRD.md)).
- A page-card is wrapped in `MergeSemantics` so "Juz ۷ · page ۱۳۴ · weak" is read as **one** phrase, not three fragments; purely decorative dividers and ornament use `ExcludeSemantics`.
- Background state changes that matter — "catch-up plan ready," "page graded," "sign-off recorded" — are announced via the announce API with the active locale's `TextDirection.rtl`, so the message is spoken in reading order ([PRD §7.9, §8.2](../PRD.md)).
- Each text run carries its `locale` (fa/ckb/ar) so the reader speaks Persian, Sorani-Kurdish, and Arabic in the right voice; numerals inside labels are in the locale digit set (§8) so the reader speaks them naturally.
- The muṣḥaf glyph page is *not* fed to the screen reader as glyph codepoints (the QPC PUA glyphs are not readable text); the reader announces the page's *reference* — surah, ayah range, juz — from the bundled structure data, never a reconstruction of the sacred text ([PRD §11.2, R1](../PRD.md)).

**Anti-patterns — we will never:**
- Ship an icon-only control without a localized semantic label, or an English label in an fa/ckb/ar build.
- Let a screen reader read a page-card as disconnected fragments, or read out decorative ornament.
- Attempt to expose the muṣḥaf glyph codepoints as "text" to assistive tech — the reference (surah/ayah/juz) is announced instead, never a re-derived string ([PRD R1](../PRD.md)).

---

## 8. RTL accessibility: focus and reading order *are* the visual order

**Statement.** Right-to-left is made accessible, not merely visible. Screen-reader traversal and keyboard/switch focus run right-to-left, top-to-bottom, matching the visual flow; directional icons mirror and non-directional ones do not; and every embedded LTR run (page numbers, "Juz N," filenames) is bidi-isolated so it neither displays nor *reads* in the wrong order.

**Evidence.**
- When an LTR layout is served to RTL users the failures are well-documented: "primary content is on the wrong side, focus order does not match visual order, and directional icons (back arrows, chevrons, progress indicators) point the wrong way" ([accessibility-test.org: RTL considerations](https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/)). Reading and focus order must follow the RTL visual order, or the user is disoriented ([SimpleLocalize: multilingual a11y](https://simplelocalize.io/blog/posts/website-accessibility/)). In Flutter, app-wide `Directionality(textDirection: TextDirection.rtl)` drives layout and semantic order together ([PRD §13.2](../PRD.md)).
- Material's bidirectionality contract: mirror icons that imply direction (back/forward, chevron, progress, send) but **not** icons that reference a real-world object or fixed convention — media playback (play points the same way), clocks, phone, numbers, and the muṣḥaf glyph itself; and use **logical** start/end properties, never hard-coded left/right ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl); [Material: Bidirectionality](https://m2.material.io/design/usability/bidirectionality.html)).
- Mixed-direction text is an accessibility bug, not just a visual one: without **bidi isolation** (`FSI`…`PDI`) the algorithm reorders embedded runs ("page 7 of 30" → "30 of 7") and a reader can speak them out of order; numerals must render in the locale digit set so the reader voices them naturally ([accessibility-test.org: RTL](https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/); [PRD §13.2, §13.3](../PRD.md)).

**In practice.**
- App-wide `Directionality.rtl` ([12-localization-and-rtl.md](12-localization-and-rtl.md)) makes focus/reading order follow the visual order on Today, Muṣḥaf, and Progress; this is a *tested invariant* — TalkBack/VoiceOver traversal is verified to run right-to-left, top-to-bottom, in the per-locale RTL golden suite (§10, [PRD §20.5](../PRD.md)).
- A single **icon-mirroring table** lives in [12-localization-and-rtl.md](12-localization-and-rtl.md): mirror back / next / chevron / progress / send; do **not** mirror media-playback, clock, phone, numerals, or the muṣḥaf glyph. Everything is driven by logical start/end ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)) so one direction flag flips the app correctly — and consistently for the screen reader.
- Every embedded LTR run — a page number, "Juz N," a version string, a backup filename — is wrapped in Unicode FSI/PDI isolation; numerals render in **Extended Arabic-Indic** (۰۱۲۳…) for fa/ckb and **Arabic-Indic** (٠١٢٣…) for ar via `intl` `NumberFormat`, never raw ASCII spliced into a localized string. This fixes both the visual reorder and the spoken order.
- Each run also sets its `locale` so the reader picks the right pronunciation voice (§7); a "Juz ۷" chip therefore both *looks* right inside the RTL row and *reads* right to TalkBack/VoiceOver in fa/ckb/ar.

**Anti-patterns — we will never:**
- Ship a focus or reading order that contradicts the RTL visual order, or assume LTR traversal "is close enough."
- Mirror an icon whose meaning is absolute (a play triangle, a clock, the muṣḥaf glyph) — only directional glyphs flip ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).
- Splice raw ASCII digits or an un-isolated Latin run into a localized RTL string; every embedded run is bidi-isolated and locale-tagged.

---

## 9. Offline + no-AI is an accessibility advantage; we bank it and state it

**Statement.** Several hard constraints help disabled users *by construction*, and we name them so reviewers see the starting floor: no account removes login/CAPTCHA cognitive barriers; no microphone removes any voice-input dependency; and the calm, non-gamified, no-motion design avoids seizure and anxiety triggers. These are wins to bank, not problems to solve.

**Evidence.**
- No account / no authentication removes the cognitive-load and CAPTCHA barriers that WCAG 2.2 added 3.3.7 / 3.3.8 to fix ([Vispero: New SC in WCAG 2.2](https://vispero.com/resources/new-success-criteria-in-wcag22/); [PRD §17](../PRD.md)) — see §2.
- No microphone / no speech recognition ([PRD C2, R5](../PRD.md)) means no voice-input dependency that would exclude users with speech differences or those who cannot recite aloud at a measured pace; grading is human and self-paced ([PRD §8](../PRD.md)).
- The calm, non-gamified design — no streaks, no confetti, no celebratory or flashing motion ([PRD R3, C6](../PRD.md); [06-motion-and-haptics.md](06-motion-and-haptics.md)) — inherently avoids the WCAG seizure/flash and motion-from-interaction risks (2.3.1 / 2.3.3) and the anxiety load that harms users with cognitive and attention differences. The empirical case against gamifying worship is the overjustification meta-analysis ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)).

**In practice.**
- The accessibility synthesis lists these three architectural wins explicitly so a reviewer or contributor sees the floor we start from, then spends their effort on the *remaining* work — contrast, labels, scaling, target size, RTL order — all of which is testable execution, not architecture.
- The "no motion to trigger" property is upheld in [06-motion-and-haptics.md](06-motion-and-haptics.md) (restrained durations, no celebratory motion, Reduce Motion honored); this file only depends on it as an accessibility guarantee.
- These wins hold identically in fa/ckb/ar — there is no locale with a login, a mic prompt, or a celebratory animation to undermine them.

**Anti-patterns — we will never:**
- Add a feature that reintroduces a removed barrier — a login, a mic dependency, a flashing celebration, a streak-pressure animation — to gain "engagement" ([PRD R3, C6](../PRD.md)).
- Treat these architectural wins as a reason to skip the testable work; the floor is high, but §3–§8 still must be verified and gated (§10).

---

## 10. The accessibility release checklist (release-blocking)

**Statement.** A build does not ship until it passes both automated `meetsGuideline` checks and a manual assistive-technology pass *in our real languages*. Automated checks catch the easy 80%; the RTL/multilingual 20% only surfaces with a screen reader in-language. This checklist is part of the §20 release gates, not a separate optional audit.

**Evidence.**
- Flutter ships automated accessibility guidelines runnable in widget tests: `meetsGuideline(textContrastGuideline)`, `androidTapTargetGuideline` (48×48), `iOSTapTargetGuideline` (44×44), and `labeledTapTargetGuideline` (tappable nodes have labels) ([Flutter: Accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing); [Flutter API: AccessibilityGuideline](https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html)).
- Flutter's own testable rule for manual verification: "The screen reader should be able to describe all controls on the page when you tap on them, and the descriptions should be intelligible" ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility)) — which, for an RTL multilingual app, can only be confirmed by a screen reader running in fa/ckb/ar ([accessibility-test.org: RTL](https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/)).
- The PRD already makes localization completeness and RTL golden screenshots release-blocking ([PRD §20.5](../PRD.md)); this checklist extends that gate to assistive tech.

**In practice.**

| # | Gate | How it is checked | Blocks release |
|---|---|---|---|
| A1 | Text contrast ≥ 4.5:1 (≥ 3:1 large) in all four appearances | `meetsGuideline(textContrastGuideline)` over golden screens | yes |
| A2 | Non-text contrast ≥ 3:1 (heat-map, decay marks, control states) | measured audit in [03](03-color-and-themes.md)/[08](08-data-visualization.md) | yes |
| A3 | Color-independence: heat-map readable in grayscale / deuteranope sim | simulation + the text weakest-pages list present | yes |
| A4 | Text resize to 200% (+ iOS AX): no clipping, no horizontal scroll | per-locale golden screens at scale (SC 1.4.4 / 1.4.10) | yes |
| A5 | Muṣḥaf zoom works; glyph layer never OS-scaled or reflowed | reader zoom test; layout-data unchanged ([PRD R1](../PRD.md)) | yes |
| A6 | Touch targets ≥ 48×48dp / 44×44pt, ≥ 8dp apart | `androidTapTargetGuideline` / `iOSTapTargetGuideline` | yes |
| A7 | Every control has a localized label (fa/ckb/ar) | `labeledTapTargetGuideline` + ARB-coverage gate | yes |
| A8 | RTL focus/reading order = visual order | per-locale RTL golden suite + manual TalkBack/VoiceOver traversal | yes |
| A9 | Manual TalkBack + VoiceOver pass in fa, ckb, ar, on the cold-start → first day → review → catch-up path | human test on real devices | yes |

- The automated gates (A1, A6, A7) run in CI as widget tests; A2–A5 and A8 ride the per-locale golden-screenshot suite; **A9 is a human pass** with TalkBack and VoiceOver in all three languages over the core daily path — the only way the RTL/multilingual 20% is caught ([research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md)).
- This checklist sits beside the muṣḥaf-integrity, engine-golden, and localization gates in [PRD §20](../PRD.md); an accessibility failure is release-blocking with the same authority as a contrast or ARB-coverage failure.

**Anti-patterns — we will never:**
- Ship on automated checks alone; the manual in-language TalkBack/VoiceOver pass (A9) is mandatory because RTL/multilingual failures don't show up otherwise.
- Defer an accessibility gate to "the next release" — A1–A9 block this one.
- Run the assistive-tech pass in English only and assume fa/ckb/ar inherit it; each locale is tested in its own voice and reading direction.

---

## References

- accessibility-test.org. *RTL (Right-to-Left) Website Accessibility Considerations* — focus/reading order must follow visual order; mirror directional icons; bidi isolation of embedded runs. https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/
- AccessibilityAssistant. *How to apply WCAG 2.2 colour-contrast accessibility* — 1.4.3 (4.5:1 / 3:1) and 1.4.11 (3:1 non-text) ratios. https://accessibilityassistant.com/blog/accessibility-insights/how-to-apply-wcag-22-colour-contrast-accessibility/
- The A11Y Project. *Text resizing in iOS and Android.* https://www.a11yproject.com/posts/text-resizing-in-ios-and-android/
- Birch, J. (2012). *Worldwide prevalence of red-green color deficiency.* Journal of the Optical Society of America A, 29(3). https://www.researchgate.net/publication/223985289_Worldwide_prevalence_of_red-green_color_deficiency
- Borland, D., & Taylor, R. M., II. (2007). *Rainbow Color Map (Still) Considered Harmful.* IEEE Computer Graphics and Applications, 27(2), 14–17. https://doi.org/10.1109/MCG.2007.323435
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). *A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation.* Psychological Bulletin, 125(6), 627–668. https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- Dept Agency. *iOS Accessibility: Dynamic Type* (Larger Text, AX sizes). https://engineering.deptagency.com/ios-accessibility-part-1-dynamic-type
- Flutter. *Accessibility* (overview: TalkBack/VoiceOver, 48×48 targets, 4.5:1 contrast, scaling; "describe all controls… intelligible"). https://docs.flutter.dev/ui/accessibility
- Flutter. *Accessibility testing* (`meetsGuideline`, tap-target and contrast guidelines). https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Flutter. *Accessibility: Assistive technologies* (Semantics tree; `MergeSemantics`/`ExcludeSemantics`; `TextSpan.locale`). https://docs.flutter.dev/ui/accessibility/assistive-technologies
- Flutter. *Deprecate textScaleFactor in favor of TextScaler.* https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor
- Flutter. *Android 14 non-linear font scaling migration.* https://docs.flutter.dev/release/breaking-changes/android-14-nonlinear-text-scaling-migration
- Flutter API. *AccessibilityGuideline class* — `androidTapTargetGuideline` (48×48), `iOSTapTargetGuideline` (44×44), `labeledTapTargetGuideline`, `textContrastGuideline`. https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html
- Flutter API. *MediaQuery.withClampedTextScaling.* https://api.flutter.dev/flutter/widgets/MediaQuery/withClampedTextScaling.html
- Flutter API. *Semantics widget.* https://api.flutter.dev/flutter/widgets/Semantics-class.html
- Flutter API. *SemanticsService.announce(message, textDirection)* — RTL announcements; superseded by `sendAnnouncement` post-v3.35. https://api.flutter.dev/flutter/semantics/SemanticsService/announce.html
- LogRocket. *All accessible touch target sizes* (48dp Android / 44pt iOS / 24px WCAG). https://blog.logrocket.com/ux-design/all-accessible-touch-target-sizes/
- Material Design 3. *Accessibility — designing for structure* (48×48dp targets, ≥8dp spacing; accessible color pairings at minimum 3:1). https://m3.material.io/foundations/designing/structure
- Material Design 3. *Bidirectionality & RTL* (mirror directional icons; do not mirror media/clock/numbers; logical properties). https://m3.material.io/foundations/layout/bidirectionality-rtl
- Material Design. *Bidirectionality* (icon-mirroring rules; text alignment). https://m2.material.io/design/usability/bidirectionality.html
- News-Medical. *Color Blindness Prevalence* (~8% of men, ~0.5% of women; red-green dominant). https://www.news-medical.net/health/Color-Blindness-Prevalence.aspx
- Quranic Universal Library (QUL), Tarteel. *Glyph-Based Fonts* (604 per-page KFGQPC/QPC fonts; renders without OS shaping). https://qul.tarteel.ai/docs/glyph-based
- SimpleLocalize. *Accessibility checklist for multilingual websites* (RTL focus/reading order, `dir`). https://simplelocalize.io/blog/posts/website-accessibility/
- Vispero. *New Success Criteria in WCAG 2.2* (incl. 3.3.7 Redundant Entry, 3.3.8 Accessible Authentication). https://vispero.com/resources/new-success-criteria-in-wcag22/
- W3C (2023, updated 2024). *Web Content Accessibility Guidelines (WCAG) 2.2* — W3C Recommendation; nine new SC (incl. 2.5.8, 3.3.7, 3.3.8); backwards-compatible superset of 2.1; SC 1.4.1, 1.4.3, 1.4.4, 1.4.10, 1.4.11, 2.3.1, 2.5.8. https://www.w3.org/TR/WCAG22/
- W3C/WAI. *Understanding SC 1.4.1: Use of Color (Level A).* https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html
- W3C/WAI. *Understanding SC 1.4.3: Contrast (Minimum) (Level AA).* https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- W3C/WAI. *Understanding SC 1.4.4: Resize Text (Level AA).* https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html
- W3C/WAI. *Understanding SC 2.5.8: Target Size (Minimum) (Level AA, new in 2.2).* https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
