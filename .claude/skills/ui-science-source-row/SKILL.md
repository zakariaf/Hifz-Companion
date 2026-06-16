---
name: ui-science-source-row
description: Build or modify the Hifz Companion science-screen source row — the single citation/claim row on "The science we follow" that pairs a plain-language attribution with a confidence (evidence-grade) label and a tappable source whose external link clearly leaves the app. Use whenever building a science topic page row, a citation/source row, the evidence-grade tag, the "why does the app say this?" affordance, or any in-app row that names a study/hadith with author/year/grade.
---

# ui-science-source-row

The source row is the atomic row of the "The science we follow" screen: it renders **exactly one verified `CLAIMS.md` row** — a plain-language claim headline, its named-and-dated **source** (author/year/venue, or a hadith collection + number), an **evidence-grade tag** rendered as honest *confidence-about-the-evidence* language, and an optional tappable link that **clearly leaves the app**. It is a calm `ListTile`/`Card`-shaped leaf; it **never authors a fact** (the register is the only author), **never shows a grade as a star rating or "proven" badge**, and **never depends on the network** to be trustworthy.

This row is where Pillar 5 (*private & offline by feel*) and the science foundation's honesty chain become visible to a ḥāfiẓ: the full citation is on-device text so the row reads identically in airplane mode, the grade describes the *strength of the evidence* and is kept strictly separate from any certainty about *your* Quran, and a `[TRAD]` source is named with its collection/number and framed as methodology — never a ruling. One row = one verified, sourced, graded claim.

## When to use

Use this skill when building or placing:

- a **science-screen source row** — the claim headline + named source + grade tag + optional "the evidence" expansion (`docs/science/11-the-in-app-science-screen.md` §3, §4);
- the **evidence-grade tag** — the `[MA]`/`[RCT]`/`[EXP]`/`[CS]`/`[OBS]`/`[TEXT]`/`[TRAD]` label rendered as plain confidence words + a non-color glyph (`docs/science/11-the-in-app-science-screen.md` §5, §7);
- the **on-device citation** block — author, year, title, venue as readable text, with an *optional* tappable URL that visibly leaves the app and degrades gracefully offline (`docs/science/11-the-in-app-science-screen.md` §2, §4; `docs/design-system/10-privacy-and-trust-ux.md` §3, §7);
- a **`[TRAD]` source row** — a hadith shown with collection + number + grading, framed as methodology, issuing no ruling (`docs/science/11-the-in-app-science-screen.md` §4, §8);
- the **"why does the app say this?"** affordance — a per-claim or per-number tappable that opens the row's source.

Do NOT use this skill for → use the sibling instead:

- authoring/grading the claim itself, the seven-column `CLAIMS.md` row, the `REFERENCES.md` entry, or the **whole science screen's** structure and offline-payload contract → use **domain-claims-register-and-science-screen** (this skill renders *one row* the register already owns; it never invents a claim).
- the **grade → lay confidence-phrase mapping** and the standalone certainty badge / grade legend → use **ui-certainty-label** (this row *composes* that badge in its "the evidence" expansion; it does not re-author the phrase mapping).
- the **engine math / rule** a claim describes (`due = min(ideal, ceiling)`, FSRS D/S/R, the cycle ceiling, "never safe to drop") → use **domain-scheduling-engine-rules**; the row *reads* the registered description, it never re-derives the rule.
- the **calm, non-coercive, sect-neutral, servant-to-teacher** wording of the headline and the no-ruling framing of a `[TRAD]` row → use **domain-adab-and-religious-integrity**.
- **per-locale numerals (year/number), FSI/PDI bidi isolation** of a Latin author/venue/URL inside RTL text, and **RTL mirroring** of the row → use **eng-rtl-and-bidi-layout**; this skill only requires you *use* them.
- adding the **localized strings** for the headline / grade label / "leaves the app" hint to the ARB bundle → use **eng-add-localized-string**.
- the **verified offline pack** the bundled citation text ships inside → use **domain-asset-pack-integrity**; this row only relies on it.

The source row is **attribution made visible** — it shows who found a thing, when, and how strong the evidence is. A row that grades the *user's* Quran, sells, promises a retention number, fetches "latest research," or hides a citation behind a link that is meaningless offline is the wrong component.

## The canonical pattern

1. **The row renders a registered claim — it is a view, never an author.** Each row reads its claim text, value/rule, source citation, and grade **from the bundled `CLAIMS.md` data**; nothing on the row is hand-written science. If a string here asserts a fact not registered with ≥1 verified source and a grade, that is a release-blocking defect, not a copy nit. `docs/science/11-the-in-app-science-screen.md` §1 (the screen "renders the register — it is a view, not a source of truth"); authoring lives in **domain-claims-register-and-science-screen**.

2. **Two-layer copy: a plain headline, an optional "the evidence" expansion.** The face of the row is a **plain headline** in the ḥāfiẓ's own frame (murājaʿa / pages / juz / cycle), `type.body`, common words, active voice; the named source, grade, and any caveat live in an optional expansion ("the evidence") so detail is on demand, never a wall of jargon. Technical terms (FSRS, retrievability) appear only with a one-line plain gloss. `docs/science/11-the-in-app-science-screen.md` §3 (plain, common words; two-layer copy; the user's frame); copy register owned by **domain-adab-and-religious-integrity**.

3. **Name and date the source on the face of every claim.** The row shows the **author(s), year, venue** (e.g. *Cepeda et al., 2006 — meta-analysis*), never a vague "studies show." The full reference is present as **readable on-device text** so it is useful with no connection. `docs/science/11-the-in-app-science-screen.md` §4 (named, dated source + grade tag on every claim); strings via **eng-add-localized-string**.

4. **The grade is honest confidence language — never a star rating, never a promise.** Compose the certainty badge (**ui-certainty-label**) in the "the evidence" expansion: it renders the grade as plain words about the *evidence* — "among the best-established findings in memory science" for `[MA]`; "a single controlled study" or "named traditional scholarship" for weaker grades — kept strictly separate from any certainty about the user's Quran. The grade is conveyed by its **text tag** ("meta-analysis") plus an optional **non-color glyph**, **never by color alone** and **never** as ★★★★★, a "proven" badge, or a retention percentage. `docs/science/11-the-in-app-science-screen.md` §5 (grades → confidence language; grade ≠ certainty) and §7 (grade never color-only, WCAG 2.2 SC 1.4.1).

5. **A `[TRAD]` source is named by collection + number and framed as methodology — no ruling.** A traditional row (e.g. the decay ḥadīth, *Ṣaḥīḥ al-Bukhārī 5032*) shows its **collection, number, and grading**, stays madhhab- and sect-neutral, positions the app as *servant to the teacher and the sanad chain*, and shows "needs scholarly review" plainly where sign-off is pending. No row interprets a verse or issues a fiqh verdict. `docs/science/11-the-in-app-science-screen.md` §4 (religious claims sourced by name/number) and §8 (methodology, not rulings); **domain-adab-and-religious-integrity**.

6. **The link clearly leaves the app — and is meaningless-but-harmless offline.** A tappable URL is an **optional convenience**, never the citation itself: it is visibly marked as an external link (a non-color "opens externally" glyph + a localized "opens in your browser" / "leaves the app" hint), and offline it simply does nothing — the on-device reference still carries full trust. The tap opens the system browser via the platform launcher; the app makes **no in-app fetch** of the source. `docs/science/11-the-in-app-science-screen.md` §2 (bundled, static, offline; source links degrade gracefully; *no runtime fetch*) and §4; external-link honesty in `docs/design-system/10-privacy-and-trust-ux.md` §3 (specific, verifiable; link is the check) and §7 (verification links are mixed Latin/RTL runs, bidi-isolated, ≥48dp).

7. **No coercion, no engagement mechanics on the row.** The row explains; it never sells, nags, frightens, or counts. No "5 of 12 sources read" progress, no badge for expanding the evidence, no urgency, no guilt, no decay-as-threat framing. A calm, declarative line does the work. `docs/science/11-the-in-app-science-screen.md` §6 (calm, no coercion; no engagement mechanics on the science); **domain-adab-and-religious-integrity**.

8. **Accessible, RTL-native, locale-numeral by construction.** The row meets WCAG 2.2 AA — ≥4.5:1 text contrast across light/sepia/dark, resizable text at 200% with **reflow** (no truncation, no horizontal scroll), and the grade never color-only. The year and any number render in **locale numerals** (Extended Arabic-Indic ۰۱۲۳ for fa/ckb, Arabic-Indic ٠١٢٣ for ar, via `intl` `NumberFormat` + `type.numeral`, never raw ASCII); the Latin author/venue/URL run is **bidi-isolated (FSI/PDI)** so it never reorders inside the RTL line; placement uses `EdgeInsetsDirectional` / logical start/end and the external-link glyph sits at the logical **end**. `docs/science/11-the-in-app-science-screen.md` §7 (WCAG 2.2; grade never color-only; RTL + numerals + bidi isolation); numeral/isolation mechanics via **eng-rtl-and-bidi-layout**.

9. **Offline, no-AI, on-device by construction.** Every word of the claim, citation, grade, and confidence label ships **inside the app binary or the verified core pack** and renders locally — no live feed, no model generating an explanation, no "latest research" fetch. Corrections ship as an app/pack update, never a silent remote edit. `docs/science/11-the-in-app-science-screen.md` §2 (bundled, static, offline, no AI; versioned with the app); relies on **domain-asset-pack-integrity** for the verified pack.

10. **One screen-reader phrase, locale-tagged.** Merge the row into one localized phrase so a screen reader hears the headline, the source, the confidence label, and "external link" as one node in the active locale — the year and Latin runs voiced correctly via their `locale`/bidi tags, the external-link glyph announced as words ("opens in your browser"), decoration excluded. `docs/science/11-the-in-app-science-screen.md` §7 (semantic label per locale); merge/exclude mechanics consistent with the app's component semantics rule.

## Do / Don't

| Do | Don't |
|---|---|
| Render one row from one verified `CLAIMS.md` entry (claim + value/rule + source + grade) | Hand-write a science claim, citation, or grade into the row with no register entry |
| Lead with a plain headline (`type.body`, user's frame); put the source/grade/caveat in an optional "the evidence" expansion | Surface effect sizes, parameter names, or paradigm labels as the primary unglossed text |
| Show the named, dated source on the face (e.g. *Cepeda et al., 2006*) as on-device text | Print "studies show" / "scientifically proven" with no named, dated, on-device source |
| Render the grade as plain confidence words + a non-color glyph + the text tag ("meta-analysis") | Render the grade as ★★★★★, a "proven" badge, a percentage, or by color alone |
| Show a `[TRAD]` source with collection + number + grading, as methodology; "needs scholarly review" where pending | Interpret a verse, issue a fiqh ruling, or strip a hadith of its collection/number/grading |
| Mark the link as visibly leaving the app (external glyph + "opens in your browser" hint); open the system browser | Disguise an external link as in-app, or hide a citation behind a link that is meaningless offline |
| Keep the citation full and trustworthy as on-device text; link is an optional convenience | Fetch the claim, citation, or "latest research" at runtime, or render any of it from an AI model |
| Render year/number in locale numerals (`intl` + `type.numeral`); bidi-isolate (FSI/PDI) the Latin author/venue/URL | Splice raw ASCII digits into the localized run, or let the Latin author/URL reorder the RTL line |
| Reference `type.*` / `color.*` / `space.*` / `touch.min` / `type.numeral` by name; logical start/end | Inline a hex / pt / dp, encode the grade in a hue, or hard-code left/right |
| Keep it explanation: calm, declarative, no count/badge/urgency | Add "N of M sources read," a badge for expanding, urgency, guilt, or decay-as-threat |

## Checklist

Before this source row / grade tag / citation block is done:

- [ ] The row renders **one verified `CLAIMS.md` entry** (claim text, value/rule, source, grade); no hand-written science, no orphan fact — authoring lives in **domain-claims-register-and-science-screen** (`docs/science/11-the-in-app-science-screen.md` §1).
- [ ] Two-layer copy: a **plain headline** (`type.body`, user's frame) on the face; the named source, grade, and caveat in an optional **"the evidence"** expansion; FSRS/retrievability glossed once (`docs/science/11-the-in-app-science-screen.md` §3).
- [ ] The **named, dated source** is on the face (author/year/venue) as **readable on-device text**, useful with no connection (`docs/science/11-the-in-app-science-screen.md` §4).
- [ ] The **grade is plain confidence language** about the *evidence* (e.g. "among the best-established findings" for `[MA]`), conveyed by **text tag + a non-color glyph** — **never** ★★★★★, a "proven" badge, a retention %, or color alone (`docs/science/11-the-in-app-science-screen.md` §5, §7 / SC 1.4.1).
- [ ] A **`[TRAD]`** source shows **collection + number + grading**, is framed as **methodology** (no fiqh ruling, sect/madhhab-neutral, servant-to-teacher), with "needs scholarly review" shown plainly where pending (`docs/science/11-the-in-app-science-screen.md` §4, §8; **domain-adab-and-religious-integrity**).
- [ ] Any URL is an **optional** convenience visibly marked as **leaving the app** (external glyph + "opens in your browser" hint), opens the **system browser** (no in-app fetch), and **degrades gracefully offline**; the citation never depends on the network to be trustworthy (`docs/science/11-the-in-app-science-screen.md` §2, §4; `docs/design-system/10-privacy-and-trust-ux.md` §3, §7).
- [ ] **No coercion or engagement mechanics**: no "N of M read," no badge for expanding, no urgency, guilt, or decay-as-threat; calm, declarative copy only (`docs/science/11-the-in-app-science-screen.md` §6).
- [ ] **Offline / no-AI by construction**: claim, citation, grade, and confidence label ship inside the binary / verified core pack and render locally; no runtime fetch, no model generation; corrections ship as an app/pack update (`docs/science/11-the-in-app-science-screen.md` §2; **domain-asset-pack-integrity**).
- [ ] **Accessibility / RTL**: ≥4.5:1 contrast across light/sepia/dark, resizable text at 200% with **reflow** (no truncation / horizontal scroll); year & numbers in **locale numerals** (Extended Arabic-Indic fa/ckb, Arabic-Indic ar via `intl` + `type.numeral`); Latin author/venue/URL **bidi-isolated (FSI/PDI)**; `EdgeInsetsDirectional` / logical start/end, external-link glyph at logical end — no hardcoded left/right (`docs/science/11-the-in-app-science-screen.md` §7; **eng-rtl-and-bidi-layout**).
- [ ] The whole row is **one ≥48dp** affordance where it taps to a source, **`MergeSemantics`**-merged into one localized phrase (headline + source + confidence label + "external link"), each run `locale`/bidi-tagged, decoration `ExcludeSemantics` (`docs/science/11-the-in-app-science-screen.md` §7).
- [ ] On-screen wording **matches** the value/rule the engine actually uses for the claim — no drift between the row's copy and the app's behavior (`docs/science/11-the-in-app-science-screen.md` §1).
- [ ] Widget + golden tests cover the row for an `[MA]` and a `[TRAD]` claim across **fa/ckb/ar** on the **real** bundled UI fonts (never `Ahem`), a grayscale/deuteranope check that the grade survives without color, and an `HttpOverrides` offline guard asserting tapping the link triggers **no in-app network call** (**eng-write-dart-test**).

The source row makes one honest, calm claim — *here is who found this, when, and how strong the evidence is* — so a sceptical ḥāfiẓ, teacher, or scholar can see attributed scholarship, not the app's opinion. If a row ever tempts you toward a star rating, a "proven" badge, a retention promise, a grade-of-the-user, or a citation that dies offline, that is the non-negotiables being violated, not a missing feature. The standard is *iḥsān*, because the work is built free, *lillāh*.

## Files

- `template.dart` — copy-paste scaffold: the domain-blind `EvidenceGradeTag` leaf (confidence text + non-color glyph, never color-only), the `SourceCitation` leaf (on-device author/year/venue text with locale numerals + bidi-isolated Latin runs and the optional "leaves the app" external link), the feature-layer `ScienceSourceRow` mapping a registered claim → the two-layer row with `MergeSemantics`, and the per-locale RTL / offline / no-color golden test stub — with `// TODO` markers and every token/rule referenced by name.
- `references.md` — the exact governing doc sections that own this row, each with the one thing to take from it, and the sibling skills.

Related skills: **domain-claims-register-and-science-screen** (the `CLAIMS.md` register + the whole science screen this row renders one entry of — the only author of a claim), **ui-certainty-label** (the grade → lay confidence-phrase badge this row composes in its "the evidence" expansion), **domain-scheduling-engine-rules** (the engine rule a claim *describes* but the row never re-derives), **domain-adab-and-religious-integrity** (the calm, sect-neutral, no-ruling, servant-to-teacher copy and the `[TRAD]` framing), **eng-rtl-and-bidi-layout** (locale numerals, FSI/PDI bidi isolation of the Latin author/venue/URL, RTL mirroring), **eng-add-localized-string** (the ARB strings for the headline, grade label, and "opens in your browser" hint), **domain-asset-pack-integrity** (the verified offline pack the bundled citation text ships inside), **eng-write-dart-test** (the per-locale RTL / CVD / offline golden harness on the real bundled fonts).
