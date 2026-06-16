# E15 — Progress & Heat-map

Replace the inert Progress placeholder tab with the app's central emotional surface: a whole-Quran retention heat-map — the 604-page / 30-juz cluster grid in muṣḥaf order, shaded by a calm single-hue green-receding-to-neutral lightness ramp (never red), with redundant colour+number+label cells, VSUP-style muting of uncertain pages, and a min-leaning juz roll-up — leading the screen over the muṣḥaf-shaped overview rather than a stats table. Behind a tap sit the page-detail sheet (a retrievability range in words, next-due, a short `review_log` history), the weakest-juz list, and a calm upcoming-load forecast. The whole surface renders streamed engine state read-only, offline, no-AI: it informs ("where is my Quran today"), and is never a streak, a score, or a scoreboard.

## Why this epic exists

A ḥāfiẓ carries 600+ pages that decay **invisibly**; the dominant failure is forgetting, and the spiritual weight of losing hifz is heavy (PRD §2). The whole product exists so that *nothing decays silently* (PRD §7.12, Pillar 4), and the Progress heat-map is that promise made into a picture — the PRD names it the app's central screen and its quiet emotional hook, *"keep your Quran green"* (PRD §12.5). A 30-juz grid where a softening page's green visibly **recedes** turns the invisible manzil-decay problem into honest situational awareness the user can act on, exactly what a spreadsheet cannot do: a spreadsheet records the past but cannot *show* the user, in one glance, which juz is about to rot (PRD §2). The forgetting curve is the engine's premise and the heat-map renders each page's slide down its own curve (C-001, C-010).

But this surface is the easiest place in the app to violate the non-negotiables, so it is its own epic rather than a tab thrown into the shell. A grid is one design slip away from a **red failing scoreboard**: saturated red carries learned threat meaning and primes avoidance motivation, which would do exactly the two things the PRD forbids — spike anxiety and frame revision as fear-driven (08-data-visualization §3; PRD R3). The temptation to make the map scary is real because loss-framing boosts short-term effort — and it is precisely the wrong bargain for an app built as *ṣadaqah* whose thesis is peace of mind, not engagement (08-data-visualization §3, §8; C-041, C-044). The roll-up is a second trap: a **mean** over a juz's ~20 pages would let one strong-average juz hide a single rotting page — silently breaking the engine's "never safe to drop" invariant at the chart layer even while the engine honours it — so the aggregate must lean to the weakest link, because one weak page is what fails you in ṣalāh (08-data-visualization §6; PRD §10.3, §7.12; C-019). And because a retrievability value is a *prediction, not a measurement* — much of it seeded from cold-start priors or low-confidence self-ratings (PRD §7.10, §8.1) — rendering a crisp "87%" would be false precision; an uncertain page must *look* uncertain (08-data-visualization §4). This epic ships the surface that makes decay visible **calmly**, honestly, and accessibly (colour is never the sole channel — ~8% of men have red-green CVD; PRD §18), so the heat-map can replace every engagement mechanic the app refuses to build (C-041).

## Scope

### In scope

- A **Progress read model** in the data layer: a `StreamProvider` over a Drift query that computes each memorized page's retrievability `R` and its calm decay band, and the **min-leaning** per-juz roll-up, by calling the pure engine on the live card set on read — the widget never re-derives `R`, `due_at`, or the aggregate (PRD §10.3; engine read via E04).
- The **Progress feature module** (`features/lib/src/progress/`): a dumb `ConsumerWidget` View + 1:1 ViewModel + scoped `progress_providers.dart`, replacing E07's inert Progress placeholder tab, wired into the existing `ShellRoute` bottom-nav entry.
- The **whole-Quran cluster grid**: all 604 pages grouped into the 30 juz, laid out **in muṣḥaf order, start→end under `Directionality.rtl`** as faithful small multiples (one learned juz block × 30), assembling E10's heat-map cell leaf; tiles meet `touch.min` with `space.*` gutters, overview-first.
- The **single-hue green-receding ramp** applied by token name (`color.heatmap.strong → good → fair → weak → faded`, monotonic in luminance, decay end a muted neutral), with each cell **redundantly encoded** — ramp colour + a localized retrievability value + a plain label (+ optional decay texture) — and **VSUP-style muting** of never-recited / self-rating-only pages.
- The **min-leaning juz roll-up tiles** and the **weakest-page badge** at the logical start of a mostly-strong juz that holds one decaying page.
- The **page-detail sheet** behind a cell tap: retrievability stated as a **range in words** with its basis ("estimated — not yet recited" / "from self-rating"), the next-due date in the chosen calendar + locale numerals, and a short history from the append-only `review_log` — never a false-precise single percent, never raw `R`/D/S.
- The **weakest-juz / weakest-pages list**: a calm, informational "where to look first" list the user can tap straight into the detail sheet (or the reader), surfacing the weak link rather than smoothing it.
- The **calm upcoming-load forecast**: how many pages are due over the coming days so the user can plan — a planning aid framed as help, never a performance dashboard or a deadline pile.
- The **no-scoreboard adab**: an optional, **opt-in, private, non-punitive** continuity indicator (off by default), the welcoming first-run / empty Progress state, and the honest-recession-no-shame response to a missed day; transcreated calm copy per locale.
- **Per-locale RTL + greyscale/deuteranope + offline golden tests** across fa/ckb/ar on the real bundled UI fonts.

### Out of scope

- The **heat-map cell leaf widget**, the page card, and the numerals/calendar/text primitive themselves (their state matrix + tokens + a11y anatomy) → owned by **E10 mihrab-component-library**; this epic *assembles* them into the grid, list, and detail sheet.
- The concrete **ramp hex values, the four appearances, and the contrast audit** → owned by `docs/design-system/03-color-and-themes.md`; this epic references `color.heatmap.*` **by name** and never inlines a hex or restates the audit.
- The **engine math behind the cell** — `R` / FSRS D/S/R, `sourceConfidence`, the min-leaning aggregate semantics, the trust clamp, "never safe to drop" → owned by **E04 scheduling-engine** (`docs/engineering/06-scheduling-engine.md`); this epic reads the result, never re-derives a schedule.
- The **recite/grade flow** a page taps into from the detail sheet (reveal-on-tap, Again/Hard/Good/Easy, teacher sign-off) → **E12 today-and-recite-grade**.
- The **immutable muṣḥaf page render** and any glyph/overlay — the visualization layer is glyph-free; "go to this page in the reader" hands off to **E13 muṣḥaf-reader** (`docs/engineering/08`; PRD R1).
- The **catch-up banner** UI and the Today daily-session list → **E12** (this epic routes a gap to the calm catch-up plan, it does not build the banner).
- The **science screen** that explains the methodology behind the map → **E19 science-screen-and-claims**.
- The **Drift schema / DAO transaction bodies** for `card` / `review_log` → **E03 models-and-persistence**; this epic adds only a read-only query over the existing tables.
- The **CI no-network / banned-import / golden / coverage gates** → authored in **E01 repo-scaffold-and-ci**; this epic must give them nothing to catch.

## Dependencies

### Depends on

- **E07 app-shell-walking-skeleton** — the Riverpod composition root, the injected `Clock` ("today" for `R`-on-read), the live Drift handle and single read path, and the `go_router` `ShellRoute` whose inert Progress placeholder tab this epic replaces.
- **E10 mihrab-component-library** — the heat-map cell leaf (ramp colour + locale-numeral label + VSUP muting), the page card used as the detail-sheet drill-down row, and the `numberFormatFor(locale)` / `CalendarPresenter` rendering primitive this surface's numbers and dates flow through.
- **E04 scheduling-engine** — the pure `retrievability(...)` function, the decay-band derivation, and the **min-leaning** per-juz aggregate semantics the read model calls on the live card set; the engine is injected and imports nothing from Riverpod or Flutter.

### Enables

- **E19 science-screen-and-claims** — "why does the app say this?" affordances from a heat-map cell / the forecast link to the science screen that renders the CLAIMS behind retention and the no-streak stance (C-041, C-044).
- **E20 release-readiness** — the per-locale RTL / greyscale-CVD / offline goldens established here feed the release gate suite; the central emotional surface is hardened before launch.

## Foundation inputs

| Input | Where (doc/skill) | What this epic takes from it |
|---|---|---|
| Heat-map visual grammar | `docs/design-system/08-data-visualization.md` §1–§8 | Overview→zoom→details-on-demand; single-hue lightness ramp; decay visible never alarming; VSUP uncertainty muting; redundant colour+number+label; min-leaning juz roll-up; muṣḥaf-order RTL small multiples; never a streak/score/scoreboard |
| Ramp tokens & contrast | `docs/design-system/03-color-and-themes.md` §5, §7 | The `color.heatmap.strong → faded` ramp (by name only), the 3:1 anchor / labelled-tap-through-cell contrast posture, no alarm-red for routine hifz state |
| Heat-map skill | skill `ui-retention-heatmap` (+ `template.dart`) | The grid / juz tile / muted cell / detail-sheet scaffold, the "read engine state only, never recompute" rule, the no-scoreboard checklist |
| Page-card / detail row | skill `ui-page-card` | The detail-sheet drill-down row (track chip + decay indicator + locale-numeral "Page N · Juz M"); never shows `R`/a percentage/"safe to drop" |
| Numerals & dates | skill `ui-numerals-calendar-text` | Every cell %/page number via `numberFormatFor(locale)`, every next-due date via the one `CalendarPresenter`, FSI/PDI-isolated; counts through ICU `plural` (ar's six categories) |
| IA & the Progress screen | PRD §12.5 | Heat-map leads; tap a juz → page detail; weakest-pages list + upcoming-load forecast + simple `review_log` history; **no streaks-as-pressure**, only an optional private opt-in continuity indicator |
| Engine read contract | `docs/engineering/06-scheduling-engine.md`; PRD §7.3, §7.12, §10.3 | `retrievability(t,S)`, conservative priors, `sourceConfidence`, the min-leaning juz aggregate, the never-"safe to drop" invariant the chart must not break |
| Read-model / store | skill `eng-create-riverpod-store`; `docs/engineering/04-flutter-and-state-patterns.md` | The `StreamProvider` over a Drift query, immutable read model, derived health never stored, no `DateTime.now()` in shell logic |
| Feature module anatomy | skill `eng-add-feature-module`; `docs/engineering/02-project-structure.md` | `features/lib/src/progress/` folder anatomy (dumb View, 1:1 ViewModel, `widgets/`, scoped providers), downward-only deps |
| RTL & bidi | skill `eng-rtl-and-bidi-layout`; `docs/design-system/12-localization-and-rtl.md` | Logical start/end grid layout, weakest-page badge at logical start, FSI/PDI isolation of every %/page/date run |
| Accessibility | `docs/design-system/09-accessibility-and-inclusivity.md`; PRD §18 | SC 1.4.1 (colour never sole channel), SC 1.4.11 (3:1 anchor), per-locale screen-reader value+label, sufficient heat-map contrast |
| Localized strings | skill `eng-add-localized-string` | The band labels, range/forecast/empty-state copy as ARB keys (ar template + fa/ckb), transcreated, count-bearing strings as ICU plurals |
| Adab guardrails | skill `domain-adab-and-religious-integrity`; PRD §4 (R3) | No gamification of worship, no guilt/loss/streak copy, calm maintenance framing, no celebration of a completed juz |
| Claims behind the numbers | `docs/science/CLAIMS.md` (C-001, C-010, C-016, C-019, C-025, C-041, C-044) | Every user-facing retention claim is a graded, sourced row; the map promises no retention percentage |
| Tests | skill `eng-write-dart-test`; `docs/engineering/11-testing-strategy.md` | Per-locale RTL goldens, a greyscale/deuteranope magnitude check, an `HttpOverrides` offline guard, read-model unit tests over a fake card set |

## Deliverables

- [ ] A `progressHeatmapProvider` `StreamProvider` (data/read-model layer) that streams per-page `R` + decay band and the min-leaning juz roll-up from the live card set, computing `R` on read via the injected engine + `Clock` — derived health never stored.
- [ ] The `features/lib/src/progress/` module: dumb `ProgressScreen` View + 1:1 `ProgressViewModel` + scoped `progress_providers.dart`, replacing E07's inert Progress placeholder tab in the `ShellRoute`.
- [ ] The 604-page / 30-juz cluster grid in muṣḥaf order under `Directionality.rtl`, faithful small multiples, overview-first, assembling E10's heat-map cell leaf with `touch.min` tiles and `space.*` gutters.
- [ ] The single-hue green-receding ramp (tokens by name), redundant colour+number+label cells with VSUP muting of uncertain pages, and locale numerals via `numberFormatFor(locale)`.
- [ ] Min-leaning juz roll-up tiles + the weakest-page badge at the logical start; the detail names the weakest page(s).
- [ ] The page-detail sheet: retrievability **range in words** + basis, next-due via `CalendarPresenter`, short `review_log` history; no raw `R`/D/S, no false-precise single percent.
- [ ] The weakest-juz / weakest-pages list, tappable into the detail sheet / reader.
- [ ] The calm upcoming-load forecast (pages due over coming days) as a planning aid; count strings through ICU `plural`.
- [ ] The optional opt-in private continuity indicator (off by default), the welcoming first-run / empty Progress state, and the honest-recession-no-shame missed-day behaviour.
- [ ] fa/ckb/ar ARB strings (ar template) for every band label, range, forecast, and empty-state copy — transcreated, scholar-reviewable adab.
- [ ] Widget + golden tests: the grid, a min-leaning juz tile, a muted (uncertain) cell, the detail sheet, and the forecast across fa/ckb/ar on real fonts, with a greyscale/deuteranope check and an `HttpOverrides` offline guard.

## Definition of Done

- [ ] **Offline / no-network**: the Progress surface renders streamed engine state only — it never fetches, records, infers, or opens a socket; an `HttpOverrides` test proves the radio stays off (PRD C1; `docs/engineering/09`).
- [ ] **No AI / no audio**: no model, no inference, no microphone anywhere on this surface — `R` and the bands are pure deterministic engine output read on read (PRD C2).
- [ ] **Text fidelity**: the visualization layer renders **no Quran glyph** and tints none — markers/overlays live over the immutable glyph layer in the reader, never here (PRD R1; `docs/engineering/08`).
- [ ] **Honest aggregate**: the juz roll-up is **min-leaning, never a mean**; one weak page can fail its juz tile colour or surface the weakest-page badge, and the detail names the weak page — a unit test pins that a single rotting page is never averaged into a green tile (PRD §10.3, §7.12; C-019).
- [ ] **Never "safe to drop", never a scoreboard**: no streak/best-day/points/level/leaderboard near the map; any continuity indicator is opt-in, private, non-punitive; a missed day shows honest recession with no shame UI and routes to the calm catch-up plan; completing a juz/session produces no confetti, green flash, badge, or sound (PRD §12.5, R3, C6; C-041, C-044; `domain-adab-and-religious-integrity`).
- [ ] **Honest about prediction**: the detail sheet states retrievability as a **range in words** with its basis, never a false-precise single percent and never raw `R`/D/S; an uncertain page (cold-start prior / self-rating-only) renders **muted** and cannot reach the most-saturated tier on one self-rating (08-data-visualization §4; PRD §7.10, §8.1); the map promises **no retention percentage** (C-025).
- [ ] **RTL + fa/ckb/ar localization**: the grid lays out start→end under `Directionality.rtl` with the weakest-page badge at the logical start; every %/page/date run uses locale numerals (Extended Arabic-Indic fa/ckb, Arabic-Indic ar) via `intl` and is FSI/PDI-isolated; counts use ICU `plural` (ar's six categories); every string is an ARB key (ar template + fa/ckb), transcreated, no hardcoded literal.
- [ ] **Accessibility**: colour is never the sole channel (SC 1.4.1) — every cell carries number + label; `color.heatmap.strong` clears the 3:1 anchor floor (SC 1.4.11); a screen reader announces each cell's value + label in the active locale; a greyscale/deuteranope golden proves magnitude order still reads (PRD §18; `docs/design-system/09`).
- [ ] **Tests**: read-model unit tests over a fake card set (R-on-read, min-leaning roll-up, muting), and widget/golden coverage of the grid, a min-leaning tile, a muted cell, the detail sheet, and the forecast across fa/ckb/ar on real bundled fonts — green locally and in CI.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E15-T01 | [Progress read model: StreamProvider streaming per-page R + min-leaning juz roll-up from the live card set — test-first](E15-T01-progress-read-model.md) | M | E07, E04 |
| E15-T02 | [Progress feature module scaffold replacing the inert Progress placeholder tab](E15-T02-progress-feature-module.md) | S | E15-T01, E07 |
| E15-T03 | [604-page / 30-juz cluster grid in muṣḥaf order under RTL, assembling the heat-map cell leaf](E15-T03-whole-quran-cluster-grid.md) | M | E15-T02, E10 |
| E15-T04 | [Green-receding ramp + redundant colour+number+label cells + VSUP uncertainty muting](E15-T04-ramp-redundancy-vsup-muting.md) | M | E15-T03, E10 |
| E15-T05 | [Min-leaning juz roll-up tiles + weakest-page badge — test-first](E15-T05-min-leaning-juz-rollup.md) | M | E15-T03, E15-T01 |
| E15-T06 | [Page-detail sheet: retrievability range in words + next-due + review_log history](E15-T06-page-detail-sheet.md) | M | E15-T03, E15-T01 |
| E15-T07 | [Weakest-juz / weakest-pages list, tappable into the detail sheet](E15-T07-weakest-pages-list.md) | S | E15-T05, E15-T06 |
| E15-T08 | [Calm upcoming-load forecast as a planning aid](E15-T08-upcoming-load-forecast.md) | S | E15-T01, E15-T02 |
| E15-T09 | [No-scoreboard adab: optional opt-in private continuity indicator + empty/first-run state + missed-day recession](E15-T09-no-scoreboard-adab-empty-state.md) | S | E15-T02, E15-T03 |
| E15-T10 | [Per-locale RTL + greyscale/deuteranope + offline golden suite for the Progress surface](E15-T10-progress-golden-suite.md) | M | E15-T04, E15-T05, E15-T06, E15-T08 |

## Risks

- **The grid drifts toward a red failing scoreboard.** A "make it scary so they revise" instinct (loss-framing boosts short-term effort) would spike anxiety and frame revision as fear — exactly what the PRD forbids. *Mitigation:* the decay end is a muted neutral by token (`color.heatmap.weak/faded`), no alarm-red is reachable, framing is "ready for revision," a gap routes to the calm catch-up plan, and the no-scoreboard rule is a release-blocking DoD item (08-data-visualization §3, §8; PRD R3; C-041).
- **The juz roll-up gets "improved" into a mean for a prettier, greener map.** An average would hide a single rotting page and silently break the never-"safe to drop" invariant at the chart layer. *Mitigation:* the min-leaning aggregate is computed in the engine-backed read model (not the widget), pinned by a test-first unit test, and called out as load-bearing in the task and DoD (08-data-visualization §6; PRD §10.3, §7.12; C-019).
- **False precision on a prediction.** Showing a crisp "87%" presents a cold-start prior or a low-confidence self-rating as a measurement. *Mitigation:* the detail sheet states a range in words with its basis, never raw `R`; uncertain pages render muted (VSUP) and a single self-rating cannot reach the top tier; the map makes no retention-percentage promise (08-data-visualization §4; PRD §7.10, §8.1; C-025).
- **Colour becomes the sole channel.** A shade-only grid excludes ~8% of men with red-green CVD and fails SC 1.4.1. *Mitigation:* every cell carries colour + localized number + plain label (+ optional decay texture); a greyscale/deuteranope golden asserts magnitude order still reads; the 3:1 anchor posture is from the audit, not re-invented (08-data-visualization §5; PRD §18).
- **The widget recomputes the schedule.** Re-deriving `R` / `due_at` / the aggregate in the View would duplicate and drift from the engine. *Mitigation:* all health is computed in the engine-backed read model on read, derived health is never stored, and the widget reads only the streamed model (skill `ui-retention-heatmap`; `eng-create-riverpod-store`; PRD §10.3).
- **A glyph or decoration creeps into the visualization layer.** A "preview the page" temptation would put sacred text on the chart. *Mitigation:* the layer is glyph-free by construction; "go to this page" hands off to the reader (E13), where the immutable glyph layer lives (PRD R1; `domain-mushaf-text-integrity`).

## References

- `docs/PRD.md` — §12.5 (Progress screen), §10.3 (min-leaning juz health, derived not stored), §7.3 / §7.6 / §7.12 (retrievability, trust clamp, engine invariants), §8.1 (`sourceConfidence`), §13.2–§13.3 (RTL, numerals, calendars), §18 (accessibility), §4 R1/R3 (text fidelity, no gamification), C1/C2/C6 (offline, no-AI, no gamification)
- `docs/design-system/08-data-visualization.md` — §1–§8 (the whole heat-map visual grammar)
- `docs/design-system/03-color-and-themes.md` — §5 (the heat-map ramp tokens), §6 (no alarm-red for routine hifz state), §7 (contrast audit / anchor posture)
- `docs/design-system/09-accessibility-and-inclusivity.md` — SC 1.4.1 / 1.4.11, per-locale screen-reader semantics
- `docs/design-system/12-localization-and-rtl.md` — §3 (FSI/PDI isolation), §4 (numerals via `intl`), §5 (calendars as display transform)
- `docs/engineering/06-scheduling-engine.md` — `retrievability(t,S)`, conservative priors, the min-leaning aggregate, the never-"safe to drop" invariant
- `docs/engineering/04-flutter-and-state-patterns.md`; `docs/engineering/02-project-structure.md` — read model / `StreamProvider`, feature-module anatomy, downward-only deps
- `docs/engineering/11-testing-strategy.md` — per-locale RTL goldens, CVD/greyscale check, offline `HttpOverrides` guard
- `docs/science/CLAIMS.md` — C-001, C-010 (forgetting curve / power-law `R`), C-016, C-019 (cycle ceiling / never "safe to drop"), C-025 (no retention-percentage promise), C-041, C-044 (no streaks/badges; calm self-referential map)
- `.claude/skills/` — `ui-retention-heatmap`, `ui-page-card`, `ui-numerals-calendar-text`, `eng-create-riverpod-store`, `eng-add-feature-module`, `eng-rtl-and-bidi-layout`, `eng-add-localized-string`, `eng-write-dart-test`, `domain-scheduling-engine-rules`, `domain-mushaf-text-integrity`, `domain-adab-and-religious-integrity`
