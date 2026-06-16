# 08 — Data Visualization

This file specifies the one chart that matters in Mihrab: the **whole-Quran retention heat-map** on the Progress screen, plus the small honest visuals around it (per-juz health, the upcoming-load forecast, the simple review history). It owns the *visual grammar* of those displays — how strength is encoded, how decay is made visible without alarm, how an uncertain estimate is shown as uncertain, how every cell stays legible in greyscale and to a colour-blind ḥāfiẓ, and the hard rule that this surface is never a streak, a score, or a scoreboard. It owns **no token values**: every colour it names (`color.heatmap.strong … color.heatmap.faded`, `color.accent.green`, the neutrals) is defined once in [03-color-and-themes.md](03-color-and-themes.md), every spacing and tap-target (`space.*`, `touch.min`) in [05-layout-spacing-touch.md](05-layout-spacing-touch.md), and the numeral/calendar formatting and grid direction in [12-localization-and-rtl.md](12-localization-and-rtl.md). The contrast floor and screen-reader semantics are gated in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md); the "never gamify worship" thesis is in [01-design-principles.md](01-design-principles.md) and [11-voice-and-tone.md](11-voice-and-tone.md). The heat-map is, per the PRD, the app's central emotional surface — *"keep your Quran green"* (PRD §12.5) — and the literal embodiment of Pillar 4, *honest about decay; nothing silently rots* ([README Pillar 4](README.md); PRD §7.12, R3). This document keeps that surface honest. The deep evidence dossier is [research/data-visualization-heatmap-uncertainty.md](research/data-visualization-heatmap-uncertainty.md).

## At a glance

| Decision | What we ship | Owning section |
|---|---|---|
| Encoding | A **cluster heat-map**: 604 pages grouped by 30 juz, read in one glance | §1 |
| Interaction | **Overview → zoom → details-on-demand** (whole Quran → juz → page) | §1 |
| Colour scale | **Single-hue lightness ramp** of the base green; never rainbow, never red→green | §2, §3 |
| Decay | Visible (green *recedes* to muted neutral), **never alarming red** | §3 |
| Uncertainty | VSUP-style **muting** of low-confidence / un-reviewed pages | §4 |
| Redundancy | Every state encoded **colour + number + label**; never colour alone | §5 |
| Aggregation | Juz roll-up **leans to the weakest page**, never the average | §6 |
| Layout | **Muṣḥaf order, RTL**, faithful small multiples — not an inventive chart | §7 |
| Framing | Honest situational awareness — **never a streak, score, or scoreboard** | §8 |

---

## 1. The whole-Quran heat-map is the surface; numbers live behind a tap

**Statement.** The Progress screen leads with a **cluster heat-map of the entire Quran** — all 604 pages, grouped into the 30 juz the ḥāfiẓ already holds in mind — shaded so the whole corpus reads in one glance. The exact numbers (a page's retrievability, its due date, its history) are **details-on-demand behind a tap**, never on the face of the grid. The interaction is the canonical *overview first → zoom and filter → details on demand*: whole Quran → tap a juz → tap a page.

**Evidence.**
- The retention display is a *cluster heat map* of a well-established kind — a rectangular tiling where each tile is shaded to encode one value — and its defining virtue is that "a dense grid of color-coded cells lets the eye take in a large matrix at once and find structure," which is "the most widely used of all bioinformatics displays" precisely for that reason ([Wilkinson & Friendly, 2009, *The American Statistician*](https://www.datavis.ca/papers/HeatmapHistory-tas.2009.pdf)). For 604 pages whose individual values nobody can hold in mind, "whole corpus at a glance" *is* the requirement.
- The interaction model is Shneiderman's **Visual Information-Seeking Mantra — "overview first, zoom and filter, then details-on-demand"** ([Shneiderman, 1996, *IEEE Symposium on Visual Languages*](https://www.cs.umd.edu/~ben/papers/Shneiderman1996eyes.pdf)). It maps one-to-one onto the screen: the whole-Quran heat-map is the overview, a juz tap is the zoom, a page tap reveals exact strength/due/history (PRD §12.5).
- The pattern is platform-proven and consumer-familiar — the GitHub-style contribution calendar is the same grid, and a Flutter port exists ([`flutter_heatmap_calendar`](https://github.com/devappmin/flutter_heatmap_calendar); pattern origin [react-calendar-heatmap](https://github.com/kevinsqi/react-calendar-heatmap)). The design work is in the *scale* and the *framing*, not the mechanism.

**In practice.**
- The Progress screen opens on the heat-map, not a stats table: overview is the default, numbers are a tap away (PRD §12.5). Tapping a juz expands its ~20 pages; tapping a page opens the detail sheet with retrievability, next-due date, and a short history from `review_log` (PRD §10.2).
- Tiles meet `touch.min` (48dp) so a juz/page is tappable on the daily-use surface ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)); the grid uses `space.*` gutters, not hairline gaps, so juz blocks read as the small-multiple unit (§7).
- The forecast and history beside the map are equally restrained: an *upcoming-load* forecast (how many pages are due over the coming days, so a user can plan) and a plain `review_log`-derived history (PRD §12.5) — informational, not a performance dashboard.
- RTL note (fa/ckb/ar): the overview→detail flow is direction-agnostic, but the grid itself lays out start→end under `Directionality.rtl` so a "hot spot" sits where that juz sits in the muṣḥaf (§7; [12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Lead the Progress screen with a number-dense table or a KPI dashboard; the muṣḥaf-shaped overview comes first, exactness on tap.
- Estimate a page's exact strength from its shade — colour is the gestalt, the tapped number is the truth (§5).
- Decorate the grid with a chart type chosen for novelty; the heat-map is the right encoding and we keep it (§7).

---

## 2. Strength is a single-hue lightness ramp of the base green

**Statement.** Page and juz health are encoded by a **sequential, single-hue lightness ramp** — `color.heatmap.strong` through `color.heatmap.faded`, monotonic in luminance — where a strong page reads as the calm base green and a decaying page fades toward a muted neutral. Strength is *ordered* data, so it gets an *ordered* encoding carried by **lightness, not hue**.

**Evidence.**
- A retention value is ordered (more strength → less strength), which calls for a **sequential** scheme whose defining property is that **lightness steps dominate** — light for low, dark for high — so the ramp is read as a monotonic order; ColorBrewer's single-hue sequential schemes (Greens, Greys) work exactly this way, holding one hue and varying chroma + luminance together ([Brewer, Hatchard & Harrower, 2003, *Cartography and Geographic Information Science*](https://www.tandfonline.com/doi/abs/10.1559/152304003100010929); [Harrower & Brewer, 2003, *The Cartographic Journal*](https://www.tandfonline.com/doi/abs/10.1179/000870403235002042)).
- A single-hue lightness ramp gives three properties we need at once: it is unambiguously *ordered* (no "is teal more or less than orange?" guessing), it *survives greyscale*, and it *survives colour-vision deficiency*, because the order is carried by luminance, not hue ([Borland & Taylor, 2007, *IEEE CG&A*](https://doi.org/10.1109/MCG.2007.323435)).
- The choice of green for the strong anchor is not arbitrary brand colour: green is the most religiously resonant hue *and* one of the most measurably calm, the rare convergence documented in [03-color-and-themes.md §2](03-color-and-themes.md) ([Jonauskaite & Mohr, 2025, *Psychonomic Bulletin & Review*](https://pmc.ncbi.nlm.nih.gov/articles/PMC12325498/)).

**In practice.**
- The ramp values live only in [03-color-and-themes.md §5](03-color-and-themes.md): `color.heatmap.strong → good → fair → weak → faded`, monotonic in relative luminance in both Light and Dark, so magnitude order survives greyscale and CVD. This file references them by name and never restates a hex.
- Tokens are named as **states, not trophies** — `color.heatmap.strong`, never `color.success` — so "your Quran, kept green" reads as one calm idea, not a reward (Pillar 2; [03-color-and-themes.md §2](03-color-and-themes.md)).
- The strong anchor is the same green family as `color.accent.green`, so the heat-map's "healthy" end and the app's interactive tint are visibly one idea; the decaying end is a *neutral*, not a second hue (§3).
- RTL note: lightness encoding is script- and direction-independent; the ramp is identical in fa/ckb/ar and under `Directionality.rtl`.

**Anti-patterns — we will never:**
- Encode health on a hue axis (e.g. teal↔amber) where order must be looked up in a legend; order is carried by lightness.
- Add a second hue to the ramp "for resolution" unless it comes from a verified perceptually-uniform family (§3) — never a hand-picked gradient.
- Re-tone the ramp so the steps are no longer monotonic in luminance; greyscale and CVD legibility depend on that monotonicity ([03-color-and-themes.md §5](03-color-and-themes.md)).

---

## 3. Decay is made visible, never alarming — no rainbow, no red scoreboard

**Statement.** The decaying end of the ramp is a **desaturated, muted neutral**, and the heat-map carries **no saturated red and no rainbow/jet colormap**. Decay is shown by the green *receding* — honestly visible, so nothing rots silently — but never as an alarm-red grid that reads as a failing scoreboard. The app makes the invisible visible without making it frightening.

**Evidence.**
- The rainbow/jet colormap "confuses viewers through its lack of perceptual ordering, obscures data through its uncontrolled luminance variation, and actively misleads … through the introduction of non-data-dependent gradients" — it is unordered and invents false boundaries, the opposite of an honest health encoding ([Borland & Taylor, 2007, *IEEE CG&A*](https://doi.org/10.1109/MCG.2007.323435)). The later, careful nuance that rainbow maps have a few expert niche uses does not rescue them for a calm, lay-audience, single-variable display ([Ware, Stone, Szafir & Rhyne, 2023, *IEEE CG&A*](https://doi.org/10.1109/MCG.2023.3246111)).
- Keeping saturated red off the grid is colour *science*, not taste: in the color-in-context framework red carries learned threat meaning and, in achievement/evaluation contexts, primes **avoidance motivation** ([Elliot & Maier, 2014, *Annual Review of Psychology*](https://pmc.ncbi.nlm.nih.gov/articles/PMC4383146/)); red also "captures and holds attention specifically in emotionally-valenced contexts" ([Kuniecki, Pilarczyk & Wichary, 2015, *Frontiers in Human Neuroscience*](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4413730/)). Combined with the rule that arousal rises strongly with saturation ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001); [03-color-and-themes.md §1](03-color-and-themes.md)), a grid of saturated-red "rotting" pages would do exactly the two things the PRD forbids — spike anxiety and frame revision as fear-driven avoidance (PRD §7.12, R3).
- There is a real temptation to make the map scary, because loss-framed incentives can boost short-term effort — people were *less* motivated by a gain to accrue than by the identical incentive framed as a loss to avoid ([Goldsmith & Dhar, 2013, *J. Experimental Psychology: Applied*](https://pubmed.ncbi.nlm.nih.gov/24059820/)). But avoidance-framed, anxiety-driven goals are associated with increased stress and decreased wellbeing, and for an app built as *ṣadaqah* whose thesis is *peace of mind, not engagement farming* (PRD §6-C6; [01-design-principles.md](01-design-principles.md)), trading the user's tranquillity for an effort bump is the wrong bargain.

**In practice.**
- The decaying end is `color.heatmap.weak` → `color.heatmap.faded`, a muted neutral, not a red ([03-color-and-themes.md §5](03-color-and-themes.md)); a most-decayed or never-reviewed page reads as *quiet*, not *injured*.
- The map is paired with maintenance framing, never loss framing: a decaying page is "ready for revision," and a gap is met by the calm catch-up banner ("You missed 3 days — here is a 5-day catch-up plan"), never a red overdue pile (PRD §7.9, §14; [11-voice-and-tone.md](11-voice-and-tone.md)).
- No multi-hue gradient ships without verification: if a second hue is ever genuinely needed for resolution at the dark end, it must come from a **perceptually-uniform, CVD-safe** family — viridis/cividis, where equal data steps map to equal perceived steps and the scale "increases in brightness linearly" and stays legible under red-green colour blindness ([Nuñez, Anderton & Renslow, 2018, *PLOS ONE*](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0199239); [viridis vignette, CRAN](https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html)) — never chosen by eye. For our single-variable case the one green ramp (§2) is preferred.
- RTL note: framing copy is transcreated, not literally translated, per locale, so "ready for revision" reads naturally in fa/ckb/ar and never as blame ([11-voice-and-tone.md](11-voice-and-tone.md)).

**Anti-patterns — we will never:**
- Use a red→amber→green "traffic light," a rainbow/jet colormap, or any hand-picked multi-hue gradient for page health.
- Render the decay end as a saturated, alarming red, or any encoding that reads as a failing scoreboard or a broken streak.
- Frame decay as loss ("you are losing your Quran") to wring out short-term effort; the honest, calm framing is quiet maintenance.

---

## 4. An uncertain estimate looks uncertain — VSUP-style muting

**Statement.** A retention value is a **prediction, not a measurement**, so a page the engine is *not sure about* — one seeded from a cold-start prior and never yet recited, or graded only by a low-confidence self-rating — renders **muted/greyed**, and saturates toward full health-green only as confident reviews (especially teacher sign-offs) accumulate. Confidence is encoded in the *vividness* of the cell, so an uncertain page literally looks less definite.

**Evidence.**
- The number the app would show is a model output: retrievability `R` predicted by the FSRS-style curve from priors and self-ratings the PRD itself flags as low-confidence (`sourceConfidence ≈ 0.5`, PRD §7.3, §8.1). Presenting that as a crisp "87%" is **false precision**; the uncertainty-visualization literature is consistent that surfacing uncertainty rather than hiding it improves decisions and trust, and that hiding it backfires when the point estimate is later wrong.
- The mechanism made for a heat-map is the **Value-Suppressing Uncertainty Palette (VSUP)**: rather than fighting value and uncertainty as two channels, a VSUP *suppresses the value signal (collapses toward grey) where uncertainty is high*, and a crowdsourced study found this makes people **weight uncertainty more heavily and decide more cautiously** ([Correll, Moritz & Heer, 2018, *CHI '18*](https://doi.org/10.1145/3173574.3174216)). For us this is almost literal: an unconfident page is muted; a teacher-confirmed page (`sourceConfidence = 1.0`) is vivid.
- This is the *visual* analogue of the PRD's conservative-priors rule — priors deliberately under-estimate strength so the first real recitation can only pleasantly surprise upward (PRD §7.10). Muting an un-reviewed page is honesty, not pessimism: it says "we have not heard this yet," exactly matching the engine's own caution.

**In practice.**
- Two confidence inputs drive the muting: (a) whether the page has had a real review at all (cold-start prior vs. recited), and (b) the source confidence of its most recent grades (self-rating ≈ 0.5 vs. teacher sign-off = 1.0; PRD §8). A never-recited page renders at `color.heatmap.faded`-grey regardless of its optimistic-looking prior; a page carried only by self-ratings reads less saturated than a teacher-confirmed one.
- The detail sheet states uncertainty in words too, never a bare percent: "estimated — not yet recited," or a retrievability *range* with the basis ("from self-rating") rather than a false-precise single figure (§5).
- This is consistent with the calibration-pass design: the early "light pass" that reviews every held page once (PRD §7.10) is *visibly* what turns the map from muted to confident, so the user sees uncertainty resolve as they recite.
- RTL note: vividness/saturation is direction- and script-independent; the muted state renders identically in fa/ckb/ar.

**Anti-patterns — we will never:**
- Render a cold-start prior or a shaky self-rating as a confident, fully-saturated green — that would manufacture false certainty the engine does not have.
- Show a crisp single percentage for a prediction without its basis or range; the estimate is shown as the estimate it is (§5).
- Let a single self-rating push a page to the most-confident, most-saturated tier — confidence grows with confirmed reviews, mirroring the engine (PRD §8.1).

---

## 5. Every state is encoded redundantly — colour and number and label

**Statement.** No cell or detail ever conveys its state by **colour alone**. Each carries its meaning in at least one non-colour channel as well — a localized retrievability value, a plain text label, and where helpful a texture/pattern for the decaying end — so the heat-map is fully legible in greyscale, to a colour-blind ḥāfiẓ, and to a screen reader. And a likelihood is never communicated by a vague word standing alone.

**Evidence.**
- About 8% of men have red-green colour-vision deficiency, and **WCAG 2.2 SC 1.4.1 (Use of Color) forbids colour as the only means of conveying information**, while **SC 1.4.11 sets a 3:1 contrast floor for graphical objects / non-text UI** like heat-map tiles and their boundaries ([W3C: WCAG 2.2](https://www.w3.org/TR/WCAG22/); [WebAIM: Contrast and Color Accessibility](https://webaim.org/articles/contrast/)). A tile must therefore carry its state in a value, label, texture, or tap-through detail too.
- Honesty about likelihood points the same way: verbal probability words ("likely," "weak") are interpreted with wide, person-specific, overlapping meanings, biased toward 50/50, and are only pinned down when paired with a number or range. So "weak" on a page must come with a concrete retrievability range and a due date, never stand alone.
- The two rules reinforce each other: **encoding every state redundantly — lightness *and* a number *and* a label — is simultaneously the colour-blind-safe design and the honest one** (PRD §18).

**In practice.**
- Each cell/detail carries a **localized number** (retrievability as a percentage in the locale numerals — Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar, via `intl`, never raw ASCII; PRD §13.3) and a **plain label** ("strong," "softening," "ready for revision"), with colour as reinforcement, not the message (PRD §12.5, §18; [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- Tile contrast posture follows the audit in [03-color-and-themes.md §7](03-color-and-themes.md): `color.heatmap.strong` clears the **3:1** non-text floor (SC 1.4.11) so the glance-critical anchor reads against the page; the lower steps intentionally sit below 3:1 because they appear only inside labelled, tap-through cells where the number and label carry the value — so SC 1.4.1 is satisfied and the graphical-object minimum applies to the at-a-glance anchor, not the atmosphere cells.
- An optional **texture/pattern** on the decaying end gives a third, fully colour-independent channel for the most important distinction (healthy vs. decaying); screen-reader semantics announce the value and label in the active locale ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).
- RTL note: the cell's number sits inside its tile with bidi isolation (FSI/PDI) so a Latin range or page number never reorders inside the RTL label run ([12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Let colour be the sole signal of a cell's state, or rely on a colour key the user must memorize to read the grid.
- Print a bare "weak" with no retrievability range and no due date, or a percentage in raw ASCII digits inside a localized string.
- Drop the 3:1 contrast on the glance-critical strong anchor in any appearance ([03-color-and-themes.md §7](03-color-and-themes.md)).

---

## 6. The juz roll-up leans to the *weakest* page — the honest aggregate

**Statement.** A juz tile's colour is a **roll-up of its pages that leans to the weakest one** — a min-leaning aggregate — not a mean. A single rotting page must be able to "fail" its juz's colour (or surface a weakest-page badge), because one weak page is what fails you in ṣalāh. Aggregation method here is not cosmetic; it is the difference between an honest display and one that lies by smoothing.

**Evidence.**
- The PRD specifies the rule directly: juz/ḥizb health is computed from `card.R` with a **min-leaning aggregate** — "one weak page is what fails you in ṣalāh — surface the weakest link" (PRD §10.3). The visualization rationale is that a mean over ~20 pages would let one strong-average juz hide a single rotting page — exactly the silent-decay failure the whole product exists to prevent (PRD §7.12).
- This is the visualization face of Pillar 4 and the PRD's hard invariant that the engine never displays or implies a page is "safe to stop revising" (PRD §7.12; [README Pillar 4](README.md)). An averaging roll-up would quietly break that invariant at the chart layer even while the engine honoured it.
- It also respects the reading-accuracy evidence behind §7: because shade is a *low-accuracy* channel for exact values ([Cleveland & McGill ranking, via 03-color-and-themes / research note]), the juz colour must err toward surfacing a problem, with the exact weak page available on tap — not average the problem into invisibility.

**In practice.**
- The juz tile colours toward its weakest constituent page (min-leaning), and the detail sheet names the weakest page(s) explicitly so the user can go straight there from the overview (PRD §10.3, §12.5).
- Where a juz is mostly strong but holds one decaying page, a small **weakest-page badge** on the tile makes the single weak link visible without recolouring the whole juz misleadingly — honesty without alarm (§3).
- This is documented as a deliberate, load-bearing choice so no future contributor "improves" the roll-up into a mean for a prettier, greener map; the roll-up is min-leaning by design and that is a release expectation (PRD §10.3, §20).
- RTL note: the badge sits at the logical *start* of the tile under `Directionality.rtl`, mirrored with the rest of the grid ([12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Roll a juz up by an average (or any aggregate) that lets one strong-average juz hide a single rotting page.
- Hide the weakest page behind a reassuring green juz tile; the weak link is surfaced, not smoothed.
- Optimize the roll-up to make the overall map look greener at the cost of honesty about a decaying page.

---

## 7. Lay the grid out in muṣḥaf order, RTL — faithful small multiples, not an inventive chart

**Statement.** The grid mirrors the structure the ḥāfiẓ already holds — **juz → pages, in muṣḥaf order, laid out right-to-left** — so a hot spot's *spatial position is its location in the Quran*. It is built as **faithful small multiples**: once the user learns to read one juz block, all thirty are instantly legible. Calm, ordered, and consistent over clever; the muṣḥaf is rendered faithfully and never gamified.

**Evidence.**
- Two perception results discipline the layout. Cleveland & McGill's ranking of elementary perceptual tasks puts **position along a common scale as the most accurately decoded channel, with colour saturation/shading far down the list** — so shading is fine for the at-a-glance gestalt (§1) but a low-accuracy channel for reading an exact value, which is why exactness lives behind a tap, not in a shade (established in the [research note](research/data-visualization-heatmap-uncertainty.md); [03-color-and-themes.md](03-color-and-themes.md)).
- Tufte's **small-multiples** principle: once the user learns to read one juz block, all thirty are instantly legible at no extra cognitive cost ([Tufte, *The Visual Display of Quantitative Information*, via Small multiple, Wikipedia](https://en.wikipedia.org/wiki/Small_multiple)). Consistency, not novelty, is the design value.
- Faithful Quran order, laid out RTL, means the position of a "hot spot" *is* its place in the muṣḥaf (PRD §13.2), and keeps faith with adab — the muṣḥaf's structure is honoured, not re-imagined into a clever infographic ([README Pillar 1](README.md); [research/islamic-app-design-patterns.md](research/islamic-app-design-patterns.md)).

**In practice.**
- The grid is 30 juz blocks in order, each block its pages in order, flowing **start→end under `Directionality.rtl`** so juz 1 / page 1 sits where a ḥāfiẓ expects the beginning of the muṣḥaf, and the eye reads the corpus the way the script reads (PRD §13.2; [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- The juz block is the learned unit (small multiple): consistent size, gutter (`space.*`), and internal page order, so thirty blocks need only one act of learning ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)).
- No re-typesetting, no ornament: the heat-map visualizes *state about* pages; it never renders or decorates the sacred glyphs — markers and overlays on the actual muṣḥaf page are governed separately and drawn over the immutable glyph layer, never here (PRD R1; [03-color-and-themes.md §2](03-color-and-themes.md)).
- adab note (all locales): the layout is identical in fa/ckb/ar; faithfulness to muṣḥaf order is intent-and-presentation, not a per-locale skin.

**Anti-patterns — we will never:**
- Reorder the grid by "weakness" or any metric so it no longer maps to muṣḥaf position; spatial order *is* Quran order.
- Replace the faithful grid with a clever chart (treemap, radial, packed bubbles) that breaks the learned juz→page small-multiple and the RTL reading order.
- Render or decorate the sacred glyphs in the visualization layer; the heat-map shows state, never the typeset Quran (PRD R1).

---

## 8. The heat-map is situational awareness — never a streak, score, or scoreboard

**Statement.** The heat-map's only job is **honest situational awareness** — "where is my Quran today" — so nothing rots silently. It is **never** a streak, a points score, a leaderboard, a "100% green!" celebration, or a punishment for a missed day. The emotional pull is the quiet wish to *keep one's Quran green*, achieved through calm maintenance, not fear or competition.

**Evidence.**
- Gamifying worship is forbidden by the product (no leaderboards, XP, badges, confetti, or streak nags; PRD R3, C6) and by the motivation science behind it: a meta-analysis of 128 experiments found tangible extrinsic rewards reliably **undermine** intrinsic motivation, while only informational positive feedback helps ([Deci, Koestner & Ryan, 1999, *Psychological Bulletin*](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)). A streak or a score on revision is precisely the extrinsic, controlling pressure that backfires.
- Negative, loss-framed displays can boost short-term effort but are tied to increased stress and decreased wellbeing ([Goldsmith & Dhar, 2013](https://pubmed.ncbi.nlm.nih.gov/24059820/); §3) — the wrong trade for a tool whose explicit thesis is peace of mind, not engagement (PRD §6-C6; [calm-non-gamified-design.md](research/calm-non-gamified-design.md)).
- Controlling, commanding framing also provokes psychological reactance and can boomerang, whereas calm, autonomy-supportive framing persuades without backfiring ([Miller et al., 2007, *Human Communication Research*](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)) — so the map must inform, never pressure.

**In practice.**
- There is no streak counter on or near the heat-map, no "best day," no points, no leaderboard; any continuity indicator is **opt-in, private, and non-punitive** (PRD §12.5). A missed day changes the map honestly (some green recedes) but triggers no shame UI — the response is the calm catch-up plan, not a red mark ([11-voice-and-tone.md](11-voice-and-tone.md); PRD §7.9).
- Completing a juz or session produces **no confetti, no celebratory green flash, no badge on an ayah** — celebration of worship is gamification (PRD R3; [03-color-and-themes.md §2](03-color-and-themes.md), [06-motion-and-haptics.md](06-motion-and-haptics.md)).
- "Keep your Quran green" is the *quiet* hook the PRD names (PRD §12.5): the desire is intrinsic (your own Quran, kept whole), surfaced by honest awareness, never manufactured by a score the app can take away.
- adab note (all locales): the no-scoreboard rule is universal across fa/ckb/ar; it is a property of the product's relationship to worship, not a regional preference.

**Anti-patterns — we will never:**
- Add a streak, points score, leaderboard, level, or any competitive/comparative metric to the Progress surface.
- Celebrate a completed juz/session with confetti, a green flash, a badge, or a sound; honest awareness, not reward.
- Punish a missed day with a red mark, a broken-streak graphic, or guilt copy; lateness is met with a calm catch-up plan, never blame (PRD §7.9, R3).

---

## References

- Borland, D., & Taylor, R. M., II. (2007). Rainbow Color Map (Still) Considered Harmful. *IEEE Computer Graphics and Applications*, 27(2), 14–17. https://doi.org/10.1109/MCG.2007.323435
- Brewer, C. A., Hatchard, G. W., & Harrower, M. A. (2003). ColorBrewer in Print: A Catalog of Color Schemes for Maps. *Cartography and Geographic Information Science*, 30(1), 5–32. https://www.tandfonline.com/doi/abs/10.1559/152304003100010929
- Correll, M., Moritz, D., & Heer, J. (2018). Value-Suppressing Uncertainty Palettes. *Proceedings of the 2018 CHI Conference on Human Factors in Computing Systems (CHI '18)*, 1–11. https://doi.org/10.1145/3173574.3174216
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation. *Psychological Bulletin*, 125(6), 627–668. https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- devappmin. *flutter_heatmap_calendar* — a heat-map calendar for Flutter inspired by GitHub's contributions chart (open-source library, accessed 2026-06-16). https://github.com/devappmin/flutter_heatmap_calendar
- Elliot, A. J., & Maier, M. A. (2014). Color Psychology: Effects of Perceiving Color on Psychological Functioning in Humans. *Annual Review of Psychology*, 65, 95–120. https://pmc.ncbi.nlm.nih.gov/articles/PMC4383146/
- Goldsmith, K., & Dhar, R. (2013). Negativity bias and task motivation: testing the effectiveness of positively versus negatively framed incentives. *Journal of Experimental Psychology: Applied*, 19(4), 358–366. https://pubmed.ncbi.nlm.nih.gov/24059820/
- Harrower, M., & Brewer, C. A. (2003). ColorBrewer.org: An Online Tool for Selecting Colour Schemes for Maps. *The Cartographic Journal*, 40(1), 27–37. https://www.tandfonline.com/doi/abs/10.1179/000870403235002042
- kevinsqi. *react-calendar-heatmap* — an SVG calendar heatmap inspired by GitHub's contribution graph (open-source library, accessed 2026-06-16). https://github.com/kevinsqi/react-calendar-heatmap
- Kuniecki, M., Pilarczyk, J., & Wichary, S. (2015). The color red attracts attention in an emotional context. An ERP study. *Frontiers in Human Neuroscience*, 9, 212. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4413730/
- Miller, C. H., Lane, L. T., Deatrick, L. M., Young, A. M., & Potts, K. A. (2007). Psychological Reactance and Promotional Health Messages. *Human Communication Research*, 33(2), 219–240. https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x
- Nuñez, J. R., Anderton, C. R., & Renslow, R. S. (2018). Optimizing colormaps with consideration for color vision deficiency to enable accurate interpretation of scientific data. *PLOS ONE*, 13(7), e0199239. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0199239
- Shneiderman, B. (1996). The Eyes Have It: A Task by Data Type Taxonomy for Information Visualizations. *Proceedings of the IEEE Symposium on Visual Languages*, 336–343. https://www.cs.umd.edu/~ben/papers/Shneiderman1996eyes.pdf
- Tufte, E. R. (1983/2001). *The Visual Display of Quantitative Information* — origin of the "small multiples" principle (summary via Small multiple, Wikipedia, accessed 2026-06-16). https://en.wikipedia.org/wiki/Small_multiple
- Valdez, P., & Mehrabian, A. (1994). Effects of color on emotions. *Journal of Experimental Psychology: General*, 123(4), 394–409. https://psycnet.apa.org/record/1995-08699-001
- Ware, C., Stone, M., Szafir, D. A., & Rhyne, T.-M. (2023). Rainbow Colormaps Are Not All Bad. *IEEE Computer Graphics and Applications*, 43(3), 88–93. https://doi.org/10.1109/MCG.2023.3246111
- viridis (Garnier, S., et al.). *Introduction to the viridis color maps* (package vignette, accessed 2026-06-16). CRAN. https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
- W3C (2023, updated 2024). *Web Content Accessibility Guidelines (WCAG) 2.2* — SC 1.4.1 Use of Color; SC 1.4.11 Non-text Contrast. https://www.w3.org/TR/WCAG22/
- WebAIM. *Contrast and Color Accessibility — Understanding WCAG 2 Contrast and Color Requirements* (accessed 2026-06-16). https://webaim.org/articles/contrast/
- Wilkinson, L., & Friendly, M. (2009). The History of the Cluster Heat Map. *The American Statistician*, 63(2), 179–184. https://www.datavis.ca/papers/HeatmapHistory-tas.2009.pdf
- Jonauskaite, D., & Mohr, C. (2025). Do we feel colours? A systematic review of 128 years of psychological research linking colours and emotions. *Psychonomic Bulletin & Review*. https://pmc.ncbi.nlm.nih.gov/articles/PMC12325498/
