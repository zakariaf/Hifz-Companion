# E09-T09 — Swappable sabaq/sabqi/manzil term-sets: ICU select/region-override + grade verbs/cycle names + provisional ckb flagging

| | |
|---|---|
| **Epic** | [E09 — Localization & RTL Foundation](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E09-T01, E09-T03 |
| **Skills** | eng-add-localized-string |

## Goal

The regional sabaq/sabqi/manzil track labels, the four traditional grade verbs (Again/Hard/Good/Easy → "needed help" / "minor mistakes" / "recited clean" / "effortless"), and the cycle/preset names exist as ICU `select`-over-a-region-key entries in `app_ar.arb` (the base) with transcreated `app_fa.arb` and provisional `app_ckb.arb` values — so swapping a whole vocabulary is a one-file, data-only edit and *never* a code change. A widget reads the active term-set's traditional verb to drive the four-grade surface; the engine signal (`Grade.again/hard/good/easy`) is unchanged. The `ckb` term-set values carry "needs native + scholar review" in their `@description` and ship clearly provisional. No widget ever hard-codes "Manzil"/"Sabqi"/"Dhor", and no base string is edited to localize a region's vocabulary.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §5 (Decision + Specification + Pitfalls) | The region-override `select` model: `"trackFar": "{region, select, levant{…} subcontinent{…} other{…}}"` with `placeholders.region` typed `String`; the `@description` carries "NEEDS scholar review"; "we refuse to edit base strings to localize a region's vocabulary"; Kurdish defaults stay flagged |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §1 | `ar` is the template/base content language (`app_ar.arb` first); `nullable-getter: false` makes a missing/typo term-set key a compile error; `@description` is the translator/scholar-context contract; **no user-facing strings in `/engine`** — the engine returns the `Grade` enum, the feature layer localizes the verb |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §3 | `ckb` values are canonical-encoding-sensitive (U+06D5 ە for AE, U+06A9 ک for kaf; no stray U+200C ZWNJ, no Teh-Marbuta-for-AE) and stay provisional pending native + scholar review — the same lint E09-T03 stands up applies to these new `ckb` strings |
| `docs/design-system/12-localization-and-rtl.md` §6 (full section + anti-patterns) | Term-sets are swappable string data with a regional override addressed by a logical key (`track.far`, `grade.again`, `cycle.weeklyKhatm`); `term_label_set`/`region_preset` on `cycle_config` selects the override; the four-grade scale shows the localized traditional verb with the engine signal unchanged; "never hard-code 'Manzil'/'Sabqi'", "never force one region's vocabulary on every locale", "never lock the ckb term-set before review" |
| `docs/design-system/12-localization-and-rtl.md` §7, §8 | Canonical Sorani encoding is enforced before build; the term-set toolkit is chrome-only and never reaches a muṣḥaf glyph |
| `docs/design-system/11-voice-and-tone.md` §8, §9 | Per-locale **transcreation**, never literal translation: Persian respectful-warm (*šomā*-aware), Arabic forms with imperatives softened to statements of readiness, Sorani register + vocabulary by native reviewers (provisional); the banned-phrase (adab) lint + native + scholar review per locale |
| `docs/PRD.md` §6.3 (grade-verb table) | The canonical four traditional verbs that the active term-set localizes: Again→"needed help", Hard→"minor mistakes", Good→"recited clean", Easy→"effortless" — the *surface* words only; the grade signal is identical across sources |
| `docs/PRD.md` §13.4 (term-set table) | The illustrative ar/fa/ckb default mapping (New lesson, Near-revision, Far-revision, Revision, Manzil) — these are **defaults, not fixed strings**; the ckb column is "best-effort, needs native + scholar review"; the architecture must make a term-set swap one file |
| `docs/PRD.md` §15.1, §15.2, §21.1 | The named cycle/preset vocabulary this task localizes (7-Manzil weekly khatm, 1 juz/day, ½ juz/day, 2 juz/day, Custom, Pure-cycle mode); the term-set selector is regional vocabulary independent of UI language; §21.1 is the open decision keeping ckb/term-set defaults provisional pending review |
| Skill `eng-add-localized-string` (SKILL §8; `template.md` §5 the `select`/region-override block, §6 the ckb canonical-encoding + provisional-flag block, §7 voice/adab) | The canonical procedure this task is an instance of: author the `select` in `app_ar.arb` first, resolve via `l10n.*` against `cycle_config.regionPreset`, show the active set's traditional verb for Again/Hard/Good/Easy, canonical-encode + flag `ckb`, transcreate to the four voice attributes, run the gate |
| CLAIMS | None. This task ships chrome wording only (track labels, grade verbs, cycle names) — it originates **no** user-facing factual number, scheduling rule, or methodology claim. The grade *meaning* and the engine math are registered/owned by their feature epics; this task only swaps the surface vocabulary |
| Siblings: E09-T01, E09-T03, E09-T02, E09-T10 | **T01** supplies the finalized `l10n.yaml` (ar base, `nullable-getter: false`) and `app_ar.arb` foundation keys this task extends (dependency); **T03** supplies the `ckb` locale + canonical-Sorani encoding lint these `ckb` term-set values must pass (dependency); **T02** owns the hardcoded-string + banned-phrase greps that catch a hard-coded "Manzil"; **T10** renders these term-set strings in the per-locale RTL/numeral golden suite |

## Implementation notes

TEST-FIRST for the term-set resolution + ARB-completeness invariants: write the resolver unit test and the `select`-branch-completeness check (below) before the ARB entries and the `TermSet` resolver are populated; the active-region→verb mapping and the "every `select` has an `other` branch / every locale defines every region key" assertions must exist and fail first.

1. **ARB term-set keys live in `lib/l10n/app_ar.arb` first (the `ar` base content language).** Add one ICU `select`-over-region entry per regional concept, each with `placeholders: { "region": { "type": "String" } }` and an `@description` that names the concept and carries "NEEDS scholar review". The concepts (from PRD §13.4 + §6.3 + §15.1), keyed logically:
   - Track labels: `trackNewSabaq`, `trackNearSabqi`, `trackFarManzil`, `trackRevisionGeneral` (§13.4 rows).
   - The four grade verbs: `gradeAgainVerb`, `gradeHardVerb`, `gradeGoodVerb`, `gradeEasyVerb` — the localized traditional verb only ("needed help" etc., §6.3), NOT the `Grade` enum name and NOT a number.
   - Cycle/preset names: `cycleWeeklyKhatm`, `cycleOneJuzPerDay`, `cycleHalfJuzPerDay`, `cycleTwoJuzPerDay`, `cycleCustom`, `cyclePureMode` (§15.1).
   Use the `{region, select, …}` shape from engineering 12 §5 verbatim in structure (region keys + a required `other` fallback). Author the *whole* concept as one entry — never two glued fragments.
2. **`app_fa.arb` and `app_ckb.arb` are transcreations diffed against `ar`, never literal translations.** Persian respectful-warm register (design 11 §8); Sorani register + vocabulary provisional. Each `ckb` term-set entry's `@description` carries "needs native + scholar review; encoding: U+06D5 ە, U+06A9 ک" and the values are canonically encoded so the E09-T03 Sorani lint passes (no U+200C ZWNJ, no Teh-Marbuta-for-AE). Use the PRD §13.4 ckb column only as a provisional default.
3. **The region key is *data*, sourced from `cycle_config`, never a code constant.** The resolver reads `regionPreset` (the `term_label_set` / `region_preset` field on `cycle_config`, design 12 §6 / PRD §10.2) and passes it into the `select` placeholder. This task does **not** add the Drift column or the Settings picker (that is E16 / the persisted-model epic) — it consumes whatever `String` region key the active config exposes and falls through to the `other` branch when unset. Do not invent a new persistence surface here.
4. **A small presentation-layer resolver maps the engine `Grade` enum → the active term-set's localized verb.** In the feature/presentation layer (e.g. `features/.../grade/term_set.dart`), a pure function `gradeVerb(AppLocalizations l10n, Grade grade, String region) → String` switches `Grade.again/hard/good/easy` to `l10n.gradeAgainVerb(region)` etc. The **engine signal is unchanged**: the engine still emits `Grade`, and nothing in `/engine` imports `AppLocalizations`/`intl` (engineering 12 §1; a grep enforces this). The four-grade UI surface (the recite/grade band) renders `gradeVerb(...)`, never a literal verb.
5. **No bidi/numeral coupling.** Term-set values are pure RTL Arabic-script words with no embedded opposite-direction run and no number — so they need no `bidi.dart` isolation and no `numberFormatFor` call. (Cycle names that *contain* a count, e.g. "7-Manzil", express the "7" as part of the transcreated phrase per locale, not as a spliced ASCII digit — keep the digit inside the ICU value's locale-appropriate wording, or defer any live count to the count-bearing plural path of E09-T07; do not concatenate `"7" + label`.)
6. **Pitfalls to avoid:**
   - Hard-coding "Manzil"/"Sabqi"/"Dhor"/"7-Manzil" in a widget, or branching on region with a Dart `switch` that returns literals — both bypass the `select`/override and fail the E09-T02 hardcoded-string grep.
   - Editing a base `ar` string in place to localize a region's vocabulary instead of adding a `select` branch (design 12 §6 anti-pattern).
   - Letting the grade verb leak into `/engine`, or storing the localized verb anywhere — derive it at the feature boundary every render.
   - A `select` entry missing its `other` branch (a region key with no default crashes at runtime), or a locale ARB omitting a region branch the base defines.
   - Locking `ckb` term-set values as final, or shipping them without the provisional `@description` flag.
   - Treating the term-set as gamification — a track label or grade verb never becomes a badge/score; it is the *name a teacher recognizes*.

## Acceptance criteria

- [ ] `app_ar.arb` defines every term-set concept (4 track labels, 4 grade verbs, 6 cycle/preset names) as a single `{region, select, …}` ICU entry with a typed `region` placeholder and an `@description` carrying "NEEDS scholar review"; each `select` has an `other` fallback branch.
- [ ] `app_fa.arb` and `app_ckb.arb` define the same key set as **transcreations** (not literal translations), every region branch present in `ar` is present in each, and the generated `AppLocalizations` exposes one getter per term-set key (compile-clean under `nullable-getter: false`).
- [ ] Each `ckb` term-set entry is canonically encoded (U+06D5 ە, U+06A9 ک; no U+200C, no Teh-Marbuta-for-AE — passes the E09-T03 Sorani lint) and its `@description` reads "needs native + scholar review".
- [ ] A presentation-layer `gradeVerb(l10n, grade, region)` maps each `Grade` to the active term-set's localized verb; the four-grade surface renders it, and no literal grade verb appears in any widget.
- [ ] The engine signal is unchanged: `/engine` still emits `Grade` and imports no `AppLocalizations`/`intl` (grep-verified); swapping `region` changes only the displayed words, never the grade or schedule.
- [ ] No widget hard-codes "Manzil"/"Sabqi"/"Dhor"/a cycle name (passes E09-T02's hardcoded-string grep); no base `ar` string was edited to localize a region.
- [ ] The region key is read from the active `cycle_config` region preset (consumed, not redefined here) and falls through to `other` when unset.

## Tests

All tests are deterministic, offline, and require no network — they read ARB/JSON fixtures and exercise pure functions; no `DateTime.now()`, no socket. Add an `HttpOverrides` no-network guard to any widget test per `eng-write-dart-test`.

- `test/l10n/term_set_arb_completeness_test.dart` (test-first):
  - **Region-branch parity:** parse `app_ar.arb`, `app_fa.arb`, `app_ckb.arb`; for every term-set `select` key, assert each locale defines exactly the same set of region branches as `ar` and that an `other` branch is present in all three (a missing branch fails the build).
  - **Provisional-flag presence:** assert every `ckb` term-set entry's `@description` contains "needs native + scholar review".
  - **Canonical-`ckb` encoding:** assert no term-set `ckb` value contains U+200C or a Teh-Marbuta where ە (U+06D5) is expected (reuses the E09-T03 lint helper).
  - **No hard-coded verb/track literal:** a grep-style assertion that the curated set of traditional verbs and track words appears only in ARB values, not in `features/**` Dart.
- `test/.../grade_verb_resolver_test.dart` (test-first, unit): with a stub/real `AppLocalizations` per locale, assert `gradeVerb` maps `Grade.again→`"needed help"-equivalent`, …, `Grade.easy→`"effortless"-equivalent` for `ar`/`fa`, and the provisional `ckb` value; assert switching `region` changes the returned string for a region-varying concept (e.g. far-revision levant vs subcontinent) while the `Grade` argument is identical.
- `test/.../grade_band_widget_test.dart` (widget): pump the four-grade band under each of `ar`/`fa`/`ckb`; assert it renders the active term-set's verb for each grade and that the engine `Grade` passed to the controller on tap is unchanged across term-sets (the surface word differs, the signal does not).
- The per-locale RTL term-set goldens themselves are owned by **E09-T10** (rendered on the real bundled fonts, never `Ahem`); this task supplies the strings and resolver they exercise and adds a focused term-set golden case there.

## Definition of Done

- [ ] All acceptance criteria met; the ARB-completeness, resolver, and grade-band suites are green locally and in CI; the E09-T02 hardcoded-string/banned-phrase greps and the E09-T03 canonical-`ckb` lint stay green.
- [ ] **Offline / no-network:** no term-set, font, or locale data is fetched at runtime; all values are bundled ARB; tests open no socket ([PRD C1, §13.5]).
- [ ] **No AI / no microphone:** transcreations are human-authored and human-reviewed, never machine-translated; no ML/ASR dependency introduced ([PRD C2]; design 11 §8).
- [ ] **Quran text fidelity / sacred boundary held:** the term-set toolkit touches only chrome words — no track label, grade verb, or cycle name reaches a muṣḥaf glyph, an ayah number, or the immutable page; the riwāyah naming is unaffected ([PRD R1, R2, §11.2]; design 12 §8).
- [ ] **RTL + fa/ckb/ar strings:** every concept ships in all three locales as transcreations; direction stays locale-derived (the ARB values carry no physical-side/hardcoded-RTL assumption); zero missing term-set keys ([PRD C4, §13]).
- [ ] **Accessibility:** the grade verbs feed the localized `Semantics` labels on the four-grade controls (the label is the active term-set's verb, spoken in the active locale); no streak/score/badge is introduced; E08 audits the spoken result.
- [ ] **Sect-neutral adab:** every term-set value passes the adab gate and the four voice attributes (reverent/calm/plain-and-warm/honest); no never-ship phrase, no "safe to drop"/"mastered", no controlling mandate, no exclamation/emoji; the term-set states no fiqh ruling and forces no region's vocabulary on another ([PRD R3, R6]; design 11 §3–§9, design 12 §6).
- [ ] **Scholarly review flagged where pending:** the term-sets and all `ckb` values carry "needs native + scholar review" in `@description` and ship clearly provisional; a cleared term-set replaces them as a one-file data change, never a code change ([PRD §13.4, §21.1]; design 12 §6).
- [ ] **Deterministic tests:** the ARB-completeness, resolver, and widget suites are deterministic and offline; correctness-sensitive resolution (region→verb, `select`-completeness) was written test-first ([PRD §20 gate 5]; engineering 12 §8).
- [ ] **No CLAIMS attach by construction:** this task ships swappable chrome vocabulary only — it originates no user-facing factual number, scheduling rule, or methodology claim; the grade meaning and engine math remain owned by their feature epics.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
