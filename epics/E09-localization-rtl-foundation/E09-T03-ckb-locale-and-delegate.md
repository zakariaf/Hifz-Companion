# E09-T03 — ckb custom locale + vendored CkbMaterialLocalizations delegate + canonical-Sorani encoding lint + ckb-dialog widget test

| | |
|---|---|
| **Epic** | [E09 — Localization & RTL Foundation](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E09-T01 |
| **Skills** | eng-add-localized-string, eng-write-dart-test |

## Goal

Central Kurdish (Sorani) is a first-class shipping locale instead of a half-rendered one. `ckb` is declared `Locale.fromSubtags(languageCode: 'ckb')` and added to `supportedLocales`; a vendored `CkbMaterialLocalizations` subclass + `LocalizationsDelegate` supplies the framework widget chrome Flutter does not ship for Central Kurdish (the OK/Cancel buttons, date-picker labels, tooltips), registered after `AppLocalizations.localizationsDelegates` so a Material dialog under `ckb` renders Sorani labels and never falls back to a default language. A canonical-Sorani encoding lint (`tool/check_ckb_canonical.dart`) fails the build on any `ckb` ARB value that does not use U+06D5 (ە) for AE or U+06A9 (ک) for kaf, or that carries a stray U+200C (ZWNJ) or a Teh-Marbuta-for-AE (ة-where-ە-belongs) substitution. All `ckb` ARB values keep their `@description` flag "needs native + scholar review". A widget test proves the dialog renders Sorani chrome. Direction is **not** in scope — `ckb` resolving to RTL is automatic once the locale is registered (engineering 12 §2, §3).

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §3 | The whole task spec: `Locale.fromSubtags(languageCode: 'ckb')`; vendor a `GlobalMaterialLocalizations` subclass (`CkbMaterialLocalizations`) + `LocalizationsDelegate` for chrome Flutter doesn't ship (OK/Cancel, date-picker labels, tooltips); register it in `localizationsDelegates`; the verbatim class skeleton (`okButtonLabel` `'باشە'`, `cancelButtonLabel` `'هەڵوەشاندنەوە'`, `textDirection => rtl`); the delegate fills chrome strings only — it is **not** a direction source; ckb copy stays provisional; the three "we refuse" pitfalls (no default-language chrome, no delegate-as-direction, no locking ckb copy) |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §1 | The `MaterialApp` wiring shape: `...AppLocalizations.localizationsDelegates` then `CkbMaterialLocalizations.delegate`; `supportedLocales: [Locale('ar'), Locale('fa'), Locale.fromSubtags(languageCode: 'ckb')]`; `nullable-getter: false`, `synthetic-package: false` (delegate sits beside the in-repo generated `AppLocalizations`) — established by E09-T01, consumed here |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §8 | The gate table this task extends with the canonical-`ckb` lint layer (alongside key coverage, hardcoded-string grep, physical-side grep, ASCII-digit grep, Arabic-plural check, RTL+numeral goldens on the real fonts); goldens load the **real** bundled UI fonts, never `Ahem` |
| `docs/design-system/12-localization-and-rtl.md` §7 | The canonical-encoding contract: ckb authored with U+06D5 (ە) for AE, U+06A9 (ک) for kaf, the chosen HEH (U+06BE); the lint rejects stray U+200C and any Teh-Marbuta-for-AE before build; the encoding risk (bad-conversion ZWNJ noise, ة-for-ە, U+0647+U+200C AE hack); ckb stays "needs native + scholar review", a per-locale RTL golden confirms the rendered/isolated result |
| `docs/design-system/12-localization-and-rtl.md` §6 | ckb term ARB stays provisional and is a data-only swap; the canonical-encoding rule (§7) couples to the term-set rule so Sorani strings are well-formed before they ship — term-sets themselves are **E09-T09**, not this task |
| `docs/design-system/11-voice-and-tone.md` §8, §9 | ckb values are **transcreations** to the four voice attributes with register set by native reviewers (never machine/literal translation); the banned-phrase (adab) lint + native + scholar review run per locale; ckb defaults ship clearly marked provisional and state no ruling |
| Skill `eng-add-localized-string` (+ `template.md` canonical-`ckb` block) | Step 9 (`ckb` is a custom locale: `Locale.fromSubtags`, vendored `CkbMaterialLocalizations` delegate, canonical U+06D5/U+06A9 encoding, ZWNJ/Teh-Marbuta lint, flagged provisional, font Sorani coverage CI-verified); step 1 (author in `app_ar.arb` first, transcreate `ckb` against it); step 10 (transcreate, never literal) |
| Skill `eng-write-dart-test` §6, §7 | The widget test loads the **real** bundled UI font via `FontLoader` in `setUpAll` (never `Ahem` — it renders every glyph as a square and would hide a missing Sorani delegate); the throwing `HttpOverrides` offline guard from the shared bootstrap; REUSE SPDX header, full-word names, typed `catch` |
| CLAIMS | **None.** This task ships no user-facing factual number, scheduling rule, or methodology claim — it adds framework chrome strings (OK/Cancel/date-picker) and an encoding lint. Any claim is owned by the feature epic that authors it (domain-claims-register-and-science-screen) |
| Siblings: E09-T01, E09-T02, E09-T09, E09-T10 | T01 stands up the `gen_l10n`/ARB pipeline (`l10n.yaml` ar-base, committed `AppLocalizations`, the `app_ckb.arb` file this task fills with canonical chrome values) and the `MaterialApp` `supportedLocales`/`localizationsDelegates` wiring this task registers the ckb delegate into; T02 is the broader locale-completeness gate (key coverage + greps + adab lint) this task's canonical-`ckb` lint plugs into; T09 swaps the sabaq/sabqi/manzil term-sets and depends on this task's canonical-encoding lint to keep its Sorani well-formed; T10 captures the per-locale ckb RTL/numeral goldens on the real fonts |

## Implementation notes

TEST-FIRST: the `ckb`-dialog widget test (a Material dialog under `ckb` must render Sorani button labels) and the canonical-Sorani lint's own fixture test are correctness-critical — write them and watch them fail (the dialog test fails with a default-language label; the lint test fails on a deliberately ZWNJ-poisoned fixture) **before** the delegate and lint are implemented.

1. **Locale declaration.** `ckb` is declared `Locale.fromSubtags(languageCode: 'ckb')` (never `Locale('ckb')` — `fromSubtags` is the prescribed constructor for a locale that may carry a script subtag). It is added to `MaterialApp.supportedLocales` alongside `Locale('ar')` and `Locale('fa')`. The composition root and `supportedLocales` list belong to E07 / E09-T01; this task supplies the constant and the delegate it pairs with, not the `MaterialApp` itself.

2. **The vendored delegate.** New file `lib/l10n/ckb_material_localizations.dart` (the `l10n` package, beside `bidi.dart`/`numerals.dart`). `class CkbMaterialLocalizations extends GlobalMaterialLocalizations` overriding the required getters — `okButtonLabel => 'باشە'`, `cancelButtonLabel => 'هەڵوەشاندنەوە'`, the date-picker/time-picker labels, tooltips — with the **full** required getter set vendored or adapted from the community `ckb_localizations` package (copied into the repo, not added as a network dependency — offline non-negotiable). `textDirection => TextDirection.rtl`. A `static const LocalizationsDelegate<MaterialLocalizations> delegate = _CkbMaterialLocalizationsDelegate()`; the private delegate's `isSupported` returns `locale.languageCode == 'ckb'`, `load` builds the `intl` formatters (`fullYearFormat`, `compactDateFormat`, …) for `ckb` and returns the localizations, `shouldReload` returns `false`. Carry the upstream package's REUSE/SPDX attribution in the file header per the dependency-license rule.

3. **Registration.** The delegate is appended to `localizationsDelegates` **after** `...AppLocalizations.localizationsDelegates` (which already pulls in the three `Global*` delegates) — `CkbMaterialLocalizations.delegate` last, because Flutter ships no `ckb` Material localization. Confirm the `GlobalMaterialLocalizations`/`GlobalWidgetsLocalizations`/`GlobalCupertinoLocalizations` delegates are present so `ckb` does not throw at first dialog. Registration lives at the composition root that E09-T01/E07 own; this task provides the line and the widget test that proves it took.

4. **The delegate is not a direction source.** `textDirection => rtl` on the subclass satisfies the framework's contract for *its own* chrome; app-wide direction still comes from the locale resolving to RTL via `GlobalWidgetsLocalizations` (E09-T04), never from reading this delegate. Do not wire any app layout off `CkbMaterialLocalizations.textDirection`.

5. **Canonical-Sorani lint.** New gate script `tool/check_ckb_canonical.dart` (pure Dart, `dart run`, no Flutter import — runs in the fast CI job). It parses `lib/l10n/app_ckb.arb`, and for every value (skip `@`-metadata keys) scans the codepoints:
   - **Reject U+200C (ZWNJ)** anywhere in a ckb value — bad-conversion noise.
   - **Reject U+0629 (ة, Teh-Marbuta)** in a ckb value — it is the AE-substitution hack; the AE letter must be **U+06D5 (ە)**.
   - **Reject U+06C0 / the U+0647+U+200C AE hack** — AE is U+06D5 only.
   - **Reject U+0643 (ك, Arabic kaf)** — Sorani kaf must be **U+06A9 (ک)**.
   - Emit a per-key, per-codepoint diagnostic (`app_ckb.arb: key "okExportLabel": forbidden U+200C at offset 4`) and exit non-zero on any hit. Keep the forbidden set and its rationale in a `const` map so the message names *why* each codepoint is banned.
   The script is wired into the locale-completeness gate (E09-T02) and into CI; it is a build-failing layer, not a warning.

6. **Provisional flag stays.** Every `ckb` value added or touched here keeps `"needs native + scholar review"` in its `@description` (the chrome strings are transcreations, not literals lifted from a package without review of register/adab). Do not lock or de-flag any ckb copy in this task — de-flagging is a separate native + scholar review event (design 11 §9).

7. **Pitfalls to avoid.** Registering the delegate *before* `...AppLocalizations.localizationsDelegates` (order matters for resolution); using `Locale('ckb')` instead of `Locale.fromSubtags`; pulling `ckb_localizations` as a live pub/network dependency instead of vendoring it (breaks offline + the dependency allow-list); driving app layout off the delegate's `textDirection`; running the dialog golden/widget test under `Ahem` (Sorani glyphs would render as squares and a fallback-language label would pass undetected); a lint that string-`contains`-checks instead of codepoint-scanning (misses combining-sequence cases and can't report offsets); de-flagging the provisional ckb copy; adding a user-facing factual claim (none belongs here).

## Acceptance criteria

- [ ] `ckb` is declared `Locale.fromSubtags(languageCode: 'ckb')` and present in `supportedLocales`; no `Locale('ckb')` shorthand anywhere (grep-clean).
- [ ] `lib/l10n/ckb_material_localizations.dart` exists with `CkbMaterialLocalizations extends GlobalMaterialLocalizations`, the full required getter set overridden (OK/Cancel + date-picker/time-picker labels + tooltips), `textDirection => TextDirection.rtl`, and a `static const delegate`; the file carries the upstream REUSE/SPDX attribution.
- [ ] `CkbMaterialLocalizations.delegate` is registered **after** `...AppLocalizations.localizationsDelegates`; the three `Global*` delegates remain present; a Material dialog under `ckb` opens without throwing.
- [ ] `tool/check_ckb_canonical.dart` exists, is pure Dart (no Flutter import), scans every `app_ckb.arb` value's codepoints, rejects U+200C, U+0629, the U+0647+U+200C AE hack, and U+0643, reports key + offset + reason, and exits non-zero on any violation; it is wired into the locale-completeness gate and CI.
- [ ] Every `ckb` ARB value authored/touched here carries `"needs native + scholar review"` in its `@description` and uses canonical encoding (U+06D5 ە, U+06A9 ک); no ckb copy is de-flagged.
- [ ] No CLAIMS row is created or referenced; no user-facing factual number, scheduling rule, or methodology copy is introduced.
- [ ] No network dependency is added (`ckb_localizations` is vendored, not fetched); the dependency allow-list and offline grep stay green.

## Tests

All tests carry the REUSE SPDX header (`GPL-3.0-or-later`), full-word names, typed `catch`, and run under the shared bootstrap's throwing `HttpOverrides` (offline by construction). Written FIRST.

- **`packages/.../l10n/test/ckb_dialog_chrome_test.dart`** (widget test, `flutter_test`): in `setUpAll`, load the **real** bundled UI font via `FontLoader` (never `Ahem`). Pump a minimal `MaterialApp` with `locale: Locale.fromSubtags(languageCode: 'ckb')`, `supportedLocales: [Locale('ar'), Locale('fa'), Locale.fromSubtags(languageCode: 'ckb')]`, and `localizationsDelegates: [...AppLocalizations.localizationsDelegates, CkbMaterialLocalizations.delegate]`. Trigger a Material chrome surface that uses framework strings (e.g. an `AlertDialog` via `showDialog`, or a `showDatePicker`). Assert:
  - `find.text('باشە')` (the Sorani OK label) is present and the default-language label ("OK") is **absent** — proving the delegate took and there is no fallback.
  - The cancel label renders `'هەڵوەشاندنەوە'`.
  - `Directionality.of(...)` at the dialog is `TextDirection.rtl` (a consequence of the locale, asserted, not the test's premise).
  - A *negative* guard: pumping the same dialog with the `CkbMaterialLocalizations.delegate` removed throws / falls back — documents what the delegate prevents (kept as an expected-failure or commented contract case if it would throw at framework level).

- **`tool/test/check_ckb_canonical_test.dart`** (unit, `package:test`): drive `check_ckb_canonical.dart`'s scan function over inline fixtures (no real file I/O needed for the unit cases):
  - A clean canonical Sorani value (U+06D5 ە, U+06A9 ک) → zero violations.
  - A value with a stray U+200C → one violation, correct key, correct offset, reason names ZWNJ.
  - A value with U+0629 (ة) where ە belongs → violation naming Teh-Marbuta-for-AE.
  - A value with U+0643 (ك, Arabic kaf) → violation naming non-canonical kaf.
  - The U+0647+U+200C AE hack → violation.
  - Running the real script against the committed `app_ckb.arb` exits zero (the shipped file is canonical).

- **No golden in this task.** The per-locale ckb RTL/numeral goldens on the real bundled fonts are **E09-T10**; this task asserts chrome-label correctness and encoding, not pixel layout.

## Definition of Done

- [ ] All acceptance criteria met; the `ckb`-dialog widget test and the canonical-lint unit test are green locally and in CI (fast job for the lint, widget job for the dialog).
- [ ] **Offline / no-network preserved:** the `ckb` Material localizations are **vendored** into the repo, not fetched; nothing opens a socket or downloads a font/locale at runtime; bundled UI fonts only, no `google_fonts`; the offline grep and dependency allow-list stay green ([PRD C1, §13.5, §19.3](../../docs/PRD.md)).
- [ ] **No AI / no microphone:** no ML/translation-service/ASR dependency; the Sorani chrome strings are human-authored transcreations, not machine-translated; no audio or microphone surface is touched ([PRD C2](../../docs/PRD.md); design 11 §8).
- [ ] **Quran text fidelity / sacred boundary held:** this task touches framework *chrome* only (OK/Cancel, date-picker labels) — no `CkbMaterialLocalizations`, `intl` formatter, encoding lint, or delegate ever reaches a muṣḥaf glyph, an ayah number, or the immutable glyph layer; the localization toolkit stops at the chrome boundary ([PRD R1, R2, §11.2, §13.1](../../docs/PRD.md); design 12 §8).
- [ ] **RTL + fa/ckb/ar strings:** `ckb` is a registered locale resolving to RTL automatically (not via the delegate's `textDirection`); the widget test confirms RTL at the dialog; `ckb` chrome values are canonical-encoded (U+06D5 ە, U+06A9 ک) and pass the canonical-Sorani lint; zero ckb chrome string is a hardcoded literal outside ARB / the vendored delegate.
- [ ] **Accessibility seam respected:** the dialog test renders on the **real** bundled UI font (Sorani extra letters پ چ ژ گ ڤ ڕ ڵ ۆ ێ ە actually exercised), never `Ahem`; the framework chrome the delegate supplies is what TalkBack/VoiceOver reads, so E08's screen-reader pass inherits correct Sorani labels.
- [ ] **Sect-neutral adab:** the Sorani chrome strings pass the adab gate and the four voice attributes (reverent/calm/plain-and-warm/honest); no never-ship phrase, no exclamation/emoji, no commercial word; no string issues a fiqh ruling or speaks for the Quran ([PRD R3, R6](../../docs/PRD.md); design 11 §3–§6).
- [ ] **Scholarly review flagged:** every `ckb` value carries "needs native + scholar review" in its `@description` and ships clearly provisional until a native speaker (register) and a scholar (terminology) clear it; nothing here is de-flagged; a cleared term-set/value can later replace these as a one-file data change ([PRD §13.4, §21.1](../../docs/PRD.md); design 12 §6).
- [ ] **Deterministic tests:** no `DateTime.now()` / wall clock in the delegate, the lint, or the tests; the lint is a pure codepoint scan over committed ARB; the dialog test is headless with in-memory wiring and the throwing `HttpOverrides` installed; vectors/fixtures are explicit literals.
- [ ] **No CLAIMS by construction:** this task originates no user-facing factual number, scheduling rule, or methodology claim; it adds framework chrome wording and an encoding gate only.
