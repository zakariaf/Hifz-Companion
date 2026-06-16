# references — ui-settings-picker

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. A Settings single-choice picker is a **named, mutually-exclusive preference** rendered on the M3 single-select pattern; it applies a **display/presentation transform** and persists the choice — it never re-typesets the muṣḥaf, mutates the engine or the stored instant, recommends, or phones home.

## Primary

- `docs/design-system/07-components.md` §6 (Grade band & component states — one explicit, predictable state model) — **The selection state model the picker is built on:** every interactive component declares explicit M3 interaction states (enabled / pressed / disabled / focused / **selected**) drawn as **state layers** over a role color, never ad-hoc opacity; a **visible focus ring** (`color.outline`) is a WCAG 2.2 SC 2.4.7 requirement for keyboard/switch-control; states mirror correctly under RTL and are announced via `Semantics` enabled/selected flags; and where a choice is "genuinely a single mutually-exclusive choice, `SegmentedButton` is the M3 control." Selected/pressed state is **functional and quiet, never a reward surface** — the calm-not-cute rule applied to a control.

- `docs/design-system/12-localization-and-rtl.md` §8 (The Quran is never localized — only the chrome is) — **The hard limit on the muṣḥaf/riwāyah picker:** whatever the UI language, the Quran is always the bundled QPC per-page glyph muṣḥaf; localization changes "buttons, labels, dates, numerals, and term-sets — never a single glyph of the page"; the muṣḥaf in use is "always stated as 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf,' never as 'the Quran' in the absolute," and **zero bundled tafsīr/translation** ships. The muṣḥaf picker therefore stores a *named edition*, never an in-app translation, and the localization toolkit (mirroring, numerals, fonts) "stops at the chrome."

- `docs/design-system/12-localization-and-rtl.md` §5 (Calendars are user-selectable — display over a single stored instant) — **The canonical "display transform, never mutate" rule:** the calendar selector offers Solar-Hijri/Jalālī (default fa), Hijri Umm al-Qurā, and Gregorian; the calendar choice "is a pure *display transform*, so changing it never mutates engine state or due-dates — it only re-renders." Defaults are per-locale CLDR/constant data (Jalālī for fa, Umm al-Qurā lead for ar, Saturday week-start) — not inference. This is the model every Settings picker follows.

## Supporting

- `docs/design-system/12-localization-and-rtl.md` §4 (Numerals render in the locale's own digit set, via `intl`) — **The numeral-system picker (and every numbered option label):** Extended Arabic-Indic (۰۱۲) for fa/ckb, Arabic-Indic (٠١٢) for ar, produced by `intl` formatters bound to the active locale — "never by hand-substituting ASCII digits." A locale switch "reshapes every number on screen with no string edits"; verify per surface (the known `intl` date-vs-number digit inconsistency). The muṣḥaf's own printed ayah numbers are the immutable glyph layer and are never `intl`-reshaped.

- `docs/design-system/12-localization-and-rtl.md` §6 (The *sabaq/sabqi/manzil* vocabulary is swappable string data) — **The term-set picker:** track names, grade verbs, and cycle names are **regional ARB string-sets** with a user-switchable regional override, independent of UI language; swapping a whole term-set is "a single-file edit." The **ckb (Sorani) defaults are provisional**, flagged "needs native + scholarly review" before they lock — so the term-set option ships clearly marked provisional, never dressed up as final.

- `docs/design-system/12-localization-and-rtl.md` §1 (RTL by geometry, not a flipped flag) — **The picker's geometry:** `Directionality.rtl` app-wide for all three locales; express every position as **logical start/end**, never physical left/right; RTL "drives both visual layout and the semantic/focus order together," so a screen-reader user traverses options right-to-left in their locale.

- `docs/design-system/12-localization-and-rtl.md` §3 (Mixed-direction text is isolated with FSI/PDI) — **The mixed-run labels:** any embedded opposite-direction run in an option label — "Hijri ۱۴۴۷," "Juz ۷," a version/edition token — is wrapped in Unicode FSI/PDI isolation (via `intl` `Bidi`/`BidiFormatter`) so it can't reorder ("page 7 of 30" → "30 of 7"); embedded values are isolated **placeholders**, never hard-spliced substrings. This is a screen-reader-order fix as much as a visual one.

- `docs/design-system/12-localization-and-rtl.md` §2 (Mirror directional icons — never the muṣḥaf) — **The mirroring limit for the muṣḥaf picker:** directional chevrons/disclosure arrows mirror in RTL, but the muṣḥaf glyph page, ayah markers, and sajda signs are **never** mirrored — "altering it ends the project." A muṣḥaf selector that previews the page must show the immutable glyph layer untransformed.

- `docs/design-system/05-layout-spacing-touch.md` §4 (Touch targets: 48×48dp, ≥8dp apart) — **The hit-target floor:** every option row is ≥48×48dp with ≥`space.2` (8dp) clear space, sized by Fitts's law; larger Quran-zoom / OS text-scale "must not shrink hit areas below 48dp." Spacing the options apart keeps a stretch-tap from catching the neighbouring choice.

- `docs/design-system/05-layout-spacing-touch.md` §5 (Thumb ergonomics & screen templates — the Settings template) — **Where the picker lives:** the Settings template is calm content scrolling above, with **destructive/rare actions (export / erase) in the hard-to-reach top corners** as a natural safety margin; one reused template across screens so the one-handed habit transfers. The picker is ordinary settings chrome, not a primary daily action.

- `docs/design-system/05-layout-spacing-touch.md` §3 (RTL is the layout's geometry) — **The inset discipline:** every spacing value is applied through `EdgeInsetsDirectional` / `AlignmentDirectional`; a leading selected affordance sits at the **start** (right), the trailing chevron at the **end** (left), mirroring automatically; the same template serves fa/ckb/ar unchanged, with ckb's longer transcreated labels reflowing within the same start/end insets.

- `docs/design-system/07-components.md` §3 / §4 (Track chip / decay indicator — color-independence) — **The color-independence precedent:** "color must not be the *only* signal" — every state pairs its color with a text label and shape (WCAG 2.2 SC 1.4.1). The Settings picker's selected state inherits this rule: the radio glyph + label carry the choice, not hue.

## Sibling skills

- **ui-cycle-preset-picker** — the other Settings selector, but it writes the engine's `EngineConfig` / cycle ceiling; this picker is presentation-only and **never** touches engine config or `due_at`. Read it to keep the boundary sharp.
- **ui-mushaf-page-view** — applies the chosen muṣḥaf/riwāyah edition and renders the immutable QPC page; this picker only *names and stores* the edition, it does not render it.
- **domain-mushaf-text-integrity** — owns the byte-exact text + per-page glyph fonts + immutable layout the muṣḥaf picker must never violate (no re-typeset, no mirror, no UI numerals on the page).
- **domain-calendars-and-hifzdate** — owns the `CalendarDate` value type, the injected "today", and the display-only calendar rules the calendar picker presents over (Jalālī / Umm al-Qurā / Gregorian, locale numerals on dates).
- **eng-create-riverpod-store** — the long-lived notifier + single write path (persist the preference transactionally before republishing) the picker's selection routes through.
- **eng-define-service-boundary** — the injected clock/"today" the calendar picker re-renders over, instead of `DateTime.now()` in the View.
- **eng-add-localized-string** — adds the option labels and *manzil/dhor* term-set strings to the ARB files (fa/ckb/ar), ckb marked provisional.
- **eng-rtl-and-bidi-layout** — RTL geometry (`EdgeInsetsDirectional`), locale numerals via `intl`, and FSI/PDI isolation for the mixed-run option labels.
- **eng-write-dart-test** — the widget test (selection routes through the controller; no `Slider`), the RTL goldens per locale, and the "calendar switch leaves the stored instant unchanged" assertion.
- **domain-adab-and-religious-integrity** — the conscience-check every preference label/subtitle must pass (riwāyah named not absolute; no "lighter/safe/done" framing; no recommendation, no gamification, no fiqh ruling).
