# Mihrab — The Hifz Companion Design System

Mihrab is the design system for **Hifz Companion**, a fully offline, free (built as *ṣadaqah jāriyah*), no-AI Flutter app that helps huffaz and serious students **retain** the Quran across all 30 juz. This folder is the single source of truth for how the app looks, moves, speaks, and earns trust: every color, type style, spacing value, motion curve, component, chart, and sentence of copy is specified here, and every significant decision is backed by a real, web-verified citation — peer-reviewed HCI/perception research, Material 3 and Flutter platform guidance, WCAG 2.2, Unicode/W3C bidi requirements, or an identifiable scholarly/traditional Islamic source. It is written for a solo developer building the app in Flutter for iOS and Android, RTL-first across **Persian (fa), Kurdish Sorani (ckb), and Arabic (ar)**, and for the open-source contributors who come after. The locked product constraints — offline, no accounts, no telemetry, no AI/audio, no gamification — are defined in [`../PRD.md`](../PRD.md); the deep evidence base is in [`../../research/RESEARCH-FINDINGS.md`](../../research/RESEARCH-FINDINGS.md) and the per-topic dossiers in [`research/`](research/).

---

## The name

A **miḥrāb** is the niche set into a mosque wall that marks the *qibla* — the single direction every worshipper faces. It is the quietest, most reverent point in the room: undecorated stone or tilework whose entire purpose is orientation, not ornament. That is this app in one image. Everything is oriented toward one thing — the faithful retention of the muṣḥaf — and the interface, like the niche, is calm, dignified, and RTL by its very geometry (the niche points the way the script reads). The miḥrāb is also where the *imām* leads recitation aloud from memory, which is exactly the act this app serves and never replaces. Where a design decision needs language- or script-specific handling — Sorani's extra letters, Persian *taʿārof*, Hijri/Jalālī calendars, the sacred glyph fonts — the relevant file flags it with a **localization note** or an **adab note**.

**Tagline:** *A quiet niche that keeps your Quran whole.*

---

## Philosophy

Mihrab is built on the conviction that an app holding the Quran is an act of *adab* before it is a product, and must behave like one. The muṣḥaf is sacred: it is rendered page-faithfully through bundled glyph fonts and never reflowed, decorated, gamified, or trivialized. The interface is calm and adult — a low-arousal palette, generous space, a book-like reader with no dashboard — because it is opened daily by someone carrying a heavy trust, and it should lower arousal, not farm engagement. Tradition is the visible surface: the day looks like *sabaq / sabqi / manzil* that a teacher recognizes, while the spaced-repetition math stays invisible underneath. Nothing decays silently — the retention heat-map makes the invisible visible, and the app is forbidden from ever telling a ḥāfiẓ a page is "safe to drop." Privacy is structural and meant to be *felt*: no account, no microphone, works in airplane mode forever. The three languages are first-class RTL citizens with correct numerals, calendars, and Arabic-script type — never a bolted-on mode. And the app is a servant to the teacher: *talaqqī* and the *sanad* chain are respected; the app aids oral correction, never claims authority over it. Reverence, calm, honesty, and privacy are the product.

---

## The seven pillars

Every file in this system traces its decisions back to these seven pillars. Each carries the single strongest piece of evidence behind it; the full evidence base lives in [REFERENCES.md](REFERENCES.md) and the per-file `## References` sections.

### 1. Reverence first (adab)

The muṣḥaf is sacred; it is rendered faithfully and never decorated, gamified, or trivialized. The strongest evidence that page-faithful rendering is the right unit of reverence *and* the right unit of memory is the production of the muṣḥaf itself: the KFGQPC / QPC fonts are **604 per-page glyph fonts in which each glyph is a whole word**, mapped through the Private Use Area and rendered without the OS shaper, so a digital page is the exact typeset image of the printed page, line-for-line ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)). This is why the app *never* lets the OS lay out Quran text, never reflows a page, and draws every weak-line or mutashābihāt marker as an overlay on the immutable glyph layer rather than re-typesetting (PRD R1, §11.2). Adab is intent-and-presentation, not device-gating. See [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md) and [04-typography.md](04-typography.md).

### 2. Calm, not cute

Low-arousal, no streaks/badges/confetti/guilt — peace of mind, not engagement farming. This is not taste; it is the central finding of color-emotion research: emotional arousal is driven primarily by saturation (upward) and brightness, not hue, with the published regression putting saturation as the dominant arousal driver ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)). And the case against gamifying worship is empirical: a meta-analysis of 128 experiments found tangible extrinsic rewards reliably *undermine* free-choice intrinsic motivation (the overjustification effect), while only informational positive feedback enhances it ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)). A daily ritual carrying spiritual weight should measurably lower arousal — so no mascots, no confetti, no exclamation marks in product copy, no saturated full-screen color, and no streaks-as-pressure anywhere. See [03-color-and-themes.md](03-color-and-themes.md), [06-motion-and-haptics.md](06-motion-and-haptics.md), and the calm-technology lineage in [01-design-principles.md](01-design-principles.md).

### 3. Tradition is the interface

The day looks like *sabaq / sabqi / manzil* a teacher recognizes; the algorithm is invisible. The evidence is that the most-admired Quran UIs are clutter-free and book-like rather than dashboard-like: the award-winning Ayah app (Kuwait International Prize) is praised for "a clean, intuitive interface… without any visual clutter" that presents "the noble Quran itself with no dashboard," mimicking a physical muṣḥaf ([Ayah — Quran App, App Store](https://apps.apple.com/us/app/ayah-quran-app/id706037876)). Tradition wins on the surface; the FSRS-style scheduler is demoted to a silent page-selector inside a fixed-shape traditional day (PRD §2, §7). Users pick a *named cycle* ("7-Manzil weekly khatm," "1 juz/day"), never a "retention slider." See [01-design-principles.md](01-design-principles.md) and [07-components.md](07-components.md).

### 4. Honest about decay

Nothing silently rots; the retention heat-map makes the invisible visible; the app never implies a page is "safe to drop." The strongest design evidence is the documented harm of the wrong color rhetoric: the rainbow/jet colormap introduces perceptual artifacts and false boundaries and is "still considered harmful," so a sequential single-hue lightness ramp is the honest encoding ([Borland & Taylor, 2007](https://doi.org/10.1109/MCG.2007.323435)). Decay is therefore shown as green *receding* to a muted neutral — never as an alarming red scoreboard — with juz health rolled up by a **min-leaning** aggregate (one weak page is what fails you in ṣalāh), and every cell redundantly encoded (color + number + label) so it never relies on color alone (PRD §10.3, §18; [WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/)). The heat-map informs; it never becomes a streak. See [08-data-visualization.md](08-data-visualization.md) and [03-color-and-themes.md](03-color-and-themes.md).

### 5. Private & offline by feel

No account, on-device, works in airplane mode — trust is structural *and* perceptible. The strongest evidence is the cautionary record of this exact market: the Muslim Pro location-data scandal, in which data on tens of millions of users reached the US military through brokers, shows that privacy is existential, not cosmetic, for an Islamic app ([Cox, 2020, Vice/Motherboard](https://www.vice.com/en/article/muslim-pro-location-data-military-xmode/)). Hifz Companion answers this structurally — no microphone, no telemetry, no accounts, network used only for a one-time checksum-verified asset download — and the UI must make that guarantee *felt*: no sync spinners, no account nags, plain-language privacy framing, and "we never record audio / never charge" stated at onboarding (PRD §17, R5). See [10-privacy-and-trust-ux.md](10-privacy-and-trust-ux.md).

### 6. RTL-native & multilingual

fa/ckb/ar are first-class, not a bolted-on mode; correct numerals, calendars, and Arabic-script type. The strongest evidence is that legibility is governed by familiarity — "you read best what you read most" — so the UI must use the letterform skeletons these readers see every day, and the sacred text must keep its long-familiar muṣḥaf forms ([Nedeljković et al., 2020, *J. Eye Movement Research*](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/)). Consequences: `Directionality.rtl` app-wide with logical (start/end) insets; bidi isolation (FSI/PDI) for mixed Latin/numeric runs; locale numerals (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar); Hijri / Solar-Hijri-Jalālī / Gregorian calendars; and a bundled Perso-Arabic UI font whose **Sorani glyph coverage (پ چ ژ ڤ ک گ ڕ ڵ ۆ ێ ە ھ) is CI-verified** before locking (PRD §13). See [12-localization-and-rtl.md](12-localization-and-rtl.md) and [04-typography.md](04-typography.md).

### 7. Servant to the teacher

*Talaqqī* and the *sanad* chain are respected; the app aids, never replaces, oral correction. The strongest design lever for this voice is the science of reactance: controlling, commanding language provokes psychological reactance and can boomerang, whereas autonomy-supportive, empathetic framing persuades without backfiring ([Miller et al., 2007, *Human Communication Research*](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)). So a teacher sign-off always overrides the machine, the app issues no fiqh rulings and stays madhhab/sect-neutral, and copy consistently frames the tool as an aid to revision — never an authority over the *qārī* or the teacher (PRD R6, §8.2). See [11-voice-and-tone.md](11-voice-and-tone.md) and [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md).

---

## Two rules that outrank everything

These appear in every file that touches the Quran or its presentation, and no design decision may soften them:

1. **The Quran text is never re-typeset, reflowed, or altered for any visual goal.** It is rendered only through the bundled per-page glyph fonts, with fixed line and page breaks from the bundled layout data; every highlight, marker, zoom, or theme is a transformation of *coordinates over the immutable glyph layer*, never an edit to text or layout. A single wrong or dropped diacritic ends the project ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based); PRD R1). The muṣḥaf in use is always stated as "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf," never as "the Quran" in the absolute.
2. **Nothing is ever framed as "safe to drop," and worship is never gamified.** No leaderboards, XP, badges on ayāt, confetti, or guilt/fear nags; progress is a calm, non-shaming retention heat-map, and notifications are neutral ("Your revision for today is ready"), never "You'll lose your hifz" ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627); PRD R3, C6).

---

## File index

| File | What it covers |
|---|---|
| [README.md](README.md) | This file: the name, philosophy, seven pillars, index, token discipline, citation policy, status. |
| [01-design-principles.md](01-design-principles.md) | The design principles (calm technology, tradition-as-interface, honesty about decay) and the research grounding each. |
| [02-material-and-platform-foundations.md](02-material-and-platform-foundations.md) | Material 3 + Flutter foundations: `ColorScheme.fromSeed`, tone-based surfaces, elevation, adaptive iOS/Android behavior, `useMaterial3`. |
| [03-color-and-themes.md](03-color-and-themes.md) | Color tokens (owns all `color.*` values): the calm green-anchored palette, light/sepia/dark themes, heat-map ramp, contrast audit. |
| [04-typography.md](04-typography.md) | Type system (owns all `type.*` values): the bundled Perso-Arabic UI font, sizing/line-height for Arabic script, and the strict separation of UI type from sacred QPC glyph fonts. |
| [05-layout-spacing-touch.md](05-layout-spacing-touch.md) | Spacing scale (owns all `space.*` values), grid, RTL logical insets, 48dp touch targets, recite/grade ergonomics, screen templates. |
| [06-motion-and-haptics.md](06-motion-and-haptics.md) | Motion and haptic tokens (owns all `motion.*` and `haptic.*` values): M3 easing/durations, restraint (no celebratory motion), Reduce Motion. |
| [07-components.md](07-components.md) | The component library: today list, recite-flow, track chips, decay indicators, sign-off controls — anatomy, states, accessibility, science notes. |
| [08-data-visualization.md](08-data-visualization.md) | The whole-Quran retention heat-map and uncertainty: single-hue ramp, VSUP-style muting, min-leaning juz roll-up, redundant encoding, never-a-scoreboard. |
| [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md) | WCAG 2.2 targets, screen-reader semantics per locale, Dynamic/text scaling, low-vision Quran zoom, color-independence, release checklist. |
| [10-privacy-and-trust-ux.md](10-privacy-and-trust-ux.md) | Trust as a design material: privacy communication, no-mic/no-account framing, honest one-time-download UX, verifiability (reproducible builds / F-Droid). |
| [11-voice-and-tone.md](11-voice-and-tone.md) | Voice, tone-by-context matrix, non-coercive notification copy, adab in wording, and transcreation (not literal translation) across fa/ar/ckb. |
| [12-localization-and-rtl.md](12-localization-and-rtl.md) | RTL architecture: logical layout direction, mirroring policy, bidi isolation, locale numerals, Hijri/Jalālī/Gregorian calendars, term-set switching. |
| [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md) | Islamic identity and adab: riwāyah statement, sacred-vs-UI distinction, servant-to-the-teacher framing, what we will never do to the muṣḥaf. |
| [REFERENCES.md](REFERENCES.md) | Master bibliography: every source, what it informed, and where it is used. |
| [research/](research/) | The underlying research dossiers (ten tracks) the numbered files distill from. |

---

## Token discipline

Semantic tokens are referenced by **name** everywhere, but each concrete value is **owned by exactly one file**. If a file does not own a token family, it cites the name and links to the owner — never a raw value. This keeps a palette change, a type-ramp change, a spacing retune, or a motion change a one-file edit. (The sacred QPC glyph fonts are *not* tokens — they are immutable bundled assets governed by Pillar 1 and PRD R1, and are referenced, never restyled.)

| Token family | Examples | Values live only in |
|---|---|---|
| `color.*` | `color.bg.primary`, `color.surface.container`, `color.accent.green`, `color.heatmap.strong` … `color.heatmap.faded`, `color.semantic.warning`, `color.text.primary` | [03-color-and-themes.md](03-color-and-themes.md) |
| `type.*` | `type.display`, `type.title`, `type.body`, `type.label`, `type.caption`, `type.numeral` (UI type only; never the muṣḥaf) | [04-typography.md](04-typography.md) |
| `space.*` | `space.1` through `space.8` (4dp scale), `touch.min` (48dp) | [05-layout-spacing-touch.md](05-layout-spacing-touch.md) |
| `motion.*`, `haptic.*` | `motion.duration.short/medium/long`, `motion.curve.standard/emphasized`, the restrained haptic vocabulary | [06-motion-and-haptics.md](06-motion-and-haptics.md) |

---

## Citation convention

Mihrab forbids uncited "best practice" claims. Every significant design decision carries an inline citation, following the convention in [`../_DOC-SET-BLUEPRINT.md` §2](../_DOC-SET-BLUEPRINT.md) exactly:

- **Research:** `([Author et al., Year](url))` — a peer-reviewed paper or primary study.
- **Platform / standards:** `([Material 3: Page](url))`, `([Flutter: Page](url))`, `([WCAG 2.2](url))`, `([Unicode/W3C: …](url))`.
- **Religious / traditional:** an identifiable scholarly or traditional source by name; for any hadith, the collection and number with grading where relevant. The app **surfaces methodology and never issues a fiqh ruling**, and stays madhhab/sect-neutral.

Citations **must be real and web-verified** — never fabricated. A claim that cannot be sourced is rewritten as an explicit assumption ("Assumption (uncited): …") or removed. Each numbered file ends with a `## References` section listing only the sources it cites; [REFERENCES.md](REFERENCES.md) is the deduplicated, annotated master. Evidence for this area is graded as **design-system** per blueprint §3 (HCI/perception/typography/behavioral research and platform guidance).

---

## Status

**Version 0.1 (draft) — June 2026.**

- Targets Flutter on iOS and Android, Material 3 (`useMaterial3`) with adaptive platform behavior, RTL-first.
- Covers the complete app as specified in [`../PRD.md`](../PRD.md): the muṣḥaf-page revision scheduler, recite/grade flow, mutashābihāt trainer, immutable muṣḥaf reader, retention heat-map, local multi-profile, onboarding, settings, and backup.
- Languages: Persian (fa), Kurdish Sorani (ckb), Arabic (ar) — all RTL. Sorani glyph coverage and the regional *sabaq/sabqi/manzil* terminology await native-speaker and scholarly review (PRD §13.4, §21).
- The app name "Hifz Companion" and the design-system name "Mihrab" are working titles; if the project picks a final name, update the READMEs.
- Maintained alongside app releases; breaking token changes bump the minor version and are noted here.

---

## References

- Borland, D., & Taylor, R. M., II. (2007). Rainbow Color Map (Still) Considered Harmful. *IEEE Computer Graphics and Applications*, 27(2), 14–17. https://doi.org/10.1109/MCG.2007.323435
- Cox, J. (2020). How the U.S. Military Buys Location Data from Ordinary Apps / Muslim Pro Stops Sharing Location Data After Motherboard Investigation. *Vice (Motherboard)*. https://www.vice.com/en/article/muslim-pro-location-data-military-xmode/
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation. *Psychological Bulletin*, 125(6), 627–668. https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- Miller, C. H., Lane, L. T., Deatrick, L. M., Young, A. M., & Potts, K. A. (2007). Psychological Reactance and Promotional Health Messages: The Effects of Controlling Language, Lexical Concreteness, and the Restoration of Freedom. *Human Communication Research*, 33(2), 219–240. https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x
- Nedeljković, U., Jovančić, K., & Pušnik, N. (2020). You read best what you read most: An eye tracking study. *Journal of Eye Movement Research*, 13(2). https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/
- Quranic Universal Library (QUL), Tarteel. *Glyph-Based Fonts* (604 per-page KFGQPC/QPC fonts; each glyph a whole word; renders without OS shaping). https://qul.tarteel.ai/docs/glyph-based
- Valdez, P., & Mehrabian, A. (1994). Effects of color on emotions. *Journal of Experimental Psychology: General*, 123(4), 394–409. https://psycnet.apa.org/record/1995-08699-001
- W3C (2023, updated 2024). Web Content Accessibility Guidelines (WCAG) 2.2 — W3C Recommendation (SC 1.4.1 Use of Color; SC 1.4.11 Non-text Contrast). https://www.w3.org/TR/WCAG22/
- Ayah — Quran App (Abdullah Bajaber). App Store listing (Kuwait International Prize; "no visual clutter," "no dashboard," mimics a physical muṣḥaf). https://apps.apple.com/us/app/ayah-quran-app/id706037876
