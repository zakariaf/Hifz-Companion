---
name: domain-claims-register-and-science-screen
description: Register, grade, and source every user-facing factual claim in the Hifz app, and build the offline "The science we follow" screen that renders the CLAIMS register. Use whenever you add/change/remove any on-screen number, scheduling rule shown to a ḥāfiẓ, educational or methodology copy, notification text, or tooltip; edit CLAIMS.md / REFERENCES.md; or build the science screen — every claim is one graded, sourced row, no claim ships unsourced, and [TRAD] claims issue no fiqh ruling.
---

# domain-claims-register-and-science-screen

The single gate between the evidence base and what the app *tells* a ḥāfiẓ. Every user-facing factual claim — in the science screen, onboarding, recite-flow copy, notifications, the methodology/progress screens, any tooltip — must exist as one row in [`CLAIMS.md`](../../docs/science/CLAIMS.md) with the claim *as stated*, the *value/rule the engine uses*, at least one *inline-cited verified source*, an *evidence grade*, the *app surface*, and *caveats*. The "The science we follow" screen is a read-only, bundled, offline projection of that register — never an independent author. The chain is one-directional and load-bearing: *verified primary source → graded claim in a synthesis doc → CLAIMS.md row → engine rule + on-screen copy → the science screen.* A wrong row here ships straight to a ḥāfiẓ, so the register, not the screen, is the gate.

This skill governs the **claims register and its renderer**, not the engine math itself, not the grading flow, not the text rendering — those are sibling skills the register *describes*.

## When to use

Use when you:
- add, change, or remove any **user-facing number** (a retention target, a cycle length, an interval, a repetition count) — it must trace to a registered, graded row
- add or reword any **scheduling rule, methodology statement, or educational claim** the user reads (recite-flow copy, the trust-clamp explanation, the "nothing is safe to drop" line, the decay ḥadīth)
- write or change **notification, onboarding, or tooltip** copy that *asserts* something about memory, spaced repetition, traditional methodology, or motivation
- edit [`docs/science/CLAIMS.md`](../../docs/science/CLAIMS.md) or [`docs/science/REFERENCES.md`](../../docs/science/REFERENCES.md) (add a row, change a grade, swap a source, add a caveat)
- build or change the **"The science we follow"** screen (`docs/science/11-the-in-app-science-screen.md` §1–§8)
- surface a **[TRAD]** religious/methodology claim anywhere (hadith, sabaq/sabqi/manzil, talaqqī, the seven manāzil)

Do NOT use this skill for → use the sibling instead:
- changing the DSR engine math, the trust clamp `due = min(ideal, ceiling)`, stability growth, or the cycle ceiling itself → use **domain-scheduling-engine-rules** (this skill only registers and *describes* those rules as claims)
- the no-AI reveal-on-tap recite/grade flow mechanics → use **domain-grading-pipeline** (this skill registers the *claim* that recall beats re-reading, C-018)
- the mutashābihāt interference subsystem (sibling pulling, discrimination drills, the dataset) → use **domain-mutashabihat-system** (this skill registers C-026…C-030)
- rendering Quran glyphs / immutable per-page layout / Tanzil-exact text → use **domain-mushaf-text-integrity**
- the one-time verified asset download and offline pack contract → use **domain-asset-pack-integrity** (this skill only relies on it: the science data ships *inside* a verified pack)

The register is where a claim earns the right to exist; the engine/flow skills are where it acts. A claim with no row is a release-blocking defect, not a copy nit.

## The canonical pattern

1. **A claim earns a row before it earns a sentence.** No string anywhere may assert a fact about memory, SR, methodology, or motivation unless it is already a row in `CLAIMS.md` with ≥1 verified source and a grade. Authoring happens in the register, never in the screen or a feature string in isolation. `docs/science/CLAIMS.md` (intro + the absolute rule: "if a statement is not registered here with at least one verified source and an evidence grade, the app must not state it"); `docs/science/11-the-in-app-science-screen.md` §1 (the screen "renders the register — it is a view, not a source of truth").

2. **Every row carries the full seven columns.** ID (`C-NNN`), **Claim (as the app states it)** in the user's frame, **Value/rule the engine uses**, **Source(s)** inline-cited, **Grade**, **App surface**, **Notes/caveats** (including the honest "the app uses X; the research shows X–Y" where it simplifies). Place the row under the right group (A Memory & forgetting · B Spacing · C Engine math · D Retrieval · E Interference · F Serial recall · G Overlearning · H Methodology · I Motivation · J Cross-cutting honesty). `docs/science/CLAIMS.md` (group tables A–J + column contract from `docs/_DOC-SET-BLUEPRINT.md` §4d).

3. **The source is real, verified, and graded — or the claim is rewritten or deleted.** Find and confirm each citation (author/year/venue, resolving URL); for hadith give the collection and number with grading. Grade per the legend: `[MA]` > `[RCT]`/`[EXP]` > `[CS]` > `[OBS]` > `[TEXT]`; `[TRAD]` for methodology/religious sources, which must name the source. An uncitable statement is rewritten as an explicit assumption or removed — never kept as an uncited "best practice." `docs/_DOC-SET-BLUEPRINT.md` §2 (citation convention: real, web-verified, never fabricated) and §3 (evidence grades); add/dedupe the entry in `docs/science/REFERENCES.md` (master graded bibliography).

4. **The grade describes the evidence, never the user's outcome.** A grade is the *strength of the evidence behind the claim*, kept strictly separate from any certainty about *this ḥāfiẓ's* Quran. Render it as plain confidence language ("among the best-established findings in memory science" for `[MA]`; "a single controlled study" / "named traditional scholarship" for weaker grades), never a star rating, "proven" badge, or retention percentage. `docs/science/11-the-in-app-science-screen.md` §5 (grades → honest confidence language; grade ≠ certainty) and §4 (named, dated source + grade tag on every claim).

5. **[TRAD] claims are scoped to methodology and issue no fiqh ruling.** Religious/methodology rows document *what the tradition does* and *why memory science says it works*; they name an identifiable source, stay madhhab- and sect-neutral, position the app as *servant to the teacher and the sanad chain*, and flag "needs scholarly review" where sign-off is pending. No row makes a cognitive, neurological, or academic-performance *promise* about the user. `docs/science/CLAIMS.md` (Scope & neutrality note, binding on every religious row; group H); `docs/science/11-the-in-app-science-screen.md` §8 (methodology not rulings; "needs scholarly review" shown plainly); `docs/design-system/11-voice-and-tone.md` §5 (speak as a teacher's aide, never *for* the Quran).

6. **Plain language in the user's frame, transcreated per locale.** State each claim in common words, short sentences, active voice, in *murājaʿa* / pages / juz / cycle — never lab jargon (no "free-recall paradigm," "stability parameter"); technical terms (FSRS, retrievability) appear only with a one-line plain gloss and only where the term is the point. The two-layer pattern is a plain headline plus an optional "the evidence" expansion. `docs/science/11-the-in-app-science-screen.md` §3 (plain, common words; two-layer copy; the user's frame); `docs/design-system/11-voice-and-tone.md` §2 (four fixed attributes: reverent, calm, plain-and-warm, honest) and §8 (transcreation, not literal translation, for fa/ar/ckb).

7. **No coercion, no promise, no engagement mechanics on the science.** The screen explains; it never sells, nags, or frightens. Never promise a retention percentage — near-100% comes from the **cycle ceiling** (every page re-recited within the chosen cycle, the trust clamp) + overlearning, not a number. Never weaponize the forgetting curve or the decay ḥadīth into a threat; no "5 of 12 cards read" progress bar, no badge for finishing. `docs/science/11-the-in-app-science-screen.md` §6 (calm, no coercion) and §5 (no retention-percentage promise); `docs/design-system/11-voice-and-tone.md` §3 (tone matrix), §4 (empathy never blame), §7 (no transactional framing); the never-ship lint in §9.

8. **It ships fully offline — bundled, static, no network, no AI.** The register-derived content (claim copy, citations, grades, confidence labels) ships inside the app binary or a checksum-verified core pack and renders locally; no runtime fetch of "latest research," no model generating explanations. Citations show the full reference as readable on-device text; a tappable URL is an optional convenience that simply does nothing offline. Corrections ship as an app/pack update, never a silent remote edit. `docs/science/11-the-in-app-science-screen.md` §2 (bundled, static, offline, no AI; source links degrade gracefully; versioned with the app); relies on **domain-asset-pack-integrity** for the verified pack.

9. **Accessible and RTL-native — reverence and accessibility are one discipline.** Meet WCAG 2.2 AA: ≥4.5:1 contrast across light/sepia/dark, resizable text at 200%, reflow with no horizontal scroll, and the grade conveyed by its **text tag** ("meta-analysis") plus optional icon — **never color alone**. Every claim card, source, and grade has a semantic label in the active locale; layout is RTL-native with locale numerals (Extended Arabic-Indic ۰۱۲۳ for fa/ckb, Arabic-Indic ٠١٢٣ for ar via `intl` `NumberFormat` + `type.numeral`) and bidi-isolated (FSI/PDI) Latin source names. `docs/science/11-the-in-app-science-screen.md` §7 (WCAG 2.2; grade never color-only; RTL + numerals + bidi isolation).

## Do / Don't

| Do | Don't |
|---|---|
| Add the `C-NNN` row to `CLAIMS.md` *first*, then write the on-screen string from it | Hand-write a scientific claim into the screen or a feature string with no register row |
| Fill all seven columns: claim, value/rule, source, grade, surface, caveats | Ship a row missing its source, grade, or the value/rule the engine actually uses |
| Verify every source (author/year/venue, resolving URL; hadith = collection + number) | Fabricate or guess a citation, DOI, author list, or grade |
| Rewrite an uncitable statement as "Assumption (uncited): …" or delete it | Keep an uncited "best practice" or a "studies show" with no named source |
| Render the grade as plain confidence words + text tag (e.g. "meta-analysis") | Render a grade as ★★★★★, a "proven" badge, or a retention-% about the user |
| Keep [TRAD] rows scoped to methodology, sect-neutral, source-named; flag "needs scholarly review" | Issue a fiqh ruling, interpret a verse, or strip a hadith of its collection/number/grading |
| Promise nothing: near-100% comes from the cycle ceiling + overlearning | State a guaranteed retention figure or imply a page is "safe to drop" / "mastered" |
| Bundle the data statically; full citation as on-device text | Fetch claims/citations/"latest research" at runtime or render any of it from an AI model |
| Write plain, in the user's frame; transcreate per fa/ar/ckb; gloss FSRS/retrievability once | Surface effect sizes / parameter names / paradigm labels as the primary unglossed copy |
| Convey the grade by text tag + icon; ≥4.5:1 contrast; reflow; RTL + locale numerals | Encode the grade in color alone, or truncate/break copy at large text sizes |

## Checklist

Before any claim or the science screen ships:

- [ ] Every user-facing factual statement traces to a `C-NNN` row in `docs/science/CLAIMS.md`; no orphan facts in any screen, notification, or tooltip.
- [ ] The row has all seven columns, including the **value/rule the engine actually uses** and a **caveat** (with the honest "app uses X; research shows X–Y" where it simplifies).
- [ ] Each source is **real and verified** (author/year/venue + resolving URL; hadith = collection + number + grading) and present in `docs/science/REFERENCES.md`.
- [ ] The grade follows the legend (`[MA]`>`[RCT]`/`[EXP]`>`[CS]`>`[OBS]`>`[TEXT]`; `[TRAD]` names the source) and is rendered as **confidence language**, never a star rating, badge, or percentage.
- [ ] No retention-percentage promise anywhere; near-100% is attributed to the **cycle ceiling** (trust clamp) + overlearning, not a number; no "safe to drop" / "mastered".
- [ ] [TRAD] claims are **methodology only**, sect/madhhab-neutral, issue **no fiqh ruling**, defer to the teacher/sanad, and show "needs scholarly review" where sign-off is pending.
- [ ] Copy is **plain** in the user's frame (murājaʿa/pages/juz/cycle); FSRS/retrievability glossed once; **transcreated** (not literally translated) for fa/ckb/ar with native + scholar review where religious.
- [ ] The screen is **bundled, static, offline** — no runtime fetch, no AI generation; citations readable on-device; corrections ship as an app/pack update.
- [ ] No coercion or engagement mechanics on the science (no streaks, badges, urgency, guilt, "N of M cards read"); decay/ḥadīth framed calmly, never as a threat.
- [ ] **Accessibility/RTL**: grade conveyed by text tag + icon, **never color alone**; ≥4.5:1 contrast across light/sepia/dark; reflow at 200%; semantic label per locale; locale numerals via `intl` + `type.numeral`; Latin names bidi-isolated (FSI/PDI).
- [ ] On-screen wording of the claim **matches** the value/rule the engine uses for it (no drift between copy and behavior).

The register is the conscience of the app: it lets a sceptical ḥāfiẓ, teacher, or scholar trace any number or sentence the app shows back to a named, dated, graded source. Excellence (*iḥsān*) here is owed because the work is *ṣadaqah jāriyah* and its subject is the Quran. *Taqabbal Allāhu minnā wa minkum.*

## Files

- `template.md` — copy-paste scaffold: a `C-NNN` register row (all seven columns), the matching science-screen claim card (plain headline + "the evidence" expansion + grade tag), the ARB-style localized strings for fa/ckb/ar, and a `REFERENCES.md` entry — with `// TODO` markers and the engine/token/rule names called out.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-scheduling-engine-rules** (the trust clamp, cycle ceiling, and DSR math this register *describes* as claims C-010…C-017, C-016), **domain-grading-pipeline** (the no-AI recite/grade flow behind the retrieval-practice claims C-018…C-022), **domain-mutashabihat-system** (the interference subsystem behind C-026…C-030), **domain-mushaf-text-integrity** (the page-unit serial-recall claims C-031…C-033), **domain-asset-pack-integrity** (the verified offline pack the bundled science data ships inside).
