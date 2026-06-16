# E09-T07 — ICU plural pipeline: every count-bearing string a plural; Arabic six-category ARB-completeness check (test-first)

| | |
|---|---|
| **Epic** | [E09 — Localization & RTL Foundation](EPIC.md) |
| **Size** | S (≈0.5–1 day) |
| **Depends on** | E09-T01, E09-T02 |
| **Skills** | eng-add-localized-string, eng-write-dart-test |

## Goal

Every count-bearing chrome string — pages-due, catch-up days, teacher sign-offs — is an ICU `plural` message whose count is locale-numeral-formatted (`numberFormatFor(locale)`, E09-T06) **before** placement, never a `count == 1 ? … : …` ternary or a `"$count pages"` splice. The correctness teeth are a test-first **ARB-completeness check** (`tool/check_arb_plurals.dart`, wired into the E09-T02 `check_l10n_complete.sh` harness) that asserts every `plural` message in `app_ar.arb` defines **all six** Arabic CLDR categories (`zero`/`one`/`two`/`few`/`many`/`other`) — a missing `few`/`many` fails the build, not the eye of a native reader. The check is written and proven against a deliberately incomplete plural *before* the foundation plurals are authored, so the gate is demonstrated to flip non-zero on an incomplete plural and back to 0 once complete.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §6 (Decision + Specification) | The owning rule: every count-bearing chrome string ("N pages due", "N days in your catch-up plan", "N sign-offs") is an ICU `plural`; Arabic's full CLDR set (`zero`/`one`/`two`/`few`/`many`/`other`) is a **translation contract**, a missing category a release blocker not a cosmetic gap; the count is locale-numeral-formatted (§5) *then* placed in the plural form; "the ARB-completeness CI step asserts that for `app_ar.arb`, every `plural` message defines `zero/one/two/few/many/other`" |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §1 (ARB entry shape) | The verbatim six-category `pagesDue` template — `{count, plural, zero{لا صفحات} one{صفحة واحدة} two{صفحتان} few{{count} صفحات} many{{count} صفحة} other{{count} صفحة}} مستحقة` — with `@pagesDue.placeholders.count.type: int`; the shape this check guards and the new count-keys follow |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §5 (Pitfalls) | The companion ASCII-digit refusal: a count "must pass through `numberFormatFor(locale)` first" then be injected as an ICU placeholder — the format-then-place rule the plural keys obey; the §5 ASCII-digit *grep* is E09-T02/E09-T06, this task asserts the plural-completeness half |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §8 (the gate table) | The "Arabic plurals → ARB completeness check → Missing CLDR plural category" row this task implements; the framing that the gate is cheap, structural, compile-time/grep-based and always-on; goldens (a separate layer) load real fonts (not this task) |
| `docs/design-system/12-localization-and-rtl.md` §7 (String discipline) | "Pluralization … use ICU messages in ARB where the language needs it, so counts ('3 pages', '۳ صفحه') agree grammatically per locale"; 100% ARB coverage as a §20.5 release-blocker; the plural-completeness check is one machine layer of that gate |
| `docs/design-system/11-voice-and-tone.md` §2, §6, §8, §9 | The count strings are *adab* first: reverent/calm/plain-and-warm/honest; no exclamation/emoji, no guilt/fear/loss ("you're behind"), no mandate; the empty-count copy is calm ("no pages due", never "all clear!" with enthusiasm); `fa`/`ckb`/`ar` are transcreations per-locale register, never literal; `ckb` plural values ship provisional pending native + scholar review |
| Skill `eng-add-localized-string` (+ `template.md` six-category plural block) | The canonical add-a-count-string procedure: author the `plural` in `app_ar.arb` first with all six Arabic categories, read only through `l10n.*`, format the count via `numberFormatFor(locale)` before placement, no ternary/no `"$count"` splice, transcreate `fa`/`ckb`/`ar` against `ar`, flag `ckb` provisional — exactly the discipline these keys instantiate |
| Skill `eng-write-dart-test` (+ `template.dart`) | This task's test home: a pure-Dart check tested with **`package:test`** (not `flutter_test`, no widget binding), the **deliberate-violation / test-first** proof a gate must carry ("a gate that passes because it checks nothing is the bug"), the throwing-`HttpOverrides` offline guard, REUSE SPDX header, full-word names, typed `catch`, `dart format`/`analyze --fatal-infos` clean, `closeTo` not relevant (no float math), behaviour-asserting `expect` |
| CLAIMS register | **None attach by construction.** This task ships plural *wording* and a completeness check; the count *values* (pages-due, catch-up days, sign-offs) are produced by the engine/feature epics that own them — those epics register any user-facing number. The §7.12 "never safe to drop" copy invariant is honoured (an empty-count string is calm and factual, never "done/mastered"), but this task originates no factual/methodology claim and the check is a pattern test over ARB, never a rendered number |
| Sibling: **E09-T01** (depends-on) | Seeded the `pagesDue` six-category exemplar in `app_ar.arb` and locked the ARB/`gen_l10n` pipeline (`nullable-getter: false`, committed `AppLocalizations`); this task adds the remaining count-keys (catch-up days, sign-offs) in the same shape and is the *check* that guards all of them |
| Sibling: **E09-T02** (depends-on) | Built the `tool/check_l10n_complete.sh` gate harness + `tool/check_adab_lint.dart` pattern; this task adds `tool/check_arb_plurals.dart` and wires it into that same `fast`-job harness, reusing its REUSE-header/typed-error/no-suppression conventions and its deliberate-violation discipline |
| Sibling: **E09-T06** | Owns `numberFormatFor(locale)` (pinned `-u-nu-arabext`/`-u-nu-arab`) and the per-locale numeral goldens; the count fed into each `plural` here is formatted by it before placement — this task asserts category completeness, T06 asserts the digit block |
| Siblings: **E09-T09 / E09-T10** | T09's region-override term-sets are `select` (not `plural`) and are *not* the subject of this check; T10's full-gate sweep re-runs this completeness check alongside the RTL/numeral goldens |

## Implementation notes

**TEST-FIRST (correctness-critical):** the ARB-completeness check is the deliverable's teeth, so author `tool/check_arb_plurals.dart` and its `package:test` suite **first**, prove it flips non-zero against a deliberately incomplete `plural` (a copy of `pagesDue` with `few`/`many` removed) and back to 0 when complete, *then* author the remaining count-keys. The proof that the gate works is a gate that has been seen to fail.

1. **The check lives in `tool/`, beside the E09-T02 harness.** Add `tool/check_arb_plurals.dart` (REUSE SPDX `GPL-3.0-or-later` header; a `sealed PluralCompletenessViolation` typed error with `offendingKey`/`missingCategories`/`localeTag` fields; full-word names — `requiredArabicCategories`, `definedCategories`; `///` doc on `main`; no `print` of user copy beyond the offending **key + missing categories + locale**; `dart format`/`dart analyze --fatal-infos` clean — eng-write-to-coding-standards). It reads `packages/l10n/lib/src/arb/app_ar.arb`, finds every value that is an ICU `plural` message, parses out the defined category names, and fails if `{zero, one, two, few, many, other}` is not a subset of them. It is invoked from `tool/check_l10n_complete.sh` (the E09-T02 layered gate) so the whole localization gate stays one entrypoint per the project's one-file-per-gate rule.

2. **Detect a `plural` message structurally, not by key name.** A value is in scope iff it contains an ICU `plural` selector (`{<arg>, plural,` after `use-escaping`-aware brace handling) — never "keys ending in `Count`" or a hand-list, which silently misses a future count-key. Parse the *immediate* category labels inside the `plural{…}` block (skip nested `{count}` placeholders and any nested `select`/`plural`); a CLDR plural label is one of `zero`/`one`/`two`/`few`/`many`/`other` or an `=N` exact-match form. The required set is exactly the six Arabic CLDR categories; `=N` exact forms are *additional*, never a substitute for a category. Keep the parser dependency-free (no new ARB-parser package — reuse the `dart:convert` JSON read already used by E09-T02's key-coverage layer; the `plural` body is a string field you scan).

3. **Scope: `app_ar.arb` only — Arabic is the hard case and the base content language.** `fa`/`ckb` need only the categories their CLDR rules use (Persian: `one`/`other`; Sorani per its rules), so this check asserts the **six-category contract on the `ar` template** (engineering 12 §6 names `app_ar.arb` explicitly). It does **not** demand six categories of `fa`/`ckb` (that would be wrong). Key *coverage* across locales (every `ar` key has an `fa`/`ckb` value) is E09-T02's separate superset layer — do not re-implement it here.

3a. **Author the remaining foundation count-keys as six-category Arabic plurals** in `app_ar.arb`, each with `@…placeholders.count.type: int` and an `@description`, transcreated to `fa`/`ckb`/`ar` (`ckb` flagged "needs native + scholar review"):
   - `catchUpDays` — "N days in your catch-up plan" (the `ui-catch-up-banner` count; calm, supportive register, no "behind"/"overdue").
   - `signOffCount` — "N sign-offs" (teacher/halaqa surface; neutral).
   - (`pagesDue` already exists from E09-T01 — confirm it still defines all six and is caught by the check.)
   Each is read only through `l10n.*`; the count is `numberFormatFor(locale).format(n)` placed via the ICU `{count}` placeholder, so digit-shaping and grammatical agreement are both correct (engineering 12 §5/§6). No ternary, no `"$count"` splice — the E09-T02 ASCII-digit grep and this completeness check are the two halves that enforce it.

4. **The empty-count copy is calm and honest** (design 11 §2/§6; PRD §7.12). The `zero`/`=0` form reads "no pages due today" / "no days to catch up", never "all clear!", never an exclamation, never "done"/"mastered"/"safe to drop". An all-caught-up day is neutral fact, not celebration or a streak — the same servant-to-the-teacher restraint the engine's "never safe to drop" invariant requires in copy.

5. **No plural logic in `/engine`.** The engine returns a locale-free `int` count (pages due, catch-up days, sign-offs); the feature layer formats it via `numberFormatFor` and selects the ICU category. A grep already bans `AppLocalizations`/`intl` imports from `/engine` (E09-T02); this task adds no string there.

6. **Pitfalls to avoid.** (a) Asserting six categories on `fa`/`ckb` — wrong; only `ar` carries the six-category contract. (b) Detecting plurals by key name instead of structure — a future count-key slips the gate. (c) Counting an `=0`/`=1` exact-match form as satisfying the `zero`/`one` *category* — they are additive, not substitutes. (d) A brace-matching bug that treats a nested `{count}` placeholder as a category label — parse only the top-level `plural{…}` labels. (e) Writing the check after authoring the plurals — it must be proven against a deliberately incomplete plural first (test-first). (f) A `count == 1 ? singular : plural` ternary or `"$count pages"` splice anywhere — grammatically wrong in Arabic/Persian and bypasses both gates. (g) Pulling in a new ARB/ICU-parser dependency — keep it `dart:convert`-only, reusing the E09-T02 read.

## Acceptance criteria

- [ ] `tool/check_arb_plurals.dart` exists with the REUSE SPDX `GPL-3.0-or-later` header, a `sealed PluralCompletenessViolation` typed error, full-word names, `///` on `main`, takes no arguments, runs from repo root, reads `packages/l10n/lib/src/arb/app_ar.arb`, and is `dart format`/`dart analyze --fatal-infos` clean.
- [ ] The check finds every `plural` message in `app_ar.arb` **structurally** (by the `{arg, plural,` selector, not by key name) and fails with a non-zero exit and a named `::error::` (citing engineering 12 §6 / PRD §20 gate 5) naming the **offending key + missing categories + locale** when any of `zero`/`one`/`two`/`few`/`many`/`other` is absent; it exits 0 when all six are present.
- [ ] The check is invoked from `tool/check_l10n_complete.sh` (the E09-T02 harness) and runs in the `fast` CI job with no `continue-on-error` and no suppression flag; it makes no network call.
- [ ] `pagesDue` (from E09-T01), `catchUpDays`, and `signOffCount` are each ICU `plural` messages defining all six Arabic CLDR categories in `app_ar.arb`, each with `placeholders.count.type: int` and an `@description`; each is transcreated to `fa`/`ckb`/`ar` (with `fa`/`ckb` using only their own CLDR categories) and `ckb` flagged "needs native + scholar review".
- [ ] No count-bearing chrome string is a `count == 1 ? … : …` ternary or a `"$count …"` splice; every count is `numberFormatFor(locale)`-formatted before placement and read through `l10n.*`.
- [ ] The empty-count (`zero`) form of each key is calm and factual (no exclamation, no emoji, no "done"/"mastered"/"safe to drop", no "behind"/"overdue").
- [ ] The check has been **proven against a deliberately incomplete plural** (a `pagesDue` copy missing `few`/`many`) — observed non-zero, then 0 after completion — and that proof is the test-first artifact below.

## Tests

This task's correctness teeth are a pure-Dart check tested with **`package:test`** (eng-write-dart-test §2 — no `flutter_test`, no widget binding), authored **test-first**, plus a deliberate-violation proof (the gate-validation procedure a gate must carry).

`tool/test/check_arb_plurals_test.dart` (`package:test`, REUSE SPDX header), required cases written FIRST:
- **Incomplete plural fails** (the test-first core): a synthetic ARB map whose one `plural` value omits `few` and `many` is reported with `offendingKey` and `missingCategories == {few, many}` and a non-zero result.
- **Complete plural passes**: the §1/§6 six-category `pagesDue` template (all of `zero`/`one`/`two`/`few`/`many`/`other`) reports no violation.
- **Each single missing category is caught**: parametrized over removing exactly one of the six, each removal is reported with precisely that category missing (proves no category is silently optional).
- **Non-plural values are ignored**: a plain string value and a `select` (region term-set) value produce no violation — the check is plural-specific, not a blanket completeness scan.
- **`=N` exact forms do not substitute a category**: a value with `=0{…} one{…} other{…}` (no `zero` category) still fails for missing `zero`/`two`/`few`/`many` — exact-match forms are additive.
- **Nested placeholder is not a category**: a `few{{count} صفحات}` body does not parse the inner `{count}` as a category label; the value with all six categories passes.
- **Empty / no-plural ARB exits 0**: an ARB map with no `plural` message is clean.

**Deliberate-violation proof** (re-run by E09-T10's full-gate sweep): temporarily delete `few`/`many` from the real `pagesDue` in `app_ar.arb`, run `tool/check_l10n_complete.sh`, observe non-zero naming `pagesDue` + `{few, many}`; revert and observe exit 0. Recorded in the PR as the gate-works evidence.

**Offline / no-network guard**: the check and its test read only the local ARB file(s) and in-memory fixtures — they open no socket, fetch no font or locale, call no service (a throwing `HttpOverrides` is installed via the shared test bootstrap, eng-write-dart-test §8); a fresh clone runs them identically. There is **no AI, no model, no microphone** — the check is a static structural scan of human-authored, human-reviewed ARB.

## Definition of Done

- [ ] All acceptance criteria met; `tool/check_arb_plurals.dart` exits 0 on the clean tree (no arguments) and via `check_l10n_complete.sh` in the `fast` CI job; the `package:test` suite is green; the deliberate-incomplete-plural proof was run and observed to flip non-zero ↔ 0.
- [ ] **Offline / no-network preserved**: the check and its test make no network call and add no dependency that does — they are pure functions of the checked-out ARB files and in-memory fixtures; nothing opens a socket ([PRD C1, §19.3](../../docs/PRD.md)).
- [ ] **No AI / no microphone**: no ML/translation-service/ASR/audio dependency is introduced; the completeness check is a static structural scan against human-authored, human-reviewed copy, never a model, and reads no microphone ([PRD C2](../../docs/PRD.md)).
- [ ] **Quran text fidelity / sacred boundary held**: this task touches only chrome count-strings; it applies no `plural`/`NumberFormat`/bidi to a muṣḥaf glyph or a printed ayah number, never scans `packages/quran` or `packages/engine`, and the riwāyah is unaffected ([PRD R1, §11.2](../../docs/PRD.md); design 12 §8).
- [ ] **RTL + fa/ckb/ar localization is structural, not a phase**: every count-bearing chrome string is an ICU `plural` read through `l10n.*` with its count locale-numeral-formatted before placement; `app_ar.arb` carries the full six Arabic CLDR categories on every plural, asserted by an always-on build gate green on draft copy; `fa`/`ckb`/`ar` are transcreations using their own CLDR categories ([PRD C4, §13, §20 gate 5](../../docs/PRD.md)).
- [ ] **Accessibility seam respected**: count strings (including any `semanticsLabel`) route through the same `l10n.*`/plural pipeline, so the localized count a screen reader speaks is grammatically correct per locale; this task renders no UI and introduces no streak/score/shame surface.
- [ ] **Sect-neutral adab**: every count string passes the adab gate first and the four voice attributes; the empty-count form is calm and factual (no exclamation, no emoji, no "done"/"mastered"/"safe to drop", no "behind"/"overdue", no mandate); Arabic forms are statements of readiness; the strings issue no fiqh ruling ([PRD R3, §7.12](../../docs/PRD.md); design 11 §2–§6, §9).
- [ ] **Scholarly / native review flagged where pending**: the `ckb` plural values carry "needs native + scholar review" in their `@description` and ship clearly provisional until a native speaker (register) and a scholar (terminology) clear them ([PRD §13.4, §21.1](../../docs/PRD.md); design 12 §6).
- [ ] **Deterministic tests**: the check is a pure function of the ARB files/fixtures with no wall clock, network, or host state; the `package:test` suite and the deliberate-violation proof are reproducible on a fresh clone; the tool carries the REUSE SPDX header, a `sealed` typed error, prints no user data beyond key/missing-categories/locale, and is `dart format`/`dart analyze --fatal-infos` clean ([PRD §20 gate 5](../../docs/PRD.md); engineering 12 §8).
- [ ] **No CLAIMS attach by construction**: this task ships plural wording and a completeness check only — it originates no on-screen factual number, scheduling rule, or methodology claim; the count *values* are registered by the feature/engine epics that produce them (domain-claims-register-and-science-screen).

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
