# E21-T03 — The sabaq intake pace + a real "pause new sabaq" (F11)

| | |
|---|---|
| **Epic** | [E21 — New-Memorization (Sabaq) Loop & Beginner Path](EPIC.md) |
| **Size** | S–M |
| **Depends on** | E21-T01 (supersedes its `EngineConfig.newLinesPerDay` field), E16 (`CycleConfig`, `CycleConfigWriter`) |
| **Skills** | domain-scheduling-engine-rules, eng-persist-on-every-change, eng-write-dart-test |

## Goal

Make the two dead F11 controls — the "new lines per day" pace and "pause new sabaq" — actually mean something, and correct where the pace lives. Deeper analysis of the page-granular design (E21) shows the pace is an **intake** concern, not an engine scheduling input: the engine's New band is the *consolidating* pages (already memorized, still strengthening), which the time budget already bounds — a pace cap on that band would **starve consolidation** (a beginner with 10 consolidating pages must revise all 10 daily, not 1). So this task (1) **removes** the `EngineConfig.newLinesPerDay` field E21-T01 added (it had no correct engine consumer and would recreate the very F11 dead-control anti-pattern), (2) adds a pure `sabaqIntakeActive(CycleConfig)` signal the intake surfaces gate on (`newLinesPerDay > 0` ⇒ active; `0` ⇒ paused/off), and (3) adds `CycleConfigWriter.pauseNewSabaq()` — a one-write pause that sets the pace to 0 (reusing the persisted field, **no schema migration**), framed as protecting what is earned. The UI that *consumes* this (the "start a new lesson" surface's visibility, and the Today pause button) lands with the surfaces in **E21-T06/T07**.

## Context & references

| Reference | What to take from it |
|---|---|
| `packages/engine/lib/src/build_today.dart:152-158`, `load_balance.dart:74-81` | The New band = *consolidating* pages, bounded by the **time budget** ("NEW only while budget remains") — proof a pace cap here would starve consolidation, so the pace is not an engine input |
| `docs/PRD.md` §7.8, §15.1 | `new_lines/day` is a Custom-cycle field and a *pace*; page-granular intake (E21) is user-driven, so it gates the intake surface, not the schedule |
| `docs/audits/2026-07-10-full-app-audit.md` F11 | The dead controls: `newLinesPerDay` "persists values nothing reads" and "pause new sabaq pauses nothing" — this task makes both live |
| `packages/features/lib/src/settings/cycle_config_writer.dart` | The persist-before-republish writer to extend with `pauseNewSabaq()` (reusing `mutateActiveConfig`) — no new persistence, no migration |

## Implementation notes

1. **Engine correction** — remove `EngineConfig.newLinesPerDay` (field, ctor param, assert) and its test file; update the class doc to state *why* there is no pace field (the New band is consolidation, bounded by the budget).
2. **`packages/features/lib/src/sabaq/sabaq_pace.dart`** — `bool sabaqIntakeActive(CycleConfig)` = `config.newLinesPerDay > 0`, documented as an intake signal (not an engine cap), with the "no shown number" note. Export `sabaqIntakeActive` from the features barrel.
3. **`CycleConfigWriter.pauseNewSabaq()`** — `mutateActiveConfig((c) => c.copyWith(newLinesPerDay: 0))`; touches only the pace, moves no `due_at`, drops no page.
4. **Pitfalls:** capping the engine's New band by the pace (starves consolidation); a schema migration for a "paused" boolean (the pace-0 reuse avoids it); showing a recommended pace number (no CLAIMS row); wiring the Today/reader UI here (that is T06/T07).

## Acceptance criteria

- [ ] `EngineConfig` no longer carries a new-lines/day field; the full engine golden-vector + invariant suite stays green (the removal perturbs nothing).
- [ ] `sabaqIntakeActive(config)` is `false` at pace 0 (the opt-in default) and `true` for any positive pace; it is pure (no engine/clock/I/O) and exported from `package:features`.
- [ ] `CycleConfigWriter.pauseNewSabaq()` persists `newLinesPerDay = 0` through the single write path and changes nothing else on the config.

## Tests

- `packages/features/test/sabaq/sabaq_pace_test.dart`: 0 → inactive; 1/5/40 → active.
- `packages/features/test/settings/cycle_config_writer_test.dart` (extended): `pauseNewSabaq` sets the pace to 0 and restoring the pace yields the pre-pause config (nothing else moved).

## Definition of Done

- [ ] All acceptance criteria met; engine + features analyze clean; the engine suite and the two feature suites pass.
- [ ] **Never "safe to drop":** pausing new sabaq changes only the intake pace — it moves no `due_at`, drops no manzil, and implies nothing is safe to stop revising (framed as protection, not failure).
- [ ] **No dead controls:** `newLinesPerDay` now gates a real signal (`sabaqIntakeActive`, consumed by T06/T07) and "pause" is a real one-write action — the F11 anti-pattern is closed, not relocated into `EngineConfig`.
- [ ] **Offline / pure / persist-before-republish:** the pace helper is pure; the pause write goes through the transactional cycle-config writer; no socket, no clock.
- [ ] **No unsourced number:** the pace ships opt-in at 0 and no recommended figure is shown (no registered CLAIMS row).
