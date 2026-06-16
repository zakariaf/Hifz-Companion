# references — ui-science-source-row

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. The source row is *attribution made visible* about one registered claim — it shows who found a thing, when, and how strong the evidence is. It never authors a fact, never grades the user's Quran, never sells, and never hides a citation behind a link that dies offline.

## Primary

- `docs/science/11-the-in-app-science-screen.md` §1 (The screen renders the CLAIMS register — a view, not a source of truth) — **The row authors nothing:** it reads claim text, value/rule, source, and grade from the bundled `CLAIMS.md` data; a fact on the row that is not a registered, sourced, graded entry is a release-blocking defect. The on-screen wording must match the value/rule the engine actually uses — no drift between copy and behavior.

- `docs/science/11-the-in-app-science-screen.md` §3 (Every claim in plain, common words — for a ḥāfiẓ, not a cognitive scientist) — **Two-layer copy:** a plain headline in the user's frame (murājaʿa/pages/juz, `type.body`, active voice) on the face, with a "the evidence" expansion carrying the named source and grade; technical terms (FSRS, retrievability) only with a one-line gloss; structure for scanning, RTL-native, transcreated per locale.

- `docs/science/11-the-in-app-science-screen.md` §4 (Every claim names and dates its source, with its grade visible) — **Source on the face of every claim:** author(s), year, venue and the grade tag (e.g. *Cepeda et al., 2006 — meta-analysis*), never a vague "studies show"; a `[TRAD]` claim shows collection, number, and grading, framed as methodology; honest "simplification" note where the app simplifies ("app uses X; research shows X–Y").

- `docs/science/11-the-in-app-science-screen.md` §5 (Grades become honest confidence language — never a promise of certainty) — **Grade = strength of the evidence, not certainty about the user's Quran:** render confidence words ("among the best-established findings" for `[MA]`; "a single controlled study" / "named traditional scholarship" for weaker grades); never a star rating, "proven" badge, or retention percentage; never imply a page is "safe to drop."

- `docs/science/11-the-in-app-science-screen.md` §2 (It ships fully offline — bundled, static, no network, no AI) — **The citation never depends on the network:** the full reference is on-device text; a tappable URL is an *optional* convenience that simply does nothing offline; no runtime fetch of claims/citations/"latest research," no AI generation; corrections ship as an app/pack update.

- `docs/science/11-the-in-app-science-screen.md` §7 (Accessible and RTL-native — reverence and accessibility are the same discipline) — **The accessibility/RTL floor for the row:** WCAG 2.2 — ≥4.5:1 contrast across light/sepia/dark, resize to 200%, reflow with no horizontal scroll; the grade conveyed by its **text tag + optional icon, never color alone** (SC 1.4.1); locale numerals for the year/number; bidi-isolated Latin source names; a semantic label per locale.

- `docs/science/11-the-in-app-science-screen.md` §8 (Honest scope — methodology, not a textbook or a fatwa) — **A `[TRAD]` row issues no ruling:** religious claims appear as named, sourced methodology with grading, never the app's verdict on a disputed matter; "needs scholarly review" is shown plainly where sign-off is pending; the screen defers to the teacher and the sanad chain.

- `docs/science/11-the-in-app-science-screen.md` §6 (Presented calmly and without coercion — explanation, not persuasion) — **No engagement mechanics on the row:** no "5 of 12 cards read" progress, no badge for finishing, no urgency, guilt, or decay-as-threat; a calm, declarative line does the work — the row is reference, opened when wanted.

## Supporting

- `docs/design-system/10-privacy-and-trust-ux.md` §3 (Honesty must be specific and verifiable) — **The link is the *check*, not a slogan:** each claim is paired with a way to verify it; "verify us" is a tap away. The external link earns trust by being real and reachable, not by rhetoric — the row's tappable source is this principle at the claim level.

- `docs/design-system/10-privacy-and-trust-ux.md` §7 (Verifiability must be structural — open source, public URLs) — **Verification links are mixed Latin/RTL runs:** they use bidi isolation so a URL never breaks the right-to-left line, and their tap targets meet the 48×48dp minimum so fa/ckb/ar users reach them identically — the exact treatment the source row's external link follows.

- `docs/science/REFERENCES.md` (Master graded bibliography + evidence-grade legend) — **The canonical source text and grade for each row:** the row's on-device author/year/venue/URL and its `[GRADE]` come from this deduplicated master (and its `CLAIMS.md` row); the row never invents or re-grades a citation, it transcribes the verified one.

## Sibling skills

- **domain-claims-register-and-science-screen** — the `CLAIMS.md` seven-column register, the `REFERENCES.md` entry, the grading, and the whole science screen's offline-payload contract; this skill renders *one row* that skill owns, and is the only author of a claim.
- **ui-certainty-label** — the standalone certainty badge / grade legend that maps a `CLAIMS` grade to a lay confidence phrase; this row *composes* it in the "the evidence" expansion rather than re-authoring the phrase mapping.
- **domain-scheduling-engine-rules** — the DSR math / trust clamp / cycle ceiling / "never safe to drop" a claim *describes*; the row reads the registered description, never re-derives the rule.
- **domain-adab-and-religious-integrity** — the calm, sect/madhhab-neutral, no-ruling, servant-to-teacher copy of the headline and the framing of every `[TRAD]` (hadith) source.
- **eng-rtl-and-bidi-layout** — the per-locale numerals for the year/number, the FSI/PDI bidi isolation of the Latin author/venue/URL run, and the RTL mirroring of the row.
- **eng-add-localized-string** — the ARB strings for the plain headline, the grade confidence label, and the "opens in your browser / leaves the app" hint, transcreated for fa/ckb/ar.
- **domain-asset-pack-integrity** — the checksum-verified core pack the bundled claim/citation/grade text ships inside.
- **eng-write-dart-test** — the per-locale RTL / grayscale-deuteranope / `HttpOverrides`-offline golden harness on the real bundled fonts (never `Ahem`).
