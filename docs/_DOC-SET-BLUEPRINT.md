# Hifz Companion — Documentation Blueprint (authoring contract)

> This file is the **authoring contract** for the three research-backed doc sets — `docs/design-system/`, `docs/engineering/`, `docs/science/`. Every agent that writes a doc MUST read this file first, plus `docs/PRD.md` and `research/RESEARCH-FINDINGS.md`. It defines the anatomy, citation rules, tone, and evidence grades so all three sets match one consistent, auditable standard.
>
> The standard we are matching is the CycleVault doc set at `/Users/zakariafatahi/Projects/MobileApps/CycleVault/docs/`. You MAY read 1–2 exemplar files there to match *structure and tone* — but the DOMAIN is completely different (we are an Islamic Quran-memorization app in Flutter, not a menstrual tracker in Swift). Never copy CycleVault's menstrual/medical content, Swift/iOS specifics, or citations.

---

## 0. The app, in one paragraph (the subject of all these docs)

**Hifz Companion** is a fully offline, free (built as *ṣadaqah jāriyah*) Flutter app that helps huffaz and serious students **retain** the Quran. Its core is an intelligent muṣḥaf-**page** revision scheduler that dresses a modern spaced-repetition engine (FSRS-style) in the traditional **sabaq / sabqi / manzil** workflow, so a ḥāfiẓ is told exactly what to revise today, nothing silently decays, and the daily load stays feasible. **Locked constraints:** no AI / no audio recognition; no backend/accounts/telemetry; Quran assets download once from a public open-source GitHub repo then run fully offline; languages **Persian (fa), Kurdish Sorani (ckb), Arabic (ar) — all RTL**; Flutter + local-first Drift/SQLite + a pure-Dart engine. Full constraints, engine, and non-negotiables are in `docs/PRD.md`. The deep research is in `research/RESEARCH-FINDINGS.md`.

---

## 1. The shared values (seed the READMEs from these)

Each area's README expresses its own "pillars / non-negotiable values," each backed by the single strongest piece of evidence (a real citation). Seed them from these; refine with what the research turns up.

**Design-system pillars (Islamic, calm, RTL):**
1. **Reverence first (adab).** The muṣḥaf is sacred; it is rendered faithfully, never decorated, gamified, or trivialized.
2. **Calm, not cute.** Low-arousal, no streaks/badges/confetti/guilt — peace of mind, not engagement farming.
3. **Tradition is the interface.** The day looks like sabaq/sabqi/manzil a teacher recognizes; the algorithm is invisible.
4. **Honest about decay.** Nothing silently rots; the retention heat-map makes the invisible visible; never "safe to drop."
5. **Private & offline by feel.** No account, on-device, works in airplane mode — trust is structural and perceptible.
6. **RTL-native & multilingual.** fa/ckb/ar are first-class, not a bolted-on mode; correct numerals, calendars, and Arabic-script type.
7. **Servant to the teacher.** Talaqqī and the sanad chain are respected; the app aids, never replaces, oral correction.

**Engineering non-negotiable values:**
1. **Quran text fidelity is existential** (immutable glyph rendering, checksums; a single wrong diacritic ends the project).
2. **Deterministic, testable scheduling engine** (pure Dart, golden tests, no I/O, "today" injected).
3. **Fully offline; no backend, no telemetry** (assets via verified one-time download, then airplane-mode forever).
4. **Date & calendar correctness** (Hijri / Solar-Hijri-Jalālī / Gregorian; calendar-date value type, no instant bugs).
5. **Crash-safe local persistence** (Drift/SQLite, transactional writes).
6. **No AI — local arithmetic only** (no ML, no model, no network inference).
7. **Open-source & auditable** (verifiable asset integrity, reproducible-ish, license clarity).

**Science non-negotiable values:**
1. **Every in-app factual claim is cited and graded** (the CLAIMS register; no claim ships unsourced).
2. **Memory science is the engine's foundation** (spacing effect, retrieval practice, interference, overlearning).
3. **Tradition validated, not replaced** (sabaq/sabqi/manzil ≈ expanding-interval SR; show the convergence).
4. **Religious/methodology claims are sourced to identifiable scholarship and scoped carefully** — the app surfaces methodology, **never issues a fiqh ruling**, and stays madhhab/sect-neutral.
5. **Honest about uncertainty** (we cannot promise perfect retention; near-100% comes from overlearning + the cycle ceiling, not a magic number).
6. **Non-coercive motivation** (the evidence *against* guilt, streaks, and gamification of worship).

---

## 2. Citation convention (identical across all three sets) — READ CAREFULLY

- Every significant claim carries an **inline citation**: research = `([Author et al., Year](url))`; platform/docs = `([Flutter: Page](url))`, `([Dart: Page](url))`, `([Unicode: …](url))`, `([WCAG 2.2](url))`, etc.
- **Citations MUST be real and verifiable.** Use WebSearch/WebFetch to find and confirm each source; verify the URL resolves and the author/year/venue are correct. **Never fabricate** a citation, DOI, author list, or URL. Prefer canonical, well-documented works (e.g., Ebbinghaus 1885; Cepeda et al. 2006 spacing meta-analysis; Roediger & Karpicke 2006; Bjork & Bjork desirable difficulties; the FSRS papers/repos) whose details you can verify.
- If a claim cannot be sourced, **rewrite it as an explicit assumption** ("Assumption (uncited): …") or remove it — never keep an uncited "best practice."
- Each numbered/synthesis doc ends with a `## References` section listing **only** the sources cited in that file. `REFERENCES.md` is the deduplicated, graded master.
- Religious content: cite identifiable scholarly/traditional sources (named books/authors/sites); for any hadith, give the collection and number and note grading where relevant; do **not** present rulings; flag "needs scholarly review" where appropriate.

---

## 3. Evidence grades

**Science** (used in CLAIMS.md and REFERENCES.md): `[MA]` meta-analysis/systematic review · `[RCT]` randomized experiment · `[EXP]` controlled cognitive experiment · `[CS]` classic foundational study · `[OBS]` observational/applied/field study · `[TEXT]` textbook/expert review · `[TRAD]` traditional/scholarly Islamic source. Preference among empirical: MA > RCT/EXP > CS > OBS > TEXT. Methodology/religious claims are `[TRAD]` and must name the source.

**Engineering** (used in the tech-decision log and REFERENCES): cite official docs (Flutter/Dart/Unicode/SQLite/Drift/FSRS), standards (WCAG, Unicode UAX), and peer-reviewed SE evidence where a practice is claimed to improve quality.

**Design-system**: cite HCI/perception/typography/behavioral research and platform guidance (Material 3, Flutter, WCAG, Unicode bidi).

---

## 4. Document anatomies (match these exactly)

### 4a. README.md (per area)
Sections, in order: **Title + one-paragraph overview** → **Non-negotiable values / pillars** (each: short statement + the single strongest evidence with a real citation) → **One or two "rules that outrank everything"** → **File index** (table: file → what it covers) → *(engineering only)* **Stack at a glance** table + a canonical **tech-decision log** table (numbered decisions, one-line rationale each; docs cite them as "Decision log: *topic*") → *(design-system only)* **Token discipline** table (which file owns `color.*`, `type.*`, `space.*`, `motion.*`) → **Citation convention** (point to this blueprint) → **Status** → **References**.

### 4b. Numbered synthesis docs
- **Design-system & science docs:** Title + 1-paragraph intro (cross-links siblings) → an "at a glance" table where useful → numbered sections, each as **Statement** → **Evidence** (bulleted, every point cited) → **In practice** (table or bullets; concrete, implementable; design tokens referenced by name) → **Anti-patterns — we will never:** → a closing `## References`.
- **Engineering docs:** Title + intro → for each decision: **Decision** (state it, reference the decision-log entry) → **Rationale** (cited) → **Specification** (schemas, APIs, Dart code blocks, tables, test vectors) → **Pitfalls / what we refuse** → `## References`. Be concrete enough to implement against.

### 4c. research/ notes (the deep evidence dossiers the synthesis docs distill)
Title → `**Topic:**` / `**Compiled:**` metadata lines → `## What the evidence says` (numbered, themed subsections, each finding cited to a real source with specifics) → `## Implications for Hifz Companion` (numbered, actionable) → `## Citations` (numbered full references with URLs and, for science, grades).

### 4d. CLAIMS.md (science only)
A register: intro explaining it indexes **every user-facing factual claim** the app makes; the grade legend; then grouped tables with columns: **ID** (C-001…), **Claim (as the app states it)**, **Value/rule the app uses**, **Source(s)** (inline cited), **Grade**, **App surface**, **Notes/caveats**. Groups for our app, e.g.: *Memory & forgetting*, *Spacing & scheduling*, *Retrieval & self-testing*, *Interference & mutashābihāt*, *Overlearning & retention*, *Traditional methodology*, *Motivation & adab*, *Cross-cutting honesty/neutrality*. End with `## References`. No claim without ≥1 verified source.

### 4e. REFERENCES.md (per area)
Intro line → the deduplicated master bibliography (alphabetical or grouped), each entry full (authors, year, title, venue, URL) and, for science, a trailing `— [GRADE]`. A short "what each source informed" annotation is encouraged where it adds clarity.

---

## 5. Tone & voice (for an Islamic app built lillāh)

Calm, precise, adult, reverent. No hype, no marketing, no exclamation marks in product copy. Respect the sacredness of the Quran and the dignity of the user; never gamify worship or weaponize guilt. Use correct transliteration (ḥāfiẓ, murājaʿa, mutashābihāt, talaqqī, muṣḥaf, riwāyah) and Arabic where apt. Stay madhhab- and sect-neutral. Where something needs a scholar's sign-off, say so plainly. Excellence (*iḥsān*) is the standard because the work is for Allah.

---

## 6. Planned doc taxonomy (for transparency; the workflow drives the exact files)

**science/** — README, CLAIMS, REFERENCES + synthesis: 01-memory-and-forgetting, 02-the-spacing-effect, 03-spaced-repetition-algorithms, 04-retrieval-practice-and-self-testing, 05-interference-and-mutashabihat, 06-overlearning-and-lifelong-retention, 07-serial-recall-and-the-page-unit, 08-sleep-consolidation-and-scheduling, 09-motivation-without-coercion, 10-traditional-hifz-methodology, 11-the-in-app-science-screen. research/: forgetting-curve, spacing-effect, spaced-repetition-algorithms, retrieval-practice, interference-theory, overlearning-automaticity, serial-recall-chunking, sleep-and-consolidation, motivation-habit-noncoercive, hifz-methodology-evidence, quran-memorization-research.

**engineering/** — README (+decision log), REFERENCES + synthesis: 01-architecture-overview, 02-project-structure, 03-coding-standards, 04-flutter-and-state-patterns, 05-persistence-and-encryption, 06-scheduling-engine, 07-dates-calendars-and-correctness, 08-quran-data-and-immutable-rendering, 09-asset-packs-and-offline-integrity, 10-backup-format, 11-testing-strategy, 12-localization-rtl-accessibility-impl, 13-oss-repo-and-release. research/: flutter-architecture-2026, dart-effective-clean-code, state-management-riverpod, drift-sqlite-persistence, fsrs-and-sr-implementations, calendars-i18n-hijri-jalali, flutter-rtl-i18n, arabic-script-rendering-fonts, flutter-testing-ci, asset-integrity-and-distribution, oss-mobile-release-fdroid.

**design-system/** — README (+token map), REFERENCES + synthesis: 01-design-principles, 02-material-and-platform-foundations, 03-color-and-themes, 04-typography, 05-layout-spacing-touch, 06-motion-and-haptics, 07-components, 08-data-visualization, 09-accessibility-and-inclusivity, 10-privacy-and-trust-ux, 11-voice-and-tone, 12-localization-and-rtl, 13-islamic-identity-and-adab. research/: islamic-app-design-patterns, material3-flutter-design, arabic-persian-kurdish-typography, calm-non-gamified-design, color-emotion-and-theming, data-visualization-heatmap-uncertainty, accessibility-rtl-inclusive, privacy-trust-ux, voice-tone-religious-adab, behavior-habit-design.

The app name "Hifz Companion" is a working title; if the project later picks a name (e.g., from PRD §naming), update the READMEs.
