# Typography

This file defines Mihrab's type system for the app *chrome* — the localized interface text of Hifz Companion across Persian (fa), Kurdish-Sorani (ckb), and Arabic (ar), all RTL. It owns every `type.*` token value: the bundled Perso-Arabic UI family and its weights, the size ramp, the Arabic-script line-height and letter-spacing rules, numeral handling, and dynamic-text scaling. Its single most important job, repeated in every section below, is to hold a **hard line between two completely separate rendering pipelines**: the calm modern UI typeface that sets buttons, labels, and dates, and the immutable KFGQPC/QPC muṣḥaf glyph fonts that *are* the typeset Quran page. The muṣḥaf is **not** a `type.*` token and is never styled here — it is an asset-pack glyph font owned by the `/quran` module (PRD §19.2, §11.2). Color values referenced by name are owned by [03-color-and-themes.md](03-color-and-themes.md); spacing and touch targets by [05-layout-spacing-touch.md](05-layout-spacing-touch.md); the full RTL/bidi/numeral/calendar architecture by [12-localization-and-rtl.md](12-localization-and-rtl.md); per-locale screen-reader and text-scaling acceptance by [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md). The evidence dossier behind this file is [research/arabic-persian-kurdish-typography.md](research/arabic-persian-kurdish-typography.md).

---

## At a glance

| Decision | Value | Owned by | Why (short) |
|---|---|---|---|
| UI typeface | **Vazirmatn** (variable, OFL 1.1), bundled | `type.family.ui` | Modern screen-Naskh sans; covers fa/ar and (verified) ckb ([rastikerdar/vazirmatn](https://github.com/rastikerdar/vazirmatn)) |
| UI fallback face | **Estedad** (variable, OFL 1.1), bundled | `type.family.uiFallback` | OFL alternate with Kurdish-glyph fixes ([aminabedi68/Estedad](https://github.com/aminabedi68/Estedad)) |
| Body floor | **16 sp** (never below 14 sp for any readable label) | `type.body`, `type.label` | Arabic dots/teeth collapse below ~16 px ([Code Guru](https://codeguru.ae/blog/fonts-and-readability-best-arabic-script-for-the-web/)) |
| Line-height | **1.5–1.6** for body | `type.lineHeight.arabic` | Arabic ascenders/descenders + stacked marks need leading ([W3C ALReQ](https://www.w3.org/International/alreq/)) |
| Letter-spacing | **0** on all Arabic-script runs | `type.letterSpacing.arabic` | Spacing joined cursive letters "creates undesirable results" ([W3C ALReQ](https://www.w3.org/International/alreq/)) |
| Numerals | Per-locale: Extended Arabic-Indic (fa/ckb), Arabic-Indic (ar) | `type.numeral` | Routed through `intl`, never concatenated as ASCII ([12-localization-and-rtl.md](12-localization-and-rtl.md)) |
| Sacred Quran type | **604 KFGQPC/QPC per-page glyph fonts** — NOT a `type.*` token | `/quran` module | The font *is* the typeset page; never the OS shaper ([QUL](https://qul.tarteel.ai/docs/glyph-based)) |

---

## 1. Two pipelines, one rule: the UI font never touches the Quran

**Statement.** The single most important typographic decision in the whole system is *not* which UI font to pick — it is that the Quran and the interface live in **two separate rendering pipelines that share no `TextStyle`, no metrics, and no shaper**. The UI font sets the chrome; the muṣḥaf is rendered glyph-only from the bundled per-page QPC fonts. They are deliberately, visibly different so a user never mistakes interface for scripture.

**Evidence.**
- KFGQPC/QPC muṣḥaf fonts are *glyph-based*: each glyph "is a visual representation of an entire word," fonts are "designed on a page-by-page basis, with each font corresponding to a specific page," and "most Muṣḥaf has 604 pages, so you'll need 604 font files to render the whole Quran" ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)). The pre-shaped words are mapped through the Unicode Private Use Area, which is exactly why they render correctly *without* OS-level shaping — the typeset page *is* the font ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based); [nuqayah/qpc-fonts](https://github.com/nuqayah/qpc-fonts)).
- The OS text shaper is the layer where ligatures break and diacritics drop or duplicate; rendering Quran text through it risks a single wrong or dropped diacritic, which ends the project (PRD R1, §11.2; README "two rules that outrank everything").
- Familiarity governs legibility — "you read best what you read most" ([Nedeljković et al., 2020, *J. Eye Movement Research* 13(2)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/)). Huffaz have read the exact Madani QPC page for years; that familiar shape is itself a memory cue, so re-typesetting the page in a modern UI font would both violate fidelity *and* actively hurt recall. The same maxim says the chrome should look like the ordinary modern script users meet everywhere else.

**In practice.**
- `type.family.ui` and `type.family.uiFallback` apply *only* to widgets that draw localized strings (`Text`, `TextField`, labels, the heat-map legend, settings rows, dates). They are never passed to the muṣḥaf reader (PRD §12.3) or any overlay painter.
- The muṣḥaf reader selects that page's dedicated QPC font and draws its glyph codepoints directly; weak-line, mutashābihāt-anchor, and current-ayah markers are rectangles/coordinates painted *over* the glyph layer (PRD §11.2). No `type.*` token participates.
- The two faces are kept *aesthetically* distinct as an adab requirement: the muṣḥaf keeps its traditional high-contrast Naskh QPC letterforms; the UI uses a calm, lower-contrast modern sans. Sacred type is reverent and fixed; UI type is quiet and serves it (Pillar 1 "reverence first"; see [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md)).
- A build-time check asserts no Quran asset path is ever routed through a `TextStyle`/UI shaper, complementing the runtime refusal-to-render guard (PRD §11.1.1, R1).

**Anti-patterns — we will never:**
- Render any Quran text — even a single ayah, a basmala, or a surah title in the muṣḥaf hand — through the UI font or the OS shaper.
- Re-typeset, reflow, or restyle a muṣḥaf page for any visual goal (zoom and theme transform the rendered glyph layer, never the text).
- Treat the QPC fonts as a `type.*` token, expose them to the theme, or let a UI font-size change affect the page.
- Pick a UI face that mimics the muṣḥaf hand closely enough to be mistaken for scripture.

---

## 2. The UI typeface: Vazirmatn, with Estedad as the verified fallback

**Statement.** Mihrab sets all interface text in **Vazirmatn**, a modern low-contrast Perso-Arabic sans, with **Estedad** as the fallback face. Both are bundled in the app binary; neither is ever fetched from a font CDN at runtime. The bundled version is pinned only after Sorani coverage is verified glyph-by-glyph (§3).

**Evidence.**
- Vazirmatn is a variable Perso-Arabic sans by Saber Rastikerdar, licensed **SIL Open Font License 1.1**, describing itself as "a Persian/Arabic font" with a true variable weight axis ([rastikerdar/vazirmatn](https://github.com/rastikerdar/vazirmatn); [Google Fonts: Vazirmatn specimen](https://fonts.google.com/specimen/Vazirmatn)). Its coverage has expanded over versions to include Kurdish from roughly v27 onward ([Wikipedia: Central Kurdish](https://en.wikipedia.org/wiki/Central_Kurdish)).
- Estedad (Amin Abedi) is an Arabic–Latin variable sans, **9 weights + variable axis, OFL 1.1**, with explicit Kurdish-glyph fixes (e.g. the HEH DOACHASHMEE isolated form) — a clean OFL fallback ([aminabedi68/Estedad](https://github.com/aminabedi68/Estedad); [Estedad issue #17](https://github.com/aminabedi68/Estedad/issues/17)).
- The Naskh-derived skeleton is the legible baseline for continuous reading: Naskh is "commonly used… for transcribing books, including the Qur'an, because of its easy legibility" and "became the basis for most types intended for continuous reading" ([Wikipedia: Naskh](https://en.wikipedia.org/wiki/Naskh_(script)); [Wikipedia: Arabic typography](https://en.wikipedia.org/wiki/Arabic_typography)). Vazirmatn and Estedad are humanist screen sans built on that familiar skeleton.
- Dedicated Kurdish families (Rabar, NRT) carry idiomatic Sorani letterforms but are commonly distributed without a clean embeddable OSS license — disqualifying for a free, auditable app that ships fonts in its binary ([Wikipedia: Kurdish typography](https://en.wikipedia.org/wiki/Kurdish_typography); [Kurdfonts: Rabar](https://www.kurdfonts.com/browse/rabar-kurdish-unicode-fonts)).
- Bundling rather than CDN fetch is a locked constraint: all UI fonts ship in the binary, no `google_fonts` runtime fetch (PRD §13.5, §19.1).

**In practice.**
- Token names: `type.family.ui` = Vazirmatn, `type.family.uiFallback` = Estedad. Both are variable OFL faces, so a small set of weights ships from one file each.
- One typeface carries all three locales (fa/ckb/ar) — there is no per-language font switch in the common case; the same `type.family.ui` resolves for every UI string. A Rabar/NRT-class face is considered *only* if a clear OFL-equivalent license is later confirmed (the hierarchy is **Vazirmatn (verified) → Estedad (verified) → dedicated Kurdish face only with a clean license**).
- Weights are restrained: Regular for body and labels, Medium/Semibold for emphasis and titles. No Thin/Light weights — thin strokes are the first thing to fail at small sizes for a dot-and-tooth script. No italics (the Perso-Arabic script does not use them).

**Anti-patterns — we will never:**
- Fetch a UI font from `google_fonts` or any CDN at runtime (offline-by-feel; PRD §17, §19.1).
- Bundle a Kurdish display font whose license is unclear or non-embeddable.
- Use a strongly geometric/Kufi display face for body or label text (reserved for short headings only, if at all — §6).
- Lock a font version before its Sorani coverage passes the CI gate (§3).

---

## 3. Sorani coverage is a release gate, not an assumption

**Statement.** A font that renders Persian and Arabic flawlessly can still drop Sorani-specific letters to tofu. Coverage of **every** Sorani codepoint is verified glyph-by-glyph in CI before the bundled font version is pinned — and the ckb localization strings are themselves authored in canonical encoding so the font is never asked to render malformed input.

**Evidence.**
- Central Kurdish in Arabic script is "almost a true alphabet in which vowels are given the same treatment as consonants," using a 33–34-letter set that adds letters absent from core Arabic ([Wikipedia: Kurdish alphabets](https://en.wikipedia.org/wiki/Kurdish_alphabets); [Wikipedia: Kurdish typography](https://en.wikipedia.org/wiki/Kurdish_typography)). The codepoints a UI font **must** carry beyond standard Arabic include پ U+067E, چ U+0686, ژ U+0698, ڤ U+06A4, ک U+06A9 (Kurdish kaf, *not* U+0643), گ U+06AF, ڕ U+0695, ڵ U+06B5, ۆ U+06C6, ێ U+06CE, ە U+06D5 (AE), ھ U+06BE ([r12a/W3C: Sorani notes](https://r12a.github.io/scripts/arab/ckb.html); [Wikipedia: Kurdish alphabets](https://en.wikipedia.org/wiki/Kurdish_alphabets)). These match the extra letters the PRD flagged for ckb (§13.1).
- Two are notorious for breaking otherwise-good Arabic fonts: U+06D5 (ە, AE) is the dedicated Sorani vowel mandated *instead of* a heh+ZWNJ hack, and U+06A9 (ک) is the Kurdish kaf standardized in place of U+0643 ([r12a/W3C: Sorani notes](https://r12a.github.io/scripts/arab/ckb.html)).
- Real-world Sorani text carries encoding noise: "Zero width non-joiner (U+200C) usage is non-standard but occurs a lot… due to poor conversions," and bad converters substitute Teh Marbuta (ة) where the AE letter (ە) belongs ([Wikipedia: Kurdish typography](https://en.wikipedia.org/wiki/Kurdish_typography)).
- The PRD already requires "verify all Sorani letters render before locking" and an RTL golden-screenshot CI gate per locale (PRD §13.5, §20.5).

**In practice.**
- A CI step renders all twelve Sorani-specific codepoints (پ چ ژ ڤ ک گ ڕ ڵ ۆ ێ ە ھ) in the bundled `type.family.ui` and asserts no tofu (□), on both iOS and Android, before the font version is pinned (operationalizes PRD §13.5, §20.5). The same gate runs against `type.family.uiFallback`.
- ckb ARB strings are authored with canonical encoding — U+06D5 (ە) for AE, U+06A9 (ک) for kaf, the chosen heh (U+06BE) — and a lint step rejects stray U+200C and Teh-Marbuta-for-AE substitutions (the font is never handed malformed input). This pairs with the still-open native-speaker + scholarly term review (PRD §21.1; see [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- Coverage is treated as data discipline as much as font choice: clean input + verified glyphs together guarantee correct Sorani rendering.

**Anti-patterns — we will never:**
- Assume "supports Arabic" implies "covers Sorani"; coverage is proven per codepoint or the version is not shipped.
- Author ckb strings with the heh+ZWNJ AE hack, Teh-Marbuta-for-AE, or stray ZWNJ.
- Ship a locale whose golden screenshots show a single tofu glyph (release blocker).

---

## 4. Size: Arabic-script UI text starts larger than a Latin layout would

**Statement.** Arabic-script body text sits at **16 sp and up**, and no readable label drops below **~14 sp**. We do *not* reuse the 12–14 sp "secondary text" sizes common in Latin Material layouts, because the marks that distinguish Perso-Arabic letters collapse at those sizes.

**Evidence.**
- Field data on Arabic web text converges on **16 px (≈12 pt) as the floor for main content**, with 18 px for long-form and ~20 px on mobile; readers are reported to "process Arabic text 20% faster when displayed at 16 points or larger," and a survey of Saudi Arabia's top-100 sites found 65% use only 12–16 px — below the recommended floor for low-vision or mobile readers ([Code Guru: best Arabic script for the web](https://codeguru.ae/blog/fonts-and-readability-best-arabic-script-for-the-web/)).
- The mechanism is script-specific: Arabic letters are distinguished by dots (1–3, above or below) and small tooth shapes that collapse at small sizes ([Wikipedia: Naskh](https://en.wikipedia.org/wiki/Naskh_(script))). Persian and Sorani add more sub-/super-script marks (the small-v of ڕ/ڵ/ڤ/ێ, the vowel letters), making small sizes worse.
- Expressing UI text in scale-independent pixels (sp) lets the device font-size setting apply; in Flutter that system scale is surfaced via `TextScaler` ([Flutter: MediaQuery.textScalerOf](https://api.flutter.dev/flutter/widgets/MediaQuery/textScalerOf.html)), and Material's type system is organized around scalable roles ([Material 3: Typography](https://m3.material.io/styles/typography)).

**In practice.**
- Token ramp (sizes are the default at normal text-scale; all are sp and scale with the OS setting via §7):

| Token | Default size | Weight | Role |
|---|---|---|---|
| `type.display` | 28 sp | Semibold | One per screen at most: the Today day-header, a section hero |
| `type.title` | 22 sp | Medium | Screen titles, card titles, sheet titles |
| `type.body` | 16 sp | Regular | Default for everything: list rows, settings, onboarding prose, recite-flow text |
| `type.label` | 14 sp | Medium | Track chips, buttons, tab labels, the heat-map legend |
| `type.caption` | 13 sp | Regular | Timestamps, "last reviewed," secondary metadata — never load-bearing |
| `type.numeral` | inherits | — | Locale digit handling layered onto any token (§5) |

- `type.body` is the workhorse at 16 sp; `type.caption` at 13 sp is the floor and carries nothing the user must read to act (dates, "based on N reviews"). Anything load-bearing — a catch-up plan, a sign-off prompt, a privacy promise — sits at `type.body` or above.
- The ramp is deliberately short (six steps); hierarchy is carried by size *plus* weight (`title`/`label` Medium) and by `color.text.primary` vs `color.text.secondary` ([03-color-and-themes.md](03-color-and-themes.md)), never by a second typeface.

**Anti-patterns — we will never:**
- Reuse a Latin "12 sp secondary text" size for any Arabic-script label that must be read.
- Put load-bearing text (predictions, the catch-up plan, disclaimers, the riwāyah statement) below `type.body`.
- Use `minimumScaleFactor`-style auto-shrinking that pushes text below the `type.caption` floor.

---

## 5. Numerals follow the resolved locale, never a hand-picked digit

**Statement.** Every UI number is routed through locale-aware formatting so the correct digit family appears: **Extended Arabic-Indic** (۰۱۲۳۴۵۶۷۸۹) for fa and ckb, **Arabic-Indic** (٠١٢٣٤٥٦٧٨٩) for ar. ASCII digits are never concatenated into a localized string.

**Evidence.**
- Persian/Kurdish use Extended Arabic-Indic numerals; Arabic uses Arabic-Indic; the app must render digits in the locale set and use `intl` `NumberFormat` per locale rather than concatenating raw ASCII digits (PRD §13.3).
- A hard-coded ASCII digit is the non-Latin sibling of a hard-coded decimal separator — locale-resolved formatting is the correctness rule, not a nicety (mixed-content and date/numeral correctness, [12-localization-and-rtl.md](12-localization-and-rtl.md)).

**In practice.**
- `type.numeral` is not a separate size — it is the rule that any token rendering digits (page numbers, juz numbers, "3 days," due/last-reviewed dates) passes through `intl` `NumberFormat`/`DateFormat` for the resolved locale, producing the right digit family and separators (PRD §13.3).
- Calendar-aware dates (Hijri Umm al-Qurā, Solar-Hijri / Jalālī, Gregorian) render their numerals in the same locale digit set; calendar selection and formatting are owned by [12-localization-and-rtl.md](12-localization-and-rtl.md), and this file only guarantees the *type* renders those digits legibly at `type.body`/`type.label` sizes.
- Latin technical strings or Western digits embedded inside an RTL run (rare) are wrapped in bidi isolation (FSI/PDI) so they do not corrupt surrounding direction (PRD §13.2; §8 below).

**Anti-patterns — we will never:**
- Build a localized string by concatenating ASCII digits (`"Juz " + "7"`); numbers are formatted, then composed via ICU message placeholders.
- Force one digit family across all three locales, or hard-pick a digit glyph independent of the resolved locale.

---

## 6. Line-height, letter-spacing, and justification: inverted from Latin habits

**Statement.** Arabic-script body text uses **generous line-height (≈1.5–1.6)**, **zero letter-spacing**, **no programmatic kashida/tatweel**, and **start-aligned ragged** text. These are not stylistic preferences; the cursive, mark-stacked script makes the Latin defaults actively wrong.

**Evidence.**
- "Arabic ascenders and descenders extend much further than those of the Latin script" ([W3C: Arabic & Persian Layout Requirements](https://www.w3.org/International/alreq/)), and "Arabic fonts require underlines positioned further from the baseline than Latin text due to longer descenders" ([W3C: Arabic Script Gap Analysis](https://www.w3.org/TR/alreq-gap/)). A 1.5× line-height is the accessibility/text-spacing floor for body text, applied to Arabic body content by the UAE government RTL design system ([greadme: best font sizes](https://www.greadme.com/blog/seo/best-font-sizes-for-readability-complete-guide); [UAE Design System: Typography](https://designsystem.gov.ae/guidelines/typography)). Sorani's mandatory vowel letters and small-v marks add vertical material on nearly every word, strengthening the case.
- Because the script is cursive, "moving two joined characters closer to or further from each other creates undesirable results" — spacing may be added only at non-joining gaps ([W3C: Arabic & Persian Layout Requirements](https://www.w3.org/International/alreq/)). Arabic justification traditionally uses kashida/tatweel, but "excessive use of kashida or applying very long kashidas results in uneven color," and most UI toolkits implement it poorly ([W3C: ALReQ](https://www.w3.org/International/alreq/); [W3C: alreq-gap](https://www.w3.org/TR/alreq-gap/)).

**In practice.**
- `type.lineHeight.arabic` = **1.5–1.6**, defined once and applied app-wide as `TextStyle.height` (≈1.5 for dense lists, up to 1.6 for prose). Verify the chosen value never clips marks at the top of a line or descenders at the bottom, per-locale, via golden screenshots (PRD §20.5).
- `type.letterSpacing.arabic` = **0**. No `letterSpacing` on any Arabic-script run; this is encoded as a component-theme default so a stray value cannot creep in.
- Text is **start-aligned ragged** (RTL "start" = right); justification is off, and tatweel is never inserted programmatically to pad a label or fill a line.
- Underline/strikethrough decorations are avoided on Arabic runs where possible (descender clearance); emphasis is carried by weight and color instead.

**Anti-patterns — we will never:**
- Apply `letterSpacing` / tracking to Arabic-script text (it shatters the cursive join).
- Insert kashida/tatweel (U+0640) programmatically to justify or pad.
- Use full justification on Arabic-script paragraphs, or copy a Latin layout's tight ~1.2–1.4 line-height onto Arabic body text.

---

## 7. Dynamic text: respect the OS scale, reflow rather than truncate

**Statement.** All UI type is expressed in sp and scales with the device's system font-size setting; the layout **reflows** (chips wrap, rows grow taller) and never truncates load-bearing text as the scale grows. This is a daily-use, often-low-vision audience, so large-text support is first-class.

**Evidence.**
- The app must respect OS text-scale and support large text (PRD §18). In Flutter, system font-size preferences are surfaced via `MediaQuery.textScalerOf` / `TextScaler`, which scales text to the user's accessibility setting ([Flutter: MediaQuery.textScalerOf](https://api.flutter.dev/flutter/widgets/MediaQuery/textScalerOf.html)).
- Material's type system is built on scalable, semantic type roles rather than fixed sizes, supporting system text-scaling and translated/foreign-language text ([Material 3: Typography](https://m3.material.io/styles/typography)).
- Flutter's text stack has documented Arabic-script pitfalls under styling/splitting: diacritics misbehave when text is split across `TextSpan`s ([flutter/flutter #73108](https://github.com/flutter/flutter/issues/73108)); trailing diacritics can wrap to a new line ([flutter/flutter #105025](https://github.com/flutter/flutter/issues/105025)); and `TextStyle.height` does not guarantee an exact line box for every script ([flutter/flutter #23875](https://github.com/flutter/flutter/issues/23875)).

**In practice.**
- Sizes in §4 are sp; the app uses the system `TextScaler` and does not impose an app-level text-size toggle for UI chrome (the Quran reader has its own independent zoom — PRD §11.2, §12.3 — which is *not* a `type.*` concern).
- **Reflow contracts:** track chips and tab labels wrap to multiple lines rather than truncate; list rows grow vertically; the catch-up plan and recite/grade prompts must never ellipsize. These layout contracts bind [05-layout-spacing-touch.md](05-layout-spacing-touch.md) and [07-components.md](07-components.md).
- **Flutter discipline:** keep each localized label in a **single `Text`/`TextSpan`** — never fragment a word to style part of it (avoids the diacritic-clip and wrap bugs); set an explicit `TextStyle.height` (`type.lineHeight.arabic`) and verify it per-locale with golden screenshots (PRD §20.5). UI text is shaped normally by Flutter — the OS-shaper ban is *only* for Quran glyphs (§1).
- Hierarchy must survive large scales: when sizes converge at the top of the range, weight (`title`/`label` Medium) and position carry the hierarchy, never size contrast alone.

**Anti-patterns — we will never:**
- Hard-code pixel sizes that ignore the system text-scale, or cap scaling below the OS maximum for chrome.
- Truncate load-bearing text (a due plan, a sign-off prompt, the riwāyah line, a privacy promise) at large sizes.
- Split a single localized word across styled `TextSpan`s (diacritic-breaking).

---

## 8. Bidi isolation for mixed runs

**Statement.** When an RTL string embeds a Latin token or a Western-digit technical value, the embedded run is **bidi-isolated** so it cannot flip the direction of the surrounding text. This keeps page references, version labels, and the occasional Latin string visually correct inside fa/ckb/ar layouts.

**Evidence.**
- Mixed page numbers, "Juz 7," and Latin technical strings inside RTL text require proper bidi isolation using Unicode FSI/PDI and Flutter's `Bidi`/`Directionality` (PRD §13.2). The app runs `Directionality.rtl` app-wide with logical (start/end) insets.

**In practice.**
- Embedded Latin/Western-digit runs are wrapped in First-Strong Isolate / Pop Directional Isolate (FSI/PDI) via Flutter's `Bidi` utilities so a stray Latin token does not reorder the RTL line (PRD §13.2). The numeral rule in §5 keeps most numbers in-script, minimizing how often isolation is needed.
- The full RTL/bidi architecture — mirroring policy, logical insets, term-set switching — is owned by [12-localization-and-rtl.md](12-localization-and-rtl.md); this file only ensures the *type* of an isolated run renders at the right token size and never with Arabic `letterSpacing`.

**Anti-patterns — we will never:**
- Place a raw Latin or Western-digit token into an RTL string without bidi isolation.
- Hard-code left/right alignment for mixed content (logical start/end only).

---

## References

- Code Guru. *Fonts and Readability: Best Arabic Script for the Web* (16 px body floor; ~20% faster ≥16 pt; Naskh/sans for screen). https://codeguru.ae/blog/fonts-and-readability-best-arabic-script-for-the-web/
- Estedad (Amin Abedi). *aminabedi68/Estedad* — Arabic–Latin variable sans, 9 weights + variable axis, SIL OFL 1.1, with Kurdish-glyph fixes. https://github.com/aminabedi68/Estedad · Kurdish-glyph fix: https://github.com/aminabedi68/Estedad/issues/17
- Flutter / Dart team. *MediaQuery.textScalerOf — Flutter API* (system text-scale / accessibility font sizing). https://api.flutter.dev/flutter/widgets/MediaQuery/textScalerOf.html
- Flutter issue #73108. *Arabic diacritics misbehave when separated into spans.* https://github.com/flutter/flutter/issues/73108
- Flutter issue #105025. *Button text with Arabic diacritics wrapped to a new line.* https://github.com/flutter/flutter/issues/105025
- Flutter issue #23875. *Add support for "leading" — `TextStyle.height` does not guarantee an exact line box.* https://github.com/flutter/flutter/issues/23875
- Google Fonts. *Vazirmatn specimen* (variable wght axis; designer Saber Rastikerdar; OFL). https://fonts.google.com/specimen/Vazirmatn
- greadme. *Best Font Sizes for Readability* (16 px body floor; 1.5× line-height; WCAG text-spacing minimums). https://www.greadme.com/blog/seo/best-font-sizes-for-readability-complete-guide
- Kurdfonts. *Rabar Kurdish Unicode Fonts* (dedicated Kurdish family; license not OFL-clear). https://www.kurdfonts.com/browse/rabar-kurdish-unicode-fonts
- Material Design 3. *Typography* (scalable, semantic type roles supporting system text-scaling and translated text). https://m3.material.io/styles/typography
- Nedeljković, U., Jovančić, K., & Pušnik, N. (2020). *You read best what you read most: An eye tracking study.* Journal of Eye Movement Research, 13(2). https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/
- nuqayah. *qpc-fonts* — KFGQPC per-page glyph fonts (Private Use Area mapping). https://github.com/nuqayah/qpc-fonts
- QUL (Quranic Universal Library / Tarteel). *Glyph-Based Fonts* (each glyph = a whole word; one font per page; 604 fonts for the whole Quran; renders without OS shaping). https://qul.tarteel.ai/docs/glyph-based
- r12a / W3C i18n. *Sorani (Central Kurdish, ckb) orthography notes* (extra letters with codepoints; U+06D5 AE over heh+ZWNJ; U+06A9 kaf; U+06BE vs U+0647 heh). https://r12a.github.io/scripts/arab/ckb.html
- Vazirmatn (Saber Rastikerdar). *rastikerdar/vazirmatn* — Persian/Arabic variable font, SIL OFL 1.1. https://github.com/rastikerdar/vazirmatn
- Wikipedia. *Arabic typography* (Naskh as the basis for continuous-reading type). https://en.wikipedia.org/wiki/Arabic_typography
- Wikipedia. *Central Kurdish* (Vazirmatn Kurdish coverage from ~v27). https://en.wikipedia.org/wiki/Central_Kurdish
- Wikipedia. *Kurdish alphabets* (Sorani Arabic-based alphabet; vowels as letters; ک U+06A9 not ك U+0643). https://en.wikipedia.org/wiki/Kurdish_alphabets
- Wikipedia. *Kurdish typography* (Sorani-unique letters; non-standard U+200C; Teh-Marbuta-for-AE substitution). https://en.wikipedia.org/wiki/Kurdish_typography
- Wikipedia. *Naskh (script)* (used for the Qur'an "because of its easy legibility"; dots aid legibility). https://en.wikipedia.org/wiki/Naskh_(script)
- W3C. *Arabic & Persian Layout Requirements (alreq)* (ascenders/descenders extend further than Latin; no spacing between joined letters; excessive kashida → uneven color). https://www.w3.org/International/alreq/
- W3C. *Arabic Script Gap Analysis (alreq-gap)* (underlines further from baseline due to longer descenders). https://www.w3.org/TR/alreq-gap/
- UAE Design System 2.0. *Typography guidelines* (Arabic body line-height ≥1.5; right-aligned; avoid justification). https://designsystem.gov.ae/guidelines/typography
