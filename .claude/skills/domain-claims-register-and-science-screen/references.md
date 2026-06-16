# references — domain-claims-register-and-science-screen

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. Paths are relative to the repo root.

## Primary

- `docs/science/CLAIMS.md` (intro + the absolute rule) — **The register is the single point of authorship.** Indexes *every user-facing factual claim* the app makes; the rule is absolute: "if a statement is not registered here with at least one verified source and an evidence grade, the app must not state it." The one-directional chain *verified source → graded synthesis claim → CLAIMS row → engine rule + on-screen copy → science screen* means a wrong row ships straight to a ḥāfiẓ. Take: author the claim in the register first, never in a screen or feature string.

- `docs/science/CLAIMS.md` (the seven-column contract + groups A–J) — **Every row carries: ID `C-NNN`, Claim (as the app states it), Value/rule the engine uses, Source(s) inline-cited, Grade, App surface, Notes/caveats** — including the honest "the app uses X; the research shows X–Y" where it simplifies. Groups: A Memory & forgetting · B Spacing & scheduling · C Engine math · D Retrieval · E Interference & mutashābihāt · F Serial recall & the page unit · G Overlearning · H Methodology · I Motivation & adab · J Cross-cutting honesty. Take: place the row under the right group with all seven columns.

- `docs/science/CLAIMS.md` (Scope & neutrality note + group H) — **[TRAD] claims document *what the tradition does* and *why memory science says it works*, name an identifiable source (hadith = collection + number + grading), are scoped strictly to methodology, and issue no fiqh ruling.** The app stays madhhab/sect-neutral, is servant to the teacher and the sanad chain, and flags "needs scholarly review"; no row makes a cognitive/neuro/academic *promise* about the user. Take: a religious row is methodology + named source, never a ruling or a promise.

- `docs/science/11-the-in-app-science-screen.md` §1 (renders the register) — **"The science we follow" is a read-only projection of `CLAIMS.md`, a view not a source of truth.** It contains no fact not already a registered, graded, sourced row; copywriters edit the register, never the screen in isolation, so the two cannot drift. Take: the screen formats the register, it never authors.

- `docs/science/11-the-in-app-science-screen.md` §2 (ships fully offline) — **Bundled, static, no network, no AI.** The register-derived content ships inside the binary or a checksum-verified core pack; no runtime fetch of "latest research," no model generating explanations; citations are full readable on-device text, a URL is an optional convenience that does nothing offline; corrections ship as an app/pack update. Take: the science travels into airplane mode forever.

- `docs/science/11-the-in-app-science-screen.md` §3 (plain language) — **Plain, common words, short sentences, active voice, the user's frame (murājaʿa/pages/juz/cycle).** Two-layer copy per claim: a plain headline + an optional "the evidence" expansion with the named study and grade; technical terms (FSRS, retrievability) only with a one-line gloss and only where the term is the point; grouped by theme for scanning. Take: write for a ḥāfiẓ, not a cognitive scientist.

- `docs/science/11-the-in-app-science-screen.md` §4 (transparency is the trust) — **Each claim shows who found it, when, and how strong: author(s), year, venue, and the grade tag.** "Studies show" without a named, dated, graded source is forbidden; a plain-words grade legend; religious claims shown with collection + number + grading; honest "simplification" notes where the app simplifies. Take: show your work — named source on the face of every claim.

- `docs/science/11-the-in-app-science-screen.md` §5 (grades → confidence, never certainty) — **A grade is the strength of the *evidence*, kept strictly separate from certainty about *your* Quran.** Render as confidence words ("among the best-established findings" / "a single controlled study" / "named traditional scholarship"), never a star rating, "proven" badge, or retention percentage; near-100% comes from the cycle ceiling + overlearning, not a number. Take: grade ≠ promise.

- `docs/science/11-the-in-app-science-screen.md` §6 (calm, no coercion) — **The screen explains; it never sells, nags, or frightens.** No streaks, badges, urgency, guilt; decay and the decay ḥadīth framed as honest premise, never a threat; no engagement mechanics ("N of M science cards read," a finish badge). Take: explanation is the whole job.

- `docs/science/11-the-in-app-science-screen.md` §7 (accessible + RTL-native) — **WCAG 2.2 AA: grade conveyed by text tag + optional icon, never color alone; ≥4.5:1 contrast across light/sepia/dark; resizable text at 200%; reflow with no horizontal scroll; semantic label per locale; RTL layout with locale numerals and bidi-isolated Latin source names.** Take: a claim no one can read is not transparent; *iḥsān* applies to this screen too.

- `docs/science/11-the-in-app-science-screen.md` §8 (honest scope) — **It is a transparency surface, not a textbook, fatwa, or marketing page.** Methodology not rulings; "needs scholarly review" shown plainly where sign-off is pending; limits of thin evidence named, not hidden; can point to the open-source `CLAIMS.md`/`REFERENCES.md` for the full record. Take: trust comes from honesty about limits, not over-claiming.

## Supporting

- `docs/_DOC-SET-BLUEPRINT.md` §2 (citation convention) — **Citations must be real and web-verified; never fabricate a citation, DOI, author list, or URL.** An unsourceable claim is rewritten as an explicit "Assumption (uncited): …" or removed; religious content names identifiable sources, gives hadith collection + number with grading, and never presents rulings. Take: the verification bar that makes the register trustworthy.

- `docs/_DOC-SET-BLUEPRINT.md` §3 (evidence grades) — **`[MA]` meta-analysis · `[RCT]` · `[EXP]` · `[CS]` classic study · `[OBS]` observational · `[TEXT]` textbook/algorithm doc · `[TRAD]` traditional Islamic source.** Preference among empirical: MA > RCT/EXP > CS > OBS > TEXT; methodology/religious claims are `[TRAD]` and must name the source. Take: the exact grade vocabulary every row uses.

- `docs/_DOC-SET-BLUEPRINT.md` §4d (CLAIMS.md anatomy) — The register's column and grouping definition, the canonical shape the rows must match. Take: the structural contract for a new row.

- `docs/science/REFERENCES.md` (master graded bibliography) — **The deduplicated superset of every source any science doc cites, each ending in `— [GRADE]` with a note on what the app takes from it.** A new claim's source is added/deduped here. Take: the single place a source's canonical, verified citation lives.

- `docs/design-system/11-voice-and-tone.md` §2 (four fixed attributes) — Every string must read **reverent, calm, plain-and-warm, honest**; sentence case, no exclamation marks, no emoji; a page is never "safe to drop." Take: the voice the on-screen claim text must pass.

- `docs/design-system/11-voice-and-tone.md` §5 (teacher's aide, never *for* the Quran) — The app surfaces methodology and never issues a ruling, never speaks for the Quran or Allah, never out-ranks a present teacher; "needs scholarly review" flagged where pending. Take: the voice-side mirror of the CLAIMS [TRAD] neutrality rule.

- `docs/design-system/11-voice-and-tone.md` §8 (transcreation, not literal translation) — fa/ar/ckb strings are transcreated against one voice charter; numerals via `intl` per locale in `type.numeral`; Latin runs bidi-isolated (FSI/PDI). Take: "plain language" means plain *in the user's language*.

- `docs/design-system/11-voice-and-tone.md` §9 (never-ship lint + per-locale review) — A release-blocking copy-lint blocks guilt/fear/loss framing, controlling mandates, "safe to drop"/"mastered", exclamation marks/emoji, and commercial words; native + scholar review per locale. Take: the QA gate that catches a claim string that breached tone.

## Sibling skills

- **domain-scheduling-engine-rules** — the DSR engine, trust clamp `due = min(ideal, ceiling)`, cycle ceiling, and stability math that the register *describes* as claims (C-009, C-010…C-017, C-016). This skill registers and explains them; that skill changes them.
- **domain-grading-pipeline** — the no-AI, no-audio reveal-on-tap recite/grade flow behind the retrieval-practice claims (C-018…C-022, C-033).
- **domain-mutashabihat-system** — the similar-verse interference subsystem behind the interference claims (C-026…C-030).
- **domain-mushaf-text-integrity** — byte-exact Quran text and immutable per-page layout behind the page-unit serial-recall claims (C-031…C-033).
- **domain-asset-pack-integrity** — the one-time, checksum-verified offline pack the bundled science-screen data and citations ship inside.
