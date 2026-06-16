# Motivation Without Coercion

This file documents why Hifz Companion sustains daily *murājaʿa* through **calm, autonomy, and honest feedback** rather than the coercive engagement machinery — streaks, badges, leaderboards, points, and guilt or fear notifications — that most apps rely on. The other science docs answer to *memory*: pages fade ([01-memory-and-forgetting.md](01-memory-and-forgetting.md)), spacing slows the fade ([02-the-spacing-effect.md](02-the-spacing-effect.md)), retrieval strengthens the trace ([04-retrieval-practice-and-self-testing.md](04-retrieval-practice-and-self-testing.md)), and overlearning carries it for decades ([06-overlearning-and-lifelong-retention.md](06-overlearning-and-lifelong-retention.md)). This doc answers to a different question: *what makes a ḥāfiẓ open the app and recite tomorrow, and the day after, for years* — without corrupting the very devotion that brings them. The answer the evidence gives is the opposite of the industry default. Habits form by repetition in a stable context, and a single missed day is harmless to that process; controlling rewards and guilt appeals reliably **undermine** intrinsic motivation rather than build it; and for an act of worship, gamified incentives risk crowding out the *niyyah* (intention) that gives the act its worth. This is the scientific justification for the PRD's hard constraints **C6 / R3 — no gamification of the sacred, no guilt notifications** (PRD §1, §4) — and for the design-system pillar *"calm, not cute."* The claim defended here is strong: a calm, loss-prevention retention engine produces *better, more durable* daily revision than a guilt-loop, not merely a more pious one. For the teacher relationship that anchors the app's sense of connection, see [10-traditional-hifz-methodology.md](10-traditional-hifz-methodology.md). This doc distills the deep dossier at [research/motivation-habit-noncoercive.md](research/motivation-habit-noncoercive.md).

> **Evidence grades (best → weakest):** **[MA]** meta-analysis/systematic review · **[RCT]** randomized experiment · **[EXP]** controlled cognitive experiment · **[CS]** classic foundational study · **[OBS]** observational/applied/field study · **[TEXT]** textbook/expert review · **[TRAD]** traditional/scholarly Islamic source. Prefer MA > RCT/EXP > CS > OBS > TEXT; methodology/religious claims are **[TRAD]** and name the source.

> **Rules that bind everything below.** The app induces **no guilt, no fear, no shame** to drive behavior. It offers **no points, badges, XP, leaderboards, or punishing streaks** on recitation (PRD C6, R3). Motivation is supported the way the evidence prescribes — autonomy (real choice), competence (honest, non-comparative feedback), and relatedness (the teacher and family) — never manufactured by loss aversion. For an act of worship, the *niyyah* outranks every engagement metric, and the app has no engagement KPI to protect because it is built free, as *ṣadaqah* (PRD §0).

---

## At a glance

| The app's position | Why (evidence) | Grade |
|---|---|---|
| Habits form by repetition in a stable context, not by willpower or pressure | Lally et al. 2010 (median 66 days, range 18–254) | [OBS] |
| Missing one day does **not** materially harm habit formation — so streak-shaming is unscientific | Lally et al. 2010 (a single miss is negligible) | [OBS] |
| Intrinsic motivation runs on autonomy, competence, relatedness; controlling contexts diminish it | Ryan & Deci 2000 (self-determination theory) | [TEXT] |
| Expected, contingent rewards reliably **undermine** intrinsic motivation | Deci, Koestner & Ryan 1999 (128 experiments) | [MA] |
| A salient reward turns play into work and is not reclaimed when withdrawn (overjustification) | Lepper, Greene & Nisbett 1973 | [EXP] |
| Points/levels/leaderboards move behavior without moving intrinsic motivation or competence | Mekler et al. 2017 | [EXP] |
| Guilt appeals that attribute blame trigger reactance and persuade *less* | Peng et al. 2023 (meta-analysis, g = 0.19) | [MA] |
| Shame attacks the self and motivates avoidance; guilt targets behavior and motivates repair | Tangney, Stuewig & Mashek 2007 | [TEXT] |
| For worship, extrinsic gamified incentives risk crowding out the *niyyah* | Bukhārī 1 / Muslim 1907; Allport & Ross 1967 | [TRAD]/[CS] |

---

## 1. A daily habit forms by repetition in a stable context — not by willpower, and not by pressure

**Statement.** What sustains *murājaʿa* over years is not motivation summoned afresh each day but an automatic habit: a stable cue that triggers the action with little deliberation. The app's job is to make the cue consistent and the action small, then let repetition do the work — and to be patient, because habits form slowly and at very different rates between people.

**Evidence.**
- In the most-cited real-world habit study, 96 volunteers each performed one self-chosen behavior **daily in the same context** (e.g. "after breakfast") and rated its automaticity for 12 weeks. Across the 82 analyzable participants, automaticity grew along an **asymptotic curve** — large early gains, diminishing later ones — and the median time to reach 95% of the automaticity plateau was **66 days, with an individual range of 18 to 254 days** ([Lally et al., 2010, *Eur. J. Soc. Psychol.*](https://onlinelibrary.wiley.com/doi/abs/10.1002/ejsp.674)) **[OBS]**. The popular "21 days to a habit" figure is a myth; two months is closer to typical, and some motivated people honestly need eight.
- The mechanism is cue-driven, not effort-driven: a habit is "a process by which a stimulus automatically generates an impulse towards action, based on learned … associations," and automaticity built only when the behavior was reliably paired with a **consistent preceding context** ([Lally et al., 2010](https://onlinelibrary.wiley.com/doi/abs/10.1002/ejsp.674)) **[OBS]**.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| One calm, consistent daily cue | A single optional daily reminder at a **user-chosen time** (PRD §14) supplies the stable context habit formation needs — not escalating nags. |
| Keep the action small and capped | The "revise today" list is short, **finite, and time-budget capped** (PRD §7.9, §12.2), so the daily action stays low-friction and repeatable, which is what builds automaticity. |
| Patience with slow-forming habits | Because the asymptote can take eight months for some users, the app never implies a user is "behind" for not having an instant routine; there is no day-count to fall short of. |

**Anti-patterns — we will never:**
- Imply that a strong daily routine should appear in 21 days, or treat a user who forms the habit slowly as failing.
- Replace a consistent, calm cue with escalating or multiplying notifications that try to *force* the action rather than *trigger* it.

---

## 2. Missing a single day does not derail the habit — so streak-shaming is unscientific, not only un-adab

**Statement.** A broken day is harmless. The science of habit formation directly contradicts the streak mechanic, which treats one missed day as a catastrophe and resets a counter to zero. We refuse streak pressure on evidence grounds as much as on grounds of *adab*.

**Evidence.**
- Lally et al. explicitly tested skipped opportunities and found that **missing one opportunity to perform the behavior did not materially affect the habit-formation process** — a single miss produced only a negligible dip in automaticity, and scores recovered on the next performance ([Lally et al., 2010](https://onlinelibrary.wiley.com/doi/abs/10.1002/ejsp.674); summarized in [BPS Research Digest, *How to form a habit*](https://www.bps.org.uk/research-digest/how-form-habit)) **[OBS]/[TEXT]**. Because the asymptotic model builds automaticity from the *accumulated mass* of repetitions, one gap is statistically trivial.
- The harm in a broken streak is therefore not the missed day but the **punishment** — the guilt and shame the reset induces, whose behavioral signature (§5) is to *avoid the cue*, i.e. to stop opening the app. The streak punishes a harmless event with the one emotion most likely to end the habit.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| No punishing streak counter | The app ships **no streak you are punished for breaking**; at most a private, opt-in continuity indicator (PRD §12.5), never framed as something lost on a single miss. |
| Graceful catch-up, never a shame-pile | After a gap the engine **re-spreads** the backlog over several days, most-decayed and prayer-critical first, and says plainly *"You missed 3 days — here is a 5-day catch-up plan that still completes your cycle"* (PRD §7.9). |
| Lapse framed as recoverable | A forgotten page demotes calmly into active revision (PRD §6.2, §7.7); copy says "this needs reactivation," never "you have lost it." |

**Anti-patterns — we will never:**
- Show a streak counter that resets to zero on one missed day, or any "don't break your streak" framing.
- Greet a returning user with a red overdue pile or a "you lost N days" message — the gap is harmless and the catch-up is help, not blame.

---

## 3. Intrinsic motivation runs on autonomy, competence, and relatedness — and controlling contexts diminish it

**Statement.** A ḥāfiẓ revises out of love and duty. The way to sustain that is to support three psychological needs — autonomy, competence, relatedness — not to apply pressure, surveillance, or contingent rewards, which the dominant theory of motivation shows actively *reduce* self-motivation.

**Evidence.**
- Self-determination theory (SDT), the leading empirical account of motivation, holds that self-motivation and well-being depend on satisfying **autonomy** (acting from one's own volition), **competence** (feeling effective), and **relatedness** (connection to others). When social contexts support these needs people are more self-motivated and healthier; when contexts are **controlling** — pressure, surveillance, contingent rewards, evaluation — they "diminish self-motivation … and well-being" ([Ryan & Deci, 2000, *American Psychologist*](https://pubmed.ncbi.nlm.nih.gov/11392867/)) **[TEXT]**.
- The three needs map cleanly onto a non-coercive hifz app: **autonomy** is *choosing* a named cycle rather than being herded by an algorithm; **competence** is *seeing* the Quran stay "green"; **relatedness** is the *talaqqī*/teacher relationship and the family — none of which require a leaderboard or a social feed.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| Autonomy: real, tradition-shaped choice | The user picks a **named cycle** (e.g. "7-manzil weekly khatm," "1 juz/day") rather than a "retention slider" (PRD §7, §15.1), and may run a **pure-cycle conservative mode** with the algorithm's reordering off (PRD §7.11). All reminders are optional and non-escalating (PRD §14). |
| Competence: visible mastery of *your own* Quran | The whole-Quran **retention heat-map** ("keep your Quran green," PRD §12.5) is the competence signal — self-referential, not a ranking. |
| Relatedness: the teacher and family, not a feed | *Talaqqī* sign-off (PRD §8.2) and local halaqa/family profiles (PRD §15.3) satisfy relatedness with no server, account, or social graph (consistent with C1). |

**Anti-patterns — we will never:**
- Build a controlling context — surveillance dashboards, contingent rewards, evaluative pressure — that SDT shows undermines the motivation a ḥāfiẓ already has.
- Manufacture relatedness through a social feed or public ranking when the teacher and family are the authentic anchors.

---

## 4. Controlling extrinsic rewards reliably undermine intrinsic motivation — a robust meta-analytic result

**Statement.** Adding points, badges, or rewards to an activity someone already values does not add motivation — it *subtracts* it. This is one of the better-replicated findings in motivation science, and it is precisely the opposite of what a gamified worship app would do.

**Evidence.**
- The foundational meta-analysis examined **128 experiments** and found that tangible rewards offered for an already-interesting activity **significantly undermined free-choice intrinsic motivation**: engagement-contingent, completion-contingent, and performance-contingent rewards all reduced it (d ≈ **−0.40, −0.36, −0.28** respectively), as did all expected tangible rewards ([Deci, Koestner & Ryan, 1999, *Psychological Bulletin*](https://www.researchgate.net/publication/12712628_A_Meta-Analytic_Review_of_Experiments_Examining_the_Effects_of_Extrinsic_Rewards_on_Intrinsic_Motivation)) **[MA]**. The mechanism (cognitive evaluation theory) is a shift in perceived **locus of causality** from internal ("I do this because it matters to me") to external ("I do this for the reward") — and when the reward stops, the original motivation does not simply return.
- This is the **overjustification effect**, shown in the classic field experiment: children who loved drawing, then drew to earn an *expected* "Good Player" award, later **drew far less freely** than children who got no award or an *unexpected* one — a salient incentive turned play into work ([Lepper, Greene & Nisbett, 1973, *J. Pers. Soc. Psychol.*](https://psycnet.apa.org/record/1974-10497-001)) **[EXP]**.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| No contingent rewards on recitation | The app awards **no points, XP, or badges** for reciting, completing a juz, or finishing a cycle (PRD C6, R3) — exactly the expected, contingent rewards the meta-analysis condemns. |
| Feedback is informational, not a prize | The heat-map and "weakest pages" list inform; they are never a reward to chase or a score to inflate (PRD §12.5). |
| Protect the internal locus of causality | Framing is calm loss-prevention and peace of mind (PRD §2), keeping the motive on the act of worship, never relocating it onto a trinket. |

**Anti-patterns — we will never:**
- Attach badges, XP, points, or unlockable rewards to reciting the Quran — the act is its own reward, and a contingent reward would corrode it.
- Introduce any mechanic that shifts the reason for revising from devotion to earning an in-app token.

---

## 5. Guilt and fear backfire — blame triggers reactance, and shame drives avoidance

**Statement.** A notification that blames the user ("you'll lose your hifz") is not just unkind; it is *less* effective and risks inducing shame, whose behavioral signature is to avoid the app entirely. Our notifications are neutral and blameless because the evidence says coercive copy defeats its own retention goal.

**Evidence.**
- A meta-analysis of guilt appeals (26 studies, 127 effect sizes, 7,512 participants) found only a **small overall persuasive effect (g = 0.19)**, and crucially that appeals **explicitly attributing responsibility to the person** persuaded *less* than appeals describing harm without blame, because explicit blame is perceived as manipulative and raises **psychological reactance** ([Peng et al., 2023, *Frontiers in Psychology*](https://pubmed.ncbi.nlm.nih.gov/37842697/)) **[MA]**. A notification reading *"You'll lose your hifz"* is exactly the high-blame appeal the meta-analysis says backfires.
- The deeper danger is **shame**, not guilt. Guilt targets a *behavior* ("I did a bad thing") and tends to motivate reparative action; **shame targets the *self* ("I am bad") and tends to motivate avoidance, denial, and withdrawal** ([Tangney, Stuewig & Mashek, 2007, *Annual Review of Psychology*](https://www.its.caltech.edu/~squartz/Tangney.pdf)) **[TEXT]**. "You broke your 90-day streak" is a shame induction, and shame's signature is to *avoid the cue* — to stop opening the app.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| Neutral, blameless reminder copy | The daily reminder reads *"Your revision for today is ready"* (PRD §14), never *"You'll lose your hifz"* — the calm framing is *more* effective, not just kinder. |
| Catch-up framed as help, not failure | The missed-day notification offers a plan that "still completes your cycle" (PRD §7.9), inviting return (guilt → repair), never self-attack (shame → avoidance). |
| No fear-based loss messaging | Decay is shown as a calm heat-map state, never as a threat that the user has "let happen" (PRD §12.5, R3). |

**Anti-patterns — we will never:**
- Send a notification that blames the user, predicts catastrophic loss, or frames a lapse as personal failure.
- Use shame mechanics ("you broke your streak," "you're falling behind") that the evidence shows drive avoidance of the very habit we want to sustain.

---

## 6. Gamification moves behavior without moving motivation — and competitive elements harm the strugglers most

**Statement.** Points, levels, and leaderboards are sold as competence signals, but controlled evidence shows they shift *output* without raising intrinsic motivation or felt competence — and competitive, comparative elements actively discourage the users who are doing worst, which for this app are exactly the people it most wants to keep.

**Evidence.**
- In a controlled experiment, adding points, levels, and leaderboards to a real task **increased task output but did *not* significantly increase intrinsic motivation or competence-need satisfaction** relative to a bare version ([Mekler, Brühlmann, Tuch & Opwis, 2017, *Computers in Human Behavior*](https://www.sciencedirect.com/science/article/abs/pii/S0747563215301229)) **[EXP]**. Game elements move *behavior*, not *the desire to do the thing* — the wrong trade for an act meant to be done for its own sake.
- The effect is not uniform across users. A meta-analysis and systematic review of gamification in education found that two of the major obstacles to gamification raising intrinsic motivation were students' **lack of perceived competence and lack of perceived autonomy** in gamified settings, with gamification showing **minimal impact on competence** even where it touched autonomy and relatedness ([Zainuddin et al., 2023, *Educational Technology Research and Development*](https://link.springer.com/article/10.1007/s11423-023-10337-7)) **[MA]**. A leaderboard over Quran recitation would convey negative feedback to those performing poorly — the struggling late-starter (PRD persona P3) and the adult who would compare himself to children — the very users the app must not discourage.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| No leaderboards or social comparison | The app has **no leaderboards, no public rankings, no group challenges** on recitation (PRD C6, R3); there is no "loser" to discourage. |
| Self-referential competence feedback only | The heat-map reports *your* whole-Quran state, not a ranking against others (PRD §12.5) — capturing the competence upside while avoiding the social-comparison downside. |
| "Weakest pages" as help, not a score | The weakest-pages list is actionable guidance toward what to revise, never a deficiency score to feel bad about (PRD §12.5, §10.3). |

**Anti-patterns — we will never:**
- Add leaderboards, group rankings, or any competitive comparison to recitation — it most discourages the user who is struggling most.
- Treat increased daily opens as success if the mechanism driving them is gamified pressure rather than genuine, devotional motivation.

---

## 7. For an act of worship, gamified incentives risk crowding out the intention (*niyyah*)

**Statement.** Here the overjustification concern is not merely psychological — it touches the heart of the act. In Islam the worth of a deed is its **intention** (*niyyah*). Layering points, badges, and public rankings onto recitation pushes the act toward the extrinsic pole and risks attaching the *niyyah* to the reward rather than to Allah. The app therefore refuses to gamify worship on both empirical and religious grounds, which point the same way.

**Evidence.**
- The worth of a deed is its intention: *"Actions are but by intentions, and every person will have only what he intended"* — placed first in *Ṣaḥīḥ al-Bukhārī* (no. 1) and in *Ṣaḥīḥ Muslim* (no. 1907) precisely because intention is treated as the ruler of the deed ([Ṣaḥīḥ al-Bukhārī 1, Sunnah.com](https://sunnah.com/bukhari:1); [Ṣaḥīḥ Muslim 1907, Sunnah.com](https://sunnah.com/muslim:1907)) **[TRAD]**.
- The psychology of religion long ago distinguished **intrinsic religiosity** ("religion as an end, lived") from **extrinsic religiosity** ("religion as a means — to status, comfort, reward"): *"the extrinsically motivated individual uses his religion, whereas the intrinsically motivated lives his"* ([Allport & Ross, 1967, *J. Pers. Soc. Psychol.*](https://psycnet.apa.org/record/1968-00339-001)) **[CS]**. By the overjustification mechanism (§4), gamified rewards push the act toward the extrinsic pole — the corruption (*riyāʾ*, reward-seeking from creation) the tradition warns against. An applied review of 11 Islamic apps reached the same design conclusion from the secular side: users were discomforted by the **"transactional model of spiritual engagement,"** with paywalled and gamified worship features felt as "disheartening" ([Kabir et al., 2024/2025, *Int. J. Human–Computer Interaction*](https://arxiv.org/abs/2402.02061)) **[OBS]**.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| Worship is never gamified | No XP, badges, confetti, or public rankings on recitation or completion (PRD C6, R3, §4) — the act stays oriented to Allah, not to a counter. |
| No transactional framing | Built free as *ṣadaqah*, with no monetization, paywall, or upsell anywhere (PRD §0) — removing the "transactional spirituality" users report as disheartening. |
| State the principle as a trust signal | The in-app "the science we follow" screen can say plainly that the app avoids streaks, badges, and guilt because the research shows they do not build lasting habits and can undermine the motivation that brings the user to revise ([11-the-in-app-science-screen.md](11-the-in-app-science-screen.md)). |

**Anti-patterns — we will never:**
- Gamify recitation in any form that could attach the *niyyah* to a reward, a rank, or a streak rather than to Allah.
- Introduce monetization or transactional mechanics around the act of worship.

---

## 8. What actually sustains the practice — and honesty about where the evidence is nuanced

**Statement.** Removing coercion is not removing support. The same literatures prescribe the constructive alternatives the app already favors. And we state honestly where the evidence is mixed — then explain why a worship app built as *ṣadaqah* still errs firmly against coercion.

**Evidence.**
- The constructive prescription is consistent across the findings: a **stable cue and a small action** (§1), **genuine autonomy** through chosen cycles and easily-silenced reminders (§3), **non-comparative competence feedback** via the heat-map (§3, §6), **relatedness through the teacher and family** (§3), and **reframing the lapse as recoverable** (§2, §5) — each grounded in the studies cited above.
- Honest scoping: gamification is **not uniformly harmful** — meta-analytic work finds it can *raise* perceptions of autonomy and relatedness when elements are perceived as **informational rather than controlling**, with the undermining concentrated in **tangible, expected, contingent** rewards and **competitive/comparative** elements ([Zainuddin et al., 2023](https://link.springer.com/article/10.1007/s11423-023-10337-7)) **[MA]**. The app's safe path is therefore not "no feedback" but *non-comparative, informational, self-referential* feedback — the heat-map — which keeps the competence upside and drops the social-comparison and contingent-reward downsides. Likewise, guilt is not always counterproductive (its small positive average, g = 0.19, [Peng et al. 2023](https://pubmed.ncbi.nlm.nih.gov/37842697/) [MA]); it is specifically **blame-attributing, manipulative-feeling** appeals that backfire — and a worship app has no need to manufacture even mild guilt.
- The asymmetry is deliberate. Much of the habit/UX evidence is observational or single-task; the rewards and guilt meta-analyses are the strongest pieces. But for a *worship* app built as *ṣadaqah* with no engagement KPI (PRD §0), the cost of wrongly omitting a streak (slightly fewer daily opens) is trivial, while the cost of wrongly adopting one (corrupting *niyyah*, inducing shame-avoidance, breaching adab) is severe — so the app errs against coercion.

**In practice.**

| Engine / app behavior | How this finding shapes it |
|---|---|
| Support, not coercion | Stable cue (§1), real choice (§3), heat-map competence (§6), teacher relatedness (§3), recoverable lapse (§2) — the whole constructive prescription, implemented. |
| Informational feedback only | The heat-map and weakest-pages list are informational and self-referential (PRD §12.5), the form of feedback the nuanced evidence supports — never controlling or comparative. |
| Accept honest retention over engineered compulsion | The app forgoes loss-aversion engagement machinery (PRD §0) and optimizes for genuine benefit (*nafʿ*) and the user's own devotional motivation, accepting that the high-intent ḥāfiẓ (persona P1) is sustained by meaning, the heat-map, and a survivable load — not a guilt loop. |

**Anti-patterns — we will never:**
- Use the "gamification can help" nuance as a loophole to introduce contingent rewards, leaderboards, or streak pressure — the app adopts only *non-comparative, informational* feedback.
- Manufacture compulsion through loss aversion to inflate daily opens; with no monetization and no engagement KPI, there is no reason to, and a strong adab reason not to.

---

## References

Only sources cited in this file are listed here. The deduplicated, graded master bibliography is in [REFERENCES.md](REFERENCES.md); the full evidence dossier is [research/motivation-habit-noncoercive.md](research/motivation-habit-noncoercive.md).

- Allport, G. W., & Ross, J. M. (1967). *Personal religious orientation and prejudice.* Journal of Personality and Social Psychology, 5(4), 432–443. https://psycnet.apa.org/record/1968-00339-001 — **[CS]**
- British Psychological Society Research Digest. *How to form a habit* (summary of Lally et al. 2010, including the negligible effect of a missed opportunity). https://www.bps.org.uk/research-digest/how-form-habit — **[TEXT]**
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). *A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation.* Psychological Bulletin, 125(6), 627–668. https://www.researchgate.net/publication/12712628_A_Meta-Analytic_Review_of_Experiments_Examining_the_Effects_of_Extrinsic_Rewards_on_Intrinsic_Motivation — **[MA]**
- Kabir, M., Kabir, M. R., & Islam, R. S. (2024/2025). *Islamic lifestyle applications: Meeting the spiritual needs of modern Muslims.* International Journal of Human–Computer Interaction (preprint arXiv:2402.02061; published DOI: 10.1080/10447318.2025.2595545). https://arxiv.org/abs/2402.02061 — **[OBS]**
- Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). *How are habits formed: Modelling habit formation in the real world.* European Journal of Social Psychology, 40(6), 998–1009. https://onlinelibrary.wiley.com/doi/abs/10.1002/ejsp.674 — **[OBS]**
- Lepper, M. R., Greene, D., & Nisbett, R. E. (1973). *Undermining children's intrinsic interest with extrinsic reward: A test of the "overjustification" hypothesis.* Journal of Personality and Social Psychology, 28(1), 129–137. https://psycnet.apa.org/record/1974-10497-001 — **[EXP]**
- Mekler, E. D., Brühlmann, F., Tuch, A. N., & Opwis, K. (2017). *Towards understanding the effects of individual gamification elements on intrinsic motivation and performance.* Computers in Human Behavior, 71, 525–534. https://www.sciencedirect.com/science/article/abs/pii/S0747563215301229 — **[EXP]**
- Peng, W., Huang, Q., Mao, B., Lun, D., Malova, E., Simmons, J. V., & Carcioppolo, N. (2023). *When guilt works: A comprehensive meta-analysis of guilt appeals.* Frontiers in Psychology, 14, 1201631. https://pubmed.ncbi.nlm.nih.gov/37842697/ — **[MA]**
- Ryan, R. M., & Deci, E. L. (2000). *Self-determination theory and the facilitation of intrinsic motivation, social development, and well-being.* American Psychologist, 55(1), 68–78. https://pubmed.ncbi.nlm.nih.gov/11392867/ — **[TEXT]**
- Ṣaḥīḥ al-Bukhārī 1 (ʿUmar ibn al-Khaṭṭāb), Book 1, Ḥadīth 1; also *Ṣaḥīḥ Muslim* 1907: "Actions are but by intentions." Sunnah.com. https://sunnah.com/bukhari:1 and https://sunnah.com/muslim:1907 — **[TRAD]**
- Tangney, J. P., Stuewig, J., & Mashek, D. J. (2007). *Moral emotions and moral behavior.* Annual Review of Psychology, 58, 345–372. https://www.its.caltech.edu/~squartz/Tangney.pdf — **[TEXT]**
- Zainuddin, Z., et al. (2023). *Gamification enhances student intrinsic motivation, perceptions of autonomy and relatedness, but minimal impact on competency: A meta-analysis and systematic review.* Educational Technology Research and Development, 71, 2477–2509. https://link.springer.com/article/10.1007/s11423-023-10337-7 — **[MA]**

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
