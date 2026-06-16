# Sleep, Consolidation, and Scheduling — Why the Day Is the Unit

The spacing effect ([`02-the-spacing-effect.md`](02-the-spacing-effect.md)) says *spread review across time*; this document explains *what grain* that time runs in, and why the answer is **the whole day**. The recitation a ḥāfiẓ does today is not finished when the session ends — for hours afterward the memory stays *labile*, and a night of sleep actively stabilises it, moves it from hippocampus toward cortex, hardens it against later interference, and even knits a page into the surrounding context. Because the consolidation event that converts a recitation into durable ḥifẓ happens **overnight**, the natural scheduling quantum is one day/night, not a sub-day micro-session — which is exactly why the engine carries stability in *days*, sets `due_at` as a *calendar date*, and injects "today" as a date (PRD §7.2, §19.3). The same biology supplies an independent mechanism for *why* spacing works at the day scale: a study gap that contains a night of sleep retains far better than the same gap spent awake. This doc sits between spacing — [`02-the-spacing-effect.md`](02-the-spacing-effect.md) — and interference — [`05-interference-and-mutashabihat.md`](05-interference-and-mutashabihat.md) — because sleep touches both: it is the across-night mechanism under distributed practice, and it is the process that makes a slept-on page resist being overwritten by a confusable *mutashābihāt* sibling. Crucially, none of this requires the app to *track* sleep; it requires the app to **schedule in days and never shame a single calm daily pass**.

> **One sentence:** Revise once a day and let the night finish the job — the engine schedules in whole days because the consolidation that makes a page stick is an overnight event, not a within-session one.

## At a glance

| Finding | What it says | Strongest evidence | Grade | Engine consequence (PRD) |
|---|---|---|---|---|
| Memory survives sleep better than waking | Verbal memory decays less across sleep than across equal waking time | Jenkins & Dallenbach 1924; Berres & Erdfelder 2021 | [CS]/[MA] | The day is the scheduling unit; once-daily revision is honoured (§7.2, §12.2) |
| Sleep *actively* consolidates | Slow-wave sleep reactivates and redistributes declarative memory — not just passive shelter | Diekelmann & Born 2010; Hu et al. 2020 | [TEXT]/[MA] | "Revise today, let it set overnight" is the mechanism, stated honestly (§12) |
| The overnight benefit is moderate, not magical | Episodic-memory sleep benefit g ≈ 0.44; daily recitation does the heavy lifting | Berres & Erdfelder 2021 | [MA] | Sleep explains *why* the cadence works; it is never a retention promise (§7.5) |
| The first night is special | Sleep soon after learning protects most; first-night loss isn't fully recoverable | Gais, Lucas & Born 2006 | [EXP] | A new/lapsed page's first follow-up lands next day, not days out (§7.5, §7.7) |
| Sleep protects against interference | A slept-on passage resists being overwritten by a confusable sibling | Ellenbogen et al. 2006 | [EXP] | Space *mutashābihāt* across nights, not only massed in-session (§9.2) |
| Sleep between two sessions is the cheap win | Sleeping *between* sessions halved relearning effort and durably out-retained waking | Mazza et al. 2016 | [EXP] | Re-spread catch-up across nights, never cram (§7.9) |
| A study gap "works" partly via sleep | A 12 h gap *with* sleep matched a 24 h gap; better than 12 daytime hours | Bell et al. 2014 | [EXP] | The day-scale lower end of spacing is banked overnight (§7.3–§7.6) |

---

## 1. Verbal memory survives sleep better than equal waking time — the day is the natural unit

**Statement.** A memory laid down before sleep is in better shape the next day than one laid down to be tested within the same waking window. Forgetting is slower across sleep than across an equal interval awake, and this holds specifically for *verbal* material — the closest analogue to recited text. This is the first reason the scheduler's smallest meaningful interval is the **day**, not the hour.

**Evidence.**
- The oldest experiment in this literature is also the cleanest: two observers learned lists of nonsense syllables and were tested after 1, 2, 4, or 8 hours filled *either* with sleep *or* with ordinary waking activity; forgetting was consistently slower across sleep, and the gap widened with longer intervals ([Jenkins & Dallenbach, 1924](https://www.jstor.org/stable/1414040)) **[CS]**.
- The size of the modern effect is meta-analytically pinned: across **823 effect sizes from 271 independent samples in 177 articles (1967–2019)**, the overall sleep benefit for episodic memory was **g ≈ 0.44** — moderate, and largest in the canonical night-sleep-vs-day-wake design ([Berres & Erdfelder, 2021](https://doi.org/10.1037/bul0000350)) **[MA]**.

**In practice.**

| Decision | What the engine does | PRD |
|---|---|---|
| Stability is in days | Card `S` is measured in days, not hours or sessions | §7.2 |
| Due dates are calendar dates | `due_at` is a date; "today" is injected as a date for determinism | §7.2, §19.3 |
| One daily session | The Today screen builds *one* finite, capped daily list — not many micro-sessions | §7.8, §12.2 |

- The engine never asks for, computes, or rewards finer-than-daily timing, because the biology that makes recitation durable does not reward it (§9 below). The day is the quantum.

**Anti-patterns — we will never:**
- Schedule reviews hours apart within a single day as if extra within-day sittings bought extra consolidation; they do not — that is just re-massing inside one waking window.
- Treat a recitation as "done" the moment the session ends; the page is still labile, and its real fixing happens overnight.

---

## 2. Sleep *actively* consolidates declarative memory — it is not just passive shelter

**Statement.** The night does more than protect a fading trace from daytime interference; during slow-wave sleep the brain *reactivates* newly recited material and *redistributes* it toward long-term cortical stores. This upgrade from "shelter" to "processing" is why effort placed *before* a night pays off more than the same effort placed to be tested the same day.

**Evidence.**
- The canonical account: during **slow-wave sleep (SWS)**, the hippocampus repeatedly reactivates newly encoded memories and, in a coordinated dialogue of slow oscillations, thalamo-cortical spindles, and hippocampal sharp-wave ripples at minimal cholinergic tone, redistributes them toward neocortical stores — *active system consolidation* ([Diekelmann & Born, 2010](https://doi.org/10.1038/nrn2762)) **[TEXT]**.
- The mechanism is causal and localisable, not just correlational: a meta-analysis of **targeted memory reactivation** (cueing specific memories during sleep) across **91 experiments, 212 effect sizes, N ≈ 2,004** found a reliable **g ≈ 0.29** benefit for cued over un-cued items — and crucially the effect lived in **NREM 2 and slow-wave sleep**, *not* in REM and *not* in wakefulness ([Hu, Cheng, Chiu & Paller, 2020](https://doi.org/10.1037/bul0000223)) **[MA]**.

**In practice.**
- The user-facing science screen may state, in calm non-promotional terms, that *"a night's sleep helps fix what you revised today into lasting memory, which is why revision is spread across days rather than crammed"* — carried with a grade and source (Diekelmann & Born 2010 **[TEXT]**; Mazza et al. 2016 **[EXP]**) and registered in [`CLAIMS.md`](CLAIMS.md), per blueprint §2.
- This frames the schedule's *shape* for the user honestly: the daily recitation is the work; the night finishes it. The app explains the cadence, it does not mystify it.

**Anti-patterns — we will never:**
- Claim the app "uses your sleep," track sleep, read a wearable, or require a microphone (C2, R5) — sleep is cited as a *mechanism that justifies day-grained scheduling*, never as an app feature.
- Imply "learning happens in your sleep" without effort; the night consolidates what *retrieval during the day* laid down (see [`04-retrieval-practice-and-self-testing.md`](04-retrieval-practice-and-self-testing.md)).

---

## 3. The overnight benefit is real but moderate — daily recitation does the heavy lifting

**Statement.** Sleep's contribution is a *moderate* boost on top of practice, not a miracle. We say so plainly: the daily recitation does the heavy lifting; sleep finishes the job. This calibrates the app's copy to the honesty pillar and keeps it from over-promising.

**Evidence.**
- The integrative meta-analysis puts the episodic-memory sleep benefit at **g ≈ 0.44** — a moderate effect, reproducible across decades, and notably *larger when material is studied more than once* rather than a single time ([Berres & Erdfelder, 2021](https://doi.org/10.1037/bul0000350)) **[MA]**.
- The targeted-reactivation benefit is smaller still at **g ≈ 0.29**, and is real only in deep NREM, not REM or wake ([Hu et al., 2020](https://doi.org/10.1037/bul0000223)) **[MA]** — the convergent reading is "meaningful help, not wishful sleep-learning."

**In practice.**
- Sleep findings enter [`CLAIMS.md`](CLAIMS.md) (group: *Spacing & scheduling* / *Memory & forgetting*) scoped as a **mechanism**, never as a percentage and never as a sleep-tracking feature (C2, R3).
- The near-100% retention promise comes from the **cycle ceiling** (every page re-recited at least once per chosen cycle, PRD §7.6), *not* from biology. Sleep merely explains *why* the daily, across-night cadence is efficient. See the honesty pillar in [`06-overlearning-and-lifelong-retention.md`](06-overlearning-and-lifelong-retention.md).

**Anti-patterns — we will never:**
- Inflate a moderate g ≈ 0.4 mechanism into a quantitative retention claim about a specific sacred page over years.
- Suggest sleep can substitute for revision, or that a missed recitation is "made up for" by sleeping.

---

## 4. The first night after (re)learning a page is a high-value, non-deferrable window

**Statement.** The *first* sleep after acquiring or reactivating material is special, and the benefit it gives is not fully recoverable later. So a page that was just memorised — or just reactivated from a lapse — should get its first follow-up revision **the next day**, not many days out.

**Evidence.**
- In a controlled within-subject design (high-school students learning **24 English–German word pairs**, crossing learning time with retention interval so time-of-day and interfering daytime activity were balanced), learning shortly before sleep produced significantly less forgetting than learning followed by a full day awake; and **sleep deprivation on the first post-learning night impaired recall even after two recovery nights** ([Gais, Lucas & Born, 2006](https://learnmem.cshlp.org/content/13/3/259.full.html)) **[EXP]**. Paired-associate foreign vocabulary is structurally close to binding an Arabic phrase to its position and continuation, which makes this the single most domain-relevant controlled demonstration here.

**In practice.**
- The conservative **New-phase target** (0.90) and **short post-lapse stability** already ensure a freshly-memorised or just-lapsed page returns soon — typically the next day rather than weeks out (PRD §7.5, §7.7). This doc supplies the *biological* justification for keeping those intervals short, not merely a tunable preference.
- The cold-start "calibration pass" front-loads an early review of every held page (PRD §7.10); the same logic favours not letting a newly-reactivated juz wait long for its first confirming recitation.

**Anti-patterns — we will never:**
- Defer a new or just-lapsed page's first revision by many days "to save budget"; that forfeits the first-night window and sits on the steep, too-short-is-cheap-but-too-late-is-costly side of the spacing cost asymmetry ([`02-the-spacing-effect.md`](02-the-spacing-effect.md) §4).
- Treat a lapse as a one-off correction; a lapsed page demotes and re-enters active revision so it gets repeated overnight consolidation (PRD §6.2, §7.7).

---

## 5. Sleep protects memories against interference — the mechanism behind *mutashābihāt*

**Statement.** A *consolidated* (slept-on) passage is far harder to overwrite with a confusable, near-identical sibling than a freshly-recited, not-yet-consolidated one. This is the finding with the sharpest bearing on ḥifẓ: similar-verse confusion is interference, and sleep is what hardens a page against it. So confusable material should be repeated *across nights*, not only contrasted within a single session.

**Evidence.**
- Participants learned a list of **12 A–B word pairs**, waited 12 hours of either overnight sleep or daytime wake, then — just before testing — learned an **interfering A–C list** (same cues, new responses: the classic retroactive-interference design). Without interference, both groups recalled the original list about equally (**~80% vs ~79%**). *With* interference, the wake group collapsed to **56%** while the **sleep group held at 68%** — sleep had made the original memory *resistant* to the competing material ([Ellenbogen, Hulbert, Stickgold, Dinges & Thompson-Schill, 2006](https://www.sciencedirect.com/science/article/pii/S0960982206016071)) **[EXP]**. A near-identical passage learned later, or a similar verse met in the same session, is precisely such an "A–C list" competing with the "A–B" the ḥāfiẓ already holds.

**In practice.**
- This *refines* — it does not contradict — the rule to interleave *mutashābihāt* siblings back-to-back *within* a session for discriminative contrast (PRD §9.2; the full interference treatment is in [`05-interference-and-mutashabihat.md`](05-interference-and-mutashabihat.md)). Massed contrast teaches the distinction *now*; the distinction is *locked in across nights*.
- A confusion pair flagged today is **re-surfaced on subsequent days** — its difficulty bump already shortens future intervals (PRD §7.7) — so each sibling gets repeated overnight consolidation against the other, not a one-off drill.

**Anti-patterns — we will never:**
- Drill a confusable pair once and consider it resolved; interference protection is built across nights, not in a single sitting.
- Schedule a confusable sibling's *first* exposure massed against a page that has not yet had a night to set, then assume the older page is safe — the not-yet-consolidated target is the vulnerable one.

---

## 6. Sleeping *between* two sessions is the cheapest large win — re-spread, never cram

**Statement.** The structure of every multi-day revision plan is "practise, sleep, practise again." Inserting a night *between* two sessions both speeds relearning and dramatically improves long-term retention — the same total recitation buys far more durable ḥifẓ when its repetitions straddle nights rather than pile into one sitting. This is the empirical heart of a *daily murājaʿa* rhythm and of re-spread catch-up.

**Evidence.**
- **40 adults** learned **16 Swahili–French word pairs** by retrieval-restudy to criterion, then relearned the same list **12 hours later**; one group slept between sessions (evening → morning), the other stayed awake (morning → evening), with sleep quality, chronotype, and time-of-day controlled ([Mazza, Gerbier, Gustin, Kasikci, Koenig, Toppino & Magnin, 2016](https://doi.org/10.1177/0956797616659930)) **[EXP]**:
  - **Relearning was about twice as efficient with sleep between:** the sleep group needed **≈3.05 list-trials** to re-reach criterion vs **≈5.80** for the wake group (*d* = 2.00).
  - **Long-term retention was far higher:** one week later the sleep group recalled **15.20 of 16** vs **11.25**; at **six months** the gap widened proportionally — **8.67 vs 3.35** correct. Of items recalled at one week, **60% survived to six months in the sleep group versus only 30%** in the wake group.
  - The authors' summary: *"sleeping after learning is definitely a good strategy, but sleeping between two learning sessions is a better strategy"* — practice and sleep interact super-additively, not as two independent effects added.

**In practice.**
- **Once-daily revision is the optimal rhythm, not the minimal one.** A user who does *one* calm daily session is doing the right thing. The daily-session design (PRD §12.2) and calm notification copy (PRD §14, R3) are therefore not merely gentle — they are *correct*.
- The **missed-day catch-up planner** re-flows a backlog over several days, most-decayed and prayer-critical first, telling the user plainly *"you missed 3 days — here is a 5-day catch-up plan that still completes your cycle"* (PRD §7.9). The biology makes this honest: cramming a reactivated juz into one sitting wastes the across-night multiplier that makes it hold — spreading it over nights is *what makes it stick*, turning a constraint into a feature.

**Anti-patterns — we will never:**
- Dump a missed backlog as one red overdue pile or a single heavy catch-up session; that re-masses exactly the effort that sleep-between would multiply.
- Push guilt-driven "do more today" nudges that implicitly favour same-day re-massing over spreading work across nights (R3, C6).

---

## 7. A study gap "works" partly because it banks a night of sleep — the day-scale of spacing

**Statement.** Sleep is part of *why* spacing across a day beats massing within a day. At the short end of the spacing curve — where the *day* is the meaningful quantum — the across-day gap delivers its benefit largely by capturing an overnight consolidation event. This is the bridge between this doc and the spacing effect.

**Evidence.**
- A spacing design isolated the role of sleep directly: the gap between an initial study and a restudy of Swahili–English pairs was varied across **massed, 12 hours same-day (no sleep), 12 hours overnight (with sleep), and 24 hours**, then long-term retention was tested. A **12-hour gap that *included sleep* produced long-term retention comparable to the full 24-hour gap, and better than 12 daytime hours without sleep** — *"the findings support the importance of sleep to the long-term benefit of the spacing effect"* ([Bell, Kawadri, Simone & Wiseheart, 2014](https://doi.org/10.1080/09658211.2013.778294)) **[EXP]**.
- This dovetails with the central spacing law — the optimal inter-study gap grows with the retention horizon ([Cepeda, Pashler, Vul, Wixted & Rohrer, 2006](https://www.yorku.ca/ncepeda/publications/CPVWR2006.html)) **[MA]** — by supplying the concrete across-night mechanism at the *lower* end of those gaps, where intervals are measured in days (see [`02-the-spacing-effect.md`](02-the-spacing-effect.md)).

**In practice.**
- The engine's day-grained intervals are not an arbitrary rounding to dates; they are the grain at which a real consolidation event is captured. A New page revisited "the next day" banks one night; a wider Far gap banks many. The phase thresholds and stability growth that widen those gaps (PRD §7.4) ride on top of this overnight mechanism.
- Honest budget framing follows directly: when the day can't fit everything, *"a longer cycle spreads revision across more nights and retains better, not worse"* — Bell 2014 and Mazza 2016 make widening the cadence an *efficiency* gain, not laziness (PRD §7.9, §12.2; serves the busy ḥāfiẓ and late-starter, P1/P3).

**Anti-patterns — we will never:**
- Sub-divide the day to "fit more reviews in" under budget pressure; the right lever is *more nights between*, not *more sittings within*.
- Frame a wider, across-more-nights cycle as a compromise on devotion or a "less serious" choice ([`02-the-spacing-effect.md`](02-the-spacing-effect.md) §7).

---

## 8. The gentle "recite before the night" default — soft, never coercive

**Statement.** Because consolidation rides on the night *after* a session, a daily reminder that lands the revision *before* the user's sleep is mildly better than a late-night-only nudge. This is a *soft default* and nothing more — it must stay fully user-set, silenceable, and free of any guilt or sleep-tracking.

**Evidence.**
- Sleep soon after learning protects most, and the first post-learning night is not fully recoverable later ([Gais, Lucas & Born, 2006](https://learnmem.cshlp.org/content/13/3/259.full.html)) **[EXP]**; the overnight benefit is consolidated in deep NREM the night after the session ([Diekelmann & Born, 2010](https://doi.org/10.1038/nrn2762)) **[TEXT]**. Together these mildly favour completing the session before bed rather than after waking.

**In practice.**
- The optional daily notification (PRD §14) may *default* to a reminder time that leaves the session before a typical bedtime. This is a convenience default only; the user sets any time, and notifications are easily silenced with no escalation (PRD §14, R3).
- The framing stays "your revision for today is ready," never "recite before bed or lose your hifz." Calm loss-prevention, never fear (R3); the motivation evidence is in [`09-motivation-without-coercion.md`](09-motivation-without-coercion.md).

**Anti-patterns — we will never:**
- Turn the soft default into a sleep-tracking feature, a bedtime monitor, or a "did you recite before bed?" check.
- Use the first-night finding to manufacture urgency or guilt ("you slept without revising — your hifz is at risk"); that weaponises a moderate mechanism into coercion (R3, C6).

---

## A note on honesty and the limits of this evidence

The controlled studies here use word-pairs, nonsense syllables, and short inference hierarchies over hours-to-months — *not* multi-year maintenance of an over-learned sacred text under heavy interference. The overnight benefit is **moderate** (g ≈ 0.44 for episodic memory; g ≈ 0.29 for targeted reactivation), reproducible, and driven by deep NREM sleep — meaningful help, not "learning in your sleep." Whether the benefit is best described as *active* system consolidation or partly *passive* protection from interference remains debated, but both readings give the *same* day-grained, across-night scheduling advice, so the engine does not depend on settling it. We therefore treat "sleep consolidates" as a robust *mechanism* that justifies scheduling in whole days and re-spreading work across nights — **never** as a quantitative promise about a specific page. The retention guarantee stays structural (the cycle ceiling, PRD §7.6), and the app never tracks sleep, never reads a wearable, and never records audio (C2, R5). This is the science foundation's honesty pillar applied to the schedule's grain.

---

## References

Only sources cited in this file are listed here; the deduplicated, graded master is in [`REFERENCES.md`](REFERENCES.md).

- Bell, M. C., Kawadri, N., Simone, P. M., & Wiseheart, M. (2014). *Long-term memory, sleep, and the spacing effect.* Memory, 22(3), 276–283. https://doi.org/10.1080/09658211.2013.778294 — **[EXP]**
- Berres, S., & Erdfelder, E. (2021). *The sleep benefit in episodic memory: An integrative review and a meta-analysis.* Psychological Bulletin, 147(12), 1309–1353. https://doi.org/10.1037/bul0000350 — **[MA]**
- Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2006). *Distributed practice in verbal recall tasks: A review and quantitative synthesis.* Psychological Bulletin, 132(3), 354–380. https://www.yorku.ca/ncepeda/publications/CPVWR2006.html — **[MA]**
- Diekelmann, S., & Born, J. (2010). *The memory function of sleep.* Nature Reviews Neuroscience, 11(2), 114–126. https://doi.org/10.1038/nrn2762 — **[TEXT]**
- Ellenbogen, J. M., Hulbert, J. C., Stickgold, R., Dinges, D. F., & Thompson-Schill, S. L. (2006). *Interfering with theories of sleep and memory: Sleep, declarative memory, and associative interference.* Current Biology, 16(13), 1290–1294. https://www.sciencedirect.com/science/article/pii/S0960982206016071 — **[EXP]**
- Gais, S., Lucas, B., & Born, J. (2006). *Sleep after learning aids memory recall.* Learning & Memory, 13(3), 259–262. https://learnmem.cshlp.org/content/13/3/259.full.html — **[EXP]**
- Hu, X., Cheng, L. Y., Chiu, M. H., & Paller, K. A. (2020). *Promoting memory consolidation during sleep: A meta-analysis of targeted memory reactivation.* Psychological Bulletin, 146(3), 218–244. https://doi.org/10.1037/bul0000223 — **[MA]**
- Jenkins, J. G., & Dallenbach, K. M. (1924). *Obliviscence during sleep and waking.* The American Journal of Psychology, 35(4), 605–612. https://www.jstor.org/stable/1414040 — **[CS]**
- Mazza, S., Gerbier, E., Gustin, M.-P., Kasikci, Z., Koenig, O., Toppino, T. C., & Magnin, M. (2016). *Relearn faster and retain longer: Along with practice, sleep makes perfect.* Psychological Science, 27(10), 1321–1330. https://doi.org/10.1177/0956797616659930 — **[EXP]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
