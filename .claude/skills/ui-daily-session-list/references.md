# references — ui-daily-session-list

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/design-system/07-components.md` §1 (The daily-session list) — **Statement**: Today is a single finite, capped list grouped **Far (manzil) → Near (sabqi) → New (sabaq)**, recited old-before-new, that **ends** — never a feed, never a count-up. **In practice**: render sections as `ListView` slivers with a quiet `type.title` header, separated by `space.6`, rows `space.2` apart; section labels are **localized term-sets** (المراجعة البعيدة / مرور دور / مەنزڵ), never hardcoded English; the four **states** (loading `surfaceContainerLow` skeleton, populated, calm all-done in `color.text.secondary`, gentle catch-up banner); RTL by geometry (leading at start, chevron at end, `EdgeInsetsDirectional`); one `Semantics` container = "Revise today" with section roles. **Anti-patterns**: never infinite scroll/feed/inbox; never celebrate all-done; never reorder the three sections; never a red shame-pile. — The single most important section: it defines the whole surface this skill governs.

- `docs/PRD.md` §12.2 (Today — the core screen) — The product contract: a "short, **finite, capped** list: 'Revise today' grouped Far → Near → New, in recitation order"; each item = page number/juz (localized numerals) + track chip + calm decay indicator, tap → recite flow; after a missed gap a **gentle catch-up banner** with the re-spread plan, **never a red shame-pile**; **honest budget feedback** — if the chosen scope can't fit the budget the app says so and offers to **raise budget / lengthen cycle / pause new sabaq**, and **never silently lets pages rot**. — The take: the exact capped/grouped/old-before-new shape, the catch-up banner, and the honest-budget line are all mandated here.

- `docs/design-system/07-components.md` §2 (The page card) — Each row = one muṣḥaf page, a `ListTile`/`Card` at elevation Level 0–1, carrying (RTL) a **leading** track chip + decay indicator, a **headline** localized "Page ۲۵۳ · Juz ۱۳", an optional **supporting** line, a **trailing** chevron; the **whole row is one ≥48dp tap** into recite, with the chip/indicator as labels not separate targets; it **never renders Quran glyphs** and **never shows D/S/R, a percentage, or "safe to drop."** — The take: what a row *is* and what it must never contain. (Build the chip/decay internals via **ui-page-card-and-decay**; here you only place the row.)

## Supporting

- `docs/design-system/05-layout-spacing-touch.md` §5 (Thumb ergonomics & screen templates) — The **Today template**: the finite Far→Near→New list scrolls in the upper/middle area; the primary daily action (begin / next-item tap) lives in the **bottom band** within one-handed thumb reach (`space.4` padding + `SafeArea` above the `NavigationBar`); the settings shortcut sits in the hard-to-reach top corner; one reused template across screens so the one-handed habit transfers. — The take: where the tap goes and why content scrolls above it.

- `docs/design-system/05-layout-spacing-touch.md` §3 (RTL is the layout's geometry, not a mode) — Express every inset/alignment with logical **start/end** via `EdgeInsetsDirectional` / `AlignmentDirectional`; leading icons (track chip, decay indicator) at the **start** (right), chevrons at the **end** (left), mirrored automatically; the one template serves fa/ckb/ar and ckb's longer transcreated labels reflow within the same insets; mixed runs (a "Juz ۷" numeral inside RTL text) stay bidi-isolated (FSI/PDI). — The take: the list is RTL by construction, never an "RTL mode."

- `docs/design-system/05-layout-spacing-touch.md` §4 (Touch targets: 48 × 48dp) — Every interactive control ≥ 48 × 48dp with ≥ 8dp (`space.2`) spacing; the page-card row is one such target; the chip/decay-indicator inside it are labels, not second targets. `touch.min` = 48. — The take: one unambiguous ≥48dp tap per row.

- `docs/design-system/05-layout-spacing-touch.md` §1 (The spacing scale) — All gaps resolve to a `space.*` token (`space.2` row gap, `space.4` default padding / edge margin, `space.6` between sections); never a raw `EdgeInsets.all(13)`; never tighten spacing to cram (Pillar 2). — The take: the section/row rhythm tokens by name.

- `docs/PRD.md` §7.9 (Load balancing & graceful catch-up) — The **engine** owns this: FAR/manzil due items are **mandatory and never dropped**; NEAR fits by urgency; NEW only if budget remains; after a gap the engine **re-spreads** the backlog over several days ("You missed 3 days — here is a 5-day catch-up plan…"), **re-spread, never shame**. — The take: the View only *displays* the catch-up banner and budget line; the math is **domain-scheduling-engine-rules**, never the widget.

## Sibling skills

- **ui-page-card-and-decay** — the track-chip and decay-indicator anatomy/encoding each row hosts (§2–§4 of `07-components.md`). This skill places the row; that one builds its internals.
- **ui-recite-grade-flow** — the reveal-on-tap, the four-level Again/Hard/Good/Easy grade band, stumble-line tapping, and teacher sign-off the row taps into (§5–§7 of `07-components.md`).
- **domain-scheduling-engine-rules** — the engine that produces the ordered, capped, load-balanced day, the tracks, the TRUST CLAMP, and the catch-up re-spread (`PRD §7`).
- **eng-add-feature-module** — where the Today feature/View, its widgets, and its scoped providers live, wired to Riverpod + `go_router` in RTL nav order.
- **eng-create-riverpod-store** — the `StreamProvider` read model and the single-write-path controller behind this dumb View.
- **eng-define-service-boundary** — the injected `CalendarDate` clock (`clockProvider`) that owns "today"; never `DateTime.now()` in this surface.
- **eng-rtl-and-bidi-layout** — the bidi-isolation (FSI/PDI) and mirroring rules for the locale-numeral "Page N · Juz M" strings and section labels.
- **domain-adab-and-religious-integrity** — the conscience-check on every term-set, decay framing, all-done copy, and budget-feedback line before it ships.
