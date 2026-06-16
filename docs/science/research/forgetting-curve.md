# The Forgetting Curve and the Decay of Memory

**Topic:** How memory for learned material decays over time — Ebbinghaus's original 1885 savings experiments, their modern replications (notably Murre & Dros 2015), the shape of the forgetting function (logarithmic vs. exponential vs. power law), "savings" on relearning as evidence that traces persist below the threshold of recall, the consolidation "jump," and the very-long-term plateau — and what all of this implies for scheduling Quran revision (*murājaʿa / manzil / dhor*).

**Compiled:** 2026-06-16

This note is the deep evidence dossier behind the synthesis doc `science/01-memory-and-forgetting.md`. It establishes the single most load-bearing fact in the entire app: that memorized material **decays measurably and predictably over time**, and that the decay is *steep early and slow late* — which is exactly why a fixed paper rota fails and why an interval-based scheduler is the correct response. Sibling notes cover the countermeasures: `spacing-effect.md` (when to re-review), `spaced-repetition-algorithms.md` (the FSRS DSR engine that models this curve), `retrieval-practice.md` (why active recall beats re-reading), and `interference-theory.md` (why *mutashābihāt* confusion, not pure decay, is the dominant failure mode for an advanced ḥāfiẓ).

---

## What the evidence says

### 1. Ebbinghaus (1885) established that forgetting follows a smooth, decelerating curve — steep at first, then flattening

Hermann Ebbinghaus, in his monograph *Über das Gedächtnis* (1885), ran the first systematic experiments on memory, using himself as the sole subject and lists of **nonsense syllables** (consonant–vowel–consonant trigrams) specifically to strip away the confounds of prior meaning, imagery, and association ([Ebbinghaus, 1885/1913](https://psychclassics.yorku.ca/Ebbinghaus/index.htm)). He measured retention not by asking "can you recall it?" but by **relearning** a list after a delay and recording how much *time/effort was saved* relative to the first learning — the **savings method** (see finding 4). Plotting savings against the retention interval produced the **forgetting curve**: retention dropped sharply within the first hour and the first day, then declined ever more slowly, approaching a long, shallow tail ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)). Ebbinghaus himself fitted his data with a **logarithmic** function of time, Q(t) = 100k / ((log t)^c + k), with c = 1.25 and k = 1.84 ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)). The qualitative shape — *fast loss early, slow loss late* — is the durable, repeatedly confirmed result; the exact equation is secondary (finding 3).

### 2. The curve replicates: Murre & Dros (2015) reproduced Ebbinghaus's 1885 data 130 years later

The most important modern check is [Murre & Dros (2015), *PLOS ONE* 10(7): e0120644](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644) — the first non-German replication of Ebbinghaus's forgetting experiment. A single subject (J. Dros, age 22) spent roughly **70 hours over 75 days** learning and relearning **70 lists** of 104 nonsense syllables, at retention intervals of **20 minutes, 1 hour, 9 hours, 1 day, 2 days, 6 days, and 31 days**. The resulting savings curve was *"remarkably"* similar to Ebbinghaus's 1885 figures across most intervals — a striking convergence given the century-plus gap, the change of language (Dutch vs. German), and a different person. The one notable divergence was at the 31-day point, where the replication's savings score was much lower (~0.041) than Ebbinghaus's, suggesting the very-long-tail estimate is the least stable part of the curve ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)). **Takeaway for the app:** the forgetting curve is not a quaint historical artifact — it is a reproducible empirical regularity robust enough to build a scheduler on.

### 3. The functional form is a power law (or summed-exponential), not a simple exponential — which matters for interval growth

What equation actually describes forgetting has real engineering consequences, because the scheduler's interval formula is the *inverse* of the retention curve. Three findings converge:

- **Power beats exponential at the individual level.** [Wixted & Ebbesen (1997), *Memory & Cognition* 25(5): 731–739](https://pubmed.ncbi.nlm.nih.gov/9337591/) showed that single-subject forgetting functions are *"described much better by a power function than by an exponential,"* and that this is **not** merely an artifact of averaging across subjects (the Anderson & Tweney critique) — it holds for individual functions and under both arithmetic and geometric averaging. Their earlier work found the power function at^(−b) outperformed five alternatives (linear, exponential, exponential-power, hyperbolic, logarithmic) across recall, recognition, and even pigeon data.
- **Murre & Dros's own model comparison agrees.** Comparing candidate fits by AIC, the best fit to the replicated Ebbinghaus data was a **Memory Chain Model / summed-exponential** (avg AIC −22.0), edging out the bare power function and Ebbinghaus's logarithm (both ~−20.5); a power function *with a 24-hour consolidation boost* fit slightly better still (−23.6) ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)).
- **Why power emerges from exponential parts.** Individual memory traces may each decay roughly exponentially, but a *population* of traces with **different stabilities** superimposed produces an aggregate curve that is best approximated by a **power law** — the slow-decaying traces dominate the long tail ([Wozniak, SuperMemo: *Forgetting curve*](https://supermemo.guru/wiki/Forgetting_curve)). This is exactly why FSRS (the app's engine) uses a **power-law** retrievability function R(t,S) = (1 + FACTOR·t/S)^DECAY with DECAY = −0.5, rather than the exponential of older models.

**Consequence:** because the curve is power-law, the *safe interval roughly scales with stability* and lengthens multiplicatively as a page is successfully re-recited — the mathematical basis for why a well-maintained juz can eventually move to a weekly or monthly cadence, while a power law (unlike an exponential) never grants a flat "now permanently safe" interval.

### 4. "Savings on relearning" reveals that traces persist below the threshold of conscious recall

The savings measure is more than a quirk of method — it is the deepest finding in this literature for a *maintenance* app. Savings is computed as the proportion of effort spared on relearning: **Q(t) = (L − L_t) / L**, where L is original learning time/trials and L_t is relearning time/trials after delay t ([Murre & Chessa, 2022/2023, *Psychonomic Bulletin & Review* 30(1): 303–307](https://link.springer.com/article/10.3758/s13423-022-02172-3)). Crucially:

- **Savings appears even when recall and recognition both fail.** [Nelson (1985), *J. Exp. Psychol.: LMC* 11(3): 472–479](https://psycnet.apa.org/record/1986-11014-001) demonstrated that items a person can *neither* recall *nor* recognize after a delay are nonetheless **relearned faster** than genuinely new items — a subthreshold trace survives. Nelson (1978) had earlier shown that "forgotten" word–number pairs were relearned more quickly than new pairs. Forgotten is not gone.
- **Savings is a "pure" memory measure.** Murre & Chessa (2022) prove mathematically that savings is *largely independent of the original encoding strength*, whereas recall-probability curves get steeper the stronger the initial learning. Savings therefore tracks the *underlying* forgetting function with less contamination — the cleanest window onto true decay ([Murre & Chessa, 2022](https://link.springer.com/article/10.3758/s13423-022-02172-3)).

**This is the scientific licence for the app's central promise.** A ḥāfiẓ who has "lost" a page has not lost it to zero; the *relearning* (a single re-recitation under teacher or self-review) is dramatically cheaper than the original ḥifẓ. The whole product is a machine for triggering cheap, timely re-recitations *before* a page falls so far that relearning becomes expensive.

### 5. The curve is not perfectly smooth: a consolidation "jump" appears around 24 hours (sleep)

Both the original and replicated data hint that forgetting **pauses or even reverses slightly across a night's sleep**. Murre & Dros (2015) report that the classic curve *"is not completely smooth"* and *"most probably shows a jump upwards starting at the 24-hour data point"*; savings at 1–2 days frequently exceeded what a smooth monotonic curve predicts, and a power function augmented with a **24-hour boost factor** fit the data better ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)). This is consistent with sleep-dependent memory consolidation (developed fully in the sibling note `sleep-and-consolidation.md`). For scheduling, it means the **first overnight interval is privileged**: a page reviewed today and again tomorrow benefits from a consolidation window that a same-day double-review does not.

### 6. Within a memorized chunk, the middle decays fastest (serial-position structure of forgetting)

Forgetting is not uniform across a sequence. Murre & Dros (2015) measured forgetting *by position within each 13-syllable row* and found a sharp serial-position signature: the **opening** items (positions 1–2, slope ≈ −0.0001) and the **final** items (positions 11–13, slope ≈ −0.0002) were highly resistant, while the **middle** (positions 3–8, slope ≈ −0.011) decayed up to ~100× faster ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)). Primacy and recency protect the edges; the middle is where loss concentrates. For Quran pages — recited as a chained serial sequence (each line cueing the next) — this predicts that **mid-page lines are the structural weak spot**, the natural place for a missed-word slip, and the right target for line-level weak-spot tracking rather than re-reviewing an otherwise-solid page.

### 7. Deeply-learned material does not decay to zero: the very-long-term "permastore" plateau

The forgetting curve flattens, and for well-learned material it can flatten to a **stable plateau** that lasts for decades. [Bahrick (1984), *J. Exp. Psychol.: General* 113(1): 1–29](https://pubmed.ncbi.nlm.nih.gov/6242406/) tested **733 people** on Spanish learned in school across a **50-year** span and found retention declined for the first ~3–6 years and then **remained essentially unchanged for up to ~30 years** before a final late decline — a durable store Bahrick named the **"permastore."** What predicted survival into permastore was the **depth and degree of original learning** (and over-learning), far more than rehearsal during the interval. This is the empirical backbone of the overlearning argument (see `overlearning-automaticity.md`): material driven well past the point of bare mastery resists forgetting on a fundamentally different, far flatter curve.

### 8. The classic curve's limits — single subject, nonsense material — are real but do not break the core result

Honest scoping. Ebbinghaus's original study has well-known weaknesses: **n = 1** (himself), and **nonsense syllables** rather than meaningful text. He was aware of both and chose nonsense syllables deliberately to control for prior associations ([Roediger, 1985, *Remembering Ebbinghaus*, PsycCRITIQUES](http://psychnet.wustl.edu/memory/wp-content/uploads/2018/04/Roediger-1985_CP.pdf)). Two points keep the result intact for our purposes:

- **Meaningful material follows the same shape, only stretched.** Ebbinghaus himself found that memorizing meaningful text (stanzas of Byron's *Don Juan*) took roughly **one-tenth** the effort of nonsense syllables; meaningful, structured material forgets along the *same form of curve but much more slowly* ([Murre & Dros, 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644); [Roediger, 1985](http://psychnet.wustl.edu/memory/wp-content/uploads/2018/04/Roediger-1985_CP.pdf)).
- **The Quran is the most over-learned, most meaningful, most rhythmically-structured material imaginable** — so a ḥāfiẓ sits at the *flat, slow, permastore-favorable* end of the curve. This is good news (loss is slow), but it does **not** mean loss is zero: the curve still slopes downward, silently, which is precisely the failure mode the app exists to prevent.

---

## Implications for Hifz Companion

1. **Decay is the premise of the entire product — make it the headline, honestly.** The retention heat-map (PRD §12.5) is a direct visualization of the forgetting curve applied to 604 pages: each page sits somewhere on its own curve, sliding right. The app's promise — *"never silently lose the Quran"* — is the operational form of "the curve always slopes down." Never imply a page is "safe to drop" (PRD §7.12); the science says nothing is.

2. **Use a power-law retrievability function, not an exponential.** Findings 3 endorse the FSRS curve already specified in PRD §7.3: R(t,S) = (1 + FACTOR·t/S)^DECAY with DECAY = −0.5, FACTOR = 19/81 ≈ 0.2346. The power law is what lets a maintained page's interval grow multiplicatively (weekly → monthly) while never granting a permanent "done" — matching both the science and the *manzil* tradition.

3. **Schedule the re-recitation *before* the page falls far down the curve — exploit cheap relearning (finding 4).** The economic argument of the app is savings-on-relearning: a timely re-recitation costs a fraction of original ḥifẓ, but only if it happens while the trace is still strong. The trust clamp (PRD §7.6) guarantees every page is re-recited at least once per chosen cycle, capping how far down the curve any page can slide before it is caught.

4. **Treat "I forgot this page" as recoverable, not catastrophic — calm, non-shaming copy (finding 4).** Because forgotten material is relearned far faster than new material (Nelson 1985), a lapsed page should demote into active revision (PRD §6.2, §7.7), not trigger guilt. The framing is "this needs reactivation," never "you have lost it." This aligns with the science *and* the non-coercive-motivation pillar (blueprint §1).

5. **Privilege the first overnight interval (finding 5).** The ~24-hour consolidation jump argues for a *next-day* re-review of newly-strengthened or freshly-lapsed pages rather than packing repetitions into one day. The cold-start "calibration pass" (PRD §7.10) and the *sabaq → sabqi* graduation should respect day boundaries, letting sleep do free consolidation work.

6. **Localize weakness to mid-page lines (finding 6).** Serial-position forgetting predicts that stumbles cluster in the *middle* of a page, not the edges. This validates the lazy line-block model (PRD §7.1, §10.2): create sub-page weak-spot state only for repeatedly-lapsing pages, and bias weak-spot attention toward interior lines. Error-position capture during the reveal-on-tap flow (PRD §8.1) is the signal that drives this.

7. **Do not over-promise zero forgetting; promise the cycle ceiling instead (findings 7–8).** The permastore result says deep over-learning produces a near-flat curve — but "near-flat" is not "flat," and a literal 0.99 global retention target is infeasible (it is ~11× the workload of 0.90; see `spaced-repetition-algorithms.md`). Honesty pillar (blueprint §1): near-100% retention is delivered by the **cycle ceiling** (every page re-recited within the chosen cycle) plus stakes-tiered targets and overlearning — *not* by a magic probability number. State this plainly in the in-app science screen.

8. **Conservative cold-start priors are scientifically justified (finding 1 + finding 2).** Because the curve is steep early and a juz memorized years ago has slid far down it, the cold-start "stale-time decay" option (PRD §7.10.3) — applying the forgetting curve from the date a juz was finished — is a legitimate use of the curve, and the deliberate under-estimation of strength (PRD §7.10.4) matches the prudent reading that the long-tail/31-day estimate is the least reliable part of the curve (finding 2).

---

## Citations

1. Ebbinghaus, H. (1885/1913). *Über das Gedächtnis: Untersuchungen zur experimentellen Psychologie* [*Memory: A Contribution to Experimental Psychology*] (H. A. Ruger & C. E. Bussenius, Trans.). Teachers College, Columbia University. Online (Classics in the History of Psychology): https://psychclassics.yorku.ca/Ebbinghaus/index.htm — [CS]

2. Murre, J. M. J., & Dros, J. (2015). Replication and analysis of Ebbinghaus' forgetting curve. *PLOS ONE*, 10(7), e0120644. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644 (DOI: 10.1371/journal.pone.0120644) — [EXP]

3. Murre, J. M. J., & Chessa, A. G. (2022/2023). Why Ebbinghaus' savings method from 1885 is a very 'pure' measure of memory performance. *Psychonomic Bulletin & Review*, 30(1), 303–307. https://link.springer.com/article/10.3758/s13423-022-02172-3 (DOI: 10.3758/s13423-022-02172-3) — [TEXT]

4. Nelson, T. O. (1985). Ebbinghaus's contribution to the measurement of retention: Savings during relearning. *Journal of Experimental Psychology: Learning, Memory, and Cognition*, 11(3), 472–479. https://psycnet.apa.org/record/1986-11014-001 (DOI: 10.1037/0278-7393.11.3.472) — [EXP]

5. Wixted, J. T., & Ebbesen, E. B. (1997). Genuine power curves in forgetting: A quantitative analysis of individual subject forgetting functions. *Memory & Cognition*, 25(5), 731–739. https://pubmed.ncbi.nlm.nih.gov/9337591/ (DOI: 10.3758/BF03211316) — [EXP]

6. Bahrick, H. P. (1984). Semantic memory content in permastore: Fifty years of memory for Spanish learned in school. *Journal of Experimental Psychology: General*, 113(1), 1–29. https://pubmed.ncbi.nlm.nih.gov/6242406/ (DOI: 10.1037/0096-3445.113.1.1) — [OBS]

7. Wozniak, P. A. (n.d.). *Forgetting curve* and *Two component model of memory*. SuperMemo Guru / supermemo.guru. https://supermemo.guru/wiki/Forgetting_curve — [TEXT]

8. Roediger, H. L. (1985). Remembering Ebbinghaus. *PsycCRITIQUES* (Contemporary Psychology), 30(7), 519–523. http://psychnet.wustl.edu/memory/wp-content/uploads/2018/04/Roediger-1985_CP.pdf — [TEXT]
