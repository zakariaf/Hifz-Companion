# E15-T07 — Weakest-juz / weakest-pages list, tappable into the detail sheet

| | |
|---|---|
| **Epic** | [E15 — Progress & Heat-map](EPIC.md) |
| **Size** | S (≈0.5-1 day) |
| **Depends on** | E15-T05, E15-T06 |
| **Skills** | ui-page-card, domain-adab-and-religious-integrity, eng-rtl-and-bidi-layout |

## Goal

A calm, informational **"where to look first" list** joins the Progress surface: the weakest juz / weakest pages from the E15-T01 read model, rendered weakest-first as tappable rows that open straight into the E15-T06 page-detail sheet. Each row composes E10's page-card anatomy — "Page N · Juz M" in locale numerals, the track chip, the calm decay indicator — and the whole list is the **fully non-visual textual equivalent** of the heat-map's weak signal: a screen-reader or colour-blind ḥāfiẓ reaches exactly the same facts through this list that a sighted user reads off the grid (09-accessibility §4). The list **surfaces the weak link, never smooths it** (08-data-visualization §6; PRD §10.3) — but its register is help, not judgment: no "behind", "failing", or "overdue", no red, no ranking. E15-T05 carries the same weak-link signal *on* the grid (tile colour + badge); this task carries it as a separate scannable *list*; neither recomputes anything — both read E15-T01.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §12.5 | The verbatim Progress spec this task ships: "weakest pages list" alongside per-juz/per-page health and the forecast; tap-through to page detail; **no streaks-as-pressure** anywhere on the surface |
| `docs/PRD.md` §10.3 | The min-leaning rule the list embodies: juz health "surfaces the weakest link" because "one weak page is what fails you in ṣalāh"; roll-ups are **computed from `card.R`**, never stored — and never re-derived in a widget |
| `docs/PRD.md` §7.12 | The engine invariant the list's framing must not violate: the app never displays or implies a page is safe to stop revising — a page *absent* from this list is "not the weakest today", never "done" |
| `docs/design-system/08-data-visualization.md` §6 | The honest-aggregate contract: the weak link is surfaced, not smoothed; the weakest page(s) are named explicitly so the user can go straight there from the overview; no future contributor "improves" the signal into a prettier average |
| `docs/design-system/08-data-visualization.md` §5 | Redundant encoding: state is carried by a localized value + a plain label, never colour alone and never a vague word standing alone; embedded numbers are FSI/PDI-isolated inside the RTL label run |
| `docs/design-system/08-data-visualization.md` §8 | The no-scoreboard posture: this list is situational awareness ("where is my Quran today"), never a punishment surface for a missed day and never a comparative ranking |
| `docs/design-system/09-accessibility-and-inclusivity.md` §4 | The load-bearing accessibility role: "the **text-based weakest-pages list** (PRD §12.5) as a fully non-visual equivalent" of the heat-map — a screen-reader user reaches the same facts through the list and per-cell labels without ever seeing a colour |
| `docs/design-system/09-accessibility-and-inclusivity.md` §7 | Localized semantic labels in fa/ckb/ar; each row merged (`MergeSemantics`) into **one** spoken phrase; decoration excluded; per-run `locale` so the reader picks the right voice |
| `docs/design-system/09-accessibility-and-inclusivity.md` §8 | RTL accessibility: focus and reading order **are** the visual order (right-to-left, top-to-bottom); embedded LTR runs bidi-isolated so they neither display nor *read* out of order; the trailing chevron mirrors (directional icon) |
| `docs/design-system/12-localization-and-rtl.md` §3, §4 | FSI/PDI isolation via ARB placeholders (never a spliced substring); numerals via `intl` bound to the locale — Extended Arabic-Indic fa/ckb, Arabic-Indic ar, never raw ASCII digits |
| Skill `ui-page-card` (+ `template.dart`) | The row anatomy this list composes: leading track chip + calm decay indicator (labels, not targets), headline "Page ۲۵۳ · Juz ۱۳" in `type.body` locale numerals, supporting band label in `type.caption`/`color.text.secondary`, one ≥48dp `touch.min` tap per row, `MergeSemantics` one phrase, **never** raw `R`/a percentage/"safe to drop" on the row |
| Skill `domain-adab-and-religious-integrity` (the conscience pass) | The release-blocking floor: no guilt/fear/loss copy, no "behind"/"failing"/"overdue", no ranking or scoreboard framing, never "safe to drop"/"mastered"/"done"; calm loss-prevention register; every string transcreated + banned-phrase lint per locale |
| Skill `eng-rtl-and-bidi-layout` | Logical start/end insets only, the icon-mirror policy for the row chevron, FSI/PDI isolation mechanics, locale-numeral rendering of every page/juz run |
| `docs/science/CLAIMS.md` — **C-019** | The warrant behind never softening the list: a strong page never becomes "done" — only continued retrieval keeps it; the list may say "look here first", never "the rest is safe" |
| `docs/science/CLAIMS.md` — **C-044** | The framing claim: progress is **self-referential** — a calm map of *your* Quran, informational competence feedback, never a ranking against others; the list orders pages by need, it awards no rank, medal, or score |
| Sibling **E15-T01** | Supplies the read model this list renders verbatim: per-page `R` + decay band and the min-leaning juz roll-up, already **ordered/orderable weakest-first**, computed on read via the injected engine + `Clock`; this task consumes the streamed slice, it computes nothing |
| Sibling **E15-T05** | Owns the **visual** weak-link signal on the grid (min-leaning tile colour + weakest-page badge); this task is the **textual** face of the same T01 facts — the two must agree by construction because neither recomputes |
| Sibling **E15-T06** | Owns the page-detail sheet a row taps into (range-in-words + basis, next-due, `review_log` history) and the "open in the reader" handoff to E13 *inside* the sheet; this task only routes to it |
| Sibling **E15-T09** | Owns the Progress-wide empty/first-run state; this task ships only the list's own quiet nothing-weak-right-now line, which must stay neutral and defer to T09's surface framing |
| Sibling **E15-T10** | Consumes this task's per-locale goldens (RTL + greyscale/deuteranope + offline) into the consolidated Progress golden suite |
| Skills (out of scope here) **E10 mihrab-component-library** | Owns the page-card leaf's anatomy/states/goldens and the `numberFormatFor(locale)` primitive; this task *composes* the leaf into a list — it does not build leaf anatomy |

## Implementation notes

This task is presentation-only: no engine call, no `DateTime.now()`, no Drift query, no write path. It renders an already-ordered slice of the E15-T01 read model and pushes the E15-T06 sheet. The copy is correctness-critical for adab → the calm-framing invariants are pinned test-first by widget tests + the banned-phrase lint before visuals are polished.

1. **Files** (in the `features` umbrella package, `lib/src/progress/`, per eng-add-feature-module): `widgets/weakest_pages_list.dart` — a dumb stateless `WeakestPagesList` taking the read model's weakest-first slice (weakest juz + their weakest pages) and an `onPageTap` callback; no state of its own, no engine, no clock. Wire it into `progress_screen.dart` below the T03 grid (a labelled section, scrollable with the screen, never a competing scroll region).
2. **Ordering is the read model's, verbatim.** The list renders pages exactly in the order T01 supplies (weakest-first by the same min-leaning facts the T05 tiles show). Do **not** sort, filter, threshold, or re-derive `R`/bands in the widget — a reordered fake read model must render reordered, byte-for-byte. If the section shows a bounded slice, the cutoff is the read model's, not the widget's; the widget renders what it is handed.
3. **Rows compose the E10 page-card** (ui-page-card): leading track chip + decay indicator as non-interactive labels, headline "Page N · Juz M" in locale numerals, supporting line = the plain decay-band label (e.g. "needs revision") in `type.caption`/`color.text.secondary`, trailing mirrored chevron. The row shows the band **label**, never raw `R`, a percentage, or a rank number — exact values live behind the tap in T06 (08-data-visualization §5's number+label redundancy is satisfied by the row label + the sheet's range-in-words).
4. **One tap, one destination.** The whole row is a single ≥48dp `touch.min` target that opens the E15-T06 detail sheet for that page (via the ViewModel/`go_router`, so a fake router can record the push). The "open in the reader" (E13) handoff is **inside** T06's sheet — this task adds no second target to the row and never navigates to the reader directly.
5. **Calm framing copy.** The section header reads as orientation help — "where to look first" register — informational and self-referential (C-044). Banned anywhere in this task's strings: "behind", "failing", "overdue", "falling", "at risk", "safe to drop", "mastered", "done", any comparative/rank word, any `!`. Style with neutral tokens on a flat surface — **no** `color.semantic.error`/alarm-red, no warning iconography; a weak page is "ready for revision", not an emergency (08-data-visualization §8).
6. **The list is the non-visual equivalent — treat that as a requirement, not a bonus.** Every fact the grid encodes in colour must be reachable here as text: each row is `MergeSemantics`-merged into one localized phrase ("Page ۲۵۳, Juz ۱۳, far-revision, needs revision") in the active locale with the correct `TextDirection`; the section header is announced; decorative dividers are `ExcludeSemantics` (09-accessibility §4, §7).
7. **Nothing-weak state stays quiet.** When the read model surfaces no weak pages, render one calm neutral line (an ARB key, e.g. `progressWeakestNoneLine`) — never a celebration, badge, "all green!", or any "mastered/done" phrasing (C-019; PRD §7.12). The Progress-wide empty/first-run surface is T09's, not this line.
8. **Strings via the ARB pipeline, transcreated for fa/ckb/ar** (eng-add-localized-string): the section header, row band labels (reusing existing E10/T04 keys where they already exist — never fork a duplicate), and the nothing-weak line are `l10n.*` keys in `app_ar.arb` (base) + transcreated `fa`/`ckb` (ckb pending native+scholar review); any count goes through ICU `plural` (ar's six categories); no hardcoded user-facing string.
9. **Numerals + bidi + RTL by geometry** (eng-rtl-and-bidi-layout; 12-localization §3–§4): every page/juz number renders via `numberFormatFor(locale)` in the locale digit set; the "Page N · Juz M" run is FSI/PDI-isolated as ARB placeholders; `EdgeInsetsDirectional`/`AlignmentDirectional` only; focus/reading order follows the RTL visual order (09-accessibility §8); the chevron mirrors, the decay glyph does not.
10. **Pitfalls to avoid:** sorting/thresholding/recomputing `R`, bands, or the aggregate in the widget (T01 owns every health number); smoothing — hiding a weak page because its juz "looks fine overall" (the whole point is the opposite: 08 §6); adding rank numerals, medals, or a "top offenders" framing (it's a reading order, not a leaderboard — C-044); a percentage or raw `R` on the row; alarm-red or warning icons on weak rows; a second tap target (chip, indicator, or an inline "open reader" button); navigating to E13 directly from the row; a celebration or "all done/mastered" phrasing in the nothing-weak state; splicing ASCII digits or un-isolated Latin runs into the localized row; `left`/`right` insets.

## Acceptance criteria

- [ ] `progress/widgets/weakest_pages_list.dart` exists in the `features` package as a dumb stateless widget taking the pre-ordered T01 slice + a tap callback; it contains no engine call, no `DateTime.now()`, no Drift/repository access, and no sort/filter/threshold over health values (verifiable by grep + a reorder test).
- [ ] The rendered order is exactly the read model's weakest-first order; a fake read model with a scrambled explicit order renders in precisely that order.
- [ ] Each row composes the E10 page-card anatomy (track chip + decay indicator as labels, "Page N · Juz M" headline in locale numerals, band-label supporting line, mirrored chevron); the whole row is one ≥48dp target and no raw `R`/percentage/rank number appears on any row.
- [ ] Tapping a row opens the E15-T06 detail sheet for that page (a fake router/observer records the push); no row navigates to the reader directly and no second target exists inside a row.
- [ ] The section header and all list copy pass the calm-framing floor: no "behind"/"failing"/"overdue"/"at risk"/"safe to drop"/"mastered"/"done", no comparative or rank word, no `!`; no `color.semantic.error`/alarm iconography anywhere in the section.
- [ ] Each row is announced as **one** merged localized phrase in fa/ckb/ar; the screen-reader traversal of the section follows the RTL visual order; the section carries every fact the grid's weak signal carries, in text.
- [ ] The nothing-weak state renders a single calm neutral line with no celebration, badge, or completion phrasing.
- [ ] Every user-facing string is an `l10n.*` ARB key present in fa/ckb/ar (ckb flagged pending native+scholar review); counts use ICU `plural`; every page/juz number renders in the locale digit set, FSI/PDI-isolated; layout uses logical insets only and ckb's longer copy reflows without truncation.

## Tests

All deterministic, offline by construction (this surface opens no socket), real bundled fonts, seeded fake read models (no engine, no clock). Test-first on the ordering and copy/adab invariants.

- `features/test/progress/weakest_pages_list_test.dart` (widget) — **written first**:
  - a fake read model with an explicit scrambled weakest-first order renders rows in exactly that order (pins "the widget never re-sorts");
  - a mostly-strong juz whose single rotting page the fake model surfaces still shows that page — the weak link is never smoothed away;
  - tapping a row records a push of the T06 detail route/sheet for that page id in a fake router; the chip and indicator are not independently tappable; each row meets ≥48dp;
  - no row text matches a percentage/raw-`R` pattern; weak rows use no `color.semantic.error`.
- `features/test/progress/weakest_pages_copy_test.dart` (unit) — runs the never-ship banned-phrase lint over every ARB value this task adds in fa/ckb/ar ("behind"/"failing"/"overdue"/"at risk", guilt/fear/loss words, "safe to drop"/"mastered"/"done", rank/comparison words, `!`, emoji) and fails on any hit; pins that the nothing-weak line exists and carries no completion claim.
- `features/test/progress/weakest_pages_semantics_test.dart` (widget) — per locale (fa/ckb/ar): each row exposes exactly one merged `Semantics` node whose label contains the localized page, juz, track, and band words in the locale digit set; semantic traversal order matches the RTL visual order; decorative dividers expose no node.
- `features/test/progress/weakest_pages_golden_test.dart` (golden) — per-locale (fa/ckb/ar) goldens of the populated list (including a surfaced single-weak-page row) and the nothing-weak line, on real bundled fonts; ckb-reflow golden proves no truncation; these goldens feed the consolidated E15-T10 suite (greyscale/deuteranope + offline harness lives there).
- Offline guard: the suite runs under an `HttpOverrides` that fails any socket open (eng-write-dart-test).

## Definition of Done

- [ ] All acceptance criteria met; the ordering and copy/adab tests were written first and are green; the per-locale goldens run in CI on the real bundled fonts and are handed to E15-T10.
- [ ] **Offline / no-network**: the list renders streamed read-model state only — no fetch, no socket; the `HttpOverrides` guard passes (PRD C1).
- [ ] **No AI / no microphone**: nothing here records, transcribes, or infers; the list is a static informational surface over deterministic engine output (PRD C2).
- [ ] **Quran text fidelity (R1)**: the list renders no Quran glyph and re-typesets nothing — rows name pages by number/juz only; the muṣḥaf appears solely in the E13 reader, reached via T06's sheet.
- [ ] **Never "safe to drop" / never smoothed (§7.12, §10.3; C-019)**: the weakest link is always surfaced — a single rotting page in a strong juz still appears; absence from the list is never framed as "done"; the nothing-weak line makes no completion or "mastered" claim; the reorder + single-weak-page tests pin it.
- [ ] **No gamification / no shame (R3, C6; C-044)**: the list is self-referential orientation, never a ranking, leaderboard, or scoreboard — no rank numerals, medals, scores, or comparative copy; weak rows carry no alarm-red or warning icon; the banned-phrase lint passes in all three locales.
- [ ] **The View is dumb**: every health number, band, and the weakest-first order come from the E15-T01 read model (engine + injected `Clock`, computed on read); the widget reads the streamed slice, never calls the engine, never reads `DateTime.now()`, never sorts or thresholds.
- [ ] **RTL + fa/ckb/ar localization**: every string ships through the ARB pipeline (ar template + fa/ckb, transcreated, ckb flagged pending native+scholar review); locale numerals via `intl`, mixed runs FSI/PDI-isolated; logical insets only; the chevron mirrors and the decay glyph does not; ckb reflows without truncation.
- [ ] **Accessibility (WCAG 2.2 AA)**: this list *is* the heat-map's fully non-visual equivalent (09-accessibility §4) — every grid fact reachable as text; one merged localized phrase per row (SC 1.4.1 satisfied without colour); reading/focus order matches the RTL visual order; ≥48dp targets; the per-screen accessibility audit passes.
- [ ] **Sect-neutral adab**: all copy cleared the adab conscience pass — calm loss-prevention register, no guilt/fear/loss, no fiqh ruling, no app-as-authority phrasing; scholarly review flagged where required.
- [ ] **Deterministic tests**: all tests use seeded fake read models and no hidden clock or network; goldens are byte-stable on the pinned fonts; all gates stay green.
