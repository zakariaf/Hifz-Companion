# references — ui-cycle-preset-picker

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. The cycle-preset picker is a **named choice** that sets the engine's cycle ceiling — it surfaces the tradition and never exposes (or computes) the FSRS math underneath.

## Primary

- `docs/PRD.md` §15.1 (Cycle presets — named, tradition-shaped) — **The canonical preset set and the iron rule:** presets are "Offered as named choices (not sliders)" — **7-Manzil weekly khatm** (full Quran every 7 days), **1 juz / day** (30-day), **½ juz / day** (60-day), **2 juz / day** (15-day), **Custom** (far-cycle length, near-window in juz, new-lines/day, daily budget), and a **Pure-cycle mode** toggle. Defaults are tuned per region but editable. This is the whole menu the picker renders.

- `docs/design-system/01-design-principles.md` §3 (Tradition is the interface) — **Why it is named, not numeric:** the visible surface is the workflow a teacher recognizes — *sabaq/sabqi/manzil* in **named cycles** ("7-Manzil weekly khatm," "1 juz/day"), "**never a `target_R` dial**"; the math's target retention is internal and never user-facing. The scheduler is demoted to a silent page-selector that may only *order* and *pull forward* inside the chosen shape. Terminology is regional/swappable, never hardcoded. Anti-patterns: a retention slider, an FSRS difficulty/stability number, or algorithm jargon as the control surface.

- `docs/engineering/06-scheduling-engine.md` §6 (The trust clamp — the whole engine in one rule) — **What the preset actually does:** the chosen named cycle defines `cycleCeilingDays(card, EngineConfig)` — `farCycleDays` for FAR/pure-cycle, `nearCeilingDays` for NEAR — and the clamp takes `due = min(SR-ideal, ceiling)` so SR may only make a page *more* frequent. The preset writes `EngineConfig` and nothing else; **Pure-cycle mode is the conservative limit, a one-flag change** (`pureCycleMode = true` → fixed rotation, zero pull-forward). The clamp/ceiling is pure, deterministic, and golden-tested — the picker stores the choice, the engine enforces it.

## Supporting

- `docs/PRD.md` §7.6 (The trust clamp — the whole design in one rule) — **The covenant the preset upholds:** `card.due_at = min(ideal_due, ceiling_due)` guarantees every page is re-recited at least once per chosen cycle, no matter what the math says — "the algorithm's only freedom is to pull a weak page forward." The cycle ceiling, set by this picker, is "nothing decays silently" in code.

- `docs/PRD.md` §7.11 (Pure-cycle / "conservative" mode) — **The Pure-cycle toggle, exactly:** for maximally traditional users/ulama who distrust any reordering, a setting runs **fixed-rotation only** (SR ordering off, zero pull-forward) — a faithful tracker with smart load-balancing and catch-up, nothing more; SR-assist becomes opt-in. Frame it as fidelity, not "off."

- `docs/design-system/01-design-principles.md` §2 (Calm, not cute) — **No celebration on selection:** no streaks, badges, points, confetti, or manufactured urgency; "copy states facts and stops" with no exclamation marks. Switching a cycle is a quiet factual change, never an "optimal!" reward or a "you're behind" pressure.

- `docs/design-system/01-design-principles.md` §6 (RTL-native & multilingual) — **RTL + numerals + term-sets:** RTL by construction with logical (start/end) insets only; locale numerals (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) via `intl`; mixed Latin/number runs bidi-isolated (FSI/PDI) so "7-Manzil / Juz 7" never flips its sentence; the *sabaq/sabqi/manzil* vocabulary lives in swappable per-locale term-sets, never hardcoded.

- `docs/design-system/07-components.md` §6 (Grade band & component states) — **The selection state model:** explicit M3 interaction states drawn as **state layers** over a role color (never ad-hoc opacity), a **visible focus ring** (`color.outline`, WCAG 2.2 SC 2.4.7) for keyboard/switch-control, states mirrored correctly under RTL and announced via `Semantics` enabled/selected flags. A selected/pressed state is functional and quiet — never a reward surface.

- `docs/PRD.md` §15.2 / §15.3 (Terminology & display; Profiles) — **Where the picker lives and per-profile scope:** the cycle preset sits in Settings alongside the term-set selector, calendar, numeral system, muṣḥaf selector; cycle config is per-profile (local multi-user, no cloud), so switching profiles switches the active cycle. §13.4 governs the regional term-set the labels resolve through.

- `docs/PRD.md` §17 / §18 (Privacy & Security; Accessibility) — **Offline + a11y floor:** no network/telemetry/inference — the picker stores a choice and computes nothing, working in airplane mode; full RTL correctness, large targets, semantic labels per locale, never color alone.

## Sibling skills

- **domain-scheduling-engine-rules** — owns `EngineConfig`, `cycleCeilingDays`, the trust clamp `due = min(SR-ideal, ceiling)`, pure-cycle, and the golden vectors; this picker only *feeds* it the chosen cycle.
- **eng-create-riverpod-store** — the long-lived notifier + single write path (persist `EngineConfig` transactionally before republishing) the picker's selection routes through.
- **eng-add-localized-string** — adds the preset names and *manzil/juz* term-set strings to the ARB files (fa/ckb/ar), scholarly-review-pending.
- **eng-rtl-and-bidi-layout** — RTL geometry (`EdgeInsetsDirectional`), locale numerals, and FSI/PDI isolation for the mixed-run labels.
- **ui-daily-session-list** — the finite, capped Far→Near→New day the chosen cycle produces.
- **ui-page-card** — the page-card row (track chip + decay indicator) the day is built from.
- **eng-write-dart-test** — the widget/RTL-golden tests for the picker and the cycle→`farCycleDays` mapping assertion.
- **domain-adab-and-religious-integrity** — the conscience-check any cycle/preset copy must pass (no "safe to relax," no shame, no gamification).
