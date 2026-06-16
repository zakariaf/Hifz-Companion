# Traditional Hifz Methodology — The Tradition Was Spaced Repetition All Along

The classical *sabaq / sabqi / manzil* workflow is not a quaint folk practice the algorithm improves upon; it is a centuries-old, hand-tuned approximation of exactly the memory science the rest of this foundation documents — distributed practice ([`02-the-spacing-effect.md`](02-the-spacing-effect.md)), retrieval from memory ([`04-retrieval-practice-and-self-testing.md`](04-retrieval-practice-and-self-testing.md)), interference management ([`05-interference-and-mutashabihat.md`](05-interference-and-mutashabihat.md)), and overlearning to a lifelong plateau ([`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md)). This document gathers the convergence: the masters arrived empirically at expanding-interval retrieval practice, full-corpus periodic review, and teacher-verified correction long before the experiments confirmed those choices. That is the science foundation's third pillar — **tradition validated, not replaced** — made concrete. The relationship is strict and one-directional: tradition supplies the *visible shape* of the day (named tracks, named cycles, old-before-new), and the FSRS DSR engine in [`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md) is only the *invisible page-selector* inside that fixed shape, allowed to order and pull a weak page forward but never to overrule the cycle ceiling, the teacher, or the *adab* of the *sanad* chain (PRD §7.6, §7.11, §7.12). The detailed evidence dossier behind this doc — with regional schools, the seven manāzil table, and the full hadith provenance — is [`research/hifz-methodology-evidence.md`](research/hifz-methodology-evidence.md); the hifz-specific empirical literature is in [`research/quran-memorization-research.md`](research/quran-memorization-research.md).

> **One sentence:** The classical revision system already *is* spaced repetition — so the engine formalizes it without overruling it, keeping the named tracks and cycles on the surface, the math invisible underneath, and the teacher above both.

## At a glance

| Finding | What it says | Strongest evidence | Grade | Engine consequence (PRD) |
|---|---|---|---|---|
| Three tracks, one lifecycle | Sabaq → sabqi → manzil are stability bands of one card, not three algorithms | IslamicTuition; Expertium FSRS | [TRAD]/[TEXT] | Phase-by-stability; lapse demotes (§6.2, §7.4) |
| Old before new | Revise old first, more time on old than new, pause new to protect the earned | IslamicTuition; Cepeda et al. 2006 | [TRAD]/[MA] | Build day Far → Near → New; throttle new sabaq (§7.8, §7.9) |
| The seven manāzil | A literal "review the whole Quran every 7 days" rota, attributed to Ḥamzah az-Zayyāt | Wikipedia: Manzil | [TRAD] | The 7-manzil weekly cycle preset; cycle ceiling (§7.6, §15.1) |
| Expanding intervals | Tradition stretches mature material — exactly what the spacing meta-analysis recommends | Cepeda et al. 2006 | [MA] | Stability compounding widens gaps automatically (§7.3, §7.4) |
| Murājaʿa is retrieval | Recitation *from memory* is effortful retrieval, not re-reading — the testing effect | Rowland 2014 | [MA] | Reveal-on-tap recite flow; production not recognition (§8.1) |
| The decay axiom | The Qur'an "escapes faster than camels" — forgetting is inevitable without review | Ṣaḥīḥ al-Bukhārī 5032; Muslim 791 | [TRAD] | Nothing decays silently; never "safe to drop" (§7.12) |
| The annual ʿarḍa | Gabriel reviewed the whole Quran with the Prophet ﷺ yearly — a full-corpus ceiling | Ṣaḥīḥ al-Bukhārī 4998 | [TRAD] | The cycle ceiling as a guaranteed maximum interval (§7.6) |
| Talaqqī & the sanad | Oral, teacher-verified transmission is the integrity layer; the human ear is ground truth | Mohamad & Mohamad; Wikipedia: Ijazah | [TRAD] | Teacher sign-off overrides all; no mic, no ASR (§8.2, R6, C2) |
| Structure is universal | Regional schools differ in vocabulary, not in the underlying skeleton | IslamicTuition; HTMTQ; Tarteel | [TRAD] | Labels are swappable string resources (§13.4) |
| Overlearn, then cycle | Near-100% comes from overlearning + guaranteed periodic review, not a magic number | Tarteel: Mauritanian; Bahrick 1984 | [TRAD]/[OBS] | Higher retention floor + cycle ceiling, not a global 0.99 (§7.5, §7.6) |

---

## 1. The three tracks are three phases of one revision lifecycle, not three algorithms

**Statement.** The familiar *sabaq / sabqi / manzil* triad is not three separate systems bolted together; it is one body of memorized material moving through three maturities. A portion enters as new (*sabaq*), consolidates as recent (*sabqi*), matures into the whole-Quran bulk (*manzil*), and — crucially — *demotes back into active revision when it lapses*. That is precisely the life of a single difficulty/stability/retrievability (DSR) card, so the engine models it as one card with a phase derived from stability, not as three queues.

**Evidence.**
- The dominant madrasa workflow structures every day around three named portions: **sabaq** (السبق, the new lesson, typically 3–5 lines/day for a beginner), **sabqi** (سبقي, the recent ~1–3 juzʾ revised daily or alternate-day while still settling), and **manzil / dhor** (منزل / دور, the long-term cycling through everything already memorized, which "risks fading without regular attention") ([IslamicTuition: Sabaq, Sabqi and Manzil](https://islamictuition.us/blog/sabaq-sabqi-manzil-hifz-revision-system/)) **[TRAD]**.
- A page is never assigned to a track permanently: it graduates sabaq → sabqi → manzil as it strengthens and rejoins active revision when forgotten — "a forgotten manzil page rejoins revision" ([Ilmify: Sabak, Sabaq Para, and Dhor](https://ilmify.app/blog/sabak-sabaq-para-dhor-hifz-stages/)) **[TRAD]**.
- This maturity-driven lifecycle is exactly how a DSR model already treats one card across its life: difficulty and stability evolve with each review, and the same item occupies "learning," "young," and "mature" bands over time ([Expertium: FSRS Algorithm](https://expertium.github.io/Algorithm.html)) **[TEXT]**.

**In practice.**

| Tradition | Engine realization (PRD) |
|---|---|
| Sabaq / sabqi / manzil as the user-facing day | Three lifecycle **phases**, distinguished by stability bands `NEAR_MIN_S ≈ 9 d`, `FAR_MIN_S ≈ 60 d` (§6.2, §7.4) |
| "A forgotten manzil page rejoins revision" | A lapse shrinks `S` and naturally demotes the card to an active-revision phase (§7.7) |
| One workflow, not three separate methods | One card type with `phase(card)` computed from `S`; **not** three algorithms (§7.4) |

- Graduation is **age-and-rating driven and predictable**, so a teacher can anticipate it — New → Near also requires *N* sign-offs; Near → Far requires crossing `FAR_MIN_S` and leaving the recent-juz window (PRD §7.4). The named tracks stay the visible surface; the stability band is the invisible mechanism.

**Anti-patterns — we will never:**
- Build three independent schedulers for sabaq, sabqi, and manzil; that fractures the single lifecycle the tradition actually describes.
- Hide graduation as a surprise jump. A teacher can predict when a page graduates or demotes (PRD §7.4).

---

## 2. "Old before new" is the tradition's built-in spacing-and-retrieval discipline

**Statement.** The classical session recites *old material before new*, allocates more time to old than to new, and pauses new memorization entirely once a few ajzāʾ are held — to "protect everything already earned." Read as scheduling, this is distributed practice plus a review-to-new ratio plus a daily-load cap, all enforced by habit. The engine encodes the same discipline in code.

**Evidence.**
- The classical order completes sabqi and manzil *before* the day's sabaq, allocating more time to old than to new; once a student finishes a few ajzāʾ, new memorization is often paused to "protect everything already earned" ([IslamicTuition](https://islamictuition.us/blog/sabaq-sabqi-manzil-hifz-revision-system/); [Ilmify: Muraja'ah in Hifz](https://ilmify.app/blog/what-is-murajaah-quran-revision/)) **[TRAD]**.
- Revising old material on a recurring schedule rather than re-massing the new lesson is precisely the distributed-practice manipulation the definitive synthesis of **839 assessments across 317 experiments** found reliably superior for long-term retention ([Cepeda, Pashler, Vul, Wixted & Rohrer, 2006](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**.
- The "more time on old than new" rule is the empirical ancestor of the commonly stated **~5:1 review-to-new ratio** and of a hard maintenance-load cap — the tradition's defense against new memorization outpacing sustainable revision ([Ilmify](https://ilmify.app/blog/what-is-murajaah-quran-revision/)) **[TRAD]**.

**In practice.**
- `buildToday` assembles the day **Far → Near → New** — old recited before new, exactly the traditional order (PRD §7.8).
- Far/manzil due items are **mandatory** and never silently dropped; new sabaq is added only "if budget remains and yesterday's sabaq is consolidated" — the live-math form of "protect what you've earned" (PRD §7.8, §7.9).
- When projected maintenance load exceeds the daily budget, the load-balancer throttles new memorization rather than letting old pages rot — enforcing the 5:1 wisdom with live arithmetic instead of a fixed ratio (PRD §7.9, §12.2).

**Anti-patterns — we will never:**
- Surface new sabaq before the day's manzil and sabqi are accounted for; old-before-new is the order (PRD §7.8).
- Let new memorization proceed while it would push existing pages past their cycle ceiling (PRD §7.9).

---

## 3. The seven manāzil are a literal "review the whole corpus every 7 days" cycle ceiling

**Statement.** For those completing the Quran weekly, the text is divided into **seven manāzil** — seven portions, one per day. This is not a reading aid; read as scheduling it is a *uniform seven-day cycle ceiling*: every part of the Quran is revisited at least once per week regardless of how strong it feels. It is the traditional ancestor of the engine's trust-clamp.

**Evidence.**
- The Quran is divided into seven manāzil for weekly recitation, a division attributed to the early Kūfan reciter **Ḥamzah az-Zayyāt (d. 156 AH / 772 CE)**; the seven run al-Fātiḥa→an-Nisāʾ, al-Māʾida→at-Tawba, Yūnus→an-Naḥl, al-Isrāʾ→al-Furqān, ash-Shuʿarāʾ→Yā-Sīn, aṣ-Ṣāffāt→al-Ḥujurāt, and Qāf→an-Nās ([Wikipedia: Manzil](https://en.wikipedia.org/wiki/Manzil)) **[TRAD]**.
- The portions are remembered by the mnemonic **"Fa-mī bi-shawqin"** (فمي بشوقٍ), whose seven consonants — F, M, B, Sh, W, Q, N — are the initials of each manzil's opening surah ([Famibisyauqin](https://famibisyauqin.blogspot.com/2016/02/fami-bi-syauqin-mengkhatamkan-al-quran.html)) **[TRAD]**.
- Other common rotas are **30 / 15 / 10-day** khatm cycles (one, two, or three juzʾ per day), with a typical ḥāfiẓ keeping a floor of about **one juzʾ per day** of revision ([IslamicTuition](https://islamictuition.us/blog/sabaq-sabqi-manzil-hifz-revision-system/)) **[TRAD]**.

**In practice.**
- The seven manāzil ship as a named cycle preset — **"7-Manzil weekly khatm"** — alongside 1-juzʾ/day (30-day), ½-juzʾ/day (60-day), and 2-juzʾ/day (15-day) cycles (PRD §15.1).
- The chosen cycle *is* the **cycle ceiling**: `ceiling_due = today + cycle_ceiling_days(card, cycle)`, and every memorized page's `due_at = min(ideal_due, ceiling_due)` — the SR math may pull a page **forward** but never past the ceiling (PRD §7.6). The seven-manzil rota, expressed in code, becomes the "nothing decays silently" guarantee.
- Pure-cycle ("conservative") mode runs the fixed rotation only, with SR ordering and pull-forward switched off — the app becomes a faithful traditional tracker with smart load-balancing and nothing more, for ulama who distrust any reordering (PRD §7.11).

**Anti-patterns — we will never:**
- Let a memorized page's `due_at` exceed the user's chosen cycle ceiling — a hard engine invariant (PRD §7.12).
- Present the seven manāzil as the app's invention; they are named, attributed, and centuries old (and the cycle is a user-selectable preset, not a forced default).

---

## 4. Expanding intervals — what the tradition tunes by hand — is what the spacing science recommends

**Statement.** The tradition tightens revision for fresh material and progressively *stretches* it for mature material: sabqi is revised daily or alternate-day, while manzil is revisited weekly to monthly as it solidifies. This expanding-interval shape is not folklore — it is what the controlled spacing literature independently recommends, and what the engine's stability growth reproduces automatically.

**Evidence.**
- The spacing meta-analysis found that the optimal inter-study interval *grows* as the desired retention interval lengthens — the mathematical license for an old, solid juz moving from daily to weekly to monthly review ([Cepeda et al., 2006](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**.
- FSRS encodes the same dynamic mathematically: each on-time successful review multiplies stability, so the safe interval lengthens on its own, and reviewing when retrievability is *lower* yields a *larger* stability gain — the desirable-difficulty effect ([Expertium: FSRS Algorithm](https://expertium.github.io/Algorithm.html)) **[TEXT]**; the desirable-difficulty mechanism itself is Bjork's storage-vs-retrieval-strength framework ([Bjork & Bjork, 2011](https://www.unh.edu/teaching-learning-resource-hub/sites/default/files/media/2023-06/itow-introducing-desirable-difficulties-into-practice-and-instruction-bjork-and-bjork.pdf)) **[TEXT]**.
- The fuller treatment of expanding vs. uniform schedules — including the finding that what matters most is delaying the *first* review enough to be effortful, not the expanding ladder per se — is in [`02-the-spacing-effect.md`](02-the-spacing-effect.md).

**In practice.**
- Expanding intervals **emerge from the engine, not from a fixed rota**: stability compounding stretches mature material while the math concentrates effort on weak and confusable pages — same total budget, better allocated (PRD §7.3, §7.4, §7.5).
- Because tradition supplies the horizon (the named cycle) and the math supplies the gaps within it, the user never sees a raw "interval" or a "retention slider"; they pick a recognizable cycle and the expanding behavior is invisible underneath (PRD §7.6, §15.1).

**Anti-patterns — we will never:**
- Hard-code one universal interval for all pages regardless of maturity; the tradition itself stretches mature material, and so must we.
- Sell a fixed "1-2-4-7-14" ladder as the scientifically optimal schedule — the evidence does not support that for long-term retention (see [`02-the-spacing-effect.md`](02-the-spacing-effect.md) §5).

---

## 5. Murājaʿa is retrieval practice — recitation from memory, never re-reading

**Statement.** The defining act of revision is *reciting the text from memory*, not re-reading the muṣḥaf. That is effortful retrieval — the testing effect — which strengthens memory far more than passive review. The app's grading flow is built so that a page is *produced* from memory before it is ever revealed.

**Evidence.**
- Reciting *from memory* (retrieval), which is exactly what *murājaʿa* and *talaqqī* demand, produces substantially more durable retention than re-studying — a meta-analytic effect across **61 experiments (g ≈ 0.50, larger for free recall)** ([Rowland, 2014](https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect)) **[MA]**.
- Huffaz themselves rate disciplined *maintenance rehearsal* above meaning-elaboration as the route to durable hifz — "it is maintenance and not elaborative rehearsal that plays the most important role in the memorization of the Quran" ([Dzulkifli, Bin Abdul Rahman, Badi & Solihu, 2016](https://www.richtmann.org/journal/index.php/mjss/article/view/9090)) **[OBS]**.
- The tradition never makes re-reading the muṣḥaf the primary act of revision; it *produces* the text aloud and has a teacher or the reciter judge the output — the full retrieval-practice treatment is in [`04-retrieval-practice-and-self-testing.md`](04-retrieval-practice-and-self-testing.md).

**In practice.**
- The primary recite flow is **reveal-on-tap**: the page is hidden, the user recites *from memory*, then reveals line-by-line and marks where they stumbled — retrieval first, confirmation second (PRD §8.1, §12.2).
- Because the app ships **no tafsīr or translation** (R2), the design coherently centers re-recitation cadence — production retrieval — rather than meaning aids, matching what the methods literature describes huffaz actually doing (PRD §4-R2).

**Anti-patterns — we will never:**
- Make the primary revision act passive re-reading of the visible page; the page is hidden and recited first (PRD §8.1).
- Reframe revision as "study" or "reading" in copy; it is *murājaʿa* — recitation from memory.

---

## 6. The Prophetic warning about forgetting is the tradition's decay axiom

**Statement.** The urgency of *murājaʿa* rests on explicit ḥadīth: memorized Qur'an *decays without active retrieval*. This is the Ebbinghaus forgetting curve stated in seventh-century terms, and it is the doctrinal root of the app's "nothing decays silently" contract. Because forgetting is inevitable, the engine may never tell a ḥāfiẓ a page is finished with revision.

**Evidence.**
- ʿAbdullāh ibn Masʿūd reported the Prophet ﷺ discouraged saying "I forgot such-and-such a verse" — rather one *was caused* to forget it — and urged continuous review, "for it escapes from the hearts of men faster than camels [from their hobbles]" (Ṣaḥīḥ al-Bukhārī 5032, Book 66 Ḥadīth 54) ([Sunnah.com: Bukhari 5032](https://sunnah.com/bukhari:5032)) **[TRAD]**.
- Abū Mūsā al-Ashʿarī reported the Prophet ﷺ said: *"Keep on reciting this Qur'an … the Qur'an slips away from memory faster than camels escaping their tying ropes"* (Ṣaḥīḥ Muslim 791, agreed upon) ([HadeethEnc 5907](https://hadeethenc.com/en/browse/hadith/5907)) **[TRAD]**.
- The decay these aḥādīth describe is an empirically reproducible regularity: Ebbinghaus's 1885 forgetting curve was reproduced 130 years later in an independent subject and language ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) **[EXP]**; the full forgetting-curve treatment is in [`01-memory-and-forgetting.md`](01-memory-and-forgetting.md).

**In practice.**
- The engine is **forbidden** from ever displaying or implying that any memorized page is "safe to drop" or finished with revision — a hard invariant (PRD §7.12).
- The whole-Quran **retention heat-map** makes the invisible decay visible without alarm or shame, so the ḥāfiẓ sees a juz softening *before* it is lost (PRD §12.5).
- The decay axiom is registered as a methodology claim in [`CLAIMS.md`](CLAIMS.md), cited to collection and number, and never paraphrased into a ruling.

**Anti-patterns — we will never:**
- Tell a ḥāfiẓ a page no longer needs revision; the camel ḥadīth is the doctrinal form of "decay never stops" (PRD §7.12).
- Use the forgetting warning to *frighten* — notifications stay calm and supportive, never "you will lose your hifz" (PRD R3, §14).

---

## 7. The annual ʿarḍa is the Prophetic precedent for a full-corpus cycle ceiling

**Statement.** Beyond daily revision, the tradition preserves a precedent for *full-corpus* periodic review: the *ʿarḍa* (عَرْضَة). This is the classical anchor for a guaranteed maximum interval over the *entire* memorized corpus — the conceptual parent of a "cycle ceiling" that no page is allowed to exceed, no matter how solid it feels.

**Evidence.**
- Abū Hurayra reported that **Gabriel (Jibrīl) used to review the Quran with the Prophet ﷺ once every year, and reviewed it twice in the year he passed away** (Ṣaḥīḥ al-Bukhārī 4998, Book 66 Ḥadīth 20) ([Sunnah.com: Bukhari 4998](https://sunnah.com/bukhari:4998)) **[TRAD]**.
- This *al-ʿarḍa al-akhīra* (the final review) is the classical basis for a complete annual or Ramadan run-through of everything one holds — a guaranteed maximum interval over the whole corpus ([Sunnah.com: Bukhari 4998](https://sunnah.com/bukhari:4998)) **[TRAD]**.
- The same logic — that a full pass over everything held should recur on a bounded schedule — is the spacing literature's "the optimal gap grows with the horizon, but a horizon still exists" applied to an entire corpus ([Cepeda et al., 2006](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**.

**In practice.**
- The cycle ceiling generalizes the ʿarḍa: where the seven manāzil guarantee a weekly full pass, the named cycle (7, 15, 30, or 60 days) is the user's chosen maximum interval over the whole Quran, and the trust-clamp enforces it on every page (PRD §7.6).
- The annual/Ramadan full run-through maps to the longest cycle presets and to "khatm-by-Ramadan" goal-setting, framed as calm continuity, never a pressured streak (PRD §15.1, §12.5).

**Anti-patterns — we will never:**
- Treat any page as exempt from the full-corpus cycle because it tests strong; the ʿarḍa reviewed *everything*, and so does the ceiling (PRD §7.6, §7.12).
- Convert the ʿarḍa precedent into a fiqh prescription; it is cited as methodology — a precedent for periodic full review — not as a ruling (blueprint §1, value 4).

---

## 8. Talaqqī and the sanad: the human ear is the authoritative error signal

**Statement.** The Quran is transmitted *talaqqī* — face-to-face, the student receiving from the teacher's recitation and the teacher correcting in real time — certified by an *ijāza* carrying a *sanad* back to the Prophet ﷺ. Correctness is judged by a qualified human ear, not a machine. An app that respects the tradition must let teacher sign-off override everything and must add **no microphone, no ASR, no machine "mistake detection."**

**Evidence.**
- The Quran is transmitted *talaqqī* (تلقّي) and *mushāfaha* (مشافهة) — face-to-face, lip-to-lip — held to descend from the Prophet ﷺ receiving from Gabriel, then to the Companions, in an unbroken chain ([Mohamad & Mohamad: Talaqqi and Musyafahah](https://www.academia.edu/81052538/Concept_and_Execution_of_Talaqqi_and_Musyafahah_Method_in_Learning_Al_Quran)) **[TRAD]**.
- Mastery is certified by an *ijāza* carrying a *sanad / isnād* — a documented chain of teachers reaching back to the Prophet ﷺ ([Wikipedia: Ijazah](https://en.wikipedia.org/wiki/Ijazah)) **[TRAD]**.
- Across the methods literature the error signal in classical practice *is* the teacher flagging a hesitation in *tasmīʿ* (recitation-check); oral correction is treated as central, not optional ([Dzulkifli & Solihu, 2018](https://journals.iium.edu.my/intdiscourse/index.php/islam/article/view/1238)) **[OBS]**.

**In practice.**

| Tradition | Engine realization (PRD) |
|---|---|
| The teacher's correction is ground truth | On-device teacher sign-off, `sourceConfidence = 1.0`, **overrides** self-rating and algorithmic state (§8.2, R6) |
| The teacher flags *where* you hesitated | Stumble *positions* (line indices) captured, richer than a binary grade (§6.3, §8.1) |
| Unverified self-recitation is lower-confidence | Self-rating `sourceConfidence ≈ 0.5`; moves stability less; cannot alone reach the top retention tier (§8.1) |
| No machine arrogates the teacher's role | **No microphone, no ASR, no AI mistake-detection** — a hard constraint and a point of *adab* (§8.3, C2) |

- *Talaqqī* sign-off is recorded in the append-only `review_log` with `source = teacher` — a local audit trail that respects the *sanad* idea without any server (PRD §8.2).

**Anti-patterns — we will never:**
- Add audio recognition or "listen-and-detect-mistakes," even optionally; that would arrogate the teacher's role and break the talaqqī chain (PRD C2, §8.3).
- Let an algorithmic state or self-rating override a teacher's verdict for a page (PRD §7.12, R6).

---

## 9. The same skeleton appears across regional schools — vocabulary varies, structure does not

**Statement.** Independent regional traditions converge on the same expanding-interval, retrieval-and-correction structure under different names. The *structure* — three maturities, expanding intervals, teacher verification, a full-corpus cycle, weak-spot drilling — is universal; the *vocabulary* is regional. Labels must therefore be swappable string resources, never hard-coded, and the app must stay sect-neutral.

**Evidence.**
- **Deobandi / South Asian:** the canonical sabaq / sabqi / manzil (dhor) triad, "old before new," the corpus split into manāzil on a fixed rotation ([IslamicTuition](https://islamictuition.us/blog/sabaq-sabqi-manzil-hifz-revision-system/)) **[TRAD]**.
- **Mauritanian (maḥḍara):** writing the lesson on a wooden *lawḥ*, reciting until memorized, then **repeating 300–500 times** counted on prayer-beads — overlearning before moving on ([Tarteel: The Mauritanian Method](https://tarteel.ai/blog/quran-memorization-techniques-the-mauritanian-method/)) **[TRAD]**; **Ottoman / Turkish-Bosnian "stacking":** memorize one page a day in rounds, "stacking" each new page, with explicit tracks for hard verses, easy verses, and full repetition (*tekrar*) ([HTMTQ: The Ottoman Hifz Method](https://howtomemorisethequran.com/the-ottoman-hifz-method/)) **[TRAD]**.
- The hifz-specific empirical literature confirms the constants vary while the skeleton holds: the headline gap across the field is *maintenance*, and the techniques that recur are talaqqī, structured repetition / spaced murājaʿa, chunking, and multisensory encoding ([Nordin et al., 2023](https://www.pertanika.upm.edu.my/resources/files/Pertanika%20PAPERS/JSSH%20Vol.%2031%20(2)%20Jun.%202023/16%20JSSH-8758-2022.pdf)) **[OBS]**.

**In practice.**
- Every track label, grade verb, and cycle name is a **swappable string resource** (ARB/JSON per locale plus an optional regional override), with region-appropriate default term-sets the user can switch (PRD §13.4).
- The Kurdish (Sorani) and some Persian terms are explicitly flagged as **pending native-speaker and scholarly review** before defaults lock; the architecture makes swapping a term-set trivial (PRD §13.4, §21).
- The app presents methodology and names its sources; it stays madhhab- and sect-neutral and **issues no ruling** about which regional method is "correct" (blueprint §1, value 4; PRD R2).

**Anti-patterns — we will never:**
- Hard-code one region's vocabulary as "the" terminology; the labels are localizable and regionally switchable (PRD §13.4).
- Privilege or disparage any school's method; the app surfaces structure, names sources, and stays neutral (blueprint §5).

---

## 10. Overlearning, then cycling everything, is the tradition's honest path to near-100% retention

**Statement.** The Mauritanian 300–500 repetitions and the Indonesian *tikrār* counts are not superstition; they are **overlearning** — continued practice past the first errorless recall — which yields durable, automatic retrieval. The tradition does not chase a fragile probability target; it *overlearns* the sacred text and then *guarantees periodic review of everything* via the manzil cycle. That is how the app delivers near-100% retention honestly and bounded — through depth plus the ceiling, not a magic number.

**Evidence.**
- The Mauritanian method counts **300–500 repetitions** of the lesson on prayer-beads before moving on — overlearning to automaticity ([Tarteel: The Mauritanian Method](https://tarteel.ai/blog/quran-memorization-techniques-the-mauritanian-method/)) **[TRAD]**; the Indonesian *takrār / tikrār* method uses systematic ordered repetition (often ~40× per portion) before reciting to the teacher ([HTMTQ: The Takrār Method](https://medium.com/how-to-memorise-the-quran/the-takrar-method-of-memorisation-in-madinah-al-munawwarah-schedules-62fe4a8d1179)) **[TRAD]**.
- Deeply over-learned material reaches a decades-long "permastore" plateau — but it is reached by *depth and spacing over time*, and the curve still slopes; it never reaches zero loss ([Bahrick, 1984](https://pubmed.ncbi.nlm.nih.gov/6242406/)) **[OBS]**. The full overlearning treatment is in [`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md).
- Chasing a literal global 0.99 retention is infeasible — it is roughly 11× the daily review load of 0.90 across 604 pages — so rigor must be tiered by stakes, not applied uniformly ([Cepeda et al., 2006](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html) for the spacing-cost foundation; quantified in [`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md)) **[MA]**.

**In practice.**
- Near-100% retention is delivered by **overlearning to automaticity plus the cycle ceiling**, not a brittle global target: ordinary Far pages run a 0.95 retention target, while **prayer-critical, weak, and previously-lapsed pages get a higher floor (0.97+)** (PRD §7.5, §7.6).
- The app **deliberately does not chase a literal 0.99 globally** — the cost curve explodes past the daily budget and breaks trust faster than an occasional stumble (PRD §7.5).
- The app is honest about uncertainty: it never *promises* perfect retention. It says spacing and overlearning retain "far better," never "99%," and the structural guarantee is the ceiling, not a probability claim (science README value 5; [`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md)).

**Anti-patterns — we will never:**
- Promise perfect or "guaranteed 99%" retention; the curve always slopes, and we say so (science README value 5).
- Apply one global retention target to all 604 pages; rigor is tiered by stakes — prayer-critical and weak pages get the higher floor (PRD §7.5).

---

## A note on honesty and the limits of this evidence

The convergence thesis is strong, but its two halves rest on different evidentiary footings, and the doc keeps them separate. The *memory-science* half — spacing, retrieval, overlearning — is graded **[MA]/[EXP]** and drawn from large controlled literatures. The *traditional-methodology* half is graded **[TRAD]**: it documents *what the tradition does* (named in identifiable scholarly and traditional sources, with hadith cited to collection and number) and *why the science says it works* — it never issues a fiqh ruling, ranks one regional method above another, or claims religious authority. The hifz-specific empirical studies that sit between them ([`research/quran-memorization-research.md`](research/quran-memorization-research.md)) are mostly small-n, single-institution, self-selected, and observational; we lean on them only to *illustrate* mechanisms the strong general literature already establishes, never to carry a quantitative claim. And the regional terminology — especially Kurdish (Sorani) and some Persian terms — awaits **native-speaker and scholarly sign-off** before defaults lock (PRD §13.4, §21). The convergence validates the tradition; it does not replace the teacher, and where a claim needs a scholar's review, this foundation says so plainly.

---

## References

Only sources cited in this file are listed here; the deduplicated, graded master is in [`REFERENCES.md`](REFERENCES.md).

- Bahrick, H. P. (1984). *Semantic memory content in permastore: Fifty years of memory for Spanish learned in school.* Journal of Experimental Psychology: General, 113(1), 1–29. https://pubmed.ncbi.nlm.nih.gov/6242406/ — **[OBS]**
- Bjork, E. L., & Bjork, R. A. (2011). *Making things hard on yourself, but in a good way: Creating desirable difficulties to enhance learning.* In *Psychology and the Real World*. https://www.unh.edu/teaching-learning-resource-hub/sites/default/files/media/2023-06/itow-introducing-desirable-difficulties-into-practice-and-instruction-bjork-and-bjork.pdf — **[TEXT]**
- Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2006). *Distributed practice in verbal recall tasks: A review and quantitative synthesis.* Psychological Bulletin, 132(3), 354–380. https://www.yorku.ca/ncepeda/publications/CPVWR2006.html — **[MA]**
- Dzulkifli, M. A., & Solihu, A. K. H. (2018). *Methods of Qur'anic Memorisation (Hifz): Implications for Learning Performance.* Intellectual Discourse, 26(2), 931–947. https://journals.iium.edu.my/intdiscourse/index.php/islam/article/view/1238 — **[OBS]**
- Dzulkifli, M. A., Bin Abdul Rahman, A. W., Badi, J. A., & Solihu, A. K. (2016). *Routes to Remembering: Lessons from al Huffaz.* Mediterranean Journal of Social Sciences, 7(3 S1), 121–128. https://www.richtmann.org/journal/index.php/mjss/article/view/9090 — **[OBS]**
- Expertium. *FSRS Algorithm.* Open Spaced Repetition. https://expertium.github.io/Algorithm.html — **[TEXT]**
- Famibisyauqin. *Fami Bi Syauqin: Mengkhatamkan Al-Qur'an dalam 7 Hari.* https://famibisyauqin.blogspot.com/2016/02/fami-bi-syauqin-mengkhatamkan-al-quran.html — **[TRAD]**
- How To Memorise The Qur'an. *The Ottoman Hifz Method.* https://howtomemorisethequran.com/the-ottoman-hifz-method/ — **[TRAD]**
- How To Memorise The Qur'an (Medium). *The Takrār Method of Memorisation in Madīnah al-Munawwarah.* https://medium.com/how-to-memorise-the-quran/the-takrar-method-of-memorisation-in-madinah-al-munawwarah-schedules-62fe4a8d1179 — **[TRAD]**
- Ijazah. Wikipedia. https://en.wikipedia.org/wiki/Ijazah — **[TRAD]**
- Ilmify. *Muraja'ah in Hifz: The Complete Quran Revision Guide.* https://ilmify.app/blog/what-is-murajaah-quran-revision/ — **[TRAD]**
- Ilmify. *Sabak, Sabaq Para, and Dhor: Understanding the 3 Stages of Hifz Revision.* https://ilmify.app/blog/sabak-sabaq-para-dhor-hifz-stages/ — **[TRAD]**
- IslamicTuition. *Sabaq, Sabqi and Manzil — The Hifz Revision System Explained.* https://islamictuition.us/blog/sabaq-sabqi-manzil-hifz-revision-system/ — **[TRAD]**
- Manzil (Quran division). Wikipedia. https://en.wikipedia.org/wiki/Manzil — **[TRAD]**
- Mohamad, N., & Mohamad, M. *Concept and Execution of Talaqqi and Musyafahah Method in Learning Al-Quran.* Academia.edu. https://www.academia.edu/81052538/Concept_and_Execution_of_Talaqqi_and_Musyafahah_Method_in_Learning_Al_Quran — **[TRAD]**
- Murre, J. M. J., & Dros, J. (2015). *Replication and analysis of Ebbinghaus' forgetting curve.* PLOS ONE, 10(7), e0120644. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644 — **[EXP]**
- Nordin, O., Nik Abdullah, N. Md. S. A., Omar, R. A. M. I., & Abdullah, A. N. (2023). *The Art of Quranic Memorization: A Meta-Analysis.* Pertanika Journal of Social Sciences & Humanities, 31(2), 787–801. https://www.pertanika.upm.edu.my/resources/files/Pertanika%20PAPERS/JSSH%20Vol.%2031%20(2)%20Jun.%202023/16%20JSSH-8758-2022.pdf — **[OBS]**
- Rowland, C. A. (2014). *The effect of testing versus restudy on retention: A meta-analytic review of the testing effect.* Psychological Bulletin, 140(6), 1432–1463. https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect — **[MA]**
- Ṣaḥīḥ al-Bukhārī 4998 (Abū Hurayra), Book 66, Ḥadīth 20: Gabriel reviewed the Quran with the Prophet ﷺ once yearly, twice in the final year (al-ʿarḍa al-akhīra). Sunnah.com. https://sunnah.com/bukhari:4998 — **[TRAD]**
- Ṣaḥīḥ al-Bukhārī 5032 (ʿAbdullāh ibn Masʿūd), Book 66, Ḥadīth 54: the Qur'an escapes the memory faster than camels from their tethers. Sunnah.com. https://sunnah.com/bukhari:5032 — **[TRAD]**
- Ṣaḥīḥ Muslim 791 (Abū Mūsā al-Ashʿarī), agreed upon: the Qur'an slips away from memory faster than camels escaping their tying ropes. Encyclopedia of Translated Prophetic Hadiths (HadeethEnc 5907). https://hadeethenc.com/en/browse/hadith/5907 — **[TRAD]**
- Tarteel. *Quran Memorization Techniques: The Mauritanian Method.* https://tarteel.ai/blog/quran-memorization-techniques-the-mauritanian-method/ — **[TRAD]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
