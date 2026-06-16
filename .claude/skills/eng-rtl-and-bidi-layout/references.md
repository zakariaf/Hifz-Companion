# references — eng-rtl-and-bidi-layout

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. Numerals, calendars, mirroring, and bidi are RTL *chrome* — never the muṣḥaf glyph layer.

## Primary

- `docs/engineering/12-localization-rtl-accessibility-impl.md` §2 (Direction is derived from the locale) — **The one rule that makes everything else correct by construction:** never hardcode an app-wide `Directionality`; RTL is a consequence of locale selection via `GlobalWidgetsLocalizations`. Feature code uses direction-relative APIs only (`EdgeInsetsDirectional`, `AlignmentDirectional`, `Positioned.directional`, `start`/`end`); physical sides are grep-banned in `features/**`. The two permitted manual islands: forced-LTR Latin token, and the Settings language preview. Logic reads `Directionality.of(context)`, never a `TextDirection.rtl` constant.

- `docs/engineering/12-localization-rtl-accessibility-impl.md` §4 (One bidi-isolation helper) — **Route every mixed-script run through one helper:** `isolate()` (FSI…PDI) for unknown direction, `isolateLtr`/`isolateRtl` (LRI/RLI…PDI) when direction is known — prefer the explicit ones because FSI first-strong mis-guesses on leading punctuation. Built on `intl`'s `Bidi` and the `Unicode` isolate constants (FSI U+2068, RLI U+2067, LRI U+2066, PDI U+2069). Raw concatenation of opposite-direction runs is banned; the helper is chrome-only and never touches muṣḥaf glyphs.

- `docs/engineering/12-localization-rtl-accessibility-impl.md` §5 (Locale numerals and regional terminology) — **Pin the numbering system; never trust the bare-locale default:** `numberFormatFor(locale)` uses `-u-nu-arabext` for fa/ckb (Extended Arabic-Indic U+06F0–U+06F9) and `-u-nu-arab` for ar (Arabic-Indic U+0660–U+0669), because `intl` emits Eastern digits in dates but not reliably in `NumberFormat`. ASCII digits are never concatenated into a localized string — format first, inject into an ICU placeholder. (The §5 term-set `select` mechanics belong to **eng-localization-arb-pipeline**.)

- `docs/engineering/12-localization-rtl-accessibility-impl.md` §8 (The localization & accessibility gate) — **Prove RTL/numerals with cheap, structural gates:** physical-side grep, ASCII-digit grep, and per-locale RTL + numeral golden screenshots — rendered on the **real** bundled UI fonts (so Sorani extra letters and Persian digits are exercised), never `Ahem`/a placeholder. RTL is testable on draft copy because direction follows the locale.

- `docs/design-system/12-localization-and-rtl.md` §1 (RTL by geometry, not a flipped flag) — **RTL is the default that must never break:** logical `start`/`end` everywhere; the bottom-nav RTL order (Today rightmost) and progress fills are the visual *result* of logical-order layout under RTL, not a manual reversal; RTL reading/focus order is a tested invariant. Translation is not localization — the geometry must flip, not just the words; an LTR-first screen "mirrored later" is a bug.

- `docs/design-system/12-localization-and-rtl.md` §2 (Mirror directional icons — and only directional ones) — **The mirroring table is authoritative:** mirror back/next/chevron/progress/sign-off and the page-turn *direction* (use the auto-mirroring `Icons.arrow_*` family); never mirror media-play/clock/phone/numerals; **never** mirror, flip, rotate, or reflect the muṣḥaf glyph page, ayah-end marker, or sajda sign. Mirroring everything is as wrong as mirroring nothing.

- `docs/design-system/12-localization-and-rtl.md` §3 (Mixed-direction text is isolated with FSI/PDI) — **The "page 7 of 30" → "30 of 7" bug is a bidi failure, not cosmetic:** wrap every embedded opposite-direction run in isolates; prefer isolating controls (LRI/RLI/FSI + PDI) over legacy embedding/override (LRE/RLE/LRO/RLO). Keep the value an isolated ARB **placeholder**, never a hard-spliced substring; keep the localized label in a single `Text`/`TextSpan`.

- `docs/design-system/12-localization-and-rtl.md` §4 (Numerals render in the locale's own digit set) — **`type.numeral` discipline:** fa/ckb → Extended Arabic-Indic, ar → Arabic-Indic, always via `intl` bound to the active locale; a locale switch reshapes every number with no string edits. The Quran's printed ayah numbers are the immutable glyph layer and are **never** re-rendered by `intl` — only UI-chrome numbers are shaped this way (the sacred/UI split).

## Supporting

- `docs/design-system/12-localization-and-rtl.md` §5 (Calendars are user-selectable) — **Calendar is a display transform over a single stored value:** offer Jalālī (default fa) / Hijri (Umm al-Qurā) / Gregorian as an explicit setting; week-start is CLDR data (Saturday for fa/ar), never hardcoded Monday/Sunday. This skill renders the converted date in RTL and remaps its digits; it does not convert.

- `docs/design-system/12-localization-and-rtl.md` §8 (The Quran is never localized — only the chrome) — **The boundary the toolkit must never cross:** no mirroring, `NumberFormat`, bidi control, UI font, or term-set reaches a glyph of the page; the reader honors zoom/theme by transforming the rendered glyph layer over fixed coordinates, never by re-shaping text.

- `docs/engineering/07-dates-calendars-and-correctness.md` §4 (Hijri/Jalālī/Gregorian are display-only, behind one presenter) — **Numerals are remapped downstream of the calendar conversion:** the `CalendarPresenter` (sibling-owned) converts first; this layer maps the Latin digits the calendar package emits to the locale set *after* conversion. The month name/era come from the calendar package's tables, not `intl`'s Gregorian-only `DateFormat`.

## Sibling skills

- **eng-localization-arb-pipeline** — the ARB / `gen_l10n` string pipeline, the `ckb` custom localizations delegate, ICU `plural`/`select`, the regional sabaq/sabqi/manzil term-sets, and 100% string-coverage hygiene (`impl-12` §1, §3, §5–§7) that this layout *localizes*.
- **eng-accessibility-implementation** — `Semantics` labels/hints, dynamic-text `textScaler`, contrast ≥ 4.5:1, the heat-map's non-color encoding, and ≥ 48 dp touch targets (`impl-12` §7) on the same widgets; RTL focus/reading order is the shared invariant.
- **domain-calendars-and-hifzdate** — the `CalendarDate` value type, integer day math, the instant-vs-civil-day split, calendar *conversion*, the `CalendarPresenter`, the injected "today", and the Hijri honesty note (`dates-07`) whose converted output this layer renders.
- **domain-mushaf-text-integrity** — the immutable Uthmani QPC glyph page, ayah markers, and sajda signs (`ds-12` §8) that this skill's mirroring/numeral/bidi/font toolkit never touches.
- **domain-claims-register-and-science-screen** — registering any user-facing factual claim surfaced in the chrome before it ships.
- **eng-add-feature-module** — where an RTL feature screen is assembled and its widget/golden tests live.
- **eng-write-dart-test** — the per-locale RTL + numeral golden screenshot harness (real bundled fonts, never `Ahem`).
