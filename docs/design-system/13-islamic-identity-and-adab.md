# 13 — Islamic Identity & Adab

This file governs the app's **Islamic visual identity and its *adab* toward the muṣḥaf** — the reverence, restraint, and honesty that make Hifz Companion behave like an act of worship before it behaves like a product. It is the synthesis of Pillar 1 (*reverence first*) and the place where Pillars 2 (*calm, not cute*), 3 (*tradition is the interface*), and 7 (*servant to the teacher*) are read specifically through the lens of *adab* — the Islamic ethic of refined, humble, respectful conduct ([*Adab (Islam)*](https://en.wikipedia.org/wiki/Adab_(Islam))). The governing idea is the one the README opens with: an app holding the Quran is an act of *adab* before it is a product, and must behave like one. This file does **not** own a token family. It composes the calm palette from [03-color-and-themes.md](03-color-and-themes.md), the strict sacred-vs-UI type separation from [04-typography.md](04-typography.md), the restrained motion vocabulary from [06-motion-and-haptics.md](06-motion-and-haptics.md), the non-coercive wording from [11-voice-and-tone.md](11-voice-and-tone.md), the RTL/numeral/calendar mechanics from [12-localization-and-rtl.md](12-localization-and-rtl.md), and the heat-map honesty from [08-data-visualization.md](08-data-visualization.md). It sets the *constraints those files must satisfy* when the thing being designed touches the words of Allah. The locked product requirements behind it are PRD R1 (text fidelity), R2 (state the riwāyah, stay neutral), R3 (no gamification of the sacred), and R6 (servant to the talaqqī chain) ([PRD §4](../PRD.md)).

## At a glance

| Question of adab | Decision | Evidence anchor | Cross-ref |
|---|---|---|---|
| What is the unit of reverence? | The faithful muṣḥaf **page** — rendered through per-page glyph fonts, never re-typeset | QUL glyph-based fonts; al-Nawawi, *al-Tibyān* | [04](04-typography.md) |
| Where does reverence live? | In **intent and presentation**, not device ritual-gating | Contemporary fatāwā (screen ≠ muṣḥaf) | this file |
| May we decorate the sacred text? | No — chrome defers to the words; markers are diagnostic, never ornament | Ayah "no dashboard"; Islamic HCI (CHI '26) | [01](01-design-principles.md) |
| May we gamify completing a juz? | No — extrinsic rewards corrode intrinsic worship motivation | Deci, Koestner & Ryan 1999 | [06](06-motion-and-haptics.md) |
| Whose Quran is shown? | "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf," never "the Quran" absolutely | PRD R2; Tanzil license (verbatim, attributed) | [12](12-localization-and-rtl.md) |
| Who has authority? | The teacher and the *sanad* — the app serves *talaqqī*, never rules | al-Nawawi; PRD R6 | [11](11-voice-and-tone.md) |
| How is identity expressed visually? | Quiet geometric restraint (the *miḥrāb* niche), never figurative or saturated ornament | Valdez & Mehrabian 1994; aniconism tradition | [03](03-color-and-themes.md) |

---

## 1. The muṣḥaf page is the unit of reverence — render it faithfully, never re-typeset it

**Statement.** The single most important act of *adab* this app performs is rendering the Quran the way the printed muṣḥaf is set — page-faithful, line-for-line, through bundled per-page glyph fonts — and never asking the OS to lay out sacred text. The page is simultaneously the unit of reverence and the unit of memory; preserving it is both adab and a retention feature.

**Evidence.**
- The standard print-grade production stack is **glyph-based per-page fonts**: the KFGQPC "QPC/QCF" fonts distributed through the Quranic Universal Library, in which **each of the 604 muṣḥaf pages has its own font** and **each glyph is a whole pre-drawn word**, not a character the OS shaper assembles — QUL states you "need 604 fonts files to render the whole Quran" and that such fonts are "handcrafted and often used in printing Quranic manuscripts" ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)). Removing the OS shaper from the path is *fidelity insurance*: it is the layer where broken ligatures and dropped or duplicated diacritics appear, and a single wrong diacritic in sacred text is unacceptable (PRD R1).
- The classical scholarship makes preservation of the muṣḥaf an obligation, not an aesthetic preference: Imām al-Nawawī, in *al-Tibyān fī Ādāb Ḥamalat al-Qurʾān* (the canonical manual on the etiquette of those who carry the Quran), holds that honouring and preserving the muṣḥaf is *wājib* — the scholars "decided that it is *wājib* to preserve the muṣḥaf of the Quran and to honour it" ([al-Nawawī, *Etiquette With the Quran*, trans. M. Furber](https://archive.org/details/nawawi-tibyan-tr.-m.-furber-etiquette-with-the-quran-1)). Digital fidelity is the contemporary form of that preservation.
- The fixed page also *carries* memory. Greentech Apps Foundation ships a dedicated "Mushaf Mode" precisely because "consistency in mushaf layouts helps memorization by building **photographic memory**," used by "students of knowledge and people doing hifz" ([GTAF: Mushaf Mode](https://gtaf.org/blog/mushaf-mode-in-quran-app/)). For a ḥāfiẓ, *where on the page* a verse sits is part of the retrieval cue; reflowing destroys it.

**In practice.**
- Every page renders by selecting that page's dedicated QPC glyph font and drawing its glyph codepoints — the font *is* the typeset page. The OS shaper is never asked to lay out Quran text; line and page breaks come only from the bundled layout dataset ([04-typography.md](04-typography.md); [PRD §11.2](../PRD.md)).
- These QPC glyph fonts are deliberately **not design tokens.** Unlike `type.body` or `type.title` (UI type, owned by [04-typography.md](04-typography.md)), the muṣḥaf fonts are immutable bundled assets governed by this pillar and PRD R1 — they are *referenced, never restyled, never re-weighted, never substituted* for a "nicer" face.
- Every marker — weak-line highlight, mutashābihāt anchor, current-ayah indicator — is drawn as **coordinates/rectangles over the immutable glyph layer**, computed from the bundled line/word geometry, never by editing or reconstructing text ([08-data-visualization.md](08-data-visualization.md); [07-components.md](07-components.md)). Zoom, sepia, and dark themes transform the rendered layer, not the text.
- This holds identically across fa/ckb/ar: the UI chrome localizes, but the muṣḥaf is always the same Uthmani QPC page regardless of UI language — the Quran is never "translated" or restyled per locale ([12-localization-and-rtl.md](12-localization-and-rtl.md); [PRD §13.1](../PRD.md)).

**Anti-patterns — we will never:**
- Ask the OS text shaper to lay out Quran text, reflow a page, or compute line breaks at runtime — a single dropped or altered diacritic ends the project (PRD R1).
- Treat the muṣḥaf glyph fonts as a styleable token, substitute a "prettier" Arabic face for them, or apply a UI type ramp to the sacred text.
- Reconstruct, store, or re-typeset Quran text to draw a highlight; markers are always an overlay of coordinates on the immutable page.

---

## 2. Reverence lives in intent and presentation, not in gating the device

**Statement.** Because a screen is not itself the bound muṣḥaf, the burden of *adab* shifts from ritual purity of the object to the **presentation and the user's state of mind**. The app expresses reverence by how it frames and protects the sacred — not by locking access behind device rituals it has no authority to impose.

**Evidence.**
- Classical jurists ruled on touching the **physical muṣḥaf** without *wuḍūʾ* (citing Q 56:79 and related reports). Contemporary fatāwā widely hold that **reading Quran from a screen does not require wuḍūʾ**, because "touching a screen is touching glass and circuits, not the sacred text itself," and the display is an electronically rendered image rather than the bound codex ([Alhannah: Reading Quran Online Without Wudu](https://blog.alhannah.com/can-you-read-the-quran-online-without-wudu-understanding-islamic-etiquette-in-the-digital-age/); [Mizan ul Muslimin](https://www.mizanulmuslimin.com/2025/03/do-you-need-wudu-for-quran.html)). *(These summarise scholarly positions; the app surfaces methodology and issues no ruling — madhhab/sect-neutral, "needs scholarly review.")*
- A retention app whose primary act is **reciting from memory** sits even further from the touching-the-muṣḥaf question: recitation from memory requires neither touching nor wuḍūʾ by consensus. This frees the design to focus reverence on **tone, framing, and the dignity of the page** rather than on gating ([Mizan ul Muslimin](https://www.mizanulmuslimin.com/2025/03/do-you-need-wudu-for-quran.html)).
- The same sources still commend approaching the text mindfully "as a sign of respect," creating "a mindful and reverent environment" — so the design *invites* a reverent state without lecturing or compelling it ([Mizan ul Muslimin](https://www.mizanulmuslimin.com/2025/03/do-you-need-wudu-for-quran.html)).

**In practice.**
- The app **does not require wuḍūʾ, a vow, or any ritual to open** — gating worship is not the app's place. It may offer a calm, *optional, dismissible* opening framing (e.g. a quiet *taʿawwudh* / basmalah line and a distraction-free entry) that invites a mindful state, set in `type.body` on `color.bg.primary` with no animation flourish ([03-color-and-themes.md](03-color-and-themes.md); [06-motion-and-haptics.md](06-motion-and-haptics.md)).
- Any etiquette guidance the app surfaces is presented as **attributed methodology**, sect-neutral, flagged "needs scholarly review," and never as a ruling the user is judged against ([11-voice-and-tone.md](11-voice-and-tone.md)).
- Reverence is enacted instead through restraint everywhere the words appear: no ad ever beside an āyah, no pop-up over the page, no celebratory effect on the sacred text (see §3, §4).

**Anti-patterns — we will never:**
- Gate the muṣḥaf or the daily revision behind a wuḍūʾ prompt, a piety pledge, or any ritual checkpoint — the app has no authority to impose ritual conditions and will not perform piety theatre.
- Issue a fiqh ruling on handling the muṣḥaf; etiquette is offered as attributed, optional methodology and flagged for scholarly review.
- Make an optional reverent framing mandatory, unskippable, or guilt-laden.

---

## 3. Never decorate, animate, or trivialize the sacred text — the chrome defers to the words

**Statement.** *Adab* in a digital muṣḥaf is, concretely, that **nothing the app adds ever sits decoratively on top of the words of Allah.** Identity is expressed by *removing* ornament from the sacred surface, not adding it; every marker on the page is diagnostic, never congratulatory or decorative.

**Evidence.**
- In this category, perceived quality correlates with *removing* UI. **Ayah**, winner of the Kuwait International Prize for the Holy Quran, is praised for a "clean, intuitive interface… **without any visual clutter**," presenting "the noble Quran itself **with no dashboard**," mimicking a physical muṣḥaf ([Ayah — App Store](https://apps.apple.com/us/app/ayah-quran-app/id706037876)). The highest compliment is that the interface disappears and only the muṣḥaf remains.
- The emerging field of **Islamic HCI** argues that faith-based design should be "grounded in a distinct value system… Islamic epistemology," foregrounding "faith-based reasoning, ethical accountability, and communal responsibility" — a frame under which decorating or gamifying an act of worship is an *ethical* choice, not a neutral engagement one ([*Decoding Islamic HCI*, CHI '26](https://dl.acm.org/doi/10.1145/3772318.3791954)).
- The case against ornament on the *text itself* is reinforced by color-emotion research: arousal is driven primarily by saturation, so a saturated, ornamental, attention-grabbing treatment is the opposite of the low-arousal reverence a worship surface needs ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)). The sacred page must be the calmest place in the app.

**In practice.**
- **The reader is "no dashboard."** When a page is shown, the words dominate; chrome recedes to the edges. There are no counters, badges, mascots, or progress rings layered over an āyah ([01-design-principles.md](01-design-principles.md); [07-components.md](07-components.md)).
- Markers are strictly **diagnostic, never decorative or congratulatory**: a weak/decaying line may be flagged with a calm `color.semantic.warning` overlay; nothing ever marks "you completed this" with confetti, a star, or a flourish ([03-color-and-themes.md](03-color-and-themes.md); [08-data-visualization.md](08-data-visualization.md)).
- Page-feel skeuomorphism stays sober: a clean RTL page-turn is allowed; **flip sound effects, ornamental gilt borders drawn over the text, and celebratory motion are not** ([06-motion-and-haptics.md](06-motion-and-haptics.md)). The muṣḥaf is paged, never infinite-scrolled, because page position is itself a retrieval cue ([PRD §11.2](../PRD.md)).
- Honorifics and correct transliteration are the *one* form of "decoration" that is actually adab: ﷺ after the Prophet's name, *raḍiya Allāhu ʿanhu* where companions are named, and correct forms (*ḥāfiẓ*, *murājaʿa*, *mutashābihāt*, *talaqqī*, *muṣḥaf*, *riwāyah*) — small markers, in `type.body`, that signal the app knows whose text it handles ([11-voice-and-tone.md](11-voice-and-tone.md)).

**Anti-patterns — we will never:**
- Place a badge, counter, mascot, sticker, cartoon, or celebratory animation on top of, or attached to, an āyah or a page.
- Draw ornamental borders, glow, drop-shadows, or saturated decorative color *over* the sacred glyph layer for visual appeal.
- Add page-flip sound effects, haptic celebrations, or any flourish to the act of opening or finishing Quran text.

---

## 4. Never gamify worship — extrinsic rewards corrode the very motive they target

**Statement.** Streaks, XP, badges on āyāt, leaderboards, and confetti on completing a juz are forbidden — not merely as taste, but because bolting an extrinsic-reward economy onto an intrinsically meaningful act of worship measurably *undermines* the worshipper's own motive. The only feedback the app gives is honest, non-controlling competence feedback.

**Evidence.**
- The definitive evidence is the meta-analysis by **Deci, Koestner & Ryan (1999)** of **128 experiments** in *Psychological Bulletin*: engagement-, completion-, and performance-contingent tangible rewards **significantly undermined free-choice intrinsic motivation** (d = −0.40, −0.36, −0.28), while the one thing that *helped* was non-controlling **positive feedback** (free-choice d = +0.33) ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)). A badge for finishing a juz risks *replacing* the worshipper's intrinsic reason with the app's token; "this page is solid, that one is decaying" does not.
- This rests on **self-determination theory**: durable motivation comes from autonomy, competence, and relatedness, and *controlling* approaches (rewards, pressure, surveillance) erode initiative ([Ryan & Deci, 2000](https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf)). The Islamic-app HCI study finds the field over-invests in extrinsic gamification and under-invests in exactly these needs ([Kabir et al., 2024](https://arxiv.org/abs/2402.02061)).
- For worship the stakes are sharper still: the intended motive is *seeking the pleasure of Allah*, and the tradition centres the reward of the act in itself — "the best among you are those who learn the Quran and teach it" ([Ṣaḥīḥ al-Bukhārī 5027](https://sunnah.com/bukhari:5027)). Substituting a points economy is both psychologically risky and spiritually backwards.

**In practice.**
- The entire extrinsic-reward apparatus is **replaced by honest competence feedback**: the calm whole-Quran retention heat-map ("keep your Quran green"), the weakest-pages surfacing, and a feasible daily plan — the one form of feedback the meta-analysis shows *helps* ([08-data-visualization.md](08-data-visualization.md)).
- The heat-map is shown as green *receding* to a muted neutral, never as an alarming red scoreboard, with juz health rolled up by a **min-leaning** aggregate; it informs and never becomes a streak to defend ([08-data-visualization.md](08-data-visualization.md); [PRD §10.3](../PRD.md)).
- Any optional continuity indicator is **private, opt-in, and never punitive** — there is no broken-streak shame state, anywhere, in any locale ([PRD §12.5](../PRD.md); [11-voice-and-tone.md](11-voice-and-tone.md)). Motion stays restrained: no confetti, no celebratory bounce, no haptic fanfare ([06-motion-and-haptics.md](06-motion-and-haptics.md)).

**Anti-patterns — we will never:**
- Add XP, points, levels, badges on āyāt, public leaderboards, or confetti/celebratory effects on completing a juz or a cycle (PRD R3, C6).
- Run a "ḥasanāt counter" or any points economy that quantifies worship into a score to chase.
- Ship a punitive streak, a "don't break your chain" nag, or any guilt/fear loss-framing — these weaponise the spiritual weight of forgetting (PRD R3; [11-voice-and-tone.md](11-voice-and-tone.md)).

---

## 5. State the riwāyah, attribute the text, and stay madhhab/sect-neutral

**Statement.** A core act of *adab* and neutrality is to never present the bundled muṣḥaf as "the Quran" in the absolute. The app names the transmission it ships, attributes the text faithfully, and carries no tafsīr, translation, or commentary that would silently encode a school of thought.

**Evidence.**
- The Quran is transmitted through multiple *riwāyāt*; naming the one in use is honest and neutral, and the architecture treats the muṣḥaf as a swappable asset so alternative layouts/riwāyāt can plug in without an engine rewrite ([PRD R2, §11](../PRD.md)). Presenting one transmission as the unqualified "Quran" misrepresents the tradition.
- The text source carries binding attribution and integrity conditions: the Tanzil Project license permits "copy and distribute **verbatim** copies" only when "its source (Tanzil Project) is clearly indicated, and a link is made to tanzil.net," and **"changing the text is not allowed"** ([Tanzil Quran Text License](https://tanzil.net/download/)). Faithful attribution is therefore both adab and a license obligation.
- Bundling tafsīr/translation "inevitably encodes a school of thought," so the product ships none — neutrality is preserved by omission, not by adjudicating between schools ([PRD R2](../PRD.md)).

**In practice.**
- The muṣḥaf in use is shown in-app as **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf,"** in settings and at onboarding, never as "the Quran" absolutely ([PRD §4 R2, §12.1](../PRD.md); [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- Source attribution (Tanzil for text; QUL for layout; KFGQPC for fonts) is surfaced in an About/Credits screen as a matter of adab and license compliance, with the integrity guarantee (checksum-verified, byte-for-byte) stated plainly ([PRD §11.1, §17](../PRD.md); [10-privacy-and-trust-ux.md](10-privacy-and-trust-ux.md)).
- **Zero bundled tafsīr, translation, or commentary** in the product; the regional sabaq/sabqi/manzil terminology is localized and term-set-switchable, but the Quran text itself is identical across all three locales ([12-localization-and-rtl.md](12-localization-and-rtl.md); [PRD §13.4](../PRD.md)).

**Anti-patterns — we will never:**
- Label the bundled muṣḥaf as "the Quran" without its riwāyah, or imply one transmission is the only valid one.
- Bundle or surface tafsīr, translation, or commentary that takes a sectarian or madhhab position.
- Modify, re-encode, or strip attribution from the Tanzil text, or ship a muṣḥaf asset that fails its checksum (PRD R1; Tanzil license).

---

## 6. The app is a servant to the teacher and the sanad — never an authority over them

**Statement.** *Adab* toward the *talaqqī* chain means the app positions itself as the humble aide on the *teacher's* side of the relationship: it encourages and informs, but a teacher's sign-off always overrides the machine, and the app never claims the authority of a teacher, a muftī, or the Quran itself.

**Evidence.**
- Classical adab frames seeking knowledge as built on three relations — toward the self, the **teacher**, and knowledge itself — and instructs the teacher's side to be gentle: "kind and compassionate towards his students… guiding gently, always encouraging them but never stifling them" ([Yasien Mohamed, Yaqeen Institute, 2023](https://yaqeeninstitute.org/read/paper/etiquette-as-spiritual-nourishment-the-adab-of-the-student-according-to-al-ghazali-and-al-isfahani)). The app stands on the teacher's gentle, encouraging side of that ethic.
- The transmission of the Quran is itself a chain of oral correction (*talaqqī*) certified by *ijāza/sanad*; a software scheduler can serve that chain but cannot be it, and reviewers of memorization apps note that a human teacher "provides accountability that streaks and badges can only **imitate**" ([Tarteel — App Store reviews](https://apps.apple.com/us/app/tarteel-ai-quran-memorization/id1391009396)). Faking that accountability with gamification is a hollow substitute; deferring to the human is adab.
- Controlling, commanding language provokes psychological reactance and can backfire, whereas autonomy-supportive framing persuades without alienating ([Miller et al., 2007, *Human Communication Research*](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)) — so the app's voice must read as a servant's, not a commander's.

**In practice.**
- **Teacher sign-off (talaqqī) is a first-class grade with `sourceConfidence = 1.0` that overrides self-rating and algorithmic state** for that page; self-rating alone can never push a page to the top retention tier ([PRD §8.2](../PRD.md); [07-components.md](07-components.md)). The sign-off control is plain and dignified, recorded in the append-only `review_log` with an optional teacher label — a local audit trail that honours the *sanad* idea without any server.
- Copy consistently frames the app as an **aid to revision, servant to the teacher** — it never issues a fiqh ruling, never says a page is "safe to drop," and never speaks *for* the Quran or pronounces on the user's spiritual state ([11-voice-and-tone.md](11-voice-and-tone.md); [PRD §7.12, R6](../PRD.md)).
- Where scholarly sign-off is still pending (Kurdish/Persian terminology, the mutashābihāt dataset, an endorser), copy stays "aid to revision" and flags "needs scholarly review" rather than asserting authority ([PRD §21](../PRD.md)).
- Local **halaqa/teacher mode** lets a teacher switch between student profiles on one device to sign off each — serving the in-person relationship, never replacing it with a remote dashboard ([PRD §15.3](../PRD.md)).

**Anti-patterns — we will never:**
- Let an algorithmic or self-rating state override a teacher's sign-off, or present the app's verdict as authoritative over a teacher.
- Issue a fiqh ruling, declare a page "safe to stop revising," or speak on behalf of the Quran or the user's spiritual standing (PRD §7.12).
- Replace the *talaqqī* relationship with gamified "accountability," or build any remote teacher-surveillance dashboard (PRD §15.3, C1).

---

## 7. Express identity through quiet, aniconic restraint — the *miḥrāb*, not the mascot

**Statement.** The app's Islamic visual identity is communicated by *calm geometric restraint* and orientation toward one purpose — the *miḥrāb* niche made interface — never by figurative imagery, saturated ornament, or playful character design. Restraint is the identity.

**Evidence.**
- The design system is named for the **miḥrāb** — the niche marking the qibla, "the quietest, most reverent point in the room: undecorated stone or tilework whose entire purpose is orientation, not ornament" ([README](README.md)). The identity is *quietness oriented toward one thing*, which is exactly the calm-technology stance: "technology should require the smallest possible amount of attention," peripheral by default ([Case, 2015, *Principles of Calm Technology*](https://calmtech.com/)).
- Low arousal is not a vibe but a measurable target: emotional arousal is driven primarily by **saturation** (and brightness), not hue, so a restrained, desaturated, geometry-forward identity is the citable way to read as reverent rather than excitable ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)).
- The most-admired Quran interfaces win by **removing** ornament, not adding it ([Ayah — App Store](https://apps.apple.com/us/app/ayah-quran-app/id706037876)); and Islamic HCI frames faith-based design as an ethical, value-grounded discipline rather than an engagement-styling exercise ([*Decoding Islamic HCI*, CHI '26](https://dl.acm.org/doi/10.1145/3772318.3791954)). *(Assumption (uncited): the broad Islamic artistic preference for geometry, calligraphy, and arabesque over figurative depiction in sacred contexts informs the aniconic identity stance; this is a design posture, not a fiqh ruling, and is flagged for scholarly review.)*

**In practice.**
- Identity is carried by **geometry, calligraphic restraint, generous space, and a green-anchored calm palette**, never by figurative characters, faces, mascots, or cartoon Qurans ([03-color-and-themes.md](03-color-and-themes.md); [05-layout-spacing-touch.md](05-layout-spacing-touch.md)). Iconography is simple, sober, and functional; the app icon and empty states stay quiet and non-figurative.
- Color stays low-arousal: no saturated full-screen color, no celebratory hue shifts; the accent green is calm and the heat-map ramp is a single-hue lightness ramp, not a rainbow scoreboard ([03-color-and-themes.md](03-color-and-themes.md); [08-data-visualization.md](08-data-visualization.md)).
- The identity reads natively RTL by its very geometry — the niche points the way the script reads — so directionality is structural, not a mirrored afterthought, across fa/ckb/ar ([12-localization-and-rtl.md](12-localization-and-rtl.md)).
- Motion is reverent: short, standard-eased transitions; no bounce, no flourish, no attention-grabbing idle animation; Reduce Motion fully honoured ([06-motion-and-haptics.md](06-motion-and-haptics.md)).

**Anti-patterns — we will never:**
- Use figurative mascots, cartoon characters, anthropomorphic Qurans, or playful illustration as the app's identity.
- Reach for saturated, high-arousal color, neon accents, or ornamental "Islamic-themed" clip-art as decoration.
- Let visual identity drift into engagement styling; restraint and orientation are the brand, per the *miḥrāb* (README).

---

## References

- *Adab (Islam)* — overview of the Islamic concept of refinement, manners, and decorum as spiritual practice. Wikipedia. https://en.wikipedia.org/wiki/Adab_(Islam)
- al-Nawawī, Abū Zakariyyā Yaḥyā ibn Sharaf. *al-Tibyān fī Ādāb Ḥamalat al-Qurʾān* (*Etiquette With the Quran*), trans. Musa Furber. (Classical manual on the adab of those who carry the Quran; obligation to preserve and honour the muṣḥaf.) Internet Archive. https://archive.org/details/nawawi-tibyan-tr.-m.-furber-etiquette-with-the-quran-1
- Ṣaḥīḥ al-Bukhārī 5027 (Book 66, Hadith 49), narrated ʿUthmān (raḍiya Allāhu ʿanhu): "The best among you are those who learn the Qurʾān and teach it." Sunnah.com. https://sunnah.com/bukhari:5027
- Alhannah / Halal Living. *Can You Read the Qurʾān Online Without Wudu? Understanding Islamic Etiquette in the Digital Age* (contemporary fatāwā on screen vs. physical muṣḥaf; recommended adab). https://blog.alhannah.com/can-you-read-the-quran-online-without-wudu-understanding-islamic-etiquette-in-the-digital-age/
- Mizanul Muslimin. *Do You Need Wudu for the Quran? A Scholarly and Practical Guide* (touching glass ≠ touching the muṣḥaf; wuḍūʾ recommended as respect; recitation from memory). https://www.mizanulmuslimin.com/2025/03/do-you-need-wudu-for-quran.html
- Yasien Mohamed (2023). *Etiquette as Spiritual Nourishment: The Adab of the Student According to al-Ghazali and al-Isfahani.* Yaqeen Institute for Islamic Research. (Teacher's side of the relationship: gentle, encouraging, never stifling.) https://yaqeeninstitute.org/read/paper/etiquette-as-spiritual-nourishment-the-adab-of-the-student-according-to-al-ghazali-and-al-isfahani
- Quranic Universal Library (QUL), Tarteel. *Glyph-Based Fonts* (604 per-page KFGQPC/QPC fonts; each glyph a whole word; renders without OS shaping). https://qul.tarteel.ai/docs/glyph-based
- Greentech Apps Foundation (GTAF). *Mushaf Mode — Read the Quran in familiar Mushaf pages* (consistent layout builds photographic memory; used by huffaz; free charity app). https://gtaf.org/blog/mushaf-mode-in-quran-app/
- Ayah — Quran App (developer: Abdullah Bajaber). App Store listing (Kuwait International Prize; "clean, intuitive interface… without any visual clutter"; "no dashboard"; mimics a physical muṣḥaf). https://apps.apple.com/us/app/ayah-quran-app/id706037876
- Tarteel — *AI Quran Memorization* (App Store listing and reviews; reviewers note a teacher "provides accountability that streaks and badges can only imitate"). https://apps.apple.com/us/app/tarteel-ai-quran-memorization/id1391009396
- *Decoding Islamic HCI: What Current Patterns Reveal About Future Possibilities.* Proceedings of the 2026 CHI Conference (CHI '26). (Islamic HCI as a distinct, value-grounded ethic; gamifying worship as an ethical, not neutral, choice.) https://dl.acm.org/doi/10.1145/3772318.3791954
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation. *Psychological Bulletin*, 125(6), 627–668. (128 experiments; tangible rewards undermine free-choice intrinsic motivation; positive feedback enhances it.) https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- Ryan, R. M., & Deci, E. L. (2000). Self-Determination Theory and the Facilitation of Intrinsic Motivation, Social Development, and Well-Being. *American Psychologist*, 55(1), 68–78. https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf
- Kabir, M., Kabir, M. R., & Islam, R. S. (2024). *Islamic Lifestyle Applications: Meeting the Spiritual Needs of Modern Muslims.* arXiv:2402.02061 [cs.HC] (later in *Int. J. Human–Computer Interaction*, 2025). (Apps lack autonomy/competence/relatedness; ethically aligned design.) https://arxiv.org/abs/2402.02061
- Miller, C. H., Lane, L. T., Deatrick, L. M., Young, A. M., & Potts, K. A. (2007). Psychological Reactance and Promotional Health Messages: The Effects of Controlling Language, Lexical Concreteness, and the Restoration of Freedom. *Human Communication Research*, 33(2), 219–240. https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x
- Valdez, P., & Mehrabian, A. (1994). Effects of color on emotions. *Journal of Experimental Psychology: General*, 123(4), 394–409. (Arousal driven primarily by saturation, not hue.) https://psycnet.apa.org/record/1995-08699-001
- Case, A. (2015). *Calm Technology: Principles and Patterns for Non-Intrusive Design* / *Principles of Calm Technology.* (Smallest possible attention; minimal feature set; peripheral by default.) https://calmtech.com/
- Tanzil Project. *Quran Text — Download & License Terms* (verbatim copies only; source must be indicated and linked; "changing the text is not allowed"). https://tanzil.net/download/
