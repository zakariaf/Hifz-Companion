---
name: ui-cycle-preset-picker
description: Build or modify the Hifz Companion named-cycle / preset selector for the Hifz app — the choice between 7-Manzil weekly khatm, 1 juz/day, ½ juz/day, 2 juz/day, Custom, and the Pure-cycle mode toggle. Use whenever building the cycle/preset selection, the manzil-cycle settings, the named-tradition picker, or anything that sets the engine's cycle ceiling. This control is a named choice a teacher recognizes — NEVER a "retention slider" or a target-R dial.
---

# ui-cycle-preset-picker

The named-cycle selector: how a ḥāfiẓ chooses the *shape of their revision day* by **name** — "7-Manzil weekly khatm," "1 juz / day," "½ juz / day," "2 juz / day," "Custom," and the "Pure-cycle" conservatism toggle — and nothing more. The chosen preset writes the engine's **cycle ceiling** (`EngineConfig.farCycleDays` / `pureCycleMode`), which is the hard floor behind the trust clamp's covenant that *no page drifts past its cycle*. The picker surfaces the tradition; it never exposes the FSRS math underneath.

This control IS the visible face of Pillar 3 (*tradition is the interface*). The user picks a cycle a teacher already runs on paper; the spaced-repetition engine is demoted to a silent page-selector inside whatever shape they choose. A picker that offers a target-retention slider, an FSRS difficulty/stability number, or a generic "due cards / day" dial is the wrong component.

## When to use

Use when building or placing:
- the cycle / preset selection screen (the named-tradition picker)
- the manzil-cycle settings row in Settings
- the **Pure-cycle mode** toggle (§7.11 — fixed-rotation, SR-assist off)
- the Custom-cycle editor (far-cycle length, near-window juz, new-lines/day, daily budget)
- the cold-start step where onboarding first picks a default cycle
- any control whose only job is to set `EngineConfig.farCycleDays` / `nearCeilingDays` / `newLinesPerDay` / `dailyBudget` / `pureCycleMode`

Do NOT use this skill for:
- the finite, capped daily session list (Far→Near→New) the cycle *produces* → use **ui-daily-session-list**
- one page card row, its track chip, or its decay indicator → use **ui-page-card**
- the reveal-on-tap recite + four-level grade flow → use **ui-recite-grade-flow**
- the muṣḥaf / riwāyah selector or the muṣḥaf reader itself → use **ui-mushaf-page-view**
- writing the `EngineConfig` value type or the trust-clamp / `cycleCeilingDays` math → use **domain-scheduling-engine-rules**
- the Riverpod store + single-write-path mutation that persists the chosen preset → use **eng-create-riverpod-store**
- adding the preset's localized term-set strings → use **eng-add-localized-string**

The picker *names* the cycle and persists the choice; the engine *enforces* it. A picker that computes a `due_at`, reorders pages, or shows a retention percentage is doing the engine's job and breaking Pillar 3.

## The canonical pattern

1. **Named choices, never a slider.** Render the presets as a single-select list of **named cards** — "7-Manzil weekly khatm," "1 juz / day," "½ juz / day," "2 juz / day," "Custom" — built on the M3 single-select pattern (`RadioListTile` / selectable `Card`, or a `SegmentedButton` where the set is short), display-only chrome with no numeric dial anywhere. This is `docs/design-system/01-design-principles.md` §3 (*Named cycles, never a retention slider*; the `target_R` dial is internal and never user-facing) and `docs/PRD.md` §15.1 ("Offered as named choices (not sliders)"). The exact preset set is `docs/PRD.md` §15.1.

2. **The preset sets the cycle ceiling — that is its entire effect.** Selecting a preset writes the engine config that the trust clamp reads: a weekly khatm → `farCycleDays = 7`, 1 juz/day → `30`, ½ juz/day → `60`, 2 juz/day → `15`. The picker never touches `due_at`, never reorders, never sets `target_R`. `docs/engineering/06-scheduling-engine.md` §6 (`cycleCeilingDays(card, EngineConfig)` reads `farCycleDays` / `nearCeilingDays`; `due = min(SR-ideal, ceiling)`) and `docs/PRD.md` §7.6 (the trust clamp), §15.1 (the preset → cycle mapping).

3. **Pure-cycle mode is one explicit flag, framed as fidelity not "off."** The Pure-cycle toggle sets `EngineConfig.pureCycleMode = true` — fixed rotation only, SR ordering off, zero pull-forward — turning the app into a faithful traditional tracker with smart load-balancing + catch-up and nothing more. Frame it for the maximally-traditional user/ʿālim ("follow my cycle exactly, no reordering"), never as "disable smart features." `docs/engineering/06-scheduling-engine.md` §6 (pure-cycle = the conservative limit, a one-flag change) and `docs/PRD.md` §7.11, §15.1.

4. **Custom is a structured editor, not a free-for-all.** "Custom" reveals exactly four named, bounded fields — far-cycle length, near-window size (in juz), new-lines/day, daily budget — each a labelled stepper/select with sane bounds, each mapping 1:1 to an `EngineConfig` field. No raw retention target, no D/S/R, no "advanced math" pane. `docs/PRD.md` §15.1 (the four Custom fields) and `docs/design-system/01-design-principles.md` §3 (the math's target retention is internal, never user-facing).

5. **Persist through the single write path — never mutate engine config in the View.** Selecting a preset routes through one controller/notifier method that persists the new `EngineConfig` transactionally **before** republishing in-memory state and rebuilding the day; the View never writes the config or calls the engine directly. `docs/design-system/07-components.md` §6 (explicit component state model; selection is functional, not a reward) and **eng-create-riverpod-store** (the persist-before-republish single write path). Changing the cycle re-runs `buildToday` deterministically (`docs/engineering/06-scheduling-engine.md` §6–§7) — the picker only stores the choice.

6. **No score, no celebration, no urgency on selection.** Picking or switching a cycle is a quiet, factual change — no confetti, no streak, no badge, no "optimal!" praise, no "you're behind" pressure, and no exclamation marks. A pressed/selected state is an M3 state layer over a role color, never a glow or pop. `docs/design-system/01-design-principles.md` §2 (*Calm, not cute* — no streaks/points/celebration; copy states facts and stops) and `docs/design-system/07-components.md` §6 (state layers, never a reward surface).

7. **RTL-native, term-set localized, locale numerals.** The whole picker is RTL by geometry: labels and the selected-state affordance sit at the **start** (right), chevrons/steppers at the **end**, via `EdgeInsetsDirectional`. Preset and term-set names are **regional term-set strings** (the *manzil / juz* vocabulary differs per region and awaits native + scholarly review) — never hardcoded English; "7-Manzil," "30-day," "1 juz" render their numerals in the locale set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) with mixed runs bidi-isolated. `docs/design-system/01-design-principles.md` §6 (RTL by construction; locale numerals; bidi isolation; localizable terminology) and §3 (localizable *sabaq/sabqi/manzil* term-sets, `docs/PRD.md` §13.4, §15.2); add strings via **eng-add-localized-string**, lay out via **eng-rtl-and-bidi-layout**.

8. **Accessibility: one labelled choice per option, announced as a group.** Each preset is a single ≥48dp `touch.min` selectable row with a `Semantics` label = its name and a selected/not-selected value; the set is a radiogroup; the Pure-cycle toggle announces "Pure-cycle, off"; a visible focus ring (`color.outline`) serves keyboard/switch-control users. `docs/design-system/07-components.md` §6 (visible focus ring per WCAG 2.2 SC 2.4.7; `Semantics` enabled/selected flags; states mirror under RTL) and `docs/PRD.md` §18 (semantic labels per locale, large targets).

9. **Offline / no-AI — the picker stores a choice, it computes nothing.** No network, no model, no "recommended for you" inference; defaults are tuned per region but are plain constants, and switching cycles works in airplane mode forever. `docs/PRD.md` §17 (offline, no telemetry, no per-user inference) and `docs/design-system/01-design-principles.md` §5 (private by feel — no outward-pointing UI on a settings surface).

## Do / Don't

| Do | Don't |
|---|---|
| Offer presets as **named** single-select cards ("7-Manzil weekly khatm," "1 juz / day") | Offer a target-retention slider, a `target_R` dial, or a "due cards / day" number |
| Let the preset write only `EngineConfig` (`farCycleDays`, `nearCeilingDays`, `newLinesPerDay`, `dailyBudget`, `pureCycleMode`) | Let the picker compute `due_at`, reorder pages, or read/show FSRS D/S/R |
| Frame Pure-cycle as fidelity ("follow my cycle exactly, no reordering") | Label it "turn off smart scheduling" or imply the app is now worse |
| Make Custom four bounded, named fields each mapped 1:1 to a config field | Add a raw retention target, an "advanced math" pane, or unbounded inputs |
| Persist via one controller method (persist-then-republish), then let the engine rebuild the day | Mutate `EngineConfig` in the View, or call the engine straight from a tap handler |
| Switch cycles as a quiet factual change; selected = M3 state layer | Fire confetti/streak/badge, praise "optimal!", or pressure "you're behind" |
| Use regional **term-set strings** + locale numerals, RTL by `EdgeInsetsDirectional` | Hardcode English "Manzil/Juz", ASCII digits, or left/right insets |
| `Semantics` name + selected value per row; radiogroup; visible focus ring | Leave options unlabeled, or signal selection by color alone |
| Keep it fully offline — defaults are regional constants | Add "recommended for you" inference, a network call, or any telemetry |

## Checklist

Before this control is done:

- [ ] Presets are **named** single-select cards/segments (7-Manzil weekly khatm · 1 juz/day · ½ juz/day · 2 juz/day · Custom) on the M3 single-select pattern — **no slider, no `target_R` dial, no FSRS number anywhere** (`docs/PRD.md` §15.1; `docs/design-system/01-design-principles.md` §3).
- [ ] Selecting a preset writes **only** `EngineConfig` fields (`farCycleDays` / `nearCeilingDays` / `newLinesPerDay` / `dailyBudget` / `pureCycleMode`); the picker never sets `due_at`, never reorders, never reads D/S/R (`docs/engineering/06-scheduling-engine.md` §6).
- [ ] Pure-cycle mode is one explicit `pureCycleMode` toggle, framed as fidelity ("follow my cycle exactly"), not "disable smart features" (`docs/PRD.md` §7.11; engine §6).
- [ ] Custom reveals exactly four bounded, labelled fields, each mapped 1:1 to an `EngineConfig` field; no raw retention target (`docs/PRD.md` §15.1).
- [ ] The mutation goes through one controller/notifier method that persists transactionally **before** republishing, then the engine rebuilds the day; no View-level config write (**eng-create-riverpod-store**; engine §6–§7).
- [ ] Switching cycles is quiet and factual — no confetti/streak/badge/score, no "optimal!", no "you're behind", no exclamation marks; selected state is an M3 state layer (`docs/design-system/01-design-principles.md` §2; `docs/design-system/07-components.md` §6).
- [ ] RTL by `EdgeInsetsDirectional`; preset/term-set names are localized **term-set strings** (fa/ckb/ar, scholarly-review-pending), never hardcoded English; numerals render in the locale set with mixed runs bidi-isolated (`docs/design-system/01-design-principles.md` §6, §3; **eng-add-localized-string**, **eng-rtl-and-bidi-layout**).
- [ ] Each option is a ≥48dp `touch.min` row with a `Semantics` name + selected value, grouped as a radiogroup, with a visible focus ring (`color.outline`) per WCAG 2.2 SC 2.4.7 (`docs/design-system/07-components.md` §6; `docs/PRD.md` §18).
- [ ] Fully offline / no-AI: no network, no model, no "recommended for you"; defaults are regional constants; works in airplane mode (`docs/PRD.md` §17; `docs/design-system/01-design-principles.md` §5).
- [ ] Tests: a widget test for selection + RTL goldens per locale (fa/ckb/ar); the engine-config write asserts the cycle → `farCycleDays` mapping and that pure-cycle flips exactly one flag (**eng-write-dart-test**; the clamp invariant itself is golden-tested under **domain-scheduling-engine-rules**).

This control sets the *cycle ceiling* — the product's covenant that nothing decays silently. Because the ceiling guarantees coverage (engine §6), the picker must never offer a path that lengthens a cycle toward "never," retires a page, or implies a juz is "safe to stop revising." If a copy string ever frames a longer cycle as "you can relax on this," it is wrong — run it past **domain-adab-and-religious-integrity**.

## Files

- `template.dart` — copy-paste starting point: the domain-blind `CyclePresetPicker` (named single-select + Pure-cycle toggle + Custom editor reveal, taking primitives + a selection callback), the feature-layer wiring that maps the chosen preset → `EngineConfig` and persists it through the controller's single write path, and the `Semantics`/RTL scaffolding. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-scheduling-engine-rules** (the `EngineConfig`, `cycleCeilingDays`, and trust-clamp math this picker feeds), **eng-create-riverpod-store** (the single-write-path method that persists the chosen preset), **eng-add-localized-string** (the preset / term-set strings), **eng-rtl-and-bidi-layout** (RTL geometry + locale numerals + bidi isolation), **ui-daily-session-list** (the capped day the cycle produces), **ui-page-card** (the row the day is built from), **domain-adab-and-religious-integrity** (the conscience-check on any cycle copy).
