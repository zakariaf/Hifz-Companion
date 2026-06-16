# Hifz App — Deep Research Findings

This is the human-readable compilation of a deep-research + product-strategy workflow for an Islamic Hifz (Quran memorization) tracker with spaced repetition. It compiles, in full, the six research dimensions (methodology, competitors, SR science, market, tech, users), the two spaced-repetition engine designs, the differentiation thesis, the adversarial critique, the completeness-gaps review, and the synthesized product vision.

The complete raw machine output (with full nesting and every field) lives alongside this file in `raw-research-output.json`. This document preserves all substance, evidence, and source URLs — nothing is summarized away.

---

## 1. Traditional Hifz Methodology
*(from `research.methodology`)*

**Summary:** Three-track hifz revision: **sabaq**, **sabqi**, **manzil**.

### Key Findings

#### Three-track system
- **Detail:** Sabaq is new lesson (3–5 lines/day), sabqi is recent revision (last 1–3 juz), manzil is long revision cycled weekly to monthly; recited **old-before-new** (dhor, sabqi, sabak).
- **Implication:** Model three review queues; graduate by age and rating.

#### Manzil scheduling and spaced repetition
- **Detail:** 7-manzil = weekly khatm; 30-juz cycles of 30/15/10 days; a hafiz keeps a minimum of **1 juz/day**; intervals follow day 1 / 2 / 4 / 7 / 14 then monthly; forgetting figures of **58% / 44% / 33% / 21%**.
- **Implication:** Cycle presets, auto-scaled targets, SM-2 scheduler.

#### Teacher, failure modes, tracking, regions
- **Detail:** **Talaqqi** is the oral teacher relationship; **ijazah** is the sanad (chain) certification. Dropping manzil = the most loss; there are **300+ mutashabihat** (near-identical passages). Tracking columns: date, range, track, rating, attempts, weak flags, computed % and next-due. Regional traditions: **Deobandi**, **Arab muraja'ah**, **Ottoman stacking**, **Indonesia takrar**, **Mauritania luh**.
- **Implication:** Un-skippable manzil; mutashabihat diff; auto-reschedule; configurable terms/order.

---

## 2. Competitive Landscape
*(from `research.competitors`)*

**Summary:** The Hifz-app market splits into four clusters:

1. **AI recitation-checkers** (Tarteel, Muallim AI, Retain Quran's beta) that listen and flag mistakes;
2. **Spaced-repetition trackers** (Quran Companion, QuranH with FSRS, the SuperMemo-2 GitHub app, Hifdh Revision Tracker);
3. **Traditional-workflow trackers** (Al Muhaffiz with sabaq/sabqi/manzil); and
4. The huge **DIY layer** of Anki decks plus Notion / Google-Sheets / Gumroad templates.

Almost every product is optimized for the **NEW memorizer adding pages**, not the completed hafiz maintaining 600+ pages. The apps that touch real spaced repetition either lack recitation verification (Quran Companion, QuranH), are free hobby projects with thin polish (GitHub SM-2 app, QuranH), or bolt SR onto a flashcard/word model rather than whole-page recall.

The clearest, defensible gap: an **intelligent, recitation-aware revision scheduler purpose-built for people who have already finished**, that keeps a full-Quran review load sustainable (caps daily reviews, surfaces weak ajzaa', and degrades gracefully when a user misses days) instead of dumping an overwhelming or rigid pile of due items. Notable secondary gaps: trust/billing reputation (Quran Companion's stalled updates and paywall complaints), modern FSRS used well with verification, and a "maintenance mode" that nobody markets directly.

### Competitor-by-Competitor Findings

#### Tarteel AI owns recitation verification but is not a real spaced-repetition scheduler
- **Detail:** Tarteel is the category leader (**15M+ users, 4.7 iOS / 4.6 Play**) with flagship **AI Memorization Mistake Detection** that listens and flags missed/swapped words, plus Historical Mistakes, Memorization Journey Planning, analytics and streaks. Premium is **$9.99/month** (lifetime tiers up to ~$250). Loudest complaints: mistake detection is too sensitive and only word-level (not full Tajweed), performance lag, the free tier is heavily capped, and people resent paywalled core features.
- **Evidence:**
  - https://support.tarteel.ai/en/articles/12414460-what-features-do-i-unlock-with-tarteel-premium
  - https://tarteel.ai/pricing
  - https://quranicma.com/best-quran-memorization-apps-2026/
  - https://www.thealphazed.com/blog/best-quran-memorization-apps-2026
- **Implication:** Tarteel proves demand for AI verification, but its scheduling is journey/streak-based, not an adaptive interval engine. A maintenance-focused, recitation-aware scheduler is an adjacent space Tarteel has not nailed.

#### Quran Companion has the SR-around-the-Mushaf model but a damaged trust/value reputation
- **Detail:** Quran Companion wraps a spaced-repetition system around the Mushaf: set a daily goal and it serves new verses plus old verses due for revision, with streaks, badges, leaderboards and group challenges. But it **cannot verify recitation** (no listening), and reviewers report it hasn't been meaningfully updated since ~2018, has bugs, and locks most value behind premium (**~£1.89–£38.49**) to the point that "the app is literally of no use if you don't have premium." Its web/course business also draws billing and customer-service complaints on Trustpilot.
- **Evidence:**
  - https://quranicma.com/best-quran-memorization-apps-2026/
  - https://www.thealphazed.com/blog/best-quran-memorization-apps-2026
  - https://www.trustpilot.com/review/alqurancompanion.com
- **Implication:** The most direct SR competitor is stale and disliked on value/trust. A polished, fairly-priced, frequently-updated SR tracker with verification can take this position directly.

#### FSRS is already in the market via QuranH, but as a free hobby PWA with no verification and no maintenance framing
- **Detail:** QuranH is a free (no ads, no premium) PWA using the modern **FSRS** algorithm, claiming **92% long-term retention**, with a Listen/Test/Recite/Review loop, 8 reciters, offline support, sync and 9 languages. Test mode is fill-in-the-missing-word; Recite is self-graded error marking, not AI-verified. It contains nothing about post-completion maintenance.
- **Evidence:**
  - https://quranh.com/
  - https://www.thealphazed.com/blog/best-quran-memorization-apps-2026
- **Implication:** FSRS is no longer a differentiator on its own. The differentiation must be in HOW SR is applied: recitation-aware grading and a sustainable whole-Quran maintenance model, which QuranH does not address.

#### The only tools explicitly built for people who already memorized are thin, niche, or self-graded
- **Detail:** An open-source Android app by Ahmad Hossain uses **SuperMemo-2** over all pages and is explicitly aimed at "maintenance practitioners" — review only pages due today, grade recall from perfect to blackout. **Al Muhaffiz** tracks the traditional sabaq (new) / sabqi (recent) / manzil (long-term rotation) workflow used in madaris but has an outdated UI, single script, and no listening. **TazkiyaTech's Hifdh Revision Tracker** and **Hifdh Revision Tester** serve revision but are utilitarian. All are self-graded with no AI verification and minimal polish.
- **Evidence:**
  - https://github.com/ahmad-hossain/quran-spaced-repetition
  - https://quranicma.com/best-quran-memorization-apps-2026/
  - https://play.google.com/store/apps/details?id=com.tazkiyatech.hifdhtracker&hl=en_GB
- **Implication:** The maintenance segment is underserved by design, validated by demand, and occupied only by free/utility apps — the single clearest opening for a well-built product.

#### A large DIY layer (Anki, Notion, Sheets, Gumroad) signals unmet demand and the manual-effort pain
- **Detail:** Serious revisers fall back to **Anki** (page-on-back, prior-page-on-front cards) and to paid Notion/Google-Sheets/Gumroad templates (Hifdh Planner Pro, Hifdh Companion, The Quran OS). Anki for Quran "requires a number of tweaks" the author has "been exploring for years," and people resort to manual interval formulas (review at 1 day, 3 days, then last interval ÷2 rounded up, added on). Substack/forum authors build custom "murajaah boards" inspired by flashcards/SR specifically to manage mixed-strength weak ajzaa'.
- **Evidence:**
  - https://howtomemorisethequran.com/using-flashcards-for-hifz-quran-memorisation/
  - https://qari.substack.com/p/a-creative-system-for-revision-murajaah
  - https://www.notion.com/templates/weekly-hifdh-revision-planner
- **Implication:** People are paying for and hand-building scheduling systems because no app does it well. Replacing that manual labor with an automatic, Quran-native scheduler is a clear value proposition.

#### Recitation-aware grading and self-grading are unsolved at the intersection
- **Detail:** The apps with verification (Tarteel, Muallim AI, Retain Quran beta) treat memorization as a journey/flashcard problem; the apps with true SR scheduling (Quran Companion, QuranH, the SM-2 app) rely on the user honestly self-grading recall. **No widely-used product closes the loop:** let the AI hear the recitation and feed that objective error signal directly into the interval/scheduling engine.
- **Evidence:**
  - https://quranicma.com/best-quran-memorization-apps-2026/
  - https://quranh.com/
  - https://apps.apple.com/us/app/id1624792039
- **Implication:** Closing the loop (AI-measured recall strength auto-driving FSRS intervals) is a genuinely novel, defensible feature nobody currently ships.

#### 'Mahir' and live-teacher apps occupy a different lane (human correction), not scheduling
- **Detail:** Searches for "Mahir" surface **Mahir Bil Quran** and the live-teacher recitation-correction genre (**Quran Mobasher**, **Moddakir**) where a human teacher corrects Tajweed in real sessions. These compete on human feedback and accountability, not on automated revision scheduling.
- **Evidence:**
  - https://apps.apple.com/my/app/mahir-bil-quran/id6748629598
  - https://moddakir.com/en/online-quran-recitation/
- **Implication:** Human-teacher accountability is a strength a software scheduler lacks; consider integrating teacher/halaqah accountability features rather than competing head-on with live correction.

#### Common failure modes: overwhelming or rigid review loads and progress that resets
- **Detail:** Guidance across the niche warns not to follow revision tables that "feel too heavy" and that the best schedule is one you can sustain indefinitely — implying current tools overwhelm users. **Retain Quran** reviewers report cards/progress resetting after ~30 days and ask for customizable review-frequency intervals; **Quranic** users report premium timers glitching and money lost. Self-graded SR apps also punish missed days by piling up due items.
- **Evidence:**
  - https://www.quransheikh.com/quran-hifz-revision-schedule/
  - https://apps.apple.com/us/app/id1624792039
  - https://justuseapp.com/en/app/1381145375/quranic-quran-arabic-learning/reviews
- **Implication:** Sustainability and graceful catch-up (load capping, weak-section prioritization, snooze/backlog handling, customizable intervals) are concrete, demanded features that would directly counter the loudest complaints.

### Market Gaps / Opportunities
- Build the first **recitation-aware spaced-repetition scheduler**: let AI mistake-detection (à la Tarteel) feed an objective recall signal directly into an FSRS engine, instead of relying on honest self-grading. Nobody closes this loop today.
- Position explicitly as a **"maintenance mode" / murajaah product for people who have FINISHED** memorizing — a segment validated by the GitHub SM-2 app, TazkiyaTech trackers, Anki users and paid Notion/Sheets templates, yet ignored by the marketed leaders.
- Make a full-Quran review load **sustainable**: cap daily reviews, prioritize weak ajzaa', and degrade gracefully after missed days (backlog smoothing / catch-up) instead of dumping an overwhelming pile — directly answering the loudest sustainability complaints.
- Win on **trust and fair pricing** where Quran Companion is weak: frequent updates, transparent/free-leaning model, no glitchy paywalls, reliable billing — a low bar competitors are failing.
- Support the traditional **sabaq/sabqi/manzil** mental model (like Al Muhaffiz) but with a modern UI, multiple mushaf scripts (13/15/16-line), and automatic scheduling, capturing madrasa-trained huffaz underserved by clunky tools.
- Replace the **DIY layer** (Anki tweaking, manual interval math, Gumroad/Notion templates) with one automatic Quran-native scheduler, marketing directly to the communities already hand-building these systems.
- Add **teacher/halaqah accountability hooks** (shareable progress, weak-area reports) to borrow the human-feedback strength of live-teacher apps like Mahir/Moddakir without competing on live correction.
- Offer **customizable review intervals and reliable cross-device sync** without progress resets — explicit unmet requests in Retain Quran reviews.

### Risks
- Tarteel's scale (15M+ users), AI lead, and capital mean it could add a real maintenance scheduler and absorb this niche; differentiation must be deep, not a feature it can copy in a sprint.
- Free, no-paywall incumbents (QuranH with FSRS, the open-source SM-2 app, Ayah) compress willingness to pay; a premium price needs clearly superior verification + sustainability, not just "SR exists."
- AI recitation accuracy is hard and reputationally sensitive: Tarteel is criticized for over-sensitive, word-level-only detection, and a worse engine would erode the core "closed-loop" value proposition and invite religious-accuracy backlash.
- Religious-content sensitivity and trust: billing glitches, resets, or perceived disrespect (as seen in Quranic/Quran Companion complaints) damage reputation faster here than in secular apps.
- Mushaf licensing/script coverage and reciter audio rights add cost and complexity; users expect 13/15/16-line scripts and multiple reciters as table stakes.
- The maintenance segment, while underserved, may be smaller and harder to monetize than the larger new-memorizer market that most competitors chase — niche focus is a positioning bet.
- Habit/retention risk: completed huffaz revise privately and may not open an app daily; without strong, non-annoying reminders and graceful catch-up the product churns.

### Sources
- https://tarteel.ai/pricing
- https://support.tarteel.ai/en/articles/12414460-what-features-do-i-unlock-with-tarteel-premium
- https://justuseapp.com/en/app/1391009396/tarteel-recite-al-quran/reviews
- https://quranicma.com/best-quran-memorization-apps-2026/
- https://www.thealphazed.com/blog/best-quran-memorization-apps-2026
- https://www.trustpilot.com/review/alqurancompanion.com
- https://quranh.com/
- https://github.com/ahmad-hossain/quran-spaced-repetition
- https://apps.apple.com/us/app/id1624792039
- https://play.google.com/store/apps/details?id=com.tazkiyatech.hifdhtracker&hl=en_GB
- https://howtomemorisethequran.com/using-flashcards-for-hifz-quran-memorisation/
- https://qari.substack.com/p/a-creative-system-for-revision-murajaah
- https://www.notion.com/templates/weekly-hifdh-revision-planner
- https://justuseapp.com/en/app/1381145375/quranic-quran-arabic-learning/reviews
- https://www.quransheikh.com/quran-hifz-revision-schedule/
- https://apps.apple.com/my/app/mahir-bil-quran/id6748629598
- https://moddakir.com/en/online-quran-recitation/
- https://www.quranprogress.com/en/blog/spaced-repetition-memorize-quran/
- https://howtomemorisethequran.com/top-quran-memorization-apps/

---

## 3. Spaced-Repetition Science
*(from `research.srscience`)*

**Summary:** Classic spaced-repetition (SR) algorithms — SM-2, SuperMemo SM-17/18, FSRS, Leitner, Anki — were built to optimize **RECOGNITION / cued-recall** of independent flashcards at a TUNABLE retention target (typically 90%). Hifz is a fundamentally different task: **serial RECALL / PRODUCTION** of one long, ordered, contiguous sequence where items mutually interfere (mutashabihat — near-identical verses), review is done in **BULK** (a page, hizb, or juz recited in one flow, not card by card), and the retention requirement is effectively **near-100%** because errors in sacred text are unacceptable.

The core SR engine — the difficulty/stability/retrievability (DSR) model and its power-law forgetting curve — **TRANSFERS well** and is the right mathematical backbone. What **BREAKS** is the unit of scheduling (card vs page), the grading signal (binary recall vs graded fluency with localized error positions), the independence assumption (interference is the dominant failure mode, not decay), and the retention target (a fixed 90% is far too low; sacred text needs ~97–99%, which is expensive but bounded).

The implementable design: treat each **PAGE** (or sub-page line-block) as the FSRS "card," carry per-page D/S/R state, drive grading from the position and count of errors during bulk recitation, run desired retention high (0.95–0.99) on a steep but finite cost curve, add an explicit **INTERFERENCE / mutashabihat** mechanism (link confusable pages, force interleaved discrimination review, penalize the involved pages' difficulty), and use FSRS's own load-simulation to load-balance daily review so the muraja'ah queue stays feasible (the traditional 5:1 review-to-new ratio and 7-manzil weekly cycle are empirical approximations of exactly this).

### Key Findings

#### The DSR model (FSRS) is the correct mathematical backbone and transfers cleanly to hifz
- **Detail:** FSRS models memory with three state variables per item: **Difficulty D in [1,10]**, **Stability S** (days until recall probability falls to 90%), and **Retrievability R** (current recall probability). The forgetting curve is a POWER law:
  `R(t,S) = (1 + FACTOR·t/S)^DECAY` with `DECAY ≈ -0.5` and `FACTOR = 0.9^(1/DECAY) - 1 = 19/81` (so R(S,S)=0.9).
  On successful review, stability grows multiplicatively:
  `S' = S·(1 + e^{w8}·(11-D)·S^{-w9}·(e^{w10·(1-R)}-1)·hard·easy)`.
  Two facts make this ideal for hifz: (1) stability compounds, so each on-time review roughly multiplies the safe interval (the empirical basis of why old juz can eventually be reviewed weekly/monthly); (2) the `e^{w10·(1-R)}` term encodes the **SPACING / desirable-difficulty** effect — reviewing when R is LOWER (memory weaker) produces a LARGER stability gain, exactly Bjork's storage-vs-retrieval-strength result. SM-17/18 use the same two-component (S,R) model with a stabilization matrix SInc(D,S,R); FSRS is the open, trainable instantiation.
- **Evidence:** FSRS forgetting curve R(t,S)=(1+FACTOR·t/S)^DECAY, DECAY=-0.5, FACTOR=19/81 (github.com/open-spaced-repetition; expertium.github.io/Algorithm.html; borretti.me/article/implementing-fsrs-in-100-lines). SM-17 two-component model with SInc(D,S,R) stabilization matrix (supermemo.guru/wiki/Algorithm_SM-17). Bjork storage/retrieval strength: largest storage-strength gains come from successful retrieval when retrieval strength is low (unh.edu Bjork & Bjork; bjorklab.psych.ucla.edu).
- **Implication:** Build the hifz scheduler on the FSRS DSR engine, not SM-2's fixed ratios. Keep per-item D/S/R state and the power-law curve. Trainable FSRS weights mean the algorithm can be fitted to hifz review logs specifically, rather than borrowed from flashcard users.

#### SM-2, Leitner and the raw Anki defaults are too crude for hifz; only FSRS-class models capture the real dynamics
- **Detail:** SM-2 (1987) uses a per-item ease factor EF (start 2.5), updated by `EF += 0.1-(5-q)(0.08+(5-q)·0.02)` from a 0–5 grade, with intervals I1=1, I2=6, In=I(n-1)·EF. It has **no explicit retrievability and no spacing-effect term**, so it cannot reason about "how overdue is acceptable" or model interference. The Leitner system is SM-2's discretization: 5 boxes reviewed at fixed cadences (daily, 2d, 4d, weekly, biweekly); a correct answer promotes one box, ANY error demotes to box 1. Anki historically wrapped SM-2 with learning steps + a graduating interval; with FSRS enabled those SM-2 knobs are hidden and intervals come from target retention. The hifz-relevant weaknesses: (a) binary/whole-item grading throws away WHERE in the page the error occurred; (b) Leitner's full demotion-to-box-1 on a single slip is brutal for a 600-page corpus and ignores that one stumbled line ≠ whole page forgotten; (c) none model cross-item interference.
- **Evidence:** SM-2 formulas and intervals (super-memory.com/english/ol/sm2.htm; dev.to/umangsinha12). Leitner 5-box cadence with promote-on-correct / demote-to-box-1-on-error (en.wikipedia.org/wiki/Leitner_system; e-student.org/leitner-system). Anki hides SM-2 graduating interval under FSRS, intervals derived from desired retention 0.70–0.99 (docs.ankiweb.net/deck-options.html; github.com/open-spaced-repetition/fsrs4anki tutorial).
- **Implication:** Use FSRS, but do NOT inherit Leitner's all-or-nothing demotion. Hifz needs a graded, position-aware error signal feeding a continuous stability update, plus sub-page granularity so a single weak line does not reset an otherwise-solid page.

#### The unit-of-scheduling mismatch is the central adaptation: schedule PAGES (with sub-page weak-spot state), not verse-cards
- **Detail:** Classic SR schedules thousands of independent cards each surfaced individually. Hifz review is **BULK and CONTIGUOUS**: a hafiz recites a whole page, hizb, or juz in one continuous flow, and you cannot meaningfully "show" verse 4 of a page without verses 1–3 as the running cue (serial recall is chained — each item cues the next). So the natural FSRS "card" is the **PAGE** (the universal mushaf page, ~15 lines), carrying its own D/S/R. But a page is not atomic: knowledge within it is partial and lumpy (a hafiz may own 13 lines and stumble on 2). Model this as a **two-level structure**: page-level D/S/R for scheduling the bulk review, PLUS a per-line (or per-verse) weak-spot vector recording recent error positions. The page's effective difficulty D and the grade fed to FSRS are DERIVED from the line-level error pattern (e.g. grade = Again if any major break, Hard if minor hesitations clustered on known weak lines, Good if clean, Easy if fluent and fast). This preserves bulk review (feasible, matches practice) while still localizing partial knowledge so weak lines can be drilled out-of-band without re-reviewing the whole page.
- **Evidence:** Serial recall is order-dependent and chained — a prior item cues the next (sciencedirect.com Serial Recall overview; en.wikipedia.org/wiki/Recall_test). Traditional muraja'ah is recited entirely from memory in bulk per page/manzil, teacher flags hesitations as the error signal (ilmify.app/blog/what-is-murajaah-quran-revision). Universal mushaf page is the natural unit in hifz pedagogy (multiple hifz-schedule sources, e.g. howtomemorisethequran.com, quransheikh.com).
- **Implication:** Data model: `Page { D, S, R, lastReview } + lines[]{ errorCount, lastErrorDate, mutashabihLinks[] }`. Schedule at page level for feasibility; surface weak lines as cheap micro-reviews. Optionally allow the unit to scale (line-block → page → hizb) as stability grows, since highly stable juz are reviewed as large blocks.

#### The grading signal must be position-aware fluency, not binary recall — and it should drive both stability and difficulty
- **Detail:** Flashcard grading is essentially binary (recalled / lapsed), optionally 4-level (Again/Hard/Good/Easy) as in FSRS where these map to G=1..4 and modulate stability via the hard penalty w15 (≤1) and easy bonus w16 (≥1), and set initial difficulty via `D0(G)=w4 - e^{w5(G-1)}+1` with mean-reversion update `D'' = w7·D0(4) + (1-w7)·(D + (-w6(G-3))·(10-D)/9)`. For hifz the recitation yields a RICHER signal: number of stumbles, their positions, whether the teacher had to prompt (a true lapse) vs a self-corrected hesitation (a Hard), and speed/fluency. Map this to the FSRS grade per page: any teacher-prompt or wrong-word = Again (triggers post-lapse stability `S_f = w11·D^{-w12}·((S+1)^{w13}-1)·e^{w14(1-R)}`, capped at S); clustered hesitations on weak lines = Hard; clean = Good; fluent+fast = Easy. Crucially, a lapse localized to mutashabihat lines should raise that page's DIFFICULTY (D toward 10), which in FSRS shortens future intervals automatically (S' shrinks because the (11-D) factor falls), giving confusable pages denser review without manual tuning.
- **Evidence:** FSRS grade-to-state mapping, hard/easy modifiers w15/w16, initial difficulty D0(G)=w4-e^{w5(G-1)}+1, difficulty mean-reversion to w4, post-lapse stability S_f formula (borretti.me/article/implementing-fsrs-in-100-lines; expertium.github.io/Algorithm.html). Higher difficulty D reduces the stability increase via the (11-D) factor (same sources).
- **Implication:** Instrument recitation to capture error position/type/count (manual teacher tap, or ASR alignment for self-study). Derive the FSRS grade from that. Let difficulty absorb interference: pages involved in a mutashabihat slip get a difficulty bump, which the standard FSRS math converts into shorter intervals — no special-case scheduler needed for the common case.

#### Interference (mutashabihat) is the dominant failure mode and is NOT modeled by any classic SR algorithm — it needs an explicit discrimination mechanism
- **Detail:** Standard SR assumes items are **INDEPENDENT**: forgetting is decay of an isolated trace. In hifz the primary error source is not decay but **INTERFERENCE** — near-identical verse pairs (mutashabihat, differing by one or two words) whose shared opening words, rhythm, and length cause the brain to merge traces and recall the wrong continuation. This worsens as the corpus grows (a 10-juz hafiz holds hundreds of confusable pairs), the opposite of decay, which independent-item SR cannot represent. The fix is grounded in two literatures: (1) **interleaving** beats blocking specifically when categories are CONFUSABLE — interleaving forces discriminative contrast and is most beneficial for perceptually similar material; (2) **retrieval-induced forgetting / cue competition** occurs only when competing associates share a cue. Implementation: maintain a mutashabihat graph linking confusable verse pairs; when one is reviewed, schedule its twin nearby and INTERLEAVE them (review A then B back-to-back, contrasting the distinguishing word) rather than in isolation; track per-pair a "confusion score" that, when high, (a) raises both pages' difficulty D and (b) triggers paired discrimination drills. This is a genuine extension beyond FSRS/SM-17, not a parameter tweak.
- **Evidence:** Mutashabihat are the primary cause of advanced-hafiz errors and worsen as more is memorized (getitqan.com/blog/what-is-mutashabihat; academia.edu Tahfiz Mutashabihat study; howtomemorisethequran.com mutashabihat series). Interleaving most benefits confusable/perceptually-similar categories via discriminative contrast (pmc.ncbi.nlm.nih.gov interleaving studies; mdpi.com category-learning interleaving). Retrieval-induced forgetting requires shared-cue competition (Bjork lab research).
- **Implication:** Add a first-class interference layer: a confusable-pairs graph (pre-seedable from published mutashabihat tables), paired interleaved review, and a confusion score feeding difficulty. This is the single biggest hifz-specific value-add over off-the-shelf SR.

#### Near-100% retention for sacred text is required, achievable, and bounded — but it lives on the steep part of the cost curve, so load-balancing is essential
- **Detail:** SR's retention target is **TUNABLE**; FSRS/Anki default to 90% and recommend 0.85–0.95 because workload-per-knowledge is minimized there. Sacred text cannot tolerate 90% (one in ten pages wrong is unacceptable in salah), so desired retention must run high, ~0.95–0.99 (Anki caps at 0.99). The cost is real and quantifiable: empirically, going 90%→95% roughly **DOUBLES** daily reviews and ~97% roughly **QUADRUPLES** vs 90%; cost rises sharply (super-linearly) as R→1. But it is FINITE, and the power-law curve helps: because intervals from desired retention r are `I = (S/FACTOR)(r^{1/DECAY}-1)`, raising r shortens intervals by a fixed MULTIPLIER, not unboundedly. With DECAY=-0.5:
  - at r=0.90: interval = S
  - at r=0.95: `I = (81/19)(0.95^{-2}-1)·S ≈ 0.448·S` (intervals ~55% shorter, ~2.2x more reviews)
  - at r=0.97: `I ≈ (81/19)(0.97^{-2}-1)·S ≈ 0.266·S` (~3.8x more reviews)
  - at r=0.99: `I ≈ (81/19)(0.99^{-2}-1)·S ≈ 0.087·S` (~11x more reviews)

  So 0.99 everywhere is ~11x the 0.90 workload — infeasible for 604 pages. The resolution: set retention **by STAKES, not globally** — e.g. r≈0.99 only for pages recited in obligatory prayer / known weak / mutashabihat pages, r≈0.95 for the rest — and let stability compounding carry mature juz to long intervals so the steady-state load stays bounded.
- **Evidence:** Default/recommended retention 0.85–0.95 minimizes workload/knowledge; permissible 0.70–0.99 (docs.ankiweb.net; github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention). 90%→95% ~doubles, ~97% ~quadruples daily reviews; cost rises exponentially toward 1.0 (studycardsai.com Anki settings; community.ankihub.net). Interval-from-retention I(r,S)=(S/FACTOR)(r^{1/DECAY}-1), I=S at r=0.9 (search results; expertium.github.io/Algorithm.html). DECAY=-0.5, FACTOR=19/81.
- **Implication:** Do NOT use one global retention. Tier it: ~0.99 for high-stakes/weak/mutashabihat pages, ~0.95 for routine maintenance. The multipliers above (0.448·S, 0.266·S, 0.087·S vs S) are directly computable, so the app can show the hafiz the workload cost of each retention tier and let them trade rigor for feasibility transparently.

#### The traditional muraja'ah system is an empirical, hand-tuned spaced-repetition schedule — formalizing it with FSRS adds adaptivity and load-balancing
- **Detail:** Classic huffaz practice already implements SR by hand. The three tiers map onto FSRS state: **Sabak** (today's new ½–1 page) = a fresh card in learning steps; **Sabqi** (last ~7–20 days, reviewed daily/alternate-day, recited faster) = low-but-rising stability cards in early review; **Dhor/Manzil** (everything older, cycled weekly via 7 manazil, or fortnightly) = high-stability mature cards. The famous **"5:1 rule"** (5 review pages per 1 new page) and the 7-day manzil cycle are fixed approximations of optimal review pressure — they ignore that some pages are far weaker (mutashabihat, rarely-recited juz) and over-review easy ones. FSRS replaces the fixed manzil rota with per-page due-dates from D/S/R, concentrating effort on weak/confusable pages and stretching solid ones — the same total budget, better allocated. Critically, FSRS can SIMULATE future workload for a given desired retention and corpus, so the app can LOAD-BALANCE: cap daily review minutes, smooth due-date pile-ups (Anki-style fuzz/"load balancer"), and warn when new memorization is outpacing sustainable review (the quantitative version of "muraja'ah is more than half the work"). Reported real loads (~15–20 pages/day early, ~30–45/day at juz 16–25) give concrete feasibility budgets to schedule against.
- **Evidence:** Three-tier Sabak/Sabqi/Dhor system maps onto increasing-interval spaced repetition; 5:1 review-to-new rule; 7-manzil weekly cycle; daily load tables ~15–20 then ~30–45 pages (ilmify.app/blog/what-is-murajaah-quran-revision; kalimah-center.com; riwaqalquran.com; howtomemorisethequran.com). FSRS can simulate workload for any retention target to balance load (domenic.me/fsrs; fsrs4anki optimal-retention wiki).
- **Implication:** Frame the product as "muraja'ah, made adaptive": keep the familiar Sabak/Sabqi/Dhor mental model on top of an FSRS engine. Add a hard daily-load cap with due-date smoothing and a "review debt" indicator that throttles new memorization (block/slow new Sabak when projected review load exceeds the cap) — directly enforcing the 5:1 wisdom with live math instead of a fixed ratio.

### Opportunities
- Build the scheduler on FSRS's trainable DSR model (power-law curve, multiplicative stability) rather than SM-2/Leitner; fit the 19–21 weights to actual hifz review logs so the forgetting curve reflects sequence-recall, not flashcard recognition.
- Treat the mushaf page as the FSRS "card" but carry a sub-page line-level weak-spot vector, so bulk review stays feasible while partial knowledge and weak lines are tracked and drilled out-of-band without re-reviewing the whole page.
- Ship a first-class mutashabihat/interference layer (pre-seeded confusable-pairs graph from published tables) with paired INTERLEAVED discrimination review and a confusion score that bumps difficulty — the highest-value differentiator over generic SR apps, since interference (not decay) is the dominant hifz failure mode.
- Use STAKES-TIERED desired retention (~0.99 for salah/weak/mutashabihat pages, ~0.95 for routine), and surface the computable interval multipliers (0.448·S at 0.95, 0.266·S at 0.97, 0.087·S at 0.99 vs S at 0.90) so users see and choose the rigor/feasibility tradeoff explicitly.
- Derive the FSRS grade from instrumented recitation (teacher taps, or ASR forced-alignment for self-study) capturing error count, position, and type (prompted lapse vs self-corrected hesitation), giving a far richer signal than binary recall.
- Keep the familiar Sabak/Sabqi/Dhor (3-tier muraja'ah) mental model as the UX on top of the FSRS engine, easing adoption for traditional huffaz while delivering adaptive, per-page scheduling underneath.
- Add a hard daily-load cap with due-date smoothing (fuzz/load-balancer) and a "review debt" throttle that automatically slows new memorization when projected review load exceeds the sustainable budget — enforcing the 5:1 rule with live simulation instead of a fixed ratio.

### Risks
- Off-the-shelf SR retention targets (90%) are dangerously low for sacred text; using FSRS defaults without raising and tiering desired retention would tolerate ~1-in-10 page errors, which is unacceptable in recitation/salah.
- Pushing global desired retention to 0.99 to be "safe" is infeasible: it is roughly 11x the daily review load of 0.90 across 604 pages; without stakes-tiering and stability compounding the schedule collapses and users abandon it.
- No classic algorithm (SM-2, SM-17/18, FSRS, Leitner, Anki) models cross-item interference; relying on any of them unmodified will leave mutashabihat — the actual dominant error source for advanced huffaz — completely unaddressed.
- Page-level (bulk) grading can mask localized failures: a page graded "Good" overall may hide two chronically weak lines; without sub-page tracking, FSRS will lengthen the interval and the weak lines will silently rot.
- Mapping recitation fluency to FSRS grades is non-trivial and error-prone; a poor grade-derivation (e.g. treating any self-corrected hesitation as a full lapse, Leitner-style) will thrash stability and over-review, while too-lenient grading will under-review and cause forgetting.
- Serial-recall chaining means you cannot cleanly isolate a mid-page verse as an independent card; naive verse-level carding breaks the cue structure and produces unnatural, infeasible review units.
- ASR-based error detection for self-study (to grade recitation without a teacher) is technically hard for tajwid/qira'at variants and dialectal recitation; over-trusting it could mis-grade and corrupt the schedule.
- FSRS weights trained on Anki flashcard users do not reflect long-sequence recall dynamics; until enough hifz-specific review data is collected, borrowed parameters may mis-estimate stability growth for page-level cards.

### Sources
- https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler
- https://expertium.github.io/Algorithm.html
- https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm
- https://borretti.me/article/implementing-fsrs-in-100-lines
- https://domenic.me/fsrs/
- https://deepwiki.com/open-spaced-repetition/rs-fsrs/3.1-fsrs-algorithm-overview
- https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention
- https://github.com/open-spaced-repetition/fsrs4anki/blob/main/docs/tutorial.md
- https://expertium.github.io/Retention.html
- https://super-memory.com/english/ol/sm2.htm
- https://dev.to/umangsinha12/how-spaced-repetition-actually-works-the-sm-2-algorithm-1ge3
- https://supermemo.guru/wiki/Algorithm_SM-17
- https://supermemo.guru/wiki/Algorithm_SM-18
- https://help.supermemo.org/wiki/SuperMemo_Algorithm
- https://en.wikipedia.org/wiki/Leitner_system
- https://e-student.org/leitner-system/
- https://docs.ankiweb.net/deck-options.html
- https://ilmify.app/blog/what-is-murajaah-quran-revision/
- https://kalimah-center.com/memorize-the-quran-and-never-forget-it/
- https://riwaqalquran.com/blog/how-to-revise-quran-hifz/
- https://howtomemorisethequran.com/quran-memorization-daily-hifdh-plans/
- https://getitqan.com/blog/what-is-mutashabihat
- https://www.academia.edu/106990183/Tahfiz_Education_in_Malaysia_Issues_and_Problems_in_Memorising_Quranic_Mutashabihat_Verses_and_its_Solution
- https://howtomemorisethequran.com/remembering-the-similar-verses-mutashabihat-1/
- https://www.unh.edu/teaching-learning-resource-hub/sites/default/files/media/2023-06/itow-introducing-desirable-difficulties-into-practice-and-instruction-bjork-and-bjork.pdf
- https://bjorklab.psych.ucla.edu/research/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC8589969/
- https://www.mdpi.com/2079-3200/13/9/107
- https://www.sciencedirect.com/topics/psychology/serial-recall
- https://en.wikipedia.org/wiki/Recall_test
- https://studycardsai.com/blog/anki-settings-guide
- https://community.ankihub.net/t/anki-fsrs-retention-for-im-shelf-too-much-above-90/424027

---

## 4. Market & Distribution
*(from `research.market`)*

> **NOTE:** The app is being built **FREE as sadaqah jariyah**; monetization/pricing findings below are retained **only for context** and are **NOT goals**.

**Summary:** A premium Hifz tracker for serious students and huffaz sits inside a large, fast-growing, and structurally underserved niche of the Islamic app market. The addressable population is enormous: ~2 billion Muslims globally, with the four largest Muslim populations (Indonesia ~242M, Pakistan ~241M, India and Bangladesh each >150M) accounting for ~840M people (40%+ of the global total). The "Media & Recreation" slice of the Islamic economy that contains apps was valued at ~$260B in 2023, growing to ~$337B by 2028, and the Islamic digital economy saw $733.6M across 169 deals in 2024. Quran/memorization is a focused sub-niche within this: the global hafiz/hifz population is estimated at roughly **10–30M living huffaz** plus a much larger flow of active students (Pakistan alone certifies ~80,000 new memorizers/year via Wafaq-ul-Madaris), spread across madrasah networks in South Asia, MENA, Indonesia, Turkey, West Africa (Nigeria), and the Western diaspora.

The category has proven products and proven money: **Muslim Pro** (~70M downloads, ~$300K/month revenue, ~85% ads / 15% subscriptions, sold for an 8-digit sum) and **Tarteel** (the closest direct competitor — an AI memorization app with 15M+ users, backed by Founders Inc., charging ~$99/year premium and a family plan). However, the single most important strategic finding is a **tension between monetization and religious sensibility**: academic and user research shows real discomfort with "transactional models of spiritual engagement" and paywalling core worship features, and the dominant successful free products (**Quran.com / Quran Foundation** as a donation-funded 501c3; **Greentech Apps Foundation** as a UK charity with 10M+ downloads) are explicitly non-commercial, framing usage as **sadaqah jariyah**. The 2020 Muslim Pro location-data scandal (data on 98M+ users reaching the US military via brokers) shows trust and privacy are existential, not cosmetic, in this market. Monetization that works is heavily religiously-coded: halal-by-default models (one-time purchase, transparent value-add subscription, institutional/madrasah licensing, family plans, and waqf/sadaqah donation funding) avoiding riba and avoiding paywalling the act of memorization itself. Demand is also intensely seasonal, spiking ~1.6–2x in downloads and +200% in MAU during Ramadan. The opportunity is a premium, privacy-first, ethically-monetized tool that sells productivity/accountability around hifz (progress tracking, revision scheduling, mistake detection, teacher/parent oversight) rather than charging for access to scripture — with a credible institutional/madrasah B2B2C channel layered on top of a freemium or donation base.

### Key Findings

#### The addressable Muslim/Islamic-app market is very large and geographically concentrated in Asia, not MENA
- **Detail:** ~2 billion Muslims globally. Indonesia has the largest single Muslim population (~242M, ~87% of population), Pakistan ~241M, and India and Bangladesh each >150M. Indonesia, Pakistan, Bangladesh and India together hold ~840M Muslims (40%+ of the global total). Turkey is ~99% Muslim. The broader "Muslim lifestyle app" market was already framed at ~$20B back in 2015, and the Islamic economy's "Media & Recreation" sector (which houses apps) was ~$260B in 2023 growing to ~$337B by 2028, per DinarStandard's State of the Global Islamic Economy 2024/25. Total Muslim consumer spending across halal sectors reached US$2.43T in 2023. Malaysia, Saudi Arabia, Indonesia, UAE rank top of the Islamic economy.
- **Evidence:** World Population Review / Visual Capitalist / IslamiCity Muslim-population-by-country data; Salaam Gateway "$20 billion market"; DinarStandard SGIE 2024/25 (Media & Recreation $260B→$337B; $2.43T consumer spend).
- **Implication:** Prioritize Southeast Asia (Indonesia) and South Asia (Pakistan/India/Bangladesh) for volume, with MENA, Turkey, and the high-ARPU Western diaspora (US/UK/Gulf) for revenue. Localization (Urdu, Bahasa Indonesia, Arabic, Turkish, Hausa) and low-end Android optimization are prerequisites, not nice-to-haves.

#### The hifz/huffaz niche is real and continuously replenished, sustained by madrasah networks
- **Detail:** There is no global registry, so estimates vary widely, but commonly cited figures put living huffaz at roughly **10–30M** (some sources cite far higher), with Egypt and Pakistan leading in absolute numbers and Libya/Somalia in per-capita density. Pakistan's Wafaq-ul-Madaris has certified >1M completed memorizers since 1982 and adds roughly **~80,000 new memorizers per year**. Large active hifz communities also exist in Nigeria, Egypt, Indonesia, Bangladesh, Malaysia, Saudi Arabia, and Turkey. The student funnel includes children (reached via parents/teachers), adult late-starters, and women, organized largely through mosques, private madrasahs, online academies, and home circles.
- **Evidence:** Riwaq Al Quran and Alhannah hafiz-statistics articles; Wafaq-ul-Madaris data cited via hifz-education sources; Arab News (Holy Qur'an Memorization International >40,000 students).
- **Implication:** The serious-student/hafiz core is a focused but globally distributed niche. The most efficient acquisition path is institutional (madrasah/academy/teacher) rather than pure D2C, because students cluster inside structured programs and decisions are mediated by teachers and parents. Build for the parent-of-child-student and teacher-oversight use cases explicitly.

#### Tarteel is the closest direct competitor and validates both the product and a premium price point
- **Detail:** Tarteel is an AI Quran memorization/recitation app (speech recognition + "Memorization Mistake Detection") reporting 15M+ users, ~17 employees, backed by Founders, Inc. (not Y Combinator; early funding was small/grant-stage per public databases). Pricing observed: an Annual Premium around **$99/year**, monthly ~£7.50 when billed annually, and a **Family Plan ~£13/month** billed annually. It periodically runs "Premium free this month" promotions. This proves serious students will pay premium SaaS-style prices for AI-assisted memorization accountability.
- **Evidence:** Tarteel App Store listing and tarteel.ai/pricing; Tracxn/PitchBook/Crunchbase profiles; MENAbytes launch coverage; Tarteel support/help-center feature pages.
- **Implication:** There IS proven willingness to pay ~$99/year for AI memorization tooling — but Tarteel already occupies the AI-recitation-correction position with scale. A new entrant must differentiate (e.g., deeper revision/spaced-repetition scheduling, teacher/madrasah dashboards, sabaq/sabqi/manzil tracking, offline-first privacy, family accountability) rather than compete head-on on AI mistake detection alone. The family plan is a validated SKU.

#### Free, donation/charity-funded products dominate the trust and scale layer of the Quran-app market
- **Detail:** Quran.com is run by Quran Foundation, a US 501(c)(3) nonprofit (EIN 82-4203288), free and ad-free, funded by donations and explicitly framing usage as **Sadaqah Jariyah** ("continuous reward for every letter read, memorized, listened to"). It draws ~16M web visits/month (Nov 2024), top traffic from the US, audience skewing 18–24. Greentech Apps Foundation (GTAF), a UK charity, has a Quran app with 10M+ downloads (4.9 stars) and is entirely free. These set a strong "good Quran tools should be free" anchor in users' minds.
- **Evidence:** donate.quran.foundation and ProPublica nonprofit record; Similarweb/Semrush quran.com traffic; GTAF (gtaf.org) about page and App/Play store listings.
- **Implication:** Core scripture access and basic memorization tracking will be benchmarked against free, charitable alternatives. A premium app cannot charge for "access to the Quran" — it must charge for productivity, accountability, analytics, AI feedback, and institutional features. The waqf/sadaqah/donation funding model is not just allowed but is a competitively-validated, trust-building monetization path.

#### Religious sensibility constrains monetization — paywalling worship triggers churn and resentment
- **Detail:** A peer-reviewed HCI study (Taylor & Francis 2025 / arXiv 2402.02061, reviewing 11 Islamic lifestyle apps + 10 in-depth user interviews) found explicit user discomfort with "the transactional model of spiritual engagement": participants found essential features behind paywalls "disheartening," and one uninstalled an app after five days because most functionality required an upgrade — the perceived spiritual ROI didn't justify paying. The paper urges "ethically aligned design...prioritizing respect for religious sensibilities, user trust, and inclusivity over aggressive monetization."
- **Evidence:** Islamic Lifestyle Applications: Meeting the Spiritual Needs of Modern Muslims (tandfonline.com / researchgate / arxiv.org/abs/2402.02061).
- **Implication:** Aggressive freemium with worship features behind the paywall is a churn and reputational risk. Safer design: keep the act of memorization/revision free; charge for "pro" productivity, multi-student/teacher management, advanced analytics, AI feedback, and cosmetic/quality-of-life upgrades. Consider "pay what you can," lifetime one-time purchase, and donation tiers to defuse the transactional-spirituality objection.

#### Halal monetization options are well-defined; riba is the bright-line constraint
- **Detail:** Riba (interest) is a major prohibition, so anything resembling interest-bearing financing is off-limits. Religiously acceptable models for an app: one-time purchase, transparent value-add subscription (selling a service/tool, not access to scripture), family plans, institutional/madrasah licensing, and donation/sadaqah/waqf funding. Waqf (perpetual endowment via a waqif/donor and mutawalli/trustee) and Sadaqah Jariyah (ongoing charity) are increasingly used to fund digital Islamic services sustainably (e.g., Quran Foundation, GTAF charity model; "modern waqf" funding discussions). Shariah-compliant digital wallets exist to handle Zakat/Sadaqah/Waqf flows ethically.
- **Evidence:** Islamic Relief / Muslim Aid on riba; Wikipedia + Islamic-law guides on waqf; Salaam Gateway on Shariah-compliant donation wallets; Ummah Builders "modern waqf models" essay.
- **Implication:** Build a hybrid: free core (charity/waqf-supportable) + halal premium tier (one-time or subscription for tooling) + institutional licensing + optional donation/waqf contribution. Avoid any BNPL/interest mechanics. Market the monetization itself as ethical (e.g., "a portion funds free access for students who can't pay") to convert the religious objection into a trust advantage.

#### Demand is intensely seasonal — Ramadan drives a 1.6–2x usage surge
- **Detail:** Across a sample of six top religious apps, average daily downloads rose from ~118.5K to ~194.7K during Ramadan (~1.6x). For Quran Majeed specifically, daily installs jumped from ~18,119 to ~37,202 during the holy month, with single-day peaks near 98K–113K at Ramadan's start. PakData reported MAU spiking **+200% in Ramadan** and average session time rising from 22.5 to 37 minutes. Ramadan and the run-up to it is the dominant acquisition and monetization window each year.
- **Evidence:** Data Darbar "Ramzan Rush" analysis; Sensor Tower Q1 Quran-app reports; PakData engagement metrics.
- **Implication:** Time launches, pricing promotions, annual-plan pushes, and madrasah-partnership campaigns to the ~6 weeks before and during Ramadan. Plan for a 2–3x infrastructure spike. Hifz students often set Ramadan completion goals, which aligns perfectly with a progress/accountability tracker's value proposition — build seasonal "khatm by Ramadan" goal features.

#### Distribution runs through institutions and trusted figures, not paid app-store ads
- **Detail:** Muslim Pro famously reached its first ~25M users organically with zero marketing budget (first ad spend only in 2015) and grew to ~62–70M downloads, ~15M MAU, >3M DAU in low season. Indonesia's umma hit 9M downloads in ~its first year (2019–20), 3M MAU, backed by local heavyweight investors (Adaro's Garibaldi Thohir, Northstar). Quran.com and GTAF grew via direct/word-of-mouth and charitable reputation. The credible channels are madrasah/academy partnerships, imams and teachers, and Islamic influencers/scholars — trust transfer matters more than CAC-driven performance marketing.
- **Evidence:** Bitsmedia "zero marketing" post and Wamda/Salaam Gateway Muslim Pro coverage; Jakarta Post/kr-asia on umma; quran.com traffic being 66% direct.
- **Implication:** Lead with a B2B2C / institutional GTM: madrasah and online-academy partnerships (online Quran academies already charge ~$30–50/student/month, so they have budgets and billing relationships), teacher-endorsement programs, and scholar/influencer credibility. Organic, community-led, trust-first growth is the proven playbook; performance ads alone are not.

#### Trust and data privacy are existential — the Muslim Pro scandal is the cautionary tale
- **Detail:** In 2020 a Vice investigation revealed Muslim Pro had passed precise location data on 98M+ users to data brokers (e.g., X-Mode) and ultimately to US military/Special Operations buyers, via SDKs justified as "location-based prayer times." It triggered legal threats, a Singapore PDPC probe, and significant uninstalls/backlash. The market is acutely sensitive to surveillance given the population's geopolitical exposure.
- **Evidence:** Vice via Al Jazeera and Foxglove coverage; Columbia Human Rights Law Review case study; Muslim Pro's own denial statement.
- **Implication:** Privacy-first / offline-first architecture and an explicit no-data-selling, no-third-party-tracking stance are a genuine differentiator and a marketing asset for a premium product. This also reinforces choosing subscription/one-time/donation revenue over ad/data-monetization — ads are both the religiously-grey and the trust-destroying path here.

### Opportunities
- Position as a premium PRODUCTIVITY/ACCOUNTABILITY tool for hifz (spaced-repetition revision scheduling, sabaq/sabqi/manzil tracking, mistake logging, streaks, khatm goals) rather than charging for scripture access — sidestepping the "free Quran" anchor and the "transactional spirituality" objection.
- Institutional/madrasah B2B2C licensing: sell teacher/admin dashboards and per-student seats to madrasahs and online Quran academies (which already bill ~$30–50/student/month and have payment relationships), creating recurring, defensible revenue and built-in distribution.
- Family plan SKU (validated by Tarteel) targeting parents managing children's memorization — parent oversight, progress reports, and multi-child management as paid value.
- Halal hybrid monetization: free core funded partly by waqf/sadaqah donations + premium one-time or subscription tier + "sponsor a student" giving — marketed as ethical, with a portion funding free access for those who can't pay (converts the religious objection into a trust/marketing advantage).
- Privacy-first / offline-first as a headline differentiator post-Muslim-Pro-scandal: explicit no-ads, no-tracking, no-data-selling — a credible premium and trust signal the incumbents can't easily match.
- Ramadan-anchored growth engine: seasonal "complete-by-Ramadan" goals, annual-plan promotions, and madrasah campaigns timed to the ~6 weeks of 1.6–2x demand surge.
- Diaspora high-ARPU beachhead (US/UK/Gulf) where willingness to pay is highest and Quran.com's audience already skews, while building volume via low-cost localized Android in Indonesia, Pakistan, India, Bangladesh, Nigeria, Turkey.
- Differentiate from Tarteel by owning revision/retention science and teacher-student-parent workflows rather than competing only on AI recitation-correction, where Tarteel already has scale.
- Influencer/scholar endorsement and teacher-referral programs as primary CAC-efficient channels, mirroring the organic, trust-led growth of Muslim Pro, umma, Quran.com, and GTAF.

### Risks
- "Free Quran tools should be free" anchor set by donation-funded incumbents (Quran.com / Quran Foundation, Greentech Apps Foundation with 10M+ downloads) compresses willingness to pay for anything perceived as core.
- Documented user discomfort with paywalling worship features (peer-reviewed study: uninstalls after 5 days, "disheartening," insufficient spiritual ROI) — aggressive freemium risks churn and reputational damage.
- Tarteel already occupies the premium AI-memorization position at scale (15M+ users, ~$99/yr, family plan, Founders Inc. backing) — direct competition on AI recitation-correction is uphill.
- Trust/privacy is existential: any data-monetization or perceived surveillance can trigger Muslim-Pro-style backlash, legal threats, regulatory probes, and mass uninstalls among a privacy-sensitive, geopolitically-exposed user base.
- Riba and ethical constraints limit financing/ads-based models; missteps (e.g., interest-like mechanics, intrusive ads on scripture) can be branded haram and kill adoption.
- Heavy Ramadan seasonality creates lumpy revenue and retention cliffs — most engagement and willingness to convert clusters into a few weeks, with steep post-Ramadan drop-off risk.
- Low-ARPU in the largest-volume markets (Indonesia, Pakistan, India, Nigeria) means high-download geographies may not monetize directly; price localization and institutional billing are needed to avoid a "lots of users, little revenue" trap (mirroring why Quran Majeed earned only ~8% of Android revenue from 35%+ of downloads in India/Pakistan).
- Fragmented madrasah landscape (no central registry, varied certification) makes institutional sales high-touch and slow despite the channel's strategic value.
- Islamic-tech venture funding, while growing ($733.6M / 169 deals in 2024), concentrates ~50% in fintech; faith-tech edutainment apps may struggle to raise large rounds (Tarteel's modest disclosed funding is indicative), pushing toward bootstrapped/charity-funded sustainability.

### Sources
- https://salaamgateway.com/story/the-global-islamic-economy-202425-overview-muslim-consumer-market-size-and-trajectory
- https://www.dinarstandard.com/insights/sgier-2024-25
- https://salaamgateway.com/en/story/muslim_lifestyle_appsgaining_share_in_a_20_billion_market-salaam14032016124711
- https://worldpopulationreview.com/country-rankings/muslim-population-by-country
- https://www.visualcapitalist.com/ranked-countries-with-the-largest-muslim-populations/
- https://en.wikipedia.org/wiki/Islam_in_Indonesia
- https://riwaqalquran.com/blog/hafiz-are-in-the-world/
- https://riwaqalquran.com/blog/countries-statistics-related-to-hafiz/
- https://blog.alhannah.com/how-many-people-memorize-the-quran-a-deep-dive-into-global-hafiz-culture/
- https://www.arabnews.com/holy-qur%E2%80%99-memorization-international-sees-more-40000-qur%E2%80%99-students
- https://tarteel.ai/pricing
- https://apps.apple.com/us/app/tarteel-ai-quran-memorization/id1391009396
- https://www.menabytes.com/tarteel-app/
- https://tracxn.com/d/companies/tarteel/__0EYCFu9t7pvXZMSUrFEZroYSP1ZJ3qfYhdmWc6xG2h8
- https://f.inc/portfolio/tarteel/
- https://bitsmedia.com/muslim-pro-zero-marketing/
- https://www.wamda.com/2014/01/how-the-muslim-pro-app-got-9m-of-muslim-users
- https://salaamgateway.com/en/story/muslim_pro_buyout__is_tip_of_the_iceberg_for_investment_in_digital_islamic_economy-salaam06082017092611
- https://app.sensortower.com/overview/388389451?country=US
- https://www.aljazeera.com/news/2020/11/17/report-us-military-buying-location-data-on-popular-muslim-apps
- https://www.foxglove.org.uk/2020/11/24/two-users-of-muslim-pro-threaten-legal-action-over-leaked-location-data/
- https://hrlr.law.columbia.edu/hrlr-online/a-fourth-amendment-loophole-an-exploration-of-privacy-and-protection-through-the-muslim-pro-case/
- https://donate.quran.foundation/
- https://projects.propublica.org/nonprofits/organizations/454269198
- https://www.similarweb.com/website/quran.com/
- https://gtaf.org/about/
- https://www.tandfonline.com/doi/full/10.1080/10447318.2025.2595545
- https://arxiv.org/abs/2402.02061
- https://insights.datadarbar.io/ramzan-rush-how-religious-apps-get-more-popular-during-ramzan/
- https://sensortower.com/blog/2025-q1-ios-top-5-books-units-mid_east-6042071f241bc16eb8c33b77
- https://islamic-relief.org/interest-riba/
- https://en.wikipedia.org/wiki/Waqf
- https://salaamgateway.com/story/ethical-giving-shariah-compliant-digital-wallets-for-donations
- https://ummahbuilders.substack.com/p/modern-waqf-models-islamic-impact
- https://salaamgateway.com/ranking/top-30-digital-islamic-economy-startups-2024
- https://www.halaltimes.com/islamic-digital-economy-sees-rising-investments-by-top-vcs/
- https://www.thejakartapost.com/life/2020/09/16/umma-app-launches-muslim-e-learning-platform-uclass.html
- https://kr-asia.com/in-times-of-a-pandemic-muslim-prayer-apps-are-gaining-followers
- https://www.pakquranacademy.com/fee-structure/
- https://www.alsyedquran.com/fee-chart/
- https://insights.datadarbar.io/decoding-the-massive-market-for-islamic-apps/

---

## 5. Quran Data & Technical Sources
*(from `research.tech`)*

**Summary:** Quran hifz app research across text sources, fonts, structure, audio, datasets, AI mistake detection, and cross-platform architecture.

### Key Findings

#### Tanzil text is canonical/free under CC BY 3.0 (verbatim-only); error-free diacritics is existential
- **Detail:** **Tanzil.net** under **CC BY 3.0**; changing it is **NOT allowed**; credit + link required; variants **Simple / Uthmani**; formats plain/XML/SQL. A single wrong diacritic is a reputational catastrophe, but per Muslim Pro most reported app errors are **DEVICE rendering failures**, not source text.
- **Evidence:**
  - https://tanzil.net/docs/text_license
  - https://tanzil.net/download/
  - Muslim Pro support article
  - Flutter #54529, #143975
- **Implication:** Store Tanzil Uthmani unmodified with attribution; checksum in CI; render via KFGQPC glyph fonts not the OS shaper; visual-diff vs reference mushaf images.

#### KFGQPC/QPC page-by-page glyph fonts give pixel-faithful mushaf; structure is fixed
- **Detail:** **604 glyph fonts (QCF_P001–604)**, each glyph a pre-shaped word, one per Madani 15-line page (the Quran.com / Tarteel method); free-use license but **no modify/sell/reverse-engineer**. Structural hierarchy: **30 juz, 60 hizb, 240 rub al-hizb (U+06DE), 604 pages, 15 lines/page, 114 surah, 6236 ayah**.
- **Evidence:**
  - https://github.com/nuqayah/qpc-fonts
  - https://qul.tarteel.ai/resources/font/249
  - https://openhub.net/licenses/KFGQPC
  - https://en.wikipedia.org/wiki/Rub_el_Hizb
- **Implication:** Bundle QPC fonts unmodified; pair with QUL MushafPage / MushafWord layout; page/line/word layout must come from a mushaf dataset (QUL), never computed (line breaks are calligraphic).

#### Tarteel QUL is the central MIT-licensed data hub
- **Detail:** **TarteelAI/quranic-universal-library** (MIT, Rails): **20+ mushaf layouts** (MushafPage / MushafWord; JSON/SQLite/DOCX), **200 translations + 16 word-by-word**, **57 segmented recitations** with ayah/word timestamps, scripts + tajweed, **19 fonts incl. QPC**, morphology **77432**.
- **Evidence:**
  - https://github.com/TarteelAI/quranic-universal-library
  - https://qul.tarteel.ai/
  - https://deepwiki.com/TarteelAI/quranic-universal-library/1-overview
- **Implication:** Use QUL as the primary data layer; **MIT covers platform/exports, but underlying assets (KFGQPC fonts, translations) keep their own licenses**, so verify per resource before shipping.

#### Audio across 50+ qaris with timing, word-by-word/tajweed (watch GPL), and AI mistake detection on open assets
- **Detail:** **EveryAyah** 50+ qaris ayah MP3s (`SSSAAA.mp3`, 192/128/64 kbps; rights unstated); **QuranicAudio** gapless; **Quran Foundation API v4** verse+word audio/timing; **alquran.cloud** no-auth. The **Quranic Arabic Corpus is GPL v3** (avoid in closed-source); QUL is app-friendly. **tarteel-ai/everyayah** is CC BY 4.0 (~800+ hrs diacritized); Whisper fine-tunes ~4–6% WER; Tarteel cloud ~4% WER <200ms; offline FastConformer ONNX ~115MB.
- **Evidence:**
  - https://everyayah.com/
  - https://api-docs.quran.foundation/docs/sdk/audio/
  - https://en.wikipedia.org/wiki/Quranic_Arabic_Corpus
  - https://huggingface.co/datasets/tarteel-ai/everyayah
  - https://github.com/yazinsai/offline-tarteel
- **Implication:** Bundle per-ayah audio (`SSSAAA.mp3`) for offline looping; prefer Quran Foundation / QuranicAudio / QUL for licensed qaris; prefer QUL over the GPL Corpus. Align ASR to the KNOWN ayah (constrained decoding) and diff at word + diacritic level; cloud + on-device ONNX hybrid.

#### Stack: Flutter with QPC glyph fonts; strict offline-first SQLite with CRDT sync for progress only
- **Detail:** Flutter's own **Skia/Impeller engine** gives consistent cross-platform Arabic, avoiding OS shaper variance (the dominant error source); but it has Arabic bugs (**#143975** Lateef/Scheherazade vs Amiri; **#54529** iOS diacritics). RN/native inherit platform shapers. Offline-first: local SQLite source of truth, **immutable read-only content**, per-juz audio (hundreds of MB to ~1–2GB), user progress synced via **CRDT** (SQLite-Sync / Turso / cr-sqlite); content never syncs.
- **Evidence:**
  - https://github.com/flutter/flutter/issues/143975
  - https://github.com/flutter/flutter/issues/54529
  - https://pub.dev/packages/arabic_reshaper
  - https://github.com/sqliteai/sqlite-sync
  - https://docs.expo.dev/guides/local-first/
- **Implication:** Use Flutter but render the mushaf with KFGQPC glyph fonts (no Unicode shaping); Amiri / KFGQPC Hafs for other text; visual-regression tests. Immutable checksummed content + small synced user-state DB; granular per-juz/qari audio downloads.

### Quick Reference — Data Sources, Licenses & Structural Counts

| Item | Value / License |
|---|---|
| **Quran text** | Tanzil.net, **CC BY 3.0**, verbatim-only (no modification), attribution + link required |
| Text variants | Simple, Uthmani (plain / XML / SQL formats) |
| **Page glyph fonts** | KFGQPC / QPC, `QCF_P001–604` (one font per page), free-use, **no modify/sell/reverse-engineer** |
| **Data hub** | TarteelAI QUL (`quranic-universal-library`), **MIT** (assets keep own licenses) |
| QUL layouts | 20+ mushaf layouts (MushafPage / MushafWord) |
| QUL translations | 200 translations + 16 word-by-word |
| QUL recitations | 57 segmented recitations with ayah/word timestamps |
| QUL fonts / morphology | 19 fonts incl. QPC; morphology 77432 |
| **Audio (per-ayah)** | EveryAyah `SSSAAA.mp3` (192/128/64 kbps), 50+ qaris (rights unstated) |
| Audio (gapless) | QuranicAudio |
| Audio APIs | Quran Foundation API v4 (verse+word audio/timing); alquran.cloud (no-auth) |
| Quranic Arabic Corpus | **GPL v3** — avoid in closed-source |
| ASR dataset | `tarteel-ai/everyayah`, **CC BY 4.0**, ~800+ hrs diacritized |
| ASR accuracy | Whisper fine-tunes ~4–6% WER; Tarteel cloud ~4% WER <200ms; offline FastConformer ONNX ~115MB |
| **Structural counts** | 30 juz · 60 hizb · 240 rub al-hizb (U+06DE) · 604 pages · 15 lines/page · 114 surah · 6236 ayah |
| Suggested stack | Flutter (Skia/Impeller, avoids OS shaper variance) + KFGQPC glyph fonts |
| Sync model | Local SQLite source of truth; immutable content (never syncs); user progress via CRDT (SQLite-Sync / Turso / cr-sqlite) |

---

## 6. User Segments & Personas
*(from `research.users`)*

**Summary:** A Hifz tracker with spaced repetition serves **seven distinct segments**, but they are not equally valuable. The market is already crowded with logging tools (Hifz Tracker, Sullam, Hifdh Tracker, Al-Muhaffiz, Al-Rahma) that act as calendars/checklists. The genuinely underserved, high-pain, emotionally charged job is **RETENTION after finishing**: the manzil/dhor problem. Every credible source independently confirms that Hifdh is never finished and the dominant failure mode is **forgetting, not memorizing**. Hadith-driven guilt makes this pain spiritual and urgent. Spaced repetition is the literal mechanism that solves this job, yet existing SRS attempts (Retain Quran, Mathani) are buggy, low-download, and shallow.

The best initial wedge is **Persona 2**: the hafiz fighting to retain the whole Quran, who has the most acute pain, the clearest payment trigger (fear of loss plus identity), the strongest fit with spaced repetition as a core mechanic, and the least adequate tooling. **Adult late-starters (Persona 3)** are the strongest expansion segment because they share the same retention engine and have disposable income; **teachers (Persona 5)** are the highest-LTV but hardest-to-win B2B segment, pursued only after the consumer wedge proves the engine.

### Key Findings

#### Persona 2 (hafiz retaining the whole Quran) is the highest-pain, worst-served segment and the best wedge
- **Detail:**
  - **GOAL:** never lose what cost years to memorize; keep 30 juz fresh enough to lead prayers and recite on demand.
  - **WORKFLOW:** traditional fixed rotations; Kalimah Sticky Hifz prescribes one juz per day (full Quran every 30 days) or a 5-day/5-juz cycle, with manzil cycled completely at least every 2 weeks; the load is large, unbounded, and self-managed on paper.
  - **BIGGEST PAIN:** the load is crushing and grows over time, and it is spiritually loaded (huffaz express real distress about being told they must re-memorize all they forgot or face Hell; one documented case memorized the whole Quran in 2012, forgot through neglect, and is restarting in 2024).
  - **WHAT MAKES THEM PAY:** a system that says exactly what to revise today so nothing silently decays, framed as loss prevention and peace of mind.
  - **FEATURES THAT MATTER:** weakness-aware SRS scheduling, per-page strength tracking, mistake/stumble logging, audio blind self-test, a bounded adaptive daily queue.
  - **NOISE:** child gamification/streaks, completion-estimate calculators, social leaderboards.
- **Evidence:** Kalimah Sticky Hifz; qari.substack stacking and murajaah systems; AboutIslam fatwa distress quote; Quora forgetting thread (2012 to forgot to 2024 restart). Existing SRS apps Retain Quran (4.7 stars but only 24 ratings, cards reset every 30 days, broken audio) and Mathani are shallow/buggy/low-download.
- **Implication:** Spaced repetition is not a feature here, it is the product. Pain is daily, recurring, spiritual, and incumbents are calendars not retention engines. Build the weakness-aware revision scheduler for huffaz first.

#### Persona 1 (full-time madrasah memorizer) is already served by the teacher and is a weak wedge
- **Detail:**
  - **GOAL:** complete 30 juz as fast as quality allows.
  - **WORKFLOW:** highly supervised, with daily sabaq (new, 20–40x), sabaq para (last 7 days), and dhor (old), recited to a teacher every day.
  - **BIGGEST PAIN:** discipline and teacher time, not software; the institution owns the tracking loop.
  - **WHAT MAKES THEM PAY:** little, usually minors, so the teacher or parent pays.
  - **FEATURES THAT MATTER:** a simple daily log the teacher can see.
  - **NOISE:** standalone consumer SRS, since the ustadh dictates the revision schedule, not an algorithm.
- **Evidence:** ilmify and Kalimah describe the rigid sabaq/sabaq-para/dhor structure enforced by teachers; institutional daily Hifdh plans show fixed schedules; Hifz Tracker markets teacher/parent invite features for this loop.
- **Implication:** Reachable only through the teacher/institution (B2B), with low individual willingness-to-pay and an already-solved accountability loop. Poor starting point.

#### Persona 3 (working adult late-starter) is the strongest secondary segment, sharing the retention engine and having real money
- **Detail:**
  - **GOAL:** steady progress (3–5 years to complete is realistic) without burnout or forgetting.
  - **WORKFLOW:** 15–30 min per day, fragmented, shifting work to the evening to compensate, reciting each page to a remote teacher.
  - **BIGGEST PAIN:** fragile unsupervised retention plus discouragement comparing to children, and guilt over stalled progress; they forget last month's pages while learning this week's.
  - **WHAT MAKES THEM PAY:** a self-directed system that replaces the teacher "what-do-I-revise-today" function and prevents all-or-nothing collapse; disposable income makes them the natural App Store buyer.
  - **FEATURES THAT MATTER:** adaptive SRS fitting 15-minute windows, a minimum-viable-revision mode for busy days, gentle non-shaming progress, hands-free audio review.
  - **NOISE:** rigid madrasah quotas, child gamification.
- **Evidence:** MuslimMatters Work-Life Balance (half-page AM/PM; "Review, review and more review," "Hifdh is never finished"); quranica/quransheikh (3–5 years for working adults, consistency over duration); quranmindmaps avoid the all-or-nothing mentality; AboutIslam distress quote.
- **Implication:** Best expansion after the wedge: same retention engine, broader TAM, real consumer payment behavior. Personas 2 and 3 share the same core feature, validating the wedge choice.

#### Persona 4 (parent) and Persona 5 (teacher) want visibility and admin, a separate B2B product pursued later
- **Detail:**
  - **PARENT GOAL:** know what was memorized, what needs revision, and that the child is not silently failing dhor.
  - **PARENT PAIN:** mysterious progress, reliance on a paper diary or scattered WhatsApp. Parents would pay for transparency and home-help guidance.
  - **PARENT FEATURES:** read-only dashboard, revision reminders, "what to review with child tonight."
  - **TEACHER GOAL:** manage 15-plus students each at a different juz with separate sabaq/sabaq-para/dhor status.
  - **TEACHER PAIN (sharpest B2B pain found):** keeping it in your head, a notebook, or three different WhatsApp messages; paper records get lost, are not accessible to parents, cannot be read by a substitute, and do not produce reports; a student can make excellent progress on new memorization while their Dhor falls apart.
  - Teachers would pay (institution budget) for multi-student dashboards, auto parent reports, struggling-student alerts, and substitute continuity.
  - **TEACHER FEATURES:** roster management, per-student 3-stage tracking, exportable reports, parent portal.
- **Evidence:** ilmify Hifz Tracking for Islamic Schools (15 students at different stages, lost paper records, WhatsApp compliance issues, Dhor falls apart); hifztracker.com For Teachers and School with $0.99 per student per month pricing; Al-Rahma Academy and IQRA Network parent dashboards.
- **Implication:** Highest LTV (recurring per-student revenue) but hardest to win (sales plus multi-sided product). Correct as a later monetization layer once the consumer retention engine has credibility, not the cold-start wedge.

#### Persona 6 (women) and Persona 7 (reverts) are constraint-driven niches, served via inclusive features rather than separate wedges
- **Detail:**
  - **WOMEN GOAL:** memorize/revise around menstruation cycles and home/childcare schedules, often without a public halaqa.
  - **WOMEN PAIN:** roughly one week per month of fiqh ambiguity about touching the mushaf; many follow the permissive view (recite from memory or a digital device without touching the printed Quran) to keep up hifz. Women would pay for a private, screen-based revision tool with flexible scheduling that pauses/shifts during menstruation without losing the streak.
  - **WOMEN FEATURES:** digital-only recitation, a pause/period mode that reschedules without penalty, privacy.
  - **REVERT GOAL:** memorize the short surahs needed for salah, with no Arabic.
  - **REVERT PAIN:** does not know where to start, cannot read Arabic script, intimidated by long surahs, no community. Reverts would pay (low) for guided onboarding starting with prayer surahs, transliteration plus audio, tiny daily bites.
  - **REVERT FEATURES:** transliteration, audio-first, salah-surah starter track, beginner-safe pacing.
  - **NOISE:** 30-juz dhor scheduling, advanced SRS internals.
- **Evidence:** British Fatwa Council, muftiwp, and Al-Salam Institute (permissive view: recite from memory or digital device during menses for memorization, without touching the mushaf); qari.substack introduce-yourself comments and Gulf News (non-Arabic memorizers succeed); quranforallschool start-even-if-busy and short-surah/transliteration starter resources.
- **Implication:** Do not build separate products. Digital-only plus pause mode (women) and transliteration plus audio plus salah starter track (reverts) are low-cost inclusive features that widen the funnel for the core retention product. They are funnel-wideners, not wedges.

### Opportunities
- Lead with a **weakness-aware spaced-repetition revision engine for huffaz (Persona 2)**: the app tells you exactly which pages to revise today before they decay, with a bounded daily queue, directly attacking the one job every incumbent tracker fails to solve.
- Reframe the value proposition from "track your hifz" (crowded, commoditized) to "never lose your hifz" / loss prevention and peace of mind, aligning with the spiritual fear of forgetting that drives this segment.
- Per-page strength plus mistake logging during recitation feeds the SRS so revision concentrates on weak pages; huffaz currently revise blindly on a fixed rotation, wasting time on strong pages.
- Audio-first blind self-testing (hands-free, commute/chores) unlocks the adult late-starter (Persona 3) and fits women's home schedules, a natural expansion once the engine works.
- Inclusive features at low cost: a fiqh-friendly digital-only pause-during-menstruation mode (women) and a transliteration plus salah-surah starter track (reverts) widen the funnel without a separate build.
- Later monetization: a teacher/institution layer (multi-student 3-stage dashboards, auto parent reports, struggling-student/Dhor alerts) at recurring per-student pricing, the highest LTV, pursued after the consumer engine earns credibility.

### Risks
- Crowded tracker category: Hifz Tracker, Sullam, Hifdh Tracker, Al-Muhaffiz, and Al-Rahma already occupy the logging/calendar space; entering as another tracker is a losing position, so differentiation must be the retention engine, not the log.
- SRS-for-Quran is not greenfield: Retain Quran and Mathani already claim spaced repetition. Their weakness (bugs like cards resetting every 30 days, broken audio, low downloads) is the opening, but execution quality on the SRS scheduler is the whole game.
- Theological/fiqh sensitivity: spaced-repetition flashcards of the Quran and digital recitation rulings vary by madhhab; mishandling (fragmenting ayat awkwardly, ignoring the touch-the-mushaf concern) risks community rejection and needs scholarly sign-off.
- Monetization tension: the highest-pain consumer (Persona 2) values free Islamic tools (Retain Quran is free, ad-free) and may resist subscriptions; willingness-to-pay must be tested via loss-aversion/peace-of-mind framing or a teacher-funded model.
- Persona 1 (madrasah students) and the institutional channel are gated by teachers/parents, not the end user, so chasing them first means a hard B2B sale before consumer product-market fit.
- Retention load grows unbounded as huffaz advance; the scheduling algorithm must gracefully cap and prioritize, or the app reproduces the exact overwhelm it claims to solve.

### Sources
- https://kalimah-center.com/memorize-the-quran-and-never-forget-it/
- https://qari.substack.com/p/a-creative-system-for-revision-murajaah
- https://qari.substack.com/p/the-ottoman-stacking-system
- https://aboutislam.net/counseling/ask-the-scholar/quran-hadith/forgetting-quran-lead-hell/
- https://www.quora.com/If-Quran-Hafiz-has-forgotten-the-Quran-what-is-the-punishment-in-the-hereafter
- https://muslimmatters.org/2017/06/15/on-maintaining-work-life-balance-while-memorizing-the-quran/
- https://ilmify.app/blog/hifz-tracking-islamic-schools/
- https://ilmify.app/blog/sabak-sabaq-para-dhor-hifz-stages/
- https://apps.apple.com/us/app/-/id1624792039
- https://apps.apple.com/app/id6748412999
- https://apps.apple.com/us/app/hifz-tracker/id6748594784
- https://hifztracker.com/for-teachers-school/
- https://iqranetwork.com/blog/the-best-online-hifz-program-for-children-with-real-parent-tracking/
- https://quranica.com/articles/how-long-does-it-take-to-learn-quran/
- https://www.quransheikh.com/quran-memorization-schedule/
- https://www.britishfatwacouncil.org/memorising-the-quran-whilst-menstruating/
- https://www.muftiwp.gov.my/en/artikel/irsyad-fatwa/irsyad-fatwa-umum-cat/2057-irsyad-al-fatwa-18-the-ruling-of-reciting-and-reviewing-one-s-memorization-of-the-quran-during-menstruation
- https://quranforallschool.com/en-US/how-to-start-memorizing-quran-even-if-youre-busy/
- https://quranmindmaps.substack.com/p/avoid-the-all-or-nothing-mentality
- https://howtomemorisethequran.com/daily-routines-for-memorising-quran/

---

## 7. SR Engine Design A — FSRS-rigor ("DSR-Q")
*(from `designs.srA`)*

### Overview

**HIFZ-SR ENGINE ("DSR-Q"): an FSRS-rigorous spaced-repetition core for Quran memorization**

The engine is a single **unified FSRS-style scheduler** operating on one card type — the **mushaf page** (604 cards) — with per-card Difficulty/Stability/Retrievability (DSR) state. The three traditional tracks (sabaq/sabqi/manzil) are NOT separate algorithms; they are **lifecycle phases of the same card**, distinguished only by their Stability band and target retention. This is the central design decision: one math model, three phase-dependent parameterizations, automatic hand-off when a card's Stability crosses a threshold. This eliminates the duplicated-logic and hand-off bugs that plague separate-queue trackers (Al-Muhaffiz etc.) while preserving the workflow huffaz already trust.

Key adaptations over vanilla FSRS:

1. **Page card with line-resolution error vector** — grade comes from WHERE and HOW MANY errors occur in a bulk recitation, not a binary card flip. Sub-page (line/ayah) state is a derived overlay used only to localize weakness and seed mutashabihat links; the scheduled unit stays the page so the review queue maps to how huffaz actually recite (whole pages in flow).
2. **Phase-dependent desired retention** — sabaq 0.90, sabqi 0.94, manzil 0.97–0.99. Sacred-text near-100% is achieved not by a single global R but by driving the *long-term* phase to a steep, finite point on FSRS's cost curve while keeping new-material cost sane.
3. **Explicit mutashabihat interference layer** — a graph of confusable passages (seeded from a curated dataset, grown from the user's own confusion errors) that (a) co-schedules linked pages into the same session for discrimination drills and (b) injects a per-card Interference penalty into the difficulty/stability update, because for hifz interference — not decay — is the dominant failure mode.
4. **Budget-aware load balancer** — a daily solver that fits due reviews + new sabaq into the user's minutes/day, using FSRS retrievability to decide what is safe to defer vs. what is un-deferrable (manzil is hard-capped as un-skippable, matching the empirical "never drop dhor" rule).
5. **Graded grading pipeline** — self-rating, teacher rating, and AI audio-listening all normalize to the same internal **(grade, error_vector)** signal with a per-source **confidence weight** that scales how aggressively the DSR update moves. AI/teacher signals (objective error positions) move state more than self-rating (noisy).
6. **Cold start for partial huffaz** — a calibration placement flow plus a per-card recency/age prior that seeds D/S without pretending strength is known, then converges over the first 2–3 weeks of real grades.

The math backbone is FSRS-6's power-law forgetting curve `R(t,S) = (1 + FACTOR·t/S)^DECAY` with DECAY≈-0.5, FACTOR = 19/81, so R(S)=0.9 by definition of S. Intervals are inverted from desired retention: `I = (S/FACTOR)·(R_desired^(1/DECAY) − 1)`.

### Data Model

#### Static reference (read-only, from QUL/Tanzil, never user-specific)
```
Page        { page_id 1..604, juz, hizb, rubʿ, surah_span, line_ids[1..15] }
Line        { line_id, page_id, line_no 1..15, ayah_refs[], word_ids[] }
Ayah        { ayah_id (surah:ayah), page_id, line_ids[] }
// Hierarchy is fixed: 30 juz / 60 hizb / 240 rubʿ / 604 pages / 15 lines / 6236 ayah
```

#### Card (the scheduled unit) — one row per page per user
```
Card {
  user_id, page_id
  phase: enum { NEW, SABAQ, SABQI, MANZIL }      // derived from stability band, persisted for queueing
  D: float [1,10]      // FSRS Difficulty
  S: float days        // FSRS Stability
  last_review: datetime
  due: datetime
  reps, lapses: int
  state: enum { unseen, learning, review, relearning }
  enabled: bool        // false = not yet in user's memorized scope (cold start)
  // derived-but-cached:
  R_now: float         // retrievability at "now", recomputed lazily
}
```

#### Sub-page strength overlay (derived; for localization, NOT scheduling)
```
LineStrength { user_id, line_id, error_rate_ewma, last_error_at, weak_flag }
```
Rolls UP: page weakness = max/weighted-mean of its 15 lines' error EWMA.
Rolls DOWN: when a page lapses, distribute the difficulty bump to the line(s) where errors actually occurred (from error_vector); clean lines are spared. This is how strength "rolls up and down the hierarchy" — **the page carries the schedule, the line carries the diagnosis.**

#### Mutashabihat interference graph
```
MutashabihGroup { group_id, ayah_ids[], type: enum{identical, near_identical, structural}, source: enum{curated, user_discovered} }
ConfusionEdge   { user_id, ayah_id_a, ayah_id_b, weight, last_confused_at }
   // weight grows each time the user recites A's text while in B's location (a "swap" error)
```

#### Review log (append-only; trains FSRS params + audits)
```
ReviewLog {
  user_id, page_id, ts, phase
  grade: enum { Again=1, Hard=2, Good=3, Easy=4 }
  error_vector: [ {line_no, type: missed|added|swapped|tajweed|hesitation, ayah_id?, confused_with_ayah_id?} ]
  source: enum { self, teacher, ai_audio }
  source_confidence: float [0,1]
  elapsed_days, R_predicted, S_before, S_after, D_before, D_after
}
```

#### User config
```
UserConfig {
  daily_budget_minutes
  per_phase_target_R: { sabaq:0.90, sabqi:0.94, manzil:0.97 }   // tunable, with safe floors
  new_pages_per_day_cap
  manzil_cycle_preset: enum{ 7day, 5day, 30day, custom }
  grading_source_default
  fsrs_weights: float[w0..w20]   // personalized FSRS-6 params; start from population defaults
}
```

The FSRS weight vector (w0..w20) is per-user and re-fit nightly once ≥~100 reviews exist; before that, population defaults are used. Cold-start huffaz get default weights but per-card D/S priors (see scheduling logic / cold start).

### Scheduling Logic

#### 1. Core DSR update (runs on every graded review)
FSRS-6 forgetting curve and interval inversion:
```
DECAY  = -0.5
FACTOR = 0.9^(1/DECAY) - 1 = 19/81 ≈ 0.2346
R(t,S) = (1 + FACTOR * t/S)^DECAY
I(S, R_target) = (S/FACTOR) * (R_target^(1/DECAY) - 1)   // days until R hits target
```
On review at elapsed t with grade g:
- R_pred = R(t, S_before)
- Update D and S using FSRS-6 stability functions: S_recall (g≥Good) grows S as a function of (D, S, R_pred); S_forget (g=Again) computes a smaller post-lapse stability. D drifts toward grade with mean-reversion.
- **Interference penalty (hifz-specific):** if error_vector contains a `swapped`/`confused_with` entry, multiply the stability gain by (1 − λ·edge_weight_norm) and add a difficulty bump, because the failure was confusion not decay — bigger S growth would be a lie.
- new_due = last_review + I(S_after, target_R_for_phase)

#### 2. Phase hand-off (the three tracks unified)
Phase is a pure function of Stability, evaluated after each update:
```
NEW    : unseen / first exposure
SABAQ  : S <  ~9 days     target_R 0.90   (still solidifying today's lesson)
SABQI  : ~9 ≤ S < ~60     target_R 0.94   (recent-juz consolidation)
MANZIL : S ≥ ~60 days     target_R 0.97+  (long-term maintenance)
```
Hand-off is automatic and graceful: as S grows past a band edge the card silently graduates; the only change is its target_R (which lengthens intervals) and which budget bucket it draws from. A lapse can demote a card (relearning) back toward SABQI/SABAQ — this is exactly the traditional "a forgotten manzil page rejoins active revision."

#### 3. Daily queue assembly (per session)
```
due_today   = cards where due <= now AND enabled
new_today   = up to new_pages_per_day_cap unseen pages, in mushaf order (sabaq)
Partition due_today by phase. Order of recitation follows tradition:
   manzil (oldest, un-skippable) -> sabqi -> sabaq/new   ("dhor before new")
Inject mutashabihat co-review: if any due card belongs to a ConfusionGroup, pull its
   linked pages into the same session even if not yet due (discrimination drill).
Hand to load balancer (see load balancing) to fit daily_budget_minutes.
```

#### 4. Manzil cycle as a retention floor, not a fixed calendar
Traditional 7-manzil/30-juz cycles are reproduced as an **emergent property**: with manzil target_R≈0.97 and grown S, each page's natural interval lands in the weeks-to-month range, so the union of due manzil pages ≈ one juz/day for a full hafiz. The preset (7day/30day) acts as a *ceiling* on interval (never let a page go longer than the user's chosen cycle) so the schedule can't drift looser than the user's spiritual comfort allows, even if the math would permit it.

### The Three Tracks: Unified Scheduler, Phase Hand-off

Decision: **ONE scheduler, three phases of a single card** — not three engines.

- **Sabaq (new):** a page enters as NEW, gets intensive short-interval learning steps, target_R 0.90 (we accept more re-exposure cheaply because the page is being built). Cap = new_pages_per_day from UserConfig (default 1 page ≈ 15 lines, tunable to the classic 3–5 lines by sub-page sabaq for beginners).
- **Sabqi (consolidation):** once S crosses ~9 days the page is "recent." target_R 0.94. This is the rolling last-1-3-juz window; in DSR terms it's simply every card with mid-band stability. No separate queue — it's a filter on phase.
- **Manzil (long-term):** S ≥ ~60 days, target_R 0.97+. Un-skippable: the load balancer may defer sabqi and reduce new, but manzil due items are hard-capped as must-do (encoding "dropping manzil = most loss").

**Hand-off mechanics:** purely stability-threshold driven and reversible.
```
after each review:
   card.phase = NEW    if state==unseen
              = SABAQ  if S < SABAQ_MAX
              = SABQI  if SABAQ_MAX <= S < SABQI_MAX
              = MANZIL if S >= SABQI_MAX
   on lapse (Again): S shrinks -> card naturally falls back a phase (relearning),
                     re-entering active revision exactly like a forgotten manzil page.
```
Why unified wins: the traditional tracks are empirical approximations of one forgetting process at different stability ranges. Modeling them as one DSR card removes hand-off ambiguity (when EXACTLY does a page leave sabqi?) — the answer is a continuous S value, not a hand-maintained calendar. Huffaz still SEE three labeled buckets in the UI (familiar mental model), but the engine has one source of truth.

### Card Granularity + Strength Roll-up/Down

**Scheduled card = the mushaf PAGE (604 cards).** Rationale:
- Huffaz recite in bulk flow (a page/hizb/juz in one breath-chain), not card-by-card. Scheduling at ayah granularity (the Anki/word-deck mistake) breaks the serial-recall nature of hifz and explodes the queue (6236 cards) into an infeasible load.
- The page (Madani 15-line, QPC font, one glyph-page) is the natural recitation and visual unit and maps 1:1 to the data layer.

**But strength is tracked at finer resolution as a derived overlay** to get the best of both:
- **Roll DOWN (diagnosis):** a page review's error_vector localizes errors to specific lines/ayat. Only those lines get their error EWMA bumped and weak_flag set. A page that lapses because of ONE shaky line doesn't pretend all 15 lines are weak.
- **Roll UP (scheduling):** page-level D/S is the scheduled state. The line overlay feeds back into the page by (a) raising page Difficulty proportional to how many/which lines are weak, and (b) enabling **targeted sub-page drills** — when a page is due AND has weak lines, the session surfaces those lines first.

**Optional sub-page sabaq for beginners/late-starters:** during initial memorization a page may be temporarily split into line-blocks (3–5 lines) as transient learning cards that merge into one page card once the whole page reaches Good. This is a learning-phase convenience, not a permanent second granularity.

**Hierarchy aggregation for UI/analytics** (not scheduling): juz/hizb/rubʿ "health %" = aggregate of contained pages' R_now, so the user sees "Juz 12 is 82% — your weakest" (surfacing weak ajzaa', the key competitive gap). Aggregation is read-only; the page remains the only thing the scheduler mutates.

### Handling Mutashabihat (Interference)

Interference — not decay — is the dominant hifz failure mode, so it gets a first-class subsystem.

**Detection (two sources):**
1. **Curated seed:** import a mutashabihat dataset (300+ documented confusable passage groups) into MutashabihGroup with ayah-level membership and type (identical / near-identical / structural-parallel). This gives every user instant coverage on day one.
2. **User-discovered (the valuable signal):** every ReviewLog error_vector entry of type `swapped`/`confused_with` creates or strengthens a ConfusionEdge between the recited-wrong ayah and the correct one. The graph thus personalizes — it learns THIS hafiz's specific confusions (often different from the textbook list).

**Scheduling response — co-schedule + discriminate:**
- When any page in a ConfusionGroup becomes due, the queue assembler pulls ALL linked pages into the SAME session (even if not individually due) and presents them back-to-back as a **discrimination drill**: recite passage A, then the confusable B, with the diverging words highlighted. Massed contrast is the established cure for interference; spacing them apart (what vanilla SR does) actually worsens confusion.
- After the drill, edges decay slowly with successful discrimination (weight *= γ) and spike on each fresh confusion.

**Model response — interference penalty in DSR update:**
- A lapse caused by confusion applies: D += δ·edge_weight_norm, and the stability gain is damped (don't reward "I recalled SOMETHING"). This keeps confusable pages in tighter rotation than pure decay would until the discrimination is reliable.
- Confusion errors are logged separately from decay errors so analytics can show "you keep swapping 2:25 ↔ 2:82-parallel" — directly actionable, a feature no competitor offers well.

### Retention Target — Near-100% vs SR's Tunable R

SR's "tunable retention" is a feature here, not a conflict — the trick is **R is per-phase, and the long-term phase is driven to the expensive end of the cost curve, but only there.**

- Vanilla SR defaults to R=0.90 (one in ten reviews is a fail-and-relearn). For sacred text that's unacceptable for *maintained* material but fine for *brand-new* material being built.
- **Per-phase target_R:** sabaq 0.90 (cheap, lots of re-exposure while building), sabqi 0.94, **manzil 0.97–0.99**. Intervals shorten as R_target rises (I = (S/FACTOR)(R^(1/DECAY)−1)), so a hafiz's maintained pages are reviewed often enough that *predicted* recall before review rarely drops below ~97%.
- **Why not just set global R=0.99?** Cost. The review-count cost of retention rises sharply (near-vertical) above ~0.97; forcing 0.99 on all 604 pages from day one is infeasible within any time budget. Reserving high R for the long-term phase (where S is large, so even high R yields multi-week intervals) makes near-100% retention **bounded and affordable**.
- **Hard safety floors independent of the curve:**
  - Manzil interval ceiling from the user's manzil_cycle preset (a page can't go longer than the chosen cycle no matter what the math says).
  - Any page that lapses twice in a window gets a difficulty floor and a forced short-interval relearning ladder.
  - error_vector with a `tajweed` or `missed-ayah` (not mere hesitation) forces grade ≤ Hard regardless of self-rating — a dropped/altered word in sacred text is never "Good."
- **Effective retention target is a user-visible promise** ("maintain ~98% recall") tied to budget: if the budget can't sustain the chosen R, the balancer tells the user honestly (raise budget or lower scope) rather than silently letting pages rot — the "degrade gracefully / nothing silently decays" requirement.

### Daily Load Balancing Within Time Budget

Goal: fit {manzil due, sabqi due, sabaq/new} into daily_budget_minutes, never silently dropping retention.

**Cost model:** est_minutes(page) = base_recite_time(page_lines) · phase_factor · weakness_factor (weak/lapsing pages take longer). Calibrated from the user's actual session timings over time.

**Solver (greedy with hard constraints), run at session start:**
```
budget = daily_budget_minutes
# 1. Un-deferrable first: manzil due items are MANDATORY (encode "never drop dhor")
schedule(manzil_due); budget -= cost(manzil_due)       # may overflow -> warn, don't drop
# 2. Sabqi due, ordered by URGENCY = (R_now below target_R) descending
for card in sort(sabqi_due, by= target_R - R_now, desc):
     if cost(card) <= budget: schedule(card); budget -= cost(card)
     else: DEFER (card.due += smallest safe slip s.t. R_now stays >= hard_floor)
# 3. New sabaq: only if budget remains AND yesterday's sabaq is consolidated
take min(new_cap, budget // new_page_cost) new pages
# 4. Mutashabihat drills are attached to their trigger card's cost (already counted)
```

**Key behaviors:**
- **Safe deferral, not dropping:** a low-urgency sabqi page can slip a day; the balancer only defers while predicted R stays above a hard floor (e.g. 0.85). A page whose R would cross the floor is promoted to mandatory — it cannot be deferred again. This is the "degrade gracefully" requirement made concrete.
- **Missed-day catch-up:** after a gap, due items pile up. The balancer spreads the backlog over N days (smoothing) rather than dumping it all at once, prioritizing by lowest R_now and manzil-first. This directly fixes the "overwhelming pile" complaint that kills competitor apps.
- **Budget feasibility check (nightly):** simulate the next 30 days' due load (FSRS load simulation); if sustained load > budget, surface "your current scope needs ~X min/day; you've set Y" and offer to (a) raise budget, (b) lower a phase's target_R within floors, or (c) freeze new sabaq until maintenance fits. The traditional 5:1 review-to-new ratio falls out of this naturally.

### Grading Approach — Self vs Teacher vs AI (one normalized signal)

All three sources normalize to the SAME internal signal: **(grade ∈ {Again,Hard,Good,Easy}, error_vector, source, source_confidence)**. The difference is only the **confidence weight**, which scales how far the DSR update is allowed to move state.

**Self-rating (source_confidence ~0.5):**
- User taps Again/Hard/Good/Easy after reciting a page from memory (optionally hides the mushaf).
- Noisy (people over-rate). So: self-rated Good moves S less aggressively (damped gain), and self-rating can never push a page to the highest manzil R tier alone — it needs corroboration from teacher/AI at least once.

**Teacher rating (source_confidence ~1.0):**
- Talaqqi flow: teacher hears recitation, taps errors per line (the error_vector) and a grade. This is ground truth (the ijazah tradition).
- Full-weight DSR update; can unlock the top retention tier; teacher-flagged errors set authoritative weak_flags and seed mutashabihat edges.

**AI audio listening (source_confidence ~0.75–0.9, model-reported):**
- Tarteel-style ASR/mistake-detection listens to live recitation, returns per-word missed/added/swapped/hesitation → builds error_vector AUTOMATICALLY and derives grade from error density and position (early-line errors and missed-ayah are weighted heavier than a single hesitation).
- Confidence is the model's own per-segment certainty; low-confidence segments fall back to asking the user to self-confirm rather than corrupting state.
- This is the defensible wedge: objective, position-localized error vectors at scale without a teacher present.

**How each feeds the model (unified):**
```
update_dsr(card, grade, error_vector, source_confidence):
    raw_S_gain = fsrs_stability_gain(card.D, card.S, R_pred, grade)
    card.S += raw_S_gain * source_confidence      # noisy self-rating moves less
    apply error_vector -> line overlay + mutashabihat edges (full effect regardless of source)
    if source==ai or teacher: record objective error positions (trustworthy weak-flags)
```
error_vector application (localization, interference) is full-strength from any source — even a self-reported "I swapped these two ayat" is valuable graph data. Only the *magnitude of the S/D move* is confidence-scaled.

### Cold Start — ~15 juz already memorized at UNKNOWN strength

The honest position: we do NOT know per-page strength, so we **seed priors and converge fast** rather than fake precision.

**Step 1 — Scope declaration (seconds):** user marks which pages/juz they currently hold (enabled=true). The other ~15 juz stay enabled=false (future sabaq). A "~15 juz, mostly the last 15" selection enables ~300 pages.

**Step 2 — Coarse self-assessment per juz (~1 min/juz):** for each enabled juz the user picks a strength bucket: Solid / Shaky / Rusty. This sets per-card PRIORS, not truths:
```
Solid  -> D=4, S=45d  (manzil-ish), target_R via manzil
Shaky  -> D=6, S=12d  (sabqi)
Rusty  -> D=7, S=4d   (back to heavy revision)
```
Priors are deliberately CONSERVATIVE (under-estimate strength) so the first real recitation can only pleasantly surprise upward — better to over-review early than to skip a page the user has actually lost.

**Step 3 — Placement reviews (calibration, first 1–3 weeks):** the engine front-loads a calibration pass: every enabled page gets reviewed once within the first ~2 weeks (balanced against budget), ideally via AI-audio or teacher (objective) so the first real grade replaces the prior with a measured D/S. Until a page has ≥1 real review, its `R_predicted` carries a wider uncertainty and the balancer treats it as higher-priority (review the unknown before trusting it).

**Step 4 — Convergence:** with FSRS population weights + real grades, per-card D/S converge within a handful of reviews; per-user FSRS weights re-fit once ≥~100 reviews accumulate. After ~2–3 weeks the cold-start priors are fully washed out by data.

**Recency/age prior refinement:** if the user supplies *when* they memorized each juz (optional), apply the FSRS forgetting curve from that date to set a more informed initial R (recently-memorized last-juz pages start stronger than a juz finished years ago). This turns "unknown strength" into a defensible estimate that real reviews then correct.

### Design Philosophy

1. **One model, many faces.** The traditional sabaq/sabqi/manzil tracks, the 7-manzil cycle, and the 5:1 review ratio are all empirical approximations of a single forgetting process at different stability ranges. Model the process ONCE (FSRS DSR per page); let the familiar tracks be UI labels and the cycles be emergent — with hard floors so the math never drifts looser than the user's spiritual comfort.
2. **Interference is the enemy, not decay.** Standard SR assumes independent items decaying. Hifz fails primarily through mutashabihat confusion. So interference is a first-class subsystem (graph + co-scheduled discrimination drills + DSR penalty), not an afterthought.
3. **Page schedules, line diagnoses.** Schedule at the unit people actually recite (the page) to keep load feasible and recall serial; track strength finer (line/ayah) only to localize weakness and seed confusion edges. Never let granularity explode the queue.
4. **Near-100% is bounded, not infinite.** Achieve sacred-text retention by reserving high desired-R for the long-term phase (where large S makes it affordable) plus hard safety floors — never by globally cranking R to 0.99 (infeasible).
5. **Trust scales the update, evidence is always kept.** Self/teacher/AI grades all produce the same (grade, error_vector); confidence scales how much state MOVES, but error localization and confusion-graph learning are kept full-strength from every source.
6. **Degrade gracefully, never silently.** Load balancing defers by retrievability with hard floors, smooths missed-day backlogs, and tells the user honestly when budget can't sustain their scope — the explicit competitive gap (nothing silently rots; the pile never overwhelms).
7. **Honest cold start.** For partial huffaz, seed conservative priors + recency, then converge on real (preferably objective) grades within weeks — estimate, don't pretend.

### Pseudocode

```python
# ============ CONSTANTS (FSRS-6) ============
DECAY = -0.5
FACTOR = 0.9 ** (1/DECAY) - 1            # = 19/81 ≈ 0.2346
SABAQ_MAX_S, SABQI_MAX_S = 9.0, 60.0     # day thresholds for phase
TARGET_R = {"NEW":0.90,"SABAQ":0.90,"SABQI":0.94,"MANZIL":0.97}
HARD_FLOOR_R = 0.85
CONF = {"self":0.5, "ai_audio":0.85, "teacher":1.0}

def retrievability(t_days, S):      return (1 + FACTOR*t_days/S) ** DECAY
def interval(S, R_target):          return (S/FACTOR) * (R_target**(1/DECAY) - 1)

def phase_of(card):
    if card.state == "unseen":            return "NEW"
    if card.S <  SABAQ_MAX_S:             return "SABAQ"
    if card.S <  SABQI_MAX_S:             return "SABQI"
    return "MANZIL"

# ============ GRADE INGESTION (unified for self/teacher/ai) ============
def review(card, grade, error_vector, source, now):
    conf  = CONF[source]
    t     = (now - card.last_review).days if card.last_review else 0
    R_pred = retrievability(t, card.S) if t else 1.0

    # sacred-text guard: a dropped/altered word or tajweed slip is never "Good"
    if any(e.type in ("missed","added","swapped","tajweed") for e in error_vector):
        grade = min(grade, HARD)

    # --- FSRS D/S update, scaled by source confidence ---
    D_new = fsrs_update_difficulty(card.D, grade)              # mean-reverting drift
    if grade == AGAIN:
        S_new = fsrs_post_lapse_stability(card.D, card.S, R_pred)
        card.lapses += 1
    else:
        gain  = fsrs_stability_gain(card.D, card.S, R_pred, grade)
        S_new = card.S + gain * conf                           # noisy self-rating moves less

    # --- interference penalty: confusion ≠ decay ---
    conf_edges = [e for e in error_vector if e.type=="swapped" and e.confused_with]
    if conf_edges:
        w = max(edge_weight_norm(card.user, e) for e in conf_edges)
        S_new *= (1 - LAMBDA*w)                                # damp reward for confused recall
        D_new  = min(10, D_new + DELTA*w)
        for e in conf_edges: bump_confusion_edge(card.user, e)

    card.D, card.S, card.last_review = D_new, S_new, now
    card.reps += 1
    card.phase = phase_of(card)

    # --- roll DOWN: localize to lines; roll UP into page difficulty ---
    apply_error_overlay(card.page_id, error_vector)            # only erring lines flagged
    card.D = min(10, card.D + WEAK_LINE_FACTOR * n_weak_lines(card.page_id))

    # --- next due, with manzil cycle ceiling (spiritual comfort floor) ---
    I = interval(card.S, TARGET_R[card.phase])
    if card.phase == "MANZIL":
        I = min(I, manzil_cycle_ceiling_days(card.user))
    card.due = now + days(I)
    log_review(card, grade, error_vector, source, conf, R_pred)

# ============ DAILY QUEUE + LOAD BALANCE ============
def build_session(user, now):
    due = [c for c in user.cards if c.enabled and c.due <= now]
    due = recompute_R(due, now)
    manzil = [c for c in due if c.phase=="MANZIL"]
    sabqi  = [c for c in due if c.phase=="SABQI"]
    budget = user.daily_budget_minutes
    session = []

    # 1. manzil = mandatory (never drop dhor) — schedule even if it overflows
    for c in sort_oldest(manzil):
        session.append(c); budget -= cost(c)
    if budget < 0: warn_budget_overflow(user)

    # 2. sabqi by urgency; defer low-urgency only while above hard floor
    for c in sort(sabqi, key=lambda c: TARGET_R[c.phase]-c.R_now, reverse=True):
        if cost(c) <= budget:
            session.append(c); budget -= cost(c)
        else:
            if c.R_now > HARD_FLOOR_R: defer_safely(c, now)     # slip a day
            else: session.append(c); budget -= cost(c)          # promote: cannot defer

    # 3. new sabaq only if room and yesterday consolidated
    if budget > 0 and yesterdays_sabaq_ok(user):
        for p in next_unseen_pages(user, k = min(user.new_cap, budget//NEW_COST)):
            session.append(start_card(p))

    # 4. mutashabihat: pull linked pages of any session card into the SAME session
    for c in list(session):
        for linked in confusion_group_pages(user, c.page_id):
            if linked not in session: session.append(as_discrimination_drill(c, linked))

    # 5. recitation order: dhor(manzil) -> sabqi -> sabaq/new
    return order_for_recitation(session)

# ============ COLD START (≈15 juz, unknown strength) ============
PRIOR = {"Solid":(4,45.0), "Shaky":(6,12.0), "Rusty":(7,4.0)}   # conservative
def cold_start(user, owned_pages, juz_strength, juz_memorized_date=None):
    for p in user.all_pages:
        c = user.card(p); c.enabled = p in owned_pages
        if not c.enabled: continue
        D, S = PRIOR[juz_strength[juz_of(p)]]
        if juz_memorized_date:                                  # optional recency prior
            age = (today - juz_memorized_date[juz_of(p)]).days
            S = max(S, S);  c.R_now = retrievability(age, S)     # informed initial R
        c.D, c.S, c.state = D, S, "review"
        c.due = today                                            # calibration pass front-loads all
    schedule_calibration_pass(user, horizon_days=14, prefer_source="ai_audio")
    # priors wash out after ~2–3 weeks of real grades; refit FSRS weights once ≥100 reviews
```

### Open Questions
1. Mutashabihat co-scheduling tension: massing confusable passages together aids discrimination but VIOLATES spacing for the individual page's own decay schedule. Needs empirical tuning of how often to mass vs. space, and whether masood drills should themselves be FSRS-scheduled as a separate "discrimination card" type.
2. FSRS weight re-fitting needs ~hundreds of reviews per user; for a hafiz reviewing whole pages, reps accumulate slowly per card. May need to fit weights at the user level across all cards (pooled) and/or warm-start from a hifz-specific population prior rather than generic Anki defaults — requires a training dataset we don't yet have.
3. The exact stability functions fsrs_stability_gain / fsrs_post_lapse_stability are stated abstractly here; the precise FSRS-6 w0..w20 formulas and how the source_confidence scaling interacts with FSRS's own fitted parameters must be pinned down (scaling raw gain by confidence is a heuristic that isn't part of standard FSRS and should be validated so it doesn't bias the curve).
4. Grade derivation from AI error_vector (mapping word-level missed/added/swapped/hesitation density+position to Again/Hard/Good/Easy) is a heuristic; the thresholds need calibration against teacher ground truth, and ASR confidence must be reliable enough that low-confidence fallback-to-self doesn't dominate.
5. Manzil interval CEILING (cycle preset) vs FSRS optimal interval can conflict: forcing shorter-than-optimal review wastes budget; needs a policy for when user comfort overrides math and whether to surface that trade-off explicitly.
6. Sub-page (line-block) sabaq merging into a single page card: the exact rule for when transient line cards collapse into one page card, and how their accumulated D/S combine, is unspecified and affects early-learning UX.
7. Budget overflow on mandatory manzil load: when even un-deferrable manzil exceeds the time budget, the policy (compress quality? overflow to tomorrow? force scope reduction?) is a product/spiritual decision, not purely algorithmic.
8. Defining the "enabled scope" and partial-page ownership: users who know half a juz, or page boundaries that split a surah mid-thought, need a sub-page enable granularity the current page-level enabled flag doesn't capture.

---

## 8. SR Engine Design B — Methodology-first
*(from `designs.srB`)*

### Overview

**METHODOLOGY-FIRST Hifz SR engine.** The product contract the user sees is the traditional one: three named tracks (sabaq = new lesson, sabqi = recent revision, manzil = far revision), juz/page quotas, the 7-manzil weekly khatm, old-before-new recitation order, and teacher sign-off (talaqqi). FSRS-style DSR math (Difficulty / Stability / Retrievability with a power-law forgetting curve) runs UNDERNEATH as a silent advisor. It never overrides the tradition; it only does three things the paper-tracker cannot: (1) **ORDER** pages within each track so the weakest/most-due surface first, (2) **FLAG** decaying pages before they are forgotten, (3) **LOAD-BALANCE** the daily pile so a full-Quran review stays feasible. The algorithm is demoted from "scheduler" to "the smart part of the page selector inside a fixed-shape day." This buys trust with traditional users and ulama because the day still looks like sabaq/sabqi/manzil quotas signed off by a teacher, while quietly hitting the near-100% retention that sacred text demands. Primary wedge: the completed/near-complete hafiz fighting manzil decay (highest pain, clearest payment trigger), with the same engine extending down to active memorizers and (later) teachers.

### Design Philosophy

Trust over algorithmic purity. Five deliberate commitments.

1. The **TRADITION IS THE UI**, the algorithm is the engine — users pick a named cycle (e.g. "1 juz/day manzil", "7-manzil weekly", "Deobandi 3-track"), not a retention slider.
2. The algorithm only **REORDERS and FLAGS** inside a track and quota the user/teacher already accepts; it is forbidden from skipping a track, shrinking the Quran's coverage, or telling a hafiz a page is "safe to drop" — manzil is un-skippable by design because dropping manzil is the documented #1 cause of loss.
3. **NOTHING decays silently and NOTHING is hidden:** the engine can pull a weak page forward but the full Quran is always on a guaranteed maximum-interval ceiling, so the system can never quietly let a juz rot the way a pure cost-optimized FSRS queue would.
4. Teacher/talaqqi sign-off is a **first-class grading input and can always override the machine** — the sanad/oral-correction chain is sacred and the app is a servant to it, not a replacement.
5. Framing is **loss-prevention and peace of mind** ("here is exactly what to revise today so nothing slips"), never gamified spirituality or transactional worship.

Where SR theory and tradition disagree, tradition wins on the surface and SR wins only in the invisible ordering.

### The Three Tracks

Tracks are MODELED AS THREE QUEUES but they are not three separate algorithms — they are three lifecycle STAGES of the same page card, distinguished by stability/age, each with its own daily quota and recitation slot.

- **SABAQ (new lesson):** pages with no stability yet or stability below ~3 days; quota 3–5 lines/day (configurable, region presets); these are being built, graded hardest, repeated within-day.
- **SABQI (recent/near revision):** pages graduated from sabaq, roughly the last 1–3 juz, stability ~3–30 days; quota is a rolling window (e.g. last 7 days of sabaq re-recited, then last 1–3 juz); this is the consolidation belt.
- **MANZIL (far revision / dhor):** everything older/more stable, the maintenance bulk that IS the whole-Quran problem; driven by the chosen cycle (7-manzil weekly khatm, or 30/15/10-day juz cycles, or 1-juz/day floor).

Recitation ORDER is enforced old-before-new exactly as taught: manzil (dhor) first, then sabqi, then sabaq last, because that is how the day is recited aloud to the teacher. A page GRADUATES sabaq→sabqi when it has been signed off N times and stability crosses the sabqi threshold; sabqi→manzil when stability exceeds the manzil floor (it has been reliably held for weeks) AND it falls outside the recent-juz window. Graduation is age-and-rating driven (matching the research), not a hidden FSRS jump, so a teacher can predict it.

### Data Model

Tables (SQLite/local-first, syncable):

**PAGE** (static, from QUL mushaf layout): `page_id (1-604), juz, hizb, rub, surah_range, line_count`. The mushaf structure is fixed glyph data, never computed.

**CARD** (one per scheduling unit). DEFAULT granularity = PAGE (604 cards) — matches how huffaz recite (whole page in one flow) and how teachers think. Fields:
```
card_id, page_id, owner_id
track ENUM(unmemorized, sabaq, sabqi, manzil)
D REAL (difficulty 1..10), S REAL (stability, days), last_review_at, last_R_at_review
sabaq_signoffs INT (talaqqi count toward graduation)
due_at (next-due ceiling, the GUARANTEED max interval — always set, never null for memorized cards)
weak_flag BOOL, lapse_count INT
mutashabihat_group_id NULLABLE
manual_lock BOOL (teacher pinned this page into a track; algorithm may not graduate it out)
```

**LINE_BLOCK** (optional finer grain, lazily created ONLY for a page that lapses): `block_id, card_id, line_start, line_end, local_error_count`. Sub-page cards exist only where a page repeatedly breaks, so we don't carry 9000 cards for the 95% of pages that are fine.

**REVIEW_LOG** (append-only, the audit trail teachers/ulama trust): `log_id, card_id, reviewed_at, track_at_review, grade ENUM(again, hard, good, easy) OR fluency 0..4, error_positions JSON (line/word indices of stumbles from recitation or AI listen), elapsed, teacher_signoff BOOL, teacher_id NULLABLE, source ENUM(self, ai_listen, teacher)`.

**MUTASHABIHAT_LINK** (curated + user-added): `group_id, page_ids[], verse_anchors, note`. Seeded from the ~300+ known near-identical passages.

**CYCLE_CONFIG** (per user, the named tradition they chose): `cycle_type, sabaq_lines_per_day, sabqi_window_juz, manzil_target_juz_per_day, manzil_full_cycle_days (e.g. 7/14/30), region_preset, term_labels (so "sabaq/sabqi/manzil" can be relabeled dhor/murajaah/etc per region), daily_review_cap`.

**STRENGTH ROLL-UP** is computed, not stored as a separate authority: page strength % = R(now) from its card; line-block strength only exists for lapsed pages; juz/hizb strength = coverage-weighted **MIN-leaning** aggregate of its pages' R (min-leaning, not mean, because one weak page in a juz is what fails you in prayer — we surface the weakest link, matching how a hafiz experiences a stumble).

### Granularity

PAGE is the default and visible unit — one Madani page (15 lines) is the natural recitation flow, the teacher's unit, and keeps the card count at a comprehensible 604. We deliberately REJECT word/ayah cards for normal flow (Tarteel-style word cards model recognition, not the serial production hifz actually needs). Sub-page LINE-BLOCK cards are created lazily ONLY when a page lapses repeatedly (error_positions cluster on the same lines across reviews); then that page splits into 1–3 line-blocks so revision can target the broken half-page instead of forcing a re-grind of the whole page. This keeps granularity coarse and trustworthy by default while still letting the engine zoom in on the genuinely hard spots a hafiz would themselves isolate. Juz and hizb are VIEWS (roll-ups), never scheduling units — but the user's QUOTAS are expressed in juz/pages/lines because that is the vocabulary of the tradition.

### Handling Mutashabihat (Interference)

Interference (not decay) is the dominant failure mode in hifz, so it gets an explicit mechanism rather than relying on R. MUTASHABIHAT_LINK groups (seeded from the curated ~300+ near-identical passage list, extensible by user/teacher) connect confusable pages. Three behaviors:

1. **DISCRIMINATION INTERLEAVING** — when one member of a group is scheduled, its siblings are pulled into the same session back-to-back so the brain practices telling them apart, not each in isolation.
2. **CONFUSION-AWARE GRADING** — error_positions let us detect a "wrong-branch" lapse (the hafiz slid from page A's wording into page B's); that specific lapse bumps D on ALL group members and raises their review frequency, because the problem is the pair, not the page.
3. **ANCHOR HINTING** — the app can show the distinguishing word/phrase between siblings as a targeted micro-drill.

This is the piece pure FSRS omits and the piece that most differentiates serious hifz tooling.

### Grading Approach

Grading is GRADED FLUENCY with error LOCATION, mapped to the traditional teacher verdict, with three input sources that all write the same REVIEW_LOG. Inputs:

1. **TEACHER sign-off (talaqqi)** — the gold standard; teacher marks pass/minor-stumbles/fail, optionally taps stumble lines; teacher_signoff=true.
2. **AI listen (Tarteel-style)** — produces error_positions automatically; treated as advisory, never as authority over a teacher.
3. **Self-grade** — the hafiz taps a 4-level button after reciting from memory.

All three collapse to a fluency 0..4 → {again, hard, good, easy}:
```
again/0  = could not recall / prompted / major break  -> LAPSE
hard/2   = recalled with stumbles (>0 error_positions but completed)
good/3   = fluent, ledger-clean
easy/4   = effortless, fast, zero hesitation
```
Crucially we keep error_positions because WHERE you stumbled drives mutashabihat detection and line-block splitting — a binary again/good throws away the most valuable signal in hifz. The visible verbs stay traditional ("recited clean / minor mistakes / needed help"), and a teacher's verdict always supersedes self and AI for that log row.

### Scheduling Logic

Two layers. LAYER 1 (visible, traditional) builds the DAY as fixed-shape quotas from CYCLE_CONFIG: today = [manzil quota] + [sabqi window] + [sabaq lines], recited old-before-new. The shape and size of the day come from the chosen named cycle, NOT from the algorithm — so the day always looks like the tradition. LAYER 2 (invisible, DSR) decides, WITHIN each track's quota, WHICH pages fill it and in what order:

- Compute `R(t) = (1 + (19/81)*t/S)^(-0.5)` for every memorized card (power-law forgetting curve, FSRS backbone).
- **MANZIL selection:** from all manzil pages, the cycle guarantees full coverage over manzil_full_cycle_days (the un-skippable ceiling). The algorithm's freedom is ONLY to (a) order today's slice weakest-R-first, and (b) PULL FORWARD any page whose R has dropped below the high retention floor (0.90 for ordinary pages, higher near prayer-critical/oft-recited surahs) even if the cycle hadn't reached it yet. It can never PUSH a page past its guaranteed ceiling.
- **SABQI window** is the literal last-1-3-juz rolling window (tradition) but ordered weakest-first inside it.
- **SABAQ** is just today's new lines plus yesterday's, repeated to sign-off.
- On every review, update S and D via FSRS-style update (success grows S as a function of D,S,R; lapse shrinks S and bumps D and weak_flag), then set due_at = S * ln(retention_floor)/ln(0.9)-style interval BUT clamp due_at to the cycle ceiling so the page is never scheduled later than the tradition allows. **The clamp is the whole trust trick: SR may make a page MORE frequent, never LESS frequent than the 7-manzil / 1-juz-day promise.**
- **MUTASHABIHAT:** if today pulls a page that belongs to a mutashabihat group, interleave its sibling(s) into the same session for discrimination, and on a confusion-type lapse bump D on all involved pages.

### Load Balancing

The daily_review_cap is the user's stated comfortable load (e.g. "I can do ~1.5 juz/day"). Three mechanisms keep the pile feasible without ever hiding the Quran.

1. The **cycle ceiling** already bounds worst-case daily manzil to (total_pages / manzil_full_cycle_days) — the tradition is self-balancing by construction; we just honor it.
2. When SR pull-forwards + the cycle slice exceed the cap on a given day, we **SMOOTH:** pages whose R is still above floor get nudged +/-1-2 days within their ceiling window to flatten peaks (FSRS load-simulation, but constrained so nothing crosses its ceiling).
3. **MISSED-DAY GRACE:** if the user skips days (life happens, the #1 reason people quit), we do NOT dump the whole backlog as "overdue red." Instead we re-flow: most-decayed-first up to the cap per day, transparently telling them "you missed 3 days; here's a 5-day catch-up plan that still finishes the cycle," prioritizing prayer-critical and weakest pages.

Graceful degradation is a headline feature, not an edge case — the competitor apps fail exactly here.

### Retention Target

Near-100%, implemented as a high but FINITE retention floor, NOT a 90% Anki-style target. Default floor R=0.90 for ordinary manzil pages, escalating: **0.95 for prayer-critical/frequently-recited surahs (Fatiha, last juz, Mulk, Kahf, Yaseen)** and for any page with lapse_count>0 or weak_flag. We do NOT chase a literal 0.99 globally because the cost curve explodes and would blow past the user's daily cap, breaking trust faster than an occasional stumble does — instead the **CYCLE CEILING provides the real near-100% guarantee** (every page is forcibly re-recited at least every manzil_full_cycle_days regardless of its computed R), and the retention floor only PULLS pages FORWARD from there. So retention = **max(cycle guarantee, SR floor)**. This is the deliberate methodology-first compromise: the tradition's fixed rotation is what actually delivers near-100% coverage; SR just sharpens which pages within that rotation get extra attention. Sacred text is protected by the un-skippable ceiling, not by a fragile probability target.

### Cold Start

A partial hafiz (e.g. "I have 12 juz, strong on first 5, shaky on the rest, finished 3 years ago") cannot be cold-started by FSRS (no review history). Onboarding builds priors WITHOUT a long calibration grind:

1. **COVERAGE CAPTURE** — user marks which juz/surahs are memorized (fast, juz-level taps), seeding which of the 604 cards exist at all.
2. **SELF-RATED CONFIDENCE per juz** (strong / okay / shaky) → seeds initial S and D per page: strong juz get high S (long initial interval, low frequency) and low D; shaky get low S (enter near sabqi/sabaq-like frequency) and high D.
3. **OPTIONAL CALIBRATION RECITATION** — recite one page per juz (teacher- or AI-graded); the grade corrects the self-rating prior for that whole juz, cheaply.
4. **STALE-TIME DECAY** — apply the forgetting curve for the gap since last active so a 3-years-neglected "strong" juz is treated as needing reactivation, matching the lived "I forgot a lot" reality.
5. **FIRST 2–3 WEEKS** run a gentle ramp: the engine watches actual grades and rapidly corrects the seeded D/S (priors are weak, observations dominate), so by ~3 cycles the schedule is real, not guessed.

Partial huffaz are explicitly first-class — they map onto the same three tracks: shaky juz start in sabqi/sabaq, strong juz start in manzil.

### Pseudocode

```
// ===== DAILY BUILD (visible = tradition, ordering = SR) =====
function buildToday(user, today):
  cfg = user.cycle_config
  cards = loadMemorizedCards(user)
  for c in cards: c.R = retrievability(c, today)   // (1 + (19/81)*age/S)^-0.5

  // ---- MANZIL: cycle guarantees coverage; SR only orders + pulls forward ----
  manzilPool   = cards.filter(track==MANZIL)
  cycleSlice   = cycleSliceForToday(manzilPool, cfg)        // tradition: e.g. 1 juz today
  pullForward  = manzilPool.filter(c -> c.R < floor(c) AND not in cycleSlice)
  manzilToday  = (cycleSlice ++ pullForward)
  manzilToday  = expandMutashabihat(manzilToday)            // interleave siblings
  manzilToday.sortBy(c -> c.R)                              // weakest first

  // ---- SABQI: literal recent-juz window, ordered weakest-first ----
  sabqiToday = cards.filter(track==SABQI AND inWindow(c, cfg.sabqi_window_juz))
  sabqiToday.sortBy(c -> c.R)

  // ---- SABAQ: today's + yesterday's new lines, to sign-off ----
  sabaqToday = sabaqLines(user, cfg.sabaq_lines_per_day)

  day = manzilToday ++ sabqiToday ++ sabaqToday             // old-before-new order
  day = loadBalance(day, cfg.daily_review_cap)              // smooth peaks within ceilings
  return day

function floor(c):
  if c.prayer_critical OR c.weak_flag OR c.lapse_count>0: return 0.95
  return 0.90

// ===== REVIEW (grade -> update D/S, CLAMP to cycle ceiling) =====
function onReview(c, grade, error_positions, source, teacher_signoff, today):
  log(c, grade, error_positions, source, teacher_signoff, today)   // audit trail
  R = c.R
  if grade == AGAIN:                          // lapse
     c.lapse_count += 1
     c.D = clamp(c.D + 1.0, 1, 10)
     c.S = max(MIN_S, c.S * lapseMult(R))      // stability shrinks
     c.weak_flag = true
     maybeSplitIntoLineBlocks(c, error_positions)
  else:
     c.D = clamp(c.D - driftToEase(grade), 1, 10)
     c.S = c.S * stabilityGrowth(c.D, c.S, R, grade)   // FSRS-style growth
     if grade in {GOOD, EASY} and c.error_positions_empty: c.weak_flag = false

  if isMutashabihatConfusion(error_positions, c):        // slid into a sibling
     for sib in group(c): sib.D = clamp(sib.D + 0.5,1,10); raiseFreq(sib)

  // graduation by AGE + RATING (predictable for teacher), not hidden FSRS jump
  if c.track==SABAQ and teacher_signoff: c.sabaq_signoffs += 1
  if c.track==SABAQ and c.sabaq_signoffs>=cfg.signoffs_to_graduate and c.S>=SABQI_S:
     c.track = SABQI
  if c.track==SABQI and c.S>=MANZIL_S and outsideRecentWindow(c):
     c.track = MANZIL

  ideal_due = today + intervalFor(c.S, floor(c))          // SR's wish
  ceiling   = today + cycleCeilingDays(c, cfg)            // tradition's promise
  c.due_at  = min(ideal_due, ceiling)   // *** TRUST CLAMP: SR may only make it MORE frequent ***
  if c.manual_lock: c.track = c.track   // teacher pin overrides auto-graduation

// ===== COLD START (partial hafiz) =====
function seedCard(page, memorized, confidence, last_active, today):
  if not memorized: return Card(track=UNMEMORIZED)
  baseS = {strong:60, okay:14, shaky:4}[confidence]
  baseD = {strong:3,  okay:5,  shaky:7}[confidence]
  S = baseS * forgettingDecay(today - last_active)   // stale time eats strength
  track = (S>=MANZIL_S)? MANZIL : (S>=SABQI_S)? SABQI : SABAQ
  return Card(S=S, D=baseD, track=track, due_at=today)  // first cycle corrects priors
```

### Open Questions
1. Card granularity validation: is whole-PAGE the right default for every region, or do luh-based (Mauritania) and Ottoman-stacking traditions need a different base unit (e.g. hizb or thumun) out of the box? Needs field testing with each tradition before locking the default.
2. Retention floor calibration: 0.90/0.95 floors are chosen for daily-load sanity, but we lack hifz-specific forgetting-curve data — the 58/44/33/21% forgetting figures from the methodology research should be fit to actual user lapse logs to set DECAY/FACTOR honestly rather than borrowing FSRS's recognition-task constants.
3. Mutashabihat seed source and authority: which curated list of the ~300+ near-identical passages do we ship, who vouches for it (ulama review), and how do we let teachers correct/extend it without fragmenting the dataset?
4. Teacher override semantics: when teacher sign-off and AI-listen disagree (AI flags errors the teacher passed, or vice-versa), what is the canonical resolution and how is it logged so the sanad/trust chain stays intact?
5. Does pull-forward ever feel like the app "changing the rules" on a traditional user who expected a fixed rotation? May need a setting to run PURE-CYCLE mode (SR ordering only, zero pull-forward) for maximally conservative users/ulama, with SR-assist as opt-in.
6. Sub-page line-block splitting UX: huffaz may distrust the app inventing fractional-page units; needs to be framed as "focus drill on the lines you keep missing," and validated that it doesn't break the whole-page recitation flow teachers expect.
7. Sync/privacy model for the REVIEW_LOG given the Muslim Pro data scandal — local-first is assumed, but teacher/madrasah B2B features imply sharing logs; the consent and data-residency model is unresolved and is existential for trust.

---

## 9. Differentiation Thesis
*(from `designs.diff`)*

**Thesis:** Fuse AI recitation verification with a page-level spaced-repetition scheduler built for MAINTENANCE, not memorization. Serve the finished hafiz RETAINING 600+ pages, the worst-served job. Tarteel has ears but no scheduler; FSRS trackers have a scheduler but no ears.

**Sharpest wedge:** Never-Lose-It maintenance engine for FINISHED huffaz: AI grades where you stumble, scheduler caps daily load. **The empty quadrant.**

**One thing to be famous for:** *The app that makes sure a hafiz never silently loses the Quran.*

### Killer Features (with impact assessment)

| ID | Feature | Impact |
|---|---|---|
| **f1** | Recitation-graded page-level maintenance scheduler (THE wedge) | Highest. Moat strong/compound. Build high. |
| **f2** | Mutashabihat confusables trainer | High. Interference is the top failure. Moat strong. Build med-high. |
| **f3** | Manzil scheduler with presets and catch-up | High. Crushing load to finite list. Moat medium. Build medium. |
| **f4** | Audio-mushaf revision mode | High. By-ear capture surface. Moat low-med. Build medium. |
| **f5** | Whole-Quran retention heat-map | Med-high. Decay made visible. Moat low. Build low-med. |
| **f6** | Offline-first and privacy | Med-high. Privacy existential. Moat medium. Build med-high. |
| **f7** | Teacher and madrasah dashboard | Medium now, high later. Highest-LTV. Moat med-high. Build high. |
| **f8** | Tasteful streaks and khatma goals | Medium. Moat low. Build low. |
| **f9** | Family and child mode | Low-med. Moat low. Build medium. |

---

## 10. Adversarial Critique
*(from `critique`)*

Each item below is a failure mode with its **severity**, **likelihood**, and a concrete **mitigation**.

### Item 1 — Quran text accuracy (DEVICE rendering risk)
- **Severity:** critical | **Likelihood:** medium
- **Issue:** One wrong diacritic, broken ligature, or device-render glitch brands you "the app that corrupted the Quran." Research says most app errors are DEVICE rendering (OS shapers), the layer you control least. FSRS error-vectors tempt recomposing text.
- **Mitigation:** Store Tanzil Uthmani unmodified (CC BY 3.0) with a SHA-256 CI checksum that fails the build on any byte change. Render only via bundled QPC per-page glyph fonts (QCF_P001-604), never the OS shaper. Take layout from QUL MushafPage; never compute line breaks. Add a CI visual-diff vs reference mushaf images on min-supported OS versions. Overlay error positions as coordinates on the immutable glyph page; never re-typeset or store reconstructed text.

### Item 2 — No scholarly endorsement = no trust = no market
- **Severity:** critical | **Likelihood:** high
- **Issue:** The audience (huffaz, madrasahs) is maximally conservative; an algorithm telling a hafiz what to revise reads as presumption, inserting a machine into the sacred talaqqi/sanad chain.
- **Mitigation:** Make a named scholar/institution endorsement a hard pre-launch gate, not marketing polish. Position as "servant to the teacher, not a replacement"; teacher sign-off is first-class and always overrides the machine. Ship maddhab-named presets (Deobandi 3-track, Arab muraja'ah) co-signed by that tradition. Get written approval on the billing model. If no endorser will attach their name, don't launch to the traditional segment; restrict to self-directed diaspora adults.

### Item 3 — Sectarian/qira'at neutrality
- **Severity:** high | **Likelihood:** medium
- **Issue:** The default Hafs + Madani 15-line mushaf is implicitly one qira'at. Warsh (West Africa, which research targets via Mauritania/Nigeria), Qaloon, Shi'a differences, and basmala/ayah-numbering vary. Mutashabihat datasets and any bundled tafsir encode a madhhab. Silent single-viewpoint invites sectarian-bias accusations.
- **Mitigation:** State the riwayah explicitly in-app ("Hafs 'an 'Asim, Madani mushaf"), not as "the" Quran. Make mushaf/riwayah a swappable asset (QUL has 20+ layouts); roadmap Warsh before targeting West Africa. Keep the scheduler text-agnostic. Ship ZERO bundled tafsir/translation/commentary in v1. Scholar-review the mutashabihat list, scoped to objective near-identical wording, not interpretive groupings.

### Item 4 — Riba/transactional-worship billing
- **Severity:** high | **Likelihood:** medium
- **Issue:** Research flags this as the top strategic tension: users reject paywalling worship ("transactional models of spiritual engagement"); winners are donation-funded charities framing usage as sadaqah jariyah. Interest-like framing, auto-renew traps, free-trial dark patterns, or installments risk a riba/gharar accusation. Tarteel already draws loud paywall resentment.
- **Mitigation:** Halal-coded model: one-time purchase and/or transparent value-add subscription that NEVER paywalls reading/reciting the Quran itself (only scheduler/analytics/AI). Offer madrasah licensing and family plans. Scholar-review for riba/gharar and publish the approval. No interest, no installments, no auto-renew dark patterns, no engineered free-trial traps. Consider a waqf/sadaqah tier. Privacy is existential (Muslim Pro's 98M-user data scandal): offline-first, no data brokering.

### Item 5 — Gamification trivializes sacred text
- **Severity:** high | **Likelihood:** medium
- **Issue:** f8 streaks/khatma + Design A risk a Duolingo-owl effect: leaderboards over recitation, XP-for-ayat, guilt-loop streaks, confetti on a juz. Breach of adab; will be screenshotted and condemned. Worse, it weaponizes hadith-driven guilt ("lose your hifz / face Hell" streak nags = spiritual abuse).
- **Mitigation:** Per Design B: framing is loss-prevention and peace of mind, never gamified spirituality. No public leaderboards over recitation, no XP/badges on sacred content, no confetti. Replace streaks with a calm "revise this today so nothing slips" dashboard plus a non-shaming whole-Quran retention heat-map. Notifications must be neutral, never guilt/fear-based. Any streak: private, opt-in, tasteful (f8 is low-impact/low-moat, cuttable).

### Item 6 — 'Just another tracker' trap
- **Severity:** high | **Likelihood:** high
- **Issue:** Spreadsheets/Anki persist for structural reasons: free, infinitely flexible (any region's terms/cycle), offline-owned, trusted (no privacy/riba worry), zero learning curve. The market is saturated with logging tools (Hifz Tracker, Sullam, Al-Muhaffiz, Al-Rahma). Perceived as "a prettier checklist," your value justifies neither subscription, download, nor surrendering data; most personas lack switch-level pain.
- **Mitigation:** Refuse to compete as a tracker. The only defensible wedge (confirmed across research) is the finished-hafiz MAINTENANCE job (manzil/dhor retention, framed as fear-of-loss). Build what a spreadsheet fundamentally can't: a scheduler that says exactly what to revise today, caps the crushing full-Quran load, surfaces weak ajzaa', and degrades gracefully on missed days. Market "the app that makes sure a hafiz never silently loses the Quran," not "track your hifz." Target Persona 2 only at launch.

### Item 7 — Habit-app retention reality
- **Severity:** high | **Likelihood:** high
- **Issue:** Daily-habit apps lose most installs in week one. This asks DAILY effort (recite, get graded) for an INVISIBLE, delayed payoff (not-forgetting is the absence of a perceivable event). The crushing load is itself a churn engine: miss a week, open to an overwhelming due-pile, quit in shame. And the better it works, the less users feel they need it at renewal.
- **Mitigation:** Make "graceful degradation after missed days" a marketed, first-class feature — re-spread the backlog, never dump a guilt-pile. Make value VISIBLE: the heat-map turns "nothing bad happened" into a tangible "whole Quran is green" artifact worth protecting. Tie renewal to loss-aversion framing. Cap minutes/day (the budget balancer is the right idea). Assume high early churn; optimize for the high-intent cohort; consider one-time purchase so revenue isn't hostage to a daily habit you can't guarantee.

### Item 8 — SR over-engineering (Design A)
- **Severity:** high | **Likelihood:** high
- **Issue:** Per-page DSR + line error-vectors + grown mutashabihat penalty graph + confidence-weighted multi-source grading + budget solver + cold-start calibration is months of work you CANNOT validate: no labeled hifz ground truth, and you can't ethically A/B-test "let this juz decay." FSRS weights came from flashcards, not whole-page serial recall; the 0.90/0.94/0.97-0.99 phase targets are guesswork dressed as rigor. Violates simplicity-first.
- **Mitigation:** Ship Design B: tradition is the UI, FSRS is a hidden ordering/flagging advisor inside fixed quotas, never an autonomous scheduler. This confines the math to three low-risk jobs (order weakest-first, flag decay, load-balance) where being slightly wrong is safe because the traditional cycle is the net. Cut the mutashabihat-DSR penalty loop, the multi-source normalization, and calibration from v1. Start with recency+age+last-rating ordering plus a hard max-interval ceiling so nothing decays silently. Add FSRS depth only after months of real data. Don't claim a retention % you can't measure.

### Item 9 — Wrong granularity + dishonest grading
- **Severity:** high | **Likelihood:** high
- **Issue:** Page is the right scheduling unit, but sabaq is 3-5 LINES (sub-page) and manzil is recited in juz flow, so a single page-rating misfits both ends. Fatal: both designs need a grade. Self-rating is biased (guilt over-rates, perfectionism under-rates) and silently corrupts the schedule. Teacher grading doesn't scale to solo huffaz (your wedge persona often has none). AI grading is the only honest signal, the hardest to build, and Tarteel owns it.
- **Mitigation:** Match grading granularity to the recitation unit per phase: sabaq at line-block, manzil at page/juz flow with error POSITIONS, not a single self-score. Don't make honest self-rating primary: prefer an objective capture (even "reveal-on-tap, did you stumble here?") over a 1-5 score; make AI recitation verification the grade where feasible (honest signal AND moat); where only self-rating exists, keep the scheduler robust to noise via the max-interval ceiling and recency, not precise DSR fitting. Design it to degrade safely under bad grades, not assume good ones.

### Item 10 — Competitive response: Tarteel bolts on the scheduler first
- **Severity:** critical | **Likelihood:** medium
- **Issue:** Tarteel owns AI mistake detection, 15M+ users, 4.7/4.6, capital (Founders Inc.), distribution, and ships memorization planning + analytics + streaks. Your whole edge is "ears but no real SR scheduler." A page-level FSRS scheduler is a quarter's work for them; verification is years for you. Quran Companion/QuranH already have FSRS. You may be building a feature, not a company.
- **Mitigation:** Admit the scheduler alone isn't a moat against Tarteel. Win the segment all rivals structurally ignore: the FINISHED hafiz maintaining 600+ pages (everyone optimizes for new memorizers adding pages). Build compound moats: the maintenance/graceful-degradation/load-cap workflow nobody markets; traditional-workflow fidelity + scholar/madrasah endorsements + the B2B teacher channel Tarteel hasn't built; trust/privacy/halal-billing reputation (their paywall resentment is an opening). Own the "never silently lose the Quran" positioning fast so a Tarteel feature looks like a copy. Accept that acquisition may be the realistic exit; plan for it.

### Item 11 — Scope creep
- **Severity:** high | **Likelihood:** high
- **Issue:** f1-f9 + mutashabihat trainer + audio-mushaf + teacher dashboard + family/child + heat-maps + streaks + multi-source grading + calibration + region presets + AI verification is years of work serving all seven personas at once, yielding a mediocre everything-app that beats the spreadsheet for no one and opens every religious red line simultaneously.
- **Mitigation:** Cut to one persona: the finished hafiz fighting manzil decay.
  - **KEEP v1:** page-level maintenance scheduler with hard max-interval ceiling, graceful backlog re-spread, un-skippable manzil, recency/age/last-rating ordering, capped session, immutable text (CI checksum + visual-diff), retention heat-map, offline privacy, scholar-reviewed halal billing.
  - **DEFER v2+:** AI recitation verification (the real moat; the one big bet if affordable).
  - **CUT v1:** full mutashabihat-penalty graph (ship a static scholar-reviewed confusables list only), confidence-weighted multi-source grading, cold-start calibration, teacher/madrasah dashboard (f7), family/child mode (f9).
  - **CUT ENTIRELY:** leaderboards, XP/badges on sacred content, guilt/fear streak notifications, bundled tafsir/translation.
  - **Success gate:** a hafiz runs full-Quran maintenance, is told exactly what to revise today, never sees silent decay or a shame-pile after missed days, and trusts the text and billing.

### Critique Summary

Six failure modes; the most dangerous are non-technical. **Existential religious-trust failures:** one wrong diacritic or device-render glitch, a perceived sectarian/qira'at bias, gamification of sacred text, or riba-coded billing can end the product overnight regardless of engineering quality. **Strategic risks:** the "just another tracker" trap (spreadsheets/Anki are free, flexible, trusted, offline-owned; your edge only beats them for the ONE persona with acute retention pain); brutal habit-app churn (invisible delayed payoff, and the better it works the less users feel they need it); and Tarteel bolting a page-level scheduler on in a quarter while you need years to build the verification it already owns. The SR designs are over-engineered for v1: Design A can't be validated (no hifz ground truth, can't A/B-test decay), and both depend on a grade self-raters won't give honestly.

**RECOMMENDED PATH:** ship **Design B** (tradition-as-UI, FSRS hidden as an ordering/flagging advisor inside fixed quotas); do NOT rely on honest self-rating as the primary signal; secure a named scholar endorsement and halal-billing certification BEFORE launch; default to non-gamified loss-prevention framing; cut to one persona (the finished hafiz fighting manzil decay).

**CUT LIST — KEEP v1:** page-level maintenance scheduler, hard max-interval ceiling so nothing decays silently, graceful backlog re-spread, un-skippable manzil, simple recency/age/last-rating ordering, budget-capped session, immutable Tanzil text via QPC fonts + CI checksum + visual-diff gate, whole-Quran retention heat-map, offline-first no-brokering privacy, scholar-reviewed halal billing.

**DEFER v2+:** AI recitation verification (the eventual moat and honest grading signal — the one big bet if affordable, not alongside everything else).

**CUT from v1:** full mutashabihat penalty graph (ship a static confusables list only), confidence-weighted multi-source grading, cold-start calibration, teacher/madrasah dashboard (f7), family/child mode (f9).

**CUT ENTIRELY:** public leaderboards, XP/badges on sacred content, guilt/fear streak notifications, bundled tafsir/translation.

**FOUR HARD LAUNCH GATES** before the traditional/madrasah segment: (1) verified text integrity in CI, (2) named scholar/institution endorsement, (3) a grading signal not dependent on honest self-rating, (4) a monetization model a conservative scholar certifies as halal on sight.

---

## 11. Completeness Gaps
*(from `completeness`)*

**Summary:** Top completeness gaps in the hifz research and designs (terse for payload limits).

| # | Gap / Issue | Mitigation |
|---|---|---|
| 1 | 604-page Hafs mushaf hardcoded; Warsh, Qaloon, non-15-line excluded. | Parameterize the card unit and layout; validate demand before locking 604. |
| 2 | AI verification build vs license vs partner unresolved; tajweed unsolved. | Plan ASR sourcing (licensed, whisper plus alignment); ship manual grading first. |
| 3 | Cold start undesigned; nobody can grade 604 pages on day one. | Per-juz self-assessment plus age and recency priors to seed state, ramped calibration. |
| 4 | Premium pricing clashes with paywalled-worship discomfort; willingness to pay unvalidated. | Free sadaqah-funded core; charge non-worship add-ons; test pricing with the wedge persona. |
| 5 | Madrasah children de-prioritized; payable market may be small; no TAM or CAC plan. | Size the payable wedge; add channels (imam, madrasah, diaspora) and a teacher B2B bridge. |
| 6 | Trust prereqs assumed: no ulama board, women audio privacy, text fidelity. | Scholar advisory early; non-audio grading first-class; checksum text in CI as launch blocker. |
| 7 | 0.97 to 0.99 retention target unvalidated for interfering serial-recall sacred text. | Run a pilot vs traditional fixed rotation on retention and daily load. |
| 8 | Mutashabihat dataset availability unverified; grading unit mismatched (ayah vs page). | Verify or grow the confusables graph from user errors; capture sub-page errors into page state. |
| 9 | No MVP sequencing; wedge needs both hardest AI piece and novel scheduler at once. | Ship thin self/teacher-graded scheduler first; AI as fast-follow with kill criteria. |
| 10 | Real moat is proprietary confusion and error data, not the replicable FSRS scheduler. | Instrument privacy-first on-device error capture from day one so data compounds. |

---

## 12. Synthesized Product Vision
*(from `vision`)*

### Vision Statement

The app that guarantees a hafiz never silently loses the Quran. We serve the most painful, worst-served job in Quran memorization: **maintenance, not memorization**. A finished or near-finished hafiz carries 600+ pages that decay invisibly, with hadith-driven spiritual dread attached to forgetting. Existing tools are paper-replica checklists (no intelligence) or AI listeners with no real scheduler (Tarteel), or hobby FSRS trackers with no ears. We fuse recitation-aware grading with a page-level spaced-repetition scheduler purpose-built for sustainable lifetime retention — it tells you exactly what to revise today, caps the daily load so a full-Quran review stays feasible, surfaces weak ajzaa before they rot, and degrades gracefully when you miss days. The traditional sabaq/sabqi/manzil workflow is the visible contract; FSRS-rigorous DSR math is the silent engine underneath. We are a servant to the teacher and the talaqqi chain, never a replacement for it. Loss prevention and peace of mind — never gamified or transactional worship.

### Differentiation Thesis

Own the empty quadrant: an intelligent, recitation-aware revision scheduler built for MAINTENANCE of the whole Quran, not for adding new pages. Every competitor optimizes the new memorizer; almost none serve the completed hafiz fighting decay. Tarteel has ears (best-in-class AI mistake detection, 15M+ users) but no genuine spaced-repetition scheduler. FSRS/SM-2 trackers (Quran Companion, QuranH) have a scheduler but no recitation verification and bolt SR onto a flashcard/word model rather than whole-page recall. Traditional trackers (Al-Muhaffiz) replicate sabaq/sabqi/manzil as a dumb calendar with no ordering intelligence. Our wedge is the fusion both halves lack: grade WHERE a hafiz stumbles (manual/teacher first, AI fast-follow), then feed that into a page-level DSR scheduler that hard-caps daily reviews, models mutashabihat interference (the dominant failure mode, not decay), keeps manzil un-skippable, and load-balances so the muraja'ah queue never becomes an overwhelming or rigid pile. The deep moat is not the replicable FSRS math — it is the proprietary, privacy-first dataset of where real huffaz actually confuse and stumble across the mushaf, captured from day one.

### Recommended SR Engine — UNIFIED-DSR-Q

One FSRS-6 scheduler, traditional tracks as the UI skin. Merge Design A's mathematical rigor with Design B's trust-first framing.

- **UNIT OF SCHEDULING:** the mushaf page is the card (604 cards for Hafs/Madani 15-line). Sub-page line/ayah state is a derived overlay used ONLY to localize weakness and seed mutashabihat links; the scheduled and recited unit stays the whole page, matching how huffaz actually recite (in flow). Make the card unit a parameter, not a hardcode, so non-15-line and (later) Warsh layouts plug in without an engine rewrite.
- **PER-CARD STATE:** Difficulty D in [1,10], Stability S (days to R=0.9), Retrievability R, plus an Interference scalar I and last-grade timestamp. FSRS-6 power-law forgetting curve: `R(t,S) = (1 + (19/81)·t/S)^(-0.5)`, so R(S)=0.9 by definition. Interval inverted from desired retention: `I_days = (S/(19/81))·(R_desired^(1/-0.5) - 1)`.
- **ONE MODEL, THREE LIFECYCLE PHASES** (NOT three algorithms — this kills the hand-off bugs of separate-queue trackers): sabaq = new lesson, no stability or S < ~3 days, desired retention 0.90, graded hardest, repeated within-day; sabqi = graduated from sabaq, recent revision band, retention 0.94; manzil = long-cycle band, retention 0.97-0.99. A card auto-promotes when its Stability crosses the band threshold. Recitation order is enforced old-before-new (manzil, then sabqi, then sabaq) to match tradition.
- **GRADING PIPELINE (the wedge):** all inputs normalize to one internal (grade, error_vector) signal with a per-source CONFIDENCE WEIGHT that scales how aggressively the DSR update moves. Self-rating = low confidence (noisy, small state move); teacher/talaqqi sign-off = highest confidence and can always override the machine (sanad chain is first-class); AI audio listening = high confidence with objective error positions, added as fast-follow. Grade is driven by WHERE and HOW MANY errors occurred in the bulk page recitation, not a binary flip.
- **MUTASHABIHAT INTERFERENCE LAYER:** a graph of confusable passages, seeded from a curated, scholar-reviewed dataset (objective near-identical wording only, never interpretive groupings) and grown from the user's own confusion errors. It (a) co-schedules linked pages into the same session for discrimination drills and (b) injects the Interference penalty I into the D/S update so confusables decay faster and resurface sooner. This is the proprietary-data moat — instrument it privacy-first, on-device, from day one.
- **BUDGET-AWARE LOAD BALANCER:** a daily solver fits due reviews + new sabaq into the user's minutes/day budget. It uses FSRS retrievability and FSRS load-simulation to decide what is safe to defer vs un-deferrable. CRITICAL TRUST CONSTRAINT (from Design B): manzil is hard-capped as un-skippable and the WHOLE Quran sits under a guaranteed maximum-interval ceiling — the engine may pull a weak page FORWARD but is forbidden from ever telling a hafiz a page is 'safe to drop' or letting a juz silently rot the way a pure cost-optimized FSRS queue would. Nothing decays silently; nothing is hidden.
- **COLD START:** no one can grade 604 pages on day one. Ship a per-juz self-assessment placement flow plus age/recency priors that seed D/S without pretending strength is known, then converge over the first 2-3 weeks of real grades. Catch-up logic re-spreads the backlog over several days after missed days instead of dumping it.
- **TRUST FRAMING:** users pick a NAMED cycle (e.g. '1 juz/day manzil', '7-manzil weekly khatm', 'Deobandi 3-track'), never a retention slider. Tradition is the surface; SR wins only in the invisible ordering. The day always looks like sabaq/sabqi/manzil quotas a teacher would recognize and can sign off.

### Core Insights
1. The underserved, high-pain, payable job is RETENTION after finishing (the manzil/dhor problem), not memorization. Hifdh is never finished; the dominant failure mode is forgetting, and hadith-driven guilt makes it spiritually urgent. Every credible source confirms this independently.
2. The empty market quadrant is recitation-verification fused with a real scheduler for maintenance. Tarteel has ears but no scheduler; FSRS trackers have a scheduler but no ears; traditional trackers are dumb calendars. No one occupies the intersection.
3. The FSRS DSR model is the correct math backbone and transfers cleanly, but four things break for hifz: the unit is a page not a card, the grade is graded fluency with error positions not a binary flip, interference (mutashabihat) not decay is the dominant failure, and the retention target must be ~0.97-0.99 not 0.90 because sacred-text errors are unacceptable.
4. Tradition must be the UI and the algorithm the silent engine. An algorithm overtly telling a hafiz what to revise reads as presumption inserting a machine into the sacred talaqqi/sanad chain. Demote the scheduler to 'the smart page-selector inside a fixed-shape traditional day.'
5. Quran text fidelity is existential and the biggest controllable risk is DEVICE rendering, not source text. Store Tanzil Uthmani unmodified with a CI SHA-256 checksum, render only via bundled QPC per-page glyph fonts (never the OS shaper), take layout from QUL MushafPage, and overlay error positions as coordinates — never re-typeset.
6. Monetization is religiously coded: paywalling worship triggers real revulsion; winners frame usage as sadaqah jariyah. Reading/reciting the Quran must NEVER be paywalled; only scheduler/analytics/teacher add-ons can be charged, and the model must avoid riba/gharar framing (no interest-like installments, no dark-pattern trials).
7. The real moat is the proprietary, privacy-first dataset of where huffaz actually confuse and stumble — not the replicable FSRS scheduler. Instrument on-device error capture from day one.
8. Scholarly/institutional endorsement is a hard pre-launch gate for the traditional segment, not marketing polish. Without an endorser, restrict launch to self-directed diaspora adults.
9. The default Hafs + Madani 15-line mushaf is implicitly one qira'at; silent single-viewpoint invites sectarian-bias accusations. State the riwayah explicitly, keep the scheduler text-agnostic, ship zero bundled tafsir in v1, and parameterize the mushaf as a swappable asset.
10. The wedge requires the novel scheduler AND the hardest AI piece; doing both at once is a trap. Ship a thin self/teacher-graded scheduler first and add AI as a fast-follow with explicit kill criteria.

### Personas Served
- **PRIMARY WEDGE — Persona 2:** the completed/near-complete hafiz fighting to retain all 30 juz. Highest pain, clearest payment trigger (fear of loss plus identity), strongest fit with SR as core mechanic, least adequate tooling. Goal: never lose what cost years; keep the Quran fresh enough to lead prayers on demand.
- **EXPANSION — Persona 3:** adult late-starter memorizers in the diaspora. Same retention engine, disposable income, self-directed (no scholar-endorsement dependency), strongest beachhead if traditional endorsement lags. Best near-term revenue.
- **EXPANSION — active memorizers** still adding pages (sabaq phase). Same unified engine, just a different lifecycle band; natural upsell as the wedge proves the scheduler.
- **LATER / HIGHEST-LTV B2B — Persona 5:** teachers and madrasahs. Hardest to win, requires the consumer engine proven first; teacher/talaqqi sign-off is already first-class in the model, so the dashboard is a natural bridge.
- **LATER — families and children mode.** Low-medium value, low moat; pursued only after the core retention loop is loved.

### MVP Features

| Feature | Priority | Why |
|---|---|---|
| Page-level DSR scheduler with the three traditional tracks as named cycle presets (sabaq/sabqi/manzil) | P0 | This is the wedge and the entire value proposition. Without the intelligent page-selector inside a fixed-shape traditional day, we are just another checklist. One FSRS engine, three lifecycle bands, named cycles (1 juz/day, 7-manzil weekly, Deobandi 3-track) so it earns trust on the surface. |
| Self-rating and teacher/talaqqi sign-off grading that drives (grade, error_vector) state with per-source confidence weights | P0 | Grading is the input to the whole engine and must ship before AI. Teacher sign-off is first-class and always overrides the machine, buying trust with the conservative audience. Defers the hardest (AI) piece without blocking the scheduler. |
| Budget-aware daily load balancer with hard manzil cap, whole-Quran maximum-interval ceiling, and missed-day catch-up | P0 | Turns a crushing, unbounded, self-managed paper load into a finite, feasible daily list — the single thing the wedge persona will pay for. The un-skippable manzil and 'nothing decays silently' ceiling are the trust guarantees that separate us from a cold cost-optimized FSRS queue. |
| Cold-start placement: per-juz self-assessment plus age/recency priors, ramped calibration over 2-3 weeks | P0 | Nobody can grade 604 pages on day one; without this the app is unusable for the exact persona we target. Onboarding is make-or-break for a hafiz with the whole Quran already in memory. |
| Immutable mushaf rendering: Tanzil Uthmani unmodified + CI SHA-256 checksum, QPC per-page glyph fonts, QUL MushafPage layout, explicit stated riwayah | P0 | Text fidelity is existential — one wrong diacritic or render glitch brands us 'the app that corrupted the Quran.' This is a launch blocker, not a feature. Error positions overlay as coordinates on the immutable glyph page, never re-typeset. |
| Whole-Quran retention heat-map (decay made visible by page/juz) | P1 | Makes the invisible decay visible and is the emotional hook that drives the loss-prevention framing. Low build cost, high perceived value, strong onboarding and retention surface. |
| Mutashabihat confusables trainer seeded from a curated, scholar-reviewed dataset and grown from user errors | P1 | Interference is the top failure mode and a strong differentiated moat. Ship a v1 discrimination-drill from a verified seed graph; the user-error growth begins the proprietary dataset. Scoped to objective near-identical wording only. |
| Offline-first, privacy-first architecture with on-device error/confusion capture from day one | P0 | Privacy is existential in this market (Muslim Pro scandal), women's audio privacy is a real concern, and on-device error capture is what builds the real moat. Must be designed in from the start, not retrofitted. |

### Killer Features
- **Recitation-graded page-level MAINTENANCE scheduler** — the wedge no competitor occupies; turns the unbounded muraja'ah load into a finite daily list and guarantees nothing silently rots.
- **Mutashabihat confusables trainer** — attacks the #1 failure mode (interference, not decay) and grows a proprietary confusion dataset that is the real moat.
- **Whole-Quran retention heat-map** — makes invisible decay visible; the emotional hook for loss-prevention framing.
- **Manzil scheduler with named maddhab/region presets and graceful missed-day catch-up** — the crushing traditional paper load made sustainable, in a form a teacher already trusts.
- **AI recitation verification (fast-follow)** — the by-ear grading surface that, fused with the scheduler, completes the empty quadrant Tarteel and FSRS trackers each only half-fill.
- **Teacher/madrasah dashboard with first-class talaqqi sign-off** — highest-LTV B2B bridge built directly on the grading model already shipped for consumers.

### Later Features
- AI audio recitation verification (whisper + forced alignment) as a fast-follow with explicit kill criteria if accuracy or false-positive rate is unacceptable.
- Teacher and madrasah B2B dashboard and licensing (after the consumer engine is proven and loved).
- Audio-mushaf revision mode (listen-and-correct, by-ear capture surface).
- Warsh and other riwayat/mushaf layouts as swappable assets (roadmap before targeting West Africa; validate demand before locking).
- Family and child mode with parent/teacher oversight.
- Tasteful streaks and khatma goals (loss-prevention framed, never gamified spirituality).
- Institutional/madrasah analytics, cohort tracking, and ijazah/sanad record-keeping.
- Tajweed-level (not just word-level) verification once core ASR is reliable.

### Tech Stack

Cross-platform offline-first client (**Flutter preferred** for render control, or React Native). Local-first **SQLite/Drift** store holding per-card D/S/R/I state, error vectors, and the confusables graph entirely on-device. **FSRS-6 scheduler as a pure, golden-tested, platform-agnostic module.** Data: **Tanzil Uthmani** unmodified (CC BY 3.0, attributed, CI SHA-256 checksum); **QUL (MIT)** for mushaf layout/segmentation/timestamps; **KFGQPC QPC fonts (QCF_P001-604)** bundled unmodified; CI visual-diff vs reference mushaf on min-OS versions; render via glyph fonts, never the OS shaper. AI fast-follow: whisper-class ASR + forced alignment to QUL word timestamps, on-device or no-raw-audio-retention service. Minimal optional backend (sync, teacher dashboard, donations); full function offline with no account.

### Monetization

> *(Retained for archival completeness; per the project framing the app is built FREE as sadaqah jariyah and monetization is not a goal.)*

Halal-by-default, sadaqah-jariyah framed. **IRON RULE: reading and reciting the Quran itself is NEVER paywalled** — only the value-add scheduler intelligence, analytics, mutashabihat trainer, and teacher tools can be charged. Free, fully-functional core (the basic scheduler + reading) framed as ongoing benefit. Revenue from a transparent value-add subscription (advanced analytics, heat-map history, AI verification, multi-device sync) AND/OR a one-time purchase, plus optional waqf/sadaqah donations. Institutional/madrasah and family licensing as the higher-LTV B2B layer later. AVOID: interest-like installments, auto-renew traps, free-trial dark patterns (riba/gharar accusation risk). Get written scholarly approval on the billing model itself before launch. Benchmark: Tarteel ~$99/year already draws loud paywall resentment — price below the resentment line and lead with 'we will never charge you to read the Quran.' Validate willingness-to-pay with the wedge persona before locking price.

### Go-to-Market

Wedge-first, community-led, endorsement-gated. Lead with one message: 'the app that makes sure a hafiz never silently loses the Quran.' Channels: (1) hafiz and muraja'ah communities (Reddit r/islam/hifz forums, Discord/Telegram hifz groups, YouTube huffaz) where the manzil-decay pain is openly discussed; (2) imams and local huffaz as trusted referrers; (3) diaspora adult-memorizer networks (self-directed, no endorsement dependency) as the fastest beachhead if scholarly sign-off lags; (4) madrasah networks (South Asia, MENA, Indonesia, Turkey, West Africa, Western diaspora) as the later B2B bridge. HARD GATE: a named scholar/institution endorsement before marketing to the traditional segment, with maddhab-named presets (Deobandi 3-track, Arab muraja'ah) co-signed by that tradition. Position relentlessly as 'servant to the teacher, not a replacement.' Privacy and offline-first as explicit trust signals (post-Muslim-Pro-scandal). Sadaqah-jariyah framing in all copy.

### Best Initial Wedge

The completed/near-complete hafiz (Persona 2) fighting manzil/dhor decay across all 30 juz. Reached first through self-directed diaspora-adult and online hifz communities so the product can launch and iterate even before traditional scholarly endorsement lands. The product they get: a thin self/teacher-graded page-level scheduler that says exactly what to revise today, caps the load, and visibly guarantees no juz silently rots — framed as loss prevention and peace of mind.

### Naming Ideas
- **Dhor** (the traditional term for far-revision — instantly recognized by the wedge persona)
- **Manzil** (the un-skippable cycle the product protects)
- **Thabat** (Arabic: firmness/steadfastness — 'keep it firm')
- **Rasikh** (deeply-rooted/firmly-established knowledge)
- **Sabeel Hifz**
- **Yaqeen Hifz**
- **Murajaah** (the revision act itself)
- **Hafiz Companion / Hifz Keeper** (English, diaspora-friendly, descriptive)

### Religious Integrity (Non-negotiable Guardrails)
1. **Text fidelity as a launch blocker:** Tanzil Uthmani byte-for-byte unmodified, CI SHA-256 checksum, QPC glyph-font rendering only, QUL layout, visual-diff in CI — never re-typeset or store reconstructed text.
2. **Scholar advisory board engaged early;** named endorsement is a hard pre-launch gate for the traditional segment — if no endorser will attach their name, restrict to self-directed diaspora adults.
3. **Servant to talaqqi, never a replacement:** teacher sign-off is first-class and always overrides the machine; the sanad chain is sacred.
4. **Riwayah stated explicitly in-app** ('Hafs an Asim, Madani mushaf'), never presented as 'the' Quran; scheduler kept text-agnostic; mushaf a swappable asset with Warsh roadmapped before targeting West Africa.
5. **ZERO bundled tafsir/translation/commentary in v1** to avoid encoding a madhhab; mutashabihat list scholar-reviewed and scoped to objective near-identical wording only.
6. **Halal monetization:** never paywall reading/reciting; sadaqah-jariyah framing; written scholarly approval on the billing model; no riba/gharar-adjacent mechanics.
7. **Women's audio privacy first-class:** non-audio (self/teacher) grading is fully sufficient; AI audio is opt-in and never required.
8. **The engine is forbidden from telling a hafiz a page is 'safe to drop'** — nothing decays silently.

### 90-Day Plan

**DAYS 1–15 — Foundations and trust gates.** Stand up the offline-first client shell. Bundle Tanzil Uthmani + QPC fonts + QUL layout; wire the CI SHA-256 checksum and visual-diff (text fidelity is a hard gate, do it first). Begin scholar-advisor outreach in parallel (long lead time). Define the FSRS-6 module interface and write golden tests against reference intervals. Instrument on-device error/confusion capture schema from day one (the moat). **VERIFY:** build fails on any text byte change; one scholar conversation opened.

**DAYS 16–40 — The engine, thin.** Implement the unified DSR-Q scheduler: one model, three lifecycle bands, page card, manzil hard-cap, whole-Quran max-interval ceiling, budget-aware load balancer, missed-day catch-up. Ship self-rating and teacher sign-off grading normalized to (grade, error_vector) with confidence weights. Build cold-start per-juz placement + age/recency priors. NO AI yet. **VERIFY:** a tester with a full Quran can onboard in under 20 min and get a sane, capped daily list; golden tests pass; manzil never disappears from the queue.

**DAYS 41–60 — Wedge polish and emotional hook.** Ship named cycle presets (1 juz/day, 7-manzil weekly, Deobandi 3-track) and the whole-Quran retention heat-map. Ship a v1 mutashabihat trainer from a small scholar-reviewed seed graph. Recruit 15–30 wedge-persona testers from diaspora/online hifz communities. **VERIFY:** testers report the daily list feels trustworthy and the heat-map drives action; capture qualitative loss-prevention reactions.

**DAYS 61–75 — Closed pilot and validation.** Run a 2-week pilot of DSR-Q vs traditional fixed rotation measuring retention and daily-load feasibility (validates the 0.97-0.99 target and the load balancer). Validate willingness-to-pay with the wedge persona; pressure-test the halal billing model with the scholar advisor (written approval on billing). Confirm or grow the mutashabihat graph from real user errors. **VERIFY:** pilot shows non-inferior retention at lower/feasible daily load; a billing model with scholarly sign-off; a go/no-go on traditional-segment launch vs diaspora-only.

**DAYS 76–90 — Launch the wedge and scope the fast-follow.** Public launch to the self-directed diaspora-adult and online hifz wedge (endorsement-gated for the traditional segment — diaspora-only if no endorser yet). Ship sadaqah/donation flow and the transparent value-add tier (never paywalling reading). Begin the AI-verification fast-follow spike (whisper + forced alignment to QUL timestamps) with EXPLICIT kill criteria on accuracy/false-positive rate before committing. **VERIFY:** live with paying/donating users, on-device error dataset accumulating, an AI go/no-go decision dated.

### Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Quran text corruption via wrong diacritic, broken ligature, or OS-shaper render glitch — brands us 'the app that corrupted the Quran.' Most app errors are DEVICE rendering, the layer we control least. | Tanzil Uthmani unmodified with a CI SHA-256 checksum that fails the build on any byte change. Render only via bundled QPC per-page glyph fonts, never the OS shaper. Layout from QUL MushafPage, never computed. CI visual-diff vs reference mushaf images on min-OS versions. Error positions overlay as coordinates on the immutable glyph page; never re-typeset. |
| No scholarly endorsement = no trust = no traditional market. An algorithm telling a hafiz what to revise reads as presumption inserting a machine into the sacred talaqqi/sanad chain. | Named scholar/institution endorsement as a hard pre-launch gate, not polish. Position as servant to the teacher; teacher sign-off first-class and always overrides. Maddhab-named presets co-signed by that tradition. If no endorser attaches their name, restrict launch to self-directed diaspora adults — which the wedge GTM already supports. |
| Sectarian/qira'at neutrality: default Hafs + Madani 15-line is implicitly one qira'at; Warsh/Qaloon/Shi'a/basmala/numbering differences invite sectarian-bias accusations. | State the riwayah explicitly in-app, never 'the' Quran. Keep the scheduler text-agnostic; make mushaf/riwayah a swappable QUL asset; roadmap Warsh before targeting West Africa. Ship ZERO bundled tafsir/translation in v1. Scholar-review the mutashabihat list, scoped to objective near-identical wording. |
| Riba/transactional-worship billing backlash — paywalling worship draws revulsion; Tarteel already gets loud paywall resentment. | Never paywall reading/reciting; charge only value-add scheduler/analytics/teacher tools. Sadaqah-jariyah framing, optional donations, one-time-purchase option. Get written scholarly approval on the billing model. No riba/gharar-adjacent mechanics (no installments, no auto-renew traps, no dark-pattern trials). |
| The 0.97-0.99 retention target is unvalidated for interfering serial-recall sacred text; could over- or under-load. | Run the days 61-75 pilot vs traditional fixed rotation, measuring retention and daily load. Tune the target empirically; the load balancer and ceiling bound the cost either way. |
| Cold start is hard — nobody can grade 604 pages on day one, and bad onboarding loses the exact persona we target. | Per-juz self-assessment + age/recency priors that seed D/S without pretending strength is known, converging over 2-3 weeks of real grades. Validated in days 41-60 with a sub-20-minute onboarding target. |
| The wedge needs both the novel scheduler AND the hardest AI piece; building both at once over-scopes and risks shipping neither well. | Ship the thin self/teacher-graded scheduler first (P0); AI verification is a fast-follow (days 76-90 spike) with explicit kill criteria on accuracy and false-positive rate before commitment. |
| The replicable FSRS scheduler is not a durable moat; a funded competitor (Tarteel) could add a scheduler. | The real moat is the proprietary, privacy-first dataset of where huffaz actually confuse and stumble. Instrument on-device error capture from day one and let the mutashabihat graph compound. Speed to the empty quadrant plus trust/endorsement are the defensible edges. |
| Women's audio privacy and general privacy are existential (Muslim Pro scandal); audio-first grading could exclude or endanger users. | Offline-first, no-account-required, on-device error capture. Non-audio (self/teacher) grading is fully sufficient and first-class; AI audio is strictly opt-in, never required, with no raw-audio retention. |
| Payable market may be smaller than the huffaz population suggests; no validated TAM/CAC. | Lead with the diaspora-adult wedge (disposable income, self-directed), validate willingness-to-pay in the pilot, and treat the teacher/madrasah B2B layer as the higher-LTV expansion once the consumer engine is proven. |
