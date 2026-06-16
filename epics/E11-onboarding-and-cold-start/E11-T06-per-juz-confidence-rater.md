# E11-T06 — Per-juz Solid/Shaky/Rusty confidence rater (self-report words, passes JuzConfidence, no D/S/R surfaced)

| | |
|---|---|
| **Epic** | [E11 — Onboarding & Cold-Start](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E11-T05 |
| **Skills** | ui-cold-start-placement, domain-scheduling-engine-rules, eng-add-localized-string |

## Goal

A `ConfidenceStep` view inside the onboarding feature module presents — for each juz the user marked **held** in E11-T05's coverage grid — a single mutually-exclusive **Solid / Shaky / Rusty** pick, worded as honest transcreated self-report (never praise, never a score). Each choice is captured into the onboarding controller's `JuzConfidence` map and is the value E11-T09 later passes verbatim to the engine's `coldStartCard`. This task owns only the *capture surface*: it renders the three-way pick per held juz, stores the chosen `JuzConfidence`, and is structurally forbidden from inventing or showing any `(D, S)` seed, any seeded `D`/`S`/`R`, or a "you're N% ready" verdict. The engine owns the `_coldStartSeed` table; the UI never hardcodes it and never reads it back.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §7.10 step 2 | The exact three confidence labels and that they *seed* `(D, S)` — Solid → D3/S60 (FAR), Shaky → D5/S14 (NEAR), Rusty → D7/S4 (active). This task captures the label; it never writes the seed. The §7.10 step-4 conservative-bias clause is why no readiness number ever shows |
| `docs/PRD.md` §12.1 | The confidence rater's slot in the onboarding sequence — after coverage capture (E11-T05), before the optional "when memorized" (E11-T07); "Per-juz confidence (Solid/Shaky/Rusty)" is named here as one screen, not a per-page grind |
| `docs/PRD.md` R3, R6, §7.12 | R3 (no fear/shame — a confidence pick is never a verdict on the user's hifz) · R6 (servant to the teacher — placement is the user's own report a teacher can later correct) · §7.12 (the engine never implies a page is "safe to drop"; the UI never anticipates that here) |
| `docs/engineering/06-scheduling-engine.md` §5 | The **owning** signature and table: `Card coldStartCard(int pageId, JuzConfidence c, SerialDay today, {SerialDay? memorizedOn})` and `_coldStartSeed = {solid:(3,60), shaky:(5,14), rusty:(7,4)}`. `JuzConfidence` is an **engine enum** in `packages/engine`; this task imports and passes it, and **never** re-declares the enum or the `(D, S)` values |
| `docs/design-system/11-voice-and-tone.md` §2 | The four fixed voice attributes — reverent, calm, plain-and-warm, **honest** — bind the three labels: they are honest self-description ("I hold this firmly / it wobbles / it's gone rusty"), never praise ("Great!"), never a score, never an exclamation |
| `docs/design-system/01-design-principles.md` §2 (Calm, not cute) | **Diagnose, don't score**: the rater captures honest self-report, it does not grade; no badge/points/celebration when every juz is rated; reaching the end is a calm informational hand-off, not a prize |
| `docs/design-system/01-design-principles.md` §4 (Honest about decay) | "Rusty" is honest, not alarming — the Rusty option is calm, never alarm-red / "you failed"; state is carried by color **and** text label, never color alone (SC 1.4.1) |
| `docs/science/CLAIMS.md` C-009 | The conservative-cold-start license behind the no-readiness-% rule: "reviewing too early costs minutes; too late can lose it — so we err early," so priors under-estimate and the UI shows the bias only as behavior, never a precise score. The only claim this step leans on |
| Skill `ui-cold-start-placement` (+ `template.dart`) | Pattern 3 (the three-way pick is `SegmentedButton`/large `FilledButton`s, single-selection, ≥56dp tall, `space.2` apart, color **+** text label), pattern 4 (pass `JuzConfidence` to `coldStartCard`; never invent `(D, S)` in the View), pattern 5 (never show seeded `D`/`S`/`R` or a readiness %), pattern 9 (each option announces word **and** meaning), pattern 10 (no shame, no verdict on the user's hifz) |
| Skill `domain-scheduling-engine-rules` | Rule 15 + the checklist line: the `_coldStartSeed` table and `coldStartCard` are the engine's, golden-tested and pure; the UI may not hardcode the seeds or compute stability. Confirms `JuzConfidence` is the engine-owned enum this task hands across the boundary |
| Skill `eng-add-localized-string` (+ `template.md`) | The three labels + their meaning-hints land in `app_ar.arb` (ar template) first, then transcreated `fa`/`ckb` (ckb canonical-encoded, flagged provisional); these are **register-sensitive term-set strings** needing native + scholar review; the juz number in each per-juz heading is `numberFormatFor(locale)`-formatted in an ICU placeholder, FSI/PDI-isolated; no literal in the widget; adab gate first; no exclamation marks |
| Sibling E11-T01 | Supplies the onboarding module anatomy (`onboarding_screen.dart` View ↔ `onboarding_view_model.dart` ↔ `widgets/` ↔ `onboarding_providers.dart`) and the resume-safe controller that already holds the `JuzConfidence` map slot; this task plugs in one step view and writes into that slot |
| Sibling E11-T05 | The dependency: its coverage grid produces the **held-juz set** this step iterates; this rater shows a row only for a held juz, in the same muṣḥaf/RTL order, and an un-held juz never appears here |
| Sibling E11-T07 | Consumes the same captured set — the optional "when memorized" date is offered per held juz *after* confidence; this task's `JuzConfidence` map and T07's `memorizedOn` map are the two inputs E11-T09 pairs |
| Sibling E11-T09 | The placement commit that actually calls `coldStartCard(pageId, confidence, today, memorizedOn:…)` per held page inside `seedColdStart`; this task only *captures* the `JuzConfidence` — it performs **no** seeding and **no** persistence |
| Sibling E11-T10 | Owns the final ar/fa/ckb transcreation lock, the `Semantics`/RTL pass, and the per-locale goldens + offline `HttpOverrides` guard across all steps; this task ships its keys and a first golden, T10 consolidates |

## Implementation notes

The correctness-critical part is the **boundary discipline**: the View passes a captured `JuzConfidence` and never reads a seed back — a test must prove no `D`/`S`/`R`/percentage string can render. Write that "no-leak" test alongside the widget.

1. **File**: `packages/features/lib/src/onboarding/widgets/confidence_step.dart` — a dumb `ConsumerWidget` leaf under the onboarding module (T01's anatomy). It reads the held-juz set and the current `JuzConfidence` map from the onboarding controller (`onboarding_view_model.dart` / `onboarding_providers.dart`) and renders one rater row per held juz. The View **writes nothing persisted** — it calls a controller method (`setJuzConfidence(juzIndex, JuzConfidence)`) that updates only the in-memory captured state; the durable `seedColdStart` write is E11-T09's.
2. **The enum is the engine's, imported not re-declared.** Use `JuzConfidence { solid, shaky, rusty }` from `package:engine` (the `coldStartCard` parameter type, `engineering/06 §5`). Do **not** define a parallel UI enum, and do **not** put the `(D, S)` seed numbers anywhere in `features/` — the View holds `JuzConfidence` values only and hands them across unchanged.
3. **The control** (per `ui-cold-start-placement` pattern 3): for each held juz, a single mutually-exclusive pick — an M3 `SegmentedButton<JuzConfidence>` (single-selection) or a row of three large `FilledButton`s — at ≥56dp tall, `space.2` apart, in the thumb zone, mirroring the recite-flow grade band's sizing. Each option pairs a **color family with its text label** (never color alone): a calm strong tone for Solid, a mid tone for Shaky, a muted/faded tone for Rusty — **never alarm-red on Rusty**. Selection is required to advance a row's juz but the step never blocks with a scolding empty-state.
4. **Copy is honest self-report, transcreated** (per `eng-add-localized-string` + voice §2): the three labels read as the user's own description of what they hold ("I hold this firmly" / "it wobbles" / "it's gone rusty"), localized as a **regional term-set** (ICU `select`/region-override is overkill for three fixed words — author them as three keys with a clear `@description` marking "needs native + scholar review"), never literal-translated, never praise, never a number. The per-juz heading "Juz {n}" formats `{n}` via `numberFormatFor(locale)` (Extended Arabic-Indic fa/ckb, Arabic-Indic ar) and FSI/PDI-isolates the numeral run.
5. **No seed, no readiness, ever** (pattern 5; C-009): the step never shows a seeded `D`/`S`/`R`, an interval, a "you're 87% ready" score, a per-juz "strength," or a running completion percentage of juz rated. The conservative bias is surfaced — if at all — only as plain behavior copy at the step's foot ("we'll start by revising everything you hold once, and adjust as you recite"), which traces to **C-009**; there is no number in it.
6. **No clock, no seeding here.** This step captures `JuzConfidence` only; it does **not** read `today`, does **not** call `coldStartCard`, and does **not** persist. `DateTime.now()` appears nowhere; the injected `today` and the seeding both belong to E11-T09. Resist the pull to "seed as we go" — a mid-flow kill must leave only in-memory captured state, never a half-seeded card (the §7.12 / single-write-path covenant the epic protects).
7. **RTL / calm styling**: the step renders inside the app's `Directionality.rtl`; rows read start→end; logical `EdgeInsetsDirectional` insets only; the juz rows follow the same muṣḥaf order as E11-T05 (juz 1 at the start/right). `type.body` for the labels, calm token tones for the three options; no streak, no progress flourish.
8. **Pitfalls to avoid**:
   - Re-declaring `JuzConfidence` or putting `D=3`/`S=60`/etc. anywhere in `features/` (the seed table is the engine's — a grep for those literals in `features/` should find nothing).
   - Calling `coldStartCard`, reading a seeded `Card`, or surfacing any `D`/`S`/`R`, interval, or readiness/completion percentage (pattern 5; the no-leak test must fail loudly if one appears).
   - Allowing multi-select, tiny (<56dp) targets, or a free-form slider that fakes precision (pattern 3 anti-pattern).
   - Wording an option as praise ("Excellent!"), a score, an exclamation, or a literal translation that drifts the register (voice §2; the adab gate).
   - Alarm-red on Rusty, or any "missing"/"failed"/"0%" framing — Rusty is honest, calm, color **plus** label (principle §4; SC 1.4.1).
   - Persisting from the View, reading `today`/`DateTime.now()`, or seeding as you go (the single-write-path + §7.12 covenant — seeding is E11-T09).
   - Splicing ASCII digits into "Juz N" instead of the `numberFormatFor(locale)` placeholder.

## Acceptance criteria

- [ ] `confidence_step.dart` exists under `packages/features/lib/src/onboarding/widgets/`, is a dumb `ConsumerWidget`, imports `JuzConfidence` from `package:engine`, and **re-declares no confidence enum** and contains **no** `(D, S)` seed literal (`3`/`60`/`5`/`14`/`7`/`4` as a seed) — verifiable by grep over the file.
- [ ] The step renders exactly one rater row per **held** juz (from E11-T05's coverage set), in muṣḥaf/RTL order; an un-held juz never appears.
- [ ] Each row is a single mutually-exclusive Solid/Shaky/Rusty pick (`SegmentedButton`/large `FilledButton`s), ≥56dp tall, `space.2` apart, each option pairing a color family **with** its text label (never color alone); Rusty is calm, never alarm-red.
- [ ] Selecting an option calls the controller's `setJuzConfidence(juzIndex, JuzConfidence)`, which updates only the in-memory captured `JuzConfidence` map; the View persists nothing and calls no engine seeding.
- [ ] No seeded `D`/`S`/`R`, no interval, no "readiness %", no "you're N% ready", and no running completion percentage appears on the surface (verifiable by the no-leak string sweep).
- [ ] The three labels and their meaning-hints resolve through `AppLocalizations` (`l10n.onboardingConfidence*`); keys exist in `app_ar.arb` (ar template) + `fa` + `ckb` (ckb flagged provisional, term-set marked "needs native + scholar review"); the "Juz {n}" heading renders the locale numeral set via `numberFormatFor(locale)`; no exclamation marks; copy passes the adab gate.
- [ ] The step reads no clock and contains no `DateTime.now()`; it captures `JuzConfidence` only and performs no `coldStartCard` call and no persistence.

## Tests

`packages/features/test/onboarding/confidence_step_test.dart` (widget) and `packages/features/test/onboarding/confidence_step_golden_test.dart` (per-locale golden), `flutter_test`, deterministic, real bundled fonts (never `Ahem`). The onboarding controller is overridden with a fake exposing a scripted held-juz set and recording `setJuzConfidence` calls; no real network, no real DB, no clock. Required cases:

- **Held-only rows**: given a held-juz set, the step shows one row per held juz and none for un-held juz; rows are in muṣḥaf/RTL order matching E11-T05.
- **Single-select capture**: tapping Solid/Shaky/Rusty on a row records exactly that `JuzConfidence` for that juz via `setJuzConfidence`; tapping a second option replaces (mutually exclusive), never accumulates.
- **No-leak (correctness-critical)**: a string + render sweep over every row and option asserts no `D`/`S`/`R` token, no FSRS number, no interval, and no `%`/"ready"/completion string renders in any locale; assert `features/` holds no `coldStartCard` call and no seed literal.
- **Engine enum, not a copy**: the value handed to `setJuzConfidence` is `package:engine`'s `JuzConfidence` (type-level assert), proving no parallel UI enum bridges the boundary.
- **Calm Rusty**: the Rusty option uses a muted/faded token, never `color.*` alarm-red; each option carries both a color and a text label (color-independence check).
- **No clock / no persist**: pumping the step and selecting confidences calls no persistence method on the fake and reads no clock; `DateTime.now()` appears nowhere in the file.
- **Numerals**: the "Juz N" headings render in the locale numeral set (Extended Arabic-Indic fa/ckb, Arabic-Indic ar), not ASCII digits, FSI/PDI-isolated.
- **No exclamation / no praise / no score**: a sweep asserts no `!`, no praise token, and no score word in any locale's labels.
- **Accessibility**: each option announces its word **and** meaning (e.g. "Shaky — needs regular revision") via `Semantics`, carries the selected/toggle flag, and shows a visible focus ring; hit targets ≥48dp (`labeledTapTargetGuideline` / `androidTapTargetGuideline`); a deuteranope/grayscale check passes.
- **Offline guard**: the suite runs under an `HttpOverrides` that throws on any socket — proving this step opens none — and fails loudly if a socket is touched.
- **Per-locale goldens** (fa/ckb/ar, real bundled fonts): a few held-juz rows with one option selected, RTL, calm tokens, locale numerals; ckb wraps rather than truncates.

## Definition of Done

- [ ] All acceptance criteria met; widget + golden suites green locally and in CI across the offline / l10n / a11y gates.
- [ ] **Offline / no-network (non-negotiable):** the step opens no socket; the `HttpOverrides`-throwing test proves the radio stays off through the rater.
- [ ] **No AI / no audio (non-negotiable):** the step captures a self-report tap only — no microphone, no ASR, no model, no inference anywhere in the path (C2, R5).
- [ ] **Text fidelity (non-negotiable):** the rater renders **no muṣḥaf glyph** (it shows only chrome — labels and juz numbers); it sits behind E11-T04's verified-pack advance-guard, so it never reaches Quran text before `text_checksum_verified_at` is stamped (R1).
- [ ] **Conservative seeding holds (non-negotiable):** the UI **never** invents `(D, S)`, never shows a seeded `D`/`S`/`R`, and never shows a "you're N% ready" verdict; it passes `JuzConfidence` only and lets `coldStartCard` (E11-T09) own the seed table; the conservative bias appears only as behavior copy traced to **C-009** (`engineering/06 §5`; PRD §7.10).
- [ ] **Single write path:** the View writes no rows and seeds no cards; it updates only the in-memory captured `JuzConfidence` map; a mid-flow kill leaves no half-seeded state (seeding + the `seedColdStart` transaction are E11-T09).
- [ ] **RTL + fa/ckb/ar localization:** every label + hint ships ar (template) + fa + ckb transcreated through `gen_l10n` (no hardcoded text); the term-set is marked "needs native + scholar review"; juz numbers render in the locale numeral set; mixed runs FSI/PDI-isolated; rows read start→end (right→left); ckb wraps; the l10n completeness + RTL-golden gate is green.
- [ ] **Accessibility:** each option is `Semantics`-labelled with its word **and** meaning ("Shaky — needs regular revision"), carries the selected/toggle flag and a visible focus ring; hit targets ≥56dp (≥48dp `touch.min` floor); redundant color+label; readable in grayscale/deuteranope; the per-screen audit gate passes (final consolidation in E11-T10).
- [ ] **Sect-neutral adab / no shame:** the three labels are honest self-report, never praise, a score, or a verdict on the user's hifz; Rusty is calm, never alarm-red / "missing" / "0%"; no streak/badge/completion-trophy; no exclamation marks; nothing speaks *for* the Quran or overrides a future teacher sign-off (R3, R6, §7.12); every string passes the adab gate.
- [ ] **Deterministic tests:** the suite uses a fake onboarding controller with a scripted held-juz set, real bundled fonts, no hidden clock and no real network; the no-leak (no `D`/`S`/`R`/%) case was written alongside the widget.
