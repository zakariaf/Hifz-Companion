# references — ui-page-card

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. The page card is *chrome* about a page — its track and its decay — and it never draws a glyph of the muṣḥaf, never shows a number to chase, and never frames a page as "safe to drop."

## Primary

- `docs/design-system/07-components.md` §2 (The page card: one muṣḥaf page, the atomic row) — **The whole anatomy:** one page = one row on the M3 list-item shape (leading / headline / supporting / trailing) as a flat `ListTile`/`Card` at elevation Level 0–1. Leading = track chip + decay indicator as *labels, not separate tap targets*; headline = "Page N · Juz M" in locale numerals (`type.body`); supporting = optional next-due/weak hint (`type.caption`, `color.text.secondary`); trailing = chevron. State (default/weak/due-today/pulled-forward/done/locked) drives only border/surface emphasis + the indicator, never the page art. The whole row is one ≥48dp tap; `MergeSemantics` reads it as one localized phrase. Never render Quran glyphs, never surface D/S/R or a "safe to drop" score, never raise the card on a shadow.

- `docs/design-system/07-components.md` §3 (The track chip: the visible name of the tradition) — **The chip is a non-interactive label, the single carrier of Pillar 3:** a label-only `Chip`/styled `Container` in `type.label`, `space.1` glyph-to-text, at the row start. It names the lifecycle phase (FAR/manzil, NEAR/sabqi, NEW/sabaq) by pairing a tradition-tied color family (manzil = `color.accent.green` maintenance core) with a **regional term-set string** — never baked-in English, never color alone, never alarm-red, never a count/XP/streak/badge. ckb's longer terms wrap, not truncate. For screen readers it is part of the row's merged label, not a separate node.

- `docs/design-system/07-components.md` §4 (The decay indicator: honest, redundant, never an alarm) — **The per-row echo of the heat-map, triple-encoded:** a tiny swatch + glyph ≤ `space.4` at the row start (after the chip) encoding the same fact three ways — single-hue lightness ramp (`color.heatmap.strong` → mid → `color.heatmap.faded`) + glyph (filled/half/hollow) + text label ("solid"/"holding"/"needs revision"). The level derives from the engine's `R` (min-leaning), but the **number is never shown**. It ranges only solid → needs-revision: **no** "safe to drop"/"mastered" state, **no** red/amber danger, **no** downward arrow, **never** color alone.

- `docs/design-system/07-components.md` §6 (Grade band & component states: one explicit state model) — **States are M3 state layers over a role color, never ad-hoc opacity:** any pressed/disabled/focused/selected emphasis on the card uses the uniform M3 state model with a **visible focus ring** (`color.outline`) for keyboard/switch-control users (WCAG 2.2 SC 2.4.7); states mirror correctly under RTL and are announced via `Semantics` flags. A disabled/quiet state reads as *waiting*, never as broken.

- `docs/design-system/03-color-and-themes.md` §5 (The retention heat-map: single-hue lightness ramp, green receding to neutral) — **The decay indicator's color values and ramp grammar:** ordered page health maps to a **sequential single-hue lightness ramp** (`color.heatmap.strong` … `color.heatmap.faded`), monotonic in luminance, green receding to a **muted neutral** — never red→green, never an alarm-red scoreboard. Each step is redundantly encoded (color + number/label); the row consumes the *strong→faded* tokens by name and never inlines the hex.

- `docs/design-system/03-color-and-themes.md` §2 (Green is the base hue — reverent ground, never reward) — **Why the card stays flat and un-celebrated:** green is *quiet reverent ground* and the "strong" end of the ramp — never a "success green," a streak color, a celebration, or a tint laid over glyphs. Token names read as **states, not trophies** (`color.heatmap.strong`, not `color.success`); the card never flashes green to celebrate a page or a juz.

- `docs/design-system/03-color-and-themes.md` §6 (A small semantic set — and what color is *not* allowed to mean) — **Weak / missed / late is not an alarm state:** the *weak* card uses a quiet `color.semantic.warning` outline + a calm hint, never an alarm-red; there is deliberately **no `color.semantic.danger`** and **no `color.semantic.success`** for routine hifz state. Semantic color is always paired with an icon + text, never load-bearing alone.

- `docs/design-system/09-accessibility-and-inclusivity.md` §4 (Color-independence is a hard requirement) — **Color is never the only channel (SC 1.4.1):** ~8% of men have red-green CVD, so the track chip and the decay indicator each pair color with a glyph and/or a text label; meaning survives grayscale and deuteranope simulation. Verified by simulation in the release gate.

- `docs/design-system/09-accessibility-and-inclusivity.md` §7 (Screen readers: every control a localized semantic label) — **Merge the row into one spoken phrase:** wrap the page-card in `MergeSemantics` so "Juz ۷ · page ۱۳۴ · weak" is read as one node, not three fragments; `ExcludeSemantics` for decoration; each run carries its `locale` (fa/ckb/ar) so the reader voices it correctly; a missing or English-only label is a release blocker.

## Supporting

- `docs/design-system/09-accessibility-and-inclusivity.md` §6 (Touch targets) — **The whole row is one ≥48×48dp / 44×44pt tap target**, with the chip/indicator as labels inside it, not pinpoint sub-targets; enforced by `androidTapTargetGuideline` / `iOSTapTargetGuideline` / `labeledTapTargetGuideline` in CI.

- `docs/design-system/09-accessibility-and-inclusivity.md` §3 (Contrast floors) — **Non-text graphical objects ≥ 3:1, re-audited per appearance:** the decay swatch's glance-critical anchor (`color.heatmap.strong`) clears 3:1 in Light/Sepia/Dark/Night; lower ramp steps sit below 3:1 *by design* only because the glyph + label co-carry the value (the values live in `03` §7).

- `docs/design-system/09-accessibility-and-inclusivity.md` §8 (RTL accessibility: focus/reading order = visual order) — **The row's leading slot sits at the visual start (right) and the chevron at the end (left)**, with focus/reading order following the RTL visual order; the "Page N · Juz M" run is bidi-isolated and locale-tagged so it both *looks* and *reads* right.

- `docs/design-system/03-color-and-themes.md` §3 (Four reading appearances) — **The decay/chip encoding is identical across Light, Sepia, Dark, Night:** the ramp is re-toned per appearance but the encoding (color + glyph + label) and the min-leaning meaning are invariant; the row is verified in all four.

## Sibling skills

- **ui-today-session-list** — the finite, capped, tradition-ordered (Far → Near → New) list container and its loading/all-done/catch-up states; this skill owns the *row* it renders, not the list (`07-components.md` §1).
- **ui-recite-grade-flow** — the full-screen reveal-on-tap + four-level Again/Hard/Good/Easy grade band, the sacred-text guard, and the teacher sign-off the row taps into (`07-components.md` §5, §7).
- **ui-heatmap-cell** — the `GridView` retention cell (ramp, VSUP uncertainty muting, min-leaning juz roll-up) that the row's decay indicator is the per-row echo of (`07-components.md` §8; `08-data-visualization.md`).
- **domain-scheduling-engine-rules** — the schedule, track assignment, FSRS D/S/R, `R`, trust clamp, and the release-blocking "never safe to drop" honesty the row reads but never re-derives.
- **domain-mushaf-text-integrity** — the immutable Uthmani QPC glyph page the row never draws or re-typesets.
- **eng-rtl-and-bidi-layout** — the per-locale numerals, FSI/PDI bidi isolation of the headline run, and directional-icon mirroring the row uses.
- **eng-add-feature-module** — the `widgets/` leaf folder, the domain→row mapping, and the widget/golden tests where this row lives.
- **domain-adab-and-religious-integrity** — the calm, servant-to-teacher, no-gamification, no-guilt copy and adab of every label on the card.
- **eng-write-dart-test** — the per-locale RTL/state golden harness on the real bundled fonts (never `Ahem`) plus the deuteranope/contrast checks.
