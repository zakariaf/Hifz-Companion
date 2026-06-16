# The Science Foundation of Hifz Companion

This directory is the **scientific source of truth** for Hifz Companion. Every claim the app makes to a ḥāfiẓ — that memory decays, that spacing review beats cramming, that reciting from memory strengthens a page more than re-reading it, that similar verses (*mutashābihāt*) confuse through interference rather than decay, that near-100% retention comes from overlearning and the cycle ceiling rather than a magic number — must trace to a graded, web-verified source documented here. The relationship is strict and one-directional: a verified primary source becomes a graded claim in a synthesis doc, which is registered in [`CLAIMS.md`](CLAIMS.md), which governs both the engine's behavior and the words shown on screen. The in-app **"The science we follow"** screen renders directly from `CLAIMS.md`, so a fabricated or wrong citation here ships straight to users and breaks the app's core promise: that this is an honest, trustworthy companion for the most serious work a Muslim can undertake. Because the work is *ṣadaqah jāriyah*, the standard is *iḥsān* — excellence — not "good enough because it is free."

```
Verified primary source  →  graded claim in a synthesis doc  →  CLAIMS.md register entry  →  engine rule + on-screen copy  →  "The science we follow" screen
```

---

## Non-negotiable values (the science pillars)

These six values govern every file in this foundation. Each is stated plainly and backed by the single strongest real, web-verified citation; the synthesis docs and `CLAIMS.md` carry the fuller evidence.

### 1. Every in-app factual claim is cited and graded

No number, rule, or piece of educational copy ships unsourced. The chain above is enforced by [`CLAIMS.md`](CLAIMS.md): if a claim is not in that register with at least one verified source and a grade, the app must not state it. Where the app *simplifies* the literature (e.g., a single power-law decay constant, a default retention target), the doc says so explicitly — *"the app uses X; the literature shows X–Y"* — and never hides that a value is a simplification. **Strongest evidence:** decay itself, the premise everything else answers to, is a reproducible empirical regularity — Ebbinghaus's 1885 forgetting curve was reproduced 130 years later in an independent subject and language ([Murre & Dros, 2015, *PLOS ONE*](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) **[EXP]**.

### 2. Memory science is the engine's foundation

The scheduler is not folk wisdom dressed in code; its backbone is the spacing effect, retrieval practice, interference, and overlearning. The single most load-bearing of these is **spacing** — reviewing on a distributed schedule, and at intervals that grow as material strengthens, produces durable retention far beyond massing. **Strongest evidence:** the definitive quantitative synthesis of 839 assessments across 317 experiments found that distributed practice reliably beats massed practice and that the optimal inter-study interval *expands with the desired retention interval* — the mathematical license for a maintained juz moving from daily to weekly to monthly review ([Cepeda et al., 2006, *Psychological Bulletin*](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**.

### 3. Tradition is validated, not replaced

The classical *sabaq / sabqi / manzil* workflow is not overruled by the algorithm — the science shows the masters arrived empirically at the same expanding-interval, retrieval-based scheduling the engine formalizes. We surface that **convergence**, keeping tradition on the visible surface and the math invisible. **Strongest evidence:** reciting *from memory* (retrieval), which is exactly what *murājaʿa* and *talaqqī* demand, produces substantially more durable retention than re-studying — a meta-analytic effect across 61 experiments (g ≈ 0.50, larger for free recall) ([Rowland, 2014, *Psychological Bulletin*](https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect)) **[MA]**.

### 4. Religious and methodology claims are sourced and carefully scoped

Every traditional or scholarly Islamic claim names an identifiable source (a named book, author, or site; for any hadith, the collection, number, and grading). The app **surfaces methodology, never issues a fiqh ruling**, and stays madhhab- and sect-neutral; where a claim needs a scholar's sign-off, the doc says so plainly. **Strongest evidence:** the decay axiom the whole product answers to is itself prophetic — *"the Qur'an slips away faster than camels escaping their tying ropes"* ([Ṣaḥīḥ al-Bukhārī 5032](https://sunnah.com/bukhari:5032)) **[TRAD]** — cited with collection and number, never paraphrased as a ruling.

### 5. Honest about uncertainty — no promise of perfect retention

We cannot promise that no page will ever slip. Near-100% retention is delivered by **overlearning to automaticity plus the cycle ceiling** (every page guaranteed re-recited within the chosen cycle), *not* by a fragile probability target. The app never tells a ḥāfiẓ a page is "safe to drop," and never chases a literal 0.99 global retention, whose cost curve explodes and breaks trust faster than an occasional stumble does. **Strongest evidence:** deeply over-learned material reaches a decades-long "permastore" plateau, but it is reached by *depth and spacing over time*, and the curve still slopes — never reaching zero loss ([Bahrick, 1984, *J. Exp. Psychol.: General*](https://pubmed.ncbi.nlm.nih.gov/6242406/)) **[OBS]**.

### 6. Non-coercive motivation — never gamify worship, never weaponize guilt

The evidence is *against* streaks, badges, leaderboards, and guilt-based nags for sacred, intrinsically-motivated work. Controlling external rewards reliably undermine the very intrinsic motivation that sustains *ḥifẓ*, so the app frames its value as calm loss-prevention and peace of mind. **Strongest evidence:** a meta-analysis of 128 experiments found that tangible, expected rewards significantly undermine intrinsic motivation for an activity ([Deci, Koestner & Ryan, 1999, *Psychological Bulletin*](https://home.ubalt.edu/tmitch/642/articles%20syllabus/Deci%20Koestner%20Ryan%20meta%20IM%20psy%20bull%2099.pdf)) **[MA]**.

---

## Rules that outrank everything

Two rules sit above every other consideration in this foundation. They override convenience, engagement, and visual polish, and no contributor may relax them.

1. **Nothing decays silently; never "safe to drop."** The forgetting curve always slopes downward, so the engine may only ever pull a page *forward* (more frequent), never push it past its cycle ceiling, and is forbidden from displaying or implying that any memorized page is finished with revision (PRD §7.6, §7.12). This is the "never silently lose the Quran" promise, encoded. Every claim and feature is checked against it.

2. **Honesty outranks reassurance; tradition and the teacher outrank the algorithm.** Where the evidence is uncertain, the docs say so rather than inventing confidence; where the app simplifies, it admits it. A teacher's *talaqqī* sign-off always supersedes self-rating and any algorithmic state (PRD §8.2, R6). The app is a servant to the *sanad* chain, never an authority over it — it aids oral correction, it does not replace it.

---

## Index of the science foundation

| File | What it covers |
|------|----------------|
| [`README.md`](README.md) | This file — the science pillars, outranking rules, citation convention, grade legend, index, and status. |
| [`01-memory-and-forgetting.md`](01-memory-and-forgetting.md) | The forgetting curve, savings-on-relearning, consolidation, and the permastore plateau — why decay is the premise of the whole product. |
| [`02-the-spacing-effect.md`](02-the-spacing-effect.md) | Distributed vs. massed practice, expanding intervals, and the optimal gap that grows with retention interval — the basis for cycle presets. |
| [`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md) | Leitner, SM-2, SuperMemo two-component models, and the FSRS DSR power-law engine the scheduler is built on. |
| [`04-retrieval-practice-and-self-testing.md`](04-retrieval-practice-and-self-testing.md) | The testing effect — why reciting from memory beats re-reading, and how the reveal-on-tap recite flow operationalizes it. |
| [`05-interference-and-mutashabihat.md`](05-interference-and-mutashabihat.md) | Why similar-verse confusion is interference (not decay), and why interleaved discrimination — not spacing — is the cure. |
| [`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md) | Overlearning, automaticity, successive relearning, and how near-100% retention is honestly achieved and bounded. |
| [`07-serial-recall-and-the-page-unit.md`](07-serial-recall-and-the-page-unit.md) | Chunking and serial recall — why the muṣḥaf *page* is the scheduled unit, recited in flow, not atomized into verse-cards. |
| [`08-sleep-consolidation-and-scheduling.md`](08-sleep-consolidation-and-scheduling.md) | Sleep-dependent consolidation — why the engine schedules in whole days and honors a once-daily revision rhythm. |
| [`09-motivation-without-coercion.md`](09-motivation-without-coercion.md) | Habit formation without streaks, self-determination theory, and the evidence against gamifying worship. |
| [`10-traditional-hifz-methodology.md`](10-traditional-hifz-methodology.md) | Sabaq/sabqi/manzil, the seven manāzil weekly khatm, and the convergence of classical method with modern memory science. |
| [`11-the-in-app-science-screen.md`](11-the-in-app-science-screen.md) | Spec for the user-facing "The science we follow" screen, which renders from `CLAIMS.md`. |
| [`CLAIMS.md`](CLAIMS.md) | **The load-bearing claims register:** every user-facing factual claim → value/rule → source → grade → app surface. The in-app science screen renders from this file. No claim ships without ≥1 verified source. |
| [`REFERENCES.md`](REFERENCES.md) | The deduplicated, graded master bibliography for the entire science foundation. |
| [`research/`](research/) | The deep evidence dossiers (forgetting-curve, spacing-effect, spaced-repetition-algorithms, retrieval-practice, interference-theory, overlearning-automaticity, serial-recall-chunking, sleep-and-consolidation, motivation-habit-noncoercive, hifz-methodology-evidence, quran-memorization-research) that each synthesis doc distills. |

---

## Citation convention

This foundation follows the citation rules defined once in [`../_DOC-SET-BLUEPRINT.md`](../_DOC-SET-BLUEPRINT.md) §2 — read it before authoring or editing any file here. In brief:

- Every significant claim carries an **inline citation** in the form `([Author et al., Year](url))` followed by its grade tag, e.g. `([Cepeda et al., 2006](url)) [MA]`.
- **Citations must be real and web-verified.** Each author, year, venue, and URL is confirmed against PubMed, a DOI/publisher page, or an authoritative scholarly source before it ships. We **never** fabricate a citation, DOI, author list, or URL.
- If a claim cannot be sourced, it is rewritten as an explicit assumption (*"Assumption (uncited): …"*) or removed — never kept as an uncited "best practice."
- Each synthesis doc ends with a `## References` section listing only the sources it cites; [`REFERENCES.md`](REFERENCES.md) is the deduplicated, graded master.
- **Religious content** cites identifiable scholarly/traditional sources by name; for any hadith, the collection and number are given with grading where relevant. The app presents **no rulings** and flags "needs scholarly review" where appropriate (PRD §4, §21).

### Evidence-grade legend

Per blueprint §3. Preference among empirical grades: **MA > RCT / EXP > CS > OBS > TEXT**. Methodology and religious claims are **[TRAD]** and must name the source.

| Grade | Meaning |
|-------|---------|
| **[MA]** | Meta-analysis or systematic review |
| **[RCT]** | Randomized controlled experiment |
| **[EXP]** | Controlled cognitive experiment |
| **[CS]** | Classic foundational study that shaped the field |
| **[OBS]** | Observational, applied, or field study |
| **[TEXT]** | Textbook or expert review |
| **[TRAD]** | Traditional or scholarly Islamic source (named) |

A grade describes the *strength of the evidence behind a claim*, kept separate from the *certainty* the app expresses to the user. The in-app "The science we follow" screen translates these grades into plain, calm language naming the source, because most users cannot vet raw citations themselves; we do the curation and attribute each claim to a named, dated source.

---

## Status

- **Version:** v1.0
- **Date:** June 2026
- **State:** Initial complete science foundation for the Hifz Companion release. Eleven deep research dossiers (`research/`) compiled and individually source-verified; synthesis docs and `CLAIMS.md` distill them into the engine rules and on-screen copy.
- **Verification:** All cited sources are real and were verified against PubMed, DOI/publisher pages, primary PDFs, or — for hadith — Sunnah.com / HadeethEnc with collection, number, and grading.
- **Maintenance:** Corrections and updates are submitted as issues against the open-source repository and versioned with the app. Religious and *mutashābihāt* content awaits named scholarly sign-off (PRD §21); until then, copy stays framed as an aid to revision and a servant to the teacher.

---

## References

Only sources cited in this file are listed here. Each synthesis doc carries its own full reference list; the master bibliography is in [`REFERENCES.md`](REFERENCES.md).

- Bahrick, H. P. (1984). *Semantic memory content in permastore: Fifty years of memory for Spanish learned in school.* Journal of Experimental Psychology: General, 113(1), 1–29. https://pubmed.ncbi.nlm.nih.gov/6242406/ — **[OBS]**
- Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2006). *Distributed practice in verbal recall tasks: A review and quantitative synthesis.* Psychological Bulletin, 132(3), 354–380. https://www.yorku.ca/ncepeda/publications/CPVWR2006.html — **[MA]**
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). *A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation.* Psychological Bulletin, 125(6), 627–668. https://home.ubalt.edu/tmitch/642/articles%20syllabus/Deci%20Koestner%20Ryan%20meta%20IM%20psy%20bull%2099.pdf — **[MA]**
- Murre, J. M. J., & Dros, J. (2015). *Replication and analysis of Ebbinghaus' forgetting curve.* PLOS ONE, 10(7), e0120644. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644 — **[EXP]**
- Rowland, C. A. (2014). *The effect of testing versus restudy on retention: A meta-analytic review of the testing effect.* Psychological Bulletin, 140(6), 1432–1463. https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect — **[MA]**
- Ṣaḥīḥ al-Bukhārī 5032 (ʿAbdullāh ibn Masʿūd), Book 66, Ḥadīth 54: the Qur'an escapes the memory faster than camels from their tethers. Sunnah.com. https://sunnah.com/bukhari:5032 — **[TRAD]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
