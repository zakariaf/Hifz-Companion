---
name: ui-daily-session-list
description: Build or modify the Hifz app's Today "revise today" surface — the finite, time-budget-capped daily revision list grouped Far (manzil) → Near (sabqi) → New (sabaq) in recitation order, its page-card rows, its calm all-done / catch-up states, and the honest budget-feedback line. Use whenever building the Today screen, the daily revision list/queue, the grouped due-pages list, the section headers, the catch-up banner, or the budget-feedback copy.
---

# ui-daily-session-list

The Today screen's core surface: a single **finite, capped** list that tells a ḥāfiẓ exactly what to revise today and then **ends**. It is grouped into the three traditional tracks — **Far (manzil) → Near (sabqi) → New (sabaq)**, recited old-before-new — each row a **page card** (one muṣḥaf page), with a calm all-done terminal state, a re-spread catch-up banner after missed days, and one honest line of budget feedback. The spaced-repetition ordering inside each group is invisible; the grouping *is* the interface a teacher recognizes (Pillar 3). It is never a feed, never a count-up, never a red overdue pile.

This list IS the daily ritual surface — the one screen the user opens after ṣalāh. Calm content scrolls above; the tap into the recite flow lives in the thumb zone below.

## When to use

Use when building or placing:
- the Today screen's "revise today" list (the grouped, capped daily queue)
- the **Far → Near → New** section headers and their localized term-sets
- a **page-card row** (track chip + decay indicator + localized page/juz headline + chevron into recite)
- the **states** of this list: loading skeleton, populated, all-done terminal surface, catch-up banner
- the **honest budget-feedback line** (when the chosen scope can't fit the time budget)

Do NOT use this skill for:
- the page-card's track-chip / decay-indicator *visual internals* and the heat-map cell → use **ui-page-card-and-decay** (this skill places the row; that skill builds its anatomy and the decay encoding)
- the reveal-on-tap, the four-level Again/Hard/Good/Easy grade band, stumble-line tapping, teacher sign-off → use **ui-recite-grade-flow**
- the engine that *produces* the ordered, capped, load-balanced day (FSRS D/S/R, tracks, TRUST CLAMP, `loadBalance`) → use **domain-scheduling-engine-rules**
- the catch-up *re-spread algorithm* itself (the math behind the banner) → use **domain-scheduling-engine-rules**
- the controller/StreamProvider/single-write-path wiring behind this View → use **eng-create-riverpod-store** and **eng-add-feature-module**
- rendering any Quran glyph in a row → never; the muṣḥaf appears only in the recite/reader surface → **domain-mushaf-text-integrity**

The list is the *map of the day*; the recite flow is the *act*. A Today list that shows a percentage score, a streak, or an infinite scroll is the wrong surface.

## The canonical pattern

1. **Finite, capped, tradition-ordered — not a feed.** The list is a single bounded queue grouped **Far (manzil) → Near (sabqi) → New (sabaq)**, recited old-before-new, and it terminates. Never an infinite scroll, never a "for you" feed, never an ever-growing inbox, never a count-up of items completed. The cap is the user's daily **time budget**; the SR ordering *within* a track is invisible. `docs/design-system/07-components.md` §1 (the daily-session list is finite/capped/tradition-ordered, not a feed) and §1 Anti-patterns (never infinite scroll / never reorder the three sections); `docs/PRD.md` §12.2 (short, finite, capped list grouped Far → Near → New, in recitation order).

2. **Section headers carry the tradition's own vocabulary.** Render three sections as `ListView` slivers, each with a quiet header in `type.title`, separated by `space.6`; rows within a section sit `space.2` apart on the `space.*` grid. Section labels are **localized term-sets** (المراجعة البعيدة / مرور دور / مەنزڵ), switchable per region, never hardcoded English — the chip/label is the only place the lifecycle phase is named to the user. `docs/design-system/07-components.md` §1 In practice (slivers, `type.title` header, `space.6` separation, `space.2` rows; localized term-sets, never hardcoded English; manzil → near → new order is non-negotiable); `docs/PRD.md` §13.4 (regional term-sets).

3. **Each row is a page card — one page, one tap, no glyphs.** Every row represents exactly one muṣḥaf page and is a single ≥48dp `touch.min` hit target into the recite flow. In muṣḥaf RTL order it carries a **leading** track chip + decay indicator (labels, not separate tappable controls), a **headline** of localized "Page ۲۵۳ · Juz ۱۳" (locale numerals, bidi-isolated), an optional **supporting** line ("next: in ۳ days" / "weak line ۷"), and a **trailing** chevron. It **never renders Quran glyphs** and **never shows D/S/R, a percentage, or "safe to drop."** Build the chip/indicator internals via **ui-page-card-and-decay**; here you only place the row and wire its single tap. `docs/design-system/07-components.md` §2 (page-card anatomy: leading/headline/supporting/trailing, one ≥48dp tap, no glyphs, no internal numbers) and §2 Anti-patterns; `docs/design-system/05-layout-spacing-touch.md` §4 (one ≥48dp target per row; chip/indicator are labels not targets).

4. **Four list states, each calm.** Model exactly: *loading* (a brief `surfaceContainerLow` skeleton while the engine builds the day — no spinner theatre); *populated* (the grouped list); *all-done* (a calm closing surface, e.g. "Today's revision is complete," in `color.text.secondary` — informational, **never confetti / streak / badge / exclamation mark**); *catch-up* (after missed days, a gentle banner offering the re-spread plan, **never a red overdue pile**). `docs/design-system/07-components.md` §1 In practice (the four states) and §1 Anti-patterns (no celebration of all-done; no red shame-pile); `docs/PRD.md` §12.2 (catch-up banner with the re-spread plan, never a red shame-pile) + §7.9 (re-spread, never shame — the algorithm is **domain-scheduling-engine-rules**).

5. **Honest budget feedback — never silently let pages rot.** When the chosen scope can't fit the daily time budget, the list states it plainly and offers to **raise budget / lengthen cycle / pause new sabaq** — it never silently drops or decays pages, and FAR/manzil due items are never dropped. Render this as one calm informational line/affordance, autonomy-supportive (offers options, never commands), never an alarm. `docs/PRD.md` §12.2 (honest budget feedback: says so and offers raise budget / lengthen cycle / pause new sabaq; never silently lets pages rot) + §7.9 (FAR/manzil mandatory, never dropped); `docs/design-system/07-components.md` §1 Anti-patterns (degrade gracefully; never a shame-pile).

6. **RTL by geometry, not a mode.** Section headers and leading affordances (chip, decay indicator) sit at the **start** (right); chevrons at the **end** (left); everything via `EdgeInsetsDirectional` / `AlignmentDirectional`, never `left`/`right`. The one template serves fa/ckb/ar unchanged; ckb's longer transcreated section labels reflow within the same insets. Locale-numeral page strings keep mixed Latin/numeral runs bidi-isolated (FSI/PDI) so a row never breaks alignment. `docs/design-system/05-layout-spacing-touch.md` §3 (RTL is the layout's geometry: logical start/end, `EdgeInsetsDirectional`, leading at start / chevron at end, ckb reflow) and §3 In practice (bidi-isolated mixed runs); detailed bidi policy in **eng-rtl-and-bidi-layout**.

7. **Thumb-zone ergonomics; the tap is low.** Calm content scrolls in the upper/middle area; the primary daily action (begin / next-item tap) lives in the bottom band within one-handed thumb reach, with `space.4` padding above the M3 `NavigationBar` and a `SafeArea` inset. Rare/destructive controls (a settings shortcut) sit in the harder-to-reach top corner. `docs/design-system/05-layout-spacing-touch.md` §5 (Today template: finite Far→Near→New list scrolls; primary tap low in the thumb zone; settings shortcut top) and §5 In practice (bottom band `space.4` + `SafeArea`).

8. **One Semantics container, three ordered groups.** A `Semantics` container announces the list as "Revise today" with section roles, so a screen-reader user hears the three tracks as ordered groups in their locale; each row is read as one labelled item ("Page 253, Juz 13, far-revision, weak"), the leading glyphs announced as *words*, not decorations. `docs/design-system/07-components.md` §1 In practice (Semantics container: "Revise today", section roles, per-locale) and §2 In practice (the row read as one labelled item); enforced by **domain-** accessibility rules and **eng-rtl-and-bidi-layout**.

9. **No gamification anywhere on this surface.** No streaks, badges, scores, XP, completion %, confetti, or count-up. The all-done state confirms; it does not react. Decay is shown as the calm indicator (Pillar 2), never as a red danger arrow, and a page is **never** labelled "safe to drop" / "mastered." `docs/design-system/07-components.md` §1 / §2 / §4 Anti-patterns (no gamification; never "safe to drop"); `docs/PRD.md` §12.2, R3, C6; cross-checked by **domain-adab-and-religious-integrity**.

10. **The View is dumb; the day comes pre-built.** This View only renders the grouped, capped, ordered day the engine + controller already produced — it never sorts, caps, load-balances, or calls the engine itself, and it never reads `DateTime.now()` (the injected `CalendarDate`/`clockProvider` owns "today"). Every read is a `StreamProvider` over Drift; every mutation (a grade) flows through the single write path in the controller, not the widget. `docs/PRD.md` §7.9 (load-balancing/catch-up is the engine's job); wiring owned by **eng-add-feature-module**, **eng-create-riverpod-store**, **eng-define-service-boundary** (the injected clock).

## Do / Don't

| Do | Don't |
|---|---|
| Render a finite, time-budget-capped list grouped Far → Near → New, recited old-before-new, that **ends** | Make Today an infinite scroll, a "for you" feed, an ever-growing inbox, or a count-up of items completed |
| Keep section order manzil → near → new; label sections with localized term-sets | Reorder the sections, or hide the tradition behind a generic "due cards" list |
| Make each row one ≥48dp `touch.min` tap into the recite flow; chip + decay indicator are *labels* | Make the track chip or decay indicator a second tappable target inside the row |
| Show page identity as localized "Page ۲۵۳ · Juz ۱۳" (locale numerals, bidi-isolated) | Render Quran glyphs in the row, or re-typeset any āyah for a preview |
| Show state as track + calm decay band only | Surface D/S/R, a percentage "score," or a "safe to drop" / "mastered" state on a card |
| Give all-done a calm closing line in `color.text.secondary` (informational) | Celebrate all-done with confetti, a streak bump, a badge, or an exclamation mark |
| After missed days, show the gentle re-spread catch-up banner | Render a red overdue / shame-pile after a gap |
| State budget overflow honestly and offer raise budget / lengthen cycle / pause new sabaq | Silently let pages rot, or drop a FAR/manzil due item to fit the budget |
| Reference tokens by name: `type.title`, `type.body`, `type.caption`, `space.2`, `space.4`, `space.6`, `touch.min`, `color.text.secondary` | Hardcode 16dp / hex / a raw point size at the call site |
| Lay out with `EdgeInsetsDirectional` / `AlignmentDirectional`; leading at start, chevron at end | Write `EdgeInsets.only(left:)` / `Alignment.centerLeft`, or bolt on an "RTL mode" |
| Keep the primary tap low (thumb zone, `space.4` + `SafeArea`); settings/destructive top | Put the primary daily action in a top corner, or a destructive action in the easy-reach bottom |
| Render only the pre-built day; let the engine/controller cap, order, and load-balance | Sort/cap/load-balance in the widget, call the engine from the View, or read `DateTime.now()` |

## Checklist

Before this surface is done:

- [ ] The list is **finite and capped to the daily time budget** and visibly **ends** — no infinite scroll, no feed, no count-up of completed items.
- [ ] Sections are grouped and ordered **Far (manzil) → Near (sabqi) → New (sabaq)**, recited old-before-new; the order is never user-reordered away from this.
- [ ] Section headers use `type.title`, are separated by `space.6`, and carry **localized term-sets** (fa/ckb/ar), never hardcoded English; ckb's longer labels reflow within the same insets.
- [ ] Each row is a **page card** (one muṣḥaf page) and is a single ≥48dp `touch.min` tap into the recite flow; the track chip and decay indicator are labels, not separate tap targets (internals built via **ui-page-card-and-decay**).
- [ ] Rows show localized "Page N · Juz M" in locale numerals (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar), bidi-isolated so mixed runs never break row alignment; **no Quran glyphs** and **no D/S/R / percentage / "safe to drop"** appear on a card.
- [ ] All four states exist and are calm: *loading* (`surfaceContainerLow` skeleton, no spinner theatre), *populated*, *all-done* (calm closing line in `color.text.secondary`, no confetti/streak/badge/`!`), *catch-up* (gentle re-spread banner, no red shame-pile).
- [ ] When scope can't fit the budget, an **honest budget-feedback line** says so and offers **raise budget / lengthen cycle / pause new sabaq**; pages never silently rot and a FAR/manzil due item is never dropped to fit.
- [ ] Layout is RTL by geometry: `EdgeInsetsDirectional` / `AlignmentDirectional` only (no `left`/`right`), leading affordances at start, chevron at end; the one template serves fa/ckb/ar.
- [ ] The primary daily tap sits low in the thumb zone (`space.4` padding + `SafeArea` above the `NavigationBar`); the settings shortcut / destructive actions sit in the hard-to-reach top corner.
- [ ] A `Semantics` container announces "Revise today" with section roles; each row reads as one labelled item ("Page 253, Juz 13, far-revision, weak") in the user's locale — leading glyphs announced as words.
- [ ] **No gamification anywhere**: no streaks, badges, scores, XP, completion %, confetti; decay is the calm indicator, never a red arrow; nothing is ever "safe to drop" / "mastered".
- [ ] The View is **dumb**: it renders the engine/controller's pre-built, capped, ordered day; it never sorts/caps/load-balances, never calls the engine, never reads `DateTime.now()`; reads are `StreamProvider`s over Drift and grades flow through the single write path.
- [ ] Widget + golden tests cover the three locales (fa/ckb/ar) and all four states with real fonts; offline by construction (no network in this surface).

This surface is the *map of the day*, not the act of reciting and not the science behind the schedule. Any decay framing, term-set, or budget copy that touches reverence, sect-neutrality, or "safe to drop" must be cleared against **domain-adab-and-religious-integrity** before it ships.

## Files

- `template.dart` — copy-paste scaffold: the dumb `Today` View, the grouped Far→Near→New sliver list with localized section headers, the page-card row placement (one tap, no glyphs), the four states, the honest budget-feedback line, and the catch-up banner — all RTL via `EdgeInsetsDirectional`, tokens by name, no gamification. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **ui-page-card-and-decay** (the track chip + decay-indicator internals each row hosts), **ui-recite-grade-flow** (the reveal-on-tap + grade band + teacher sign-off the row taps into), **domain-scheduling-engine-rules** (the engine that produces the ordered, capped, load-balanced day and the catch-up re-spread), **eng-add-feature-module** (where the Today feature/View lives), **eng-create-riverpod-store** (the StreamProvider + single-write-path controller behind it), **eng-define-service-boundary** (the injected `CalendarDate` clock — never `DateTime.now()`), **eng-rtl-and-bidi-layout** (the bidi-isolation + mirroring for the locale-numeral page strings), **domain-adab-and-religious-integrity** (the conscience-check on every term-set, decay framing, and budget copy).
