# references — ui-retention-heatmap

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. The heat-map references every `color.heatmap.*` / `space.*` / `touch.min` token **by name** — the concrete values, ramp, and contrast audit live in the design docs, not here.

## Primary — the heat-map's own grammar

- `docs/design-system/08-data-visualization.md` §1 (overview → zoom → details) — **The whole-Quran cluster grid is the surface; numbers live behind a tap.** Progress opens on the 604-page / 30-juz overview, not a stats table; the interaction is *overview first → zoom (juz) → details-on-demand (page)*; tiles meet `touch.min`, gutters use `space.*`.

- `docs/design-system/08-data-visualization.md` §2 (single-hue lightness ramp) — **Strength is ordered data, so it gets an ordered encoding carried by lightness, not hue.** `color.heatmap.strong → faded`, monotonic in luminance, the strong anchor the same green family as `color.accent.green`; the order survives greyscale and CVD.

- `docs/design-system/08-data-visualization.md` §3 (decay visible, never alarming) — **The decay end is a muted neutral, never a saturated red, and never a rainbow/jet colormap.** Green *recedes* to show decay honestly; framing is maintenance ("ready for revision"), never loss; a gap routes to the calm catch-up plan, not a red overdue pile.

- `docs/design-system/08-data-visualization.md` §4 (VSUP uncertainty muting) — **A prediction looks like a prediction.** A cold-start / never-recited page and a self-rating-only page render muted toward `color.heatmap.faded` and saturate only as confident reviews (teacher sign-off = 1.0) accumulate; a single self-rating never reaches the top tier.

- `docs/design-system/08-data-visualization.md` §5 (redundant encoding) — **Colour is never the sole channel.** Each cell/detail carries a localized retrievability value/range + a plain label (+ optional decay texture); the strong anchor clears the 3:1 graphical-object floor, lower steps live only inside labelled tap-through cells; likelihood never stands on a bare word.

- `docs/design-system/08-data-visualization.md` §6 (min-leaning juz roll-up) — **The juz colour leans to the weakest page, never the average.** One rotting page must be able to fail its juz colour or surface a weakest-page badge; an averaging roll-up would break "never safe to drop" at the chart layer; this is a load-bearing choice, not a cosmetic one.

- `docs/design-system/08-data-visualization.md` §7 (muṣḥaf-order RTL small multiples) — **Spatial order *is* Quran order.** 30 juz blocks in muṣḥaf order flow start→end under `Directionality.rtl`; one juz block is learned once and read thirty times; never reorder by weakness or swap for a clever chart; the layer renders state, never the sacred glyphs.

- `docs/design-system/08-data-visualization.md` §8 (never a streak, score, or scoreboard) — **The map's only job is honest situational awareness.** No streak/best-day/points/level/leaderboard; any continuity indicator is opt-in, private, non-punitive; completing a juz/session triggers no confetti/flash/badge/sound; a missed day shows honest recession with no shame UI.

- `docs/PRD.md` §12.5 (Progress) — **The product contract for this screen.** Whole-Quran retention heat-map = the emotional hook ("keep your Quran green"); tap a juz → page detail; per-juz/per-page health, weakest-pages list, upcoming-load forecast, simple `review_log` history; **no streaks-as-pressure**, only an optional private opt-in continuity indicator.

## Supporting — tokens, engine inputs, accessibility, RTL

- `docs/design-system/03-color-and-themes.md` §5 (the retention heat-map ramp) — **The concrete ramp lives here, owned by token name.** `color.heatmap.strong → good → fair → weak → faded`, the per-appearance hex table, monotonic-in-luminance guarantee, and the redundant number+label rule; reference these by name, never inline a hex.

- `docs/design-system/03-color-and-themes.md` §2 (green = reverent ground, never reward) — **Green is a state, not a trophy.** `color.heatmap.strong`, never `color.success`; green never flashes to celebrate, never badges an ayah, never tints the QPC glyphs.

- `docs/design-system/03-color-and-themes.md` §6 (small semantic set) — **No alarm-red for routine hifz state.** Decay, missed days, and catch-up are not semantic error states; the only red-adjacent token is the rare asset-integrity warning, never a comment on the user's revision.

- `docs/design-system/03-color-and-themes.md` §7 (WCAG 2.2 contrast audit) — **The strong anchor clears 3:1 (SC 1.4.11); lower steps intentionally sit below it inside labelled cells.** The audit is re-run on any token change as a release gate — do not restate or fork it in the widget.

- `docs/PRD.md` §7.10 (cold start) + §7.12 (engine invariants) — **The engine's conservative priors and "never safe to drop" invariant are what the muting and roll-up render.** Priors under-estimate so the first recitation can only surprise upward; the engine never implies a page is safe to stop revising — the chart must not break that.

- `docs/PRD.md` §8.1 (self-rating) + §10.2 (user data) — **`sourceConfidence` drives the muting; the cell reads, never writes.** Self-rating ≈ 0.5 vs. teacher sign-off = 1.0; `card.R`, due, and the `review_log` history behind a cell are read from the engine/Drift, never recomputed in the widget.

- `docs/design-system/09-accessibility-and-inclusivity.md` (SC 1.4.1 / 1.4.11, target size, screen reader) — **Colour-independence and the contrast floor are release-gated here.** A cell announces its value + label in the active locale; the grayscale/CVD legibility of the ramp is verified, not assumed.

- `docs/PRD.md` §13.2 (RTL) + §13.3 (numerals) — **Grid flows RTL; numerals are locale-set, bidi-isolated.** Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar, via `intl` `NumberFormat`; mixed Latin/numeral runs use FSI/PDI so a range never reorders inside the RTL label.

## Sibling skills

- **ui-page-card** — the single Today row; its per-row decay indicator (color + glyph + label) echoes a heat-map cell, but that skill owns the *row* and this one owns the *grid*.
- **ui-daily-session-list** — the finite, capped, Far→Near→New Today list container the page-card rows live in.
- **ui-recite-grade-flow** — the reveal-on-tap + Again/Hard/Good/Easy grade flow a page taps into from the detail sheet.
- **domain-scheduling-engine-rules** — the `card.R`, FSRS D/S/R, `sourceConfidence`, min-leaning aggregate, and "never safe to drop" logic the cell reads but never re-derives.
- **domain-mushaf-text-integrity** — the immutable QPC glyph layer; the visualization renders state *about* pages and never draws or tints a glyph.
- **eng-rtl-and-bidi-layout** — locale numerals, FSI/PDI bidi isolation, and RTL grid mirroring for cells, labels, and the weakest-page badge.
- **eng-create-riverpod-store** — the read model / `StreamProvider` over a Drift query that streams the heat-map state into the widget.
- **eng-add-feature-module** — where the Progress feature's `widgets/` heat-map leaf and its goldens live.
- **domain-adab-and-religious-integrity** — the calm, non-coercive, no-scoreboard, servant-to-teacher copy and adab of every label and the no-celebration rule.
- **eng-write-dart-test** — the per-locale RTL / CVD / offline golden harness on the real bundled fonts.
