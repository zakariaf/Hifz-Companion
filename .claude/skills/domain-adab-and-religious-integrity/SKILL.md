---
name: domain-adab-and-religious-integrity
description: The always-on religious conscience-check for the Hifz Companion app — the non-negotiable adab guardrails that outrank every feature: reverence toward the muṣḥaf, riwāyah stated explicitly, ZERO bundled tafsīr, sect/madhhab neutrality, no gamification of worship, no guilt/fear/loss copy, never "safe to drop", servant-to-the-teacher, no microphone, and where scholarly review is required. Use whenever authoring or reviewing ANY user-facing copy, notification, feature, motivational mechanic, visual treatment of the muṣḥaf, or methodology/religious claim.
---

# domain-adab-and-religious-integrity

The conscience of the whole app, in one place. Before Hifz Companion is a product it is an act of *adab* — refined, humble, reverent conduct toward Allah, toward the muṣḥaf, and toward the user — and these guardrails outrank every feature, metric, performance win, or convenience. This skill is the always-on check that every string, screen, notification, motivational mechanic, sacred-text treatment, and methodology claim must pass: the muṣḥaf is rendered faithfully and never decorated; the riwāyah is named and no tafsīr ships; the app stays madhhab/sect-neutral; worship is never gamified; the voice never guilts, scares, commands, or speaks *for* the Quran; a page is never called "safe to drop"; there is no microphone; and where a scholar's sign-off is still pending, the copy says so plainly.

This is the rule above the rules. `docs/PRD.md` §4 (R1–R6) makes these **release-blocking** — "any one, gotten wrong, ends the project." When this skill conflicts with any other, this skill wins.

## When to use

Use this skill — as the conscience pass — whenever you author, change, or review:

- **any user-facing copy** in any locale: onboarding, the Today list, the recite/grade flow, notifications, errors, settings, empty states, About/Credits;
- **a notification** (the one calm daily line, the catch-up note) or any reminder wording;
- **a motivational or progress mechanic** — anything that could become a streak, score, badge, XP, leaderboard, counter, or celebratory effect;
- **any visual treatment of the muṣḥaf** — overlays, page-turn motion, decoration, color over the glyph layer, an "opening" framing;
- **a methodology or religious claim** — a sentence about hifz, the cycle, the tradition, etiquette, or anything a user might read as a ruling;
- **a feature surface that names or attributes the Quran** — the muṣḥaf selector, riwāyah label, source credits, swappable-edition picker;
- **anything touching privacy as religious trust** — audio, recording, network, accounts, telemetry, or teacher/parent surfaces.

If a change produces words a user reads, a reward a user feels, or a mark on the sacred page, run this conscience check before it ships.

Do **NOT** use this skill for the *implementation* it guards — use the named sibling, then return here for the conscience pass:

- the byte-exact text, KFGQPC glyph-font rendering, layout-from-dataset, overlay-not-re-typeset mechanics of R1 → use **domain-mushaf-text-integrity** (that skill *enforces* R1 in code; this skill is *why* it outranks everything and the adab around it);
- how verified asset packs are downloaded once over the single HTTPS socket and fail-closed verified → use **domain-asset-pack-integrity** (the "no network / no telemetry" privacy-as-trust covenant lives there in code);
- the DSR math, trust clamp, "never safe to drop" engine invariant, stakes-tiered retention → use **domain-scheduling-engine-rules** (that skill owns the *invariant*; this skill owns the *honesty/non-coercion framing* around it);
- the reveal-on-tap self-rating + teacher (talaqqī) sign-off normalization and the sacred-text grade guard → use **domain-grading-pipeline** (the talaqqī-overrides-the-machine rule lives there; this skill is the servant-to-the-teacher adab behind it);
- the scholar-reviewed confusables dataset, discrimination drills, swap logging → use **domain-mutashabihat-system** (objective-wording-only scope is enforced there; this skill is the neutrality/scholar-review obligation behind it).

The siblings build the mechanisms; this skill is the conscience every one of them — and every UI string — must satisfy.

## The canonical pattern

The guardrails trace to `docs/PRD.md` §4 (R1–R6, release-blocking), the adab synthesis `docs/design-system/13-islamic-identity-and-adab.md`, the voice rules `docs/design-system/11-voice-and-tone.md`, and the methodology evidence `docs/science/10-traditional-hifz-methodology.md`. Never invent a guardrail without a doc behind it; cite the section.

### Reverence toward the muṣḥaf (R1)

1. **The muṣḥaf page is the unit of reverence — rendered faithfully, never re-typeset, never decorated.** Sacred text is byte-exact and drawn through the per-page KFGQPC glyph font (the OS shaper is never asked to lay out Quran text); every marker is a coordinate overlay on the immutable glyph layer, never reconstructed text. A single dropped/altered diacritic ends the project. `docs/PRD.md` R1; `docs/design-system/13-islamic-identity-and-adab.md` §1. *(Mechanics enforced by **domain-mushaf-text-integrity**.)*
2. **The chrome defers to the words — diagnostic, never decorative or congratulatory.** When the page is shown it is "no dashboard": no badge, counter, mascot, sticker, glow, gilt border, drop-shadow, or saturated decorative color over an āyah. A weak/decaying line may carry a calm `color.semantic.warning` overlay; nothing ever marks "you completed this." Page-turn motion is sober — no flip sound, no haptic celebration, no flourish. `docs/design-system/13-islamic-identity-and-adab.md` §3; motion vocabulary per `docs/design-system/06-motion-and-haptics.md`.
3. **Reverence lives in intent and presentation, not in gating the device.** The app never gates the muṣḥaf or the daily revision behind a wuḍūʾ prompt, a piety pledge, or any ritual checkpoint — it has no authority to impose ritual conditions. An *optional, dismissible* calm opening framing (e.g. a quiet *taʿawwudh*/basmalah line) is allowed; never mandatory, unskippable, or guilt-laden. `docs/design-system/13-islamic-identity-and-adab.md` §2.

### Riwāyah, attribution, neutrality (R2)

4. **State the riwāyah; never present the bundled muṣḥaf as "the Quran" absolutely.** Show it as **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf,"** at onboarding and in settings; the muṣḥaf is a swappable asset. `docs/PRD.md` R2; `docs/design-system/13-islamic-identity-and-adab.md` §5.
5. **ZERO bundled tafsīr, translation, or commentary in the product — neutrality by omission.** Any of these inevitably encodes a school of thought; the product ships none. Only the UI chrome localizes; the Quran text is identical across fa/ckb/ar and is never "translated" in-app. `docs/PRD.md` R2; `docs/design-system/13-islamic-identity-and-adab.md` §5; `docs/science/10-traditional-hifz-methodology.md` §9 (structure universal, app surfaces methodology, issues no ruling).
6. **Attribute the sources faithfully — adab and license obligation.** Tanzil (text, verbatim, attributed, "changing the text is not allowed"), QUL (layout), KFGQPC (fonts) are credited in About/Credits with the checksum guarantee stated plainly. `docs/design-system/13-islamic-identity-and-adab.md` §5; `docs/PRD.md` §11.1, §17.

### No gamification of worship (R3, C6)

7. **The extrinsic-reward apparatus is replaced by honest competence feedback.** No XP, points, levels, badges on āyāt, leaderboards, ḥasanāt counter, or confetti on completing a juz/cycle — extrinsic rewards measurably *undermine* intrinsic worship motivation (Deci, Koestner & Ryan 1999, d ≈ −0.40; non-controlling positive feedback is the one thing that *helps*). The only feedback is the calm retention heat-map, weakest-pages surfacing, and a feasible plan. `docs/PRD.md` R3, C6; `docs/design-system/13-islamic-identity-and-adab.md` §4.
8. **No streak-as-pressure, no broken-chain shame, anywhere, in any locale.** Any continuity indicator is private, opt-in, and never punitive; the heat-map shows green *receding* to a muted neutral, never an alarming red scoreboard, rolled up by a **min-leaning** aggregate. `docs/design-system/13-islamic-identity-and-adab.md` §4; `docs/PRD.md` §12.5; `docs/PRD.md` §10.3.

### The voice — non-coercive, reverent, honest (R3)

9. **Adab is the first gate of copy review — gentleness outranks every engagement convention.** Every string passes the four fixed voice attributes — **reverent, calm, plain-and-warm, honest** — before clarity or brevity; a string that is clear but harsh fails first. `docs/design-system/11-voice-and-tone.md` §1, §2.
10. **No guilt, fear, or loss framing — it is release-blocking, not a style nit.** "You'll lose your hifz," "you're falling behind," "you haven't opened the app in N days," "don't break your streak" are banned — loss appeals raise guilt/shame/fear and *backfire* for an audience already carrying the spiritual weight of forgetting. Hard news (decay, missed days, a lapse, budget overflow) leads with **empathy, then a calm path, then the user's choice** (the missed-day re-spread is the canonical instance: "You missed 3 days — here is a 5-day catch-up that still completes your cycle"). `docs/design-system/11-voice-and-tone.md` §3, §4; `docs/PRD.md` R3, §7.9.
11. **Invite and inform; never command; never transact.** The mandate words — "must," "have to," "should," "don't" — and scolding imperatives are banned (they provoke reactance); the cycle, budget, and pace are framed as the user's choices. No "upgrade/premium/unlock," no urgency, no debt-to-the-app — the app is free as *ṣadaqah jāriyah*, so there is nothing to sell. `docs/design-system/11-voice-and-tone.md` §6, §7; `docs/PRD.md` §14.

### Servant to the teacher and the sanad (R6)

12. **The app serves the talaqqī chain — it never out-ranks a present teacher.** Teacher sign-off (`sourceConfidence = 1.0`) overrides self-rating and algorithmic state; copy credits the teacher ("Recorded with your teacher's sign-off"), never the app ("Approved"). The app never issues a fiqh ruling, never speaks *for* the Quran or Allah, never pronounces on the user's spiritual state. `docs/PRD.md` R6, §8.2; `docs/design-system/13-islamic-identity-and-adab.md` §6; `docs/design-system/11-voice-and-tone.md` §5. *(Overrides rule enforced by **domain-grading-pipeline**.)*
13. **Never "safe to drop," "mastered," or "done" — the decay axiom forbids it.** The Quran "escapes faster than camels" (Bukhārī 5032); nothing memorized is ever exempt from revision. Progress language is "weakening / strengthening / due," never "finished with." `docs/science/10-traditional-hifz-methodology.md` §6; `docs/PRD.md` §7.12; `docs/design-system/11-voice-and-tone.md` §5. *(Engine invariant in **domain-scheduling-engine-rules**.)*

### Privacy as religious trust (R5) and the scholar-review boundary

14. **No microphone, no recording, no ASR, no AI mistake-detection — by construction.** Recitation correctness is judged by a human (the ḥāfiẓ or the teacher), exactly as the tradition does; this also structurally protects women's privacy. No telemetry, no account, no per-user data ever leaves the device. `docs/PRD.md` R5, C2, §8.3, §17; `docs/science/10-traditional-hifz-methodology.md` §8. *(Network covenant enforced by **domain-asset-pack-integrity**.)*
15. **Where a scholar's sign-off is pending, the copy says so — it never asserts authority.** Etiquette guidance is offered as *attributed, optional, sect-neutral methodology* flagged "needs scholarly review," never as a ruling; regional terminology (Kurdish Sorani, some Persian), the mutashābihāt dataset, and the endorser all await native-speaker + scholarly review before defaults lock. `docs/design-system/13-islamic-identity-and-adab.md` §2, §6; `docs/PRD.md` §13.4, §21; `docs/design-system/11-voice-and-tone.md` §9 (release-blocking per-locale review).
16. **Quiet, aniconic identity — the *miḥrāb*, not the mascot.** Islamic identity is carried by calm geometric restraint, calligraphic sobriety, and a green-anchored low-arousal palette — never figurative characters, cartoon Qurans, neon accents, or "Islamic-themed" clip-art; honorifics (ﷺ, *raḍiya Allāhu ʿanhu*) and correct transliteration (*ḥāfiẓ, murājaʿa, mutashābihāt, talaqqī, muṣḥaf, riwāyah*) are the *one* form of decoration that is actually adab. `docs/design-system/13-islamic-identity-and-adab.md` §7, §3; `docs/design-system/11-voice-and-tone.md` §2.

## Do / Don't

| Do | Don't |
|---|---|
| Render the muṣḥaf faithfully via per-page glyph fonts; markers as overlays on the immutable layer | Decorate, animate celebrate, re-typeset, or put a badge/counter/mascot over an āyah |
| Name the riwāyah: "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"; attribute Tanzil/QUL/KFGQPC | Call the bundled muṣḥaf "the Quran" absolutely; strip or alter attribution |
| Ship zero tafsīr/translation/commentary; localize only the UI chrome | Bundle or surface any tafsīr/translation/commentary that encodes a madhhab/sect position |
| Give honest competence feedback: calm heat-map, weakest pages, a feasible plan | Add XP, points, badges on āyāt, leaderboards, a ḥasanāt counter, or confetti on a juz |
| Keep any continuity indicator private, opt-in, non-punitive | Ship a punitive streak, a "don't break your chain" nag, or a broken-streak shame state |
| Pass every string through the adab gate (reverent/calm/plain-warm/honest) first | Let an engagement, growth, or usability convention override the gentleness floor |
| Lead hard news with empathy, then a calm path, then the user's choice | Open with blame ("you're behind") or weaponize the fear of losing hifz |
| Phrase as invitation/readiness ("your revision for today is ready") | Command ("you must / should / don't"), or use "upgrade / premium / unlock" |
| Credit the teacher; defer the sanad; flag "needs scholarly review" where pending | Override a present teacher; issue a fiqh ruling; speak *for* the Quran or Allah |
| Say "weakening / strengthening / due"; keep every page in the cycle forever | Say a page is "safe to drop," "mastered," or "done" |
| Judge recitation by a human; ship no microphone/ASR/AI; no telemetry; offline | Add audio recognition, recording, accounts, analytics, or any per-user network call |
| Express identity through quiet geometric restraint, honorifics, correct transliteration | Use mascots, cartoon Qurans, saturated/neon color, or "Islamic-themed" clip-art |

## Checklist

Before this copy / feature / mechanic / sacred-surface ships — the conscience pass:

- [ ] **R1 reverence:** the muṣḥaf is rendered faithfully (per-page glyph fonts, no OS shaping, no runtime reflow); every marker is a coordinate overlay, never re-typeset; no decoration/badge/celebration sits on or near an āyah (`docs/PRD.md` R1; `docs/design-system/13-islamic-identity-and-adab.md` §1, §3 — mechanics via **domain-mushaf-text-integrity**).
- [ ] **No device gating:** nothing gates the muṣḥaf/revision behind wuḍūʾ, a pledge, or a ritual checkpoint; any reverent opening framing is optional and dismissible (`docs/design-system/13-islamic-identity-and-adab.md` §2).
- [ ] **R2 riwāyah + neutrality:** the riwāyah is named ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"), sources attributed; **zero** tafsīr/translation/commentary; the Quran text is identical across fa/ckb/ar, only the chrome localizes (`docs/PRD.md` R2; `docs/design-system/13-islamic-identity-and-adab.md` §5).
- [ ] **R3 no gamification:** no XP/points/levels/badges/leaderboards/ḥasanāt-counter/confetti; the only feedback is the calm heat-map + weakest-pages + a feasible plan; any continuity indicator is private, opt-in, non-punitive (`docs/PRD.md` R3, C6; `docs/design-system/13-islamic-identity-and-adab.md` §4).
- [ ] **Voice gate (adab first):** the string is reverent, calm, plain-and-warm, honest; no exclamation marks, no emoji in product copy (`docs/design-system/11-voice-and-tone.md` §1, §2).
- [ ] **No guilt/fear/loss + no command/transaction:** none of the never-ship patterns ("you'll lose your hifz," "you're behind," "don't break your streak," "you must/should/don't," "upgrade/premium/unlock") appear; hard news leads with empathy, then a path, then the user's choice (`docs/design-system/11-voice-and-tone.md` §3, §4, §6, §7; `docs/PRD.md` §7.9, §14).
- [ ] **Never "safe to drop":** progress language is "weakening / strengthening / due," never "mastered/done/finished"; no page is exempt from the cycle (`docs/science/10-traditional-hifz-methodology.md` §6; `docs/PRD.md` §7.12 — invariant via **domain-scheduling-engine-rules**).
- [ ] **R6 servant to the teacher:** teacher sign-off overrides the machine; copy credits the teacher, never the app; no fiqh ruling, no speaking *for* the Quran/Allah, no pronouncement on the user's spiritual state (`docs/PRD.md` R6, §8.2; `docs/design-system/13-islamic-identity-and-adab.md` §6 — overrides via **domain-grading-pipeline**).
- [ ] **R5 privacy as trust:** no microphone/recording/ASR/AI mistake-detection; no account/telemetry/per-user network; works fully offline in airplane mode (`docs/PRD.md` R5, C2, §17 — network covenant via **domain-asset-pack-integrity**).
- [ ] **Scholar-review boundary:** etiquette/methodology is attributed, optional, sect-neutral, and flagged "needs scholarly review" where pending (terminology, mutashābihāt dataset, endorser); it never reads as a ruling (`docs/design-system/13-islamic-identity-and-adab.md` §2, §6; `docs/PRD.md` §13.4, §21).
- [ ] **Identity is aniconic restraint:** quiet geometry, sober iconography, low-arousal green palette; honorifics (ﷺ) and correct transliteration present where a name/term appears; no mascots, no figurative imagery, no saturated/neon color (`docs/design-system/13-islamic-identity-and-adab.md` §7).
- [ ] **RTL + three locales:** the string exists for **all** of fa/ckb/ar via `gen_l10n` ARB (no missing keys, no hardcoded user-facing strings), is **transcreated** (not literally translated) so the calm-reverent feeling survives per-locale register, with locale numerals (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar via `intl`) and bidi isolation (FSI/PDI) for mixed runs (`docs/design-system/11-voice-and-tone.md` §8, §9; `docs/PRD.md` §13).
- [ ] **Release-blocking review recorded:** banned-phrase lint passes in every locale; native-speaker register review and — for religious/methodology wording — scholar review are done or the surface stays flagged pending (`docs/design-system/11-voice-and-tone.md` §9; `docs/PRD.md` §20, §21).

This is the rule above the rules: *iḥsān* is the standard because the work is for Allah. If a change makes the app more engaging, more "delightful," or more profitable at the cost of any guardrail here, it is wrong no matter how good it looks — the non-negotiables outrank the feature, every time.

## Files

- `template.md` — a copy-paste conscience-review scaffold (the R1–R6 gate, the adab voice gate, the never-ship phrase list, the per-locale + scholar-review record) with `// TODO` markers, referencing each guardrail by its PRD/doc section and naming the sibling that enforces the mechanism.
- `references.md` — the exact governing doc sections, each with the one thing to take from it, and the sibling skills.

Related skills: **domain-mushaf-text-integrity** (enforces R1 — the byte-exact text and glyph-overlay rendering this skill reveres), **domain-asset-pack-integrity** (enforces the R5/C1 no-network, no-telemetry, fail-closed download covenant), **domain-scheduling-engine-rules** (owns the "never safe to drop" / trust-clamp invariant this skill frames honestly), **domain-grading-pipeline** (owns the teacher-overrides-the-machine talaqqī rule and the sacred-text grade guard), **domain-mutashabihat-system** (owns the objective-wording-only, scholar-reviewed confusables dataset this skill keeps neutral).
