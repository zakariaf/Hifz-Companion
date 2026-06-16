# E11-T03 — Language pick + riwāyah/muṣḥaf confirmation single-select (display transform, edition named)

| | |
|---|---|
| **Epic** | [E11 — Onboarding & Cold-Start](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E11-T01, E10 |
| **Skills** | ui-settings-picker, eng-rtl-and-bidi-layout, eng-add-localized-string |

## Goal

Two onboarding steps land inside the E11-T01 module: a **language pick** (fa / ckb / ar, all RTL) rendered as a single-select that applies **live as a display transform** the moment it is chosen, and a **riwāyah / muṣḥaf confirmation** that names the bundled edition explicitly — **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"**, never "the Quran" in the absolute (R2). Both are dumb Views composing E10's `SettingsSinglePicker<T>`; each captures only the **named choice** into the resume-safe onboarding controller (`locale`, `mushaf` edition id) and never re-typesets, mirrors, translates, or applies UI numerals/fonts to a glyph of the muṣḥaf. The pick mutates no engine state, no `due_at`, and no stored instant — switching language re-renders the chrome; confirming the riwāyah stores an edition name. Both steps read as a radiogroup, RTL by geometry, with per-locale goldens on the real bundled fonts.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §12.1 | The exact onboarding sequence position: "Language pick (fa/ckb/ar) and muṣḥaf confirmation (riwāyah stated — R2)" — these two steps sit after welcome+privacy and before the one-time download |
| `docs/PRD.md` R2 (§4) | The two outranking rules this step must hold: the muṣḥaf is shown as **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf," never "the Quran" in the absolute**; the muṣḥaf is a **swappable named asset**, so the confirmation stores a named edition id, not a flag; **zero tafsīr/translation/commentary** — confirming the riwāyah never offers a translation or word-meaning |
| `docs/PRD.md` R5/R6 (§4) | No microphone, no telemetry on the chosen language/edition; the picker is a quiet preference, never a place that phones home or claims authority over the teacher |
| `docs/design-system/11-voice-and-tone.md` §1 (adab), §5 (authority boundary), §6 (invitation not command) | The confirmation copy names the edition as a fact, never speaks *for* the Quran, issues no ruling about which riwāyah is "correct"; no exclamation marks, no "recommended for you," no praise on a choice |
| `docs/design-system/01-design-principles.md` §1 (reverence — "State the riwāyah"), §2 (calm not cute), §3 (tradition is the interface), §5 (private by feel) | Reverence: the riwāyah is named; calm: no confetti/badge on a selection; tradition: a named edition a ḥāfiẓ recognizes, never an abstract toggle |
| `docs/design-system/12-localization-and-rtl.md` §1 (RTL geometry), §3 (FSI/PDI isolation), §4 (locale numerals), §8 (the muṣḥaf is never localized — only the chrome) | Logical start/end rows; the edition name "Ḥafṣ ʿan ʿĀṣim — Madani" carrying Latin/Arabic-script runs FSI/PDI-isolated; **§8 is the hard boundary — selecting an edition never re-renders, re-numbers, mirrors, or re-fonts a glyph of the page** |
| Skill **ui-settings-picker** (+ `template.dart` → `SettingsSinglePicker<T>`) | The canonical pattern this task implements: named single-select rows (no slider/free-text/switch), selected = shape AND text (radio glyph + label, never color alone), the **display-transform** rule (re-render chrome, mutate no engine state/instant), the muṣḥaf rule (store a **named** edition, state the riwāyah, never call it "the Quran" absolutely, never re-typeset/mirror/translate), RTL geometry, radiogroup `Semantics`, ≥48dp rows, persist-through-controller, no recommendation/celebration, fully offline. **This step composes E10's picker; it does not re-author the widget.** |
| Skill **eng-rtl-and-bidi-layout** (+ `template.dart`) | Direction is locale-derived (no hardcoded `Directionality`); logical `EdgeInsetsDirectional`/`AlignmentDirectional` only; the **language preview is one of the two permitted manual-`Directionality` islands** — render a sample line in the candidate locale's own direction; isolate the edition name's mixed Latin/Arabic-script run via `isolateRtl`/`isolate`; no mirroring/numeral/bidi reaches the glyph layer (§8) |
| Skill **eng-add-localized-string** (+ `template.md`) | Author keys in `app_ar.arb` (template/base) first, transcreate fa/ckb/ar; read only through `AppLocalizations` (`l10n.*`); no literal in `features/**`; the edition name **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"** is one ICU message with the script run isolated, never hard-spliced; ckb values canonical-encoded (U+06D5 ە, U+06A9 ک), flagged provisional pending native + scholar review; adab gate first |
| `docs/science/CLAIMS.md` | **No CLAIMS id consumed** — this step surfaces no factual/methodology number and no scheduling claim; the only fixed copy is the riwāyah name (R2 naming, not a graded claim). The privacy/servant claims (C-048/C-046) belong to the welcome step (E11-T02). |
| Siblings: **E11-T01**, **E11-T02**, **E11-T10**, **E10** | T01 supplies the `/onboarding` route, the step controller, and the resume-safe captured state (`locale`, `mushaf choice`, …) this task writes two fields of — **the controller, not this View, owns the write**; T02 (welcome+privacy) precedes this step; the next step is the one-time download (E11-T04). T10 owns the final per-locale golden/Semantics/RTL/offline-guard sweep across all steps; this task ships its own widget + golden tests so T10 audits, not authors. E10 supplies `SettingsSinglePicker<T>` and the welcoming onboarding chrome. |

## Implementation notes

1. **Files** (in the E11-T01 onboarding module, `packages/features/lib/src/onboarding/`):
   - `widgets/language_step.dart` — the dumb View for the language pick, composing E10's `SettingsSinglePicker<AppLocaleChoice>`.
   - `widgets/riwayah_step.dart` — the dumb View for the riwāyah/muṣḥaf confirmation, composing the same `SettingsSinglePicker<MushafEdition>` (one edition selectable in v1: `hafs_madani15`).
   - No new feature-scope provider file here; both steps read from and call into **E11-T01's `onboardingControllerProvider`** (the resume-safe captured state). The View never writes — per the feature-module View-never-writes rule.

2. **Captured-state fields.** This task writes exactly two fields of E11-T01's captured state: `locale` (the chosen `Locale` — `fa`, `ckb`, or `ar`) and `mushafEditionId` (the named edition id string, e.g. `'hafs_madani15'`). Selecting a row calls one controller method (`setLocale(Locale)` / `confirmMushaf(String editionId)`); the controller persists/holds the choice **before** republishing in-memory state. There is **no `(D, S)`, no `due_at`, no engine call** anywhere in this step.

3. **Language pick is a live display transform.** Choosing fa/ckb/ar updates the app `Locale` immediately so the rest of onboarding re-renders in the chosen language and direction — this is a re-render of chrome only, not a string edit or a glyph change (ds-12 §4/§8). Direction comes from the locale (`supportedLocales: [ar, fa, ckb]` + `GlobalWidgetsLocalizations`); do **not** wrap the step in a hardcoded `Directionality`. The one permitted manual-`Directionality` island is the **per-row language preview** (a short sample rendered in the candidate locale's own direction) per eng-rtl-and-bidi-layout §2.

4. **Riwāyah confirmation names the edition.** The single row reads the localized edition label via `l10n.mushafEditionHafsMadani` → **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"**, with a calm subtitle stating it is the bundled edition and that the scheduler is text-agnostic (swappable later in Settings — E16), framed as information, not a ruling. It stores only `mushafEditionId`. It renders **no muṣḥaf glyph** (the core pack is not downloaded yet — E11-T04 follows; rendering any page before `text_checksum_verified_at` is forbidden), offers **no translation/transliteration/tafsīr**, and never prints "the Quran" absolutely.

5. **Selected state is shape AND text.** Each option pairs the radio glyph / check with its text label, drawn as an M3 state layer over a role color — never color alone, never per-component opacity (ui-settings-picker rule 2; WCAG 2.2 SC 1.4.1). Rows are ≥48dp `touch.min`, ≥`space.2` apart, and never shrink below 48dp under OS text scale.

6. **RTL + bidi + numerals.** All geometry is logical (`EdgeInsetsDirectional`/`AlignmentDirectional`/`Positioned.directional`); no `EdgeInsets.only(left:/right:)` survives the `features/**` grep. The edition name mixes Arabic-script ("Ḥafṣ ʿan ʿĀṣim") and transliteration/Latin punctuation — route the run through the `bidi.dart` helper (`isolateRtl` for the known-RTL Arabic run; `isolate`/FSI only where direction is genuinely unknown) so it never reorders its line (ds-12 §3). Any number that appears (e.g. a line count, if shown) formats via `numberFormatFor(locale)` (fa/ckb arabext, ar arab) — never ASCII digits.

7. **Strings (eng-add-localized-string).** New keys authored in `lib/l10n/app_ar.arb` first, transcreated for fa/ckb/ar:
   - `onboardingLanguageStepTitle`, `onboardingLanguageStepBody`
   - language option labels (each language's **endonym**: `فارسی`, `کوردیی ناوەندی`, `العربية`) and their `Semantics` selected/not-selected values
   - `onboardingRiwayahStepTitle`, `onboardingRiwayahStepBody`
   - `mushafEditionHafsMadani` = "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf" (one ICU message, script run isolated; `@description` notes it is an R2-required edition name and must not be rendered as "the Quran")
   - the confirm/continue affordance label.
   ckb values canonical-encoded and flagged "needs native + scholar review" in `@description`; the riwāyah name is methodology-adjacent → run past the adab/scholar gate; no literal in `features/**`.

8. **TEST-FIRST note.** Correctness-critical for this step = the **no-glyph-mutation / no-engine-write / display-transform** invariants. Write the widget tests in §Tests asserting (a) selecting a language routes through the controller and mutates **only** `locale` (no engine/`due_at`/instant write), (b) the tree contains **no `Slider`**, no muṣḥaf glyph render, and no "the Quran"-absolute string, and (c) the riwāyah row's text contains the exact named edition — **before** wiring the Views. Pure-UI radiogroup geometry is golden-tested, not test-first.

9. **Pitfalls to avoid:**
   - Calling the muṣḥaf "the Quran" in the absolute, or offering a translation/word-meaning at confirmation (breaks R2 — the single hardest rule here).
   - Writing the preference in the View, reaching into a global, or calling `DateTime.now()` — the controller's single write path owns it (eng-create-riverpod-store / eng-define-service-boundary).
   - Hardcoding app-wide `Directionality(rtl)` (hides physical-side bugs); using physical `left/right` insets.
   - Rendering any muṣḥaf glyph in the riwāyah step (the pack is unverified/undownloaded — fail-closed, ds R1).
   - Applying UI numerals, UI fonts, or mirroring to the edition name as if it were page text; hard-splicing the mixed-script edition name instead of one isolated ICU message.
   - A "recommended" / "best" badge on a language or edition, confetti/streak on selection, or an exclamation mark.
   - Treating the language pick as anything heavier than a display transform (no re-typeset, no engine touch).

## Acceptance criteria

- [ ] `language_step.dart` and `riwayah_step.dart` exist in `packages/features/lib/src/onboarding/widgets/`, each a dumb View composing E10's `SettingsSinglePicker<T>`; neither writes state directly — both call one E11-T01 controller method.
- [ ] Choosing a language updates the app `Locale` live (the visible chrome re-renders in the chosen language and RTL direction) and writes **only** `locale` into the captured state; no engine state, `due_at`, or stored instant is touched.
- [ ] The riwāyah step shows the row **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"** read from `l10n.*`, stores only `mushafEditionId`, renders **no muṣḥaf glyph**, offers no translation/tafsīr, and contains no string presenting the muṣḥaf as "the Quran" in the absolute (R2).
- [ ] Selected state is the radio glyph + text label (shape AND color), an M3 state layer — never color alone; rows are ≥48dp and ≥`space.2` apart and do not shrink below 48dp under OS text scale.
- [ ] All geometry is logical (`EdgeInsetsDirectional`/`AlignmentDirectional`); the `features/**` physical-side grep is clean; the language preview is the only manual `Directionality` island and renders its sample in the candidate locale's direction.
- [ ] The edition name's mixed-script run is isolated via the `bidi.dart` helper (one `Text`/`TextSpan`, never hard-spliced); any numeral formats via `numberFormatFor(locale)`; the ASCII-digit grep is clean.
- [ ] Every user-facing string resolves through `AppLocalizations` (no literal in `features/**`); keys authored in `app_ar.arb` first and transcreated for fa/ckb/ar; ckb canonical-encoded and flagged provisional; the riwāyah name has cleared the adab/scholar gate (or ships marked provisional, stating no ruling).
- [ ] Each option exposes a `Semantics` name + selected/not-selected value, grouped as a radiogroup (`inMutuallyExclusiveGroup`), with a visible focus ring (`color.outline`); states mirror correctly under RTL.
- [ ] No slider, no free-text, no switch; no "recommended"/"best"/"optimal," no confetti/streak/badge, no exclamation mark anywhere in either step.

## Tests

`packages/features/test/onboarding/language_step_test.dart` and `riwayah_step_test.dart` (`flutter_test`, real bundled UI fonts — never `Ahem`), plus the goldens. Required cases:

**Widget — language step (`language_step_test.dart`):**
- **Routes through the controller / display-transform only**: tapping a language option (fa) invokes the controller's `setLocale` and the captured state's `locale` becomes `fa`; assert **no** engine method, `due_at`, or stored-instant mutation occurred (over a fake controller/clock that records writes) — the only change is the chrome re-rendering.
- **No slider, radiogroup semantics**: `find.byType(Slider)` is empty; each option carries a `Semantics` name + selected value and is `inMutuallyExclusiveGroup`; exactly one is selected.
- **Live re-render**: after selecting ckb, a localized chrome string on the step renders its ckb value (proves the locale transform applied), and direction is RTL.

**Widget — riwāyah step (`riwayah_step_test.dart`):**
- **Edition is named, never absolute**: the visible text contains "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"; assert **no** widget text equals/contains a "the Quran"-absolute phrase; confirming writes `mushafEditionId == 'hafs_madani15'` and nothing else.
- **No glyph, no tafsīr**: the step renders no muṣḥaf glyph/page widget and offers no translation/transliteration affordance.
- **Bidi isolation present**: the edition-name run is wrapped by the isolation helper (assert the isolate controls are present around the mixed-script run, not raw concatenation).

**Goldens (per locale):** `test/onboarding/goldens/language_step_{ar,fa,ckb}.png` and `riwayah_step_{ar,fa,ckb}.png` — rendered on the real bundled fonts (Sorani extra letters پ چ ژ گ ڤ ڕ ڵ ۆ ێ ە and Persian/Arabic digits actually exercised), proving RTL geometry (start/end), the named edition, and ckb wrapping rather than truncating.

**Offline / no-network guard:** an `HttpOverrides`-throwing harness wraps both step tests — neither the language pick nor the riwāyah confirmation opens any socket (the one permitted download is E11-T04's, which comes after this step). Asserts the radio stays off.

## Definition of Done

- [ ] All acceptance criteria met; widget + per-locale golden tests green locally and in CI across the offline / l10n / a11y gates.
- [ ] **Offline / no-network (non-negotiable):** neither step touches the network or any model; the `HttpOverrides`-throwing test proves no socket opens; no analytics/telemetry on the chosen language or edition.
- [ ] **No AI / no microphone (non-negotiable):** the steps capture two named choices only — no inference, no "recommended for you," no microphone, no audio.
- [ ] **Quran text fidelity (non-negotiable, R1/R2):** no muṣḥaf glyph is rendered before the pack is downloaded and verified; the riwāyah is **named** ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"), **never** "the Quran" in the absolute; the picker stores a named edition and re-typesets/mirrors/translates **nothing** in the glyph layer.
- [ ] **Display transform, never a mutation:** the language pick re-renders chrome only; the riwāyah confirmation stores an edition name only; no engine state, `due_at`, or stored instant is touched; the View writes no state (the E11-T01 controller's single write path does).
- [ ] **RTL + fa/ckb/ar localization:** every string ships ar (template) + fa + ckb transcreated through `gen_l10n` (no hardcoded text); ckb is canonical-encoded and flagged provisional; the edition name's mixed-script run is FSI/PDI-isolated; geometry reads start→end (right→left); the l10n completeness + RTL-golden gate is green.
- [ ] **Accessibility:** each option is `Semantics`-labelled with its state, grouped as a radiogroup, with a visible focus ring; hit targets ≥48dp; selected = color + shape + label (readable in grayscale/deuteranope); the per-screen audit gate passes.
- [ ] **Sect-neutral adab:** the confirmation names the edition as a fact and issues no ruling about which riwāyah is correct; no tafsīr/translation offered; no streak/badge/confetti/score; no "recommended"/"best"; no exclamation marks; every string has passed the adab gate.
- [ ] **Deterministic tests:** fixtures are explicit (fixed locale, fake controller/clock recording writes); no hidden clock, no network, real bundled fonts in goldens; the suite is reproducible in CI.
