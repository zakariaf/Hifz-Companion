---
name: eng-rtl-and-bidi-layout
description: Build RTL-correct, bidi-safe layout for the Hifz Companion app — logical start/end insets, directional-icon mirror policy, Unicode FSI/PDI isolation of mixed runs, per-locale numerals, and the display of converted calendar dates. Use whenever you author directional layout, mirror or refuse to mirror a custom-drawn graphic, wire a direction-relative gesture, render a number/date/free-text run inside RTL chrome, or place any widget in the fa/ckb/ar UI.
---

# eng-rtl-and-bidi-layout

The app ships only RTL locales (Persian `fa`, Kurdish-Sorani `ckb`, Arabic `ar`), so **RTL is not a mode — it is the default that must never break**, and a physical-side layout slip is a guaranteed-visible bug in every locale, not a latent one in an unused one. This skill is the widget-layer contract that keeps direction correct by construction: direction is *derived from the locale*, never hardcoded; layout uses logical `start`/`end` APIs only; directional icons mirror and the muṣḥaf never does; every mixed-script run is isolated with Unicode FSI/PDI; numbers render in the locale's own digit block; and a converted calendar date is rendered (not converted) here. The sacred text stops this toolkit at the chrome boundary — no mirroring, numeral, bidi, or font logic ever reaches the immutable muṣḥaf glyph layer. The governing specs are `docs/design-system/12-localization-and-rtl.md` (the design contract) and `docs/engineering/12-localization-rtl-accessibility-impl.md` (the implementation), with date rendering bridging to `docs/engineering/07-dates-calendars-and-correctness.md`.

## When to use

Use this skill when you:

- author or place any widget in the fa/ckb/ar UI — padding, alignment, positioning, a list row, a chevron, a progress fill, the bottom nav;
- mirror, or decide *not* to mirror, a directional icon or a custom-drawn graphic (arrow, chevron, sign-off flow, page-turn affordance, play triangle, the muṣḥaf page);
- wire a direction-relative gesture or animation (swipe to advance a page, a slide-in, a progress sweep);
- render a run that mixes scripts or directions inside one line — a page number, "Juz N", a surah name beside RTL copy, a version string, a backup filename, a user-typed name, a date, a percentage;
- render a number, percentage, daily-budget minute count, or a date string for the user in chrome;
- add or wire the in-Settings calendar picker, the language preview, or a Latin-only technical island that must be forced LTR.

Do **NOT** use this skill for — use the sibling instead:

- the ARB / `gen_l10n` string pipeline, the `ckb` custom localizations delegate, ICU `plural`/`select`, the regional sabaq/sabqi/manzil term-sets, or 100% string-coverage hygiene → use **eng-localization-arb-pipeline**;
- screen-reader `Semantics`, dynamic-text `textScaler`, contrast ≥ 4.5:1, the heat-map's non-color encoding, or ≥ 48 dp touch targets → use **eng-accessibility-implementation**;
- the `CalendarDate` value type, integer day math, the instant-vs-civil-day split, calendar *conversion* (Hijri/Jalālī), the injected "today", or the Hijri honesty note → use **domain-calendars-and-hifzdate**;
- rendering the immutable muṣḥaf glyph page, ayah markers, or sajda signs → use **domain-mushaf-text-integrity** (this skill's toolkit never touches them);
- registering a user-facing factual claim → use **domain-claims-register-and-science-screen**.

This skill owns the **direction, mirroring, bidi isolation, and numeral/date rendering of the chrome** — nothing that converts a date, looks up a string, annotates semantics, or draws a glyph belongs here. If your change opens an ARB file, adds a `Semantics` label, or converts a `CalendarDate` to another calendar, it belongs to a sibling.

## The canonical pattern

The governing specs are `docs/design-system/12-localization-and-rtl.md` and `docs/engineering/12-localization-rtl-accessibility-impl.md`. Reference each rule by its doc section — never re-derive a Unicode block, an isolate control, or a mirroring decision here.

### Direction is locale-derived; layout is logical (`docs/engineering/12-localization-rtl-accessibility-impl.md` §2, `docs/design-system/12-localization-and-rtl.md` §1)

1. **Do not wrap the app in a hardcoded `Directionality`.** App-wide RTL is a *consequence of locale selection*, supplied automatically by `GlobalWidgetsLocalizations` once `MaterialApp` declares its delegates and `supportedLocales: [ar, fa, ckb]`. A hardcoded `Directionality(TextDirection.rtl)` hides physical-side bugs (they happen to look right) and breaks the moment a Latin island needs LTR. `docs/engineering/12-localization-rtl-accessibility-impl.md` §2 (direction is derived from the locale — never hardcoded); `docs/design-system/12-localization-and-rtl.md` §1 (RTL by geometry, not a flipped flag).
2. **Use direction-relative layout APIs only.** Every position is a logical `start`/`end` relationship via `EdgeInsetsDirectional`, `AlignmentDirectional`, `Positioned.directional` — never `EdgeInsets.only(left:/right:)`, `Alignment.centerLeft/Right`, or `Positioned(left:/right:)`, which are CI-grep-banned in `features/**`. Spacing flows through the logical `space.*` scale. One `Directionality` flip then mirrors the whole app correctly: the bottom nav (Today rightmost), chevrons, back/next, and progress fills are the *visual result* of laying logical-order children out under RTL, not a manual reversal. `docs/engineering/12-localization-rtl-accessibility-impl.md` §2 (direction-relative APIs; the physical-side grep gate); `docs/design-system/12-localization-and-rtl.md` §1 (logical `start`/`end` everywhere; RTL nav order).
3. **Read direction from context, never as a constant.** When logic needs direction it reads `Directionality.of(context)` — never assumes `TextDirection.rtl` — so the two permitted manual islands behave: forcing **LTR** around a Latin-only technical token (a version string, a hex checksum) and the in-Settings language preview rendering a sample in the candidate locale's direction. `docs/engineering/12-localization-rtl-accessibility-impl.md` §2 (the two permitted manual-`Directionality` islands; "we refuse to assume RTL in logic").

### Mirror directional icons — and only those (`docs/design-system/12-localization-and-rtl.md` §2)

4. **Mirror sequence/navigation glyphs; never mirror real-world, fixed-convention, or sacred ones.** Back/next/continue arrows, chevrons, progress fills, sign-off flow arrows, and the page-turn *direction* mirror in RTL (use the auto-mirroring `Icons.arrow_back`/`Icons.arrow_forward` family, which respects ambient direction). Media play/pause, clock, phone, and numeral digit glyphs are **never** mirrored. The muṣḥaf glyph page, ayah-end marker, and sajda sign are **never** mirrored, flipped, rotated, or reflected — altering the sacred glyph layer is forbidden by the system's first outranking rule. The mirroring decision lives in the curated table, not per-widget intuition; mirroring everything is as wrong as mirroring nothing. `docs/design-system/12-localization-and-rtl.md` §2 (the icon-mirroring table; the muṣḥaf is never mirrored).

### Isolate every mixed-script run (`docs/engineering/12-localization-rtl-accessibility-impl.md` §4, `docs/design-system/12-localization-and-rtl.md` §3)

5. **Route every mixed run through the one bidi-isolation helper.** A page number, "Juz N", a surah name beside RTL copy, a date, a percentage, a version string, a backup filename, or a user-typed name is wrapped in Unicode **isolates** before display — `isolate()` (FSI…PDI) for unknown direction, `isolateLtr()` / `isolateRtl()` (LRI/RLI…PDI) when the run's direction is known. Use `intl`'s `Bidi`/`Unicode` constants; prefer the **isolating** controls (LRI/RLI/FSI + PDI) over the legacy embedding/override codes (LRE/RLE/LRO/RLO), which the standard discourages. Raw concatenation of opposite-direction runs is grep-banned. `docs/engineering/12-localization-rtl-accessibility-impl.md` §4 (one bidi-isolation helper; FSI vs known-direction); `docs/design-system/12-localization-and-rtl.md` §3 (FSI/PDI isolation; the "page 7 of 30" → "30 of 7" failure).
6. **Prefer explicit direction over first-strong when you know it; keep the run a single placeholder.** First-strong (FSI) mis-guesses when the leading character is the "wrong" script (an Arabic string opening with an ASCII quote detects as LTR), so a known-direction run uses `isolateLtr`/`isolateRtl`. The opposite-direction value is an isolated, formatted **ARB placeholder** (`"{page} از {total}"`), never a hard-spliced substring; isolation wraps the *embedded token*, not the surrounding word — and a localized label stays in a single `Text`/`TextSpan` (fragmenting an Arabic-script word triggers diacritic-clipping bugs). `docs/engineering/12-localization-rtl-accessibility-impl.md` §4 (we refuse FSI where direction is known); `docs/design-system/12-localization-and-rtl.md` §3 (placeholder, not hard-splice; single `Text`/`TextSpan`).

### Numerals render in the locale's own digit block (`docs/engineering/12-localization-rtl-accessibility-impl.md` §5, `docs/design-system/12-localization-and-rtl.md` §4)

7. **Format numbers through per-locale `NumberFormat` with a pinned numbering system.** `fa` and `ckb` render **Extended Arabic-Indic** (U+06F0–U+06F9, `۰۱۲۳۴۵۶۷۸۹`) via `-u-nu-arabext`; `ar` renders **Arabic-Indic** (U+0660–U+0669, `٠١٢٣٤٥٦٧٨٩`) via `-u-nu-arab` — pin the numbering system explicitly because `intl`'s bare-locale Arabic-digit defaults are inconsistent between date and number formatting. These are two distinct, non-interchangeable Unicode blocks; showing `٤٥٦` to a Persian reader is a defect. ASCII digits are never concatenated into a localized string — a number is formatted (`numberFormatFor(locale)`), then injected into an ICU placeholder. This is the `type.numeral` token discipline. `docs/engineering/12-localization-rtl-accessibility-impl.md` §5 (per-locale `NumberFormat`; pinned `-u-nu-`); `docs/design-system/12-localization-and-rtl.md` §4 (`type.numeral`; locale digit sets via `intl`).

### A converted date is rendered here, downstream (`docs/engineering/07-dates-calendars-and-correctness.md` §4, `docs/design-system/12-localization-and-rtl.md` §5)

8. **Render a date the calendar layer already converted — remap its digits downstream, then isolate it.** The Hijri (Umm al-Qurā) / Jalālī / Gregorian *conversion* and the `CalendarPresenter` are owned by **domain-calendars-and-hifzdate**; this skill only places the converted label in an RTL line — re-mapping its Latin digits to the locale set (rule 7) *after* conversion, then isolating the run (rule 5). The in-Settings calendar picker selects an explicit `CalendarSystem` (default Jalālī for `fa`); week-start is locale data (Saturday for fa/ar from CLDR), never hardcoded Monday/Sunday. `docs/engineering/07-dates-calendars-and-correctness.md` §4 (numerals remapped downstream of conversion); `docs/design-system/12-localization-and-rtl.md` §5 (user-selectable calendars; CLDR week-start).

### The sacred-text boundary (`docs/design-system/12-localization-and-rtl.md` §8)

9. **The localization toolkit stops at the chrome.** Whatever the UI language, the Quran is always the Uthmani muṣḥaf via the bundled QPC per-page glyph fonts; only the chrome is localized. No mirroring, `NumberFormat`, bidi isolation, UI font, or term-set ever reaches a glyph of the page — the ayah numbers, ayah-end markers, and sajda signs printed on the page are the immutable layer, not re-rendered by `intl`. The reader honors zoom/theme by transforming the rendered glyph layer over fixed coordinates, never by re-shaping text. `docs/design-system/12-localization-and-rtl.md` §8 (the Quran is never localized — only the chrome); `docs/design-system/12-localization-and-rtl.md` §4 (only UI-chrome numbers are `intl`-shaped, never the page's ayah numbers).

### It is a release gate (`docs/engineering/12-localization-rtl-accessibility-impl.md` §8)

10. **Prove it with the per-locale RTL/numeral goldens and the grep gates.** RTL correctness is a layout property that can regress on any screen and is testable on draft copy (direction follows the locale). The gate is mostly compile-time/grep: a physical-side grep over `features/**`, an ASCII-digit-interpolation grep, and per-locale RTL + numeral golden screenshots loading the **real** bundled UI fonts (so Sorani extra letters and Persian digits are actually exercised — never `Ahem` or a placeholder font). `docs/engineering/12-localization-rtl-accessibility-impl.md` §8 (the localization & accessibility gate; the layer table); `docs/design-system/12-localization-and-rtl.md` §1 (RTL focus/reading order is a tested invariant).

## Do / Don't

| Do | Don't |
|---|---|
| Let RTL come from the locale (`supportedLocales: [ar, fa, ckb]` + `GlobalWidgetsLocalizations`) | Wrap the app/root in a hardcoded `Directionality(TextDirection.rtl)` |
| Lay out with `EdgeInsetsDirectional` / `AlignmentDirectional` / `Positioned.directional` and `start`/`end` | `EdgeInsets.only(left:/right:)`, `Alignment.centerLeft/Right`, `Positioned(left:/right:)` (grep-banned) |
| Read `Directionality.of(context)` when logic needs direction | Assume `TextDirection.rtl` as a constant in logic |
| Mirror back/next/chevron/progress via the auto-mirroring `Icons.arrow_*` family; keep the table authoritative | Mirror media-play/clock/phone/numerals, or mirror per-widget by intuition |
| Treat the muṣḥaf page, ayah marker, and sajda sign as never-mirrored, never-reshaped | Flip/rotate/reflect/re-typeset any glyph of the sacred page for any visual goal |
| Isolate every mixed run with `isolate` / `isolateLtr` / `isolateRtl` (FSI/LRI/RLI…PDI) | Concatenate a raw number/Latin token into RTL copy ("Juz " + n); use legacy LRE/RLE/LRO/RLO |
| Prefer `isolateLtr`/`isolateRtl` when direction is known; keep the run an isolated ARB placeholder | Rely on FSI first-strong for a run you know the direction of; hard-splice the token mid-string |
| Format numbers via `numberFormatFor(locale)` with pinned `-u-nu-arabext` (fa/ckb) / `-u-nu-arab` (ar) | Concatenate ASCII digits, show `٤٥٦` to a Persian reader, or rely on bare-locale digit defaults |
| Render a date the `CalendarPresenter` converted, remap digits downstream, then isolate; week-start from CLDR | Convert the calendar here, hardcode a Monday/Sunday week-start, or let Latin digits reach the UI |
| Keep mirroring/numerals/bidi/fonts to the chrome only | Apply any of them to the muṣḥaf glyph layer or present the page as "the Quran" in the absolute |
| Verify with per-locale RTL + numeral goldens on the real bundled fonts | Skip the goldens trusting "Flutter handles bidi", or render goldens with `Ahem`/a placeholder font |

## Checklist

Before an RTL/bidi/numeral layout change is done:

- [ ] No hardcoded app-wide `Directionality`; RTL comes from the locale (`supportedLocales: [ar, fa, ckb]` + `GlobalWidgetsLocalizations`); the only manual `Directionality` is a forced-LTR Latin island or the Settings language preview (§2 of impl-12; §1 of ds-12).
- [ ] All positioning is logical — `EdgeInsetsDirectional`, `AlignmentDirectional`, `Positioned.directional`, `start`/`end` and the `space.*` scale; no `EdgeInsets.only(left:/right:)`, `Alignment.centerLeft/Right`, or `Positioned(left:/right:)` survives the `features/**` grep (§2 of impl-12; §1 of ds-12).
- [ ] Direction-needing logic reads `Directionality.of(context)`, never a hardcoded `TextDirection.rtl` (§2 of impl-12).
- [ ] Directional icons (back/next/chevron/progress/sign-off) mirror via the auto-mirroring `Icons.arrow_*` family; media-play/clock/phone/numerals do not; every decision traces to the mirroring table (§2 of ds-12).
- [ ] The muṣḥaf glyph page, ayah-end marker, and sajda sign are never mirrored, flipped, rotated, reflected, or re-typeset — the toolkit stops at the chrome (§2, §8 of ds-12; adab via **domain-mushaf-text-integrity**).
- [ ] Every mixed-script run goes through the one bidi-isolation helper (`isolate`/`isolateLtr`/`isolateRtl`, FSI/LRI/RLI…PDI); no raw concatenation, no legacy LRE/RLE/LRO/RLO; known-direction runs use `isolateLtr`/`isolateRtl`, not FSI (§4 of impl-12; §3 of ds-12).
- [ ] The opposite-direction value is an isolated, formatted ARB **placeholder**, not a hard-spliced substring; the localized label stays in a single `Text`/`TextSpan` (§4 of impl-12; §3 of ds-12).
- [ ] Numbers format through `numberFormatFor(locale)` with a pinned numbering system — `-u-nu-arabext` for fa/ckb (Extended Arabic-Indic), `-u-nu-arab` for ar (Arabic-Indic); no ASCII digits in any localized string; survives the ASCII-digit grep (§5 of impl-12; §4 of ds-12).
- [ ] Date labels come from the `CalendarPresenter` (sibling-owned conversion); this layer only remaps digits downstream and isolates the run; the calendar is an explicit `CalendarSystem` setting (default Jalālī for `fa`); week-start is CLDR data (Saturday for fa/ar) (§4 of dates-07; §5 of ds-12; conversion via **domain-calendars-and-hifzdate**).
- [ ] No mirroring, `NumberFormat`, bidi control, UI font, or term-set reaches the muṣḥaf glyph layer; the page's printed ayah numbers are never re-rendered by `intl` (§8, §4 of ds-12; **domain-mushaf-text-integrity**).
- [ ] Per-locale RTL + numeral golden screenshots pass in fa/ckb/ar on the **real** bundled UI fonts (Sorani extra letters پ چ ژ گ ڤ ڕ ڵ ۆ ێ ە and Persian digits actually exercised; never `Ahem`); RTL reading/focus order verified (§8 of impl-12; §1 of ds-12; harness via **eng-write-dart-test**).
- [ ] Offline & no-AI preserved: nothing here touches the network or any model — all direction/numeral/bidi logic is local layout; no streak/score/shame surface is introduced (`docs/_DOC-SET-BLUEPRINT.md`; `docs/PRD.md`).

RTL is the design baseline, not a phase: any LTR-first screen "mirrored later" is a bug. The geometry must flip, not just the words — and every flip stops at the chrome, never reaching a glyph of the muṣḥaf.

## Files

- `template.dart` — copy-paste scaffold for a typical RTL chrome surface: a locale-derived (never hardcoded) `MaterialApp` direction setup, a logical-inset Riverpod widget, the bidi-isolation helper (`isolate`/`isolateLtr`/`isolateRtl`), the pinned per-locale `numberFormatFor`, an isolated localized-number/date line, the forced-LTR Latin island and Settings language preview, and the per-locale RTL/numeral golden test stub — with `// TODO` markers and every token/rule referenced by name.
- `references.md` — the exact governing doc sections, each with the one thing to take from it, and the sibling skills.

Related skills: **eng-localization-arb-pipeline** (the ARB / `gen_l10n` strings, `ckb` delegate, ICU plural/select, regional term-sets this layout localizes), **eng-accessibility-implementation** (the `Semantics`/`textScaler`/contrast/48 dp obligations on the same widgets; RTL focus order is shared), **domain-calendars-and-hifzdate** (the `CalendarDate`, conversion, `CalendarPresenter`, and Hijri honesty note whose output this layer renders), **domain-mushaf-text-integrity** (the immutable glyph page this skill's toolkit never touches), **domain-claims-register-and-science-screen** (registering any factual claim surfaced in the chrome), **eng-add-feature-module** (where an RTL feature screen is assembled), **eng-write-dart-test** (the per-locale RTL/numeral golden harness).
