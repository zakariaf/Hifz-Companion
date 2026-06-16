# 11 — Voice and Tone

This file defines how Hifz Companion **speaks** — the single voice every string must pass, a tone-by-context matrix for the emotionally distinct moments of revision, the rules that keep copy non-coercive and reverent, the framing of sensitive news (decay, missed days, lapses), and the per-locale guidance that carries one voice across Persian (fa), Arabic (ar), and Kurdish Sorani (ckb) without flattening it into literal translation. Copy is load-bearing here, not decoration: this is an app whose subject is the Quran, opened daily by a ḥāfiẓ who already carries the spiritual weight of what they hold, so a single wrong sentence — a guilt nag ("You'll lose your hifz"), a streak-shame state, a page declared "safe to drop" — is a documented harm and a breach of *adab*, not a style slip ([Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full); [PRD R3, §14, §7.12](../PRD.md)). It implements Pillar 7 (*servant to the teacher*) and supports Pillar 2 (*calm, not cute*) and Pillar 1 (*reverence first*); it distills [`research/voice-tone-religious-adab.md`](research/voice-tone-religious-adab.md). This file **owns no token family**: it composes the calm palette from [03-color-and-themes.md](03-color-and-themes.md), the UI type (`type.body`, `type.label`, `type.caption`, `type.numeral`) from [04-typography.md](04-typography.md), the locale numerals, calendars, bidi isolation and term-set switching from [12-localization-and-rtl.md](12-localization-and-rtl.md), the screen-reader semantics from [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md), and it supplies the wording for [10-privacy-and-trust-ux.md](10-privacy-and-trust-ux.md), [07-components.md](07-components.md), and [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md). The governing rule above all rules below: **the app's voice is itself an act of *adab*** — toward Allah, toward the muṣḥaf, and toward the user — and the same restraint applied to motion and color is applied, more strictly, to language ([Ṣaḥīḥ Muslim 2594a](https://sunnah.com/muslim:2594a)).

## At a glance

| Concern | Decision | Evidence anchor | Cross-ref |
|---|---|---|---|
| Governing concept | Voice is *adab*; gentleness ranks above any engagement convention | Ṣaḥīḥ Muslim 2594a; Yasien Mohamed 2023 | [13](13-islamic-identity-and-adab.md) |
| Voice attributes | Four fixed targets: reverent, calm, plain-and-warm, honest | Moran (NN/g) 2016/2023; M3 Content design | this file |
| Controlling language | Banned — "must/should/don't" provoke reactance and rejection | Miller et al. 2007; Reynolds-Tylus 2019 | §2, §6 |
| Guilt / fear / loss copy | Release-blocking; backfires and weaponises a real spiritual fear | Reynolds-Tylus 2019; Shen 2010 | §3, [PRD R3](../PRD.md) |
| Hard news (decay, gaps) | Lead with empathy, then a calm path forward | Shen 2010 | §4, [PRD §7.9](../PRD.md) |
| Authority boundary | Never speak *for* the Quran, rule, or override the teacher | Yasien Mohamed 2023; [PRD R6](../PRD.md) | §5, [13](13-islamic-identity-and-adab.md) |
| Transactional framing | No "upgrade," urgency, or debt-to-the-app; worship is served | Kabir et al. 2024 | §7 |
| One voice, three languages | Transcreation + per-locale register, not literal translation | Smartling; Izadi 2015; Al-Hamzi et al. 2024 | §8, §9, [12](12-localization-and-rtl.md) |
| Tone is QA-able | Banned-phrase lint + native + scholar review per locale in CI | Moran 2016/2023; [PRD §20.5](../PRD.md) | §9 |

---

## 1. The governing concept is *adab*: gentleness outranks every copy convention

**Statement.** Before any usability rule, the voice is bound by *adab* — the Islamic ethic of refined, gentle, reverent conduct. For an app whose subject is the Quran, *adab* is the **top** constraint on language and ranks above any engagement-, conversion-, or retention-optimised copy convention the wider industry treats as default.

**Evidence.**
- *Adab* in the tradition is not mere politeness but "refinement, good manners, morals, decorum, decency, humaneness" that "transcends mere politeness and embodies a profound spiritual practice centered around respectful conduct, humility, and devoted service" ([*Adab (Islam)*](https://en.wikipedia.org/wiki/Adab_(Islam))). An app that holds the muṣḥaf is judged by this ethic first.
- Gentleness (*al-rifq*) is a religious obligation, not a nicety: the Prophet ﷺ said, "Verily, gentleness is not found in anything except that it beautifies it, and it is not removed from anything except that it disgraces it" ([Ṣaḥīḥ Muslim 2594a](https://sunnah.com/muslim:2594a)). Read as a copy law: gentleness makes *any* message better and its absence makes *any* message worse — there is no register in which harshness improves this product.
- The classical *adab* of teaching places the teacher on the side of gentleness — "kind and compassionate towards his students … guiding gently, always encouraging them but never stifling them" ([Yasien Mohamed, Yaqeen Institute, 2023](https://yaqeeninstitute.org/read/paper/etiquette-as-spiritual-nourishment-the-adab-of-the-student-according-to-al-ghazali-and-al-isfahani)). In the revision relationship the app stands on the *teacher's* side — it is the thing that tells the student what to revise — so this is the directly applicable model: encourage, never stifle; correct, never shame.
- The Quran prescribes the *manner* of invitation: "Invite to the way of your Lord with wisdom (*ḥikmah*) and good instruction (*al-mawʿiẓa al-ḥasana*)" (Q 16:125), read by the classical tafsīr as method-tiered gentleness ([Q 16:125, Quran.com](https://quran.com/en/an-nahl/125)). This is the scriptural warrant for a calm, instructive, never-hectoring voice.

**In practice.**
- *Adab* is encoded as the **first gate** of the copy review, ahead of clarity and brevity: a string that is clear but harsh fails before it is assessed for anything else. This gate is a named step in the `voice-tone` review and is release-blocking (§9; [PRD §20.5](../PRD.md)).
- The reverent register is the same across surfaces — onboarding, the Today list, the recite/grade flow, notifications, errors, settings — so the *adab* is structural, not a flourish on the welcome screen. Tone (§ tone matrix below) flexes; the gentleness floor never does.
- Reverence is also typographic-adjacent in copy: the muṣḥaf is named honestly ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf," [PRD R2](../PRD.md)), Allah's name and Quranic terms are rendered correctly in the bundled Perso-Arabic UI font (`type.body`/`type.title`, [04-typography.md](04-typography.md)), and honorifics (ﷺ, raḍiya Allāhu ʿanhu) appear where a name appears — small markers that signal the app knows whose text it handles ([13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md)).

**Anti-patterns — we will never:**
- Let any usability, engagement, or growth convention override the gentleness floor — *adab* is not a tunable parameter.
- Joke about, be flippant toward, or "spice up" copy about the muṣḥaf, hifz, or the user's effort.
- Treat reverence as a one-screen onboarding gesture rather than a property of every string in every locale.

---

## 2. The voice: four fixed attributes every string must pass

**Statement.** Four voice attributes are fixed across every screen, notification, widget, and error: **reverent**, **calm**, **plain-and-warm**, and **honest**. Tone (next section) flexes by context; the voice never does. Adopting one named voice is more effective than any clever turn of phrase, because tone differences in practice are small in magnitude and the win is *consistency*, which is exactly what a reverence-first product wants.

**Evidence.**
- Nielsen Norman Group's standard model decomposes tone into **four auditable dimensions, each a spectrum**: *Formal ↔ Casual*, *Serious ↔ Funny*, *Respectful ↔ Irreverent*, *Matter-of-fact ↔ Enthusiastic* — making "tone" a thing a string can be scored against, not a vibe ([Moran / NN/g, 2016, updated 2023](https://www.nngroup.com/articles/tone-of-voice-dimensions/)). *Adab* fixes our targets: **respectful** (never irreverent — no quirk, no edge, no jokes about the muṣḥaf), **matter-of-fact** (not enthusiastic — NN/g notes enthusiasm is signalled by emotive language and exclamation marks, which [PRD R3](../PRD.md) and the blueprint tone rule forbid), and **serious** (not funny). The one axis with latitude — *Formal ↔ Casual* — still has a floor of "respectful and warm."
- NN/g also reports that tone differences are real but *small* (≈0.5–1 point on a 5-point scale), so the leverage is a single, quiet, dependable voice across every screen and all three languages, not flourish ([Moran, 2016/2023](https://www.nngroup.com/articles/tone-of-voice-dimensions/)).
- Plainness is platform guidance, not preference: Material 3 content design directs UI text to be simple, direct, scannable, sentence-case, jargon-free, and to clearly explain the consequences of an action ([Material Design 3: Content design](https://m3.material.io/foundations/content-design/overview)). For a Flutter app this is the platform-native bar (the analogue of CycleVault's Apple-HIG citation).

**In practice.**

| Attribute | It means | Sounds like | Never sounds like |
|---|---|---|---|
| **Reverent** | The muṣḥaf, hifz, and the user's effort are treated with *adab*; the riwāyah is named; honorifics and correct transliteration appear ([13](13-islamic-identity-and-adab.md)) | "Your revision of the Ḥafṣ muṣḥaf for today is ready." | Any flippant, gamey, or mascot register about sacred material |
| **Calm** | No urgency the data doesn't warrant; no exclamation marks, no alarm styling, no countdown pressure; renders in calm `color.text.primary`/`secondary`, never a saturated warning fill ([03](03-color-and-themes.md)) | "You have 12 pages to revise today." | "12 pages OVERDUE!" |
| **Plain & warm** | Short sentences, one idea each, key fact first, a knowledgeable companion — not a clerk, not a coach ([M3 Content design](https://m3.material.io/foundations/content-design/overview)) | "Backup saved. All profiles, on this phone." | "Your archive has been successfully persisted." |
| **Honest** | Estimates are labelled; nothing is hidden; the engine's limits are stated, never dressed up; a page is never called "safe to drop" ([PRD §7.12](../PRD.md)) | "This juz is weakening. Next review pulled earlier." | "You've mastered this juz." |

- **Mechanics, app-wide:** address the user as second-person singular, warm; sentence case; **no exclamation marks; no emoji in product copy** (per blueprint §5); state the fact, then the option, then stop; buttons are verbs in the locale's idiom ("Start revision," "Save backup"). Numerals always render in the locale set — Extended Arabic-Indic (۰۱۲۳۴۵) for fa/ckb, Arabic-Indic (٠١٢٣٤٥) for ar — via `intl` `NumberFormat` and the `type.numeral` token, never raw ASCII concatenated into a string ([12-localization-and-rtl.md](12-localization-and-rtl.md)).
- The four attributes are written into the `voice-tone` review checklist so every new string is scored on each before it ships.

**Anti-patterns — we will never:**
- Let the voice (not the tone) vary by screen, locale, or mood — one voice, everywhere.
- Reach for enthusiasm markers — exclamation marks, hype adjectives, "amazing," "great job" — to manufacture warmth ([Moran, 2016/2023](https://www.nngroup.com/articles/tone-of-voice-dimensions/)).
- Confuse "warm" with "cute": no mascots, no baby-talk, no clinical coldness either.

---

## 3. Tone-by-context matrix: the voice is constant, the warmth and density adjust

**Statement.** The voice stays fixed; **tone** adjusts how much warmth and how much information each moment can carry. Revision has emotionally distinct moments — a clean recite, a lapse, a decaying juz, a missed-day backlog, a teacher sign-off — and each needs a calibrated tone, but all share the same non-coercive, non-shaming mechanism: predictability, user control, no surprise emotional content.

**Evidence.**
- Controlling, mandate-laden wording provokes reactance and message rejection; autonomy-supportive, choice-restoring wording repairs it ([Miller et al., 2007, *Human Communication Research* 33:219–240](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x); open record [ERIC EJ755929](https://eric.ed.gov/?id=EJ755929)). Every row below must therefore suggest and inform, never command.
- The proven reactance-reducers — implicit/qualified language, restoration-of-freedom postscripts ("the choice is yours"), provision of choice, message-induced empathy, narrative framing — map directly onto these surfaces ([Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full)). The hard-news rows lead with empathy because empathy *measurably* lowers reactance above and beyond a message's content ([Shen, 2010, HCR 36(3):397–422](https://academic.oup.com/hcr/article-abstract/36/3/397/4107508)).

**In practice.** The voice is constant across rows; only tone (warmth, density) moves. Examples are English glosses of the intended *feeling*; each is transcreated per locale (§8) and rendered in `type.body`/`type.label` on the calm palette ([03](03-color-and-themes.md), [04](04-typography.md)).

| Context | Tone | Example (gloss) | Never | Why |
|---|---|---|---|---|
| Daily session ready | Calm, neutral statement of readiness | "Your revision for today is ready." | "Don't miss today!", urgency, exclamation | [PRD §14](../PRD.md); [Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x) |
| Clean recite logged | Brief, quiet confirmation — no praise theatre | "Logged. Good and clean." | "Great job! 🎉", points, streak +1 | [Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full); [PRD R3](../PRD.md) |
| Lapse / stumble | Matter-of-fact, no blame; localize the weak line, schedule it sooner | "Noted — line 7 needs another pass. It'll come up again soon." | "You forgot this.", "wrong", red shame fill | [Shen, 2010](https://academic.oup.com/hcr/article-abstract/36/3/397/4107508); [PRD §7.7](../PRD.md) |
| Decaying juz | Honest + empathetic; describe, then act; never alarm | "This juz is weakening. Today's plan brings it back." | "Juz at risk!", "you're losing this" | [Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full); [PRD R3](../PRD.md) |
| Missed days / catch-up | Empathy first, then a concrete plan and choice | "You missed 3 days. Here is a 5-day catch-up that still completes your cycle." | "You're behind.", "N days lost", red overdue pile | [Shen, 2010](https://academic.oup.com/hcr/article-abstract/36/3/397/4107508); [PRD §7.9](../PRD.md) |
| Budget overflow | Honest tradeoff stated as the user's choice, not a verdict | "Today's scope doesn't fit your time. You can raise the budget, lengthen the cycle, or pause new sabaq." | Silently dropping manzil; "do more" | [Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x); [PRD §12.2, §7.12](../PRD.md) |
| Teacher sign-off | Defer to the teacher; the app records, the teacher decides | "Recorded with your teacher's sign-off." | "Approved by the app", overriding the teacher | [Yasien Mohamed, 2023](https://yaqeeninstitute.org/read/paper/etiquette-as-spiritual-nourishment-the-adab-of-the-student-according-to-al-ghazali-and-al-isfahani); [PRD R6](../PRD.md) |
| Errors | Cause, consequence, next step; no blame, no mascot apology | "Couldn't read this backup file. The password may be wrong — try again. Your data on this phone is unchanged." | "Oops!", "Something went wrong" with no path | [M3 Content design](https://m3.material.io/foundations/content-design/overview) |
| Resume after a gap | Resume silently into the normal day | (normal Today screen) | "Welcome back! You haven't opened the app in N days." | [Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full); [PRD R3](../PRD.md) |

- **Notification copy** uses the calmest rows only: one neutral daily line ("Your revision for today is ready") and an optional, framed-as-help catch-up note, both fully silenceable with no nagging escalation ([PRD §14](../PRD.md)); motion and haptics on arrival stay in the restrained vocabulary ([06-motion-and-haptics.md](06-motion-and-haptics.md)).

**Anti-patterns — we will never:**
- Let any row drift into command, praise theatre, or alarm — the tone moves between *calm* and *empathetic*, never into *pressuring*.
- Show a red "overdue" pile or a broken-streak state after missed days; catch-up is re-spread, never shame ([PRD §7.9](../PRD.md)).
- Greet a returning user with "Welcome back!" or any cheerful resumption that implies they lapsed.

---

## 4. Lead with empathy when the news is hard; never with blame

**Statement.** The app must sometimes deliver hard news — a juz is decaying, a backlog has built up, a page has lapsed, the day won't fit the budget. Every such message opens with **understanding**, then offers a **calm path forward and a real choice**. It never opens with fault, and never amplifies the fear a ḥāfiẓ already carries.

**Evidence.**
- Message-induced **empathy mitigates psychological reactance** and contributes to persuasion above and beyond a message's affective and cognitive content, partly by reducing anger and counter-arguing ([Shen, 2010, HCR 36(3):397–422](https://academic.oup.com/hcr/article-abstract/36/3/397/4107508)). Leading with "life interrupts; here is a calm way back" is therefore both kinder *and* more effective than leading with blame.
- Loss-framed, negatively-valenced appeals raise guilt, shame, and fear, which spill into anger and *increase* reactance, producing boomerang effects ([Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full)). For this audience the effect is acute: forgetting already carries real spiritual weight, so amplifying that fear manufactures the very anxiety [PRD R3](../PRD.md) forbids.
- Restoration-of-freedom framing ("the choice is yours") and provision of choice are the documented repairs for a freedom-threat ([Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)). Hard news must therefore end in *options the user owns*, not a single mandated fix.

**In practice.**
- **The empathy-then-path template** governs every hard-news string: (1) a calm, non-blaming acknowledgment, (2) the honest fact, (3) a concrete path, (4) the user's choices. Missed-day catch-up is the canonical instance: *"You missed 3 days — here is a 5-day catch-up plan that still completes your cycle."* ([PRD §7.9](../PRD.md)) — re-spread, never a dump.
- **Budget honesty** never silently lets pages rot: when scope can't fit the time, the app states the tradeoff and surfaces the three real choices — raise budget / lengthen cycle / pause new sabaq — as equal options, never as a "you should do more" ([PRD §12.2](../PRD.md); [Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full)).
- **Visual register matches the verbal one:** decay is shown as green *receding* to a muted neutral, never an alarming red scoreboard, so the copy and the heat-map tell the same calm, honest story ([08-data-visualization.md](08-data-visualization.md), [03-color-and-themes.md](03-color-and-themes.md)). Catch-up banners use `type.body` on a calm surface container, with the plan's numerals in the locale set ([12](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Open a decay, lapse, or backlog message with fault ("You're behind," "You let this slip").
- Use loss imagery or the spiritual stakes as leverage — "You'll lose your hifz" is the exact backfiring appeal we forbid ([PRD R3](../PRD.md)).
- Deliver hard news without a path forward and without leaving the choice with the user.

---

## 5. Speak as a gentle teacher's aide — never *for* the Quran, never as an authority

**Statement.** *Adab* constrains not only *how* the app speaks but *what it may claim to be*. The app is a servant to the *talaqqī* chain: it surfaces methodology and information, but it never issues a ruling, never declares a page "safe to drop," never speaks *on behalf of* the Quran, and never pronounces on the user's spiritual state. A teacher's sign-off always outranks the machine.

**Evidence.**
- The classical *adab* model places the app on the gentle, encouraging *teacher's* side of the relationship, with the Quran and the user's relationship with Allah held above the software ([Yasien Mohamed, 2023](https://yaqeeninstitute.org/read/paper/etiquette-as-spiritual-nourishment-the-adab-of-the-student-according-to-al-ghazali-and-al-isfahani)). [PRD R6](../PRD.md) makes this binding: teacher sign-off is a first-class grade that overrides any self-rating or algorithmic state.
- Controlling, authoritative language provokes reactance ([Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)); an app that *over-claims* authority over a teacher or the text both violates *adab* and risks rejection. The autonomy-supportive register — aid, not authority — is the same lever that reduces reactance ([Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full)).

**In practice.**
- **The forbidden sentence:** the app never says, implies, or visually signals that a page is "safe to drop" or "mastered" — [PRD §7.12](../PRD.md) makes this an engine invariant, and the copy mirrors it: progress language is "weakening / strengthening / due," never "done with."
- **No rulings, ever:** the app states methodology ("this is how the cycle is built") and never a fiqh ruling; where a scholar's sign-off is pending (the regional terminology, the mutashābihāt dataset, the endorser), copy stays "aid to revision" and explicitly flags "needs scholarly review" ([PRD §13.4, §21](../PRD.md); [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md)).
- **Teacher defers, app records:** sign-off copy credits the teacher ("Recorded with your teacher's sign-off"), never the app ("Approved"); in local halaqa mode the profile switcher copy frames the teacher as the one verifying, the device as the ledger ([PRD §8.2, §15.3](../PRD.md)).
- **It never speaks for the Quran or for Allah:** no copy interprets verses, assigns spiritual reward, or pronounces on the user's standing — the riwāyah is named specifically and the boundary held ([PRD R2](../PRD.md)).

**Anti-patterns — we will never:**
- Say or imply a page is "safe to drop," "mastered," or "finished" — it contradicts an engine invariant and the honesty pillar.
- Issue a fiqh ruling, interpret a verse, or speak *on behalf of* the Quran or Allah.
- Phrase the app as overriding, grading, or out-ranking a present teacher.

---

## 6. Phrase as invitation and information, never as command

**Statement.** Default copy suggests and informs; it never commands. The mandate words — "you must," "you have to," "you should," "don't" — and scolding imperatives are banned from product copy, because they provoke reactance and message rejection, the opposite of what a daily revision aid needs.

**Evidence.**
- Psychological Reactance Theory holds that people are "aversively aroused when perceived freedoms are threatened," and reactance "is more likely to occur when messages are controlling (containing orders and words like 'should,' 'have to,' and 'must')" ([Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full)). The canonical experiment found controlling language produced "a number of negative outcomes," and restoration-of-freedom postscripts repaired them ([Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)).
- **Honest calibration (an [OBS]-grade null result we will not overstate):** a randomized online trial testing "could" vs. "should" wording found *no significant difference* in perceived autonomy support or reactance in an already-cooperative, low-threat context ([Altendorf et al., 2019, *Digital Health*](https://pmc.ncbi.nlm.nih.gov/articles/PMC6393822/)). The lesson is calibration, not abandonment: the marginal persuasion gain from softer wording can be small, but the *downside* of controlling wording is well-documented and asymmetric, so the safe default for a reverence-first product remains autonomy-supportive phrasing — adopted on principle (*adab*) even where the measured delta is modest.

**In practice.**
- **Statements of readiness over orders:** "Your revision for today is ready" not "Revise now" ([PRD §14](../PRD.md)); "You can change this anytime" appended where a setting affects the schedule.
- **Restoration-of-freedom by default:** the cycle, budget, and pace are the user's — named cycles, the daily budget, and Pure-cycle mode are framed as the user's choices, and copy reminds them so ([PRD §7.11, §15.1](../PRD.md); [Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)).
- **Provision of choice over a single mandate:** where guidance is needed, offer options ("raise budget / lengthen cycle / pause new sabaq"), never dictate one fix ([PRD §12.2](../PRD.md)).
- **A banned-phrase lint** asserts no controlling pattern ships in any locale; because the imperative carries differently per language (a bare Arabic command verb reads curt; Persian over-formality reads cold), the lint is paired with native review (§9).

**Anti-patterns — we will never:**
- Ship "you must," "you have to," "you should," "don't," or scolding imperatives in default copy, in any locale.
- Strip the user's choice out of a guidance message by mandating one resolution.
- Treat the app's schedule as something owed *to* the app rather than chosen *by* the user.

---

## 7. No transactional or pressuring framing — worship is served, not managed

**Statement.** Revision is never framed as a transaction with, or a debt owed to, the app. There is no "upgrade," no manufactured urgency, no engagement-for-its-own-sake. The user is a guest being served, and the copy must actively *support* their autonomy, competence, and relatedness.

**Evidence.**
- A study of 11 Islamic lifestyle apps through self-determination theory found that most *fail* to foster autonomy, competence, and relatedness — the three needs that determine whether a tool feels supportive or controlling — and that worship-context users judge an app on whether it *supports* their autonomy, not on engagement metrics ([Kabir, Kabir & Islam, 2024, arXiv:2402.02061](https://arxiv.org/abs/2402.02061)). The project's own market research records explicit user discomfort with the "transactional model of spiritual engagement," with paywalled or pressuring worship features experienced as "disheartening" ([RESEARCH-FINDINGS §4](../../research/RESEARCH-FINDINGS.md)).
- This converges with the *adab* evidence (§1) and the reactance evidence (§3, §6): in a worship context, the non-transactional, autonomy-supportive register *is* what the audience experiences as respect, and its absence is experienced as a violation.

**In practice.**
- **The app is free as *ṣadaqah jāriyah*** and the copy reflects it: no "upgrade," no premium nags, no SKU language anywhere ([PRD intent; §17](../PRD.md)). This is structural, not a tone choice — there is nothing to sell.
- **No manufactured urgency:** the daily reminder is one calm, optional line; there are no engagement streaks, no "keep your streak," no escalating nags ([PRD §14, R3](../PRD.md); the evidence against streaks-as-pressure lives in [`research/calm-non-gamified-design.md`](research/calm-non-gamified-design.md)).
- **Competence and relatedness are supported, not exploited:** progress copy describes the user's own retention honestly (the heat-map, weakest-pages list) so the user feels capable, and the teacher/halaqa framing supports the human relationship rather than substituting a social feed for it ([PRD §12.5, §15.3](../PRD.md); [08-data-visualization.md](08-data-visualization.md)).

**Anti-patterns — we will never:**
- Use "upgrade," "premium," "unlock," paywall, or any commercial-transaction language.
- Manufacture urgency, scarcity, FOMO, or streak-pressure to drive opens ([RESEARCH-FINDINGS §4](../../research/RESEARCH-FINDINGS.md)).
- Frame revision as a debt to the app or measure the user against an engagement target.

---

## 8. One voice across fa/ar/ckb requires transcreation, not literal translation

**Statement.** The same calm, reverent, non-coercive voice must survive the move into Persian, Arabic, and Kurdish Sorani — but pronoun, register, and the imperative do **not** map across these languages, so a literal translation would silently change the tone. Strings are **transcreated** to preserve the *feeling*, governed by one voice charter, and reviewed per locale.

**Evidence.**
- Maintaining one voice across languages "requires more than direct translation … direct translations rarely capture the tone, style, and intent of your original message"; transcreation recreates content so it "evokes the same emotional response and intent as the original" ([Smartling, *Transcreation vs. Translation*](https://www.smartling.com/blog/six-ways-transcreation-differs-from-translation); [*Transcreation*](https://en.wikipedia.org/wiki/Transcreation)). Material 3's own global-writing guidance frames localization as adapting voice for cultural fit, not word-for-word substitution ([Material Design 3: Global writing](https://m3.material.io/foundations/content-design/global-writing)).
- **Persian** carries a grammaticalised politeness/honorific system bound up with *taʿārof*: the formal *šomā* and honorific verb forms are conventionally polite, but Izadi (2015) shows honorifics "may not necessarily lead to positive evaluations" — politeness is evaluated *in interaction*, so register is a deliberate stance (warm-respectful), never a dictionary default ([Izadi, 2015, *Journal of Pragmatics* 85:81–91](https://www.sciencedirect.com/science/article/abs/pii/S0378216615001794)).
- **Arabic** has no single egalitarian "you": the second person splits by number and gender, with address terms and titles adding layers, and politeness/power dynamics drive which form is appropriate ([Al-Hamzi, Nababan, Santosa & Anis, 2024, *Cogent Arts & Humanities* 11(1)](https://www.tandfonline.com/doi/full/10.1080/23311983.2024.2359764)). A bare command verb reads curt, so directives must be mitigated into statements of readiness.
- **Kurdish Sorani** has its own register conventions, and — per [PRD §13.4](../PRD.md) — its religious-revision vocabulary (sabaq/manzil equivalents) is regional and still pending native-speaker + scholarly review, so its tone *cannot* be inferred from Persian or Arabic.

**In practice.**
- **A single voice charter** (the four attributes of §2) is the source of truth; the fa/ar/ckb strings in the ARB files (`gen_l10n`) are transcreated against it, never literally mapped ([PRD §13.6](../PRD.md)).
- **Per-locale register, set deliberately:**
  - **Persian** — respectful-warm: *šomā* / honorific verb forms as a calm stance, never cold over-formality nor the over-familiar *to*; *taʿārof*-aware phrasing that reads as a private companion, not a clerk.
  - **Arabic** — number/gender-appropriate forms; **imperatives softened** into statements of readiness rather than bare commands.
  - **Kurdish Sorani** — register *and* religious vocabulary set by native reviewers against the charter; defaults are placeholders until that review lands ([PRD §13.4, §21](../PRD.md)).
- **Mechanics that protect the tone:** dates/numbers are formatted via `intl` per locale (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) in `type.numeral`, never concatenated; mixed Latin/numeric runs inside RTL copy are wrapped in bidi isolation (FSI/PDI) so a page number or URL never breaks the right-to-left line; sentence fragments are never glued together (RTL word order will not survive it) ([12-localization-and-rtl.md](12-localization-and-rtl.md); [Material Design 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).

**Anti-patterns — we will never:**
- Literally translate strings across fa/ar/ckb and let register or tone drift silently.
- Assume the three languages share a register, or infer Sorani religious vocabulary from Persian or Arabic.
- Concatenate sentence fragments or hard-code numerals/dates, which breaks both grammar and the calm register in RTL.

---

## 9. Tone is a per-locale QA gate — banned-phrase lint plus native and scholar review

**Statement.** Tone is not left to good intentions: it is *auditable* and *release-blocking*. Every user-facing string passes an automated banned-phrase lint and a human review in each locale — native speaker for register, and, for religious terminology, a scholar — checking that the calm-reverent-non-coercive *feeling* survived transcreation, not merely that the words are accurate.

**Evidence.**
- NN/g's four-dimension model exists precisely to make tone auditable: a string can be scored on each axis and checked against the target ([Moran, 2016/2023](https://www.nngroup.com/articles/tone-of-voice-dimensions/)). Transcreation must be *reviewed* to confirm the emotional intent carried, because the words alone don't guarantee it ([Smartling](https://www.smartling.com/blog/six-ways-transcreation-differs-from-translation)).
- The reactance and guilt-appeal evidence makes specific phrases *harmful*, not merely off-brand, which is what justifies a release-blocking lint rather than a soft style note ([Reynolds-Tylus, 2019](https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full); [Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)).

**In practice.**
- **The never-ship list** (a copy-lint, release-blocking, run on every locale) blocks: guilt/fear/loss framing ("You'll lose your hifz," "You're falling behind," "You haven't opened the app in N days," "Don't break your streak"); controlling mandates ("you must / have to / should," "don't"); "safe to drop" / "mastered" / "done"; exclamation marks and emoji in product copy; and any commercial-transaction word ("upgrade," "premium," "unlock"). Each entry traces to a cited harm above, not a preference.
- **Human review per locale** (PRD §20.5 localization gate): a native speaker checks register and naturalness in fa/ar/ckb; a scholar additionally reviews religious terminology and any methodology-adjacent wording (terms, mutashābihāt, honorifics) ([PRD §13.4, §20.5, §21](../PRD.md)). An RTL voice-screenshot pass per locale confirms the tone *and* the bidi/numeral rendering visually ([12-localization-and-rtl.md](12-localization-and-rtl.md), [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).
- **Coverage gate:** zero missing ARB keys and zero hardcoded user-facing strings, so no string can escape the voice review ([PRD §13.6, §20.5](../PRD.md)).

**Anti-patterns — we will never:**
- Treat a banned phrase as a style nit; a string matching a never-ship pattern fails the build.
- Ship a locale on literal-translation accuracy alone, without a native-speaker register review.
- Ship religious or methodology-adjacent copy without scholarly review where one is pending.

---

## References

- *Adab (Islam)* — overview of the Islamic concept of refinement, manners, and decorum as spiritual practice. Wikipedia. https://en.wikipedia.org/wiki/Adab_(Islam)
- Al-Hamzi, A. M. S., Nababan, M., Santosa, R., & Anis, M. Y. (2024). Socio-pragmatic analysis of utterances with polite addressing terms: translation shift across Arabic-English cultures. *Cogent Arts & Humanities*, 11(1), 2359764. https://www.tandfonline.com/doi/full/10.1080/23311983.2024.2359764
- Altendorf, M. B., van Weert, J. C. M., Hoving, C., & Smit, E. S. (2019). Should or could? Testing the use of autonomy-supportive language and the provision of choice in online computer-tailored alcohol reduction communication. *Digital Health*, 5. (Reports a null result; cited for honest calibration.) https://pmc.ncbi.nlm.nih.gov/articles/PMC6393822/
- Izadi, A. (2015). Persian honorifics and im/politeness as social practice. *Journal of Pragmatics*, 85, 81–91. https://www.sciencedirect.com/science/article/abs/pii/S0378216615001794
- Kabir, M., Kabir, M. R., & Islam, R. S. (2024). Islamic Lifestyle Applications: Meeting the Spiritual Needs of Modern Muslims. arXiv preprint arXiv:2402.02061. https://arxiv.org/abs/2402.02061
- Material Design 3. *Content design — Write effective content.* Google. https://m3.material.io/foundations/content-design/overview
- Material Design 3. *Global writing — Writing for localization and translation.* Google. https://m3.material.io/foundations/content-design/global-writing
- Material Design 3. *Bidirectionality & RTL.* Google. https://m3.material.io/foundations/layout/bidirectionality-rtl
- Miller, C. H., Lane, L. T., Deatrick, L. M., Young, A. M., & Potts, K. A. (2007). Psychological Reactance and Promotional Health Messages: The Effects of Controlling Language, Lexical Concreteness, and the Restoration of Freedom. *Human Communication Research*, 33(2), 219–240. https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x · Open record: https://eric.ed.gov/?id=EJ755929
- Moran, K. (2016, updated 2023). *The Four Dimensions of Tone of Voice.* Nielsen Norman Group. https://www.nngroup.com/articles/tone-of-voice-dimensions/
- Q 16:125 (Sūrat al-Naḥl) — "Invite to the way of your Lord with wisdom and good instruction…" with classical tafsīr. Quran.com. https://quran.com/en/an-nahl/125
- Reynolds-Tylus, T. (2019). Psychological Reactance and Persuasive Health Communication: A Review of the Literature. *Frontiers in Communication*, 4:56. https://www.frontiersin.org/journals/communication/articles/10.3389/fcomm.2019.00056/full
- Ṣaḥīḥ Muslim 2594a — ʿĀʾisha (raḍiya Allāhu ʿanhā), the Prophet ﷺ on *al-rifq* (gentleness): "gentleness is not found in anything except that it beautifies it…" Sunnah.com. https://sunnah.com/muslim:2594a
- Shen, L. (2010). Mitigating Psychological Reactance: The Role of Message-Induced Empathy in Persuasion. *Human Communication Research*, 36(3), 397–422. https://academic.oup.com/hcr/article-abstract/36/3/397/4107508
- Smartling. *Six Ways Transcreation Differs from Translation.* https://www.smartling.com/blog/six-ways-transcreation-differs-from-translation
- *Transcreation* — overview of recreating content to preserve emotional intent across languages. Wikipedia. https://en.wikipedia.org/wiki/Transcreation
- Yasien Mohamed (2023). *Etiquette as Spiritual Nourishment: The Adab of the Student According to al-Ghazali and al-Isfahani.* Yaqeen Institute for Islamic Research. https://yaqeeninstitute.org/read/paper/etiquette-as-spiritual-nourishment-the-adab-of-the-student-according-to-al-ghazali-and-al-isfahani
