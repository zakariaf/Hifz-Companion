# Design-System — References (master bibliography)

> The deduplicated, graded master bibliography for the **design-system** doc set. Every source cited anywhere in `docs/design-system/` (the README, the numbered synthesis docs `01`–`13`, and the `research/` dossiers) appears here exactly once, with full bibliographic detail and a short note on **what it informed**. Each numbered doc carries its own `## References` listing only what it cites; this file is the single auditable union. Citations are real and web-verified — see the authoring contract in [`_DOC-SET-BLUEPRINT.md`](../_DOC-SET-BLUEPRINT.md) §2.
>
> **Grade legend.** Empirical/research sources carry a science-style grade so the reader can weigh them at a glance: `[MA]` meta-analysis / systematic review · `[EXP]` controlled experiment · `[TEXT]` textbook / expert review / foundational essay · `[TRAD]` traditional or scholarly Islamic source · `[PEER]` peer-reviewed HCI paper · `[REPORTING]` investigative journalism · `[INDUSTRY]` product / practitioner evidence · `[PLATFORM]` official platform spec, API, or package docs (primary) · `[ORTHOGRAPHY]` script / typography / i18n reference. Preference among empirical evidence: MA > EXP > TEXT (per the blueprint §3).

---

## 1. Memory, motivation & behavioural science

These ground the calm, non-gamified, non-coercive stance (principles `01`, motion `06`, voice & tone `11`, privacy/trust `10`) — the evidence that streaks, badges, and quantification can **harm** the very engagement they chase.

- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). *A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation.* **Psychological Bulletin, 125**(6), 627–668. https://doi.org/10.1037/0033-2909.125.6.627 — **[MA]** 128 experiments; tangible rewards reliably undermine free-choice intrinsic motivation while positive feedback enhances it. *Informed:* the refusal to put XP/badges/rewards on recitation; verbal/positive framing over extrinsic tokens (principles `01`, voice & tone `11`).
- Ryan, R. M., & Deci, E. L. (2000). *Self-Determination Theory and the Facilitation of Intrinsic Motivation, Social Development, and Well-Being.* **American Psychologist, 55**(1), 68–78. https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf — **[TEXT]** Autonomy, competence, and relatedness as the basis of durable motivation. *Informed:* designing for autonomy (named cycles, not coercion) rather than engagement farming (principles `01`, privacy/trust `10`).
- Etkin, J. (2016). *The Hidden Cost of Personal Quantification.* **Journal of Consumer Research, 42**(6), 967–984. https://doi.org/10.1093/jcr/ucv095 — **[EXP]** Six experiments: measuring an activity reduces its enjoyment and intrinsic motivation. *Informed:* keeping counts/metrics quiet, framing progress as calm loss-prevention not a scoreboard (principles `01`, data-visualization `08`).

---

## 2. Calm & non-intrusive design

The "calm, not cute" pillar — technology that informs without demanding attention (principles `01`, motion & haptics `06`, components `07`).

- Weiser, M., & Brown, J. S. (1996). *The Coming Age of Calm Technology.* Xerox PARC; repr. in *Beyond Calculation: The Next Fifty Years of Computing* (Springer, 1997). https://calmtech.com/papers/coming-age-calm-technology — **[TEXT]** The founding essay on calm technology: design that moves between the centre and periphery of attention. *Informed:* notifications, motion, and the heat-map as ambient (peripheral) rather than attention-grabbing.
- Case, A. (2015). *Calm Technology: Principles and Patterns for Non-Intrusive Design.* O'Reilly Media (see also *Principles of Calm Technology*). https://calmtech.com/ — **[TEXT]** Operational principles: technology should require the smallest amount of attention; communicate without speaking. *Informed:* the low-arousal component and motion vocabulary; "amplify the smallest signal."

---

## 3. Islamic-app design, HCI & ethics

The peer-reviewed and practitioner evidence on designing for Muslim users — autonomy over monetization, adab, and the harms of paywalling/surveilling worship (principles `01`, privacy/trust `10`, Islamic identity & adab `13`).

- Kabir, M., Kabir, M. R., & Islam, R. S. (2025). *Islamic Lifestyle Applications: Meeting the Spiritual Needs of Modern Muslims.* **International Journal of Human–Computer Interaction.** https://doi.org/10.1080/10447318.2025.2595545 (preprint: arXiv:2402.02061 [cs.HC], https://arxiv.org/abs/2402.02061) — **[PEER]** 11 apps analysed via self-determination theory + technology-as-experience, plus 10 user interviews; users report discomfort with paywalls/ads and apps that fail to support autonomy, competence, and relatedness. *Informed:* the free-as-ṣadaqah stance, no-paywall/no-ads commitment, and designing for the three SDT needs (principles `01`, privacy/trust `10`).
- *Decoding Islamic HCI: What Current Patterns Reveal About Future Possibilities* (2026). In **Proceedings of the 2026 CHI Conference on Human Factors in Computing Systems (CHI '26).** ACM. https://dl.acm.org/doi/10.1145/3772318.3791954 — **[PEER]** Scoping review of 268 papers (2006–2025) plus interviews; argues Islamic HCI introduces a distinct value system grounded in Islamic epistemology, not a localization of secular norms. *Informed:* treating reverence/adab as a first-class design value rather than decoration (Islamic identity & adab `13`, principles `01`).
- *Ayah — Quran App* (Abdullah Bajaber). Apple App Store listing. https://apps.apple.com/us/app/ayah-quran-app/id706037876 — **[INDUSTRY]** Kuwait International Prize–recognized reader praised for a clean interface "without any visual clutter," "no dashboard," that mimics a physical muṣḥaf. *Informed:* the no-dashboard, reader-first information architecture (components `07`, principles `01`).
- *Quran Foundation / Quran.com.* https://quran.foundation/ — **[INDUSTRY]** Free, ad-free US 501(c)(3); usage framed explicitly as *Sadaqah Jariyah*. *Informed:* the free/charitable positioning and trust framing (privacy/trust `10`, Islamic identity & adab `13`).
- *Tarteel — AI Quran Memorization.* Apple App Store listing & reviews. https://apps.apple.com/us/app/tarteel-ai-quran-memorization/id1391009396 — **[INDUSTRY]** Streaks, heat-maps, badges, and "hasanat" counters; reviewers note a human teacher "provides accountability that streaks and badges can only imitate." *Informed:* the explicit anti-pattern catalogue — what we will **not** copy (principles `01`, data-visualization `08`, voice & tone `11`).
- *Muslim Pro Stops Sharing Location Data After Motherboard Investigation* (2020). **Vice / Motherboard.** https://www.vice.com/en/article/muslim-pro-location-data-military-xmode/ — **[REPORTING]** Location data sold via X-Mode and onward to the US military, triggering reputational damage and uninstalls. *Informed:* the structural privacy stance — no telemetry, no accounts, offline by construction (privacy/trust `10`).

---

## 4. Traditional muṣḥaf craft, adab & Islamic visual identity

Sources that anchor reverent rendering, the etiquette of the digital muṣḥaf, and the green/sacred visual language (color & themes `03`, Islamic identity & adab `13`).

- *Uthman Taha.* Wikipedia. https://en.wikipedia.org/wiki/Uthman_Taha — **[TRAD]** The calligrapher who hand-wrote the Madani muṣḥaf for the King Fahd Complex (ijāza in calligraphy; 200M+ copies distributed; ~3 years per copy). *Informed:* why the muṣḥaf is rendered faithfully and never re-typeset or decorated (Islamic identity & adab `13`, typography `04`).
- *Green in Islam.* Wikipedia. https://en.wikipedia.org/wiki/Green_in_Islam — **[TRAD]** Green as the color of Islam and of the garments/cushions of paradise (Qurʾān 18:31, 76:21, 55:76). *Informed:* the green seed/accent and the "keep your Quran green" heat-map metaphor (color & themes `03`, data-visualization `08`).
- *Can You Read the Qurʾān Online Without Wudu? Islamic Etiquette in the Digital Age.* Alhannah / Halal Living blog. https://blog.alhannah.com/can-you-read-the-quran-online-without-wudu-understanding-islamic-etiquette-in-the-digital-age/ — **[TRAD]** Contemporary fatāwā on screen vs physical muṣḥaf and recommended adab. *Informed:* reverent reader copy and adab cues (Islamic identity & adab `13`).
- *Do You Need Wudu for the Quran?* Mizanul Muslimin (2025). https://www.mizanulmuslimin.com/2025/03/do-you-need-wudu-for-quran.html — **[TRAD]** Qurʾān 56:79; pixels are not physical ink, so wudu is recommended as respect (not obligation), and recitation from memory needs no wudu. *Informed:* the recite-from-memory flow and non-prescriptive adab framing (Islamic identity & adab `13`, voice & tone `11`).

---

## 5. Quran rendering, mushaf fonts & layout (glyph-based)

The primary documentation behind immutable, glyph-font, per-page rendering and the "mushaf mode = photographic memory" rationale (typography `04`, components `07`, Islamic identity & adab `13`).

- *Glyph-Based Fonts.* Quranic Universal Library (QUL), Tarteel. https://qul.tarteel.ai/docs/glyph-based — **[PLATFORM]** 604 per-page KFGQPC/QPC fonts where each glyph is a whole word; handcrafted for Quranic manuscripts. *Informed:* the locked per-page glyph-font rendering rule (typography `04`).
- *Integrating Quran Font Rendering.* Quran Foundation developer docs. https://api-docs.quran.foundation/docs/tutorials/fonts/font-rendering/ — **[PLATFORM]** Per-page QCF/QPC font-rendering tutorial. *Informed:* the implementation pattern for selecting one font per page (typography `04`).
- *Mushaf Mode: Read the Quran in familiar Mushaf pages.* Greentech Apps Foundation. https://gtaf.org/blog/mushaf-mode-in-quran-app/ — **[INDUSTRY]** Fixed-layout pages build positional/photographic memory; used by huffaz; free charity app with 10M+ downloads. *Informed:* the fixed-layout, never-reflow reader and its memory rationale (components `07`, principles `01`).
- *QuranSheikh — Quran Memorization Techniques & Hifz Revision Schedule.* https://www.quransheikh.com/quran-memorization-techniques/ — **[INDUSTRY]** The 15-line Madani page as a complete unit; one fixed print builds positional/photographic memory; overly heavy revision tables and pile-ups named as failure modes. *Informed:* the page-as-unit visual model and the "no overwhelming pile" stance (components `07`, data-visualization `08`).

---

## 6. Color, contrast & reading comfort

Evidence for sepia/dark themes and reading-comfort defaults (color & themes `03`, accessibility `09`).

- *How to read Quran in night/dark mode.* Greentech Apps Foundation support. https://gtaf.org/support/how-to-read-quran-in-night-dark-mode/ — **[INDUSTRY]** Dark theme as a standard reading-comfort feature in mainstream Quran apps. *Informed:* light/sepia/dark as first-class reader themes (color & themes `03`).
- *Is sepia mode essential?* a11y-blog.dev (Digital Accessibility). https://a11y-blog.dev/en/articles/is-sepia-mode-essential/ — **[INDUSTRY]** Sepia/beige backgrounds suit many readers (including astigmatism) better than stark black-on-white contrast. *Informed:* the sepia default and the contrast strategy for long reading (color & themes `03`, accessibility `09`).

---

## 7. Material Design 3 (platform spec — primary)

The design-token foundation: color roles, surfaces, elevation, type scale, motion, RTL, and touch targets (Material foundations `02`, color `03`, typography `04`, layout/spacing/touch `05`, motion `06`, localization & RTL `12`, accessibility `09`).

- *Material Design 3 — Color roles.* https://m3.material.io/styles/color/roles — **[PLATFORM]** Five key colors; 13-tone tonal palettes; the "apply roles, not static values" rule; on-color pairings. *Informed:* the `color.*` token map and role-based theming (color & themes `03`).
- *Material Design 3 — Introducing Tone-based Surfaces in Material 3.* https://m3.material.io/blog/tone-based-surface-color-m3 — **[PLATFORM]** The `surfaceContainer` ladder replacing surface tint; intent to remove surface tint. *Informed:* surface/elevation tokens and the move off `surfaceTint` (color `03`, components `07`).
- *Material Design 3 — Elevation tokens.* https://m3.material.io/styles/elevation/tokens — **[PLATFORM]** Levels 0–5 = 0/1/3/6/8/12 dp; shadow vs tonal elevation; per-component conventions. *Informed:* the elevation scale and component conventions (components `07`).
- *Material Design 3 — Typography.* https://m3.material.io/styles/typography — **[PLATFORM]** Display/Headline/Title/Body/Label × Large/Medium/Small; type-scale tokens. *Informed:* the `type.*` scale (typography `04`).
- *Material Design 3 — Easing and duration tokens & specs.* https://m3.material.io/styles/motion/easing-and-duration/tokens-specs — **[PLATFORM]** Standard/emphasized easing and the duration ladder. *Informed:* the `motion.*` tokens (motion & haptics `06`).
- *Material Design 3 — Bidirectionality & RTL.* https://m3.material.io/foundations/layout/bidirectionality-rtl — **[PLATFORM]** Mirroring rules; NavigationBar and directional icons switch sides while spacing/height stay constant. *Informed:* the RTL-native layout and icon-mirroring rules (localization & RTL `12`, layout `05`).
- *material-components/material-components-android — Issue #1279* (why 48×48 dp touch targets). https://github.com/material-components/material-components-android/issues/1279 — **[PLATFORM]** The 48 dp (~9 mm) target rationale; WCAG 2.5.5 (AAA, ≥44 px) / 2.5.8 (AA, ≥24 dp). *Informed:* the minimum touch-target tokens for the daily recite/grade flow (layout/spacing/touch `05`, accessibility `09`).

---

## 8. Flutter & Dart (platform API / package — primary)

How the M3 tokens above are realized in the Flutter codebase: theming, dynamic color, adaptive widgets, motion, and offline-bundled fonts (Material foundations `02`, color `03`, typography `04`, motion `06`, components `07`).

- *ColorScheme class.* Flutter API. https://api.flutter.dev/flutter/material/ColorScheme-class.html — **[PLATFORM]** M3 color roles; deprecated `background`/`onBackground`/`surfaceVariant`; surface containers. *Informed:* the concrete `ColorScheme` token bindings (color `03`).
- *ColorScheme.fromSeed constructor.* Flutter API. https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html — **[PLATFORM]** Tonal palettes from a seed; `dynamicSchemeVariant` (tonalSpot); `contrastLevel`. *Informed:* generating the green-seeded scheme and contrast handling (color `03`, accessibility `09`).
- *Migrate to Material 3.* Flutter docs. https://docs.flutter.dev/release/breaking-changes/material-3-migration — **[PLATFORM]** `useMaterial3` true by default since 3.16; NavigationBar/NavigationDrawer/SegmentedButton; FilledButton; surfaceTint; Typography 2021. *Informed:* the baseline M3 component choices (components `07`, Material foundations `02`).
- *Typography.material2021.* Flutter API. https://api.flutter.dev/flutter/material/Typography/Typography.material2021.html — **[PLATFORM]** M3 2021 defaults (englishLike/dense/tall 2021); uniform `onSurface` coloring. *Informed:* the type-theme baseline and RTL "tall" geometry (typography `04`).
- *Durations class.* Flutter API. https://api.flutter.dev/flutter/material/Durations-class.html — **[PLATFORM]** short1–4 (50/100/150/200 ms); medium (250–400); long (450–600); extralong (700–1000 ms). *Informed:* the named duration tokens (motion & haptics `06`).
- *Curves.easeInOutCubicEmphasized constant.* Flutter API. https://api.flutter.dev/flutter/animation/Curves/easeInOutCubicEmphasized-constant.html — **[PLATFORM]** The emphasized ThreePointCubic control-point values. *Informed:* the emphasized-easing token (motion `06`).
- *ThemeExtension class.* Flutter API. https://api.flutter.dev/flutter/material/ThemeExtension-class.html — **[PLATFORM]** Custom theme additions with required `copyWith`/`lerp`; `Theme.of(context).extension<T>()`. *Informed:* how app-specific tokens (sepia palette, heat-map ramp) are attached to the theme (color `03`, data-visualization `08`).
- *Adaptive & responsive design.* Flutter docs. https://docs.flutter.dev/ui/adaptive-responsive — **[PLATFORM]** `.adaptive` constructors (Switch/Slider/CircularProgressIndicator/AlertDialog); `Theme.of(context).platform`; `defaultTargetPlatform`; responsive vs adaptive. *Informed:* the iOS/Android adaptation policy (components `07`, Material foundations `02`).
- *flutter/flutter — Issue #94821: Material 3 iOS Adaptations.* https://github.com/flutter/flutter/issues/94821 — **[PLATFORM]** Which Material widgets adapt to iOS; automatic vs opt-in philosophy. *Informed:* the decision of which widgets to adapt vs keep uniform (components `07`).
- *flutter/flutter — packages/flutter/lib/src/animation/curves.dart.* https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/animation/curves.dart — **[PLATFORM]** Legacy standard/accelerate/decelerate easing and the M3 `Easing` replacements. *Informed:* mapping legacy curves to the M3 motion tokens (motion `06`).
- *dynamic_color package.* pub.dev. https://pub.dev/packages/dynamic_color — **[PLATFORM]** `DynamicColorBuilder`/`CorePalette`; Android API ≥31, with `ColorScheme.fromSeed` fallback on iOS/older Android. *Informed:* the decision to keep a fixed green identity vs optional dynamic color (color `03`).
- *google_fonts package.* pub.dev. https://pub.dev/packages/google_fonts — **[PLATFORM]** Bundle fonts as assets for offline/instant load; set `GoogleFonts.config.allowRuntimeFetching = false` for production. *Informed:* the offline-bundled UI-font rule — no runtime font CDN fetch (typography `04`, localization & RTL `12`).

---

## 9. Arabic / Persian / Kurdish script, typography & i18n

Orthography, codepoints, and font coverage for the three RTL UI languages — fa, ar, and especially Sorani Kurdish (typography `04`, localization & RTL `12`).

- *Vazirmatn* (Saber Rastikerdar). GitHub: rastikerdar/vazirmatn. https://github.com/rastikerdar/vazirmatn — **[ORTHOGRAPHY]** Persian/Arabic variable font; 9 weights; SIL OFL 1.1; Non-Latin build. *Informed:* the bundled UI font for fa/ar (typography `04`).
- *Central Kurdish.* Wikipedia. https://en.wikipedia.org/wiki/Central_Kurdish — **[ORTHOGRAPHY]** Vazirmatn (from ~v27) supports Persian, Arabic, Azerbaijani, Kurdish, Pashto, Urdu, Gilaki, Uzbek, Kazakh, and Balochi. *Informed:* the verification that one font can cover fa/ar/ckb (typography `04`, localization & RTL `12`).
- *Kurdish alphabets.* Wikipedia. https://en.wikipedia.org/wiki/Kurdish_alphabets — **[ORTHOGRAPHY]** The Central Kurdish (Sorani) Arabic-based alphabet with a Unicode codepoint table; vowels treated as letters; the Kurdistan Region uses ک (U+06A9) not ك (U+0643). *Informed:* correct keh/kaf codepoints and vowel handling in ckb strings (localization & RTL `12`).
- *Kurdish typography.* Wikipedia. https://en.wikipedia.org/wiki/Kurdish_typography — **[ORTHOGRAPHY]** The 33-letter Sorani set; unique letters ڕ ڵ ۆ ێ ە پ چ ژ گ ڤ; non-standard U+200C from bad conversions; the Teh-Marbuta-for-AE substitution pitfall. *Informed:* the Sorani glyph-coverage checklist and conversion pitfalls to test for (typography `04`, localization & RTL `12`).
- Ishida, R. *Sorani (Central Kurdish, ckb) orthography notes.* W3C i18n / r12a. https://r12a.github.io/scripts/arab/ckb.html — **[ORTHOGRAPHY]** Extra letters with codepoints; U+06D5 (AE) over heh+ZWNJ; U+06BE vs U+0647 heh ambiguity; cursive joining behaviour. *Informed:* the canonical-codepoint and joining rules for ckb text rendering (localization & RTL `12`).
- *x11-fonts/vazirmatn.* FreshPorts. https://www.freshports.org/x11-fonts/vazirmatn — **[ORTHOGRAPHY]** Packaging record for the Vazirmatn font family. *Informed:* corroborating font versioning/licensing for the bundled UI font (typography `04`).

---

## Status

Living document. Updated whenever a design-system doc adds or removes a source. All URLs verified to resolve and all authors/years/venues confirmed against the source at the cited URL; no citation is fabricated (per [`_DOC-SET-BLUEPRINT.md`](../_DOC-SET-BLUEPRINT.md) §2). Where a source is awaiting deeper scholarly review (Sorani terminology, adab fatāwā), the citing doc flags it inline.
