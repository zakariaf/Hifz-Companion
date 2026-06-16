# Master Graded Bibliography

This is the deduplicated master bibliography for the Hifz Companion science foundation: every source that any science doc cites — the eleven synthesis docs (`01`–`11`), [`README.md`](README.md), and the [`CLAIMS.md`](CLAIMS.md) register — gathered in one place, graded, and grouped by topic. It exists so that a developer (or a sceptical ḥāfiẓ, teacher, or scholar) can trace any number, rule, or piece of on-screen copy back to a named, dated, web-verified source. Each entry gives the full citation, a working URL, the evidence grade, and a short note on **what the app takes from it**. This file introduces no new claims; it indexes the sources behind claims made elsewhere in `docs/science/`. Because the work is *ṣadaqah jāriyah*, the standard is *iḥsān* — every citation here is real and was verified against PubMed, a DOI/publisher page, a primary PDF, or — for hadith — Sunnah.com / HadeethEnc with collection, number, and grading.

---

## How to read this file

- Sources are **grouped by theme** (matching the synthesis docs) and, within each group, sorted alphabetically by first author or — for institutional/web sources — by title. A source used by several docs is listed once, under its primary theme, with its broader use noted.
- Every entry ends with its **evidence grade** in the form `— [GRADE]`, per blueprint §3.
- Each synthesis doc carries its own `## References` list of only the sources it cites; **this file is the deduplicated superset.** Where a source's exact citation varied slightly across docs (edition, mirror URL, or annotation), the canonical, most-verifiable form is used here.
- The citation policy (real, web-verified, never fabricated; rulings never issued; "needs scholarly review" flagged where due) lives in [`../_DOC-SET-BLUEPRINT.md`](../_DOC-SET-BLUEPRINT.md) §2 and is recapped in [`README.md`](README.md).

### Evidence-grade legend

Preference among empirical grades: **MA > RCT / EXP > CS > OBS > TEXT.** Methodology and religious claims are **[TRAD]** and must name the source.

| Grade | Meaning |
|-------|---------|
| **[MA]** | Meta-analysis or systematic review |
| **[RCT]** | Randomized controlled experiment |
| **[EXP]** | Controlled cognitive experiment |
| **[CS]** | Classic foundational study that shaped the field |
| **[OBS]** | Observational, applied, or field study |
| **[TEXT]** | Textbook, expert review, or authoritative technical documentation |
| **[TRAD]** | Traditional or scholarly Islamic source (named) |

### Theme-to-file map

| Theme | Primary file(s) |
|-------|-----------------|
| Memory & forgetting | 01 |
| The spacing effect | 02 |
| Spaced-repetition algorithms (FSRS / SM-2 / Leitner) | 03 |
| Retrieval practice & self-testing | 04 |
| Interference & mutashābihāt | 05 |
| Overlearning & lifelong retention | 06 |
| Serial recall & the page unit | 07 |
| Sleep & consolidation | 08 |
| Motivation without coercion | 09 |
| Traditional hifz methodology & Islamic sources | 10 |
| Trust, transparency & the in-app science screen | 11, README |

---

## 1. Memory & forgetting

The decay axiom the whole product answers to: that an unrevised page slopes downward on a measurable, reproducible curve. Used in **01**, with the savings/permastore findings also feeding **06**.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Bahrick, H. P. (1984). *Semantic memory content in permastore: Fifty years of memory for Spanish learned in school.* Journal of Experimental Psychology: General, 113(1), 1–29. https://pubmed.ncbi.nlm.nih.gov/6242406/ | **[OBS]** | The "permastore" plateau reached by depth-and-spacing over years — the honest basis for "near-100% retention comes from overlearning, not a magic number," and that even mastered material's curve still slopes. The single most-reused source in the set (01, 06, 10, 11, README). |
| Ebbinghaus, H. (1885/1913). *Über das Gedächtnis (Memory: A Contribution to Experimental Psychology)* (H. A. Ruger & C. E. Bussenius, Trans.). Teachers College, Columbia University. https://psychclassics.yorku.ca/Ebbinghaus/index.htm | **[CS]** | The founding forgetting-curve and savings-on-relearning method — the empirical premise of the entire scheduler. (Dover reprint, 1885/1964, at https://archive.org/details/memorycontributi00ebbiuoft; overview at https://en.wikipedia.org/wiki/Forgetting_curve.) Used in 01, 02, 03. |
| Murre, J. M. J., & Chessa, A. G. (2022/2023). *Why Ebbinghaus' savings method from 1885 is a very 'pure' measure of memory performance.* Psychonomic Bulletin & Review, 30(1), 303–307. https://link.springer.com/article/10.3758/s13423-022-02172-3 | **[TEXT]** | Why savings-on-relearning is a clean retention measure — supports treating a re-recited page's ease as a stability signal. |
| Murre, J. M. J., & Dros, J. (2015). *Replication and analysis of Ebbinghaus' forgetting curve.* PLOS ONE, 10(7), e0120644. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0120644 | **[EXP]** | The 130-years-later independent replication — the strongest evidence that decay is a reproducible empirical regularity, not folklore. The README's pillar-1 anchor. |
| Nelson, T. O. (1985). *Ebbinghaus's contribution to the measurement of retention: Savings during relearning.* Journal of Experimental Psychology: Learning, Memory, and Cognition, 11(3), 472–479. https://psycnet.apa.org/record/1986-11014-001 | **[EXP]** | Relearning is faster than first learning even when recall has failed — the basis for cheap reactivation of a lapsed juz rather than re-memorizing it. Used in 01, 06. |
| Roediger, H. L. (1985). *Remembering Ebbinghaus.* PsycCRITIQUES (Contemporary Psychology), 30(7), 519–523. http://psychnet.wustl.edu/memory/wp-content/uploads/2018/04/Roediger-1985_CP.pdf | **[TEXT]** | Historical context placing Ebbinghaus's method and its enduring validity — background for the curve's authority. |
| Wixted, J. T., & Ebbesen, E. B. (1997). *Genuine power curves in forgetting: A quantitative analysis of individual subject forgetting functions.* Memory & Cognition, 25(5), 731–739. https://pubmed.ncbi.nlm.nih.gov/9337591/ | **[EXP]** | Forgetting follows a **power law**, not an exponential — the justification for FSRS's power-law retrievability curve over a simple exponential. |
| Woźniak, P. A. (n.d.). *Forgetting curve.* SuperMemo Guru. https://supermemo.guru/wiki/Forgetting_curve | **[TEXT]** | Practitioner framing of the forgetting curve and the two-component (stability/retrievability) view the engine encodes. |

---

## 2. The spacing effect

Distributed beats massed practice, and the optimal gap **expands** with the target retention interval — the mathematical licence for a juz moving from daily to weekly to monthly review. Used in **02**, feeding the cycle presets (PRD §7, §15).

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Bahrick, H. P., Bahrick, L. E., Bahrick, A. S., & Bahrick, P. E. (1993). *Maintenance of foreign language vocabulary and the spacing effect.* Psychological Science, 4(5), 316–321. https://journals.sagepub.com/doi/10.1111/j.1467-9280.1993.tb00571.x | **[CS]** | The nine-year study showing wide spacing yields durable, decades-long retention — direct support for long far-revision (*manzil*) intervals. (Graded [CS] in 02, [EXP] in 06; the classic grade is used here.) |
| Cepeda, N. J., Coburn, N., Rohrer, D., Wixted, J. T., Mozer, M. C., & Pashler, H. (2009). *Optimizing distributed practice: Theoretical analysis and practical implications.* Experimental Psychology, 56(4), 236–246. https://doi.org/10.1027/1618-3169.56.4.236 | **[EXP]** | The optimal gap as a fraction of the retention interval — concrete tuning for how far apart reviews should sit. |
| Cepeda, N. J., Pashler, H., Vul, E., Wixted, J. T., & Rohrer, D. (2006). *Distributed practice in verbal recall tasks: A review and quantitative synthesis.* Psychological Bulletin, 132(3), 354–380. https://www.yorku.ca/ncepeda/publications/CPVWR2006.html | **[MA]** | The definitive synthesis (839 assessments, 317 experiments): distributed reliably beats massed, and the optimal inter-study interval grows with the retention interval. The README's pillar-2 anchor; also used in 03, 08, 10. |
| Cepeda, N. J., Vul, E., Rohrer, D., Wixted, J. T., & Pashler, H. (2008). *Spacing effects in learning: A temporal ridgeline of optimal retention.* Psychological Science, 19(11), 1095–1102. https://doi.org/10.1111/j.1467-9280.2008.02209.x | **[EXP]** | The "ridgeline" mapping gap to retention interval — empirical shape behind expanding-interval scheduling. |
| Donovan, J. J., & Radosevich, D. J. (1999). *A meta-analytic review of the distribution of practice effect: Now you see it, now you don't.* Journal of Applied Psychology, 84(5), 795–805. https://psycnet.apa.org/doi/10.1037/0021-9010.84.5.795 | **[MA]** | Spacing's benefit varies with task complexity — a caution that the effect size is real but moderated, keeping claims honest. |
| Dunlosky, J., Rawson, K. A., Marsh, E. J., Nathan, M. J., & Willingham, D. T. (2013). *Improving students' learning with effective learning techniques: Promising directions from cognitive and educational psychology.* Psychological Science in the Public Interest, 14(1), 4–58. https://journals.sagepub.com/doi/10.1177/1529100612453266 | **[MA]** | The high-utility verdict on distributed practice and practice testing — independent confirmation that the two techniques the engine is built on are the best-evidenced of all. |
| Karpicke, J. D., & Roediger, H. L. III (2007). *Expanding retrieval practice promotes short-term retention, but equally spaced retrieval enhances long-term retention.* Journal of Experimental Psychology: Learning, Memory, and Cognition, 33(4), 704–719. https://doi.org/10.1037/0278-7393.33.4.704 | **[EXP]** | The nuance that *equal* spacing can match or beat naive expanding schedules for long-term retention — keeps the engine from over-claiming about expansion. Used in 02, 04. |
| Landauer, T. K., & Bjork, R. A. (1978). *Optimum rehearsal patterns and name learning.* In M. M. Gruneberg, P. E. Morris, & R. N. Sykes (Eds.), *Practical Aspects of Memory* (pp. 625–632). London: Academic Press. https://www.gwern.net/docs/spaced-repetition/1978-landauer.pdf | **[CS]** | The original expanding-rehearsal demonstration — historical root of expanding-interval SR. |
| Pashler, H., Zarow, G., & Triplett, B. (2003). *Is temporal spacing of tests helpful even when it inflates error rates?* Journal of Experimental Psychology: Learning, Memory, and Cognition, 29(6), 1051–1057. https://doi.org/10.1037/0278-7393.29.6.1051 | **[EXP]** | Spacing helps even when it makes practice feel harder/error-prone — the desirable-difficulty rationale for not over-reviewing. |
| Rohrer, D., & Taylor, K. (2006). *The effects of overlearning and distributed practice on the retention of mathematics knowledge.* Applied Cognitive Psychology, 20(9), 1209–1224. https://doi.org/10.1002/acp.1266 | **[EXP]** | Spacing beats overlearning (cramming extra reps in one session) for durable retention — argues for distributing revision over days, not piling it up. |

---

## 3. Spaced-repetition algorithms (FSRS / SM-2 / Leitner)

The lineage of scheduling math, and the FSRS DSR power-law engine the scheduler is built on (PRD §7.3, §7.6). These document the algorithm; they are technical references, not empirical studies, hence mostly **[TEXT]**. Used in **03**, feeding the engine spec.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Anki Manual. *Deck Options — Desired Retention / FSRS.* https://docs.ankiweb.net/deck-options.html | **[TEXT]** | The permissible desired-retention range (0.70–0.99) and default 0.90 — frames the per-phase retention targets the app picks by stakes. Used in 06. |
| Expertium. *FSRS Algorithm.* https://expertium.github.io/Algorithm.html | **[TEXT]** | D/S/R definitions; interval equals stability at 90% desired retention; post-lapse stability forced to `min(…, S)`; power curve fits better than exponential — the precise rules the lapse/update logic mirrors. Used in 03, 10, CLAIMS. |
| Leitner, S. (1972). *So lernt man lernen.* Verlag Herder, Freiburg. (Five-box system; common electronic variant 1/2/4/8/16 days; promote-on-correct, demote-to-box-1-on-error.) https://en.wikipedia.org/wiki/Leitner_system | **[TEXT]** | The ancestral box system — and the explicit reason the engine does **not** inherit Leitner's brutal demote-to-box-1 on a single slip for a 604-page corpus. |
| Open Spaced Repetition. *Free Spaced Repetition Scheduler (FSRS)* — repository. https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler | **[TEXT]** | The open, trainable DSR model that runs entirely locally — the licence basis for a fully-offline, no-AI-service scheduler (PRD C1/C2). |
| Open Spaced Repetition. *The Algorithm* — awesome-fsrs wiki. https://github.com/open-spaced-repetition/awesome-fsrs/wiki/The-Algorithm | **[TEXT]** | The exact power-law curve `R(t,S) = (1 + FACTOR·t/S)^DECAY`, `DECAY = −0.5`, `FACTOR = 19/81`, `R = 0.9` at `t = S`; interval `I(r,S) = (S/FACTOR)(r^(1/DECAY) − 1)`; parameter counts 17/19/21 for FSRS-4.5/5/6 — the formulae transcribed into the engine. Used in 03, CLAIMS. |
| Open Spaced Repetition. *fsrs4anki tutorial.* https://github.com/open-spaced-repetition/fsrs4anki/blob/main/docs/tutorial.md | **[TEXT]** | The default desired retention of 0.90 — the engine's starting prior before stakes-tiering. |
| Open Spaced Repetition. *The optimal retention* — fsrs4anki wiki. https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-optimal-retention | **[TEXT]** | Higher retention → shorter intervals → super-linearly more reviews; "optimal retention" minimises the workload-to-knowledge ratio — the cost-curve argument for not chasing a literal 0.99 globally (PRD §7.5). Used in 03, 06. |
| Open Spaced Repetition. *srs-benchmark* — benchmark of spaced-repetition algorithms (~727M reviews / 10k users, with a larger 1.7B-review / 20k-user set). https://github.com/open-spaced-repetition/srs-benchmark | **[OBS]** | The large-scale calibration evidence (FSRS-6 better calibrated than SM-2 for ~99.6% of collections, than SM-17 for ~83.3%; HLR ≈0.128, Ebisu v2 ≈0.163 RMSE) — why FSRS is chosen over SM-2/SM-17/HLR as the backbone. |
| Settles, B., & Meeder, B. (2016). *A Trainable Spaced Repetition Model for Language Learning.* Proc. 54th Annual Meeting of the ACL, Berlin, pp. 1848–1858. https://research.duolingo.com/papers/settles.acl16.pdf | **[OBS]** | Half-life regression on 12.9M sessions (MAE 0.128 HLR vs 0.235 Leitner, 0.445 Pimsleur; +12% engagement); Leitner and Pimsleur shown to be fixed-weight special cases — evidence that a trainable curve beats fixed schedules. Used in 03, CLAIMS. |
| Sinha, U. (2021). *How spaced repetition actually works: the SM-2 algorithm.* dev.to. https://dev.to/umangsinha12/how-spaced-repetition-actually-works-the-sm-2-algorithm-1ge3 | **[TEXT]** | A clear restatement of SM-2's formulas and its key limitation (no explicit retrievability) — context for why the engine moves past SM-2. |
| Woźniak, P. A. (1990; SM-2 in use since 1987). *SuperMemo 2: Algorithm.* https://super-memory.com/english/ol/sm2.htm | **[TEXT]** | The original SM-2 intervals and E-Factor update (start 2.5, floor 1.3) — the historical baseline the FSRS engine improves on. |
| Woźniak, P. A. *Algorithm SM-17.* SuperMemo Guru. https://supermemo.guru/wiki/Algorithm_SM-17 | **[TEXT]** | The stability-increase function `SInc(D, S, R)`; stability gain is largest when retrievability is low — the desirable-difficulty term the engine relies on. Used in 03, CLAIMS. |
| Woźniak, P. A., Murakowski, J., & Gorzelańczyk, E. J. *Two components of memory.* SuperMemo Guru. https://supermemo.guru/wiki/Two_components_of_memory | **[TEXT]** | The stability-vs-retrievability decomposition that grounds the whole D/S/R state — reviews raise stability little while R is high, more when R is low. Used in 03, CLAIMS. |

---

## 4. Retrieval practice & self-testing

The testing effect: reciting *from memory* (retrieval) strengthens a page far more than re-reading it — the science behind the reveal-on-tap recite flow and behind *talaqqī* itself (PRD §8.1). Used in **04**.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Adesope, O. O., Trevisan, D. A., & Sundararajan, N. (2017). *Rethinking the use of tests: A meta-analysis of practice testing.* Review of Educational Research, 87(3), 659–701. https://eric.ed.gov/?id=EJ1141817 | **[MA]** | A second large meta-analysis confirming the testing effect across formats — independent corroboration that retrieval beats restudy. |
| Bjork, E. L., & Bjork, R. A. (2011). *Making things hard on yourself, but in a good way: Creating desirable difficulties to enhance learning.* In *Psychology and the Real World.* https://www.unh.edu/teaching-learning-resource-hub/sites/default/files/media/2023-06/itow-introducing-desirable-difficulties-into-practice-and-instruction-bjork-and-bjork.pdf | **[TEXT]** | The storage-vs-retrieval-strength framework: the largest stability gains come from successful retrieval when retrieval strength is low — the rationale for reciting before revealing, and for not over-reviewing. Used in 04, 10. |
| Butler, A. C., Karpicke, J. D., & Roediger, H. L. III (2007). *The effect of type and timing of feedback on learning from multiple-choice tests.* Journal of Experimental Psychology: Applied, 13(4), 273–281. https://pubmed.ncbi.nlm.nih.gov/18194050/ | **[EXP]** | Delayed, correct-answer feedback maximises the benefit of testing — supports revealing the correct line *after* the recall attempt, not before. |
| Butler, A. C., & Roediger, H. L. III (2008). *Feedback enhances the positive effects and reduces the negative effects of multiple-choice testing.* Memory & Cognition, 36(3), 604–616. https://link.springer.com/article/10.3758/MC.36.3.604 | **[EXP]** | Feedback prevents errors from being learned — why the recite flow always shows the true text and a teacher's correction overrides a self-rating. |
| Karpicke, J. D., & Blunt, J. R. (2011). *Retrieval practice produces more learning than elaborative studying with concept mapping.* Science, 331(6018), 772–775. https://www.science.org/doi/10.1126/science.1199327 | **[EXP]** | Retrieval beats even effortful elaborative study — strong support for an app built on recall, not on re-reading or annotation. |
| Karpicke, J. D., Butler, A. C., & Roediger, H. L. III (2009). *Metacognitive strategies in student learning: Do students practise retrieval when they study on their own?* Memory, 17(4), 471–479. https://www.tandfonline.com/doi/abs/10.1080/09658210802647009 | **[OBS]** | Left alone, learners under-use retrieval and over-use re-reading — the justification for making recall the *default* flow rather than an option. |
| Karpicke, J. D., & Roediger, H. L. III (2008). *The critical importance of retrieval for learning.* Science, 319(5865), 966–968. https://www.science.org/doi/abs/10.1126/science.1152408 | **[EXP]** | Repeated retrieval, not repeated study, drives long-term retention — the headline experiment behind the whole flow. |
| Roediger, H. L. III, & Karpicke, J. D. (2006). *Test-enhanced learning: Taking memory tests improves long-term retention.* Psychological Science, 17(3), 249–255. https://journals.sagepub.com/doi/10.1111/j.1467-9280.2006.01693.x | **[EXP]** | The canonical testing-effect experiment — restudy wins short-term, testing wins long-term, which is the regime hifz lives in. |
| Roediger, H. L. III, & Karpicke, J. D. (2006). *The power of testing memory: Basic research and implications for educational practice.* Perspectives on Psychological Science, 1(3), 181–210. https://journals.sagepub.com/doi/abs/10.1111/j.1745-6916.2006.00012.x | **[TEXT]** | The authors' own review translating the testing effect into practice — plain-language grounding for the in-app explanation. |
| Rowland, C. A. (2014). *The effect of testing versus restudy on retention: A meta-analytic review of the testing effect.* Psychological Bulletin, 140(6), 1432–1463. https://www.researchgate.net/publication/264988491_The_Effect_of_Testing_Versus_Restudy_on_Retention_A_Meta-Analytic_Review_of_the_Testing_Effect | **[MA]** | The definitive meta-analysis (61 experiments, g ≈ 0.50, larger for free recall) — the README's pillar-3 anchor that *murājaʿa* as recall is the evidence-based core. Used in 04, 10, README. |
| Wheeler, M. A., Ewers, M., & Buonanno, J. F. (2003). *Different rates of forgetting following study versus test trials.* Memory, 11(6), 571–580. https://pubmed.ncbi.nlm.nih.gov/14982124/ | **[EXP]** | Tested material forgets more slowly than restudied material — the slower-decay benefit the scheduler banks on. |
| Zamary, A., & Rawson, K. A. (2019). *Why is free recall practice more effective than recognition practice for enhancing memory? Evaluating the relational processing hypothesis.* Journal of Memory and Language, 105, 141–152. https://www.sciencedirect.com/science/article/abs/pii/S0749596X19300026 | **[EXP]** | Free recall (producing from nothing) beats recognition — why the flow asks the user to recite the page, not pick from prompts. |

---

## 5. Interference & mutashābihāt

Why similar-verse confusion is **interference**, not decay, and why interleaved discrimination — not spacing — is the cure (PRD §9). The dominant failure mode for advanced ḥuffāẓ. Used in **05**.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Ahmad, A. M., Saleh, M. H., Musa, M. A., Alias, N., & Muhammad, K. A. (2021). *Methods of Memorizing Mutashabihat Verses: Study on Darul Quran, JAKIM and Department of al-Quran and al-Qiraat KUIS.* Jurnal Islam dan Masyarakat Kontemporari, 22(3), 77–85. https://doi.org/10.37231/jimk.2021.22.3.525 | **[OBS]** | Field study of how tahfiz institutions actually teach mutashābihāt — grounds the discrimination-drill design in current practice. |
| Anderson, M. C., Bjork, R. A., & Bjork, E. L. (1994). *Remembering can cause forgetting: Retrieval dynamics in long-term memory.* Journal of Experimental Psychology: Learning, Memory, and Cognition, 20(5), 1063–1087. https://bjorklab.psych.ucla.edu/wp-content/uploads/sites/13/2016/07/Anderson_RBjork_EBjork_1994.pdf | **[EXP]** | Retrieval-induced forgetting: recalling one competing associate suppresses its rivals — why confusable verses must be trained *together*, not in isolation. Used in 05, CLAIMS. |
| Anderson, M. C., & Neely, J. H. (1996). *Interference and inhibition in memory retrieval.* In E. L. Bjork & R. A. Bjork (Eds.), *Memory* (pp. 237–313). Academic Press. https://uwaterloo.ca/memory-attention-cognition-lab/sites/default/files/uploads/files/interference_theory_4_final_revised.pdf | **[TEXT]** | The authoritative review of interference and cue competition — the theoretical spine of the mutashābihāt subsystem. |
| Birnbaum, M. S., Kornell, N., Bjork, E. L., & Bjork, R. A. (2013). *Why interleaving enhances inductive learning: The roles of discrimination and retrieval.* Memory & Cognition, 41(3), 392–402. https://link.springer.com/article/10.3758/s13421-012-0272-7 | **[EXP]** | Interleaving works by forcing **discrimination** between confusable items — the direct evidence for back-to-back sibling review. Used in 05, CLAIMS. |
| Carvalho, P. F., & Goldstone, R. L. (2014). *Putting category learning in order: Category structure and temporal arrangement affect the benefit of interleaved over blocked study.* Memory & Cognition, 42(3), 481–495. https://link.springer.com/article/10.3758/s13421-013-0371-0 | **[EXP]** | Interleaving helps most when items are **highly similar** — exactly the mutashābihāt case, and a caution that it is not universally better. Used in 05, CLAIMS. |
| GetItQan. *What is Mutashabihat.* https://getitqan.com/blog/what-is-mutashabihat | **[TRAD]** | Plain definition of mutashābihāt and confirmation they are the leading advanced-ḥāfiẓ error source, worsening as more is memorized — the domain framing for the subsystem. |
| Kornell, N., & Bjork, R. A. (2008). *Learning concepts and categories: Is spacing the "enemy of induction"?* Psychological Science, 19(6), 585–592. https://journals.sagepub.com/doi/10.1111/j.1467-9280.2008.02127.x | **[EXP]** | For confusable categories, interleaving beats blocking — why spacing the siblings *apart* would worsen confusion. Used in 05, CLAIMS. |
| McGeoch, J. A. (1932). *Forgetting and the law of disuse.* Psychological Review, 39(4), 352–370. https://psycnet.apa.org/record/1932-04263-001 | **[CS]** | The foundational argument that forgetting is driven by **interference**, not mere disuse — the conceptual root of treating mutashābihāt as the enemy, not decay. |
| McGeoch, J. A., & McDonald, W. T. (1931). *Meaningful relation and retroactive inhibition.* American Journal of Psychology, 43(4), 579–588. https://www.jstor.org/stable/1415159 | **[CS]** | Similar material interferes more than dissimilar — the classic basis for "near-identical verses confuse most." |
| Müller, G. E., & Pilzecker, A. (1900). *Experimentelle Beiträge zur Lehre vom Gedächtnis.* (Origin of "retroactive inhibition.") https://en.wikipedia.org/wiki/Interference_theory | **[CS]** | The historical origin of retroactive inhibition and consolidation — context for why new, similar learning can damage old. |
| Osgood, C. E. (1949). *The similarity paradox in human learning: A resolution.* Psychological Review, 56(3), 132–143. https://psycnet.apa.org/record/1949-05293-001 | **[CS]** | The similarity gradient: interference scales with stimulus similarity — a principled way to score how confusable a mutashābihāt pair is. |
| Qari Mubashir. *You're Studying the Similar Verses Wrong.* How To Memorise The Quran (Substack). https://qari.substack.com/p/youre-studying-the-similar-verses | **[TRAD]** | Practitioner argument that siblings must be studied side-by-side on their distinguishing word — corroborates the anchor-hinting drill. |
| Underwood, B. J. (1957). *Interference and forgetting.* Psychological Review, 64(1), 49–60. https://psycnet.apa.org/record/1958-01239-001 | **[CS]** | Prior learning (proactive interference) explains much apparent forgetting — why a large memorized corpus increases, not decreases, confusion risk. |
| Wickens, D. D. (1973). *Some characteristics of word encoding.* Memory & Cognition, 1(4), 485–492. https://link.springer.com/article/10.3758/BF03198132 | **[EXP]** | Release from proactive interference when encoding shifts — supports using a distinguishing cue to break a confusion. |

*Plus, listed under Theme 10 because it is hifz-specific applied work:* Mohd Yusoff et al. (2022), *Tahfiz Education in Malaysia… Mutashabihat…* **[OBS]**.

---

## 6. Overlearning & lifelong retention

How near-100% retention is honestly achieved and bounded — overlearning to automaticity, successive relearning, and the permastore plateau (PRD §7.5). Used in **06**.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Bahrick, H. P., & Hall, L. K. (1991). *Lifetime maintenance of high school mathematics content.* Journal of Experimental Psychology: General, 120(1), 20–33. https://www.semanticscholar.org/paper/Lifetime-maintenance-of-high-school-mathematics-Bahrick-Hall/5bac650cdedcbf14cb4ebd2a88cc3e793ba81b55 | **[OBS]** | Decades-long maintenance of mastered content when over-learned — second pillar of the "permastore is real but earned" story. |
| Driskell, J. E., Willis, R. P., & Copper, C. (1992). *Effect of overlearning on retention.* Journal of Applied Psychology, 77(5), 615–622. https://www.scirp.org/reference/referencespapers?referenceid=2833379 | **[MA]** | Meta-analytic confirmation that overlearning improves retention but with **diminishing returns that decay over time** — why the app over-reviews to automaticity yet still re-schedules, never declaring a page "done." |
| Heathcote, A., Brown, S., & Mewhort, D. J. K. (2000). *The power law repealed: The case for an exponential law of practice.* Psychonomic Bulletin & Review, 7(2), 185–207. https://link.springer.com/article/10.3758/BF03212979 | **[EXP]** | The careful counter-case that individual practice curves are exponential, not power-law — cited for honesty about the automaticity-curve debate. |
| Logan, G. D. (1988). *Toward an instance theory of automatization.* Psychological Review, 95(4), 492–527. https://www.scirp.org/reference/referencespapers?referenceid=1095590 | **[EXP]** | Automaticity comes from accumulating retrieval instances — the mechanism behind "recite a page enough times and it becomes effortless." |
| Newell, A., & Rosenbloom, P. S. (1981). *Mechanisms of skill acquisition and the law of practice.* In J. R. Anderson (Ed.), *Cognitive Skills and Their Acquisition* (pp. 1–55). Erlbaum. https://en.wikipedia.org/wiki/Power_law_of_practice | **[TEXT]** | The power law of practice — speed and fluency improve predictably with reps, supporting fluency (speed) as a grading signal. |
| Rawson, K. A., & Dunlosky, J. (2011). *Optimizing schedules of retrieval practice for durable and efficient learning: How much is enough?* Journal of Experimental Psychology: General, 140(3), 283–302. https://www.researchgate.net/publication/51251736_Optimizing_Schedules_of_Retrieval_Practice_for_Durable_and_Efficient_Learning_How_Much_Is_Enough | **[EXP]** | How many correct recalls per session, then relearning to criterion, gives durable efficient retention — informs the sign-off-to-graduate thresholds. |
| Rawson, K. A., Vaughn, K. E., Walsh, M., & Dunlosky, J. (2018). *Investigating and explaining the effects of successive relearning on long-term retention.* Journal of Experimental Psychology: Applied, 24(1), 57–71. https://pubmed.ncbi.nlm.nih.gov/29431462/ | **[EXP]** | **Successive relearning** (spaced retrieval to a criterion, repeated across sessions) is the exact mechanism of *murājaʿa* — the strongest match between the literature and the traditional cycle. |
| Rohrer, D., Taylor, K., Pashler, H., Wixted, J. T., & Cepeda, N. J. (2005). *The effect of overlearning on long-term retention.* Applied Cognitive Psychology, 19(4), 361–374. https://onlinelibrary.wiley.com/doi/abs/10.1002/acp.1083 | **[EXP]** | Overlearning's benefit shrinks over long retention intervals — the honest caveat that extra same-session reps are no substitute for spaced revision. |

*Also drawn on here:* Bahrick (1984) **[OBS]**, Nelson (1985) **[EXP]** — listed under Theme 1; Bahrick et al. (1993) — under Theme 2; the Anki/FSRS optimal-retention docs — under Theme 3.

---

## 7. Serial recall & the page unit

Why the muṣḥaf **page** is the scheduled unit — recited in chained flow, not atomized into verse-cards — and the chunking/working-memory limits behind it (PRD §7.1, §6.1). Used in **07**.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Baddeley, A. (2003). *Working memory: Looking back and looking forward.* Nature Reviews Neuroscience, 4(10), 829–839. https://www.nature.com/articles/nrn1201 | **[TEXT]** | The working-memory architecture (phonological loop) underlying verbatim verbal recall — why recitation is a phonological, sequential act. |
| Chase, W. G., & Simon, H. A. (1973). *Perception in chess.* Cognitive Psychology, 4(1), 55–81. https://andymatuschak.org/prompts/Chase1973.pdf | **[EXP]** | Expertise is built from large, meaningful **chunks** — the basis for treating a whole page as one recited unit for an experienced ḥāfiẓ. |
| Cowan, N. (2001). *The magical number 4 in short-term memory: A reconsideration of mental storage capacity.* Behavioral and Brain Sciences, 24(1), 87–114. https://www.cambridge.org/core/services/aop-cambridge-core/content/view/44023F1147D4A1D44BDC0AD226838496/S0140525X01003922a.pdf/the-magical-number-4-in-short-term-memory-a-reconsideration-of-mental-storage-capacity.pdf | **[CS]** | The ~4-chunk working-memory limit — why material must be chunked into pages/lines, not held as 6,236 independent ayāt. |
| Cowan, N., & Elliott, E. M. (2022). *Deconfounding serial recall: Response timing and the overarching role of grouping.* Journal of Experimental Psychology: Learning, Memory, and Cognition, 49(2), 249–268. https://pmc.ncbi.nlm.nih.gov/articles/PMC10028597/ | **[EXP]** | Grouping (e.g., into lines) governs serial-recall accuracy and timing — supports line-level weak-spot localization within the page. Used in 07, CLAIMS. |
| Ericsson, K. A., Chase, W. G., & Faloon, S. (1980). *Acquisition of a memory skill.* Science, 208(4448), 1181–1182. https://www.science.org/doi/10.1126/science.7375930 | **[EXP]** | Memory span expands hugely through learned chunking strategies — evidence that a ḥāfiẓ's page-level recall is a trained skill, not raw span. |
| Ericsson, K. A., & Kintsch, W. (1995). *Long-term working memory.* Psychological Review, 102(2), 211–245. https://www.researchgate.net/publication/15452779_Long-Term_Working_Memory | **[TEXT]** | Experts use long-term working memory to hold far more than short-term limits allow — why a ḥāfiẓ can recite a page continuously. |
| Henson, R. N. A., Norris, D. G., Page, M. P. A., & Baddeley, A. D. (1996). *Unchained memory: Error patterns rule out chaining models of immediate serial recall.* Quarterly Journal of Experimental Psychology A, 49(1), 80–115. https://journals.sagepub.com/doi/10.1080/713755612 | **[EXP]** | Serial recall is **positional**, not a simple item-to-item chain — refines how the engine localizes a stumble within a page. Used in 07, CLAIMS. |
| Lashley, K. S. (1951). *The problem of serial order in behavior.* In L. A. Jeffress (Ed.), *Cerebral Mechanisms in Behavior* (pp. 112–136). Wiley. (Analyzed in Rosenbaum et al., 2007, *Human Movement Science*, 26(4), 525–554.) https://www.academia.edu/4453729/The_problem_of_serial_order_in_behavior_Lashley_s_legacy | **[CS]** | The classic statement that ordered behavior needs a hierarchical plan — why recitation is structured, not a reflex chain. |
| Miller, G. A. (1956). *The magical number seven, plus or minus two: Some limits on our capacity for processing information.* Psychological Review, 63(2), 81–97. https://psychclassics.yorku.ca/Miller/ | **[CS]** | The founding chunk-capacity result — historical anchor for chunking the muṣḥaf into manageable units. |
| Rubin, D. C. (1995). *Memory in Oral Traditions: The Cognitive Psychology of Epic, Ballads, and Counting-out Rhymes.* Oxford University Press. https://academic.oup.com/book/53811 | **[TEXT]** | How oral traditions use rhythm, meter, and cueing for verbatim recall — directly relevant to Quranic recitation and to honoring the page's flow. |
| Ryan, J. (1969). *Grouping and short-term memory: Different means and patterns of grouping.* Quarterly Journal of Experimental Psychology, 21(2), 137–147. https://journals.sagepub.com/doi/10.1080/14640746908400206 | **[EXP]** | Temporal grouping aids serial recall — supports the line as a natural sub-unit of the page. Used in 07, CLAIMS. |
| SisterNourhan Academy. *Quran Memorization — The Complete Guide to Hifz the Holy Quran.* https://sisternourhan.academy/blog/quran-memorization/quran-memorization | **[TRAD]** | The verse-chaining ("1, 1–2, 1–2–3 …") connecting method where each verse cues the next — the traditional practice that matches serial-recall theory. |
| Solway, A., Murdock, B. B., & Kahana, M. J. (2012). *Positional and temporal clustering in serial order memory.* Memory & Cognition, 40(2), 177–190. https://pmc.ncbi.nlm.nih.gov/articles/PMC3282556/ | **[EXP]** | Recall clusters by position and time — corroborates positional models of where within a page errors fall. Used in 07, CLAIMS. |
| Szmalec, A., Duyck, W., Vandierendonck, A., Barberá Mata, A., & Page, M. P. A. (2009). *The Hebb repetition effect as a laboratory analogue of novel word learning.* Quarterly Journal of Experimental Psychology, 62(3), 435–443. https://pubmed.ncbi.nlm.nih.gov/18785073/ | **[CS]** | The Hebb repetition effect: a repeated sequence becomes a stored long-term unit — the lab analogue of memorizing a page through repetition. (Originates Hebb, D. O., 1961, *Distinctive features of learning in the higher animal*; reviewed here.) Used in 07, CLAIMS. |

---

## 8. Sleep & consolidation

Why the engine schedules in whole days and honors a once-daily revision rhythm — sleep-dependent consolidation and sleep's protection against interference (PRD §7, day-grained scheduling). Used in **08**.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Bell, M. C., Kawadri, N., Simone, P. M., & Wiseheart, M. (2014). *Long-term memory, sleep, and the spacing effect.* Memory, 22(3), 276–283. https://doi.org/10.1080/09658211.2013.778294 | **[EXP]** | Sleep within the spacing gap strengthens the spacing benefit — support for day-spanning intervals over within-day massing. |
| Berres, S., & Erdfelder, E. (2021). *The sleep benefit in episodic memory: An integrative review and a meta-analysis.* Psychological Bulletin, 147(12), 1309–1353. https://doi.org/10.1037/bul0000350 | **[MA]** | The definitive quantification of the sleep benefit for memory — the strongest evidence that "a night between reviews" matters, hence whole-day scheduling. |
| Diekelmann, S., & Born, J. (2010). *The memory function of sleep.* Nature Reviews Neuroscience, 11(2), 114–126. https://doi.org/10.1038/nrn2762 | **[TEXT]** | The mechanism of active systems consolidation during sleep — the plain explanation for why revision is "slept on." |
| Ellenbogen, J. M., Hulbert, J. C., Stickgold, R., Dinges, D. F., & Thompson-Schill, S. L. (2006). *Interfering with theories of sleep and memory: Sleep, declarative memory, and associative interference.* Current Biology, 16(13), 1290–1294. https://www.sciencedirect.com/science/article/pii/S0960982206016071 | **[EXP]** | Sleep protects memories against later interference — directly relevant to stabilizing mutashābihāt-prone pages overnight. |
| Gais, S., Lucas, B., & Born, J. (2006). *Sleep after learning aids memory recall.* Learning & Memory, 13(3), 259–262. https://learnmem.cshlp.org/content/13/3/259.full.html | **[EXP]** | Sleeping soon after learning improves later recall — supports an evening-or-before-sleep revision rhythm. |
| Hu, X., Cheng, L. Y., Chiu, M. H., & Paller, K. A. (2020). *Promoting memory consolidation during sleep: A meta-analysis of targeted memory reactivation.* Psychological Bulletin, 146(3), 218–244. https://doi.org/10.1037/bul0000223 | **[MA]** | Meta-analytic evidence that reactivation during sleep strengthens memory — reinforces consolidation as a real, scheduled-around process (the app does not attempt TMR; it simply respects the day boundary). |
| Jenkins, J. G., & Dallenbach, K. M. (1924). *Obliviscence during sleep and waking.* The American Journal of Psychology, 35(4), 605–612. https://www.jstor.org/stable/1414040 | **[CS]** | The classic demonstration that less is forgotten across sleep than across equivalent waking — the founding sleep-and-memory result. |
| Mazza, S., Gerbier, E., Gustin, M.-P., Kasikci, Z., Koenig, O., Toppino, T. C., & Magnin, M. (2016). *Relearn faster and retain longer: Along with practice, sleep makes perfect.* Psychological Science, 27(10), 1321–1330. https://doi.org/10.1177/0956797616659930 | **[EXP]** | Interleaving sleep between study sessions both speeds relearning and improves retention — the clean evidence for spacing reviews across nights. |

---

## 9. Motivation without coercion

The evidence *against* streaks, badges, leaderboards, and guilt for sacred, intrinsically-motivated work — and for calm, non-coercive framing (PRD §C6, R3). Used in **09**, with the guilt and transparency findings feeding **11**.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Allport, G. W., & Ross, J. M. (1967). *Personal religious orientation and prejudice.* Journal of Personality and Social Psychology, 5(4), 432–443. https://psycnet.apa.org/record/1968-00339-001 | **[CS]** | The intrinsic-vs-extrinsic religious-orientation distinction — frames hifz as intrinsically motivated worship the app must not crowd out. |
| British Psychological Society Research Digest. *How to form a habit* (summary of Lally et al., 2010, incl. the negligible effect of a single missed day). https://www.bps.org.uk/research-digest/how-form-habit | **[TEXT]** | Accessible confirmation that one missed day does not derail a forming habit — the evidence basis for "missed-day catch-up, never shame." |
| Deci, E. L., Koestner, R., & Ryan, R. M. (1999). *A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation.* Psychological Bulletin, 125(6), 627–668. https://home.ubalt.edu/tmitch/642/articles%20syllabus/Deci%20Koestner%20Ryan%20meta%20IM%20psy%20bull%2099.pdf | **[MA]** | The 128-experiment meta-analysis: tangible, expected rewards undermine intrinsic motivation — the README's pillar-6 anchor and the reason no XP/badges touch recitation. (Also mirrored at https://www.researchgate.net/publication/12712628.) Used in 09, 11, README. |
| Kabir, M., Kabir, M. R., & Islam, R. S. (2024/2025). *Islamic lifestyle applications: Meeting the spiritual needs of modern Muslims.* International Journal of Human–Computer Interaction (preprint arXiv:2402.02061; DOI 10.1080/10447318.2025.2595545). https://arxiv.org/abs/2402.02061 | **[OBS]** | User research showing discomfort with transactional/gamified spiritual apps and paywalled worship — empirical support for calm, free, non-gamified design. |
| Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). *How are habits formed: Modelling habit formation in the real world.* European Journal of Social Psychology, 40(6), 998–1009. https://onlinelibrary.wiley.com/doi/abs/10.1002/ejsp.674 | **[OBS]** | Habits form over ~weeks (median ~66 days) and survive an occasional lapse — the basis for a gentle daily cue, not streak pressure. Used in 09, CLAIMS. |
| Lepper, M. R., Greene, D., & Nisbett, R. E. (1973). *Undermining children's intrinsic interest with extrinsic reward: A test of the "overjustification" hypothesis.* Journal of Personality and Social Psychology, 28(1), 129–137. https://psycnet.apa.org/record/1974-10497-001 | **[EXP]** | The overjustification effect — adding extrinsic rewards reduces later intrinsic engagement, a concrete reason to keep worship reward-free. |
| Mekler, E. D., Brühlmann, F., Tuch, A. N., & Opwis, K. (2017). *Towards understanding the effects of individual gamification elements on intrinsic motivation and performance.* Computers in Human Behavior, 71, 525–534. https://www.sciencedirect.com/science/article/abs/pii/S0747563215301229 | **[EXP]** | Points/levels/leaderboards raise output without raising intrinsic motivation — they are pressure, not joy; reason to omit them. |
| Peng, W., Huang, Q., Mao, B., Lun, D., Malova, E., Simmons, J. V., & Carcioppolo, N. (2023). *When guilt works: A comprehensive meta-analysis of guilt appeals.* Frontiers in Psychology, 14, 1201631. https://pubmed.ncbi.nlm.nih.gov/37842697/ | **[MA]** | Strong guilt appeals backfire (reactance) — the evidence behind neutral notification copy ("Your revision for today is ready"), never fear. (Also at https://pmc.ncbi.nlm.nih.gov/articles/PMC10568480/.) Used in 09, 11. |
| Ryan, R. M., & Deci, E. L. (2000). *Self-determination theory and the facilitation of intrinsic motivation, social development, and well-being.* American Psychologist, 55(1), 68–78. https://pubmed.ncbi.nlm.nih.gov/11392867/ | **[TEXT]** | Autonomy, competence, and relatedness as the supports for durable motivation — the frame for a calm tool that serves the user's own goal. |
| Tangney, J. P., Stuewig, J., & Mashek, D. J. (2007). *Moral emotions and moral behavior.* Annual Review of Psychology, 58, 345–372. https://www.its.caltech.edu/~squartz/Tangney.pdf | **[TEXT]** | Guilt-vs-shame: shame is corrosive and disengaging — why progress is shown as a calm heat-map, never a shaming streak. |
| Zainuddin, Z., et al. (2023). *Gamification enhances student intrinsic motivation, perceptions of autonomy and relatedness, but minimal impact on competency: A meta-analysis and systematic review.* Educational Technology Research and Development, 71, 2477–2509. https://link.springer.com/article/10.1007/s11423-023-10337-7 | **[MA]** | Even where gamification helps, the competency gains are minimal — net argument against gamifying the core hifz work. |

---

## 10. Traditional hifz methodology & Islamic sources

The classical *sabaq / sabqi / manzil* workflow, the seven manāzil weekly khatm, *talaqqī* and the *sanad* chain, and the prophetic basis for both decay and intention — sourced to named books, sites, and hadith with collection and number (PRD §4, §10). The app **surfaces methodology, never issues a fiqh ruling**; mutashābihāt and methodology content awaits named scholarly sign-off (PRD §21). Used in **10**.

### Hadith and prophetic sources

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| *Ṣaḥīḥ al-Bukhārī* 1 (ʿUmar ibn al-Khaṭṭāb), Book 1, Ḥadīth 1: "Actions are but by intentions." Sunnah.com. https://sunnah.com/bukhari:1 | **[TRAD]** | The intention (*niyya*) basis for framing the app as worship done lillāh — supports non-coercive, reward-free motivation. (Also *Ṣaḥīḥ Muslim* 1907, https://sunnah.com/muslim:1907.) Used in 09, 11. |
| *Ṣaḥīḥ al-Bukhārī* 4998 (Abū Hurayra), Book 66, Ḥadīth 20: Gabriel reviewed the Quran with the Prophet ﷺ yearly, twice in the final year (*al-ʿarḍa al-akhīra*). Sunnah.com. https://sunnah.com/bukhari:4998 | **[TRAD]** | Prophetic precedent for **periodic full review** — the traditional warrant for a recurring khatm/manzil cycle. |
| *Ṣaḥīḥ al-Bukhārī* 5032 (ʿAbdullāh ibn Masʿūd), Book 66, Ḥadīth 54: the Quran escapes the memory faster than tethered camels. Sunnah.com. https://sunnah.com/bukhari:5032 | **[TRAD]** | The prophetic statement of the decay axiom — the README's pillar-4 anchor that the whole product answers to. Used in 01, 10, README. |
| *Ṣaḥīḥ Muslim* 791 (Abū Mūsā al-Ashʿarī), agreed upon: the Qur'an slips away faster than camels escaping their tying ropes. Encyclopedia of Translated Prophetic Hadiths (HadeethEnc 5907). https://hadeethenc.com/en/browse/hadith/5907 | **[TRAD]** | The parallel, agreed-upon narration of the decay axiom — corroborates Bukhārī 5032 with a second collection and number. |

### Methodology and scholarship

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| Dzulkifli, M. A., Bin Abdul Rahman, A. W., Badi, J. A., & Solihu, A. K. (2016). *Routes to Remembering: Lessons from al Huffaz.* Mediterranean Journal of Social Sciences, 7(3 S1), 121–128. https://www.richtmann.org/journal/index.php/mjss/article/view/9090 | **[OBS]** | Empirical study of how ḥuffāẓ actually memorize and revise — grounds the three-track design in observed practice. |
| Dzulkifli, M. A., & Solihu, A. K. H. (2018). *Methods of Qur'anic Memorisation (Hifz): Implications for Learning Performance.* Intellectual Discourse, 26(2), 931–947. https://journals.iium.edu.my/intdiscourse/index.php/islam/article/view/1238 | **[OBS]** | Comparative methods study linking repetition/revision intensity to retention — support for the murājaʿa-heavy design. |
| Famibisyauqin. *Fami Bi Syauqin: Mengkhatamkan Al-Qur'an dalam 7 Hari.* https://famibisyauqin.blogspot.com/2016/02/fami-bi-syauqin-mengkhatamkan-al-quran.html | **[TRAD]** | The "Fa-mī bi-shawqin" mnemonic for the seven manāzil — the source of the 7-manzil weekly khatm preset's structure. |
| GetItQan. *What is Mutashabihat.* https://getitqan.com/blog/what-is-mutashabihat | **[TRAD]** | (Listed in Theme 5.) Domain framing for the mutashābihāt subsystem. |
| How To Memorise The Qur'an. *The Ottoman Hifz Method.* https://howtomemorisethequran.com/the-ottoman-hifz-method/ | **[TRAD]** | The Ottoman page-stacking method — a regional tradition informing the localizable term-sets and cycle shapes. |
| How To Memorise The Qur'an (Medium). *The Takrār Method of Memorisation in Madīnah al-Munawwarah.* https://medium.com/how-to-memorise-the-quran/the-takrar-method-of-memorisation-in-madinah-al-munawwarah-schedules-62fe4a8d1179 | **[TRAD]** | The Madinah takrār (repetition) schedules — a concrete daily-load reference for the cycle presets. |
| *Ijazah.* Wikipedia. https://en.wikipedia.org/wiki/Ijazah | **[TRAD]** | The ijāza/sanad chain of transmission back to the Prophet ﷺ — the basis for treating teacher sign-off as authoritative and the app as a servant to the sanad. |
| Ilmify. *Muraja'ah in Hifz: The Complete Quran Revision Guide.* https://ilmify.app/blog/what-is-murajaah-quran-revision/ | **[TRAD]** | A full description of murājaʿa practice (old-before-new, daily minimums) — practitioner grounding for the daily-session order. |
| Ilmify. *Sabak, Sabaq Para, and Dhor: Understanding the 3 Stages of Hifz Revision.* https://ilmify.app/blog/sabak-sabaq-para-dhor-hifz-stages/ | **[TRAD]** | The three-stage vocabulary and how pages move between stages — the source for the New / Near / Far lifecycle. |
| IslamicTuition. *Sabaq, Sabqi and Manzil — The Hifz Revision System Explained.* https://islamictuition.us/blog/sabaq-sabqi-manzil-hifz-revision-system/ | **[TRAD]** | A second independent description of the sabaq/sabqi/manzil system — corroborates the track definitions and regional terms. |
| *Manzil (Quran division).* Wikipedia. https://en.wikipedia.org/wiki/Manzil | **[TRAD]** | The seven manāzil division (attributed to Ḥamzah az-Zayyāt) and the "Fa-mī bi-shawqin" mnemonic — the structure of the weekly-khatm preset. |
| Mohamad, N., & Mohamad, M. *Concept and Execution of Talaqqi and Musyafahah Method in Learning Al-Quran.* Academia.edu. https://www.academia.edu/81052538/Concept_and_Execution_of_Talaqqi_and_Musyafahah_Method_in_Learning_Al_Quran | **[TRAD]** | The talaqqī/mushāfaha (face-to-face oral) method — the basis for teacher sign-off being first-class and overriding the algorithm. |
| Mohd Yusoff, M. Y. Z., et al. (2022). *Tahfiz Education in Malaysia: Issues and Problems in Memorising Quranic Mutashabihat Verses and its Solution.* IJARBSS, 12(1). https://hrmars.com/papers_submitted/10821/tahfiz-education-in-malaysia-issues-and-problems-in-memorising-quranic-mutashabihat-verses-and-its-solution.pdf | **[OBS]** | Applied evidence that mutashābihāt are a top reported difficulty in real tahfiz programs — demand validation for the discrimination trainer. |
| Nordin, O., Nik Abdullah, N. Md. S. A., Omar, R. A. M. I., & Abdullah, A. N. (2023). *The Art of Quranic Memorization: A Meta-Analysis.* Pertanika Journal of Social Sciences & Humanities, 31(2), 787–801. https://www.pertanika.upm.edu.my/resources/files/Pertanika%20PAPERS/JSSH%20Vol.%2031%20(2)%20Jun.%202023/16%20JSSH-8758-2022.pdf | **[OBS]** | A synthesis of hifz-method studies — independent grounding that repetition, revision, and teacher correction are the consensus pillars. |
| Qari Mubashir. *You're Studying the Similar Verses Wrong.* How To Memorise The Quran (Substack). https://qari.substack.com/p/youre-studying-the-similar-verses | **[TRAD]** | (Listed in Theme 5.) Practitioner method for studying mutashābihāt side-by-side. |
| SisterNourhan Academy. *Quran Memorization — The Complete Guide to Hifz the Holy Quran.* https://sisternourhan.academy/blog/quran-memorization/quran-memorization | **[TRAD]** | (Listed in Theme 7.) The verse-chaining connecting method. |
| Tarteel. *Quran Memorization Techniques: The Mauritanian Method.* https://tarteel.ai/blog/quran-memorization-techniques-the-mauritanian-method/ | **[TRAD]** | The Mauritanian *luh* (slate) method — a regional tradition informing term-sets and the breadth of recognized workflows. |

---

## 11. Trust, transparency & the in-app science screen

Sources behind the "The science we follow" screen — how to attribute claims credibly, in plain language, accessibly (PRD §12.5, R-series trust). Used in **11**, with motivation/guilt sources shared from Theme 9.

| Source | Grade | What the app takes from it |
|--------|-------|----------------------------|
| American Press Institute. *How publishers should build credibility through transparency.* https://americanpressinstitute.org/transparency-credibility/ | **[OBS]** | Transparency about sources builds trust — the rationale for surfacing every claim's named source on the science screen. |
| Otis, A. (2024). *The effects of transparency cues on news source credibility online: An investigation of "opinion labels."* Journalism. https://journals.sagepub.com/doi/10.1177/14648849221129001 | **[OBS]** | Labeling the *nature* of a claim (evidence vs. opinion) raises perceived credibility — supports showing grades/source-types, not star ratings. |
| U.S. General Services Administration / Digital.gov (formerly PlainLanguage.gov). *Federal Plain Language Guidelines.* https://digital.gov/guides/plain-language (healthcare guidance: https://www.plainlanguage.gov/resources/content-types/healthcare/) | **[TEXT]** | Plain-language standards for explaining evidence to non-experts — the writing standard for the science screen's calm, jargon-free copy. |
| W3C. (2024). *Web Content Accessibility Guidelines (WCAG) 2.2.* W3C Recommendation, 12 December 2024. https://www.w3.org/TR/WCAG22/ (SC 1.4.1 Use of Color; SC 1.4.3 Contrast (Minimum)) | **[TEXT]** | Never relying on color alone and meeting contrast minimums — the accessibility floor for the heat-map and the science screen (PRD §18). |

---

## Status

- **Version:** v1.0 — June 2026. The deduplicated master for the initial complete science foundation.
- **Scope:** Every source cited in `01`–`11`, [`README.md`](README.md), and [`CLAIMS.md`](CLAIMS.md) appears here exactly once (cross-uses noted). Where a citation's edition or mirror URL varied across docs, the canonical, most-verifiable form is used.
- **Verification:** All entries are real and were verified against PubMed, DOI/publisher pages, primary PDFs, or — for hadith — Sunnah.com / HadeethEnc with collection, number, and grading. We never fabricate a citation, DOI, author list, or URL.
- **Maintenance:** Corrections are submitted as issues against the open-source repository and versioned with the app. Traditional, methodology, and mutashābihāt sources (Theme 10, and the [TRAD]/[OBS] entries in Theme 5) await named scholarly sign-off (PRD §21); until then, the app's copy stays framed as an aid to revision and a servant to the teacher, and issues **no fiqh ruling**.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
