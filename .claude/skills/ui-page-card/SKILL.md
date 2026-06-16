---
name: ui-page-card
description: Build or modify the Hifz Companion page card — the one-muṣḥaf-page tile/row used in the Today list and the heat-map detail — together with its non-interactive track chip (sabaq/sabqi/manzil, localized) and its calm decay indicator. Use whenever placing a page tile/row, the leading track chip, the per-page decay indicator (shape + glyph + label, never color alone), or any list row that names a page by number + juz in locale numerals.
---

# ui-page-card

The page card is the recurring atomic row of the app: it represents **exactly one muṣḥaf page** (the scheduled unit, 604 cards), carrying — in the muṣḥaf's own RTL reading order — a **leading** track chip + decay indicator, a **headline** of localized page/juz identity in locale numerals, an optional **supporting** line (next-due or weak hint), and a **trailing** chevron into the recite flow. It is a `ListTile`/`Card` at elevation Level 0–1; it **never renders Quran glyphs itself** and **never shows the engine's internal D/S/R or a percentage score**.

This row is the surface where Pillar 3 (*tradition is the interface* — the day looks like sabaq/sabqi/manzil, the algorithm is invisible) and Pillar 4 (*honest about decay* — nothing silently rots, never "safe to drop") become visible. The track chip names the lifecycle phase in the teacher's own word; the decay indicator says how solid the page is using **shape + glyph + label**, never hue alone. One row = one tap into recitation.

## When to use

Use this skill when building or placing:

- a **page-card row** in the Today daily-session list (`docs/design-system/07-components.md` §2) or as a heat-map drill-down detail row;
- the **track chip** — the small non-interactive label that names a card's track (sabaq / sabqi / manzil, localized) (`docs/design-system/07-components.md` §3);
- the **decay indicator** — the per-row honest-decay swatch (strong / holding / needs-revision), encoded as color **+ glyph + label** (`docs/design-system/07-components.md` §4);
- the page-card's **state emphasis** (default / weak / due-today / pulled-forward / done / locked) where state drives only border/surface emphasis and the decay indicator, never the page art.

Do **NOT** use this skill for — use the sibling instead:

- the **daily-session list container** itself (the finite, capped, Far→Near→New section ordering, the all-done / catch-up states) → use **ui-today-session-list**; this skill owns the *row*, not the list.
- the **recite/grade flow** the row taps into (reveal-on-tap, the four-level Again/Hard/Good/Easy band, the sacred-text guard, teacher sign-off) → use **ui-recite-grade-flow** + **domain-grading-pipeline**.
- the **retention heat-map cell** as a `GridView` component (the ramp, VSUP-style uncertainty muting, min-leaning juz roll-up) → use **ui-heatmap-cell** + `docs/design-system/08-data-visualization.md`.
- the **immutable QPC glyph rendering** of any Quran text — the row never draws a glyph → use **domain-mushaf-text-integrity**.
- the **schedule itself** (which page is due, the track assignment, `due_at`, FSRS D/S/R, the trust clamp, "never safe to drop" engine semantics) → use **domain-scheduling-engine-rules**; the row *reads* the result, it never re-derives it.
- **per-locale numerals, bidi isolation of the "Page N · Juz M" run, and RTL mirroring mechanics** → use **eng-rtl-and-bidi-layout**; this skill only requires you *use* them.
- the **calm, non-coercive, servant-to-teacher copy and adab** of every label on the row → use **domain-adab-and-religious-integrity**.

The page card is a **label that taps into recitation** — it is not a control panel. A row whose chip or indicator is separately tappable, or that shows a number to chase, is the wrong component.

## The canonical pattern

1. **One page = one row, built on the M3 list-item anatomy.** The card represents exactly one muṣḥaf page (the natural scheduling unit, because serial recall is order-dependent), realized as a Flutter `ListTile`/`Card` at elevation **Level 0–1** with the four logical slots — leading, headline, supporting, trailing (`docs/design-system/07-components.md` §2, *Statement* + *In practice* slot table). The card is flat: no decorative shadow, no brand-color tint to "pop" — Quran content stays reverence-first and calm (`docs/design-system/07-components.md` §2 *Evidence*; `docs/design-system/03-color-and-themes.md` §2, green is reverent ground never reward). Reference elevation/surface via tokens; never inline a hex or a `pt`.

2. **The leading slot is a label cluster, never a second tap target.** At the row **start** (right, in RTL) sits the track chip then the decay indicator, `space.2` apart — both are *labels inside the row*, not separate interactive controls, so there is one unambiguous tap per row into the recite flow (`docs/design-system/07-components.md` §2 slot table + *In practice*: "the chip and indicator inside it are labels, not separate tappable controls"; recognition over recall). Use `EdgeInsetsDirectional` / logical start/end for placement (`eng-rtl-and-bidi-layout`).

3. **Headline + supporting in locale numerals, bidi-isolated.** The headline is the localized "Page ۲۵۳ · Juz ۱۳" string in `type.body`; the optional supporting line ("next: in ۳ days" / "weak line ۷") is `type.caption` in `color.text.secondary` (`docs/design-system/07-components.md` §2 slot table). Numerals render in the locale set — Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar — and the mixed Latin/numeral run is bidi-isolated (FSI/PDI) so the row never breaks alignment or reads "30 of 7" (`docs/design-system/07-components.md` §2 *In practice*; numeral + isolation mechanics via **eng-rtl-and-bidi-layout**). Strings come from `AppLocalizations`; no hardcoded literal.

4. **The track chip is a non-interactive label that names the tradition.** Render it as a label-only `Chip` (or a styled `Container` with the same metrics) at the row start, inheriting `type.label`, with `space.1` between glyph and text, never exceeding the row's vertical rhythm (`docs/design-system/07-components.md` §3 *Statement* + *In practice*). It pairs a **tradition-tied color family with its text label** — FAR/manzil uses the `color.accent.green` maintenance family, NEAR/sabqi a secondary neutral-tinted family, NEW/sabaq a tertiary neutral-tinted family (`docs/design-system/07-components.md` §3 track table; concrete values owned by `docs/design-system/03-color-and-themes.md`). The label is a **regional term-set string** (المراجعة البعيدة / مرور دور / مەنزڵ), switchable per region, never a baked-in English glyph; ckb's longer terms wrap, never truncate sacred-adjacent vocabulary (`docs/design-system/07-components.md` §3 *In practice*).

5. **The chip carries color AND text — never color alone, never an alarm hue.** Every track pairs its color family with its localized text, satisfying color-independence for ~8% of men with red-green CVD (`docs/design-system/07-components.md` §3 *Anti-patterns*; `docs/design-system/09-accessibility-and-inclusivity.md` §4, SC 1.4.1). Manzil green is **maintenance, not danger** — no track uses an alarming red, and the chip never gains a count, XP, streak, or stacked badge (`docs/design-system/07-components.md` §3 *Anti-patterns*; `docs/design-system/03-color-and-themes.md` §6, no semantic alarm-red for routine hifz state).

6. **The decay indicator is honest, triple-redundant, never an alarm.** Render a tiny custom-painted swatch + glyph at the row start (after the chip), no larger than `space.4`, so it stays a quiet indicator not a gauge (`docs/design-system/07-components.md` §4 *In practice*). It encodes the same fact **three ways** — a **single-hue lightness ramp** (`color.heatmap.strong` → mid → `color.heatmap.faded`) + a **glyph** (filled / half / hollow) + a **text label** ("solid" / "holding" / "needs revision") (`docs/design-system/07-components.md` §4 level table; `docs/design-system/03-color-and-themes.md` §5, single-hue green→neutral ramp). Color is never the sole channel (`docs/design-system/09-accessibility-and-inclusivity.md` §4).

7. **The decay level derives from `R` but the number is never shown.** The three calm bands roll up from the engine's retrievability `R` (computed on read, min-leaning like juz health) — but the user reads "needs revision," **never** "R = 0.83" or a percentage (`docs/design-system/07-components.md` §4 *In practice*; `docs/design-system/03-color-and-themes.md` §5, redundant number/label carries the value, color reinforces). The indicator ranges only from *solid* to *needs-revision* — it has **no** "safe to drop," "mastered," or "you can stop revising" state; that honesty contract is release-blocking (`docs/design-system/07-components.md` §4 *Anti-patterns*; `domain-scheduling-engine-rules`).

8. **State drives emphasis and the indicator — never the page art.** Card state (*default* `surface`; *weak* → a quiet `color.semantic.warning` outline + weak hint in supporting text, never an alarm; *due-today*; *pulled-forward* shown identically to any due item with no "the algorithm chose this" exposure; *done* a checked, dimmed, removable row; *locked* a small lock affordance for a teacher's `manual_lock` override) changes only border/surface emphasis and the decay indicator (`docs/design-system/07-components.md` §2 *In practice* states list). Decay and the weak state use calm neutral / warning tokens, **never** an alarm-red shame signal (`docs/design-system/03-color-and-themes.md` §6, missed/weak is never alarm-red). Any focus/pressed/disabled emphasis uses **M3 state layers over the role color**, with a visible focus ring (`color.outline`) for switch-control/keyboard users — never ad-hoc opacity (`docs/design-system/07-components.md` §6; `docs/design-system/09-accessibility-and-inclusivity.md` §3).

9. **The whole row is one ≥48dp hit target; the row reads as one merged phrase.** The row is a single `touch.min` (≥48dp / 44pt) tap into the recite flow; the chip and indicator are not separate targets (`docs/design-system/07-components.md` §2 *In practice*; `docs/design-system/09-accessibility-and-inclusivity.md` §6, target-size floor). Wrap the row in `MergeSemantics` so a screen reader hears **one** localized phrase — "Page ۲۵۳, Juz ۱۳, far-revision, needs revision" — in the active locale (`fa`/`ckb`/`ar`), the leading glyphs announced as **words**, decorative dividers excluded with `ExcludeSemantics` (`docs/design-system/07-components.md` §2/§3/§4 *In practice* semantics notes; `docs/design-system/09-accessibility-and-inclusivity.md` §7, merge into one node + localized label; `eng-rtl-and-bidi-layout` for the per-run locale tag).

10. **No glyphs, no scores, no gamification on the row.** The card **never** renders a Quran glyph or re-typesets an āyah for a preview — the muṣḥaf appears only in the immutable reader/recite surface (`docs/design-system/07-components.md` §2 *Anti-patterns*; **domain-mushaf-text-integrity**). It never surfaces D/S/R, a percentage, or "safe to drop"; state is shown as track + decay only (`docs/design-system/07-components.md` §2/§4 *Anti-patterns*). No streak, badge, score, confetti, or celebratory tint appears anywhere on the card — these are forbidden non-negotiables, not preferences (`docs/design-system/03-color-and-themes.md` §2/§6; **domain-adab-and-religious-integrity**). RTL by construction, offline by construction, no AI/no audio — the row reads, it never fetches, records, or infers.

## Do / Don't

| Do | Don't |
|---|---|
| Build the row as a flat `ListTile`/`Card` at elevation Level 0–1 with leading/headline/supporting/trailing slots | Raise the card on a decorative shadow or tint it with brand color to "pop" |
| Keep the chip + decay indicator as labels *inside* one row; one ≥48dp tap into recite | Make the track chip or decay indicator a second tappable target inside the row |
| Render "Page ۲۵۳ · Juz ۱۳" in locale numerals (`type.body`), bidi-isolated (FSI/PDI) | Splice raw ASCII digits into the localized run, or let the mixed run reorder ("30 of 7") |
| Pair every track with its color family **and** its localized term-set label | Encode a track by color alone, or hardcode the track name in English / one dialect |
| Use the manzil `color.accent.green` family as *maintenance*; neutral-tinted families for near/new | Use an alarming red for any track, or add a count/XP/streak/badge to the chip |
| Encode decay three ways: single-hue lightness ramp + glyph + text label, ≤ `space.4` | Show decay as red/amber danger, a downward arrow, a falling-grade animation, or color alone |
| Derive the decay band from `R` (computed on read, min-leaning) and show only "solid…needs revision" | Expose `R`, a D/S/R number, a percentage, or ever a "safe to drop" / "mastered" state |
| Drive *weak* with a quiet `color.semantic.warning` outline + a calm hint in supporting text | Render a weak/missed/late page in alarm-red as a shame signal |
| Use M3 state layers over the role color + a visible focus ring (`color.outline`) | Invent per-component opacity for states, or ship a row with no visible focus indicator |
| `MergeSemantics` the row into one localized phrase; `ExcludeSemantics` decoration | Read the row as disconnected fragments, or leave the leading glyphs unlabeled |
| Reference `color.*` / `type.*` / `space.*` / `touch.min` tokens by name; logical start/end | Inline hex / pt / dp, or hard-code left/right inside the row |
| Compose the muṣḥaf only in the reader; keep the row glyph-free | Render a Quran glyph or re-typeset an āyah preview inside the card |

## Checklist

Before this page card / chip / decay indicator is done:

- [ ] Row is a flat `ListTile`/`Card` (elevation Level 0–1), one per muṣḥaf page, with leading (chip + indicator) / headline / supporting / trailing slots; no decorative shadow, no brand-color tint.
- [ ] The track chip and decay indicator are non-interactive labels *inside* the row; the whole row is one ≥48dp / 44pt `touch.min` tap into the recite flow — never a second target.
- [ ] Headline "Page N · Juz M" and supporting hints render in locale numerals (Extended Arabic-Indic fa/ckb, Arabic-Indic ar), in `type.body` / `type.caption` + `color.text.secondary`, every mixed run bidi-isolated (FSI/PDI); strings from `AppLocalizations` (ar template, fa/ckb), no hardcoded literal.
- [ ] Track chip is a label-only `Chip`/styled `Container` in `type.label`, pairing a tradition-tied color family with a **regional term-set** label (sabaq/sabqi/manzil, switchable, ckb wraps not truncates); manzil green = maintenance, no alarm-red, no count/XP/streak/badge.
- [ ] Color is never the sole signal on the chip or the decay indicator — each pairs color with a glyph and/or text label (SC 1.4.1).
- [ ] Decay indicator encodes the same fact three ways — single-hue lightness ramp (`color.heatmap.strong`→`…faded`) + glyph (filled/half/hollow) + text label ("solid"/"holding"/"needs revision"), ≤ `space.4`, identical across light/sepia/dark and fa/ckb/ar.
- [ ] Decay band derives from `R` (computed on read, min-leaning); the raw `R` / D/S/R / a percentage is **never** shown; the indicator has **no** "safe to drop" / "mastered" / "stop revising" state.
- [ ] State (default/weak/due-today/pulled-forward/done/locked) drives only border/surface emphasis + the indicator, never the page art; *weak* uses a quiet `color.semantic.warning` outline + calm hint, never alarm-red; pulled-forward looks identical to any due item.
- [ ] Interaction states use M3 state layers over the role color with a visible focus ring (`color.outline`); states mirror correctly under RTL and are announced via `Semantics` flags.
- [ ] Row is wrapped in `MergeSemantics` and announced as one localized phrase ("Page ۲۵۳, Juz ۱۳, far-revision, needs revision") in the active locale with the correct `TextDirection`; decoration is `ExcludeSemantics`.
- [ ] All design comes from tokens referenced by name (`color.*` / `type.*` / `space.*` / `touch.min`); no inline hex/pt/dp; logical start/end only, no hard-coded left/right; verified in fa/ckb/ar.
- [ ] No Quran glyph is rendered and no āyah is re-typeset inside the row (the muṣḥaf lives only in the reader); no streak/badge/score/confetti/celebratory tint anywhere on the card.
- [ ] Offline / no-AI / no-audio by construction: the row reads streamed state only — it never fetches, records, infers, or recomputes a schedule/`due_at`; copy and adab follow **domain-adab-and-religious-integrity**.
- [ ] Widget + golden tests cover the row in all six states across fa/ckb/ar on the **real** bundled UI fonts (never `Ahem`), with `androidTapTargetGuideline` / `labeledTapTargetGuideline` and a grayscale/deuteranope check that the decay band is still readable (**eng-write-dart-test**).

The page card makes an honest, calm claim about a page — its track and its decay — and nothing more. If a row ever tempts you toward a score, a streak, a percentage, an alarm-red, or "safe to drop," that is the non-negotiables being violated, not a missing feature. The standard is *iḥsān*, because the work is built free, *lillāh*.

## Files

- `template.dart` — copy-paste scaffold: the domain-blind `DecayIndicator` and `TrackChip` leaf widgets (color + glyph + label, tokens by name), the feature-layer `PageCard` mapping a domain `ReviewItem` → row slots with `MergeSemantics` and locale-numeral/bidi-isolated headline, and the per-locale RTL/state golden test stub — with `// TODO` markers and every token/rule referenced by name.
- `references.md` — the exact governing doc sections that own this row, each with the one thing to take from it, and the sibling skills.

Related skills: **ui-today-session-list** (the finite, capped, Far→Near→New list container these rows sit in), **ui-recite-grade-flow** (the reveal-on-tap + four-level grade flow the row taps into), **ui-heatmap-cell** (the `GridView` retention cell this row's decay indicator echoes), **domain-scheduling-engine-rules** (the schedule / track / `R` / "never safe to drop" logic the row reads but never re-derives), **domain-mushaf-text-integrity** (the immutable QPC glyph layer the row never draws), **eng-rtl-and-bidi-layout** (locale numerals, bidi isolation, and mirroring for the headline + chip), **eng-add-feature-module** (where the row's `widgets/` leaf and its goldens live), **domain-adab-and-religious-integrity** (the calm, servant-to-teacher, no-gamification copy and adab of every label on the card), **eng-write-dart-test** (the per-locale RTL/state golden harness on real fonts).
