# Spaced-Repetition Algorithms

This file documents the algorithm family the Hifz Companion engine adapts, and how it converts memory science into a date on a calendar. It traces the lineage from the **Leitner box** (a fixed interval ladder), through **SuperMemo SM-2** (the ease-factor algorithm behind a generation of flashcard apps), to the modern **two-component (Stability, Retrievability) models** — SuperMemo's SM-17/18 and the open, trainable **FSRS** — that the PRD's scheduler is built on, with **Duolingo's half-life regression** as a fitted-from-data fourth point in the design space. The thesis running through it: every one of these algorithms is a machine for inverting a forgetting curve, but only the ones that carry explicit Stability/Retrievability state can reason about *how overdue a page is and how much a timely review buys* — which is exactly what a "never silently lose the Quran" scheduler needs. It is the silent engine under the visible *sabaq / sabqi / manzil* surface; the math never reaches the user as a "retention slider." This doc distils [research/spaced-repetition-algorithms.md](research/spaced-repetition-algorithms.md) and builds directly on its two siblings — [01-memory-and-forgetting.md](01-memory-and-forgetting.md) (the decay curve these algorithms invert) and [02-the-spacing-effect.md](02-the-spacing-effect.md) (the behavioural law they exploit) — and feeds the engine spec in [PRD §7](../PRD.md) and the [in-app science screen](11-the-in-app-science-screen.md).

> **Evidence grades (per [blueprint §3](../_DOC-SET-BLUEPRINT.md), best → weakest among empirical):** **[MA]** meta-analysis/systematic review · **[RCT]** randomized experiment · **[EXP]** controlled cognitive experiment · **[CS]** classic foundational study · **[OBS]** observational/applied/field study (here: large real-world review datasets and operational A/B tests) · **[TEXT]** textbook/expert review/algorithm documentation · **[TRAD]** named traditional/scholarly Islamic source. Algorithm *specifications* are graded **[TEXT]** (they are engineering documentation, not empirical claims); the *behavioural* results that justify them carry the empirical grade.

> **Rules that bind everything below.** The algorithm is **demoted to a page-selector inside a fixed traditional day** ([PRD §2](../PRD.md)): it may only ever pull a page *forward* (more frequent), never push it past the user's chosen cycle ceiling, and is forbidden from ever telling a ḥāfiẓ a page is "safe to drop" ([PRD §7.6, §7.12](../PRD.md)). Desired retention is set *for the user* by phase and stakes — it is **never** exposed as a slider. A teacher's *talaqqī* sign-off always supersedes the math ([PRD §8.2](../PRD.md), R6).

---

## At a glance — the algorithm family

| Algorithm | Year | Memory state per item | Sets the interval by | Why it is / isn't our engine |
|---|---|---|---|---|
| **Leitner boxes** | 1972 | a box number (5 boxes) | a fixed ladder (e.g. 1/2/4/8/16 d); promote on pass, reset to box 1 on any slip | Right *metaphor* for the three tracks; wrong engine — one slip nukes a 15-line page. |
| **SuperMemo SM-2** | 1987 | a single ease factor (EF) | `I(n) = I(n−1)·EF` from a fixed ease | The multiplicative-interval insight, but no model of *how overdue* a page is. |
| **SuperMemo SM-17/18** | 2016/19 | Stability + Retrievability (+Difficulty) | inverting a fitted forgetting curve at a target R | The two-component model the PRD adopts; closed-source. |
| **FSRS** | 2022– | Difficulty, Stability, Retrievability (DSR) | inverting a power-law curve at *desired retention* | **The engine** ([PRD §7.3](../PRD.md)) — open, trainable, runs fully on-device. |
| **Duolingo HLR** | 2016 | one half-life, fitted by regression | `p = 2^(−Δ/h)`, half-life learned from features | A lesson (fit from logs), not a model we adopt — single exponential, over-fits. |

---

## 1. Every SR algorithm is a machine for inverting a forgetting curve

**Statement.** All five algorithms below exist to answer one question — *when should this be reviewed again?* — and they all answer it the same way in principle: estimate how the memory decays over time, then schedule the next review for the moment recall is predicted to drop to an acceptable level. They differ only in how well they model the curve and the memory's current state.

**Evidence.**
- The shared root is Ebbinghaus: newly learned material decays over time unless reviewed, measured as *savings* on relearning, published in 1885 ([Ebbinghaus, 1885/1913](https://en.wikipedia.org/wiki/Forgetting_curve)) **[CS]** — and his forgetting curve was reproduced 130 years later in an independent replication ([Murre & Dros, 2015, *PLOS ONE*](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644)) **[EXP]**. Decay is the premise every algorithm answers to; see [01-memory-and-forgetting.md](01-memory-and-forgetting.md).
- The quantitative warrant for *spacing* — distributing reviews beats massing them, and the optimal gap *grows as the required retention interval grows* — is the definitive synthesis of **839 assessments across 317 experiments in 184 articles** ([Cepeda et al., 2006, *Psychological Bulletin*](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]**. That expanding gap is the behavioural law all five algorithms try to track per item; see [02-the-spacing-effect.md](02-the-spacing-effect.md).

**In practice.** The engine never invents a schedule from first principles; it inverts the forgetting curve the PRD pins in [§7.3](../PRD.md) and reads off a due date. The same expanding-interval logic is what the traditional day-1 / day-2 / day-4 / day-7 / day-14 / monthly *murājaʿa* ladder already encodes (RESEARCH-FINDINGS §1) — so the algorithm is formalising a tradition, not overruling it. We surface that convergence in the science screen rather than presenting the math as new ([10-traditional-hifz-methodology.md](10-traditional-hifz-methodology.md)).

**Anti-patterns — we will never:**
- Schedule by a generic rule of thumb ("review weekly") detached from any model of the page's own strength.
- Treat the algorithm as the inventor of spaced revision, rather than the formaliser of what huffaz have done by hand for centuries.

---

## 2. Leitner boxes: the right metaphor for tracks, the wrong engine for pages

**Statement.** The Leitner box system — the no-computer ancestor of every SR app — is honest, intuitive, and the correct *mental model* for the three traditional tracks, but its mechanics are too crude to schedule a 604-page corpus: it cannot tell a strong page from a weak one, and a single stumble resets the whole page.

**Evidence.**
- Devised by Sebastian Leitner in 1972, cards live in (typically five) boxes reviewed at increasing cadences — a common electronic variant uses **1, 2, 4, 8, 16 days**; a correct answer promotes a card one box, and **any error demotes it back to box 1** ([Leitner system, Wikipedia](https://en.wikipedia.org/wiki/Leitner_system)) **[TEXT]**.
- Two consequences are disqualifying for hifz: (a) the interval ladder is **fixed and identical for every card**, so it cannot reason that one page is far weaker than another; and (b) **a single slip resets the whole item to box 1**, which for a page where a ḥāfiẓ may stumble on 2 of 15 lines is brutally lossy (RESEARCH-FINDINGS §3). Leitner and Pimsleur are later shown to be *fixed-weight special cases* of a fittable curve ([Settles & Meeder, 2016, *Proc. ACL*](https://research.duolingo.com/papers/settles.acl16.pdf)) **[OBS]** — i.e. crude instances of the models we prefer.

**In practice.**

| Leitner idea | What we keep | What we refuse |
|---|---|---|
| Boxes of increasing interval | The *three-track* mental model: New / Near / Far ≈ boxes a teacher recognises ([PRD §6.2](../PRD.md)) | Boxes as the *per-page math* — they over-review easy pages and under-protect weak ones |
| Promote on pass | A clean recitation strengthens the page and lengthens its interval | A one-box-at-a-time fixed ladder identical for all 604 pages |
| Demote on error | A lapse demotes the card's *phase* and shrinks its stability | Resetting an otherwise-solid page to "box 1" over two stumbled lines |

A lapse is modelled as a **stability shrink plus a difficulty bump**, with the weakness localised to the erring lines, not a wholesale page reset ([PRD §7.7](../PRD.md)). For maximally traditional users, **pure-cycle mode** ([PRD §7.11](../PRD.md)) runs a fixed rotation closer to Leitner's spirit — SR reordering off — so the app degrades gracefully to a faithful traditional tracker.

**Anti-patterns — we will never:**
- Reset a page's whole schedule to the shortest interval because of a single stumbled line.
- Use one fixed interval ladder for every page regardless of its measured strength.

---

## 3. SuperMemo SM-2: the multiplicative-interval insight, but blind to *how overdue* a page is

**Statement.** SM-2 (1987) — the algorithm behind Anki's classic scheduler and most flashcard apps — contributed the lasting idea that each successful review roughly *multiplies* the safe interval, which is why mature juz can eventually be reviewed monthly. But it schedules from a single fixed "ease" with no model of current recall probability, so it cannot reason about how overdue a page is or how much a review *now* would help. We take its insight and discard its mechanics.

**Evidence.**
- SM-2's specification is small enough to state exactly ([Woźniak, *SuperMemo 2: Algorithm*](https://super-memory.com/english/ol/sm2.htm)) **[TEXT]**: intervals `I(1)=1`, `I(2)=6`, and for `n>2`, `I(n)=I(n−1)·EF`; each item carries an **E-Factor starting at 2.5**, floored at **1.3**, updated from a 0–5 recall-quality grade `q` by `EF′ = EF + (0.1 − (5−q)·(0.08 + (5−q)·0.02))`. The quality scale is graded (5 = perfect; 4 = correct after hesitation; 3 = correct with serious difficulty; ≤2 = failure).
- On **any grade below 3 (a lapse), repetitions restart from `I(1)` while the E-Factor is left unchanged** ([Woźniak](https://super-memory.com/english/ol/sm2.htm)) **[TEXT]** — a near-Leitner reset that throws away how strong the item was.
- SM-2 has **no explicit retrievability and no spacing-effect term**: it cannot answer "how overdue is this, and how much extra durability would a review now buy?" ([Sinha, 2021, dev.to](https://dev.to/umangsinha12/how-spaced-repetition-actually-works-the-sm-2-algorithm-1ge3)) **[TEXT]**. On real review logs, modern two-component models beat it decisively — FSRS-6 predicts recall better than Anki's SM-2 for **99.6%** of user collections ([Open Spaced Repetition, *srs-benchmark*](https://github.com/open-spaced-repetition/srs-benchmark)) **[OBS]**.

**In practice.** We keep SM-2's *multiplicative growth* — stability compounding, so each on-time review stretches the next interval — because it is the formal reason a settled juz moves from daily to weekly to monthly review. We reject its single-ease model and its lapse reset. The 4-level recitation grade (Again / Hard / Good / Easy, [PRD §6.3](../PRD.md)) aligns with SM-2's graded quality scale but feeds a *continuous* stability update, not a box reset, and is enriched with the one signal no flashcard algorithm has: *which lines* the ḥāfiẓ stumbled on ([PRD §7.7](../PRD.md)).

**Anti-patterns — we will never:**
- Schedule a page from a fixed "ease number" with no model of its current recall probability.
- Inherit SM-2's lapse-resets-to-day-1 behaviour for an otherwise-strong page.

---

## 4. The two-component (Stability, Retrievability) model: reasoning about *how overdue* becomes possible

**Statement.** The decisive advance — and the foundation of our engine — is the two-component model: describe a memory by its **Stability** (how durable the trace is) and its **Retrievability** (the probability you can recall it right now). This is the minimum state needed to answer the questions Leitner and SM-2 cannot, and it encodes the spacing effect directly: reviewing a page when it is *weaker* buys more durability than reviewing it when it is fresh.

**Evidence.**
- The status of a memory in long-term storage is captured by two variables: **stability (S)** — how long a trace lasts if undisturbed — and **retrievability (R)** — the probability of recall at a given time ([Woźniak, Murakowski & Gorzelańczyk, *Two components of memory*, supermemo.guru](https://supermemo.guru/wiki/Two_components_of_memory)) **[TEXT]**.
- Two model properties are exactly the dynamics a hifz engine must respect: **(1)** reviews have little power to raise stability while retrievability is still high (reviewing too early wastes effort — the spacing effect, formalised); and **(2)** retrieval raises stability *more when retrievability is low* — "less accessible memories are more reinforced by retrieval" ([*Two components of memory*](https://supermemo.guru/wiki/Two_components_of_memory)) **[TEXT]**. This is the same desirable-difficulty result Bjork's storage-vs-retrieval-strength work predicts, and the empirical backbone of [02-the-spacing-effect.md](02-the-spacing-effect.md).
- SM-17 (SuperMemo 17, 2016) operationalises this with a **stability-increase function `SInc(D, S, R)`**, where the gain on a successful review is largest when retrievability is *low* ([*Algorithm SM-17*, supermemo.guru](https://supermemo.guru/wiki/Algorithm_SM-17)) **[TEXT]**; SM-18 (2019) refined the difficulty estimation. On real logs, FSRS edges even SM-17 (better calibrated for **83.3%** of collections) ([*srs-benchmark*](https://github.com/open-spaced-repetition/srs-benchmark)) **[OBS]** — so we adopt the open instantiation.

**In practice.** The engine carries `S` (days) and derives `R` on demand for every memorized page, exactly so it can answer "is this page at risk *today*?" and "how much will reciting it now strengthen it?". Reviewing weak pages preferentially is not just efficient — it is what makes the recitation strengthen the page most (the "review-when-weak pays most" property), and it is why the day is ordered weakest-first within each track ([PRD §7.8](../PRD.md)). A lapse genuinely sets stability back, which naturally **demotes the card's phase** (New/Near/Far is a function of `S`, [PRD §7.4](../PRD.md)) — the formal version of "a forgotten manzil page rejoins revision."

**Anti-patterns — we will never:**
- Model a page with a single number that conflates "how hard it is" and "how due it is."
- Schedule reviews while a page is still strong (high R), wasting effort the spacing effect says is low-yield.

---

## 5. FSRS: the open, trainable DSR engine the scheduler is built on

**Statement.** FSRS (Free Spaced Repetition Scheduler) is the open-source, free-licence successor that makes the two-component model trainable on review logs and runs entirely on-device. It carries three per-page state variables — **Difficulty, Stability, Retrievability** — and a power-law forgetting curve whose constants the PRD hard-codes. It is the engine, chosen because it is the only model that is *both* a true two-component model *and* open, local, and auditable — preconditions for a no-AI, no-backend, *ṣadaqah* app.

**Evidence.**
- FSRS descends from MaiMemo's DHP model, itself a variant of Woźniak's DSR model, and runs fully locally with no server ([Open Spaced Repetition, *FSRS* repo](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler)) **[TEXT]**. Its three states: **Difficulty (D) ∈ [1,10]** (inherent hardness; higher D *dampens* the stability gain per review), **Stability (S)** ("the interval when R = 90%," in days), and **Retrievability (R)** (current probability of recall) ([*The Algorithm* wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)) **[TEXT]**.
- From FSRS-4.5 the forgetting curve is a **power law** (a better empirical fit than the older exponential `0.9^(t/S)`): `R(t, S) = (1 + FACTOR·t/S)^DECAY` with **DECAY = −0.5, FACTOR = 19/81**, so that **R = 0.9 exactly when elapsed time t equals stability S** — the definition of S ([*The Algorithm* wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm); [expertium.github.io/Algorithm.html](https://expertium.github.io/Algorithm.html)) **[TEXT]**. These are the constants the PRD pins in [§7.3](../PRD.md).
- On a successful review `S′ = S·SInc`, the increase larger when D, S, and R are all low (the same "review-when-weak pays most" dynamic); on a lapse, post-lapse stability is forced to `min(…, S)` so a lapse can **never** raise stability ([expertium.github.io/Algorithm.html](https://expertium.github.io/Algorithm.html)) **[TEXT]**. The model is versioned and the parameter count has grown: **FSRS-4.5 = 17, FSRS-5 = 19, FSRS-6 = 21 trainable weights** ([*The Algorithm* wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm)) **[TEXT]**.

**In practice.**

| FSRS element | How the engine uses it | PRD anchor |
|---|---|---|
| `D, S, R` per page | Per-card state; one card = one muṣḥaf page (604 cards) | [§7.1, §7.2](../PRD.md) |
| `R(t,S) = (1 + (19/81)·t/S)^(−0.5)` | The decay curve, pure Dart, deterministic, golden-tested | [§7.3, §7.12](../PRD.md) |
| `SInc` larger when R low | Weakest-first ordering; recite-when-due strengthens most | [§7.7, §7.8](../PRD.md) |
| Post-lapse `S ≤` prior `S` | A lapse always shrinks stability, demoting the phase | [§7.4, §7.7](../PRD.md) |
| Trainable weights | Constants are a *prior*, curve-fit from the user's own lapse logs — plain arithmetic, no ML service, no network | [§7.3](../PRD.md), C1/C2 |

The PRD treats the published constants as a **starting prior the engine never depends on for safety**: because the trust clamp (§7 below) guarantees every page is recited at least once per cycle regardless of what the math predicts, a mis-estimated stability can only cause harmless *over*-review, never silent decay. Accuracy buys *efficiency* here, not *safety*.

**Anti-patterns — we will never:**
- Send any review data off the device to train weights — fitting is local arithmetic on the user's own logs (C1/C2).
- Add per-page learned features to a single user's sparse log (the over-fitting trap §6 documents).
- Depend on the curve constants being exactly right; the cycle ceiling, not the constant, is the guarantee.

---

## 6. Duolingo's half-life regression: take the lesson (fit from logs), not the model

**Statement.** Half-life regression (HLR) is a fourth point in the design space — keep a simple forgetting curve but *learn its half-life from data at web scale*. It proves two things we care about: a forgetting curve really can be fitted to one's own review behaviour, and doing so beats fixed-weight heuristics by a wide margin. But its single exponential and per-item features over-fit even at Duolingo's scale, so we borrow the lesson, not the model.

**Evidence.**
- HLR models recall as `p = 2^(−Δ/h)`, where Δ is the lag since last practice and `h` is the item's **half-life** (the direct analogue of stability; at Δ = h, p = 0.5), with `h` estimated from features by `ĥ = 2^(Θ·x)` and weights fitted by gradient descent ([Settles & Meeder, 2016, *Proc. ACL*, pp. 1848–1858](https://research.duolingo.com/papers/settles.acl16.pdf)) **[OBS]**.
- On **12.9 million** Duolingo student-word practice sessions, HLR cut mean absolute error well below the baselines Duolingo previously ran — **MAE 0.128 for HLR vs 0.235 for Leitner and 0.445 for Pimsleur** — and an operational A/B test improved daily student engagement by **12%** ([Settles & Meeder, 2016](https://research.duolingo.com/papers/settles.acl16.pdf)) **[OBS]**. The paper shows **Leitner and Pimsleur are special cases of HLR with fixed, hand-picked weights** — formal confirmation that box/ladder systems are crude instances of a fittable curve.
- The paper's own cautions matter for us: its per-item lexeme features *over-fit* and were dropped from production, and a single exponential is a weaker fit than the power-law forms that model long-horizon retention better (and which FSRS adopts, §5). On a head-to-head benchmark, the two-component FSRS is far better calibrated than HLR ([*srs-benchmark*](https://github.com/open-spaced-repetition/srs-benchmark)) **[OBS]**.

**In practice.** We adopt HLR's *principle* — fit the curve to the user's own behaviour rather than trust borrowed constants forever — but apply it conservatively: fit only the **global curve constants** from aggregate lapse history, on the **power-law** curve, with **no per-page learned features**, because we have one user's sparse log, not Duolingo's millions (RESEARCH-FINDINGS §3; [PRD §7.3](../PRD.md)). This is the disciplined middle path: not frozen flashcard defaults, not an over-fitted personal model.

**Anti-patterns — we will never:**
- Fit per-page (or per-line) learned features to a single user's sparse log — that is the over-fitting HLR itself warned against.
- Adopt a single-exponential curve when the power law fits long-horizon retention better.

---

## 7. Desired retention is the one knob — and the cycle ceiling, not the number, is the guarantee

**Statement.** In every two-component model the single design lever is **desired retention** `r` — the recall probability you accept before re-reviewing — which sets the interval by inverting the forgetting curve. We set `r` *for the user* by phase and stakes (never a slider), and — crucially — we do **not** trust a high `r` to deliver the near-100% retention sacred text demands. That guarantee comes from the **cycle ceiling** (the trust clamp), which forces every page to be recited at least once per chosen cycle no matter what the math says.

**Evidence.**
- FSRS computes the next interval by inverting the curve at `r`: `I(r, S) = (S / FACTOR)·(r^(1/DECAY) − 1)`, so **at r = 0.9 the interval equals S**, and a higher `r` shortens it by a fixed multiplier; the default desired retention is **0.9 (90%)** ([*The Algorithm* wiki](https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm); [fsrs4anki tutorial](https://github.com/open-spaced-repetition/fsrs4anki/blob/main/docs/tutorial.md)) **[TEXT]**.
- The cost of higher retention is real, super-linear, but *bounded*: with DECAY = −0.5 the interval multipliers versus `S` at r = 0.9 are **0.448·S at 0.95, 0.266·S at 0.97, 0.087·S at 0.99** — empirically, 90%→95% roughly doubles daily reviews and ~97% roughly quadruples them, with 0.99 across 604 pages near ~11× the 0.90 load (RESEARCH-FINDINGS §3). FSRS therefore distinguishes *desired* retention from **optimal retention** — the value minimising the *workload-to-knowledge ratio* — because pushing `r` too high explodes review load while pushing it too low forces costly relearning ([*The optimal retention* wiki](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention)) **[TEXT]**.
- A default 90% is **far too low for sacred text** — one in ten pages wrong is intolerable in ṣalāh (RESEARCH-FINDINGS §3) — so retention must run high *and* be stakes-tiered, and the near-100% guarantee must rest on something more robust than a fragile probability target. That robust thing is overlearning plus the cycle ceiling; see [06-overlearning-and-lifelong-retention.md](06-overlearning-and-lifelong-retention.md).

**In practice.**

| Phase / stakes | Desired retention `r` | Interval as multiple of `S` | PRD anchor |
|---|---|---|---|
| New (cheap re-exposure while building) | 0.90 | `S` | [§7.5](../PRD.md) |
| Near (recent-juz consolidation) | 0.94 | ~0.52·S | [§7.5](../PRD.md) |
| Far (ordinary maintenance) | 0.95 | ~0.45·S | [§7.5](../PRD.md) |
| Prayer-critical / weak / previously-lapsed | 0.97+ | ≤0.27·S | [§7.5](../PRD.md) |

The retention number is set internally; the user picks a **named cycle** ("1 juz/day," "7-manzil weekly khatm"), never a retention slider ([PRD design principle 1](../PRD.md)). On every review the engine computes the SR-ideal interval, then **clamps it to the cycle ceiling**: `card.due_at = min(ideal_due, ceiling_due)` ([PRD §7.6](../PRD.md)). The algorithm's only freedom is to pull a weak page *forward*; it can never let a juz drift past the cycle. This is the "nothing decays silently" contract, in code — and it is what makes the engine's correctness independent of whether the curve constants are exactly right.

**Anti-patterns — we will never:**
- Expose desired retention as a user-facing slider, or any "retention %" control ([PRD §2](../PRD.md)).
- Chase a literal global 0.99 — its cost curve explodes past the daily budget and breaks trust faster than an occasional stumble (RESEARCH-FINDINGS §3).
- Let the high-retention *number* be the promise; the cycle ceiling is the promise, and the engine may only ever make a page *more* frequent ([PRD §7.6, §7.12](../PRD.md)).

---

## 8. What none of these algorithms give us — interference, serial recall, and the page unit

**Statement.** Every algorithm in this family assumes **independent items recalled in isolation**. Hifz violates that on three counts, and each is an extension the engine must add *on top of* FSRS, not a knob any off-the-shelf scheduler provides: review is **serial recall in bulk** (a whole page recited in flow), the dominant failure is **interference** (mutashābihāt) not decay, and partial knowledge within a page is **lumpy** (13 lines solid, 2 weak).

**Evidence.**
- No SR algorithm (Leitner, SM-2, SM-17/18, FSRS, HLR) models **cross-item interference**, yet mutashābihāt confusion is the leading advanced-ḥāfiẓ failure and *grows* with the corpus — the opposite of decay, which a single-item curve cannot represent (RESEARCH-FINDINGS §3). The cure is **interleaved discrimination**, not spacing; see [05-interference-and-mutashabihat.md](05-interference-and-mutashabihat.md).
- Serial recall is **order-dependent and chained** — each item cues the next — so a mid-page verse cannot be shown as an isolated card without its preceding lines as the running cue (RESEARCH-FINDINGS §3). The muṣḥaf page is therefore the natural unit; see [07-serial-recall-and-the-page-unit.md](07-serial-recall-and-the-page-unit.md).
- The recitation grade carries a signal no flashcard algorithm has: **where** the stumble occurred (line indices), which localises weakness and seeds mutashābihāt links ([PRD §6.3, §7.7](../PRD.md)).

**In practice.** The engine schedules at the **page level** (604 cards) for feasibility and carries a derived **per-line weak-spot overlay**, created lazily only for repeatedly-lapsing pages ([PRD §7.1, §7.7](../PRD.md)). A first-class **interference layer** links confusable pairs, pulls siblings into the same session for back-to-back discrimination, and raises difficulty `D` on all group members — which, via FSRS's standard `(11−D)` damping, automatically shortens their intervals with no special-case scheduler ([PRD §9](../PRD.md)). A dropped or swapped sacred word is **never** graded "Good" — the sacred-text guard caps such a review at Hard ([PRD §7.7](../PRD.md)).

**Anti-patterns — we will never:**
- Atomise a page into independent verse-cards — that breaks the serial-recall cue chain and produces unnatural review units.
- Rely on any off-the-shelf SR algorithm to handle mutashābihāt; interference is an explicit extension we build, not a parameter we tune.
- Let a page graded "Good" overall hide two chronically weak lines and silently lengthen — sub-page tracking exists precisely to prevent that.

---

## References

Only sources cited in this file are listed here. The deduplicated master is in [REFERENCES.md](REFERENCES.md); the full evidence dossier is [research/spaced-repetition-algorithms.md](research/spaced-repetition-algorithms.md).

- Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2006). *Distributed practice in verbal recall tasks: A review and quantitative synthesis.* Psychological Bulletin, 132(3), 354–380. https://www.yorku.ca/ncepeda/publications/CPVWR2006.html — **[MA]**
- Ebbinghaus, H. (1885; Eng. transl. 1913). *Über das Gedächtnis* / *Memory: A Contribution to Experimental Psychology.* Columbia University, New York. https://en.wikipedia.org/wiki/Forgetting_curve — **[CS]**
- Expertium. *FSRS Algorithm.* (Definitions of D/S/R; interval equals stability at 90% desired retention; post-lapse stability forced to min(…, S); power curve a better fit than exponential.) https://expertium.github.io/Algorithm.html — **[TEXT]**
- Leitner, S. (1972). *So lernt man lernen.* Verlag Herder, Freiburg. (Five-box system; common electronic variant 1/2/4/8/16 days; promote-on-correct, demote-to-box-1-on-error.) https://en.wikipedia.org/wiki/Leitner_system — **[TEXT]**
- Murre, J. M. J., & Dros, J. (2015). *Replication and analysis of Ebbinghaus' forgetting curve.* PLOS ONE, 10(7), e0120644. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644 — **[EXP]**
- Open Spaced Repetition. *Free Spaced Repetition Scheduler (FSRS)* — repository. (Open, trainable DSR model from MaiMemo's DHP / Woźniak's DSR; runs entirely locally.) https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler — **[TEXT]**
- Open Spaced Repetition. *The Algorithm* — awesome-fsrs wiki. (D/S/R definitions; power-law curve R(t,S)=(1+FACTOR·t/S)^DECAY with DECAY=−0.5, FACTOR=19/81, R=0.9 at t=S; interval I(r,S)=(S/FACTOR)(r^(1/DECAY)−1); parameter counts 17/19/21 for FSRS-4.5/5/6.) https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm — **[TEXT]**
- Open Spaced Repetition. *fsrs4anki tutorial.* (Default desired retention 0.9.) https://github.com/open-spaced-repetition/fsrs4anki/blob/main/docs/tutorial.md — **[TEXT]**
- Open Spaced Repetition. *The optimal retention* — fsrs4anki wiki. (Higher retention → shorter intervals → more reviews; "optimal retention" minimises the workload-to-knowledge ratio.) https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention — **[TEXT]**
- Open Spaced Repetition. *srs-benchmark* — benchmark of spaced-repetition algorithms. (FSRS-6 better calibrated than Anki SM-2 for 99.6% of collections and than SM-17 for 83.3%; HLR and Ebisu v2 compared.) https://github.com/open-spaced-repetition/srs-benchmark — **[OBS]**
- Settles, B., & Meeder, B. (2016). *A Trainable Spaced Repetition Model for Language Learning.* Proc. 54th Annual Meeting of the ACL, Berlin, pp. 1848–1858. (Half-life regression p=2^(−Δ/h), ĥ=2^(Θ·x); 12.9M sessions; MAE 0.128 HLR vs 0.235 Leitner, 0.445 Pimsleur; +12% daily engagement A/B test; Leitner & Pimsleur shown to be fixed-weight special cases.) https://research.duolingo.com/papers/settles.acl16.pdf — **[OBS]**
- Sinha, U. (2021). *How spaced repetition actually works: the SM-2 algorithm.* dev.to. (Restatement of SM-2 formulas and its no-retrievability limitation.) https://dev.to/umangsinha12/how-spaced-repetition-actually-works-the-sm-2-algorithm-1ge3 — **[TEXT]**
- Woźniak, P. A. (1990; SM-2 in use since 1987). *SuperMemo 2: Algorithm.* (Intervals I(1)=1, I(2)=6, I(n)=I(n−1)·EF; E-Factor start 2.5, floor 1.3, update EF′=EF+(0.1−(5−q)·(0.08+(5−q)·0.02)); 0–5 quality scale; grade below 3 restarts intervals, EF unchanged.) https://super-memory.com/english/ol/sm2.htm — **[TEXT]**
- Woźniak, P. A. *Algorithm SM-17.* supermemo.guru. (Stability-increase function SInc(D, S, R); stability gain largest when retrievability is low.) https://supermemo.guru/wiki/Algorithm_SM-17 — **[TEXT]**
- Woźniak, P. A., Murakowski, J., & Gorzelańczyk, E. J. *Two components of memory.* supermemo.guru. (Retrievability = probability of recall now; stability = how long the trace lasts; reviews raise stability little while R is high; retrieval raises stability more when R is low.) https://supermemo.guru/wiki/Two_components_of_memory — **[TEXT]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
