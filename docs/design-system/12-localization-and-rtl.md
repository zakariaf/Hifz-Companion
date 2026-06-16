# 12 — Localization & RTL

This file is Mihrab's RTL-and-localization contract: how the app is laid out right-to-left by its very geometry, which directional elements mirror and which never may, how mixed Latin/numeric runs are isolated so they read correctly, which digit set each locale renders, which calendars are offered, and how the regional *sabaq / sabqi / manzil* vocabulary becomes swappable string data. It owns no design tokens — it *constrains* and *directs* them: it tells [05-layout-spacing-touch.md](05-layout-spacing-touch.md) that every inset is logical (start/end), it tells [04-typography.md](04-typography.md) which scripts and `type.numeral` digit sets must render, it gives [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md) the RTL focus-order and bidi-isolation rules it audits, and it hands [11-voice-and-tone.md](11-voice-and-tone.md) the transcreated, region-aware term-sets it writes. The driving fact, from pillar 6 of the [README](README.md), is that fa/ckb/ar are **first-class RTL citizens, not a bolted-on mode** — legibility is governed by familiarity ("you read best what you read most"), so the chrome must read the way these users read every day ([Nedeljković et al., 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/)). The locked constraints — three RTL languages, locale numerals, locale calendars, localizable terminology — are [PRD §13](../PRD.md) and [PRD C4](../PRD.md); this file makes them precise, citable, and testable. The two evidence dossiers behind it are [research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md) and [research/arabic-persian-kurdish-typography.md](research/arabic-persian-kurdish-typography.md).

## At a glance

| Concern | Rule | Where enforced |
|---|---|---|
| Layout direction | `Directionality.rtl` app-wide; logical start/end insets only | §1 · [05](05-layout-spacing-touch.md) |
| Icon mirroring | mirror **directional** glyphs; never mirror media/clock/numerals/the muṣḥaf | §2 · [04](04-typography.md) |
| Mixed-direction text | Unicode FSI/PDI isolation around every embedded Latin/numeric run | §3 · [09](09-accessibility-and-inclusivity.md) |
| Numerals | Extended Arabic-Indic (۰۱۲۳) for fa/ckb; Arabic-Indic (٠١٢٣) for ar; via `intl` | §4 · `type.numeral` in [04](04-typography.md) |
| Calendars | Solar-Hijri/Jalālī (fa default), Hijri (Umm al-Qurā), Gregorian — user-selectable | §5 |
| Week start | locale-driven (Saturday for fa/ar) from CLDR, not hard-coded | §5 |
| Terminology | *sabaq/sabqi/manzil* are swappable ARB string-sets with a regional override | §6 · [11](11-voice-and-tone.md) |
| String hygiene | 100% ARB coverage; canonical ckb encoding; no hardcoded user strings | §7 · [04](04-typography.md) |
| The Quran | always the Uthmani QPC muṣḥaf regardless of UI locale — only chrome is localized | §8 · [13](13-islamic-identity-and-adab.md) |

---

## 1. The app is RTL by geometry, not by a flipped flag — logical direction app-wide

**Statement.** Mihrab runs with `Directionality(textDirection: TextDirection.rtl)` across the entire app and expresses every position as a **logical** start/end relationship, never a physical left/right. RTL is the native coordinate system — the *miḥrāb* points the way the script reads — so the layout is correct by construction rather than corrected after the fact.

**Evidence.**
- Material's bidirectionality guidance requires layout, padding, and icon decisions to use logical start/end properties (not hard-coded left/right) so a single direction flip produces a correct mirror, and mandates that RTL-script UIs lay content out right-to-left ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl); [Material: Bidirectionality](https://m2.material.io/design/usability/bidirectionality.html)).
- In Flutter, app-wide `Directionality(textDirection: TextDirection.rtl)` drives **both** visual layout **and** the semantic/focus order together, which is why a single declaration makes screen-reader traversal and the visible layout agree ([accessibility-test.org: RTL considerations](https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/); [research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md)).
- Serving an LTR layout to RTL users is a documented, compound failure: "primary content is on the wrong side, focus order does not match visual order, and directional icons point the wrong way" ([accessibility-test.org: RTL](https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/)).
- Flutter's localization is wired through `flutter_localizations` + the global delegates, and Material/Cupertino widgets adopt the correct LTR/RTL layout from the active locale automatically once those delegates and `supportedLocales` are declared ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)).

**In practice.**
- `MaterialApp` declares `localizationsDelegates` (`AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`) and `supportedLocales: [Locale('fa'), Locale('ckb'), Locale('ar')]`; because all three are RTL, the ambient `Directionality` is RTL in every supported locale ([PRD §13.2, §19.1](../PRD.md)).
- Spacing uses the logical `space.*` scale via `EdgeInsetsDirectional` / `AlignmentDirectional` and `start`/`end` everywhere — the rule and values live in [05-layout-spacing-touch.md](05-layout-spacing-touch.md); this file is the reason that rule exists.
- The bottom nav follows RTL order — rightmost is "home" (Today · Muṣḥaf · Mutashābihāt · Progress · Settings reads right-to-left) — matching [PRD §12](../PRD.md); list rows, chevrons, back/next, and progress fills all originate from `start`.
- Reading and focus order are a **tested invariant**: TalkBack/VoiceOver traversal must run right-to-left, top-to-bottom on Today, Muṣḥaf, and Progress, captured in the per-locale RTL golden-screenshot suite ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md); [PRD §20.5](../PRD.md)).

**Anti-patterns — we will never:**
- Hard-code `EdgeInsets.only(left:…)`, `Alignment.centerLeft`, or `Positioned(left:…)` for any directional placement; physical left/right is reserved only for genuinely physical things (a hardware-anchored element, never content).
- Ship an LTR layout "translated" into Persian/Kurdish/Arabic — translation is not localization; the geometry must flip, not just the words.
- Build a single screen LTR-first and "mirror it later"; RTL is the design baseline, and any LTR-only screen is a bug, not a phase.

---

## 2. Mirror directional icons — and only directional ones; the muṣḥaf is never mirrored

**Statement.** Icons and graphics that imply movement or sequence (back/next arrows, chevrons, progress fills, send) are **mirrored** in RTL; icons that depict a real-world object or follow a fixed convention (media play, clock, phone, numeral glyphs) and — above all — the sacred muṣḥaf glyph page are **never** mirrored. A curated mirroring table, not per-widget intuition, governs this.

**Evidence.**
- Material's bidirectionality rule is explicit: icons implying direction — back/forward arrows, chevrons, progress, send — should be **mirrored** in RTL, while icons referencing a real-world object or fixed convention — media playback (play points the same way), clocks, phone, numbers — must **not** be mirrored ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl); [Material: Bidirectionality](https://m2.material.io/design/usability/bidirectionality.html)). Mirroring everything is as wrong as mirroring nothing ([research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md)).
- The muṣḥaf page is a fixed glyph image of the printed page — the KFGQPC/QPC fonts are 604 per-page glyph fonts in which each glyph is a whole word, rendered without the OS shaper ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)) — so mirroring it is not a "directional" choice but an alteration of scripture, forbidden by the system's first outranking rule ([README](README.md); [PRD R1, §11.2](../PRD.md)).
- Page-turning in an Arabic-script book is already right-to-left, so the reader's swipe and any page-advance affordance follow RTL natively ([PRD §12.3](../PRD.md); [Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).

**In practice.**

| Element | Mirror in RTL? | Note |
|---|---|---|
| Back / next / "continue" arrow, chevron | **Yes** | Sequence/navigation; flips with `Directionality` (`Icons.arrow_back` is auto-mirrored) |
| Progress fill, today-list ordering, sign-off flow arrows | **Yes** | Progress runs start→end (= right→left) |
| Muṣḥaf page-turn affordance, reader swipe | **Yes (direction)** | RTL paging; the *page content itself* is the immutable glyph layer and is **not** mirrored |
| Media play / pause (optional reciter audio) | **No** | Play triangle points the same way in all locales |
| Clock, phone, numeral digit glyphs | **No** | Real-world / fixed-convention icons |
| The muṣḥaf glyph page, sajda mark, ayah-end marker | **Never** | Sacred glyph layer — altering it ends the project ([PRD R1](../PRD.md)) |

- Every directional decision flows from logical start/end so one `Directionality` flip mirrors the whole app correctly; the icon mirroring table is curated once in the design system and referenced by [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md) and the component library ([07-components.md](07-components.md)).
- Icon-only mirrored controls (back/next, sign-off) carry a localized semantic label in fa/ckb/ar so a screen reader names them correctly regardless of mirroring ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

**Anti-patterns — we will never:**
- Auto-mirror *every* icon "because the app is RTL" — a flipped play button, mirrored clock, or reversed phone glyph is a recognizability bug.
- Mirror, flip, rotate, or reflect the muṣḥaf page, an ayah marker, or a sajda sign for any visual goal; the glyph layer is transformed only by zoom/theme over fixed coordinates ([PRD §11.2](../PRD.md); [README](README.md) rule 1).
- Leave mirroring to chance per widget; if an icon's direction matters, it is in the mirroring table with an explicit yes/no.

---

## 3. Mixed-direction text is isolated with Unicode FSI/PDI, not left to chance

**Statement.** Every embedded opposite-direction run inside localized text — a page number, "Juz 7," a version string, a backup filename, a Latin technical token — is wrapped in **bidirectional isolation** so the Unicode bidi algorithm cannot reorder it. This is both a visual-correctness fix and a screen-reader-order fix.

**Evidence.**
- The Unicode Bidirectional Algorithm (UAX #9) defines **isolate** formatting characters — LRI, RLI, and **FSI** (First Strong Isolate), closed by **PDI** (Pop Directional Isolate) — and the standard's own guidance is that these **isolating** controls (RLI/LRI/FSI) should be used in preference to the older embedding/override controls (LRE/RLE/LRO/RLO) because they properly isolate a run from its surroundings ([Unicode: UAX #9 Bidirectional Algorithm](https://www.unicode.org/reports/tr9/)).
- Without isolation, embedded runs reorder incorrectly — the classic "page 7 of 30" rendering as "30 of 7" — and a screen reader can speak them in the wrong order, so this is an accessibility bug, not only a cosmetic one ([accessibility-test.org: RTL](https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/); [research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md)).
- Flutter/Dart's `intl` ships the tooling: the `Bidi` utility class (e.g. `enforceRtlInText` / `enforceLtrInText`) and `BidiFormatter` (whose `wrapWithUnicode` wraps a string in the correct directional markers for a known context) handle exactly this isolation around embedded runs ([Dart intl: Bidi class](https://api.flutter.dev/flutter/intl/Bidi-class.html); [Dart intl: BidiFormatter.wrapWithUnicode](https://api.flutter.dev/flutter/intl/BidiFormatter/wrapWithUnicode.html)); the W3C bidi authoring guidance is to isolate rather than embed mixed runs ([W3C i18n: Inline bidirectional text](https://www.w3.org/International/articles/inline-bidi-markup/)).
- Per-run **language/locale** must also be set so the screen reader picks the right pronunciation voice, exposed via `TextSpan.locale` and `MaterialApp.locale` ([Flutter: Assistive technologies](https://docs.flutter.dev/ui/accessibility/assistive-technologies)).

**In practice.**
- ARB messages keep the opposite-direction value as a **placeholder**, never a hard-spliced substring, so the generated `intl` formatter can isolate it — e.g. `"todayLabel": "{page} از {total}"` with `page`/`total` formatted (and digit-shaped) by `intl`, the LTR-shaped tokens isolated with FSI/PDI before composition.
- The recurring isolated runs in this app are: muṣḥaf page numbers and juz/ḥizb labels on the Today list and reader ([PRD §12.2–12.3](../PRD.md)), version strings and backup filenames in Settings/Backup ([PRD §16](../PRD.md)), and any Latin technical string surfaced to the user.
- Isolation is verified in the per-locale RTL golden screenshots and exercised by a TalkBack/VoiceOver pass in fa/ckb/ar so order is confirmed both visually and aurally ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md); [PRD §20.5](../PRD.md)).
- A localized label stays in a **single** `Text`/`TextSpan` (fragmenting an Arabic-script word to style part of it triggers diacritic-clipping/wrap bugs — see [04-typography.md](04-typography.md)); isolation wraps the *embedded token*, not the surrounding word.

**Anti-patterns — we will never:**
- Concatenate a raw ASCII number or Latin token directly into a localized string ("Juz " + n); every embedded run is a formatted, isolated placeholder.
- Use the legacy embedding/override controls (LRE/RLE/LRO/RLO) where the standard calls for isolates (LRI/RLI/FSI + PDI) ([Unicode: UAX #9](https://www.unicode.org/reports/tr9/)).
- Assume "Flutter handles bidi" and skip the golden-screenshot + screen-reader check; mixed-direction order is verified, not trusted.

---

## 4. Numerals render in the locale's own digit set, always via `intl`

**Statement.** Digits are shown in the reader's own numeral system: **Extended Arabic-Indic** (۰۱۲۳۴۵۶۷۸۹) for Persian and Kurdish-Sorani, **Arabic-Indic** (٠١٢٣٤٥٦٧٨٩) for Arabic. They are produced by `intl` number/date formatters bound to the active locale — never by hand-substituting ASCII digits. This is the `type.numeral` discipline.

**Evidence.**
- The PRD mandates locale digit sets — Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar — formatted through `intl` `NumberFormat` per locale, with raw ASCII digits never concatenated into localized strings ([PRD §13.3](../PRD.md)).
- Dart's `intl` `NumberFormat` is locale-aware for digit representation, decimal/group separators, percent and permille, and the locale's native digit shaping ([Dart intl: NumberFormat class](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html)). A documented caveat to test against: `intl` has historically shaped digits inconsistently between date formatting and plain number formatting for Arabic locales, so digit output must be **verified per surface**, not assumed uniform ([dart-lang/i18n issue #197: Arabic-locale digit handling](https://github.com/dart-lang/i18n/issues/197)).
- Rendering numerals in the locale set is also a screen-reader-correctness requirement so the spoken number is natural, not an English read-out of ASCII digits ([research/accessibility-rtl-inclusive.md](research/accessibility-rtl-inclusive.md); [Flutter: Assistive technologies](https://docs.flutter.dev/ui/accessibility/assistive-technologies)).

**In practice.**
- One owned token, `type.numeral`, names the locale digit set ([04-typography.md](04-typography.md)); page numbers, juz/ḥizb indices, retention percentages on the heat-map, daily-budget minutes, and dates all flow through `intl` formatters so they inherit the right glyphs automatically.
- Persian and Sorani share the Extended Arabic-Indic set (U+06F0–U+06F9); Arabic uses Arabic-Indic (U+0660–U+0669) — the formatter chooses the set from the locale, so a locale switch reshapes every number on screen with no string edits.
- Because of the known `intl` date-vs-number inconsistency, the CI per-locale numeral check asserts that **dates and numbers both** show the locale's digits in fa/ckb/ar, on the heat-map %, the Today list, and the calendar surfaces ([PRD §20.5](../PRD.md)).
- The **Quran's own ayah numbers** printed on the muṣḥaf page are part of the immutable glyph layer and are **not** re-rendered by `intl` — only *UI-chrome* numbers are localized this way (the sacred/UI split, §8 and [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md)).

**Anti-patterns — we will never:**
- String-replace ASCII digits into a localized sentence, or build "Page " + n.toString() — numbers are formatted, not spliced.
- Ship one numeral set for all three locales; fa/ckb (Extended Arabic-Indic) and ar (Arabic-Indic) are distinct and locale-driven.
- Re-typeset or overpaint the ayah numbers on the muṣḥaf page to "match the UI numeral set"; the printed page is immutable ([PRD R1](../PRD.md)).

---

## 5. Calendars are user-selectable: Solar-Hijri/Jalālī, Hijri (Umm al-Qurā), and Gregorian

**Statement.** The app offers three calendars — **Solar Hijri / Jalālī** (the default for Persian, and offered for Kurdish), **Hijri** (Umm al-Qurā), and **Gregorian** — and renders every user-facing date (next-due, last-reviewed) in the chosen calendar with the locale's numerals and week-start. Calendars are a display concern over a single, unambiguous stored instant.

**Evidence.**
- The PRD requires support for Hijri (Umm al-Qurā), Solar-Hijri/Jalālī (default for fa, offered for Kurdish), and Gregorian, user-selectable, with dates rendered in the chosen calendar and numerals, and week-start/formatting following the locale ([PRD §13.3](../PRD.md)).
- The Solar Hijri (Jalālī) calendar is the official calendar of Iran, observation-based on the vernal equinox (it begins each year at Nowrūz), and because its year-start is astronomically determined rather than fixed by rule it tracks the solar year with no intrinsic drift — more accurate, but harder to compute leap years for, than the Gregorian calendar ([Wikipedia: Solar Hijri calendar](https://en.wikipedia.org/wiki/Solar_Hijri_calendar)). It is also widely used in Afghanistan (legally adopted historically, with different month names) ([Wikipedia: Solar Hijri calendar](https://en.wikipedia.org/wiki/Solar_Hijri_calendar)).
- The **Umm al-Qurā** variant — Saudi Arabia's administrative Islamic calendar — is a standardized, deterministic algorithm available through Unicode CLDR/ICU as the `islamic-umalqura` calendar type (selected via the `-u-ca-islamic-umalqura` locale extension), the canonical choice when a specific Hijri reckoning is needed rather than a generic tabular one ([Unicode CLDR: islamic-umalqura data](https://github.com/unicode-cldr/cldr-cal-islamic-full); [ICU: IslamicCalendar (ISLAMIC_UMALQURA)](https://unicode-org.github.io/icu-docs/apidoc/released/icu4j/com/ibm/icu/util/IslamicCalendar.html)).
- Week-start is locale data, not a constant: CLDR's supplemental `weekData` records the first day of the week per territory, and for Iran/Arab locales that first day is **Saturday** (šanbe) — so the calendar grid and any week roll-up must read CLDR, not hard-code Monday/Sunday ([Unicode: LDML Part 4 — Dates / week data](https://unicode-org.github.io/cldr/ldml/tr35-dates.html)).

**In practice.**
- Timestamps are stored as a single UTC instant and a **calendar-date value** ([PRD §10.3](../PRD.md)); the calendar choice (Settings → calendar) is a pure *display transform*, so changing it never mutates engine state or due-dates — it only re-renders.
- The Settings calendar selector defaults to **Jalālī for fa** and offers Jalālī/Hijri/Gregorian to all locales; Arabic defaults can lead with **Umm al-Qurā Hijri**; the chosen calendar drives "next due / last reviewed" on the Today screen and Progress history ([PRD §12.2, §12.5](../PRD.md)).
- Date strings are produced by `intl`'s `DateFormat` for the active locale so month names, ordering, and digit set come for free; Jalālī/Hijri conversion uses a deterministic, well-tested calendar library (the calendar correctness contract lives in engineering — [PRD §19, engineering 07-dates-calendars](../PRD.md)) and is verified by golden tests so identical inputs yield identical displayed dates.
- Week-start is read from CLDR (`firstDay`) per locale (Saturday for fa/ar), so any week grouping in Progress aligns with how the user's week actually runs ([Unicode: LDML Part 4 — Dates](https://unicode-org.github.io/cldr/ldml/tr35-dates.html)).

**Anti-patterns — we will never:**
- Store a wall-clock date or let the chosen calendar alter the underlying instant; the calendar is presentation, the stored value is a single unambiguous date ([PRD §10.3](../PRD.md)).
- Hard-code a Gregorian grid, a Monday/Sunday week-start, or English month names and "translate" them; calendar, week-start, and month names are locale data.
- Approximate Jalālī or Hijri conversion with ad-hoc arithmetic; conversions are library-backed and golden-tested, because a wrong "due date" erodes the whole trust contract ([PRD §7.6, §19.3](../PRD.md)).

---

## 6. The *sabaq / sabqi / manzil* vocabulary is swappable string data with a regional override

**Statement.** The traditional track names, grade verbs, and cycle names are **string resources**, not hard-coded labels, because this vocabulary is regional — what one community calls *manzil* another calls *dhor*. Each locale ships a default term-set, and the user can switch a regional override; swapping a whole term-set is a single-file edit.

**Evidence.**
- The PRD specifies that the *sabaq/sabqi/manzil* vocabulary is regional, that track labels, grade verbs, and cycle names are string resources with region-appropriate default sets the user can switch, and that the architecture must make swapping a term-set trivial (one ARB/JSON file per locale plus an optional regional override) ([PRD §13.4](../PRD.md)). The illustrative mapping it gives — e.g. Far-revision = المراجعة البعيدة / المنزل (ar), مرور دور / منزل (fa), پێداچوونەوەی دوور / مەنزڵ (ckb) — is a *default*, not a fixed string.
- The Kurdish (Sorani) terms are explicitly flagged as placeholders pending **native-speaker and scholarly review** before defaults are locked ([PRD §13.4, §21.1](../PRD.md)), so the term-set mechanism must tolerate later correction without code change.
- Correct, idiomatic regional wording is not cosmetic: controlling or alien framing provokes reactance and erodes the "a teacher recognizes this day" trust that the whole product rests on ([Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x); [README](README.md) pillar 3). Transcreation, not literal translation, is the standard ([11-voice-and-tone.md](11-voice-and-tone.md)).

**In practice.**
- Term-sets are addressed by a logical key (e.g. `track.far`, `grade.again`, `cycle.weeklyKhatm`) and resolved through ARB; a `term_label_set` / `region_preset` on `cycle_config` ([PRD §10.2, §15.2](../PRD.md)) selects the regional override layered on top of the locale's base ARB.
- The Settings term-set selector lets a user pick the regional vocabulary independently of the UI language — a Sorani speaker can choose the *mەنزڵ* set; an Arabic speaker can choose *المنزل* vs *الدّور* phrasing — without changing anything else ([PRD §15.2](../PRD.md)).
- The four-grade scale (Again/Hard/Good/Easy) shows the localized **traditional verb** ("needed help," "minor mistakes," "recited clean," "effortless" — [PRD §6.3](../PRD.md)) drawn from the active term-set; the underlying engine signal is unchanged, only the surface words differ.
- Because ckb defaults are provisional, the ckb term ARB is annotated "needs native + scholar review" and is updatable as a data-only change; this couples to the canonical-encoding rule (§7) so the Sorani strings are well-formed before they ship.

**Anti-patterns — we will never:**
- Hard-code "Manzil," "Sabqi," or any track/grade/cycle label in a widget; every user-facing term is an ARB key with a regional override.
- Force one region's vocabulary on every locale, or present a regional default as the only correct term — the day must look like the day *this* user's teacher recognizes.
- Lock the ckb term-set before native-speaker and scholarly review; until then it ships clearly marked as provisional ([PRD §21.1](../PRD.md)).

---

## 7. String discipline: 100% ARB coverage, canonical Sorani encoding, no hardcoded strings

**Statement.** Every user-facing string lives in an ARB file via Flutter `gen_l10n`; coverage is gated at 100% with no missing keys and no hardcoded strings; and the Kurdish-Sorani strings are authored with **canonical Unicode encoding** so the bundled font is never asked to render malformed input.

**Evidence.**
- The PRD requires Flutter `gen_l10n` with ARB files per locale, a 100% coverage gate in CI (no missing keys, no hardcoded user-facing strings), and ICU plural/gender handling where a language needs it ([PRD §13.6, §20.5](../PRD.md)). Flutter's i18n workflow drives exactly this: ARB template + `l10n.yaml` generate the typed `AppLocalizations` accessor ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)).
- Sorani's orthography is the encoding risk: it is "almost a true alphabet in which vowels are given the same treatment as consonants," and real-world Sorani text carries encoding noise — non-standard ZWNJ (U+200C) from bad conversions, and Teh-Marbuta (ة) substituted where the AE letter (ە, U+06D5) belongs ([Wikipedia: Kurdish alphabets](https://en.wikipedia.org/wiki/Kurdish_alphabets); [Wikipedia: Kurdish typography](https://en.wikipedia.org/wiki/Kurdish_typography)). The h-sound and the æ-vowel are also encoded inconsistently (U+06BE vs U+0647; U+06D5 vs a U+0647+U+200C hack) ([r12a/W3C: Sorani notes](https://r12a.github.io/scripts/arab/ckb.html)).
- Coverage is also a *familiarity* requirement: a missing or English-fallback string breaks the "read what you read most" comfort and signals a bolted-on locale ([Nedeljković et al., 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/); [research/arabic-persian-kurdish-typography.md](research/arabic-persian-kurdish-typography.md)).

**In practice.**
- ckb ARB strings are authored with **U+06D5 (ە)** for AE, **U+06A9 (ک)** for kaf, and the chosen HEH (U+06BE); a lint step rejects stray U+200C and any Teh-Marbuta-for-AE substitution before the build, so the bundled UI font (whose Sorani coverage is CI-verified — [04-typography.md](04-typography.md)) only ever receives well-formed text.
- The CI localization gate fails the build on any missing ARB key, any user-facing string found outside ARB, and any malformed ckb codepoint; this sits alongside the RTL golden-screenshot and numeral/calendar checks ([PRD §20.5](../PRD.md)).
- Pluralization and gender use ICU messages in ARB where the language needs it, so counts ("3 pages," "۳ صفحه") agree grammatically per locale ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)).
- Strings are authored as transcreations reviewed for adab and tone, not machine-translated literally ([11-voice-and-tone.md](11-voice-and-tone.md)); the ckb set remains marked provisional pending native + scholarly review ([PRD §21.1](../PRD.md)).

**Anti-patterns — we will never:**
- Ship a user-facing literal outside ARB, or let a key fall back to English at runtime — both fail the §20.5 gate.
- Author ckb with the heh+ZWNJ AE hack or a Teh-Marbuta where ە belongs; canonical encoding is enforced, so the font never has to "guess."
- Treat a translation as done without a per-locale RTL golden screenshot confirming the rendered, isolated, digit-shaped result.

---

## 8. The Quran is never localized — only the chrome is

**Statement.** Whatever the UI language, the Quran is **always** the Uthmani muṣḥaf rendered through the bundled QPC per-page glyph fonts; only the interface chrome is localized. There is no in-app translation, transliteration, or re-typesetting of the Quran for any locale.

**Evidence.**
- The PRD is explicit: the Quran text is always the Uthmani muṣḥaf via QPC fonts regardless of UI language — only the UI chrome is localized, and the Quran is never "translated" in-app ([PRD §13.1, R2](../PRD.md)). Zero bundled tafsīr, translation, or commentary ships, because it inevitably encodes a school of thought ([PRD R2](../PRD.md)).
- The muṣḥaf is rendered glyph-only — 604 per-page KFGQPC/QPC fonts, each glyph a whole word, mapped through the Private Use Area and drawn without the OS shaper ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)) — so it sits in a rendering pipeline entirely separate from the localized UI type ([04-typography.md](04-typography.md)). "You read best what you read most" cuts both ways: the page must keep its long-familiar Madani forms (a memory cue for the ḥāfiẓ), while the chrome reads as ordinary modern script ([Nedeljković et al., 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/)).
- The muṣḥaf in use is always stated as "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf," never as "the Quran" in the absolute ([PRD R2](../PRD.md); [README](README.md) rule 1).

**In practice.**
- Localizing the app changes buttons, labels, dates, numerals, and term-sets — never a single glyph of the page; the reader shows the same immutable muṣḥaf to a Persian, Kurdish, and Arabic user alike ([PRD §12.3](../PRD.md); [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md)).
- The riwāyah statement and surah/juz chrome around the page are localized (their *labels* are ARB strings and their *numbers* are `intl`-shaped, §4), but the page content, ayah markers, and sajda signs are the fixed glyph layer ([PRD §11.2](../PRD.md)).
- This is the sacred/UI boundary that [04-typography.md](04-typography.md) and [13-islamic-identity-and-adab.md](13-islamic-identity-and-adab.md) own; this file's job is to ensure no localization mechanism (mirroring, numerals, calendar, term-sets) ever reaches across it.

**Anti-patterns — we will never:**
- Translate, transliterate, gloss, or re-typeset the Quran for any locale, or bundle tafsīr/translation/commentary ([PRD R2](../PRD.md)).
- Apply UI numerals, UI fonts, or mirroring to the muṣḥaf glyph page; the localization toolkit stops at the chrome ([PRD R1, §11.2](../PRD.md)).
- Present the muṣḥaf as "the Quran" in the absolute rather than as the stated riwāyah and edition ([PRD R2](../PRD.md)).

---

## References

- accessibility-test.org. *RTL (Right-to-Left) Website Accessibility Considerations* (focus order matches visual order; directional icons; reading order). https://accessibility-test.org/blog/support/rtl-right-to-left-website-accessibility-considerations/
- Dart `intl` package. *Bidi class — intl library, Dart API* (`enforceRtlInText` / `enforceLtrInText`; bidi isolation utilities). https://api.flutter.dev/flutter/intl/Bidi-class.html
- Dart `intl` package. *BidiFormatter.wrapWithUnicode — intl library, Dart API* (wrap a run in directional markers for a known context). https://api.flutter.dev/flutter/intl/BidiFormatter/wrapWithUnicode.html
- Dart `intl` package. *NumberFormat class — intl library, Dart API* (locale-aware digit representation, separators, percent/permille). https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html
- dart-lang/i18n. *Issue #197 — odd handling of Arabic locales and their digits* (date- vs number-formatting digit inconsistency; verify per surface). https://github.com/dart-lang/i18n/issues/197
- Flutter. *Internationalizing Flutter apps* (`flutter_localizations`, `intl`, `gen_l10n`/ARB, `l10n.yaml`, `supportedLocales`, automatic LTR/RTL). https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Flutter. *Accessibility — Assistive technologies* (Semantics tree; `TextSpan.locale` / `MaterialApp.locale` for per-run language). https://docs.flutter.dev/ui/accessibility/assistive-technologies
- ICU (Unicode). *IslamicCalendar (ICU4J)* — ISLAMIC_UMALQURA calculation type / `islamic-umalqura`. https://unicode-org.github.io/icu-docs/apidoc/released/icu4j/com/ibm/icu/util/IslamicCalendar.html
- Material Design 3. *Bidirectionality & RTL* (mirror directional icons; do not mirror media/clock/numbers; logical start/end properties; RTL layout). https://m3.material.io/foundations/layout/bidirectionality-rtl
- Material Design. *Bidirectionality* (icon-mirroring rules; text alignment; logical properties). https://m2.material.io/design/usability/bidirectionality.html
- Miller, C. H., Lane, L. T., Deatrick, L. M., Young, A. M., & Potts, K. A. (2007). Psychological Reactance and Promotional Health Messages. *Human Communication Research*, 33(2), 219–240. https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x
- Nedeljković, U., Jovančić, K., & Pušnik, N. (2020). You read best what you read most: An eye tracking study. *Journal of Eye Movement Research*, 13(2). https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/
- Quranic Universal Library (QUL), Tarteel. *Glyph-Based Fonts* (604 per-page KFGQPC/QPC fonts; each glyph a whole word; renders without OS shaping). https://qul.tarteel.ai/docs/glyph-based
- r12a / W3C i18n. *Sorani (Central Kurdish, ckb) orthography notes* (U+06D5 AE over heh+ZWNJ; U+06BE vs U+0647 heh; U+06A9 kaf). https://r12a.github.io/scripts/arab/ckb.html
- Unicode Consortium. *UAX #9: Unicode Bidirectional Algorithm* (isolate formatting characters LRI/RLI/FSI + PDI; prefer isolates over embeddings/overrides). https://www.unicode.org/reports/tr9/
- Unicode CLDR. *cldr-cal-islamic-full — `ca-islamic-umalqura` data* (Umm al-Qurā calendar locale data). https://github.com/unicode-cldr/cldr-cal-islamic-full
- Unicode CLDR. *LDML Part 4: Dates* (calendars; supplemental `weekData` / first day of week per territory). https://unicode-org.github.io/cldr/ldml/tr35-dates.html
- W3C i18n. *Creating HTML pages in Arabic, Hebrew and other right-to-left scripts / inline bidirectional markup* (isolate mixed-direction runs). https://www.w3.org/International/articles/inline-bidi-markup/
- Wikipedia. *Kurdish alphabets* (Sorani Arabic-based alphabet; vowels as letters; ک U+06A9 vs ك U+0643). https://en.wikipedia.org/wiki/Kurdish_alphabets
- Wikipedia. *Kurdish typography* (non-standard U+200C from bad conversions; Teh-Marbuta-for-AE substitution). https://en.wikipedia.org/wiki/Kurdish_typography
- Wikipedia. *Solar Hijri calendar* (official calendar of Iran; observation-based on the vernal equinox; begins at Nowrūz; no intrinsic drift vs Gregorian). https://en.wikipedia.org/wiki/Solar_Hijri_calendar
