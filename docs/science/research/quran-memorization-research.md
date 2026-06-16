# Quran-Memorization (Hifz) Research

**Topic:** Academic and applied research *specifically* on Quran memorization — memorization methods, retention and maintenance (murājaʿa), the cognition and neuroscience of huffaz, the interference problem of mutashābihāt, and the educational/well-being outcomes of hifz. This note gathers the hifz-specific empirical literature; the general memory-science notes (forgetting curve, spacing, retrieval practice, interference, overlearning) live in their own sibling files and supply the mechanisms behind what the hifz studies observe.

**Compiled:** 2026-06-16

A standing caveat for this whole literature: the hifz-specific empirical base is **young, small-n, and methodologically uneven**. Most studies are observational/cross-sectional, run in a single institution, and use convenience samples; almost none randomize, and self-selection (who becomes a ḥāfiẓ) is a pervasive confound. We therefore grade most of it `[OBS]` and lean on the larger, stronger general memory-science literature for any *mechanism* claim. Where a hifz study merely illustrates a mechanism that the strong literature already establishes, we say so rather than over-claiming from the weaker source.

---

## What the evidence says

### 1. The literature's own headline gap is *maintenance*, not memorization — which is exactly this app's thesis

A 2023 meta-analysis of 20 open-access Quran-memorization studies (2016–2021) found "a high research interest relating to methods of Quranic memorization" but concluded that "less research has been conducted on sustaining Quranic memorization… Simply memorizing the Quran is not enough; it is essential to maintain memorization" ([Nordin et al., 2023](https://www.pertanika.upm.edu.my/resources/files/Pertanika%20PAPERS/JSSH%20Vol.%2031%20(2)%20Jun.%202023/16%20JSSH-8758-2022.pdf)). The same applied gap appears in the field literature: revision (murājaʿa) is repeatedly named as "more than half the work," yet the tooling and the research both over-serve the *new* memorizer and under-serve the finished ḥāfiẓ fighting decay (the competitive-landscape and methodology findings in `research/RESEARCH-FINDINGS.md`).

- The meta-analysis is itself observational (a content/frequency synthesis, not pooled effect sizes), so we cite it for *what the field studies and neglects*, not for a quantitative retention effect.
- This is the single most load-bearing finding for the product: an entire scholarly literature naming the exact problem the app exists to solve, and naming it as under-built.

### 2. Traditional hifz methodology is, structurally, hand-tuned spaced repetition + retrieval practice

The classical three-track system — **sabaq** (new lesson), **sabqi** (recent revision), **manzil/dhor** (whole-Quran maintenance), recited *old-before-new* — maps cleanly onto expanding-interval spaced repetition and onto recall-based (production) retrieval practice ([Dzulkifli & Solihu, 2018](https://journals.iium.edu.my/intdiscourse/index.php/islam/article/view/1238); methodology synthesis in `research/RESEARCH-FINDINGS.md`).

- The famous heuristics — the 7-manzil weekly khatm, the "1 juz/day minimum," the 30/15/10-day cycles, the ~5:1 review-to-new ratio, and day-1/2/4/7/14-then-monthly intervals — are fixed approximations of an adaptive expanding-interval schedule ([RESEARCH-FINDINGS §1, §3]).
- Recitation is always **production from memory** (serial recall of an ordered sequence), not recognition; this is why the general retrieval-practice and serial-recall literatures, not the flashcard-recognition literature, are the right mechanism base (see sibling notes; serial-recall structure summarized in `research/RESEARCH-FINDINGS §3`).
- "It is maintenance and not elaborative rehearsal that plays the most important role in the memorization of the Quran" — an interview/survey study of huffaz found that the strongest predictors of memorizing ability were self-efficacy, goal-setting, and disciplined *maintenance* rehearsal rather than meaning-elaboration ([Dzulkifli, Bin Abdul Rahman, Badi & Solihu, 2016](https://www.richtmann.org/journal/index.php/mjss/article/view/9090)).

### 3. Mutashābihāt (near-identical passages) are the dominant *interference* failure mode, empirically the hardest part of hifz

In a survey of 368 tahfiz students at two Malaysian institutions, **more than 60% could not clearly remember the mutashābihāt verses**, and the same majority agreed that the near-identical passages in Sūrat al-Wāqiʿah and Sūrat Yāsīn cause confusion — students "accidentally move from one surah to another" because of them ([Mohd Yusoff et al., 2022](https://hrmars.com/papers_submitted/10821/tahfiz-education-in-malaysia-issues-and-problems-in-memorising-quranic-mutashabihat-verses-and-its-solution.pdf)).

- The study identifies concrete causes: no specific reference book to *identify* mutashābihāt, and too little focus on them in tasmīʿ (recitation-check) sessions. Its top recommended fix is to **identify the similar passages before memorizing** and drill the distinguishing words — i.e. deliberate discrimination training.
- This is interference, not decay: it *worsens as the corpus grows* (more passages to confuse), the opposite signature of a forgetting curve. No classic spaced-repetition algorithm models cross-item interference, so this needs an explicit discrimination mechanism rather than a faster interval (mechanism detail in `research/RESEARCH-FINDINGS §3`; the general interference/interleaving evidence is in the sibling note).
- Caveat: this is single-region, self-report data; it establishes that mutashābihāt are *perceived and reported* as the leading difficulty, not a measured error rate. It is strong enough to justify a first-class subsystem, not strong enough to specify drill dosage.

### 4. Hifz training is associated with measurable gains in verbal and visual memory, attention, and fluency

A pre/post quasi-experimental study of 33 Turkish secondary-school students (18 female, 15 male) in a formal Quran-memorization program administered a four-test neuropsychological battery (California Verbal Learning Test–children's, Wechsler Memory Scale–revised visual reproduction, Trail Making Test, Verbal Fluency) before training and again 5½–8 months later. It found **statistically significant improvement (p < 0.05–0.001) in immediate and delayed verbal recall, immediate and delayed visual reproduction, attention/processing speed (Trail Making A and B), and phonemic and semantic fluency** ([Şirin, Metin & Tarhan, 2021](http://www.jnbs.org/uploads/files/104103jnbsjnbs-42-20_en.pdf)).

- Notably, the sample did **not know Arabic**, so the verbal-fluency gains are attributed to the *sound-oriented* (phonemic) rehearsal of the text rather than semantic processing — consistent with hifz being maintenance-rehearsal-heavy (finding 2).
- Design caveats are real: no untrained control group (it is a within-subjects pre/post design), modest n, and self-selected enrollees, so "Quran memorization causes general cognitive gains" overstates it. We grade it `[OBS]` and read it as *consistent with* the strong general finding that extensive structured retrieval practice trains working memory and attention.

### 5. Structural-neuroimaging studies find more preserved brain tissue and grey-matter differences in huffaz — suggestive, not causal

Two MRI studies converge directionally:

- A comparative MRI study of 63 healthy adults (ages 35–80; 19 complete memorizers, 28 partial, 16 controls) found that those who memorized scripture had **more grey and white matter preserved** than non-memorizers, with no significant age difference between groups (p > 0.50); the authors concluded that "engaging our brains by memorizing scripture may increase brain health" ([Rahman, Aribisala, Ullah & Omer, 2020](https://pubmed.ncbi.nlm.nih.gov/32214278/)).
- A voxel-based-morphometry (VBM) study followed 28 volunteers (14 male) through one year of textual-memory training on a 1.5-T MRI and reported grey-matter-volume differences in memorizers versus controls across regions tied to memory, language, and recognition ([Sapuan, Mustofa, Azemin, Majid & Jamaludin, 2015](https://link.springer.com/chapter/10.1007/978-981-10-0266-3_8)).
- These are small, cross-sectional or short-longitudinal samples with severe self-selection confounds; they show *association*, and the field itself warns that "various confounding factors can influence structural and neuronal changes." They are interesting context for the dignity of the practice, **not** a basis for any in-app "grows your brain" claim. Grade `[OBS]`.

### 6. Hifz attainment correlates with academic performance, but the effect is modest and confounded

- In 83 secondary tahfiz students in Pahang, Malaysia, hifz performance correlated positively with overall academic achievement, **explaining ~22% of the variance**, with female students outperforming males on hifz ([Tarmuji, Mohamed, Hazudin & Wan Ahmad, 2022](http://apjee.usm.my/APJEE_37_1_2022/apjee37012022_9.pdf)).
- An earlier study of 36 participants reported that completing hifz was associated with later academic achievement, attributing it to enhanced memory capacity ([Nawaz & Jahangir, 2015](https://www.researchgate.net/publication/282467544_Effects_of_Memorizing_Quran_by_Heart_Hifz_On_Later_Academic_Achievement)).
- A controlled recall experiment with 100 Saudi high-schoolers (50 huffadh, 50 non-huffadh) on English- and Arabic-word-list recall found short-term recall **differed between groups**, suggesting hifz is associated with better short-term recall ([Khan & Dzulkifli, 2021](https://journal.iainlangsa.ac.id/index.php/inspira/article/view/2934)).
- Read together cautiously: small samples, correlational designs, and powerful selection effects (motivated, disciplined, well-supported students disproportionately complete hifz). The honest reading is "associated with," never "causes." We will not put an academic-performance promise in the product.

### 7. Effective *methods* converge on talaqqī (oral teacher correction), repetition/murājaʿa, and multisensory encoding

Across the methods literature, the techniques repeatedly identified as effective are: **talaqqī/musyāfaha** (face-to-face recitation to a teacher who corrects, in the canonical five steps: explain → teacher recites → models correct reading → student imitates → teacher evaluates and corrects), **structured repetition and spaced murājaʿa**, **chunking** (memorizing in small line-blocks), and **multisensory encoding** combining hearing (samāʿī), sight, and articulation ([Dzulkifli & Solihu, 2018](https://journals.iium.edu.my/intdiscourse/index.php/islam/article/view/1238); [Nordin et al., 2023](https://www.pertanika.upm.edu.my/resources/files/Pertanika%20PAPERS/JSSH%20Vol.%2031%20(2)%20Jun.%202023/16%20JSSH-8758-2022.pdf); methods synthesis in `research/RESEARCH-FINDINGS §1`).

- The teacher relationship is treated as central, not optional: oral correction (talaqqī) and the certified chain (ijāza/sanad) are how the tradition guarantees text fidelity. The error signal in classical practice *is* the teacher flagging a hesitation.
- These method studies are mostly descriptive/qualitative and self-report; they tell us *what huffaz and teachers consistently do and value*, which is enough to honor in design, not enough to rank one technique numerically over another.

---

## Implications for Hifz Companion

1. **The product is aimed at the literature's own admitted gap.** The maintenance-of-hifz problem is named as under-researched and under-built ([Nordin et al., 2023]) and as "more than half the work" in practice. The positioning ("never *silently* lose the Quran") is evidence-aligned, not marketing. *(PRD §2)*

2. **Keep tradition as the visible interface; let SR be the invisible page-selector.** Because sabaq/sabqi/manzil is already hand-tuned spaced repetition + production retrieval, the three lifecycle tracks and named cycle presets should stay the surface, with the FSRS-style math only *ordering and pulling forward* inside the cycle ceiling. This respects what the methodology research describes as established practice. *(PRD §6.2, §7.6, §7.11)*

3. **Make mutashābihāt a first-class subsystem, with discrimination drills.** A measured majority of students cannot reliably tell near-identical passages apart ([Mohd Yusoff et al., 2022]); the recommended fix is to *identify them before memorizing* and drill the distinguishing words. This validates the bundled, scholar-reviewed mutashābihāt dataset, the interleaved same-session sibling review, and the anchor-hinting drill. *(PRD §9)*

4. **Treat interference as a distinct enemy from decay.** Because mutashābihāt confusion worsens as the corpus grows (unlike decay), a "wrong-branch" stumble should raise difficulty and frequency on *all* group members, not just the page — and the confusion log must be the user's own, never inferred by AI. *(PRD §7.7, §9.1–9.2)*

5. **Position the error signal as the teacher's tap, exactly as talaqqī works.** The methods literature makes oral correction the authoritative error signal; the app's on-device teacher sign-off (sourceConfidence = 1.0, overrides self-rating) mirrors talaqqī faithfully without any audio or AI. *(PRD §8.2, §4-R6)*

6. **Localize stumbles to lines, because *where* you broke is the real signal.** Traditional tasmīʿ flags the *position* of a hesitation; the app's reveal-on-tap line-marking and lazy line-block splitting capture exactly that, which is richer than a binary recall grade. *(PRD §6.3, §7.1, §8.1)*

7. **Be honest and modest about cognitive/neuro benefits — claim none in-app.** The memory, attention, grey-matter, and academic-performance findings are small-n, confounded, and mostly correlational. They may motivate the *builder's* iḥsān, but the product must not advertise "improves your memory" or "grows your brain." Any such line would violate the science values (cited + graded + honest-about-uncertainty). *(Blueprint §1 Science values; PRD §4)*

8. **Default to maintenance-rehearsal framing, not meaning-elaboration.** Since huffaz themselves rate disciplined maintenance above elaboration ([Dzulkifli et al., 2016]), and the app deliberately ships **no tafsīr/translation** (R2), the design coherently centers re-recitation cadence rather than meaning aids — and frames motivation through self-efficacy and calm goal-setting, never guilt. *(PRD §4-R2, §14; non-coercion value)*

---

## Citations

1. Nordin, O., Nik Abdullah, N. Md. S. A., Omar, R. A. M. I., & Abdullah, A. N. (2023). *The Art of Quranic Memorization: A Meta-Analysis.* Pertanika Journal of Social Sciences & Humanities, 31(2), 787–801. DOI: 10.47836/pjssh.31.2.16. https://www.pertanika.upm.edu.my/resources/files/Pertanika%20PAPERS/JSSH%20Vol.%2031%20(2)%20Jun.%202023/16%20JSSH-8758-2022.pdf — [OBS] (meta/scoping review of 20 studies; field-gap evidence)

2. Dzulkifli, M. A., & Solihu, A. K. H. (2018). *Methods of Qur'anic Memorisation (Hifz): Implications for Learning Performance.* Intellectual Discourse, 26(2), 931–947. https://journals.iium.edu.my/intdiscourse/index.php/islam/article/view/1238 — [OBS]

3. Dzulkifli, M. A., Bin Abdul Rahman, A. W., Badi, J. A., & Solihu, A. K. (2016). *Routes to Remembering: Lessons from al Huffaz.* Mediterranean Journal of Social Sciences, 7(3 S1), 121–128. DOI: 10.5901/mjss.2016.v7n3s1p121. https://www.richtmann.org/journal/index.php/mjss/article/view/9090 — [OBS]

4. Mohd Yusoff, M. Y. Z., et al. (2022). *Tahfiz Education in Malaysia: Issues and Problems in Memorising Quranic Mutashabihat Verses and its Solution.* International Journal of Academic Research in Business and Social Sciences (IJARBSS), 12(1). DOI: 10.6007/IJARBSS/v12-i1/10821. https://hrmars.com/papers_submitted/10821/tahfiz-education-in-malaysia-issues-and-problems-in-memorising-quranic-mutashabihat-verses-and-its-solution.pdf — [OBS] (survey, n = 368 tahfiz students; >60% cannot clearly distinguish mutashābihāt, 90% urge extra attention to them)

5. Şirin, S., Metin, B., & Tarhan, N. (2021). *The Effect of Memorizing the Quran on Cognitive Functions.* The Journal of Neurobehavioral Sciences, 8(1), 22–27. DOI: 10.4103/jnbs.jnbs_42_20. http://www.jnbs.org/uploads/files/104103jnbsjnbs-42-20_en.pdf — [OBS] (pre/post, n = 33, no control group)

6. Rahman, M. A., Aribisala, B. S., Ullah, I., & Omer, H. (2020). *Association between scripture memorization and brain atrophy using magnetic resonance imaging.* Acta Neurobiologiae Experimentalis, 80(1), 90–97. PMID: 32214278. https://pubmed.ncbi.nlm.nih.gov/32214278/ — [OBS] (cross-sectional MRI, n = 63)

7. Sapuan, A. H., Mustofa, N. S., Azemin, M. Z. C., Majid, M. C., & Jamaludin, I. (2015). *Grey Matter Volume Differences of Textual Memorization: A Voxel Based Morphometry Study.* In *International Conference for Innovation in Biomedical Engineering and Life Sciences* (IFMBE Proceedings), pp. 36–43. Springer. DOI: 10.1007/978-981-10-0266-3_8. https://link.springer.com/chapter/10.1007/978-981-10-0266-3_8 — [OBS] (VBM, n = 28, 1-year longitudinal)

8. Tarmuji, N. H., Mohamed, N., Hazudin, S. F., & Wan Ahmad, W. A. (2022). *Linking Study of Memorising Quran with Academic Performance.* Asia Pacific Journal of Educators and Education, 37(1), 181–191. DOI: 10.21315/apjee2022.37.1.9. http://apjee.usm.my/APJEE_37_1_2022/apjee37012022_9.pdf — [OBS] (n = 83; hifz explains ~22% of academic variance)

9. Nawaz, N., & Jahangir, S. F. (2015). *Effects of Memorizing Quran by Heart (Hifz) on Later Academic Achievement.* Journal of Islamic Studies and Culture, 3(1), 58–64. DOI: 10.15640/jisc.v3n1a8. https://www.researchgate.net/publication/282467544_Effects_of_Memorizing_Quran_by_Heart_Hifz_On_Later_Academic_Achievement — [OBS] (n = 36, correlational)

10. Khan, R., & Dzulkifli, M. A. (2021). *Understanding hifdh and its effect on short-term memory recall performance: An experimental study on high school students in Saudi Arabia.* INSPIRA: Indonesian Journal of Psychological Research, 2(1), 12–21. https://journal.iainlangsa.ac.id/index.php/inspira/article/view/2934 — [OBS] (controlled recall task, n = 100)
