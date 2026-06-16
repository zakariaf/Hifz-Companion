<!--
  template — domain-claims-register-and-science-screen
  Copy-paste scaffold for registering ONE user-facing factual claim and
  surfacing it on the "The science we follow" screen, fully offline, RTL, no-AI.

  THE ORDER IS LAW: (1) register the row in CLAIMS.md → (2) add/verify the
  source in REFERENCES.md → (3) write the on-screen card from the row →
  (4) write the transcreated ARB strings. A claim with no row is a
  release-blocking defect, not a copy nit. Fill every // TODO. Delete nothing
  that is a rule.
-->

<!-- ─────────────────────────────────────────────────────────────────────────
  STEP 1 — CLAIMS.md ROW  (paste under the correct group A–J)
  Groups: A Memory&forgetting · B Spacing · C Engine-math · D Retrieval ·
          E Interference · F Serial-recall · G Overlearning · H Methodology ·
          I Motivation&adab · J Cross-cutting-honesty
  All seven columns are mandatory. "Value/rule" must name the ACTUAL engine
  rule/token the claim describes (e.g. trust clamp `due = min(ideal, ceiling)`,
  cycle ceiling, stability growth `S' = S·SInc`) — owned by
  domain-scheduling-engine-rules; this skill only registers it.
───────────────────────────────────────────────────────────────────────────── -->

| ID | Claim (as the app states it) | Value / rule the app uses | Source(s) | Grade | App surface | Notes / caveats |
|---|---|---|---|---|---|---|
| C-0NN | <!-- TODO plain, user-frame sentence — murājaʿa/pages/juz/cycle, NOT lab jargon --> | <!-- TODO the exact engine rule/token, e.g. "trust clamp may pull a page forward only: due = min(ideal, ceiling)" --> | <!-- TODO ([Author et al., Year, *Venue*](https://verified-url)); hadith = collection + number --> | <!-- TODO [MA]/[RCT]/[EXP]/[CS]/[OBS]/[TEXT]/[TRAD] --> | <!-- TODO e.g. Science screen; recite flow; heat-map --> | <!-- TODO caveat; if simplified: "the app uses X; the research shows X–Y"; if [TRAD]: "methodology only, no ruling; needs scholarly review" where pending --> |

<!--
  GATES before this row is "done":
  [ ] Source VERIFIED (author/year/venue + resolving URL; hadith collection+number+grading).
  [ ] Grade follows blueprint §3 legend; grade ≠ certainty about the user's Quran.
  [ ] If [TRAD]: methodology only, sect/madhhab-neutral, NO fiqh ruling, defers to teacher/sanad.
  [ ] No retention-% promise; near-100% is attributed to the cycle ceiling + overlearning.
  [ ] "Value/rule" matches what the engine ACTUALLY does (no copy↔behavior drift).
-->


<!-- ─────────────────────────────────────────────────────────────────────────
  STEP 2 — REFERENCES.md ENTRY  (add under the matching theme group; dedupe)
  Every entry ends with its grade in the form  — [GRADE].
───────────────────────────────────────────────────────────────────────────── -->

<!-- TODO: Author, A. B., & Author, C. D. (YEAR). *Title.* Venue, vol(issue), pages. https://verified-url — **[GRADE]** -->
<!-- TODO (if [TRAD]): *Ṣaḥīḥ al-Bukhārī* NNNN (Narrator): "…". Sunnah.com. https://sunnah.com/bukhari:NNNN — **[TRAD]** -->


<!-- ─────────────────────────────────────────────────────────────────────────
  STEP 3 — SCIENCE-SCREEN CLAIM CARD  (rendered FROM the row above; never authored here)
  Two layers: plain headline (always visible) + "the evidence" (expand on demand).
  The screen is bundled/static/offline/no-AI: this content ships inside the app
  binary or a checksum-verified core pack (see domain-asset-pack-integrity).
  Accessibility: grade conveyed by TEXT TAG + optional icon, never color alone;
  ≥4.5:1 contrast (light/sepia/dark); reflow at 200%; semantic label per locale.
───────────────────────────────────────────────────────────────────────────── -->

### Claim card — references C-0NN  <!-- back-link to the register row -->

**Headline (plain, user-frame):**
> <!-- TODO same meaning as the registered claim, plainest accurate wording -->

**The evidence (expansion):**
- Source: <!-- TODO Author et al., Year — Venue (READABLE on-device text; URL is an optional offline-noop convenience) -->
- Grade tag: `<!-- TODO meta-analysis | controlled experiment | classic study | observational | textbook | traditional source -->`
- Confidence (plain words, describes the EVIDENCE not the user): <!-- TODO e.g. "among the best-established findings in memory science" / "a single controlled study" / "named traditional scholarship" -->
- Honest note (only if simplified / uncertain / pending): <!-- TODO "the app uses X; the research shows X–Y" or "needs scholarly review" -->

<!--
  CARD GATES:
  [ ] No fact appears here that is not the C-0NN row.
  [ ] No streaks/badges/urgency/guilt; no "N of M cards read"; decay/ḥadīth not weaponized.
  [ ] No retention-% promise; no "safe to drop" / "mastered".
  [ ] Grade shown as text tag (+icon), NEVER ★★★★★ / "proven" / a %.
-->


<!-- ─────────────────────────────────────────────────────────────────────────
  STEP 4 — LOCALIZED STRINGS  (ARB-style; gen_l10n / intl)
  TRANSCREATE against the one voice charter (reverent · calm · plain-and-warm ·
  honest) — do NOT literally translate. fa/ckb = Extended Arabic-Indic numerals
  (۰۱۲۳) , ar = Arabic-Indic (٠١٢٣) via NumberFormat + the `type.numeral` token,
  never raw ASCII concatenated. Bidi-isolate (FSI/PDI) any Latin source name.
  Native review per locale; scholar review for any [TRAD] terminology.
───────────────────────────────────────────────────────────────────────────── -->

```jsonc
// app_ar.arb
{
  "scienceClaimC0NNHeadline": "// TODO ar transcreation (number/gender-correct; imperatives softened)",
  "scienceClaimC0NNGradeTag": "// TODO ar grade label (text, not color)",
  "scienceClaimC0NNConfidence": "// TODO ar plain confidence wording",
  "@scienceClaimC0NNHeadline": { "description": "Science-screen headline for claim C-0NN; transcreated, no fiqh ruling, no retention promise." }
}
```

```jsonc
// app_fa.arb  (respectful-warm: šomā / honorific verb forms; taʿārof-aware)
{
  "scienceClaimC0NNHeadline": "// TODO fa transcreation",
  "scienceClaimC0NNGradeTag": "// TODO fa grade label",
  "scienceClaimC0NNConfidence": "// TODO fa plain confidence wording"
}
```

```jsonc
// app_ckb.arb  (register + religious vocab set by native + scholarly review — placeholder until then)
{
  "scienceClaimC0NNHeadline": "// TODO ckb transcreation — NEEDS NATIVE + SCHOLARLY REVIEW",
  "scienceClaimC0NNGradeTag": "// TODO ckb grade label",
  "scienceClaimC0NNConfidence": "// TODO ckb plain confidence wording"
}
```

<!--
  FINAL CHECKLIST (mirror of SKILL.md):
  [ ] Row in CLAIMS.md with all seven columns; source in REFERENCES.md, verified.
  [ ] Grade per legend; rendered as confidence language + text tag, never a star/%/badge.
  [ ] [TRAD] = methodology only, sect-neutral, no ruling, defers to teacher, "needs scholarly review" where pending.
  [ ] No retention-% promise; near-100% via cycle ceiling + overlearning; no "safe to drop".
  [ ] Plain, user-frame copy; transcreated fa/ckb/ar; FSRS/retrievability glossed once.
  [ ] Bundled/static/offline/no-AI; citations readable on-device; corrections ship as an update.
  [ ] No coercion / engagement mechanics on the science.
  [ ] WCAG 2.2 AA: grade never color-only; ≥4.5:1; reflow 200%; semantic label per locale; locale numerals; bidi-isolated Latin names.
  [ ] On-screen wording matches the engine's actual value/rule (no drift).
-->
