# The Spacing Effect — Why Revision Is Distributed, and Why the Gap Grows

Decay is the premise of this product ([`01-memory-and-forgetting.md`](01-memory-and-forgetting.md)); spacing is the answer to it. This document distils the strongest finding in the science foundation — that review *distributed* over time produces durable retention far beyond *massed* review (cramming), and that the gap which maximises later recall is not fixed but *grows with how long you intend to keep the material*. That single law is the mathematical licence for a maintained juz moving from daily, to weekly, to monthly revision, and it is the empirical foundation under the scheduler's intervals, its cycle ceilings, and its deliberate bias toward reviewing *too soon* rather than too late (PRD §7.3–§7.6). Spacing is *what* to do across time; the FSRS DSR engine in [`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md) is *how* the app computes it per page; reciting from memory rather than re-reading — [`04-retrieval-practice-and-self-testing.md`](04-retrieval-practice-and-self-testing.md) — is *what happens* in each spaced session; and the classical *sabaq / sabqi / manzil* rota — [`10-traditional-hifz-methodology.md`](10-traditional-hifz-methodology.md) — is the same expanding-interval schedule the masters reached by hand. Spacing is the cure for *decay*; it is **not** the cure for *interference* between similar verses, which needs the opposite treatment (massed contrast) covered in [`05-interference-and-mutashabihat.md`](05-interference-and-mutashabihat.md).

> **One sentence:** Spread review out, widen the gaps as a page strengthens, and when in doubt review early — because the cost of spacing *too short* is far steeper than the cost of spacing *too long*.

## At a glance

| Finding | What it says | Strongest evidence | Grade | Engine consequence (PRD) |
|---|---|---|---|---|
| Spacing beats massing | Distributed review retains far better than the same time crammed | Cepeda et al. 2006; Donovan & Radosevich 1999 | [MA] | An SR scheduler exists at all (§7) |
| Optimal gap grows with horizon | The best inter-study gap rises as the retention interval rises | Cepeda et al. 2006, 2008 | [MA]/[EXP] | Named cycles set the horizon; phase thresholds widen gaps (§7.4, §15.1) |
| Proportional gap shrinks | As horizon lengthens, the optimum gap is a *smaller fraction* of it | Cepeda et al. 2008 | [EXP] | Mature pages rest weeks-to-months, not "review forever daily" (§7.4) |
| Cost asymmetry | Too-short is punished far harder than too-long | Cepeda et al. 2009 | [EXP] | The trust-clamp may only pull *forward*; conservative cold-start priors (§7.6, §7.10) |
| Expanding ≠ magic | What matters is delaying the *first* review enough to be effortful, not an expanding ladder | Karpicke & Roediger 2007 | [EXP] | New→Near spacing matters; later gaps emerge from DSR growth (§7.4) |
| Spacing survives stumbles | The benefit holds even for items that errored at the long gap | Pashler et al. 2003 | [EXP] | A stumble near the ceiling is desirable difficulty, graded honestly, never shamed (§7.7, R3) |
| Wider gaps = less work | Half the sessions at wide gaps matched dense schedules for durability | Bahrick et al. 1993 | [CS] | A longer cycle is *efficient*, not lazy — honest budget framing (§7.9, §12.2) |

---

## 1. Distributed practice beats massed practice — the most robust law we build on

**Statement.** Spreading review across separate sessions produces substantially more durable retention than packing the same total study time into one sitting. This is the single finding that justifies a spaced-repetition engine existing at all; without it, a paper rota recited "until it sticks" would be enough.

**Evidence.**
- The benefit of distributing study over time is one of the oldest and most replicated results in experimental psychology, traced to Ebbinghaus's own self-experiments, where distributed relearning required far fewer repetitions than massed relearning ([Ebbinghaus, 1885/1964](https://archive.org/details/memorycontributi00ebbiuoft)) **[CS]**.
- The first large modern meta-analysis found a **mean weighted effect of d ≈ 0.46** favouring spaced over massed practice across 63 studies and 112 effect sizes, with the advantage growing as the lag between sessions grew, for both free- and cued-recall tasks ([Donovan & Radosevich, 1999](https://psycnet.apa.org/doi/10.1037/0021-9010.84.5.795)) **[MA]**.
- The definitive verbal-recall synthesis — **839 assessments across 317 experiments in 184 articles** — confirmed distributed practice reliably beats massed practice in final-test retention ([Cepeda, Pashler, Vul, Wixted & Rohrer, 2006](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**.
- Independent reviews of evidence-based learning rate distributed practice as one of only **two "high-utility" techniques**, helping learners of every age and ability and transferring to real classrooms ([Dunlosky et al., 2013](https://journals.sagepub.com/doi/10.1177/1529100612453266)) **[MA]**.

**In practice.**
- The whole engine is premised on this: revision is *scheduled across days*, never collapsed into "do it until fluent today." A page recited once and marked Good does not graduate to "done"; it earns a *future* due date (PRD §7.6, §7.7).
- The catch-up planner re-spreads a missed backlog **over several days** rather than dumping it into one massed session, because a single heavy sitting yields fluency that does not hold (PRD §7.9; see §6 below).
- The user-facing science screen may state, in calm terms, that "revising across days retains far better than re-reading in one sitting," cited to Cepeda et al. 2006 **[MA]** and registered in [`CLAIMS.md`](CLAIMS.md).

**Anti-patterns — we will never:**
- Offer a "cram this juz today" mode that masses revision into one sitting and implies it is now secure.
- Treat a clean recitation as completion. Nothing is ever "finished with revision" (the never-"safe-to-drop" rule, PRD §7.12).

---

## 2. The optimal gap grows with the retention interval you want

**Statement.** There is no single best interval. The gap between reviews that maximises later recall is a *function of how long you intend to remember* — short horizons want short gaps, long horizons want long gaps. This is the mathematical permission for an old, solid juz to move from daily to weekly to monthly review while a freshly-consolidated one stays dense.

**Evidence.**
- The 2006 synthesis isolated two temporal variables earlier reviews had conflated — the **inter-study interval (ISI)**, the gap between study episodes, and the **retention interval (RI)**, the gap from last study to test — and concluded that *"the ISI producing maximal retention increased as retention interval increased"* ([Cepeda et al., 2006](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**.
- The most systematic long-horizon test — **1,354 participants** learning 32 facts, restudied after a gap of minutes to 105 days, tested after **7, 35, 70, or 350 days** — found the same: at every test delay, increasing the gap first raised then lowered recall, and the optimal gap *rose* with the retention interval (interpolated optima of roughly **3, 8, 12, and 27 days** for the four horizons) ([Cepeda, Vul, Rohrer, Wixted & Pashler, 2008](https://doi.org/10.1111/j.1467-9280.2008.02209.x)) **[EXP]**.
- The payoff is large and comes purely from *when* study time was placed, with total study time held constant: at the optimal gap, recall improved by **10%, 59%, 111%, and 77%** over massed practice for the four horizons ([Cepeda et al., 2008](https://doi.org/10.1111/j.1467-9280.2008.02209.x)) **[EXP]**.

**In practice.**
- The user chooses a **named cycle** (7-day khatm, 30-day, 60-day — PRD §15.1), which *is* their declared retention horizon. The engine never asks for a raw "gap" or a "retention slider"; tradition supplies the horizon, the math supplies the gaps within it.
- Phase thresholds (`NEAR_MIN_S ≈ 9 d`, `FAR_MIN_S ≈ 60 d`) and DSR stability growth encode "the gap widens as the page strengthens" directly: a New page is revisited in days, a mature Far page in weeks-to-months (PRD §7.4).
- Golden tests should assert that computed Far intervals for mature pages land in the **weeks-to-month** range, matching the ridgeline anchors (≈3 days for a 1-week horizon, ≈8–12 days for a 1–2-month horizon, ≈3–4 weeks for a ~1-year horizon), not in days (cramming) (PRD §20).

**Anti-patterns — we will never:**
- Hard-code one universal interval for all pages regardless of how long the user intends to hold them.
- Expose the horizon as a naked number; it is always a tradition-shaped named cycle.

---

## 3. The proportional gap shrinks — so mature pages rest, they are not reviewed forever-daily

**Statement.** While the *absolute* optimal gap grows with the horizon, as a *fraction* of that horizon it shrinks. A solid juz held for a year does not need reviewing every few days; the longer you have kept something, the smaller the slice of that span the next gap should be.

**Evidence.**
- In the temporal-ridgeline study the interpolated optima of ≈3, 8, 12, and 27 days were about **43%, 23%, 17%, and 8%** of their 7-, 35-, 70-, and 350-day retention intervals — the optimal gap "declined from about 20 to 40% of a 1-week test delay to about 5 to 10% of a 1-year test delay" ([Cepeda et al., 2008](https://doi.org/10.1111/j.1467-9280.2008.02209.x)) **[EXP]**.
- Pooling the 2009 multi-day data (test delays to 6 months) with the 2006 meta-analysis across 48 optimal-gap points, the optimal-gap-to-test-delay **ratio fell** as the horizon grew (≈1.0 at minute-scale delays, ≈0.1 at multi-day delays) ([Cepeda, Coburn, Rohrer, Wixted, Mozer & Pashler, 2009](https://doi.org/10.1027/1618-3169.56.4.236)) **[EXP]**.
- The mechanism is well understood: stability compounds, so each on-time review roughly multiplies the safe interval — the formal reason old juz can eventually be reviewed weekly or monthly ([Cepeda et al., 2008](https://doi.org/10.1111/j.1467-9280.2008.02209.x)) **[EXP]**; the DSR realisation of this compounding is in [`03-spaced-repetition-algorithms.md`](03-spaced-repetition-algorithms.md).

**In practice.**
- The three lifecycle phases are *not three algorithms* but stability bands of one card: a page graduates New → Near → Far as its stability rises, and the gap widens with it (PRD §6.2, §7.4). This is the shrinking-proportional-gap law expressed as graduation.
- The retention heat-map can show a mature juz resting comfortably without alarm — resting is correct, not neglect — while still never displaying "safe to drop" (PRD §12.5, §7.12).

**Anti-patterns — we will never:**
- Keep a long-stable page on a punishingly dense daily rota "just to be safe" — that is the steep, wasteful arm of the cost curve and breaks the daily budget (PRD §7.5).
- Confuse a page *resting* on a wide interval with a page being *abandoned*; the cycle ceiling still guarantees its return (PRD §7.6).

---

## 4. The cost asymmetry — too-short is punished far harder than too-long

**Statement.** The penalty for spacing reviews *too close together* is much larger than the penalty for spacing them *too far apart*. When the engine is uncertain, it should err toward reviewing **sooner**. This asymmetry is the empirical justification for the entire trust-clamp design.

**Evidence.**
- The single most design-relevant sentence in this literature: *"the penalty for a too-short gap is far greater than the penalty for a too-long gap"* — moving from minutes to the optimum produced a large gain, but lengthening *beyond* the optimum cost relatively little, while shortening *below* it was steeply harmful ([Cepeda et al., 2009](https://doi.org/10.1027/1618-3169.56.4.236)) **[EXP]**.
- Across both the 2008 and 2009 studies the gap function is a clear inverted-U: a too-long gap exists, but the falling arm is shallow compared with the cliff on the too-short side, and an optimal gap improved final recall by **up to 150%** ([Cepeda et al., 2009](https://doi.org/10.1027/1618-3169.56.4.236)) **[EXP]**.

**In practice.**
- This is the empirical backing for the **trust-clamp** `card.due_at = min(ideal_due, ceiling_due)` (PRD §7.6): the SR math may pull a page **forward** toward a harder, more valuable retrieval, but it can never push a memorized page's `due_at` past its cycle ceiling. Erring early is not over-caution — under the cost asymmetry it is *optimal*.
- The cold-start priors (Solid → S = 60 d, Shaky → S = 14 d, Rusty → S = 4 d) deliberately *under*-estimate strength so the first real recitation can only surprise upward (PRD §7.10). Better to over-review a held page early than to skip one the user has actually lost.
- Load-balancing may let a *low-urgency* page slip a day only while predicted retrievability stays above a hard floor; a page crossing the floor becomes mandatory and can no longer be deferred (PRD §7.9). Slipping is bounded on the cheap side of the asymmetry.

**Anti-patterns — we will never:**
- Let a memorized page's `due_at` exceed its cycle ceiling — this is a hard engine invariant (PRD §7.12).
- "Optimise away" reviews by stretching intervals aggressively to lighten the day; the asymmetry says that trade loses memory cheaply bought minutes can never buy back.

---

## 5. Expanding intervals are not magic — what matters is making the *first* review effortful

**Statement.** The folk belief that an *expanding* schedule (1, 2, 4, 7, 14 days…) is inherently superior is only half true. Expanding helps an *immediate* test; for *long-term* retention, equal-interval spacing is as good or better, and the real driver is that the **first** review after memorizing is delayed enough to be genuinely effortful — not the expanding shape of later reviews.

**Evidence.**
- The classic intuition comes from Landauer & Bjork's (1978) finding that expanding retrieval beat equal-interval on an immediate test ([Landauer & Bjork, 1978](https://www.gwern.net/docs/spaced-repetition/1978-landauer.pdf)) **[CS]**.
- But the careful factorial test overturned the simple version: comparing massed (0-0-0), expanding (1-5-9), and equal-interval (5-5-5) retrieval, **expanding helped a 10-minute test but equal-interval spacing was as good or better at a 2-day test**, and Experiment 3 isolated the cause — *"Delaying the first retrieval to make it more difficult … was the important factor in promoting long-term retention … Expanding the interval between repeated tests had little effect on long-term retention"* ([Karpicke & Roediger, 2007](https://doi.org/10.1037/0278-7393.33.4.704)) **[EXP]**.
- The unifying mechanism is the desirable-difficulty principle: a review done when the memory is *weaker* (lower retrievability) is harder in the moment but produces a larger durable gain, provided it still succeeds; near-perfect immediate fluency is "borrowed" from short-term memory and does not translate into long-term retention ([Karpicke & Roediger, 2007](https://doi.org/10.1037/0278-7393.33.4.704)) **[EXP]**. The retrieval side of this is developed in [`04-retrieval-practice-and-self-testing.md`](04-retrieval-practice-and-self-testing.md).

**In practice.**
- The engine does **not** chase a precisely engineered expanding ladder. It schedules by *predicted strength* (the DSR retrievability function), and a naturally widening schedule falls out of stability growth on its own (PRD §7.3, §7.4).
- The one place the "first review" finding bites hard: the New → Near (sabaq → sabqi) transition must ensure the first revision is spaced enough to be a *real* retrieval, not a same-day re-read. The reveal-on-tap recite flow makes that retrieval effortful by design (PRD §8.1, §12.2).
- This also frees the product from over-claiming: marketing copy and the science screen describe spacing and growing gaps, never a magic "1-2-4-7" ladder presented as the secret.

**Anti-patterns — we will never:**
- Sell a fixed "1-2-4-7-14" expanding schedule as the scientifically optimal one; the evidence does not support that claim for long-term retention.
- Make the first sabqi review a trivially-easy same-day re-read; that borrows fluency from short-term memory and teaches nothing durable.

---

## 6. Spacing survives in-session stumbles — a long-gap error is the difficulty working

**Statement.** The benefit of spacing holds *even when the wide gap causes the user to stumble or err in the moment*. A hesitation on a Far/manzil page that comes due near its ceiling is the desirable difficulty doing its job, not a scheduling bug — so it is graded honestly and never framed as shame.

**Evidence.**
- Across two experiments, larger lags sharply reduced in-session (second-test) performance yet markedly improved a later test — *"the benefit of spacing overwhelms any possible harmful effect of producing errors"* — and crucially the benefit held **even for items that had errored on the first test** ([Pashler, Zarow & Triplett, 2003](https://doi.org/10.1037/0278-7393.29.6.1051)) **[EXP]**.
- The same desirable-difficulty mechanism from §5 explains why: a harder, error-prone retrieval at a long gap, if it still ultimately succeeds, yields the larger durable gain ([Karpicke & Roediger, 2007](https://doi.org/10.1037/0278-7393.33.4.704)) **[EXP]**.

**In practice.**
- When a Far page is recited near its ceiling and the ḥāfiẓ stumbles, the lapse honestly shrinks stability and pulls the page forward (PRD §7.7) — the system self-corrects. This is the engine *learning the page is weaker*, exactly as intended.
- Copy frames the stumble as "this is how revision strengthens it," never "you are losing your hifz." Notifications and feedback stay calm and non-coercive (PRD R3, §14); the motivation evidence behind this is in [`09-motivation-without-coercion.md`](09-motivation-without-coercion.md).
- A self-corrected hesitation is graded **Hard**, a true prompted break is **Again** — the position and count of stumbles is the richest signal in hifz and drives weak-spot localisation (PRD §6.3, §7.7).

**Anti-patterns — we will never:**
- Shorten every interval to keep recitations always-easy and stumble-free; that maximises in-the-moment fluency at the expense of durable memory.
- Present a long-gap stumble as failure, guilt, or a broken streak (PRD R3, C6).

---

## 7. Wider gaps are *less* daily work, not more rigor — the honest budget framing

**Statement.** Spacing review wider is not a rigor setting that costs more effort; under the right horizon it delivers *equal durability for less total work*. A longer cycle is efficient, not lazy — and that is how the app must frame the trade so a busy ḥāfiẓ is never shamed for choosing it.

**Evidence.**
- The closest analogue to multi-year *murājaʿa*: a 9-year study in which 4 subjects relearned **300 foreign-language word pairs** across sessions spaced 14, 28, or 56 days found that **13 sessions spaced at 56 days yielded retention comparable to 26 sessions spaced at 14 days** — half the total effort at the wide gap matched the dense schedule's durability, and the spacing benefit was independent of session count and held regardless of item difficulty ([Bahrick, Bahrick, Bahrick & Bahrick, 1993](https://journals.sagepub.com/doi/10.1111/j.1467-9280.1993.tb00571.x)) **[CS]**.
- In a schooled, applied setting, distributing 10 maths problems across two sessions a week apart **roughly doubled** 4-week retention versus massing them, while extra same-session "overlearning" problems added nothing ([Rohrer & Taylor, 2006](https://doi.org/10.1002/acp.1266)) **[EXP]** — durable retention came from *distribution*, not from grinding more in one sitting (the overlearning question is taken up in [`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md)).

**In practice.**
- The load-balancer and budget feedback frame a longer cycle as *efficient*: the math lets a solid juz rest longer precisely so the daily list stays survivable, serving the finished-ḥāfiẓ and late-starter personas (P1/P3) without piling on work (PRD §7.9, §12.2).
- The honest trade-off the app surfaces is "slightly slower to feel fluent, much cheaper to keep" — never "you chose the lazy cycle." If a chosen scope cannot fit the budget, the app says so plainly and offers to lengthen the cycle, raise the budget, or pause new sabaq (PRD §12.2).
- The catch-up planner re-spreads a reactivated juz across several days because one massed sitting yields "misleadingly high immediate mastery" that decays fast (Cepeda et al. 2008; Rohrer & Taylor 2006) — and tells the user so plainly (PRD §7.9).

**Anti-patterns — we will never:**
- Frame a wider, lighter cycle as a compromise on devotion or a "less serious" choice.
- Reward dense daily grinding as if more sessions automatically meant more retention; the evidence says distribution, not volume, is what holds.

---

## A note on honesty and the limits of this evidence

The long-horizon spacing data stop at months-to-a-few-years and were collected on novel verbal facts, not on near-100%-mastery *serial recall* of a sacred text under interference (the serial-recall adaptation is in [`07-serial-recall-and-the-page-unit.md`](07-serial-recall-and-the-page-unit.md), interference in [`05-interference-and-mutashabihat.md`](05-interference-and-mutashabihat.md)). So the engine treats the spacing *constants* as priors — fitted over time from the user's own lapse history (PRD §7.3) — and delivers its retention *guarantee* structurally, through the cycle ceiling, not through a probability claim (PRD §7.5). The app may say spacing retains "far better," never that it retains "99%." This is the science foundation's honesty pillar applied to its own strongest finding.

---

## References

Only sources cited in this file are listed here; the deduplicated, graded master is in [`REFERENCES.md`](REFERENCES.md).

- Bahrick, H. P., Bahrick, L. E., Bahrick, A. S., & Bahrick, P. E. (1993). *Maintenance of foreign language vocabulary and the spacing effect.* Psychological Science, 4(5), 316–321. https://journals.sagepub.com/doi/10.1111/j.1467-9280.1993.tb00571.x — **[CS]**
- Cepeda, N. J., Coburn, N., Rohrer, D., Wixted, J. T., Mozer, M. C., & Pashler, H. (2009). *Optimizing distributed practice: Theoretical analysis and practical implications.* Experimental Psychology, 56(4), 236–246. https://doi.org/10.1027/1618-3169.56.4.236 — **[EXP]**
- Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2006). *Distributed practice in verbal recall tasks: A review and quantitative synthesis.* Psychological Bulletin, 132(3), 354–380. https://www.yorku.ca/ncepeda/publications/CPVWR2006.html — **[MA]**
- Cepeda, N. J., Vul, E., Rohrer, D., Wixted, J. T., & Pashler, H. (2008). *Spacing effects in learning: A temporal ridgeline of optimal retention.* Psychological Science, 19(11), 1095–1102. https://doi.org/10.1111/j.1467-9280.2008.02209.x — **[EXP]**
- Donovan, J. J., & Radosevich, D. J. (1999). *A meta-analytic review of the distribution of practice effect: Now you see it, now you don't.* Journal of Applied Psychology, 84(5), 795–805. https://psycnet.apa.org/doi/10.1037/0021-9010.84.5.795 — **[MA]**
- Dunlosky, J., Rawson, K. A., Marsh, E. J., Nathan, M. J., & Willingham, D. T. (2013). *Improving students' learning with effective learning techniques: Promising directions from cognitive and educational psychology.* Psychological Science in the Public Interest, 14(1), 4–58. https://journals.sagepub.com/doi/10.1177/1529100612453266 — **[MA]**
- Ebbinghaus, H. (1885/1964). *Memory: A Contribution to Experimental Psychology* (H. A. Ruger & C. E. Bussenius, Trans.). New York: Dover. https://archive.org/details/memorycontributi00ebbiuoft — **[CS]**
- Karpicke, J. D., & Roediger, H. L. III (2007). *Expanding retrieval practice promotes short-term retention, but equally spaced retrieval enhances long-term retention.* Journal of Experimental Psychology: Learning, Memory, and Cognition, 33(4), 704–719. https://doi.org/10.1037/0278-7393.33.4.704 — **[EXP]**
- Landauer, T. K., & Bjork, R. A. (1978). *Optimum rehearsal patterns and name learning.* In M. M. Gruneberg, P. E. Morris, & R. N. Sykes (Eds.), *Practical Aspects of Memory* (pp. 625–632). London: Academic Press. https://www.gwern.net/docs/spaced-repetition/1978-landauer.pdf — **[CS]**
- Pashler, H., Zarow, G., & Triplett, B. (2003). *Is temporal spacing of tests helpful even when it inflates error rates?* Journal of Experimental Psychology: Learning, Memory, and Cognition, 29(6), 1051–1057. https://doi.org/10.1037/0278-7393.29.6.1051 — **[EXP]**
- Rohrer, D., & Taylor, K. (2006). *The effects of overlearning and distributed practice on the retention of mathematics knowledge.* Applied Cognitive Psychology, 20(9), 1209–1224. https://doi.org/10.1002/acp.1266 — **[EXP]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
