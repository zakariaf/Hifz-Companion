# The In-App "The Science We Follow" Screen

This file specifies the user-facing **"The science we follow"** screen — the one place in Hifz Companion where the app shows a ḥāfiẓ, in calm plain language, *why* it schedules the way it does and *what evidence* stands behind each claim. Every other science doc establishes a finding; this doc establishes how those findings reach the user honestly. The screen does not contain its own facts: it **renders the [`CLAIMS.md`](CLAIMS.md) register** — the load-bearing index where every user-facing factual claim is mapped to a value/rule, a named source, an evidence grade, and an app surface ([README.md](README.md)). The chain the whole foundation enforces ends here: *verified source → graded claim in a synthesis doc → `CLAIMS.md` entry → engine rule + on-screen copy → this screen.* Because the app is fully offline (PRD C1) and uses no AI (PRD C2), the screen is **a static, bundled, read-only view** — no network call, no model, no live fetch — so the science travels with the app into airplane mode forever. The design problem this doc solves is threefold: present graded scientific claims in language a non-specialist can trust without vetting raw citations (the *plain-language* problem), name and date every source so the screen is a trust signal rather than marketing (the *transparency* problem), and do both without coercion, hype, or any promise the evidence cannot keep (the *honesty* problem). For the claims this screen surfaces, see the sibling docs it draws from: [01-memory-and-forgetting.md](01-memory-and-forgetting.md), [02-the-spacing-effect.md](02-the-spacing-effect.md), [03-spaced-repetition-algorithms.md](03-spaced-repetition-algorithms.md), [04-retrieval-practice-and-self-testing.md](04-retrieval-practice-and-self-testing.md), [05-interference-and-mutashabihat.md](05-interference-and-mutashabihat.md), [06-overlearning-and-lifelong-retention.md](06-overlearning-and-lifelong-retention.md), [09-motivation-without-coercion.md](09-motivation-without-coercion.md), and [10-traditional-hifz-methodology.md](10-traditional-hifz-methodology.md).

> **Evidence grades (best → weakest):** **[MA]** meta-analysis/systematic review · **[RCT]** randomized experiment · **[EXP]** controlled cognitive experiment · **[CS]** classic foundational study · **[OBS]** observational/applied/field study · **[TEXT]** textbook/expert review · **[TRAD]** traditional/scholarly Islamic source. Prefer MA > RCT/EXP > CS > OBS > TEXT; methodology/religious claims are **[TRAD]** and name the source.

> **Rules that bind this screen.** It is **a faithful renderer of [`CLAIMS.md`](CLAIMS.md), never an independent author** — no claim appears here that is not in the register with ≥1 verified source and a grade. It ships **fully offline** (PRD C1): bundled, static, no network, no AI. It states the science **calmly and without coercion** (PRD C6, R3): it never sells, never promises perfect retention, never weaponizes decay into a threat. And it stays **madhhab- and sect-neutral**, surfacing methodology but **issuing no fiqh ruling** (PRD §4, blueprint §1 science value 4).

---

## At a glance

| The screen's design rule | Why (evidence) | Grade |
|---|---|---|
| Render the CLAIMS register, never invent on-screen facts | Foundation chain: no claim ships unsourced ([README.md](README.md); blueprint §2) | — |
| Ship bundled, static, offline — no network, no AI | PRD C1/C2; offline integrity (PRD §11.1.1, §17) | — |
| Write every claim in plain, common words for a non-specialist | Federal Plain Language Guidelines: write for your audience, use common words, active voice | [TEXT] |
| Name and date every source on-screen, with its grade | Source transparency raises perceived credibility and trust | [OBS] |
| Translate evidence grades into honest confidence language, never a star rating | Honesty value: grade ≠ certainty ([README.md](README.md); blueprint §3) | — |
| Never promise a retention percentage; near-100% comes from the cycle ceiling, not a number | Permastore curve still slopes; cost curve explodes near 1.0 (Bahrick 1984) | [OBS] |
| Present the science calmly — no streaks, guilt, hype, or persuasion machinery | Coercive framing undermines intrinsic motivation and backfires (Deci/Koestner/Ryan 1999; Peng et al. 2023) | [MA] |
| Meet WCAG 2.2 AA: contrast, resizable text, reflow, never color-only | WCAG 2.2 SC 1.4.1/1.4.3/1.4.4/1.4.10 (W3C Recommendation, Dec 2024) | [TEXT] |
| Keep religious claims sourced by name/number, issuing no ruling | Blueprint §2; PRD §4, R2 | [TRAD] |

---

## 1. The screen renders the CLAIMS register — it is a view, not a source of truth

**Statement.** "The science we follow" is a **read-only projection of [`CLAIMS.md`](CLAIMS.md)**. It contains no fact that is not already a registered, graded, sourced claim. This is not a stylistic choice; it is the structural guarantee that what the app *tells* a ḥāfiẓ is exactly what the app's engine *does*, and that both trace to verified evidence. A claim that is wrong here is wrong in the engine and wrong on screen — so the single point of authorship is the register, and the screen merely formats it.

**Evidence.**
- The science foundation enforces a strict one-directional chain: *verified primary source → graded claim in a synthesis doc → `CLAIMS.md` register entry → engine rule + on-screen copy → this screen*; "if a claim is not in that register with at least one verified source and a grade, the app must not state it" ([README.md](README.md), science value 1; [blueprint §2](_DOC-SET-BLUEPRINT.md)). [TRAD-equivalent project rule — not an empirical claim.]
- `CLAIMS.md` is defined as the register of **every user-facing factual claim**, with columns for the claim as the app states it, the value/rule the engine uses, the inline-cited source(s), the grade, and the app surface ([blueprint §4d](_DOC-SET-BLUEPRINT.md)). The science screen is named as the surface that "renders from this file" ([README.md](README.md) file index).

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| One source of authorship | The screen reads claim text, value/rule, source citation, and grade **from the bundled `CLAIMS.md` data**; copywriters edit the register, never the screen in isolation, so the two can never drift. |
| Claim ↔ surface back-links | Each entry names its **app surface** (e.g. the recite flow, the heat-map, the catch-up banner); the screen can link a claim to where it acts, so the user sees the science *and* where it lives. |
| No orphan facts | If a string on any screen makes a factual claim not in the register, that is a release-blocking defect — the register, not the screen, is the gate (consistent with PRD §20 release gates). |

**Anti-patterns — we will never:**
- Hand-write a scientific claim directly into the screen that is not a registered, sourced, graded entry in `CLAIMS.md`.
- Let the on-screen wording of a claim diverge from the value/rule the engine actually uses for it.

---

## 2. It ships fully offline — bundled, static, no network, no AI

**Statement.** The science screen and all the sources it shows are **bundled in the app and rendered locally**. It makes no network request, runs no model, and fetches nothing live. The science is part of the app's offline payload, available in airplane mode the same as the muṣḥaf itself.

**Evidence.**
- The app is offline after setup: "no backend we operate, no accounts, no live services, no per-user data ever leaves the device," and after the one-time asset download it "works fully offline, forever (airplane mode)" (PRD C1, §17).
- The app uses **no AI / no ML** anywhere (PRD C2): the screen cannot, and must not, generate explanations on the fly from a model — every word is pre-written, reviewed, and bundled.
- Quran and reference assets arrive as **checksum-verified, versioned packs** and the app "refuses to render … from any unverified asset" (PRD §11.1.1); the CLAIMS data and its rendered copy are part of the same auditable, versioned, bundled payload.

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| Static bundled data | The `CLAIMS.md`-derived content (claim copy, source citations, grades, plain-language confidence labels) ships **inside the app binary or the verified core pack**, never as a live feed. |
| Source links degrade gracefully | Citations show the full reference **as readable text on-device** (author, year, title, venue) so they are useful with no connection; a tappable URL is an *optional* convenience that simply does nothing offline — the citation never depends on the network to be trustworthy. |
| Versioned with the app | Corrections to claims or sources ship as an **app/pack update** (per [README.md](README.md) maintenance), not a silent remote edit — the user can trust that the science is fixed at a known, auditable version. |

**Anti-patterns — we will never:**
- Fetch claim text, citations, or "latest research" from a server at runtime, or render any part of this screen from an AI model.
- Hide a citation behind a link that is meaningless offline; the full reference is always present as on-device text.

---

## 3. Every claim is written in plain, common words — for a ḥāfiẓ, not a cognitive scientist

**Statement.** The screen states each claim in the plainest accurate language: common words, short sentences, active voice, and the user's own frame of reference (revising the Quran), reserving technical terms only where a term is itself the point. The user should understand *what the app believes and why* without a psychology degree — and without being condescended to.

**Evidence.**
- The U.S. Federal Plain Language Guidelines, the canonical public-sector standard, define plain language as writing that is "clear, concise, well-organized," and prescribe **writing for your audience, using common everyday words, the active voice, personal pronouns, and easy-to-read structure (bullets, tables)** ([Federal Plain Language Guidelines, plainlanguage.gov / digital.gov](https://digital.gov/guides/plain-language)) [TEXT]. The same guidance is adopted for health communication, where the audience is non-specialist and the stakes of misunderstanding are high ([plainlanguage.gov, Plain Language in Healthcare](https://www.plainlanguage.gov/resources/content-types/healthcare/)) [TEXT].
- This translation step is *required by the foundation itself*: the screen "translates these grades into plain, calm language naming the source, because most users cannot vet raw citations themselves; we do the curation" ([README.md](README.md), evidence-grade legend).

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| Two-layer copy per claim | Each entry shows a **plain headline** ("Reciting from memory protects your hifz more than re-reading it") with an optional **"the evidence" expansion** carrying the named study and grade — common words first, detail on demand. |
| The user's frame, not the lab's | Copy speaks in *murājaʿa*, pages, juz, and revision — not "free-recall paradigm" or "stability parameter"; technical terms (FSRS, retrievability) appear only with a one-line plain gloss, and only where the term is genuinely informative. |
| Structure for scanning | Claims are **grouped by theme** (memory & forgetting, spacing, retrieval, interference, overlearning, methodology, motivation) and laid out as short cards with bullets — the readable design the guidelines call for, and the grouping `CLAIMS.md` already uses ([blueprint §4d](_DOC-SET-BLUEPRINT.md)). |
| Localized, RTL-native | All copy is fully translated into fa / ckb / ar as RTL string resources (PRD §13), so "plain language" means plain *in the user's language*, with correct numerals and bidi isolation for any Latin source names. |

**Anti-patterns — we will never:**
- Surface raw academic jargon (effect sizes, parameter names, paradigm labels) as the primary, unglossed text of a claim.
- Write the screen in English-first prose that is merely translated word-for-word; each locale gets genuinely plain, idiomatic copy, scholar/native-reviewed where terminology is religious (PRD §13.4, §21).

---

## 4. Every claim names and dates its source, with its grade visible — transparency is the trust

**Statement.** Beside each claim the screen shows **who found it, when, and how strong the evidence is** — a named, dated source and its grade tag — because for a sacred, high-trust task the user must be able to see that a claim is attributed scholarship, not the app's opinion. We do the citation curation the user cannot, and we show our work.

**Evidence.**
- Transparency about sources measurably raises perceived credibility: disclosing sources and making attribution clear "helps to build perceptions of integrity and benevolence" and improves judgments of an organization's competence and trustworthiness; transparency comprises **disclosure, accuracy, and clarity** ([American Press Institute, *Building credibility through transparency*](https://americanpressinstitute.org/transparency-credibility/)) [OBS]. Studies of transparency cues find that clear attribution and disclosed reporting material account for a substantial share of readers' trust decisions ([Otis, 2024, *Journalism*, transparency-cue study](https://journals.sagepub.com/doi/10.1177/14648849221129001)) [OBS].
- The foundation's own citation convention requires that every significant claim carry an inline, real, web-verified citation, and that **religious claims name an identifiable source** (for hadith, the collection and number with grading) ([blueprint §2](_DOC-SET-BLUEPRINT.md)). The screen is where that convention becomes visible to the user.

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| Source on the face of every claim | Each claim card shows the **author(s), year, venue**, and the **grade tag** from `CLAIMS.md` (e.g. *Cepeda et al., 2006 — meta-analysis*), not just a vague "studies show." |
| Grade legend, in plain words | A short, always-reachable legend explains the grades calmly: a meta-analysis pools many studies; an experiment is a single controlled test; a traditional source is named scholarship — never a marketing "★★★★★." |
| Religious claims sourced by name and number | Any traditional claim (e.g. the decay ḥadīth, *Ṣaḥīḥ al-Bukhārī 5032*) is shown **with collection, number, and grading**, framed as methodology, never as a ruling (PRD §4; [blueprint §2](_DOC-SET-BLUEPRINT.md)). |
| Honest "simplification" notes | Where the app simplifies the literature (a single decay constant, a default retention target), the screen says so — *"the app uses X; the research shows X–Y"* — per the foundation's no-hidden-simplification rule ([README.md](README.md), science value 1). |

**Anti-patterns — we will never:**
- Show a claim as "scientifically proven" or "studies show" without a named, dated, graded source the user can read on-device.
- Present a religious or methodology claim as a fiqh ruling, or strip a hadith of its collection, number, and grading.

---

## 5. Grades become honest confidence language — strength of evidence, never a promise of certainty

**Statement.** The screen renders each grade as **plain confidence about the evidence**, kept strictly separate from any certainty about *your* Quran. A meta-analysis is described as strong, well-replicated evidence; an observational or traditional source is described honestly as weaker or as named scholarship. The screen never converts a high grade into a guarantee, and never lets the user mistake "strong evidence for spacing in general" for "this page is safe."

**Evidence.**
- The foundation states the principle directly: "A grade describes the *strength of the evidence behind a claim*, kept separate from the *certainty* the app expresses to the user" ([README.md](README.md), evidence-grade legend). [Project rule.]
- Honesty about uncertainty is a non-negotiable value: "We cannot promise that no page will ever slip. Near-100% retention is delivered by overlearning to automaticity plus the cycle ceiling … not by a fragile probability target" ([README.md](README.md), science value 5) — grounded in the permastore finding that deeply over-learned material plateaus for decades but the curve **still slopes and never reaches zero loss** ([Bahrick, 1984, *J. Exp. Psychol.: General*](https://pubmed.ncbi.nlm.nih.gov/6242406/)) [OBS].

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| Confidence words, not certainty words | Copy says "this is among the best-established findings in memory science" for an [MA] claim, and "this is a single controlled study" or "this is traditional scholarship, named below" for weaker grades — describing the *evidence*, never the user's outcome. |
| No retention-percentage promise | The screen **never** states a guaranteed retention figure; it explains that durable retention comes from the **cycle ceiling** (every page re-recited within the chosen cycle, PRD §7.6) and overlearning, not a number — matching PRD §7.5 and science value 5. |
| Uncertainty stated, not hidden | Where the engine's constants are priors fitted from the user's own history (PRD §7.3), the screen says so plainly: the math is a starting estimate; the *guarantee* is structural, not statistical. |

**Anti-patterns — we will never:**
- Render a grade as a star rating, a "proven" badge, or a confidence percentage about the user's retention.
- Promise that any page, juz, or cycle will be remembered perfectly, or imply that strong general evidence makes an individual page "safe to drop" (PRD §7.12).

---

## 6. The science is presented calmly and without coercion — explanation, not persuasion

**Statement.** This screen explains; it does not sell, nag, or frighten. It uses no streaks, badges, urgency, or guilt to make the science "land." A single honest, sourced line does the work, because the evidence shows coercive framing undermines the very devotional motivation that brings a ḥāfiẓ to revise — and because gamifying or guilt-tripping the science of worship breaches *adab*.

**Evidence.**
- Controlling, contingent rewards reliably **undermine** intrinsic motivation across 128 experiments ([Deci, Koestner & Ryan, 1999, *Psychological Bulletin*](https://home.ubalt.edu/tmitch/642/articles%20syllabus/Deci%20Koestner%20Ryan%20meta%20IM%20psy%20bull%2099.pdf)) [MA], so the science screen must not become one more surface that turns revision into reward-chasing (see [09-motivation-without-coercion.md](09-motivation-without-coercion.md)).
- Guilt appeals that **attribute blame** persuade *less* and trigger reactance (meta-analysis, g = 0.19, with blame-framing weaker still) ([Peng et al., 2023, *Frontiers in Psychology*](https://pmc.ncbi.nlm.nih.gov/articles/PMC10568480/)) [MA] — so explaining decay must never tip into "you'll lose your hifz." The foundation prescribes exactly the constructive line: *"We deliberately avoid streaks, badges, and guilt: the research shows they don't build lasting habits and can undermine the very motivation that brings you to revise"* ([research/motivation-habit-noncoercive.md](research/motivation-habit-noncoercive.md), implication 9).

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| Calm, declarative tone | Claims read as quiet statements of fact ("Memory fades on a predictable curve; spaced revision slows the fade"), never as exclamations, urgency, or fear copy (PRD R3, §2; [blueprint §5](_DOC-SET-BLUEPRINT.md)). |
| The non-coercion principle, stated as a claim | The screen itself carries the motivation finding as a registered claim — that the app **avoids streaks, badges, and guilt on purpose, because the research is against them** — turning a constraint into a visible trust signal (PRD C6, R3; [09-motivation-without-coercion.md](09-motivation-without-coercion.md)). |
| Decay explained, never weaponized | Where the screen explains the forgetting curve (and the decay ḥadīth), it frames it as the honest premise of calm loss-prevention, never as a threat the user has "let happen" (PRD §12.5, R3). |
| No engagement mechanics on the science | No "you've read 5 of 12 science cards" progress bar, no badge for finishing, no reason to return manufactured by loss aversion — the screen is reference, opened when wanted (PRD §0, no engagement KPI). |

**Anti-patterns — we will never:**
- Use urgency, fear, streaks, badges, or guilt to make the science persuasive; explanation is the whole job.
- Frame the forgetting curve or any decay evidence as a threat, a countdown, or a personal failure.

---

## 7. The screen is accessible and RTL-native — reverence and accessibility are the same discipline

**Statement.** The science screen meets the same accessibility and RTL bar as the rest of the app: legible at large text sizes, sufficient contrast, never color-alone, fully reflowing, screen-reader-labeled, and correct in all three RTL locales. A claim no one can read is not transparent. *Iḥsān* applies to the science screen as much as to the muṣḥaf.

**Evidence.**
- WCAG 2.2 (W3C Recommendation, 12 December 2024) sets the relevant criteria: **1.4.1 Use of Color** (color is never the only means of conveying information), **1.4.3 Contrast (Minimum)** (≥ 4.5:1 for normal text, 3:1 for large), **1.4.4 Resize Text** (usable at 200% zoom), and **1.4.10 Reflow** (no loss of content or two-dimensional scrolling on small viewports) ([WCAG 2.2, W3C Recommendation](https://www.w3.org/TR/WCAG22/); [Understanding SC 1.4.1: Use of Color](https://w3c.github.io/wcag/understanding/use-of-color.html)) [TEXT].
- The app's own accessibility requirements echo this: respect OS text-scale, "never rely on color alone (use labels/patterns)," sufficient contrast, semantic labels in each locale, and full RTL correctness (PRD §18, §13.2).

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| Text scale & reflow | Claim copy honors OS text-scale and **reflows** without truncation or horizontal scroll at the largest supported size (WCAG 1.4.4, 1.4.10; PRD §18). |
| Grade never color-only | The evidence grade is conveyed by its **text tag** ("meta-analysis") and an optional icon — **never by color alone** (WCAG 1.4.1; PRD §18) — so a color-blind user reads the grade exactly. |
| Contrast and theming | Text meets ≥ 4.5:1 contrast across light / sepia / dark themes (WCAG 1.4.3; PRD §18, §12.6). |
| Screen-reader & RTL | Every claim card, source, and grade has a **semantic label in the active locale** (PRD §18), and the layout is RTL-native with correct numerals and bidi-isolated Latin source names (PRD §13.2–§13.3). |

**Anti-patterns — we will never:**
- Encode the evidence grade or any meaning in color alone, or ship copy that truncates or breaks at large text sizes.
- Treat the science screen as a "secondary" surface exempt from the RTL, contrast, and screen-reader bar the rest of the app meets.

---

## 8. Honest scope of the screen — what it is, and what it deliberately is not

**Statement.** The screen is a **transparency and trust surface**, not a textbook, not a fatwa, and not a marketing page. It states honestly the limits of what it shows: it curates and grades evidence so the user need not, but it does not pretend the evidence is more certain, more complete, or more religiously authoritative than it is.

**Evidence.**
- The foundation's neutrality rule binds the screen: the app "surfaces methodology, **never issues a fiqh ruling**, and stays madhhab- and sect-neutral," flagging "needs scholarly review" where appropriate ([README.md](README.md), science value 4; PRD §4, §21). The mutashābihāt and religious content await named scholarly sign-off; until then copy stays framed as an aid to revision and a servant to the teacher ([README.md](README.md) status).
- The honesty value requires admitting uncertainty rather than inventing confidence ([README.md](README.md), science value 5; rule 2) — so the screen names where evidence is thin (e.g. very-long-horizon spacing data are under-sampled, per [02-the-spacing-effect.md](02-the-spacing-effect.md)) rather than papering over it.

**In practice.**

| Engine / app behavior | How this rule shapes it |
|---|---|
| Methodology, not rulings | Religious claims appear as **named, sourced methodology** with grading, never as the app's verdict on a disputed matter; the screen defers to the teacher and the *sanad* chain (PRD R6, §8.2). |
| "Needs scholarly review" shown plainly | Where a claim awaits named scholarly sign-off, the screen says so (PRD §21) rather than implying settled authority. |
| Limits named, not hidden | Where the science is genuinely uncertain or the app simplifies, the screen states it (science value 5) — the trust comes from the honesty, not from over-claiming. |
| Pointer to the full record | For users who want more, the screen can point to the open-source repository's `CLAIMS.md` and `REFERENCES.md` (the auditable master record), consistent with the app being open and community-correctable ([README.md](README.md) maintenance). |

**Anti-patterns — we will never:**
- Present the screen as a complete scientific or religious authority, or issue a ruling on a contested matter under the guise of "the science."
- Hide a known limitation of the evidence to make the app look more certain than it is.

---

## References

Only sources cited in this file are listed here. The deduplicated, graded master bibliography is in [REFERENCES.md](REFERENCES.md); the claims this screen renders are registered in [CLAIMS.md](CLAIMS.md).

- American Press Institute. *How publishers should build credibility through transparency.* https://americanpressinstitute.org/transparency-credibility/ — **[OBS]**
- Bahrick, H. P. (1984). *Semantic memory content in permastore: Fifty years of memory for Spanish learned in school.* Journal of Experimental Psychology: General, 113(1), 1–29. https://pubmed.ncbi.nlm.nih.gov/6242406/ — **[OBS]**
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). *A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation.* Psychological Bulletin, 125(6), 627–668. https://home.ubalt.edu/tmitch/642/articles%20syllabus/Deci%20Koestner%20Ryan%20meta%20IM%20psy%20bull%2099.pdf — **[MA]**
- Otis, A. (2024). *The effects of transparency cues on news source credibility online: An investigation of "opinion labels."* Journalism. https://journals.sagepub.com/doi/10.1177/14648849221129001 — **[OBS]**
- Peng, W., Huang, Q., Mao, B., Lun, D., Malova, E., Simmons, J. V., & Carcioppolo, N. (2023). *When guilt works: A comprehensive meta-analysis of guilt appeals.* Frontiers in Psychology, 14, 1201631. https://pmc.ncbi.nlm.nih.gov/articles/PMC10568480/ — **[MA]**
- U.S. General Services Administration / Digital.gov (formerly PlainLanguage.gov). *Federal Plain Language Guidelines / Plain language guide series.* https://digital.gov/guides/plain-language (healthcare guidance: https://www.plainlanguage.gov/resources/content-types/healthcare/) — **[TEXT]**
- W3C. (2024). *Web Content Accessibility Guidelines (WCAG) 2.2.* W3C Recommendation, 12 December 2024. https://www.w3.org/TR/WCAG22/ (Understanding SC 1.4.1 Use of Color: https://w3c.github.io/wcag/understanding/use-of-color.html; Understanding SC 1.4.3 Contrast (Minimum): https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum) — **[TEXT]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
