---
name: ui-settings-picker
description: Build or modify a single-choice Settings control for the Hifz Companion app — the picker/dropdown that sets one preference (UI language, calendar system, numeral system, sabaq/sabqi/manzil term-set, theme, or muṣḥaf / riwāyah) inside the grouped Settings surface. Use whenever building a Settings single-choice picker, a calendar/numerals/language/term-set/theme/muṣḥaf selector, or any mutually-exclusive preference row. This control is a quiet, display-only preference change — NEVER a place that re-typesets the muṣḥaf, mutates engine state, gamifies, or phones home.
---

# ui-settings-picker

The single-choice **Settings picker**: how a ḥāfiẓ changes one preference — **UI language** (fa/ckb/ar), **calendar** (Solar-Hijri/Jalālī · Hijri Umm al-Qurā · Gregorian), **numeral system** (Extended Arabic-Indic / Arabic-Indic), **term-set** (the regional *sabaq/sabqi/manzil* vocabulary), **theme** (light/sepia/dark), or **muṣḥaf / riwāyah** — from a calm, grouped Settings list, and nothing more. Each picker is a mutually-exclusive choice rendered on the M3 single-select pattern; the change is a **display transform** persisted through the single write path, never a mutation of the scheduling engine, the stored instant, or the immutable glyph layer.

This control is a Settings citizen, not a feature surface: it states a fact, applies a presentation choice, and gets out of the way (Pillar 2, *calm not cute*; Pillar 5, *private & offline by feel*). A Settings picker that re-typesets the Quran, alters a `due_at`, recommends an option, or celebrates a choice is the wrong component.

## When to use

Use when building or placing:
- a Settings single-choice picker / dropdown / selection sub-screen for one preference
- the **language** selector (fa/ckb/ar — all RTL)
- the **calendar** selector (Solar-Hijri/Jalālī · Hijri Umm al-Qurā · Gregorian)
- the **numeral-system** selector (Extended Arabic-Indic ۰۱۲ for fa/ckb · Arabic-Indic ٠١٢ for ar)
- the **term-set** selector (the regional *manzil/dhor* vocabulary, independent of UI language)
- the **theme** selector (light / sepia / dark)
- the **muṣḥaf / riwāyah** selector (named edition + riwāyah, e.g. "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf")
- any mutually-exclusive preference row built on `RadioListTile` / a selectable `Card` / a single-select sub-page

Do NOT use this skill for:
- the **cycle / preset** choice that sets the engine's cycle ceiling → use **ui-cycle-preset-picker** (that one writes `EngineConfig`; a Settings picker never does)
- choosing the muṣḥaf to *render*, registering glyph fonts, or the reader itself → use **ui-mushaf-page-view** (this picker only stores the named choice; the reader applies it)
- the teacher-present source toggle in the recite flow → use **ui-teacher-signoff**
- the export / erase / `.hifzbackup` controls in Settings → use **domain-backup-format**
- adding the option's localized / term-set strings to ARB → use **eng-add-localized-string**
- the RTL geometry, locale numerals, and FSI/PDI isolation of the labels → use **eng-rtl-and-bidi-layout**
- the long-lived notifier + persist-before-republish mutation that saves the preference → use **eng-create-riverpod-store**

The picker *names and stores* a presentation choice; the rest of the app *applies* it. A Settings picker that computes a date, reorders pages, re-renders a glyph, or shows a "recommended" option is doing another layer's job.

## The canonical pattern

1. **A single-select list of named options — never a slider, never free text.** Render the choices on the M3 **single-select** pattern: `RadioListTile<T>` rows (or a selectable `Card`, or a `SegmentedButton` where the set is short and short-labelled), display-only chrome, exactly one selected at a time. There is no numeric dial and no on/off ambiguity — a preference with two-or-more named values is a radiogroup, not a switch. `docs/design-system/07-components.md` §6 (the explicit, predictable component **state model** — enabled/pressed/disabled/focused/**selected**, drawn with M3 **state layers** over a role color; where a choice is genuinely single mutually-exclusive, `SegmentedButton` is the M3 control). Selection token discipline: `color.*` roles (owned by `03-color-and-themes.md`), `type.body`/`type.caption` labels (`04-typography.md`), `space.*` gaps (`05-layout-spacing-touch.md`).

2. **Selected state is shape AND text, never color alone.** Each option pairs its selected state with the radio glyph / a check and its text label, so a color-blind user reads the choice without hue, and the state reads through an M3 state layer rather than ad-hoc opacity. `docs/design-system/07-components.md` §6 (state layers over a role color; selected = filled emphasis; never per-component opacity) — the same color-independence rule the track chip and decay indicator follow (`07-components.md` §3, §4 / WCAG 2.2 SC 1.4.1).

3. **The picker stores a presentation choice — it computes nothing.** A Settings preference is a **display transform** over already-stored data: the calendar selector re-renders dates over a single unambiguous stored instant and **never mutates the instant or any `due_at`**; the numeral selector reshapes digits through `intl`; the term-set selector relabels chips; the theme re-tones the palette; the muṣḥaf selector names the edition. None of them touch the scheduling engine. `docs/design-system/12-localization-and-rtl.md` §5 (calendars are "a display concern over a single, unambiguous stored instant"; changing the calendar "never mutates engine state or due-dates — it only re-renders") and §4 (numerals reshape via `intl`, the locale switch "reshapes every number on screen with no string edits").

4. **The muṣḥaf is never localized or re-typeset — the picker only names the edition.** Whatever the UI language, the Quran is always the bundled QPC per-page glyph muṣḥaf; the muṣḥaf/riwāyah picker swaps a *named* edition (and its pinned glyph-font + layout asset set), and the riwāyah is always **stated explicitly** ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"), never presented as "the Quran" in the absolute. The selector must never apply UI numerals, UI fonts, or mirroring to the glyph page, and must never trigger an in-app translation/transliteration/tafsīr. `docs/design-system/12-localization-and-rtl.md` §8 (the Quran is never localized — only the chrome is; riwāyah named, not absolute; localization stops at the chrome) and §2 (the muṣḥaf glyph page is **never** mirrored). Applying the chosen edition is **ui-mushaf-page-view** / **domain-mushaf-text-integrity**; this picker only persists the choice.

5. **RTL by geometry, term-set labels, locale numerals.** The picker is RTL by construction for fa/ckb/ar: option labels and the leading selected affordance sit at the **start** (right), trailing chevron/disclosure at the **end** (left), via `EdgeInsetsDirectional`/`AlignmentDirectional` — left/right are never named. Option names that carry a number ("Hijri ۱۴۴۷," "every ۷ days") render numerals in the locale set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) via `intl`, with mixed Latin/number runs FSI/PDI-isolated so a "Juz ۷" run never flips its sentence. The *manzil/dhor* term-set values are swappable ARB strings, never hardcoded English. `docs/design-system/12-localization-and-rtl.md` §1 (RTL by geometry; logical start/end only), §3 (FSI/PDI isolation of every embedded run), §4 (locale numeral set via `intl`), §6 (the term-set is swappable string data); `docs/design-system/05-layout-spacing-touch.md` §3 (`EdgeInsetsDirectional`, logical insets). Add strings via **eng-add-localized-string**; lay out via **eng-rtl-and-bidi-layout**.

6. **Persist through the single write path — never mutate the preference in the View.** Selecting an option routes through one controller/notifier method that persists the new preference transactionally **before** republishing in-memory state; the View never writes the setting and never reaches into a global. Switching it re-renders the affected surfaces deterministically (the day's dates, the chip labels, the palette) — the picker only stores the choice. `docs/design-system/07-components.md` §6 (selection is a functional state change, not a reward) and **eng-create-riverpod-store** (the persist-before-republish single write path). The injected "today"/clock stays the source of dates — never `DateTime.now()` in the View (**eng-define-service-boundary**).

7. **48×48dp targets, grouped, in the calm Settings template.** Each option is one ≥48dp `touch.min` selectable row with ≥`space.2` (8dp) between rows; the picker sits in the grouped Settings list (content scrolls above, the rare/destructive controls like erase live in the hard-to-reach top corner). Larger OS text scale must not shrink any row below 48dp. `docs/design-system/05-layout-spacing-touch.md` §4 (minimum 48×48dp, ≥8dp apart, sized by Fitts's law) and §5 (the one-handed Settings template — calm content scrolls, destructive actions sit out of easy thumb reach).

8. **Accessibility: one labelled choice per option, announced as a radiogroup, with a visible focus ring.** Each row exposes a `Semantics` label = its option name and a selected / not-selected value, grouped as a mutually-exclusive radiogroup (`inMutuallyExclusiveGroup`); a visible focus ring (`color.outline`) serves keyboard/switch-control users; states mirror correctly under RTL and are announced via `Semantics` enabled/selected flags. Per-option labels are localized per locale (and per-run `locale` set so the screen reader speaks numerals naturally). `docs/design-system/07-components.md` §6 (visible focus ring per WCAG 2.2 SC 2.4.7; `Semantics` enabled/selected flags; states mirror under RTL) and `docs/design-system/12-localization-and-rtl.md` §1 (RTL drives focus/traversal order), §4 (locale numerals are a screen-reader-correctness requirement).

9. **No score, no celebration, no recommendation, no urgency.** Picking a preference is a quiet, factual change — no confetti, no streak, no badge, no "recommended for you," no "optimal" praise, no manufactured urgency, and no exclamation marks; a pressed/selected state is an M3 state layer, never a glow or pop. The ckb term-set ships clearly marked **provisional** (pending native + scholarly review) rather than dressed up as final. `docs/design-system/07-components.md` §6 (state feedback is functional and quiet, never a reward surface; Pillar 2) and `docs/design-system/12-localization-and-rtl.md` §6 (the ckb default term-set is provisional until native + scholarly review). Run any preference copy past **domain-adab-and-religious-integrity**.

10. **Offline / no-AI — the picker stores a choice, it infers nothing.** No network, no model, no "recommended for you," no telemetry on which option was chosen; defaults are plain per-locale constants (Jalālī default for fa, Umm al-Qurā lead for ar, the locale's numeral set) and every selector works in airplane mode forever. `docs/design-system/12-localization-and-rtl.md` §5 (per-locale calendar/week-start defaults are CLDR/constant data, not inference) — private-by-feel: a Settings surface carries no outward-pointing UI.

## Do / Don't

| Do | Don't |
|---|---|
| Render the options as **named** single-select rows (`RadioListTile`/selectable `Card`/short `SegmentedButton`) | Use a slider, a free-text field, or a switch for a 2+-value preference |
| Pair selected state with the radio glyph + text label (shape AND color) | Signal selection by color alone, or with per-component opacity |
| Treat the choice as a **display transform** — re-render dates/digits/labels/palette over unchanged data | Mutate the stored instant, a `due_at`, or any engine state from a Settings picker |
| For the muṣḥaf picker, store a **named** edition + state the riwāyah ("Ḥafṣ ʿan ʿĀṣim — Madani") | Re-typeset, mirror, translate, or apply UI numerals/fonts to the glyph page; or call it "the Quran" in the absolute |
| Persist via one controller method (persist-then-republish), then let surfaces re-render | Write the preference in the View, or reach into a global / `DateTime.now()` |
| RTL by `EdgeInsetsDirectional`; locale numerals via `intl`; mixed runs FSI/PDI-isolated | Hardcode left/right insets, ASCII digits, or English "Manzil/Juz" labels |
| ≥48dp `touch.min` rows, ≥`space.2` apart, in the grouped Settings list | Cram options below 48dp, or put a destructive control in easy thumb reach |
| `Semantics` name + selected value per row; radiogroup; visible focus ring (`color.outline`) | Leave options unlabeled, or ship a row with no visible focus indicator |
| Switch quietly and factually; selected = M3 state layer; ckb term-set marked provisional | Fire confetti/streak/badge, praise a choice, recommend one, or pressure with urgency |
| Keep it fully offline — defaults are per-locale constants (Jalālī for fa, Umm al-Qurā for ar) | Add "recommended for you" inference, a network call, or telemetry on the choice |

## Checklist

Before this control is done:

- [ ] Options are a **named** single-select set on the M3 single-select pattern (`RadioListTile`/selectable `Card`/short `SegmentedButton`) — exactly one selected, **no slider / no free text / no switch** for a 2+-value preference (`docs/design-system/07-components.md` §6).
- [ ] Selected state is the radio glyph + text label (shape AND color), drawn as an M3 **state layer** over a role color — never color alone, never ad-hoc opacity (`docs/design-system/07-components.md` §6; WCAG 2.2 SC 1.4.1).
- [ ] The choice is a **display transform**: the calendar re-renders dates over the unchanged stored instant, numerals reshape via `intl`, the term-set relabels, the theme re-tones — **no engine state, `due_at`, or stored instant is mutated** (`docs/design-system/12-localization-and-rtl.md` §5, §4).
- [ ] The muṣḥaf/riwāyah picker stores a **named** edition and states the riwāyah explicitly; it never re-typesets, mirrors, translates, or applies UI numerals/fonts to the glyph page, and never calls the muṣḥaf "the Quran" absolutely (`docs/design-system/12-localization-and-rtl.md` §8, §2; apply via **ui-mushaf-page-view** / **domain-mushaf-text-integrity**).
- [ ] RTL by `EdgeInsetsDirectional`; option numerals render in the locale set (Extended Arabic-Indic fa/ckb, Arabic-Indic ar) via `intl`; mixed Latin/number runs FSI/PDI-isolated; term-set labels are ARB strings, never hardcoded English (`docs/design-system/12-localization-and-rtl.md` §1, §3, §4, §6; **eng-add-localized-string**, **eng-rtl-and-bidi-layout**).
- [ ] The mutation goes through one controller/notifier method that persists transactionally **before** republishing; no View-level write, no global, no `DateTime.now()` in the View (**eng-create-riverpod-store**; **eng-define-service-boundary**).
- [ ] Each option is a ≥48dp `touch.min` row, ≥`space.2` apart, in the grouped Settings list; OS text scale never shrinks a row below 48dp; destructive controls (erase) stay in the hard-to-reach top corner (`docs/design-system/05-layout-spacing-touch.md` §4, §5).
- [ ] Each option has a `Semantics` name + selected value, grouped as a radiogroup (`inMutuallyExclusiveGroup`), with a visible focus ring (`color.outline`) per WCAG 2.2 SC 2.4.7; states mirror under RTL (`docs/design-system/07-components.md` §6; `docs/design-system/12-localization-and-rtl.md` §1).
- [ ] Switching is quiet and factual — no confetti/streak/badge/score, no "recommended", no "optimal!", no urgency, no exclamation marks; the ckb term-set is marked **provisional** until native + scholarly review (`docs/design-system/07-components.md` §6; `docs/design-system/12-localization-and-rtl.md` §6; conscience-check via **domain-adab-and-religious-integrity**).
- [ ] Fully offline / no-AI: no network, no model, no "recommended for you", no telemetry; defaults are per-locale constants (Jalālī for fa, Umm al-Qurā lead for ar); works in airplane mode (`docs/design-system/12-localization-and-rtl.md` §5).
- [ ] Tests: a widget test asserting selection routes through the controller (persist-before-republish) and that **no `Slider`** exists in the tree; RTL goldens per locale (fa/ckb/ar); a calendar-picker test asserting the stored instant is unchanged after a calendar switch (**eng-write-dart-test**).

This control changes *how the app presents itself*, never *what the Quran says* or *what the engine schedules*. The two outranking lines for a Settings picker: the muṣḥaf/riwāyah selector must keep the glyph layer immutable and the riwāyah named (it is a naming choice, not a rendering or a ruling), and no preference copy may ever frame a setting as making revision "lighter," "safe," or "done." If a label or subtitle drifts toward recommendation, reassurance about decay, or a religious claim, run it past **domain-adab-and-religious-integrity**.

## Files

- `template.dart` — copy-paste starting point: the domain-blind `SettingsSinglePicker<T>` (named single-select rows + selected `Semantics` + RTL geometry, taking primitives + a selection callback), the feature-layer wiring that builds the localized options for one preference and persists the choice through the controller's single write path (with the calendar picker shown as the canonical "display transform, never mutate the instant" case), and the widget-test stub. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **ui-cycle-preset-picker** (the other Settings selector — but that one writes `EngineConfig`; this one never does), **ui-mushaf-page-view** (applies the chosen muṣḥaf/riwāyah and renders the immutable page), **domain-mushaf-text-integrity** (the glyph-layer integrity the muṣḥaf picker must never violate), **domain-calendars-and-hifzdate** (the `CalendarDate` value type + display-only calendar rules the calendar picker presents over), **eng-create-riverpod-store** (the single-write-path method that persists the preference), **eng-add-localized-string** (the option / term-set strings), **eng-rtl-and-bidi-layout** (RTL geometry + locale numerals + bidi isolation), **eng-write-dart-test** (the widget + RTL-golden tests), **domain-adab-and-religious-integrity** (the conscience-check on any preference copy).
