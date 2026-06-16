# E09-T06 — numerals.dart: numberFormatFor(locale) with pinned -u-nu-arabext/-u-nu-arab + ASCII-digit grep + per-locale numeral goldens (test-first)

| | |
|---|---|
| **Epic** | [E09 — Localization & RTL Foundation](EPIC.md) |
| **Size** | M (≈1–2 days) |
| **Depends on** | E09-T01, E06 |
| **Skills** | eng-rtl-and-bidi-layout, eng-write-dart-test |

## Goal

`packages/l10n/lib/src/numerals.dart` exposes `numberFormatFor(Locale locale)` — the **one** numeral path for all chrome numbers — returning a `NumberFormat` whose numbering system is **pinned by an explicit Unicode `-u-nu-` extension**: Extended Arabic-Indic (`-u-nu-arabext`, U+06F0–U+06F9 `۰۱۲۳۴۵۶۷۸۹`) for `fa` and `ckb`, Arabic-Indic (`-u-nu-arab`, U+0660–U+0669 `٠١٢٣٤٥٦٧٨٩`) for `ar` — never the bare-locale default, which `intl` shapes inconsistently between date and number formatting. A number is **formatted, then injected into an ICU placeholder** (never ASCII-concatenated into a localized string), and the grep that bans raw-int interpolation into `Text`/ARB goes live over `features/**`. Written **test-first**: a per-locale numeral golden and a unit suite assert the exact Unicode digit block per locale (U+06F0-range for fa/ckb, U+0660-range for ar) on chrome numbers — and the toolkit never re-renders the muṣḥaf's printed ayah numbers (chrome only).

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §5 | The verbatim `numberFormatFor(Locale)` shape: a `switch` on `languageCode` → `'fa-u-nu-arabext'` / `'ckb-u-nu-arabext'` / `'ar-u-nu-arab'` (fallback `'en'`), `NumberFormat.decimal(tag)`; **why** the numbering system is pinned (the dart-lang/i18n #197 date-vs-`NumberFormat` inconsistency); a number is formatted then placed in an ICU placeholder, never raw ASCII; the ASCII-digit grep; the sacred boundary (ayah numbers/juz·ḥizb markers on the page come from the immutable glyph layer, never `NumberFormat`) |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §8 | The gate this task feeds: the **ASCII-digit grep** layer (raw int interpolation into `Text`/ARB) and the **per-locale RTL + numeral golden** layer, rendered on the **real** bundled UI fonts (never `Ahem`) so Persian digits are actually exercised |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §4 | A locale number is a **known-direction** run: format via `numberFormatFor`, then isolate the token with `bidi.dart`'s `isolateLtr`/`isolateRtl` before injection (the `juzLabel` exemplar) — numerals feed bidi isolation, they do not replace it |
| `docs/design-system/12-localization-and-rtl.md` §4 | `type.numeral` discipline: two distinct, non-interchangeable Unicode blocks; `۴۵۶` not `٤٥٦` for a Persian reader is a defect; numbers are *formatted, not spliced* ("Page " + n is banned); only **UI-chrome** numbers are `intl`-shaped — the page's ayah numbers are never re-rendered |
| `docs/design-system/12-localization-and-rtl.md` §8 | The sacred/chrome boundary `numberFormatFor` never crosses: the muṣḥaf is always the immutable QPC glyph page; no `NumberFormat` reaches a glyph, ayah marker, or sajda sign |
| `docs/design-system/11-voice-and-tone.md` §8 | One voice across fa/ar/ckb is transcreation, not literal carry-over — the *numeral set* is part of "reading the way these users read every day"; rendering the wrong digit block breaks the familiarity the voice depends on |
| Skill `eng-rtl-and-bidi-layout` (rule 7; `template.dart`) | The canonical pinned-`numberFormatFor` pattern: per-locale `NumberFormat` with the explicit `-u-nu-` numbering system, ASCII-digit refusal, format→isolate→inject, the chrome-only boundary; the `template.dart` scaffold has the `numberFormatFor` stub and the per-locale numeral golden stub |
| Skill `eng-write-dart-test` (§6 real-font goldens; §7 RTL-per-locale; §8 offline; `template.dart`) | Goldens load the **real** bundled UI fonts via `FontLoader` in `setUpAll` (never `Ahem`), pin `devicePixelRatio`/`physicalSize`/theme, disable animations, `@Tags(['golden'])` for the pinned golden CI job; pump each locale under `Directionality.rtl`; the throwing-`HttpOverrides` offline guard; REUSE SPDX header; assert behaviour (exact codepoints), never lines |
| CLAIMS register | **None attach by construction.** This task is pure chrome — it digit-shapes an already-supplied integer; it originates no user-facing factual number, scheduling rule, or methodology claim. The *value* of any count (pages due, retention %, day-count) is produced upstream by the feature/engine epic that owns the claim (domain-claims-register-and-science-screen); this task only renders its digits in the locale block |
| Sibling: **E01-T04** | Stood up `packages/l10n` and the `numerals.dart` **stub** (alongside `bidi.dart`/`ckb_material_localizations.dart` stubs) plus the `lib/l10n.dart` barrel — this task fills the `numerals.dart` body and confirms the barrel re-exports `numberFormatFor` |
| Sibling: **E09-T01** | Authored the `juzLabel` (`{juz}` `String`) and `pagesDue` (six-category `plural`, `count` `int`) ARB exemplars that *consume* this formatter; the `juzLabel` placeholder receives an already-formatted, already-isolated token from here — this task makes "format → isolate → inject" real for those keys |
| Sibling: **E09-T05** (`bidi.dart`) | Supplies `isolate`/`isolateLtr`/`isolateRtl`; a chrome number is formatted here then isolated there before injection. This task does **not** re-implement isolation — it produces the digit string the isolator wraps |
| Sibling: **E09-T02** (gate) | Owns wiring the ASCII-digit grep (and the other layers) into the CI gate over `features/**`; this task **authors** the grep pattern + its proven-violation fixture and hands it to T02 — keep one source of truth for the pattern |
| Sibling: **E09-T08** (calendar-display) | Renders E02's converted `(y,m,d)` by re-mapping its Latin digits **through this formatter**, downstream of conversion, then isolating the run — this task's `numberFormatFor` is the digit transform that layer calls; conversion is not here |
| Sibling: **E09-T10** (golden suite) | Aggregates the full per-locale RTL + numeral golden suite into the green CI gate on the real bundled fonts; this task lands the **numeral** goldens (the exact-digit-block assertions) that T10 folds in |
| Sibling: **E06** (mihrab-foundation) | Supplies the calm-palette tokens, the `type.numeral` UI typography token, and the **bundled Perso-Arabic / Sorani-covering UI fonts** the goldens render with (never `Ahem`, never `google_fonts`) — this task's goldens depend on E06's real fonts being loadable via `FontLoader` |

## Implementation notes

**TEST-FIRST (correctness-critical).** `numberFormatFor` is a small function whose *output codepoints* are the whole point — the exact-digit-block unit suite and the per-locale numeral golden below are written **first** and must fail (against the empty E01-T04 stub) before the body is filled. The failure mode this guards (a Persian reader shown `٤٥٦` instead of `۴۵۶`) is invisible to a human reviewer skimming Dart and only caught by asserting codepoints.

1. **File**: `packages/l10n/lib/src/numerals.dart` (fill the E01-T04 stub), `import 'package:intl/intl.dart';`, REUSE SPDX header (`GPL-3.0-or-later`). One public function, `///`-documented as *the single chrome numeral path* (eng-write-to-coding-standards §4). The barrel `lib/l10n.dart` re-exports it; no feature imports `src/numerals.dart` directly.
2. **`numberFormatFor`** — the verbatim engineering 12 §5 shape, pinned numbering system, no sublocale guessing:
   ```dart
   /// The single chrome numeral formatter. Pins the numbering system explicitly
   /// because intl's bare-locale Arabic-digit default is inconsistent between
   /// date and number formatting (dart-lang/i18n #197). Chrome only — never the
   /// muṣḥaf's printed ayah numbers (engineering 12 §5; design 12 §4, §8).
   NumberFormat numberFormatFor(Locale locale) {
     final tag = switch (locale.languageCode) {
       'fa'  => 'fa-u-nu-arabext',  // Extended Arabic-Indic ۰۱۲۳۴۵۶۷۸۹ (U+06F0..)
       'ckb' => 'ckb-u-nu-arabext', // Sorani shares the Extended set
       'ar'  => 'ar-u-nu-arab',     // Arabic-Indic ٠١٢٣٤٥٦٧٨٩ (U+0660..) — pinned, not default
       _     => 'en',
     };
     return NumberFormat.decimal(tag);
   }
   ```
   Use named constant strings for the four tags (no magic literals scattered); keep the fallback `'en'` (ASCII) for an unsupported/test locale — the three shipping locales never reach it.
3. **Numerals feed bidi, they do not replace it.** The intended call shape is **format → isolate → inject**: `final juz = isolateLtr(numberFormatFor(locale).format(juzNumber)); Text(l10n.juzLabel(juz));`. A chrome number is a *known-direction* run, so the call site uses `isolateLtr`/`isolateRtl` from E09-T05's `bidi.dart` (not `isolate`/FSI) before placing the token in the ICU placeholder (engineering 12 §4). This task supplies the formatter; the isolation is `bidi.dart`'s. Do **not** add a "convenience" helper here that concatenates digits into a label — that re-introduces the splice the gate bans.
4. **ASCII-digit grep — author the pattern + the proven-violation fixture here; T02 wires it.** The grep flags raw-int interpolation into a `Text`/ARB value (`'$count '`, `'Page ' + n.toString()`, `'${pageNumber}'` inside a `Text`/`l10n.*` arg) anywhere in `features/**`, requiring every user-facing number to pass through `numberFormatFor(locale)` first (engineering 12 §5, §8). Per `eng-add-ci-check`, prove the grep against a deliberate violation (a committed throwaway fixture or an inline test asserting the grep exits non-zero on a planted `Text('$count')`), so a grep that matches nothing cannot pass green. Keep the **pattern itself** as the single source of truth and hand it to E09-T02's gate wiring — do not fork it.
5. **The sacred boundary is structural, not a comment.** `numberFormatFor` is chrome-only: it is called from Today / Progress / Settings / calendar-display, **never** from the muṣḥaf reader. The page's printed ayah numbers, juz/ḥizb markers, and sajda signs are the immutable glyph layer (E05), never re-rendered by `intl` (engineering 12 §5; design 12 §4, §8). There is nothing to *add* to enforce this here beyond never wiring the formatter into the reader — note it at the call-site boundary and let the muṣḥaf golden (E05) prove the glyphs are untouched.
6. **No clock, no network, no engine import.** This is pure presentation over `intl`: no `DateTime.now()`, no socket, no `google_fonts`. `numerals.dart` imports only `dart:ui`'s `Locale` (via `flutter`) and `package:intl`; it must not import `/engine`, Drift, or any feature.
7. **Pitfalls to avoid**: relying on the bare-locale default (`NumberFormat.decimal('fa')`) and assuming Persian digits — that is exactly the #197 inconsistency the pin defeats; using the **Arabic** block for fa/ckb or the **Extended** block for ar (the two are different codepoints even where 0/1/2 glyphs look alike — assert 4/5/6, where they visibly differ); concatenating ASCII digits into a localized string instead of formatting-then-injecting; isolating the run *here* (that is `bidi.dart`'s job — keep the layers separate); rendering the numeral golden with `Ahem`/a placeholder font (it would render every digit as a square and assert nothing — load the **real** bundled UI font); letting the formatter touch a muṣḥaf glyph or an ayah number; introducing a second numeral helper that splices.

## Acceptance criteria

- [ ] `packages/l10n/lib/src/numerals.dart` exists with a single public, `///`-documented `NumberFormat numberFormatFor(Locale locale)`; the `lib/l10n.dart` barrel re-exports it; no feature imports `src/numerals.dart` directly (grep-verifiable).
- [ ] `numberFormatFor` pins the numbering system by explicit `-u-nu-` tag — `fa`/`ckb` → `*-u-nu-arabext`, `ar` → `*-u-nu-arab`, fallback `'en'` — and never relies on a bare-locale default.
- [ ] For `fa` and `ckb`, `numberFormatFor(...).format(n)` emits only **Extended Arabic-Indic** digits in U+06F0–U+06F9; for `ar`, only **Arabic-Indic** digits in U+0660–U+0669 — asserted by codepoint on digits 0–9 including 4/5/6 (where the blocks visibly differ).
- [ ] No ASCII digit appears in any localized `fa`/`ckb`/`ar` chrome number; the ASCII-digit grep pattern is authored, proven against a deliberate violation (exits non-zero), and handed to E09-T02 as the single source of truth.
- [ ] The intended call shape is **format → isolate (via `bidi.dart`) → inject into an ICU placeholder**; `numerals.dart` adds no concatenating/splicing helper of its own.
- [ ] `numberFormatFor` is reachable only from chrome surfaces; it is never called from the muṣḥaf reader, and no key/`@description`/numeral reaches a glyph or an ayah number (the boundary is held by construction and noted at the call site).
- [ ] `numerals.dart` imports only `flutter` (`Locale`) + `package:intl`; no `/engine`, Drift, feature, `DateTime.now()`, network, or `google_fonts` import.

## Tests

Written **test-first**, REUSE SPDX header on every file, deterministic (fixed locales, fixed integers, no clock, no network).

`packages/l10n/test/numerals_test.dart` (`flutter_test`, fast lane, every PR):

- **Exact digit block per locale (the load-bearing case).** For `Locale('fa')` and `Locale.fromSubtags(languageCode: 'ckb')`, assert `numberFormatFor(locale).format(n)` for `n` covering each digit 0–9 (e.g. `1234567890`, plus `456`) contains **only** codepoints in U+06F0–U+06F9 and **no** codepoint in U+0660–U+0669 and **no** ASCII `0x30–0x39`. For `Locale('ar')`, the mirror: only U+0660–U+0669, none in the Extended block, no ASCII. Assert the visibly-distinct 4/5/6 explicitly (the #197/Eastern-Arabic distinction).
- **Pin defeats the bare-locale default.** Assert `numberFormatFor(Locale('ar'))` produces U+0660-range digits (not the Latin/bare default some `ar` sublocales fall back to) and `numberFormatFor(Locale('fa'))` produces U+06F0-range — i.e. the explicit `-u-nu-` tag, not the inconsistent default, governs.
- **Fallback is ASCII.** `numberFormatFor(Locale('en')).format(7)` is the ASCII `7` — the unsupported-locale path is explicit, and the three shipping locales never hit it.
- **Format → isolate → inject round-trips (integration with `bidi.dart`).** Format a juz number, wrap with `isolateLtr` (E09-T05), inject into `l10n.juzLabel(token)` (E09-T01); assert the resulting string contains the locale-digit token between `LRI`/`PDI` and that the digits are the correct block — proving the three layers compose without re-rendering or splicing.

`packages/l10n/test/numerals_grep_test.dart` (or the gate-script fixture; coordinate with E09-T02):

- **ASCII-digit grep catches a planted violation.** Run the authored grep pattern over a fixture containing `Text('$count pages')` / `'Page ' + n.toString()` and assert it exits non-zero (the grep matches a real violation, so it cannot pass by checking nothing); assert it exits zero over a compliant `Text(l10n.pagesDue(formatted))`.

`packages/l10n/test/goldens/numerals_golden_test.dart` (`flutter_test`, `@Tags(['golden'])`, pinned golden CI job):

- **Per-locale numeral golden on the real bundled fonts.** In `setUpAll`, load the **real** E06 bundled UI font(s) via `FontLoader` (never `Ahem`). Pump a minimal chrome strip (e.g. a "Juz N · Page M" line and a retention "P%" using `numberFormatFor`) under `Directionality(textDirection: TextDirection.rtl)` once per locale `[ar, fa, ckb]`, pinning `devicePixelRatio`/`physicalSize`/theme and disabling animations; `await expectLater(find.byType(...), matchesGoldenFile('goldens/numerals_<locale>.png'))`. The `fa`/`ckb` masters show `۰۱۲…` (U+06F0..); the `ar` master shows `٠١٢…` (U+0660..) — a digit-block regression changes pixels and fails the build. Masters regenerated with `--update-goldens` **locally** only; CI never blesses. (E09-T10 folds these into the full suite.)

Offline / no-network guard: the shared throwing-`HttpOverrides` bootstrap (E01-T06) covers `packages/l10n`; `intl` formatting and `FontLoader` over bundled assets touch no socket — any stray connection is a loud, named failure. No font is fetched at runtime (no `google_fonts`).

## Definition of Done

- [ ] All acceptance criteria met; `numerals_test.dart`, the grep fixture, and `numerals_golden_test.dart` green locally and in CI (unit on every PR, golden in the pinned golden job); the unit + golden cases existed and **failed against the stub before** `numberFormatFor` was implemented (test-first proven in the PR history).
- [ ] **Offline / no-network preserved:** nothing here opens a socket or fetches a font/locale at runtime; `intl` is local, fonts are E06's bundled assets loaded via `FontLoader`, no `google_fonts`, no second `l10n.yaml` (PRD C1, §13.5, §19.3).
- [ ] **No AI / no microphone:** no ML/translation-service/ASR dependency introduced; no audio or recognition path touched; digit shaping is pure `intl` (PRD C2).
- [ ] **Quran text fidelity / sacred boundary held:** `numberFormatFor` is chrome-only — no numeral, key, or formatter reaches a muṣḥaf glyph; the page's printed ayah numbers, juz/ḥizb markers, and sajda signs are the immutable glyph layer (E05), never re-rendered by `intl`; the reader is never wired to this formatter (PRD R1, R2, §11.2, §13.1; design 12 §4, §8).
- [ ] **RTL + fa/ckb/ar strings structural:** `fa`/`ckb` render Extended Arabic-Indic (U+06F0..) and `ar` renders Arabic-Indic (U+0660..), proven by codepoint assertions **and** the per-locale numeral goldens on the real bundled fonts; the ASCII-digit grep is green over `features/**`; numbers are formatted-then-isolated-then-injected, never ASCII-spliced (PRD C4, §13.3, §20 gate 5; design 12 §4).
- [ ] **Accessibility seam respected:** locale digits render in the reader's own block so a screen reader speaks a natural number (not an English read-out of ASCII), feeding E08's TalkBack/VoiceOver pass; goldens use the real fonts (Persian/Sorani digits actually exercised, never `Ahem`); this task introduces no streak/score/shame surface.
- [ ] **Sect-neutral adab:** the task originates no user-facing copy — it shapes digits of values authored elsewhere; it adds no never-ship phrase, no fiqh ruling, and speaks for no one; rendering the correct numeral block is part of the calm, familiar register the voice charter requires (design 11 §8).
- [ ] **Deterministic tests:** all cases use fixed locales and fixed integers, no `DateTime.now()`, no network, no clock; goldens pin DPR/size/theme and disable animations; masters are the committed artifacts, regenerated only by a reviewed local `--update-goldens` run, never blessed in CI.
- [ ] **No CLAIMS attach by construction:** this task digit-shapes an already-supplied integer and originates no factual number, scheduling rule, or methodology claim; the value of any count is registered by the feature/engine epic that authors it (domain-claims-register-and-science-screen), and this task renders only its digits.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
