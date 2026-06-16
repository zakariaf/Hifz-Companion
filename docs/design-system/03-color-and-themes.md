# 03 — Color & Themes

This file is the single source of truth for every `color.*` token in Mihrab: the calm, green-anchored Islamic palette; the four reading appearances (Light, Sepia, Dark, Night); the retention heat-map's sequential ramp; the small semantic set; and a measured WCAG 2.2 contrast audit re-run per appearance. Every other file references these tokens **by name only** — if a raw hex value appears anywhere outside this document, that is a bug (sole exemption: the verbatim research material in [research/color-emotion-and-theming.md](research/color-emotion-and-theming.md), which is source notes, not a system file). The implementation target is Flutter Material 3 (`useMaterial3: true`) with a seeded `ColorScheme` per appearance: a tonal palette is generated from one seed green via `ColorScheme.fromSeed(seedColor:, brightness:, contrastLevel:)`, then a small number of roles are pinned to the audited values below ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html); [Material 3: Color roles](https://m3.material.io/styles/color/roles)). The token families this file owns are listed in the [README token map](README.md); the heat-map's *visual* grammar and "never a scoreboard" rule live in [08-data-visualization.md](08-data-visualization.md); contrast as a release gate lives in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md); the warm-night reading rationale and polarity choice cross-link [04-typography.md](04-typography.md) and the calm thesis in [01-design-principles.md](01-design-principles.md). Color is the app's loudest emotional lever and its quietest act of adab; this file keeps both honest.

## At a glance

| Decision | What we ship | Owning section |
|---|---|---|
| Base hue | Low-saturation **green** as reverent ground (calm *and* Islamic) | §1, §2 |
| Arousal rule | Saturation is the volume knob — cut saturation before anything else | §1 |
| Appearances | **Light, Sepia, Dark, Night** — system default respected, light/sepia default for dense reading | §3 |
| Dark surface | Off-black (~`#121413`), never pure black; desaturated tones | §4 |
| Heat-map | Single-hue **lightness ramp** green→neutral, redundantly labelled, never red/green | §5 |
| Semantic color | Tiny set; **never** a "success" green, never an alarm-red for decay | §6 |
| Contrast | WCAG 2.2 **AA as a hard floor**, re-audited in all four appearances | §7 |

---

## 1. Calm is a measurable specification: low saturation, blue–green region

**Statement.** Mihrab's palette is not "calm" by taste; it is calm by the published arousal regressions. The base is built from **low-to-medium saturation in the blue–green region**, and saturated warm color (reds/oranges) is rationed to rare, small, deliberate marks — never to surfaces. When any screen feels "loud," we lower **saturation** before touching hue, brightness, or layout.

**Evidence.**
- Emotional arousal is driven far more by **saturation and brightness than by hue**: the foundational PAD study gives `Arousal = −0.31·Brightness + 0.60·Saturation`, with saturation the dominant lever and brighter colors mildly *calming* ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)).
- A factorial replication with skin-conductance, heart-rate, and Self-Assessment-Manikin measures reproduced the pattern with objective bodily signals — "saturated and bright colors were associated with higher arousal" — and found the brightness→arousal effect appears *only under high saturation*, so a low-saturation palette stays calm across the full brightness range (i.e. in both a bright Light mode and a dim Night mode); arousal rises along the hue axis blue → green → red ([Wilms & Oberfeld, 2018](https://pubmed.ncbi.nlm.nih.gov/28612080/)).
- The largest synthesis to date — a systematic review spanning 128 years (1895–2022), 132 articles, 42,266 participants across 64 countries — concludes the colour–affect correspondences are systematic and stable across time and culture, driven by "lightness, saturation, and hue," and places **blue and green at the positive-valence, low-arousal corner** ([Jonauskaite & Mohr, 2025](https://pmc.ncbi.nlm.nih.gov/articles/PMC12325498/)). The cross-cultural stability matters: the calm choice generalizes across the fa/ckb/ar user base, not one culture's taste.

**In practice.**
- The seed for every `ColorScheme.fromSeed` is one desaturated green; Material 3 derives the tonal surfaces and on-colors from it ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)).
- `color.accent.green` is the single interactive tint (links, the primary action, selected states). Warm color exists only as `color.semantic.warning` and the catch-up accent — small marks paired with an icon and text (§6), never a full surface.
- The arousal regression is the literal design check: a reviewer who finds a surface "loud" reduces the chroma of the offending token here, in one file, and re-runs the audit (§7) — they do not add a brighter accent to compensate.
- RTL note (fa/ckb/ar): saturation is script-independent, so this rule is identical across all three locales; nothing about Arabic-script density changes the arousal budget.

**Anti-patterns — we will never:**
- Fill a screen, sheet, or card with a saturated color "for energy" — the daily ritual must lower arousal, not raise it.
- Reach for a brighter or more saturated accent to make something feel "more important"; importance is size, position, and copy, not chroma.
- Introduce a saturated red field anywhere (the most arousing hue–saturation corner), least of all on a decay surface (§5).

---

## 2. Green is the base hue — reverent ground, never reward

**Statement.** Green is the primary hue on a second, independent axis: it is the colour most associated with Islam and with Paradise, and it is used as **quiet, reverent ground** — for calm surfaces and for the "strong/healthy" end of the heat-map — *never* as a "success green," a streak colour, a celebration, or decoration laid over the muṣḥaf glyphs. Token names read as **states, not trophies** (`color.heatmap.strong`, not `color.success`).

**Evidence.**
- Green recurs in the Quran as the colour of the people of Paradise — "they will wear green garments of fine silk and brocade" (Q 18:31; also Q 76:21, Q 55:76) — and of gardens (*janna* literally *garden*), life, and serenity ([Green in Islam, Wikipedia](https://en.wikipedia.org/wiki/Green_in_Islam)); a Dar al-Iftāʾ al-Miṣriyya fatwa documents the traditional association of green with the Prophet ﷺ and its standing as a permissible expression of love, not innovation ([Dar al-Iftāʾ al-Miṣriyya: green and the Prophet ﷺ](https://www.dar-alifta.org/en/article/details/481/is-there-any-relation-between-the-green-color-and-prophet-muhammad)).
- The convergence is exact and rare: the most religiously resonant hue is also one of the most **measurably calm** (§1; [Jonauskaite & Mohr, 2025](https://pmc.ncbi.nlm.nih.gov/articles/PMC12325498/)) — adab and arousal science point at the same palette.
- The discipline that follows is required by the product's own rule against gamifying worship, which the motivation literature backs: tangible extrinsic rewards reliably undermine intrinsic motivation, so green-as-trophy would be both un-adab and counterproductive ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627); PRD R3, C6).

**In practice.**
- `color.accent.green` is a soft, desaturated green used as tint and as the "strong" anchor of the heat ramp (`color.heatmap.strong`, §5) — the same hue family, so "your Quran, kept green" reads as one calm idea across the app.
- Green never appears as confetti, a streak flame, a badge on an ayah, or a tinted overlay on the QPC glyph layer — the muṣḥaf is rendered faithfully and never decorated ([README Pillar 1](README.md); PRD R1, R3). Markers over the glyph page use neutral overlay tokens, not the accent green (see [08-data-visualization.md](08-data-visualization.md)).
- adab note (all locales): the green is identical in fa/ckb/ar; reverence is intent-and-presentation, not a per-locale skin. Where a surface must read as "healthy," it uses the *state* token, and the redundant label (§5, §6) carries the meaning so a colour-blind ḥāfiẓ is never excluded from the reassurance.

**Anti-patterns — we will never:**
- Name or use a green token as `color.success` / a "you won" colour, or flash green to celebrate completing a juz or a session.
- Lay green (or any tint) over the sacred glyphs as ornament; overlays are functional coordinates, never decoration.
- Treat green as a brand flourish to be saturated up for marketing screenshots — the in-app green and the store green are the same calm token.

---

## 3. Four reading appearances; default to positive polarity; respect the system

**Statement.** The muṣḥaf reader ships **four appearances — Light, Sepia, Dark, and Night (warm, dimmed)** — and the daytime default for dense Quran reading is a **light or sepia (positive-polarity)** appearance. The app honours the OS light/dark setting and offers an in-reader switch; it never forces dark mode as a brand statement, and it makes **no sleep claim** for Night.

**Evidence.**
- A consistent ergonomics literature finds a **positive-polarity advantage**: dark-on-light is read faster and more accurately than light-on-dark for younger and older adults, because the bright background constricts the pupil and sharpens the retinal image — and the penalty **grows as character size shrinks** ([Piepenbrock, Mayr, Mund & Buchner, 2013, *Ergonomics*](https://www.tandfonline.com/doi/abs/10.1080/00140139.2013.790485); [Piepenbrock, Mayr & Buchner, 2014, *Human Factors*](https://journals.sagepub.com/doi/abs/10.1177/0018720813515509)). Nielsen Norman Group's review concurs: "light mode won across all dimensions" for visual-acuity and proofreading, and the smaller the font, the more light mode helps ([NN/g: *Dark Mode vs. Light Mode*](https://www.nngroup.com/articles/dark-mode/)). For small, dense, diacritic-rich Arabic glyphs where a dropped ḥaraka changes a word, this argues for a light/sepia daytime default.
- But dark mode is a genuine accessibility need, and the picture reverses for some eyes: readers with cloudy ocular media (e.g. cataract) read *faster* in dark mode, while astigmatic readers (~30–50% of adults) suffer halation from light-on-dark — there is no universally better polarity, so NN/g's guidance is to **offer both and let the user choose**, and to ship dark mode for apps emphasizing prolonged reading ([NN/g: *Dark Mode vs. Light Mode*](https://www.nngroup.com/articles/dark-mode/)).
- Sepia keeps the positive-polarity legibility advantage while softening blue-white glare; a four-appearance set (a distinct warm Night beside Dark) is the conventional e-reader pattern, e.g. Libby's Bright / Sepia / Dark lighting ([Libby/OverDrive: *Change the lighting in the reading area*](https://help.libbyapp.com/en-us/6046.htm)). A warm, dimmed Night is defensible for *comfort* on circadian grounds — short-wavelength light at night suppresses melatonin ([Haghani et al., 2024, *J. Biomedical Physics & Engineering*](https://pmc.ncbi.nlm.nih.gov/articles/PMC11252550/)) — **but** a randomized trial found display colour-warming alone (Night Shift) produced no measurable sleep benefit, so we promise comfort and reverence, not better sleep ([Duraccio et al., 2021, *Sleep Health*](https://www.sleephealthjournal.org/article/S2352-7218(21)00060-7/abstract)).

**In practice.**

| Appearance | When | Polarity | Token behaviour |
|---|---|---|---|
| **Light** | Daytime default; brightest rooms | dark-on-light | full `ColorScheme.light` from the green seed |
| **Sepia** | Long murājaʿa in a dim room; glare-sensitive | dark-on-warm-paper | warm low-chroma `bg.primary`, contrast still ≥4.5:1 |
| **Dark** | Low-light, cataract/low-vision, OS dark | light-on-off-black | desaturated tones, `#121413` surface (§4) |
| **Night** | Reading at night, comfort | light-on-warm-dim | Dark warmed *and* luminance-reduced; no sleep copy |

- Implementation: each appearance is its own `ColorScheme` (the same seed green, per-appearance `brightness` and pinned roles) selected by a user setting that defaults to "follow system" for Light/Dark and exposes Sepia/Night as explicit choices in the reader (PRD §11.2, §15.2).
- Night is built as warmth **plus** a real brightness reduction, and onboarding/settings copy describes it as a comfort mode — the science set's "every claim is cited and graded" rule forbids a sleep promise ([11-voice-and-tone.md](11-voice-and-tone.md)).
- RTL note: appearance is orthogonal to direction — all four render under `Directionality.rtl` identically; the warm Sepia/Night paper tones must keep `color.text.primary` ≥4.5:1 for the same dense fa/ckb/ar UI text, which the audit (§7) confirms.

**Anti-patterns — we will never:**
- Force dark mode (or any single appearance) on the muṣḥaf reader as a "look"; the user and the OS decide.
- Describe Night as improving sleep, reducing eye strain to health levels, or any claim the cited evidence does not support.
- Drop Sepia or Night as "redundant with Dark" — they serve distinct eyes and distinct rooms (positive-polarity glare relief vs. warm low-luminance night reading).

---

## 4. Dark and Night use desaturated tones and an off-black surface — never pure black

**Statement.** The Dark and Night appearances use an **off-black surface (~`#121413`-equivalent)** and **desaturated, lighter tones** for colour and text — never pure `#000000`, never saturated accents that "vibrate" against the dark.

**Evidence.**
- Platform guidance and the arousal science coincide here. Material Design recommends **dark grey (≈`#121212`), not pure black**, as the base dark surface — grey carries shadow, elevation, and a wider tonal range, and high-saturation colours visually vibrate and lose legibility against very dark backgrounds, so dark themes should use **less-saturated, lighter tones** ([Material Design: *Dark theme*](https://m2.material.io/design/color/dark-theme.html)). Material 3 formalizes this with **tone-based surface roles** (surface containers from a tonal palette rather than translucent elevation overlays) and ships baseline schemes whose on-color/surface pairings are kept at accessible contrast ([Material 3: *Tone-based surfaces*](https://m3.material.io/blog/tone-based-surface-color-m3); [Material 3: Color roles](https://m3.material.io/styles/color/roles)).
- "Desaturate in the dark" is the *same* instruction the arousal data give: low saturation = low arousal (§1; [Wilms & Oberfeld, 2018](https://pubmed.ncbi.nlm.nih.gov/28612080/)). The legibility rule and the calm rule are one rule, which is why a single token set satisfies both.

**In practice.**
- `color.bg.primary` (Dark) = `#121413`; surface containers step up in *tone*, not via overlay opacity, so RTL surfaces stack predictably regardless of mirroring — we prefer Material 3 tone-based surface roles over translucent elevation ([Material 3: Tone-based surfaces](https://m3.material.io/blog/tone-based-surface-color-m3)).
- Dark `color.accent.green` is *lighter and lower-chroma* than its Light counterpart (`#6FC2A8` vs `#1F6E5A`) so it reads as text/link on the dark surface without vibration; the audit (§7) confirms 8.77:1.
- Material 3 exposes user-selectable contrast via `contrastLevel` on `ColorScheme.fromSeed` (−1.0 … 1.0); low-vision users can push past our floor without a bespoke theme ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)). See [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md).

**Anti-patterns — we will never:**
- Ship a pure-black (`#000000`) surface for OLED "savings" at the cost of halation and lost elevation cues.
- Keep an accent at its Light-mode saturation in Dark/Night — every accent is re-toned for the dark surface and re-audited.
- Simulate elevation in dark mode with stacked translucent whites instead of tone-based surface containers.

---

## 5. The retention heat-map: a single-hue lightness ramp, green receding to neutral

**Statement.** Page/juz health is encoded by a **sequential single-hue lightness ramp** (`color.heatmap.strong` → `…faded`), monotonic in luminance, where strong reads as the calm green and decay reads as a **muted neutral** — *never* a red→green gradient, *never* an alarming red scoreboard. Every cell is **redundantly encoded** (colour + number + label); colour is never the sole channel. Juz roll-ups use a **min-leaning** aggregate (one weak page is what fails you in ṣalāh).

**Evidence.**
- Ordered data must map to a **lightness ramp of one hue**, because lightness order is perceived as magnitude order under every form of colour-vision deficiency, whereas arbitrary hue steps are not ([Borland & Taylor, 2007, *Rainbow Color Map (Still) Considered Harmful*](https://doi.org/10.1109/MCG.2007.323435)). The rainbow/jet colormap introduces perceptual artifacts and false boundaries — the opposite of an honest health encoding.
- ~8% of men have red–green colour-vision deficiency and WCAG SC 1.4.1 forbids colour as the sole information channel, so a red→green "page health" scale would be unreadable for a meaningful slice of users and non-compliant ([W3C: WCAG 2.2, SC 1.4.1](https://www.w3.org/TR/WCAG22/); [WebAIM: Contrast and Color Accessibility](https://webaim.org/articles/contrast/)).
- A calm desaturated decay end (not saturated red) is required by the arousal science — saturated red is the highest-arousal corner and would spike alarm and shame ([Wilms & Oberfeld, 2018](https://pubmed.ncbi.nlm.nih.gov/28612080/)) — and by the product's honesty rule that the app never frames a page as "safe to drop" or punishes the user (PRD §7.12, §18; PRD R3).

**In practice.**

| Token | Light | Dark | Meaning |
|---|---|---|---|
| `color.heatmap.strong` | `#2E7D5B` | `#4FB386` | high retention (calm green) |
| `color.heatmap.good` | `#5FA382` | `#3C7E61` | solid |
| `color.heatmap.fair` | `#93BFA6` | `#356B55` | softening |
| `color.heatmap.weak` | `#B9C3BC` | `#38453E` | decaying (muted neutral) |
| `color.heatmap.faded` | `#D2D8D2` | `#262B27` | most-decayed / un-reviewed |

- The ramp is **monotonic in relative luminance** in both appearances (Light strong→faded L = 0.16 → 0.67; Dark strong→faded L = 0.36 → 0.02), so magnitude reads correctly in greyscale and under CVD; the *direction* flips with polarity (darker = stronger in Light; lighter = stronger in Dark) so the strong end always has the most contrast against the page.
- Each cell carries a **redundant value and label** (a localized percentage/number in the locale numerals, plus a tap-through detail) — the colour is reinforcement, never the message (PRD §12.5, §18). The visual grammar, VSUP-style uncertainty muting, and the "never a scoreboard" rule are specified in [08-data-visualization.md](08-data-visualization.md).
- Contrast posture (SC 1.4.11): the **strong** end clears the 3:1 graphical-object floor in both appearances (§7), and the lower steps intentionally sit below 3:1 — exactly like the labelled, tap-through heat cells where number and label carry the value, never colour alone ([W3C: WCAG 2.2, SC 1.4.11](https://www.w3.org/TR/WCAG22/)).
- RTL note: the heat-map grid lays out start→end under `Directionality.rtl`; numerals inside cells render in the locale set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) via `intl`, never raw ASCII (PRD §13.3; [12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Use a red→amber→green "traffic light" or a rainbow/jet colormap for page health — it is harmful and inaccessible.
- Render the decay end as a saturated, alarming red, or any encoding that reads as a failing scoreboard or a broken streak.
- Let colour alone carry a cell's state, or roll juz health up by an average that hides a single weak page (the roll-up is min-leaning).

---

## 6. A small semantic set — and what color is deliberately *not* allowed to mean

**Statement.** Semantic colour is a **tiny set** used only in transient alerts, confirmations, and integrity warnings — always paired with an icon and text. Decay, missed days, and catch-up are **not** semantic states: they never use an alarm-red, and they stay in calm neutral/green-family tokens so the app never assigns shame or alarm the user did not choose.

**Evidence.**
- Semantic colour must be redundant with shape and text (WCAG SC 1.4.1), and never the only carrier of meaning ([W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/)).
- The non-coercion principle forbids turning a missed day into a punitive red signal: extrinsic pressure and guilt undermine the intrinsic motivation a daily worship ritual depends on ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627); PRD R3), and controlling, alarming framing provokes reactance rather than action ([Miller et al., 2007, *Human Communication Research*](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)).

**In practice.**

| Token | Light | Dark | Paired icon | Use |
|---|---|---|---|---|
| `color.semantic.warning` | `#8A5A00` | `#E8B23C` | `warning` | Asset-integrity / checksum notice, "core pack not verified" (PRD §11.1.1) |
| `color.accent.green` | `#1F6E5A` | `#6FC2A8` | contextual | the one interactive tint; "verified / done" reads via icon + text, not a separate success-green |

- Deliberate restraint: a **missed-day catch-up** banner is framed as help, not failure — it uses calm neutral surface + `color.accent.green` accent and supportive copy ("You missed 3 days — here is a 5-day catch-up plan"), never a red overdue pile (PRD §7.9, §12.2; [11-voice-and-tone.md](11-voice-and-tone.md)).
- There is intentionally **no `color.semantic.success`** and **no `color.semantic.danger`** for routine hifz states: "saved" and "verified" are communicated by an icon + text in `color.accent.green`; the only red-adjacent token is the asset-integrity warning, which is a genuine, rare, technical failure (a corrupted Quran asset must be refused — PRD R1), not a comment on the user's revision.
- RTL note: warning/confirmation rows mirror under `Directionality.rtl`; the icon sits at the logical start, and the localized string carries the meaning so the colour is never load-bearing for fa/ckb/ar screen-reader users ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

**Anti-patterns — we will never:**
- Colour a missed day, a low-retention page, or a long gap in alarm-red, or treat lateness as an error state.
- Add a "success green" that flashes on completing a session or juz (that is gamification of worship).
- Use a semantic colour as the only signal of an integrity warning — it is always icon + text + colour, and the app refuses the unverified asset regardless of colour.

---

## 7. WCAG 2.2 AA is a hard floor, re-audited in every appearance

**Statement.** Every appearance — Light, Sepia, Dark, Night — independently clears **WCAG 2.2 AA**: body text ≥ **4.5:1**, large text and non-text/graphical objects ≥ **3:1**. A palette that passes in Light is **not** assumed to pass when re-toned for Sepia/Dark/Night; the luminance math is redone for each. The audit below is recomputed whenever any `color.*` value changes.

**Evidence.**
- WCAG 2.2 thresholds are computed from **relative luminance**, so a passing pair works regardless of colour vision: **4.5:1** normal text, **3:1** large text and non-text UI/graphical objects (SC 1.4.11), and colour is never the sole information channel (SC 1.4.1) ([W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/)). The 4.5:1 figure is empirically derived — the ISO/ANSI 3:1 baseline for normal observers times the ~1.5× contrast-sensitivity loss at 20/40 acuity ([W3C: *Understanding SC 1.4.3 — Contrast (Minimum)*](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)) — which is why it is a floor, not a target.
- Dark mode carries an intrinsic small-text legibility penalty, so each dark/night pair is audited independently — a passing light pair proves nothing about its inversion ([Piepenbrock, Mayr & Buchner, 2014](https://journals.sagepub.com/doi/abs/10.1177/0018720813515509)).
- The emerging APCA/WCAG 3.0 perceptual model better captures polarity, but its visual-contrast section is not yet a compliance standard (WCAG 3.0 is not expected to reach Recommendation before ~2028), so WCAG 2.2's 4.5:1 floor is what we commit to today ([W3C/WAI: *Visual contrast of text (WCAG 3 how-to)*](https://www.w3.org/WAI/GL/WCAG3/2021/how-tos/visual-contrast-of-text/)).

**In practice.** Ratios below were computed with the WCAG relative-luminance formula. Text/accent pairs target ≥4.5:1; heat-map marks are graphical objects (≥3:1 floor) where the *strong* anchor must clear 3:1 in each appearance.

### Core tokens — text & accent

| Pair (token on token) | Need | Light | Sepia | Dark | Night | Result |
|---|---|---|---|---|---|---|
| `text.primary` on `bg.primary` | 4.5 | 15.05 | 12.54 | 15.19 | 11.75 | Pass (AAA) |
| `text.primary` on `surface.container` | 4.5 | 13.68 | — | 13.34 | — | Pass (AAA) |
| `text.secondary` on `bg.primary` | 4.5 | 7.59 | 6.60 | 8.30 | 6.81 | Pass (AAA) |
| `text.tertiary` on `bg.primary` | 4.5 | 5.47 | — | 5.26 | — | Pass (AA) |
| `accent.green` as text/link on `bg.primary` | 4.5 | 5.61 | 5.88 | 8.77 | 7.90 | Pass |
| `text.on-accent` on `accent.green` fill | 4.5 | 6.11 | — | 8.87 | — | Pass |
| `semantic.warning` text on `bg.primary` | 4.5 | 5.44 | — | 9.57 | — | Pass |

Appearance background anchors used above: Light `bg.primary` `#F3F6F1` / `surface.container` `#E7ECE4`; Sepia `bg.primary` `#F3EAD8`; Dark `bg.primary` `#121413` / `surface.container` `#1E211F`; Night `bg.primary` `#14110C`. Text/accent values per appearance: Light `text.primary` `#1A211E`, `text.secondary` `#46514B`, `text.tertiary` `#5C665F`, `accent.green` `#1F6E5A`, `on-accent` `#FFFFFF`; Sepia `text.primary` `#2B2620`, `text.secondary` `#5A5042`, `accent.green` `#1C6450`; Dark `text.primary` `#E6EAE3`, `text.secondary` `#A7B0A8`, `text.tertiary` `#828B83`, `accent.green` `#6FC2A8`, `on-accent` `#0C140F`; Night `text.primary` `#D8CBB2`, `text.secondary` `#A89A80`, `accent.green` `#7FB48C`.

### Heat-map ramp — graphical objects (SC 1.4.11, mark vs theme `bg.primary`)

| Token | Need | Light | Dark | Result |
|---|---|---|---|---|
| `heatmap.strong` | 3 | 4.59 | 7.16 | Pass (the anchor clears 3:1) |
| `heatmap.good` | 3 | 2.73 | 3.83 | By design < 3:1 in Light* |
| `heatmap.fair` | 3 | 1.88 | 2.98 | By design < 3:1* |
| `heatmap.weak` | 3 | 1.66 | 1.84 | By design < 3:1* |
| `heatmap.faded` | 3 | 1.33 | 1.28 | By design < 3:1* |

\*The lower steps sit below the 3:1 minimum **intentionally**: they appear only inside labelled, tap-through heat cells where a localized number and label carry the value — colour is never the sole channel, so SC 1.4.1 is satisfied and SC 1.4.11's graphical-object minimum applies to the anchor that must read at a glance (`heatmap.strong`), not to atmosphere cells ([W3C: WCAG 2.2, SC 1.4.1 & 1.4.11](https://www.w3.org/TR/WCAG22/)). The ramp is monotonic in luminance in both appearances, so magnitude order survives greyscale and CVD (§5).

**Audit maintenance.** The release checklist in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md) re-runs this audit on any token change; any new colour pair (new appearance, new heat step, new semantic) must be added to these tables before merge, and tested with Material 3's increased `contrastLevel` ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)). The four `ColorScheme`s are defined once in the design-system layer; no widget hardcodes a hex value (token discipline, [README](README.md)).

**Anti-patterns — we will never:**
- Audit only Light and assume Sepia/Dark/Night inherit the result — each appearance is re-measured.
- Ship a text or interactive pair below 4.5:1, or a glance-critical graphical anchor below 3:1, in any appearance.
- Use APCA numbers as the compliance bar while WCAG 2.2 remains the standard, or treat 4.5:1 as a ceiling rather than a floor.

---

## References

- Borland, D., & Taylor, R. M., II. (2007). Rainbow Color Map (Still) Considered Harmful. *IEEE Computer Graphics and Applications*, 27(2), 14–17. https://doi.org/10.1109/MCG.2007.323435
- Dar al-Iftāʾ al-Miṣriyya. *Is there any relation between the green color and Prophet Muhammad ﷺ?* https://www.dar-alifta.org/en/article/details/481/is-there-any-relation-between-the-green-color-and-prophet-muhammad
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation. *Psychological Bulletin*, 125(6), 627–668. https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- Duraccio, K. M., et al. (2021). Does iPhone Night Shift mitigate negative effects of smartphone use on sleep outcomes in emerging adults? *Sleep Health*, 7(4). https://www.sleephealthjournal.org/article/S2352-7218(21)00060-7/abstract
- Flutter (Google). *ColorScheme.fromSeed* — API documentation (seedColor, brightness, contrastLevel, dynamicSchemeVariant). https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
- *Green in Islam* (Wikipedia, accessed 2026-06-16). https://en.wikipedia.org/wiki/Green_in_Islam
- Haghani, M., Abbasi, S., Abdoli, L., et al. (2024). Blue Light and Digital Screens Revisited: Vision Quality, Circadian Rhythm and Cognitive Functions Perspective. *Journal of Biomedical Physics and Engineering*. https://pmc.ncbi.nlm.nih.gov/articles/PMC11252550/
- Jonauskaite, D., & Mohr, C. (2025). Do we feel colours? A systematic review of 128 years of psychological research linking colours and emotions. *Psychonomic Bulletin & Review*. https://pmc.ncbi.nlm.nih.gov/articles/PMC12325498/
- Material Design (Google). *Dark theme* (Material 2) — off-black surface, desaturated tones. https://m2.material.io/design/color/dark-theme.html
- Material Design 3 (Google). *Color roles.* https://m3.material.io/styles/color/roles
- Material Design 3 (Google). *Introducing Tone-based Surfaces in Material 3.* https://m3.material.io/blog/tone-based-surface-color-m3
- Miller, C. H., Lane, L. T., Deatrick, L. M., Young, A. M., & Potts, K. A. (2007). Psychological Reactance and Promotional Health Messages. *Human Communication Research*, 33(2), 219–240. https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x
- Nielsen Norman Group (Pernice, K., & Schade, A.). *Dark Mode vs. Light Mode: Which Is Better?* https://www.nngroup.com/articles/dark-mode/
- OverDrive / Libby. *Change the lighting in the reading area* (Bright / Sepia / Dark). https://help.libbyapp.com/en-us/6046.htm
- Piepenbrock, C., Mayr, S., Mund, I., & Buchner, A. (2013). Positive display polarity is advantageous for both younger and older adults. *Ergonomics*, 56(7), 1116–1124. https://www.tandfonline.com/doi/abs/10.1080/00140139.2013.790485
- Piepenbrock, C., Mayr, S., & Buchner, A. (2014). Positive display polarity is particularly advantageous for small character sizes. *Human Factors*, 56(5), 942–951. https://journals.sagepub.com/doi/abs/10.1177/0018720813515509
- Valdez, P., & Mehrabian, A. (1994). Effects of color on emotions. *Journal of Experimental Psychology: General*, 123(4), 394–409. https://psycnet.apa.org/record/1995-08699-001
- W3C (2023, updated 2024). *Web Content Accessibility Guidelines (WCAG) 2.2* — SC 1.4.1 Use of Color, SC 1.4.3 Contrast (Minimum), SC 1.4.11 Non-text Contrast. https://www.w3.org/TR/WCAG22/
- W3C / WAI. *Understanding Success Criterion 1.4.3: Contrast (Minimum)* — the 3:1 × 1.5 (20/40 acuity) derivation of 4.5:1. https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- W3C / WAI. *Visual contrast of text (WCAG 3 how-to)* — status of the APCA / perceptual contrast method. https://www.w3.org/WAI/GL/WCAG3/2021/how-tos/visual-contrast-of-text/
- WebAIM. *Contrast and Color Accessibility — Understanding WCAG 2 Contrast and Color Requirements.* https://webaim.org/articles/contrast/
- Wilms, L., & Oberfeld, D. (2018). Color and emotion: effects of hue, saturation, and brightness. *Psychological Research*, 82(5), 896–914. https://pubmed.ncbi.nlm.nih.gov/28612080/
