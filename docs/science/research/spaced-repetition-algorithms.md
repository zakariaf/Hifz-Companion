# Spaced-Repetition Algorithms — Research Note

**Topic:** The family of spaced-repetition (SR) scheduling algorithms and how each decides *when* to review: the Leitner box system, SuperMemo SM-2, the modern SuperMemo two-component model (SM-17/18), the open FSRS model (Difficulty / Stability / Retrievability), and Duolingo's half-life regression (HLR). What each one actually computes, the exact forgetting-curve math, how a *desired-retention* target sets the interval, what the head-to-head benchmark evidence says about accuracy, and which parts transfer to a whole-page Quran-revision engine versus which break.

**Compiled:** 2026-06-16 · Science research agent, Hifz Companion

> Evidence grades (per blueprint §3, best → weakest among empirical): **[MA]** meta-analysis/systematic review · **[RCT]** randomized experiment · **[EXP]** controlled cognitive experiment · **[CS]** classic foundational study · **[OBS]** observational/applied/field study (here: large-scale real-world review datasets and operational A/B tests) · **[TEXT]** textbook/expert review/algorithm documentation. Algorithm specifications themselves are graded **[TEXT]** (they are engineering documentation, not empirical claims); the *behavioural* results that justify them carry the empirical grade.

This note is the evidence dossier behind synthesis doc `03-spaced-repetition-algorithms.md`. It distils the engine math the PRD specifies in §7 (the FSRS-style DSR backbone, the trust clamp, stakes-tiered retention) down to its sources, and it is a sibling to `research/forgetting-curve.md` (the decay model these algorithms invert) and `research/spacing-effect.md` (the behavioural law they exploit). The recurring thesis: **all five algorithms exist to invert a forgetting curve, but only the two-component (S, R) models reason about *how overdue is acceptable*, which is exactly what a never-let-a-page-rot scheduler needs.**

---

## What the evidence says

### 1. Every SR algorithm is a machine for inverting a forgetting curve

The shared root is Ebbinghaus: memory of newly learned material decays over time unless reviewed, and **distributing reviews over time beats massing them** (the spacing effect). Ebbinghaus established this on himself with nonsense syllables, measuring *savings* in relearning, and published it in 1885 as *Über das Gedächtnis* (translated 1913 as *Memory: A Contribution to Experimental Psychology*) ([Ebbinghaus 1885/1913](https://en.wikipedia.org/wiki/Forgetting_curve)) **[CS]**. The modern quantitative warrant for *spacing* specifically is the Cepeda meta-analysis of distributed practice: **839 assessments across 317 experiments in 184 articles**, which found that the inter-study interval producing maximal retention *grows as the retention interval grows* — i.e. the optimal gap is not a constant but expands with how long you need to remember ([Cepeda, Pashler, Vul, Wixted & Rohrer 2006, *Psychological Bulletin* 132(3):354](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**. Every algorithm below is a different way of estimating, per item, where that expanding gap currently sits. The relevance to Hifz is direct: the traditional day-1 / day-2 / day-4 / day-7 / day-14 / monthly murājaʿa ladder (RESEARCH-FINDINGS §1) *is* an expanding-interval schedule hand-tuned over centuries.

### 2. Leitner (1972): the discrete ancestor — boxes, promote-on-correct, demote-on-error

The Leitner system, devised by German science journalist Sebastian Leitner in his 1972 book *So lernt man lernen* ("How to learn to learn"), is the physical, no-computer implementation of expanding intervals. Cards live in (typically five) boxes reviewed at increasing cadences — a popular electronic variant uses intervals of **1, 2, 4, 8, 16 days**. **A correct answer promotes a card one box (longer interval); any error demotes it back to box 1 (daily review)** ([Leitner system, Wikipedia](https://en.wikipedia.org/wiki/Leitner_system)) **[TEXT]**. Its strengths are its honesty and zero-maths simplicity; its fatal weaknesses for Hifz are two: (a) the interval ladder is **fixed and identical for every card** — it cannot reason that one page is far weaker than another; and (b) **a single slip resets the whole item to box 1**, which for a 604-page corpus where a ḥāfiẓ may stumble on 2 of 15 lines is brutally lossy (RESEARCH-FINDINGS §3). Leitner is the right *mental model* (boxes ≈ tracks) and the wrong *engine*.

### 3. SuperMemo SM-2 (1987): the ease-factor algorithm that seeded a generation

SM-2, authored by Piotr Woźniak and used in SuperMemo since 1987 (published openly in his 1990 master's thesis), is the algorithm behind Anki's classic scheduler and most "SR" flashcard apps. Its specification is small enough to quote in full ([Woźniak, *SuperMemo 2: Algorithm*](https://super-memory.com/english/ol/sm2.htm)) **[TEXT]**:

- Intervals: `I(1) = 1`, `I(2) = 6`, and for `n > 2`, `I(n) = I(n-1) × EF`.
- Each item carries an **E-Factor (ease)** starting at **2.5**, updated from a 0–5 recall-quality grade `q` by `EF' = EF + (0.1 − (5−q)·(0.08 + (5−q)·0.02))`, floored at **1.3**.
- The quality scale is graded, not binary: 5 = perfect, 4 = correct after hesitation, 3 = correct with serious difficulty, 2/1/0 = increasingly bad failures.
- **On any grade below 3 (a lapse), repetitions reset to the start (interval back to 1 day), but the E-Factor is left unchanged.**

SM-2's lasting contribution is the *multiplicative* interval (each success roughly multiplies the safe gap — the formal basis for why mature juz can eventually be reviewed monthly). Its limitation, decisive for our use, is that **SM-2 has no explicit retrievability and no spacing-effect term**: it cannot answer "how overdue is this page, and how much extra stability would a review *now* buy?" ([dev.to: How the SM-2 algorithm works](https://dev.to/umangsinha12/how-spaced-repetition-actually-works-the-sm-2-algorithm-1ge3)) **[TEXT]**. It schedules from a fixed ease, not from a model of memory state.

### 4. SuperMemo's two-component model (SM-17, 2016): stability and retrievability become first-class

The modern SuperMemo algorithms abandon the single ease factor for an explicit **two-component model of long-term memory**, theoretically grounded by Woźniak with Murakowski and Gorzelańczyk and proven (1995) to require exactly two variables to describe memory status in spaced repetition ([Woźniak: *Two components of memory*](https://supermemo.guru/wiki/Two_components_of_memory)) **[TEXT]**:

- **Retrievability (R)** — "how easy it is to retrieve a memory trace (i.e. recall it)" right now; a probability that decays with time.
- **Stability (S)** — "how long a memory trace can last in memory"; the durability that determines how slowly R decays.

Two properties of this model are exactly the dynamics a Hifz engine must respect: **(1) reviews have little power to increase stability while retrievability is still high** (reviewing too early wastes effort — the spacing effect, formalised); and **(2) on forgetting, stability declines rapidly** (a lapse genuinely sets you back) ([*Two components of memory*](https://supermemo.guru/wiki/Two_components_of_memory)) **[TEXT]**. SM-17 (introduced in SuperMemo 17, 2016) operationalises this with a **stability-increase function `SInc(D, S, R)`** read from data matrices: the stability gain on a successful review is largest when retrievability is *low* — i.e. reviewing a page when it is genuinely at risk buys the most durability ([Wikipedia: SuperMemo](https://en.wikipedia.org/wiki/SuperMemo); [*Algorithm SM-17*](https://supermemo.guru/wiki/Algorithm_SM-17)) **[TEXT]**. SM-18 (2019) refined the difficulty estimation. This (S, R) framing is the direct ancestor of FSRS and the model the PRD's engine adopts.

### 5. FSRS: the open, trainable DSR instantiation — the engine the PRD builds on

FSRS (Free Spaced Repetition Scheduler) is the open-source, free-licence successor that makes the two-component model trainable on logs. It descends from MaiMemo's DHP model, itself a variant of Woźniak's DSR model, and carries three per-card state variables ([FSRS repo](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler); [The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)) **[TEXT]**:

- **Difficulty (D)** ∈ [1, 10] — inherent hardness; higher D *dampens* the stability gain per review.
- **Stability (S)** — "the amount of time required for R to decrease from 100% to 90%," measured in days.
- **Retrievability (R)** — current probability of recall.

From FSRS-4.5 onward the forgetting curve is a **power law** (a better empirical fit than the older exponential `0.9^(t/S)` of FSRS v3):

```
R(t, S) = (1 + FACTOR · t / S) ^ DECAY      with DECAY = −0.5, FACTOR = 19/81
```

so that **R = 0.9 exactly when elapsed time t equals stability S** — that is the definition of S ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm); [expertium.github.io/Algorithm.html](https://expertium.github.io/Algorithm.html)) **[TEXT]**. On a successful review, `S' = S × SInc` where the increase is *larger when D is low, S is low, and R is low* — the same "review-when-weak pays most" dynamic as SM-17, and the same `e^{w·(1−R)}` desirable-difficulty term Bjork's storage-vs-retrieval-strength work predicts (RESEARCH-FINDINGS §3). On a lapse, post-lapse stability is forced to `min(…, S)` so a lapse can **never** increase stability ([expertium.github.io/Algorithm.html](https://expertium.github.io/Algorithm.html)) **[TEXT]**. FSRS is versioned and the parameter count has grown: **FSRS-4.5 has 17 trainable weights, FSRS-5 has 19, FSRS-6 has 21** ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)) **[TEXT]**. These constants (DECAY = −0.5, FACTOR = 19/81) are exactly the ones the PRD hard-codes in §7.3.

### 6. Desired retention is the one knob: it sets the interval by inverting the curve

The single most important design lever in every (S, R) model is **desired (requested) retention** `r` — the recall probability you are willing to accept before re-reviewing. FSRS computes the next interval by inverting the forgetting curve at `r`:

```
I(r, S) = (S / FACTOR) · (r^(1/DECAY) − 1)
```

so **at r = 0.9 the interval equals S**, and a higher `r` shortens it by a fixed *multiplier* ([The Algorithm wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm); [expertium.github.io/Algorithm.html](https://expertium.github.io/Algorithm.html)) **[TEXT]**. The default desired retention is **0.9 (90%)** ([fsrs4anki tutorial](https://github.com/open-spaced-repetition/fsrs4anki/blob/main/docs/tutorial.md)) **[TEXT]**. Crucially the cost of higher retention is real, super-linear, but *bounded*: empirically, going **90% → 95% roughly doubles daily reviews and ~97% roughly quadruples** them, rising sharply toward 1.0 (RESEARCH-FINDINGS §3, with the directly computable multipliers `0.448·S` at 0.95, `0.266·S` at 0.97, `0.087·S` at 0.99 versus `S` at 0.90). FSRS therefore distinguishes *desired* retention (a user choice) from **optimal retention** — the value that minimises the *workload-to-knowledge ratio*, found numerically (Brent's method) because pushing `r` too high explodes review load while pushing it too low forces costly relearning ([The optimal retention](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention)) **[TEXT]**. This is the precise mechanism the PRD's stakes-tiered retention (§7.5) and trust clamp (§7.6) exploit: set `r` *per phase and per stakes* (0.90 New → 0.95 Far → 0.97+ for prayer-critical/weak pages), and clamp the resulting interval to the cycle ceiling so the math may only ever pull a page *forward*.

### 7. Duolingo half-life regression (HLR, 2016): the same curve, fitted by regression at web scale

HLR, from Duolingo's production language app, is a fourth point in the design space: keep a simple exponential forgetting curve but *learn its half-life from data*. Its model is explicit ([Settles & Meeder 2016, *Proc. ACL*, pp. 1848–1858](https://research.duolingo.com/papers/settles.acl16.pdf)) **[OBS]**:

- Recall probability `p = 2^(−Δ / h)`, where Δ is the lag (time since last practice) and `h` is the item's **half-life** (the strength of the memory trace — the direct analogue of stability; at Δ = h, p = 0.5).
- Half-life is estimated from features: `ĥ_Θ = 2^(Θ · x)`, where `x` is a feature vector (counts of times the word was seen / recalled correctly / recalled incorrectly, plus per-item lexeme tags) and `Θ` are weights fitted by gradient descent.
- The loss function fits *both* the observed recall rate and an algebraic half-life estimate simultaneously: `ℓ = (p − p̂)² + α·(h − ĥ)² + λ‖Θ‖²`.

HLR's reported results on **12.9 million Duolingo student-word practice sessions**: it cut mean absolute error by **45%+** versus the Leitner and Pimsleur baselines that Duolingo previously ran (MAE 0.128 for HLR vs **0.235 for Leitner** and **0.445 for Pimsleur**), and an operational A/B test on just under 1 million students improved daily engagement by **12%** ([Settles & Meeder 2016](https://research.duolingo.com/papers/settles.acl16.pdf)) **[OBS]**. The paper explicitly shows that **Leitner and Pimsleur are special cases of HLR with fixed, hand-picked weights** — formal confirmation that the older box/ladder systems are crude instances of a fittable curve. Two cautions, stated in the paper itself, matter for us: HLR's per-item lexeme features *over-fit* and were dropped in production; and HLR models a single exponential curve, weaker than the power-law / multi-scale forms that fit long-horizon retention better.

### 8. The head-to-head benchmark: (S, R) models clearly beat ease-factor and regression models — but accuracy is not the binding constraint for Hifz

The open `srs-benchmark` evaluates algorithms on real review logs at a scale no Hifz project will ever match: **~727 million reviews from 10,000 users (≈350M used for evaluation after excluding same-day reviews), and a larger ~1.7-billion-review set from 20,000 users.** Ranked by RMSE(bins) (lower = better calibrated), the modern models dominate: **FSRS-6 ≈ 0.065 and FSRS-7 ≈ 0.063**, versus **HLR ≈ 0.128** and **Ebisu v2 ≈ 0.163**; pure sequence models (LSTM/RWKV) edge slightly ahead of FSRS but at far greater complexity ([srs-benchmark](https://github.com/open-spaced-repetition/srs-benchmark)) **[OBS]**. The ordering — FSRS ≫ HLR ≫ older heuristics — confirms the literature thesis: **two-component (S, R) models predict recall markedly better than ease-factor (SM-2) or single-half-life (HLR) models.** But two qualifications govern how much we should care. First, this benchmark measures *flashcard recognition*, not *serial recall of contiguous sacred text* — the dominant Hifz failure is **interference (mutashābihāt), which none of these algorithms model** (RESEARCH-FINDINGS §3). Second, the PRD's design deliberately **does not depend on the curve's precision**: because the trust clamp (§7.6) guarantees every page is recited at least once per chosen cycle regardless of what the math predicts, a mis-estimated stability can only cause *over*-review (harmless to retention, costly only to time), never silent decay. Accuracy buys *efficiency* here, not *safety*.

### 9. Where the algorithms agree, and where they diverge for Hifz

- **Consistent across all five:** memory decays on a curve; reviews should be spaced and the gap should expand as the item strengthens; reviewing when the memory is *weaker* (lower R) buys more durability than reviewing when it is fresh (the spacing / desirable-difficulty effect, from Cepeda 2006 and the two-component property in §4). Every algorithm is a way to estimate the next gap.
- **The real divide is whether the model carries explicit (S, R) state.** Leitner (fixed ladder) and SM-2 (single ease) do *not*, so they cannot reason about how overdue a page is or how much a timely review helps — they over-review easy pages and under-protect weak ones. SM-17/18, FSRS and (partly) HLR *do*, and the benchmark (§8) shows that this materially improves recall prediction.
- **None models interference or serial-recall chaining.** All five assume independent items recalled in isolation. For Hifz this is the decisive gap: mutashābihāt confusion *worsens* as the corpus grows, the opposite of decay, and cannot be represented by any single-item curve (RESEARCH-FINDINGS §3). This is an *extension* the engine must add, not a parameter any off-the-shelf algorithm provides.
- **Retention target is the lever, and 90% is far too low for sacred text.** All these systems default to ~0.85–0.90 because that minimises workload-per-knowledge. One-in-ten pages wrong is unacceptable in ṣalāh — so Hifz must run retention high and *stakes-tiered*, and lean on the cycle ceiling (not a fragile probability) for the near-100% guarantee.

---

## Implications for Hifz Companion

Numbered, concrete decisions for the engine (PRD §7) and the in-app science copy. Items marked **MUST NOT** are hard constraints.

1. **Build on the FSRS-style DSR backbone, not Leitner or SM-2.** Carry per-page **D ∈ [1,10], S (days), R (probability)** with the power-law curve `R(t,S) = (1 + (19/81)·t/S)^(−0.5)` and interval `I(r,S) = (S/(19/81))·(r^(1/−0.5) − 1)`, exactly as PRD §7.3. Rationale: only (S, R) models reason about overdue-ness, and they win the benchmark decisively over SM-2/HLR (§5, §8). The constants are a *starting prior*, tunable from the user's own lapse logs by plain curve-fitting — no ML service, no network (PRD C1/C2).

2. **MUST NOT inherit Leitner's all-or-nothing demotion.** A single stumbled line must not reset an otherwise-solid page to "box 1." Model a lapse as a *stability shrink* (post-lapse `S` clamped to `min(…, S)`, never higher) plus a difficulty bump, and localise the weakness to the erring lines rather than nuking the page (PRD §7.7). Leitner's promote/demote is the right metaphor for the three *tracks*, not for the per-page math (§2).

3. **Keep "desired retention" as the one true knob, and set it by phase and stakes — never expose it as a slider.** Use `r ≈ 0.90` for New, `0.94` Near, `0.95` Far ordinary, `0.97+` for prayer-critical / weak / previously-lapsed pages (PRD §7.5). The interval-from-retention formula makes each tier a fixed multiplier of `S`, so the cost is predictable and bounded (§6). Users pick a *named cycle*, not a retention number (PRD design principle 1).

4. **MUST NOT chase a global 0.99.** Pushing every page to 99% is ~11× the 90% review load across 604 pages and will blow the daily budget, breaking trust faster than an occasional stumble (RESEARCH-FINDINGS §3). Near-100% retention comes from the **cycle ceiling (the trust clamp), not the probability target** (PRD §7.6).

5. **The trust clamp is what makes algorithmic imprecision safe — keep it inviolable.** Because every memorized page's `due_at = min(ideal_due, ceiling_due)`, the curve can only ever pull a page *forward*, never past its cycle ceiling (§8). This means a wrong stability estimate causes at worst harmless over-review, never silent decay — the engine's correctness does not depend on the constants being exactly right (PRD §7.6, §7.12).

6. **Steal HLR's lesson, not its model: fit from the user's own logs, but use the power-law curve.** HLR proves a forgetting curve can be fitted to real behaviour and that doing so beats fixed-weight heuristics by 45%+ MAE (§7). But HLR's single exponential and per-item lexeme features over-fit even at Duolingo's scale. We have *one* user's logs, not millions — so fit only the global curve constants conservatively from aggregate lapse history, and **MUST NOT** add per-page learned features that would over-fit a sparse personal log (§7).

7. **Treat the page as the card, with a sub-page weak-line overlay — no algorithm here gives you that for free.** All five algorithms schedule independent atomic items; Hifz recites whole pages in serial-recall flow. Schedule at the page level (604 cards) for feasibility and carry a derived per-line error vector only to localise weakness and seed mutashābihāt links (PRD §7.1, §7.7). This is an adaptation *on top of* FSRS, not something FSRS provides.

8. **Add the interference layer the algorithms omit — it is the biggest Hifz-specific gap.** No SR algorithm (Leitner, SM-2, SM-17/18, FSRS, HLR) models cross-item interference, yet mutashābihāt confusion is the dominant advanced-ḥāfiẓ failure and *grows* with the corpus (§9; RESEARCH-FINDINGS §3). Implement a confusable-pairs graph with interleaved discrimination drills and a confusion score that raises difficulty `D` on all group members — which, via the standard `(11−D)` damping, automatically shortens their intervals (PRD §9).

9. **Map the recitation grade to the SM-2/FSRS 4-level scale, but enrich it with error position.** The Again/Hard/Good/Easy grades (PRD §6.3) align with FSRS's G = 1..4 and SM-2's 0–5 quality scale (§3, §5). The valuable extra signal — *which lines* the user stumbled on — has no analogue in any flashcard algorithm and is what drives weak-spot localisation. A dropped/swapped sacred word **MUST NOT** be graded "Good" (PRD §7.7 sacred-text guard).

10. **Frame tradition as the validated original, the algorithm as its adaptive refinement — for the in-app science screen.** The day-1/2/4/7/14/monthly murājaʿa ladder, the 7-manzil weekly khatm, and the "5:1 review-to-new" rule are hand-tuned expanding-interval schedules — Leitner and Pimsleur are themselves special cases of a fittable curve (§7), and the spacing law they embody is meta-analytically established (§1, Cepeda 2006). Honest copy: *"The traditional revision cycle already is spaced repetition; the app only re-orders within it, pulling weaker pages forward, and never lets a page drift past your chosen cycle."* **MUST NOT** present the algorithm as superseding the teacher or the tradition (PRD R6, §7.11 pure-cycle mode).

11. **For the conservative/ulama user, offer pure-cycle mode — the SR math fully off.** Some users distrust any reordering. A fixed-rotation mode (Leitner-like, no pull-forward) turns the app into a faithful traditional tracker with only load-balancing and catch-up (PRD §7.11). The (S, R) engine is then opt-in, and the design above degrades gracefully to it.

---

## Citations

1. Ebbinghaus H (1885; English transl. 1913). *Über das Gedächtnis* / *Memory: A Contribution to Experimental Psychology.* Columbia University, New York. (Forgetting curve and spacing effect; nonsense-syllable savings method.) https://en.wikipedia.org/wiki/Forgetting_curve — **[CS]**

2. Cepeda NJ, Pashler H, Vul E, Wixted JT, Rohrer D (2006). *Distributed Practice in Verbal Recall Tasks: A Review and Quantitative Synthesis.* Psychological Bulletin 132(3):354–380. (839 assessments / 317 experiments / 184 articles; optimal inter-study interval expands with retention interval.) https://www.yorku.ca/ncepeda/publications/CPVWR2006.html — **[MA]**

3. Leitner S (1972). *So lernt man lernen.* Verlag Herder, Freiburg. Summarised with the standard electronic five-box variant (intervals 1/2/4/8/16 days; promote-on-correct, demote-to-box-1-on-error). https://en.wikipedia.org/wiki/Leitner_system — **[TEXT]**

4. Woźniak PA (1990; SM-2 in use since 1987). *SuperMemo 2: Algorithm.* (Intervals I(1)=1, I(2)=6, I(n)=I(n-1)·EF; E-Factor start 2.5, floor 1.3, update EF′=EF+(0.1−(5−q)·(0.08+(5−q)·0.02)); 0–5 quality scale; lapse below 3 resets interval, EF unchanged.) https://super-memory.com/english/ol/sm2.htm — **[TEXT]**

5. Sinha U (2021). *How spaced repetition actually works: the SM-2 algorithm.* dev.to. (Clear restatement of the SM-2 formulas and their no-retrievability limitation.) https://dev.to/umangsinha12/how-spaced-repetition-actually-works-the-sm-2-algorithm-1ge3 — **[TEXT]**

6. Woźniak PA, Murakowski J, Gorzelańczyk EJ. *Two components of memory.* supermemo.guru. (Two-component model: retrievability = ease of recall now; stability = how long the trace lasts; reviews don't raise stability while R is high; stability falls fast on forgetting; theoretically derived 1995.) https://supermemo.guru/wiki/Two_components_of_memory — **[TEXT]**

7. Woźniak PA. *Algorithm SM-17.* supermemo.guru. (Operationalises the two-component model with the stability-increase function SInc(D, S, R); stability gain largest when retrievability is low.) https://supermemo.guru/wiki/Algorithm_SM-17 — **[TEXT]**

8. *SuperMemo* (encyclopedia entry). Wikipedia. (Version history: SM-2 released 1987; SM-17 in SuperMemo 17, 2016, first to incorporate the two-component model.) https://en.wikipedia.org/wiki/SuperMemo — **[TEXT]**

9. Open Spaced Repetition. *Free Spaced Repetition Scheduler (FSRS)* — repository. (Open, trainable DSR model from MaiMemo's DHP / Woźniak's DSR; runs entirely locally; stability increase falls with higher D, S, and R.) https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler — **[TEXT]**

10. Open Spaced Repetition. *The Algorithm* — awesome-fsrs wiki. (Definitions of D/S/R; power-law curve R(t,S)=(1+FACTOR·t/S)^DECAY with DECAY=−0.5, FACTOR=19/81, R=0.9 at t=S; interval I(r,S)=(S/FACTOR)(r^(1/DECAY)−1); parameter counts FSRS-4.5=17, FSRS-5=19, FSRS-6=21.) https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm — **[TEXT]**

11. Expertium. *FSRS Algorithm.* (Definitions of retrievability, stability, difficulty; interval equals stability at 90% desired retention; post-lapse stability forced to min(…, S); power-curve fit better than exponential.) https://expertium.github.io/Algorithm.html — **[TEXT]**

12. Open Spaced Repetition. *fsrs4anki tutorial* and *The optimal retention* wiki. (Default desired retention 0.9; higher retention → shorter intervals → exponentially more reviews; "optimal retention" minimises workload-to-knowledge ratio, found via Brent's method.) https://github.com/open-spaced-repetition/fsrs4anki/blob/main/docs/tutorial.md · https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention — **[TEXT]**

13. Settles B, Meeder B (2016). *A Trainable Spaced Repetition Model for Language Learning.* Proceedings of the 54th Annual Meeting of the Association for Computational Linguistics (ACL), Berlin, pp. 1848–1858. (Half-life regression: p=2^(−Δ/h), ĥ=2^(Θ·x), combined loss; on 12.9M sessions cut MAE 45%+ vs baselines — HLR 0.128 vs Leitner 0.235, Pimsleur 0.445; +12% daily engagement in a ~1M-student A/B test; Leitner & Pimsleur shown to be fixed-weight special cases of HLR.) https://research.duolingo.com/papers/settles.acl16.pdf · code/data: https://github.com/duolingo/halflife-regression — **[OBS]**

14. Open Spaced Repetition. *srs-benchmark* — benchmark of spaced-repetition algorithms. (~727M reviews / 10,000 users for evaluation, plus a ~1.7-billion-review / 20,000-user set; RMSE(bins) ranking FSRS-6/7 ≈ 0.063–0.065 ≪ HLR ≈ 0.128 ≪ Ebisu v2 ≈ 0.163; neural models marginally ahead of FSRS.) https://github.com/open-spaced-repetition/srs-benchmark — **[OBS]**
