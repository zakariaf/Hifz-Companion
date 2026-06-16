# Memory and Forgetting

This is the foundation document of the science set: it establishes the single fact the whole app answers to — that memorized material, including the Quran, **decays measurably and predictably over time** — and traces what that decay's shape, speed, and limits mean for an honest retention engine. Everything downstream depends on it: spacing ([`02-the-spacing-effect.md`](02-the-spacing-effect.md)) is *when* to catch a page before it falls; the DSR/FSRS engine ([`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md)) is the curve made computable; retrieval practice ([`04-retrieval-practice-and-self-testing.md`](04-retrieval-practice-and-self-testing.md)) is *how* the catching strengthens the trace; interference ([`05-interference-and-mutashabihat.md`](05-interference-and-mutashabihat.md)) is why an advanced ḥāfiẓ's dominant failure is *confusion*, not pure decay; and overlearning ([`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md)) is why the slope flattens to a near-permanent plateau without ever reaching zero loss. The deep evidence dossier behind this synthesis is [`research/forgetting-curve.md`](research/forgetting-curve.md); every claim here is registered in [`CLAIMS.md`](CLAIMS.md). Grades follow [`../_DOC-SET-BLUEPRINT.md`](../_DOC-SET-BLUEPRINT.md) §3: **[MA]** meta-analysis · **[RCT]** randomized · **[EXP]** controlled experiment · **[CS]** classic foundational · **[OBS]** observational/applied · **[TEXT]** textbook/review · **[TRAD]** named Islamic source.

The product's single promise — *never silently lose the Quran* — is just the operational form of one sentence from this literature: **the curve always slopes downward.** A paper rota cannot see the curve; an interval scheduler can.

## At a glance

| What the science establishes | The number/shape | How the app uses it |
|---|---|---|
| Forgetting is a smooth, decelerating curve — steep early, slow late | Sharp loss within hours/the first day, then a long shallow tail ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP] | Every page sits on its own curve; the heat-map (PRD §12.5) visualizes 604 of them sliding right |
| The curve is reproducible across 130 years, language, and person | Replicated Ebbinghaus's 1885 savings curve closely ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP] | Justifies building a scheduler on the curve at all |
| The functional form is a **power law**, not an exponential | Individual curves fit power functions, not exponentials ([Wixted & Ebbesen, 1997](https://pubmed.ncbi.nlm.nih.gov/9337591/)) [EXP] | FSRS power-law `R(t,S)=(1+FACTOR·t/S)^DECAY`, DECAY=−0.5 (PRD §7.3) — lets intervals grow multiplicatively |
| "Forgotten" ≠ "gone": relearning is far cheaper than first learning | Savings survive even when recall *and* recognition fail ([Nelson, 1985](https://psycnet.apa.org/record/1986-11014-001)) [EXP] | A lapsed page is reactivated, not catastrophized; the trust clamp catches it cheaply (PRD §7.6) |
| Sleep gives a ~24-hour consolidation "jump" | Curve shows an upward step around 24h ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP] | Schedule in whole days; privilege the next-day re-review (PRD §7.10) — detail in [`08-sleep-consolidation-and-scheduling.md`](08-sleep-consolidation-and-scheduling.md) |
| Deeply over-learned material plateaus for decades — but still slopes | "Permastore," stable ~30 years, predicted by depth of learning ([Bahrick, 1984](https://pubmed.ncbi.nlm.nih.gov/6242406/)) [OBS] | Near-100% comes from overlearning + the cycle ceiling, never a magic 0.99 (PRD §7.5–7.6) |

---

## 1. Forgetting follows a smooth, decelerating curve — steep at first, then flattening

**Statement.** Memorized material is lost along a predictable curve: most of the loss happens fast (within hours and the first day), after which the rate of loss slows and the curve approaches a long, shallow tail. This is the most load-bearing fact in the app — it is *why* a fixed paper rota fails (it treats a fresh page and a decade-old page identically) and *why* an interval-based scheduler is the correct response.

**Evidence.**
- Hermann Ebbinghaus ran the first systematic memory experiments in *Über das Gedächtnis* (1885), using himself as the only subject and lists of **nonsense syllables** chosen deliberately to strip away prior meaning and association ([Ebbinghaus, 1885/1913](https://psychclassics.yorku.ca/Ebbinghaus/index.htm)) [CS]. Plotting retention against delay produced the **forgetting curve**: a sharp early drop that decelerates into a shallow tail.
- The shape replicates. A single-subject replication had J. Dros (age 22) spend ~70 hours over 75 days learning and relearning lists of 104 nonsense syllables at delays of **20 min, 1 h, 9 h, 1 day, 2 days, 6 days, and 31 days**; the resulting curve closely matched Ebbinghaus's 1885 figures across a 130-year gap, a different language, and a different person ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP].
- The decay axiom is, for the Quran specifically, also a prophetic one: *"the Qur'an slips away faster than camels escaping their tying ropes"* ([Ṣaḥīḥ al-Bukhārī 5032](https://sunnah.com/bukhari:5032)) [TRAD] — cited with collection and number, framed as the premise the app answers, never as a fiqh ruling or a fear-nudge.

**In practice.**

| The science says | The engine does (PRD ref) |
|---|---|
| Every memorized item is sliding down its own curve | The retention heat-map renders 604 pages each at its point on the curve (§12.5) |
| Decay is steep early, slow late | A just-memorized page (sabaq/NEW, low stability) is re-recited soon; a mature juz (manzil/FAR) safely stretches to weekly/monthly (§7.4–7.5) |
| Loss is continuous and silent | The "never silently lose" promise: the engine may only pull a page *forward*, never declare it "safe to drop" (§7.6, §7.12) |

**Anti-patterns — we will never:**
- Treat all pages on a single fixed rotation as though they decayed at the same rate.
- Use the prophetic ḥadīth (or any text) as a guilt or fear notification — it scopes the *premise*, not a threat (PRD R3).
- Imply forgetting is a personal failing rather than a universal, measured regularity.

---

## 2. The forgetting function is a power law — which is exactly why intervals may grow

**Statement.** *Which* equation describes forgetting is not academic trivia: the scheduler's interval formula is the inverse of the retention curve, so the curve's form dictates how intervals are allowed to behave. The best description of individual forgetting is a **power law**, not a simple exponential — and a power law is precisely what lets a well-maintained page's safe interval lengthen multiplicatively (daily → weekly → monthly) while never granting a permanent "now done."

**Evidence.**
- Single-subject forgetting functions are *"described much better by a power function than by an exponential,"* and this is not an artifact of averaging across people — it holds for individual functions under both arithmetic and geometric averaging ([Wixted & Ebbesen, 1997](https://pubmed.ncbi.nlm.nih.gov/9337591/)) [EXP].
- The Murre & Dros replication's own model comparison agreed: by AIC, summed-exponential / power-law forms (a power function with a 24-hour consolidation boost fitting slightly best) outperformed Ebbinghaus's original logarithmic fit ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP].
- Mechanistically, a *population* of traces that each decay roughly exponentially but with **different stabilities** superimposes into an aggregate that is best approximated by a power law — slow-decaying traces dominate the long tail ([Woźniak, SuperMemo: *Forgetting curve*](https://supermemo.guru/wiki/Forgetting_curve)) [TEXT]. This is the conceptual basis for the modern DSR model treated in [`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md).

**In practice.**
- The engine uses the FSRS power-law retrievability function `R(t,S) = (1 + FACTOR·t/S)^DECAY` with **DECAY = −0.5** and **FACTOR = 19/81 ≈ 0.2346**, so R(S) = 0.9 by the definition of stability S (PRD §7.3).
- Because the curve is power-law, the safe interval roughly scales with stability and **lengthens each time a page is successfully re-recited** — the mathematical license for a maintained juz moving to a weekly or monthly *manzil* cadence (PRD §7.4).
- Critically, a power law (unlike an exponential) **never reaches a flat interval**: there is no "permanently safe." The engine therefore always keeps a finite due date for every memorized page (`due_at` is never null — PRD §7.2, §7.12).

**Anti-patterns — we will never:**
- Use a simple exponential model that would either over-review mature pages or imply a flat "safe forever" interval.
- Let interval growth run unbounded on the math alone — the *cycle ceiling* (§3 below, PRD §7.6) clamps it regardless of what the curve permits.
- Hard-depend on the precise DECAY/FACTOR constants; they are a starting prior, tunable from the user's own lapse history, and the cycle ceiling — not the constant — is the real guarantee (PRD §7.3).

---

## 3. "Forgotten" is not "gone" — relearning is cheap, which is the whole economic case for maintenance

**Statement.** A page a ḥāfiẓ "can't recall today" has not decayed to zero. A subthreshold trace survives below the level of conscious recall, and *relearning* it (one timely re-recitation) costs a fraction of the original ḥifẓ — **but only while the trace is still reachable.** The entire product is a machine for triggering cheap, timely re-recitations *before* a page falls so far that relearning becomes expensive.

**Evidence.**
- Ebbinghaus measured retention not by "can you recall it?" but by **savings on relearning** — how much time/effort is spared relearning a list after a delay, `Q(t) = (L − L_t) / L` ([Ebbinghaus, 1885/1913](https://psychclassics.yorku.ca/Ebbinghaus/index.htm)) [CS].
- Savings appear even when recall *and* recognition both fail: items a person can neither recall nor recognize after a delay are nonetheless **relearned faster than genuinely new items** — a subthreshold trace persists ([Nelson, 1985](https://psycnet.apa.org/record/1986-11014-001)) [EXP].
- Savings is mathematically a "pure" memory measure — largely independent of original encoding strength, so it tracks the underlying forgetting function with less contamination than recall-probability curves ([Murre & Chessa, 2022/2023, *Psychonomic Bulletin & Review*](https://link.springer.com/article/10.3758/s13423-022-02172-3)) [TEXT].

**In practice.**

| The science says | The engine does (PRD ref) |
|---|---|
| Relearning is far cheaper than first learning, *if timely* | The trust clamp guarantees every page is re-recited at least once per chosen cycle, capping how far it can slide before it is caught (§7.6) |
| Forgotten material is recoverable, not lost | A lapsed page is **demoted into active revision**, not deleted or flagged as failure (§6.2, §7.7) |
| The signal of decay precedes total loss | The engine pulls a decaying page *forward* (more frequent) before it crosses a hard floor (§7.8–7.9) |

This is also the emotional core of the copy: a lapse is *"this page needs reactivation,"* never *"you have lost it"* — honest *and* non-coercive (see [`09-motivation-without-coercion.md`](09-motivation-without-coercion.md)).

**Anti-patterns — we will never:**
- Treat a lapse as catastrophic, shame the user for it, or zero out their progress on a page.
- Wait until a page is deeply lost (expensive to relearn) when the curve and the cycle ceiling let us catch it cheaply.
- Borrow Leitner's "any error → back to box 1" brutality across a 600-page corpus; a single stumbled line does not reset an otherwise-solid page ([`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md)).

---

## 4. The curve has a sleep-linked consolidation step around 24 hours

**Statement.** Forgetting is not perfectly monotonic. Around the 24-hour mark, the curve shows a small upward step — memory pauses or slightly *recovers* across a night's sleep. This privileges the **first overnight interval**: a page reviewed today and again tomorrow benefits from a consolidation window that a same-day double-review cannot buy.

**Evidence.**
- The replicated curve is *"not completely smooth"* and *"most probably shows a jump upwards starting at the 24-hour data point"*; savings at 1–2 days frequently exceeded a smooth monotonic prediction, and a power function augmented with a **24-hour boost factor** fit the data better ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP].
- This is consistent with sleep-dependent memory consolidation, developed fully in the sibling note and synthesis ([`08-sleep-consolidation-and-scheduling.md`](08-sleep-consolidation-and-scheduling.md)).

**In practice.**
- The engine schedules in **whole days**, never sub-day repetitions, and the pure-Dart core injects "today" as a calendar date rather than a wall-clock instant (PRD §7.12, §19.3) — schedules are deterministic and day-granular.
- New and freshly-lapsed pages are re-reviewed the *next day* rather than packed into one sitting; the cold-start "calibration pass" and the sabaq → sabqi graduation respect day boundaries so sleep does free consolidation work (PRD §7.10).

**Anti-patterns — we will never:**
- Cram multiple scheduled repetitions of the same page into a single day to "get ahead."
- Use sub-day intervals or wall-clock timestamps inside the engine (breaks determinism and ignores the consolidation window).

---

## 5. Within a chunk, the *middle* decays fastest — loss is positional

**Statement.** Forgetting is not uniform across an ordered sequence. The opening and closing items of a chunk are protected (primacy and recency); the **middle is where loss concentrates**. For a Quran page recited as a chained serial sequence — each line cueing the next — this predicts that mid-page lines are the structural weak spot and the natural site of a missed-word slip.

**Evidence.**
- Measuring forgetting *by position within each 13-syllable row*, the replication found a sharp serial-position signature: opening items (positions 1–2, slope ≈ −0.0001) and final items (positions 11–13, slope ≈ −0.0002) were highly resistant, while the middle (positions 3–8, slope ≈ −0.011) decayed up to ~100× faster ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP].
- That Quran recall is a *chained serial sequence* (not independent flashcards) is the basis for scheduling the page as the unit and tracking lines only to localize weakness — developed in [`07-serial-recall-and-the-page-unit.md`](07-serial-recall-and-the-page-unit.md).

**In practice.**
- The page is the scheduled unit; **sub-page (line) state is a derived overlay** used only to localize weakness, created **lazily** only for pages that repeatedly lapse — so we don't carry thousands of fragments for the ~95% of pages that are fine (PRD §7.1, §10.2).
- Error-position capture during the reveal-on-tap recite flow records *which lines* stumbled (PRD §8.1); weak-spot attention is biased toward interior lines, and the error overlay is drawn as coordinates on the immutable glyph page, never by re-typesetting (PRD §11.2).

**Anti-patterns — we will never:**
- Atomize a page into independent verse-cards, which breaks the serial cue chain and produces unnatural review units (PRD §7.1).
- Re-review an entire solid page when the diagnosis is two weak interior lines — the page carries the schedule, the line carries the diagnosis.

---

## 6. Deeply over-learned material plateaus for decades — but the slope never reaches zero

**Statement.** The curve flattens, and for material learned well past bare mastery it can flatten to a **stable plateau lasting decades**. This is the honest source of "near-permanent" retention — and equally, the honest limit: the plateau is *near*-flat, not flat. We never promise a page is permanently safe, and we never chase a literal 0.99 global retention number.

**Evidence.**
- Testing **733 people** on Spanish learned in school across a **50-year** span, retention declined for the first ~3–6 years, then **remained essentially unchanged for ~30 years** before a final late decline — a durable store named the **"permastore"** ([Bahrick, 1984](https://pubmed.ncbi.nlm.nih.gov/6242406/)) [OBS]. What predicted survival into permastore was the **depth/degree of original (over-)learning**, far more than rehearsal during the interval.
- Meaningful, structured material follows the same *shape* of curve, only stretched: Ebbinghaus found memorizing meaningful text (Byron's *Don Juan*) took roughly **one-tenth** the effort of nonsense syllables ([Roediger, 1985, *Remembering Ebbinghaus*](http://psychnet.wustl.edu/memory/wp-content/uploads/2018/04/Roediger-1985_CP.pdf)) [TEXT]. The Quran — over-learned, meaning-rich, rhythmically structured — sits at the flat, permastore-favorable end. Good news (loss is slow); not zero (the curve still slopes).
- The overlearning mechanism and its bound are developed in [`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md).

**In practice.**
- Near-100% retention is delivered by **overlearning to automaticity plus the cycle ceiling** — every page guaranteed re-recited within the chosen cycle — *not* by a fragile probability target (PRD §7.5–7.6). A literal 0.99 everywhere is ~11× the workload of 0.90 and would blow the daily budget and break trust (PRD §7.5; see [`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md)).
- Retention targets are tiered by stakes, not set globally: ~0.95 routine, **0.97+ for prayer-critical / weak / previously-lapsed pages** (PRD §7.5).
- The permastore result also licenses the cold-start "stale-time decay" option — applying the forgetting curve from the date a juz was finished, so a juz memorized years ago is treated as needing reactivation — and justifies *conservative* priors that under-estimate strength (PRD §7.10.3–7.10.4), since the long-tail estimate is the least reliable part of the curve ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP].

**Anti-patterns — we will never:**
- Tell a ḥāfiẓ any memorized page is "safe to drop" or finished with revision (PRD §7.12) — the curve always slopes.
- Promise perfect retention or advertise a magic retention percentage as a guarantee.
- Chase a literal 0.99 global target; the cost curve explodes and an occasional honest stumble damages trust less than a broken, over-loaded schedule (PRD §7.5).

---

## A note on scope and honesty

The classic curve's known weaknesses — n = 1, nonsense syllables — are real and we state them plainly. They do not break the core result: meaningful material follows the same curve, only slower ([Roediger, 1985](http://psychnet.wustl.edu/memory/wp-content/uploads/2018/04/Roediger-1985_CP.pdf)) [TEXT], and the curve has been independently reproduced 130 years on ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) [EXP]. Hifz-specific empirical work confirms that *maintenance* (murājaʿa), not initial memorization, is the named, under-built problem — but that literature is young, small-n, and observational, so we lean on the strong general curve for any mechanism claim and never over-read the hifz studies ([`research/quran-memorization-research.md`](research/quran-memorization-research.md)). Where the app simplifies the literature — one power-law decay constant, a default retention tier — the relevant section above says so. That honesty is the science pillar this whole foundation is built on (README; [`../_DOC-SET-BLUEPRINT.md`](../_DOC-SET-BLUEPRINT.md) §1).

---

## References

Only sources cited in this file are listed. The deduplicated, graded master bibliography is in [`REFERENCES.md`](REFERENCES.md); the deep dossier is [`research/forgetting-curve.md`](research/forgetting-curve.md).

- Bahrick, H. P. (1984). *Semantic memory content in permastore: Fifty years of memory for Spanish learned in school.* Journal of Experimental Psychology: General, 113(1), 1–29. https://pubmed.ncbi.nlm.nih.gov/6242406/ — **[OBS]**
- Ebbinghaus, H. (1885/1913). *Über das Gedächtnis (Memory: A Contribution to Experimental Psychology)* (H. A. Ruger & C. E. Bussenius, Trans.). Teachers College, Columbia University. https://psychclassics.yorku.ca/Ebbinghaus/index.htm — **[CS]**
- Murre, J. M. J., & Chessa, A. G. (2022/2023). *Why Ebbinghaus' savings method from 1885 is a very 'pure' measure of memory performance.* Psychonomic Bulletin & Review, 30(1), 303–307. https://link.springer.com/article/10.3758/s13423-022-02172-3 — **[TEXT]**
- Murre, J. M. J., & Dros, J. (2015). *Replication and analysis of Ebbinghaus' forgetting curve.* PLOS ONE, 10(7), e0120644. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644 — **[EXP]**
- Nelson, T. O. (1985). *Ebbinghaus's contribution to the measurement of retention: Savings during relearning.* Journal of Experimental Psychology: Learning, Memory, and Cognition, 11(3), 472–479. https://psycnet.apa.org/record/1986-11014-001 — **[EXP]**
- Roediger, H. L. (1985). *Remembering Ebbinghaus.* PsycCRITIQUES (Contemporary Psychology), 30(7), 519–523. http://psychnet.wustl.edu/memory/wp-content/uploads/2018/04/Roediger-1985_CP.pdf — **[TEXT]**
- Ṣaḥīḥ al-Bukhārī 5032 (ʿAbdullāh ibn Masʿūd), Book 66, Ḥadīth 54: the Qur'an escapes the memory faster than tethered camels. Sunnah.com. https://sunnah.com/bukhari:5032 — **[TRAD]**
- Wixted, J. T., & Ebbesen, E. B. (1997). *Genuine power curves in forgetting: A quantitative analysis of individual subject forgetting functions.* Memory & Cognition, 25(5), 731–739. https://pubmed.ncbi.nlm.nih.gov/9337591/ — **[EXP]**
- Woźniak, P. A. (n.d.). *Forgetting curve.* SuperMemo Guru. https://supermemo.guru/wiki/Forgetting_curve — **[TEXT]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
