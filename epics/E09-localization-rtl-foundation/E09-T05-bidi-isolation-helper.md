# E09-T05 — bidi.dart: the one FSI/PDI isolation helper (isolate / isolateLtr / isolateRtl) + raw-concat grep ban (test-first)

| | |
|---|---|
| **Epic** | [E09 — Localization & RTL Foundation](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E09-T01 |
| **Skills** | eng-rtl-and-bidi-layout, eng-write-to-coding-standards, eng-write-dart-test |

## Goal

`packages/l10n/lib/src/bidi.dart` exists as the *single* bidi-isolation helper for the whole app: `isolate(run)` wraps a run of unknown direction in `FSI…PDI`, and `isolateLtr(run)` / `isolateRtl(run)` wrap a known-direction run in `LRI…PDI` / `RLI…PDI` — built on `intl`'s `Bidi` and Flutter's `Unicode` isolate constants (FSI U+2068, RLI U+2067, LRI U+2066, PDI U+2069). Every mixed-script chrome run (a page number, "Juz N", a surah name beside RTL copy, a date, a percentage, a user-typed profile name, a version string) flows through this one helper, with `isolateLtr`/`isolateRtl` preferred over FSI wherever direction is known (because FSI's first-strong detection mis-guesses on leading punctuation). The legacy embedding/override codes (LRE/RLE/LRO/RLO) and raw concatenation of opposite-direction runs are grep-banned. The helper is chrome-only and provably never touches a muṣḥaf glyph. Test-first: unit tests pin the exact emitted control characters before the body exists.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §4 | **The literal contract this task implements.** The verbatim `l10n/bidi.dart` shape: `isolate` = `'${Unicode.FSI}$run${Unicode.PDI}'`, `isolateLtr` = LRI…PDI, `isolateRtl` = RLI…PDI, and the private `_isRtl(s) => Bidi.hasAnyRtl(s)`. The three refusals: (a) raw concatenation of opposite-direction runs is banned; (b) FSI is refused where direction is known (first-strong mis-detects on leading punctuation); (c) the helper is chrome-only — muṣḥaf glyph runs come pre-shaped from the immutable layer and are never passed through bidi controls. Prefer isolating controls (LRI/RLI/FSI + PDI) over legacy LRE/RLE/LRO/RLO per UAX #9. |
| `docs/design-system/12-localization-and-rtl.md` §3 | **Why the helper exists, and the failure it prevents.** "page 7 of 30" rendering "30 of 7" is a bidi failure that is *also* a screen-reader-order bug, not cosmetic. The opposite-direction value is kept as a formatted ARB **placeholder** (`"{page} از {total}"`), never a hard-spliced substring; isolation wraps the *embedded token*, not the surrounding word; a localized label stays in a single `Text`/`TextSpan` (fragmenting an Arabic-script word triggers diacritic-clipping). Anti-patterns to forbid: concatenating a raw ASCII number/Latin token into a localized string ("Juz " + n); using LRE/RLE/LRO/RLO where the standard calls for isolates. |
| `docs/design-system/11-voice-and-tone.md` §1 | Adab is a gate even on a string-plumbing task: this helper carries *no copy of its own* — it only wraps runs the ARB pipeline (E09-T01) authored. It introduces no streak/score/shame surface and speaks for nothing; the strings it isolates are reverent/calm by the time they reach it. |
| Skill `eng-rtl-and-bidi-layout` (+ `template.dart` §2, `references.md`) | **Rules 5–6 are this task's entire checklist:** route every mixed run through the one helper; prefer `isolateLtr`/`isolateRtl` over FSI when direction is known; the value is an isolated ARB placeholder, not a hard-splice; the helper is chrome-only and never reaches a glyph of the muṣḥaf. Copy the helper block from `template.dart` §2 verbatim as the implementation shape; ignore rules 1–4, 7–10 (siblings' work). |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | §4 `///` summary-first docs on every public top-level function; in-body comments say *why* (the FSI-vs-known-direction rationale), never *what*; §1.1 rule 4 — user-facing strings live in the ARB files, never hardcoded in Dart (this helper holds zero literal copy, only the four Unicode control constants by name); §3 `dart format` clean; §8 analyzer clean. Pure functions, no I/O, no clock, no throw — these are total string transforms (§5.2 totality applies trivially: every input yields a string). |
| Skill `eng-write-dart-test` (+ `template.dart` §2, §11) | **TEST-FIRST** for correctness-critical helpers: §2 use `flutter_test` (the `Unicode` constants live in `package:flutter/foundation.dart`, so the test needs the Flutter SDK, not bare `package:test`); pin the emitted controls by exact codepoint, not by re-deriving them; §8 the throwing `HttpOverrides` offline guard is installed by the shared bootstrap; §11 REUSE SPDX header, full-word names, `dart format` clean, typed `catch`, no `print`/`!`/`late`. |
| CLAIMS register | **None attach.** This task is pure chrome plumbing — it wraps already-cleared wording in Unicode controls but originates no user-facing number, scheduling rule, or methodology claim (epic DoD: "No CLAIMS attach by construction"). Any number it isolates was registered by the feature epic that authored it. |
| Sibling E09-T01 | Supplies `AppLocalizations` and the `app_ar.arb` foundation keys whose placeholder messages (`"{page} از {total}"`, `welcomeBack`, `juzLabel`) embed the runs this helper isolates. This task consumes that pipeline; it adds no ARB key. |
| Sibling E09-T02 | Owns the locale-completeness CI gate. This task adds the **raw-concat / legacy-embedding grep** to that gate's rule-set: ban `Unicode.LRE`/`RLE`/`LRO`/`RLO` and the `Bidi.RTL_EMBEDDING`/`LTR_EMBEDDING` constants, and flag opposite-direction interpolation into `Text(...)` that bypasses `isolate*`. This task supplies the deliberate-violation fixture proving the grep bites; T02 wires it into CI. |
| Sibling E09-T06 | Owns `numerals.dart` / `numberFormatFor(locale)`. Its formatted, locale-numeral output is the canonical known-direction run this helper's `isolateLtr` wraps. T05 and T06 are the two halves of one mixed-run call site (format the number, then isolate it); each is independently unit-tested. |
| Sibling E09-T08 | The calendar-display layer renders E02's converted `(y,m,d)` into locale numerals, then calls this helper to isolate the date run inside RTL copy. T08 depends on T05; this task must land first. |
| Sibling E09-T10 | The per-locale RTL + numeral golden suite on the real bundled fonts visually confirms "page N of M" reads in the correct order because of this helper. T05's unit tests pin the control characters; T10's goldens prove the rendered result. |

## Implementation notes

**TEST-FIRST (correctness-critical).** The exact byte sequence this helper emits *is* the contract — a wrong or missing control character silently reorders a line and scrambles screen-reader order. Write `bidi_test.dart` (the cases below) **before** the body; the assertions on the emitted FSI/LRI/RLI/PDI codepoints must exist and fail before `bidi.dart` is implemented.

1. **File & package.** Create `packages/l10n/lib/src/bidi.dart` in the `l10n` package — the same package that holds `icon_mirror_policy.dart`/`forced_ltr.dart`/`language_preview.dart` (E09-T04) and will hold `numerals.dart` (E09-T06). Export the three public functions from the package barrel (`packages/l10n/lib/l10n.dart`). The `engine` package is untouched (it holds no strings and no Flutter import).

2. **Imports — by name, not by literal codepoint.** `import 'package:flutter/foundation.dart' show Unicode;` for the isolate constants and `import 'package:intl/intl.dart' show Bidi;` for `Bidi.hasAnyRtl`. Reference the controls as `Unicode.FSI` / `Unicode.LRI` / `Unicode.RLI` / `Unicode.PDI` — never as raw `'⁨'` literals in production code, so the intent is legible and the constant is the single source of truth (eng-write-to-coding-standards §4).

3. **The three public functions — copy the impl-12 §4 / `template.dart` §2 shape verbatim.**
   - `String isolate(String run) => '${Unicode.FSI}$run${Unicode.PDI}';` — for a run of *unknown* direction (a user-typed profile name, an arbitrary token). `///` doc: "Wrap a run of unknown direction in a First-Strong Isolate."
   - `String isolateLtr(String run) => '${Unicode.LRI}$run${Unicode.PDI}';` — for a known-LTR run (a Latin technical token, a locale-numeral string that is to render left-to-right inside RTL copy).
   - `String isolateRtl(String run) => '${Unicode.RLI}$run${Unicode.PDI}';` — for a known-RTL run.
   Each `///` doc states the why: prefer `isolateLtr`/`isolateRtl` over `isolate` when the direction is known, because FSI's first-strong detection mis-guesses when the leading character is the "wrong" script (an Arabic string opening with an ASCII quote detects as LTR) — cite Flutter's `Unicode.FSI` constant doc warning (impl-12 §4 rationale).

4. **The `_isRtl` predicate.** `bool _isRtl(String s) => Bidi.hasAnyRtl(s);` — private, the seam a call site uses to *choose* `isolateRtl` vs `isolateLtr` for a run whose direction it must detect at runtime (e.g. a backup filename that may be either). Keep it private to `bidi.dart`; if a call site needs a public direction-aware "isolate, auto-detecting" convenience, add it only when a real call site exists (no speculative API — eng-write-to-coding-standards §9; the same restraint E09-T04 applied to `isRtl`).

5. **Totality, purity, no throw.** All three functions are total string transforms — every input (including the empty string) yields a string; there is no I/O, no clock, no `throw`, no `Bidi`/`BidiFormatter` HTML path. Do **not** use `BidiFormatter.wrapWithUnicode` as the implementation: it auto-detects context direction and is heavier than the explicit isolate this app's call sites want; the three thin functions above are the contract (impl-12 §4 lists the explicit shape). `_isRtl` is the only place `Bidi` is consulted.

6. **Chrome-only boundary — encode the refusal in the doc, not just by convention.** The library-level `///` doc states: this helper is chrome-only; muṣḥaf glyph runs come pre-shaped from the immutable layer (E05 / domain-mushaf-text-integrity) and are *never* passed through it. There is no muṣḥaf import reachable from `l10n`, so this is structural — but the doc makes the refusal reviewer-visible (impl-12 §4 pitfall (c); ds-12 §8).

7. **The grep ban (the deliverable's other half).** Provide the grep rules for E09-T02's gate to adopt: (a) ban `Unicode.LRE`, `Unicode.RLE`, `Unicode.LRO`, `Unicode.RLO` and `Bidi.RTL_EMBEDDING`/`Bidi.LTR_EMBEDDING`/`Bidi.POP_DIRECTIONAL_FORMATTING` anywhere under `lib/` except `bidi.dart` itself (which references none of them — so the ban is total in practice); (b) flag interpolation of a number/name/Latin token directly into a `Text(...)`/`l10n.*` call without an `isolate*` wrapper, per ds-12 §3's "Juz " + n anti-pattern. Author a deliberate-violation fixture (`packages/l10n/test/fixtures/raw_concat_violation.dart.txt`, kept out of the build) containing both a legacy `Unicode.RLE` use and a raw `'Juz ' + n.toString()` concat, so T02's gate test can prove the grep fails on it (per `eng-add-ci-check`). The grep *rules* land here; T02 *wires* them into the CI job.

8. **Pitfalls to avoid.** (a) Emitting an embedding (LRE/RLE) instead of an isolate — embeddings do not isolate the run from its surroundings and are discouraged by UAX #9. (b) Using `FSI` for a run whose direction is known — use `isolateLtr`/`isolateRtl` (impl-12 §4 refusal (b)). (c) Forgetting the closing `PDI`, leaving the isolate unbalanced and corrupting everything after it on the line. (d) Hard-splicing the token mid-word instead of isolating a placeholder run; the localized sentence stays a single `Text`/`TextSpan` (ds-12 §3). (e) Routing a muṣḥaf glyph run through the helper (forbidden — chrome only). (f) Writing the control characters as raw `'⁨'` literals instead of the named `Unicode.*` constants. (g) Reaching for `BidiFormatter.wrapWithUnicode` and silently changing the emitted controls.

## Acceptance criteria

- [ ] `packages/l10n/lib/src/bidi.dart` exists and is exported from the `l10n` barrel; it imports only `package:flutter/foundation.dart` (`Unicode`) and `package:intl/intl.dart` (`Bidi`) — no muṣḥaf/engine/data import, no networking import.
- [ ] `isolate(run)` returns `Unicode.FSI + run + Unicode.PDI`; `isolateLtr(run)` returns `Unicode.LRI + run + Unicode.PDI`; `isolateRtl(run)` returns `Unicode.RLI + run + Unicode.PDI` — verified by exact-codepoint unit assertions (U+2068, U+2066, U+2067 leading; U+2069 trailing).
- [ ] The helper preserves the inner run byte-for-byte (it only prepends one isolate-initiator and appends one PDI); the empty string yields `initiator + PDI` with nothing between.
- [ ] No legacy embedding/override control (`Unicode.LRE`/`RLE`/`LRO`/`RLO`, `Bidi.*_EMBEDDING`) appears anywhere in `bidi.dart` or under `lib/`; the raw-concat / legacy-embedding grep rules are authored for E09-T02 and bite on the deliberate-violation fixture.
- [ ] `isolateLtr`/`isolateRtl` are documented as preferred over `isolate` for known-direction runs, with the first-strong-mis-guess rationale in the `///` doc.
- [ ] The library `///` doc states the chrome-only boundary (muṣḥaf glyphs are never passed through the helper); `_isRtl` is private.
- [ ] Every public function carries a summary-first `///` doc; the file carries the REUSE `GPL-3.0-or-later` SPDX header; `dart format` and the analyzer are clean.

## Tests

All tests obey `eng-write-dart-test`: `flutter test` (the `Unicode` constants need the Flutter SDK), the REUSE SPDX header, full-word names, the throwing `HttpOverrides` offline guard installed by the shared bootstrap, no `DateTime.now()`, no network. Written **test-first** — these assertions exist and fail before `bidi.dart`'s body.

`packages/l10n/test/bidi_test.dart` — unit (`flutter_test`):

- **`isolate` emits FSI…PDI.** `isolate('abc')` equals `'${Unicode.FSI}abc${Unicode.PDI}'`; the first rune is U+2068 and the last is U+2069 (assert the codepoints directly, not by re-using the helper to build the expectation).
- **`isolateLtr` emits LRI…PDI.** Leading rune U+2066, trailing U+2069; inner run unchanged.
- **`isolateRtl` emits RLI…PDI.** Leading rune U+2067, trailing U+2069; inner run unchanged.
- **No legacy control leaks.** The output of all three contains none of U+202A–U+202E (LRE/RLE/PDF/LRO/RLO) — proving isolates, not embeddings, are emitted.
- **Inner run preserved.** For an Arabic-script run, an ASCII-digit run, an Extended-Arabic-Indic numeral run (`۴۵۶`), and a mixed run, the substring strictly between the initiator and the PDI is byte-equal to the input.
- **Empty and edge inputs.** `isolate('')` equals `'${Unicode.FSI}${Unicode.PDI}'`; a run that already contains a balanced isolate is wrapped, not unwrapped (the helper does not parse — it only brackets).
- **`isolateLtr`/`isolateRtl` differ only in the initiator.** For the same run, the two outputs share the trailing PDI and the inner run and differ solely in the leading rune (U+2066 vs U+2067) — pinning that direction selection is a one-character choice.
- **Round-trip with `intl`.** A page-label run formed as `isolateLtr(numberFormatFor(faLocale).format(7))` (the real T06 path, with T06's formatter or a stub) contains the Extended-Arabic-Indic `۷` and is bracketed by LRI…PDI — proving the helper composes with the numeral path without mangling locale digits.

`packages/l10n/test/fixtures/raw_concat_violation.dart.txt` — a non-compiled fixture containing a legacy `Unicode.RLE` use and a `'Juz ' + n.toString()` raw concat, referenced by **E09-T02**'s gate test to prove the raw-concat / legacy-embedding grep fails on a deliberate violation (per `eng-add-ci-check`); it is excluded from the package source set.

The real-font, per-locale RTL **golden** that proves "page N of M" renders in the correct visual order *because* of this isolation is **E09-T10**, not this task — T05 pins the control characters; T10 pins the pixels.

## Definition of Done

- [ ] All acceptance criteria met; the test-first unit suite is green locally and in CI; the E09-T02 raw-concat / legacy-embedding grep is green over the new source and bites on the deliberate-violation fixture.
- [ ] **Offline / no-network preserved:** nothing here opens a socket or loads a font/locale at runtime; the helper is three pure string transforms; the throwing `HttpOverrides` guard is installed in the test bootstrap ([PRD C1, §19.3]).
- [ ] **No AI / no microphone:** no ML, translation service, ASR, or microphone dependency is introduced; this is pure Unicode string bracketing ([PRD C2]).
- [ ] **Quran text fidelity / sacred boundary held:** the helper is chrome-only — its `///` doc forbids passing muṣḥaf glyph runs through it; no bidi control, `NumberFormat`, mirror, or UI font reaches a glyph of the page; the page's pre-shaped glyph runs come from E05's immutable layer and never enter `l10n` ([PRD R1, R2, §11.2]; impl-12 §4; ds-12 §8).
- [ ] **RTL + fa/ckb/ar is structural, not a phase:** every mixed-script chrome run is isolatable through this one helper; known-direction runs use `isolateLtr`/`isolateRtl` (not FSI's mis-guessing first-strong); no legacy LRE/RLE/LRO/RLO survives the grep; the helper composes with the fa/ckb Extended-Arabic-Indic and ar Arabic-Indic numeral paths without mangling digits ([PRD C4, §13, §20 gate 5]; impl-12 §4).
- [ ] **Bidi correctness proven:** the emitted FSI/LRI/RLI…PDI controls are pinned by exact-codepoint unit assertions written test-first; the "page 7 of 30 → 30 of 7" reorder the helper prevents is verified at the pixel level by E09-T10's per-locale goldens and exercised aurally by E08's TalkBack/VoiceOver pass ([PRD §20.5]; ds-12 §3).
- [ ] **Accessibility seam respected:** isolating a mixed run is a screen-reader-order fix as well as a visual one — the helper keeps the localized label a single `Text`/`TextSpan` so the reader speaks the run in logical order; this task adds no streak/score/shame surface ([PRD §18]; ds-12 §3).
- [ ] **Sect-neutral adab:** the helper holds zero literal copy — it only brackets wording the ARB pipeline authored and the adab gate cleared; it speaks for nothing, issues no fiqh ruling, and introduces no banned phrase ([PRD R3, R6]; ds-11 §1).
- [ ] **Deterministic tests:** unit assertions are on exact codepoints with no wall clock and no network; the suite is hermetic and stable across contributor machines (no font/golden dependency — the real-font golden is E09-T10).
- [ ] **No CLAIMS attach by construction:** this task originates no user-facing factual number, scheduling rule, or methodology claim — it isolates runs of already-cleared wording; any claim is registered by the feature epic that authored the string ([domain-claims-register-and-science-screen]).

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
