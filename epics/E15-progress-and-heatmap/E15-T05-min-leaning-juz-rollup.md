# E15-T05 — Min-leaning juz roll-up tiles + weakest-page badge — test-first

| | |
|---|---|
| **Epic** | [E15 — Progress & Heat-map](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E15-T03, E15-T01 |
| **Skills** | ui-retention-heatmap, domain-scheduling-engine-rules, eng-write-dart-test |

## Goal

The juz level of the heat-map tells the truth about the weakest link. Each of the 30 juz tiles colours **toward its weakest constituent page** — the **min-leaning** aggregate streamed from the E15-T01 read model, **never a mean** — and where a juz is mostly strong but holds one decaying page, a small **weakest-page badge** (redundant shape + glyph + plain label) sits at the **logical start** of the tile under `Directionality.rtl`; tapping the tile opens the detail with the weak page(s) **named**. This is **test-first**: the invariant that a single rotting page can "fail" its juz colour or surface the badge — and is never averaged into a green tile — is pinned by widget tests *before* the tile is styled (08-data-visualization §6; PRD §10.3, §7.12; C-019). The tile renders the streamed aggregate and **never recomputes** `R`, `due_at`, or the roll-up. Boundary: the aggregate's *semantics* are E04 engine + E15-T01 (same invariant pinned there at the data layer, here at the presentation layer); per-page cell encoding is E15-T04; grid geometry is E15-T03; the detail-sheet *body* is E15-T06; the textual weakest-pages *list* is E15-T07.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/08-data-visualization.md` §6 | The governing spec, verbatim: the juz tile is a **min-leaning roll-up, not a mean**; "a single rotting page must be able to 'fail' its juz's colour (or surface a weakest-page badge), because one weak page is what fails you in ṣalāh"; the badge makes one weak link visible on a mostly-strong juz "without recolouring the whole juz misleadingly — honesty without alarm"; the badge sits at the logical **start** under `Directionality.rtl`; the detail names the weakest page(s); documented as **load-bearing** so no contributor "improves" the roll-up into a mean for a prettier, greener map |
| `docs/design-system/08-data-visualization.md` §3 | The badge and the weak-leaning tile are *calm* honesty: decay visible, never alarming — no saturated red, no failing-scoreboard styling on the badge or the tile |
| `docs/PRD.md` §10.3 | Juz health is **computed from `card.R`, never stored**, with a **min-leaning aggregate** — "one weak page is what fails you in ṣalāh — surface the weakest link"; the computation lives in the engine-backed read model (T01), not this widget |
| `docs/PRD.md` §7.12 | The invariant a mean would silently break at the chart layer: "the engine never displays or implies 'this page is safe to stop revising'" — a green tile hiding a rotting page *is* that implication |
| `docs/PRD.md` §12.5, §20 | Tap a juz → page detail; the min-leaning roll-up is a release expectation (08 §6 names §20); §20's widget-test tier explicitly covers the heat-map, and §7.12 invariants ship as pinned tests |
| `docs/design-system/03-color-and-themes.md` §5 | The tile draws only from the `color.heatmap.strong → good → fair → weak → faded` ramp **by token name** (values owned there, never inlined); the §5 anti-pattern restates it: never "roll juz health up by an average that hides a single weak page" |
| `docs/design-system/09-accessibility-and-inclusivity.md` §8 | RTL reading/focus order **is** the visual order: the badge at the logical start is reached first in traversal; logical start/end properties only (never `left`/`right`); the badge's page-number run is FSI/PDI-isolated in locale numerals so it neither displays nor *reads* out of order |
| Skill `ui-retention-heatmap` (+ `template.dart`) | Pattern 6 (min-leaning tile + weakest-page badge, load-bearing — never a mean), Pattern 7 (`EdgeInsetsDirectional`/logical start-end, muṣḥaf order untouched), Pattern 10 (badge at logical start; screen reader announces value + label per locale); the template's `JuzTile` / `weakestPageId` scaffold is the starting shape |
| Skill `domain-scheduling-engine-rules` | The aggregate's semantics belong to the engine layer; never "safe to drop" (rule 18) — this tile *reads* the engine-backed result and renders it, it never re-derives `R`, a band, or the roll-up |
| Skill `eng-write-dart-test` | Test-first at the widget tier; injected `CalendarDate`/fake read model (no `DateTime.now()`); goldens on the real bundled fonts tagged `@Tags(['golden'])`; the throwing-`HttpOverrides` offline guard |
| `docs/science/CLAIMS.md` — **C-019** | The scientific warrant behind this surface ("a strong page never becomes 'done' — only continued recitation keeps it", [EXP]; surfaces: engine invariant + **heat-map**) — why the weak link is surfaced, not smoothed |
| `docs/science/CLAIMS.md` — **C-016** | The calm framing behind any badge/detail copy that says the weak page remains scheduled: every page is guaranteed a revision at least once per cycle — the app "can only revise it *more* often, never less" ([EXP]/[TRAD]); surfacing weakness is information, never an alarm |
| Sibling **E15-T01** | The producer: pins **test-first at the data layer** that `progressHeatmapProvider` *computes* the min-leaning roll-up + weakest-page id(s) from the live card set via the injected engine + `Clock`; this task pins the **same invariant at the presentation layer** — the tile renders the streamed value verbatim and never recomputes it |
| Sibling **E15-T03** | Supplies the juz-block small-multiple slot (geometry, `space.*` gutters, `touch.min` tiles, muṣḥaf order under RTL) this tile mounts into; this task changes no layout |
| Sibling **E15-T04** | Owns the **per-page cell** encoding (ramp application, colour+number+label redundancy, VSUP muting); this task owns only the **juz-level** tile appearance and badge |
| Sibling **E15-T06** | Owns the detail-sheet **body** (range in words, next-due, history); this task wires the tile's tap and hands over the weakest-page id(s) so the sheet can name them |
| Sibling **E15-T07** | Owns the textual weakest-juz / weakest-pages **list** — the non-visual equivalent surface; this task is the *on-grid* tile + badge only |
| Sibling **E15-T10** | Consumes this task's per-locale tile/badge goldens into the consolidated RTL + greyscale/deuteranope + offline suite |
| Out of scope **E10 mihrab-component-library** | Owns the heat-map cell leaf's anatomy/tokens; this task composes the juz tile *around* T03's assembled block — it does not build or alter leaf anatomy |

## Implementation notes

This task is presentation-only: no engine import, no Drift query, no `DateTime.now()`, no write path. It renders the juz roll-up the E15-T01 read model already streamed. The min-vs-mean invariant is **correctness-critical for honesty** → it is pinned by widget tests written *before* the tile is styled, mirroring T01's data-layer test-first pin.

1. **Files** (in the `features` umbrella package, `lib/src/progress/`, per eng-add-feature-module): `widgets/juz_rollup_tile.dart` — a dumb stateless `JuzRollupTile` taking the streamed per-juz roll-up value from T01 (its band + weakest-page id(s)/flag, per the `ui-retention-heatmap` template's `JuzTile`/`weakestPageId` shape); `widgets/weakest_page_badge.dart` — the badge leaf. Mount into T03's juz-block slot; touch no grid geometry.
2. **The tile never aggregates.** The band arrives computed (min-leaning, from the engine-backed read model); the widget maps it to a `color.heatmap.*` token **by name** and draws. No loop over page `R`s, no `min`/`reduce`/average, no threshold logic in widget code — verifiable by grep over the task's files. If the streamed value seems wrong, fix T01/E04, never "correct" it here.
3. **Badge trigger comes from the model too.** The read model marks a mostly-strong juz holding decaying page(s) and supplies the weakest-page id(s) (T01's contract); this widget only renders the flag. The badge is **redundant**: a distinct shape + glyph + plain localized label — never colour alone (SC 1.4.1) — styled with calm neutral/outline tokens. Decay is **not a semantic state** (03-color §6): no `color.semantic.warning` (reserved for asset-integrity notices), no red-adjacent tone, no alarm iconography (08 §3, §6).
4. **Badge at the logical start.** Place via `PositionedDirectional(start: …)` / `AlignmentDirectional.topStart` under the app-wide `Directionality.rtl` — never `left`/`right` (09-accessibility §8; ui-retention-heatmap Pattern 10). The badge is part of the tile's one semantic node (merged `Semantics`), not a separate focus stop, so traversal order stays the visual order.
5. **Tap → detail names the weak page.** The tile's tap opens the E15-T06 detail sheet, passing the juz and its weakest-page id(s); the detail names them as "Page N · Juz M" in locale numerals via `numberFormatFor(locale)`, FSI/PDI-isolated. This task asserts the name *arrives and renders*; the sheet's body/anatomy is T06's.
6. **Copy through the ARB pipeline** (eng-add-localized-string): the badge label and any weakest-page phrase are `l10n.*` keys in `app_ar.arb` (base) + transcreated `fa`/`ckb` — calm maintenance framing (e.g. "one page ready for revision"), never "failing"/"behind"/"at risk"/"you are losing". If copy states the weak page remains scheduled, it traces to **C-016** (revised more often, never less). No raw `R`/D/S, no percent on the tile face — exactness lives behind the tap (08 §1).
7. **Semantics:** the tile announces juz (locale numerals) + band label + the weakest-page fact when present, in the active locale; the whole tile is one ≥`touch.min` target (T03 sizing). No celebration on an all-strong juz — the calm strong ramp colour and nothing else: no checkmark, trophy, flash, or sound.
8. **Pitfalls to avoid:** computing the aggregate — or *any* mean — in the widget; suppressing the badge or nudging the band to make the map greener; hard-coding the badge `left`/`right` (it must flip with directionality by construction); a red or exclamatory badge; a percent or raw `R` on the tile face; deriving the "mostly strong" threshold locally; a separate badge focus node that breaks RTL traversal; styling the tile before the min-vs-mean widget tests exist and fail.

## Acceptance criteria

- [ ] `progress/widgets/juz_rollup_tile.dart` and `weakest_page_badge.dart` exist in the `features` package; each is a dumb stateless widget taking a pre-computed roll-up value, with no engine import, no aggregate/mean/threshold computation, no `DateTime.now()`, no Drift access (verifiable by grep).
- [ ] A juz tile's colour is the streamed **min-leaning** band mapped to a `color.heatmap.*` token by name (no inlined hex); a juz of 19 strong pages + 1 rotting page renders the weak-leaning band **or** shows the weakest-page badge — never the plain strong/green tile a mean would produce.
- [ ] The weakest-page badge is redundantly encoded (shape + glyph + localized label, never colour alone), uses no semantic-alert token and no red-adjacent/alarm styling (decay is not a semantic state, 03-color §6), and sits at the **logical start** of the tile under `Directionality.rtl` in all three locales.
- [ ] Tapping a tile opens the E15-T06 detail carrying the weakest-page id(s); the detail names the weak page(s) as "Page N · Juz M" in locale numerals, FSI/PDI-isolated.
- [ ] The tile face shows no raw `R`/D/S and no percent; an all-strong juz renders calmly with no celebration element.
- [ ] Every user-facing string is an `l10n.*` ARB key in fa/ckb/ar (ckb flagged pending native+scholar review), transcreated, calm maintenance framing; no hardcoded user-facing text.
- [ ] The tile is one merged `Semantics` node announcing juz + band label + weakest-page fact in the active locale; layout uses logical start/end only (no `left`/`right`).
- [ ] The min-vs-mean widget tests were written first (red before the tile was styled) and are green; the goldens render on the real bundled fonts.

## Tests

All deterministic and offline by construction: a fake T01 read model supplies seeded roll-up values (no live Drift, no engine call in the test, no wall clock); the suite runs under a throwing `HttpOverrides` (eng-write-dart-test). **Written first**, before the tile is styled.

- `features/test/progress/juz_rollup_tile_test.dart` (widget) — **written first**, the presentation-layer pin of the T01 invariant:
  - seeded juz of **19 strong + 1 rotting** pages (streamed band = weak-leaning, weakest-page id set) → the rendered tile resolves to the weak-leaning `color.heatmap.*` token **or** shows the badge — asserted **never** the strong band;
  - the test computes the hypothetical *mean* band for the same 20 pages and asserts the rendered tile does **not** match it — a regression to averaging fails loudly;
  - the tile renders the streamed band **verbatim**: a recording fake read model proves the widget consumed the provided value and performed no page-level aggregation;
  - an all-strong juz renders the strong band with no badge and no celebration widget.
- `features/test/progress/weakest_page_badge_test.dart` (widget) — the badge renders shape + glyph + localized label (colour never the sole channel); under `Directionality.rtl` it sits at the logical **start** in each of fa/ckb/ar; no `color.semantic.warning` token, no red-adjacent tone, and no alarm icon in the subtree (03-color §6); the label resolves from the ARB pipeline in all three locales.
- `features/test/progress/juz_tile_detail_wiring_test.dart` (widget) — tapping a badged tile opens the detail route/sheet (a fake navigator records the push) carrying the weakest-page id(s), and the weak page is **named** in the opened surface in locale numerals; no write path is touched (a recording repository double asserts zero writes).
- `features/test/progress/juz_rollup_tile_golden_test.dart` (golden, `@Tags(['golden'])`) — per-locale (fa/ckb/ar) goldens of a badged mostly-strong tile and a weak-leaning tile on the real bundled fonts; masters feed the E15-T10 consolidated RTL + greyscale/deuteranope suite (which owns the CVD simulation pass — not re-run here).
- Offline guard: the throwing `HttpOverrides` bootstrap proves no surface in this task opens a socket.

## Definition of Done

- [ ] All acceptance criteria met; the min-vs-mean widget tests were written first and are green; goldens run in CI on the real bundled fonts under the pinned golden job.
- [ ] **Offline / no-network**: the tile and badge render streamed read-model state only — no fetch, no socket; the `HttpOverrides` guard passes (PRD C1).
- [ ] **No AI / no microphone**: nothing here records, infers, or listens; the roll-up is deterministic engine output read through T01 (PRD C2).
- [ ] **Quran text fidelity (R1)**: the visualization layer stays glyph-free — no Quran glyph is rendered, tinted, or decorated on a tile or badge; "go to the page" hands off outside this layer.
- [ ] **Honest aggregate / never "safe to drop" (§7.12, §10.3; C-019)**: the juz tile is **min-leaning, never a mean**; a single rotting page is never hidden behind a green tile — it fails the colour or surfaces the badge, and the detail names it; pinned test-first here at the presentation layer, matching T01's data-layer pin; no copy implies a page is done, mastered, or safe to stop revising.
- [ ] **No gamification / no shame (R3, C6)**: the badge is calm information (no red, no alarm, no guilt copy — the weak page is "ready for revision", still guaranteed its cycle pass per C-016); an all-strong juz gets no checkmark, trophy, flash, or sound.
- [ ] **The View is dumb**: the tile reads the streamed T01 aggregate and never recomputes `R`, `due_at`, a band, a mean, or the badge threshold; no `DateTime.now()`, no engine import, no write path (grep-verifiable).
- [ ] **RTL + fa/ckb/ar localization**: the badge sits at the logical start via directional APIs only and flips with `Directionality` by construction; every string ships through the ARB pipeline (ar template + fa/ckb, transcreated, ckb flagged for native+scholar review); page/juz numbers render in locale numerals, FSI/PDI-isolated.
- [ ] **Accessibility (WCAG 2.2 AA)**: colour is never the sole channel on tile or badge (SC 1.4.1); the tile is one merged `Semantics` node announcing juz + band + weakest-page fact per locale; traversal order matches the RTL visual order (09-accessibility §8); targets meet `touch.min`.
- [ ] **Deterministic tests**: fake read model + injected values only (no hidden clock, no network); goldens byte-stable on the pinned fonts; the E15-T10 suite consumes them unchanged.
