---
name: eng-write-to-coding-standards
description: Write or modify production Dart in the Hifz Companion repo to the project's coding standards — Effective Dart naming/casing, full-word domain identifiers with units in the name, dart format and analyzer/lint conformance, immutability, total (never-throwing) engine functions, sealed I/O error types, no print/logging of user data, and `///` docs on public APIs. Use whenever authoring or editing any production Dart function, class, value type, error type, async/I-O boundary, or analysis_options entry in any package.
---

# eng-write-to-coding-standards

The repository is published openly as a form of *waqf*; the huffaz, teachers, scholars, and privacy-literate reviewers who audit it spend most of their effort *reading*, not writing — field instrumentation puts ~58% of developer time on comprehension (`docs/engineering/03-coding-standards.md` §2). So readable, honest Dart is not aesthetics here, it is the trust artifact. This skill is the style-and-review companion you apply to **every production Dart line you write or change**: it makes each line trace to a rule, each rule trace to `docs/engineering/03-coding-standards.md` (the normative standard) and `docs/engineering/01-architecture-overview.md` (the layer shape the standard protects).

These are not preferences to negotiate in review — `dart format` and `dart analyze --fatal-infos` and the path-scoped import bans run in CI and fail the build (`docs/engineering/03-coding-standards.md` §3, §7). Come here to write code that passes those gates the first time, and to know *why* each gate exists.

## When to use

Use this skill when you:

- author or modify any production Dart function, method, class, `enum`, `extension`, or `typedef` in any package (`docs/engineering/03-coding-standards.md` §1);
- name a domain quantity, a boolean, a sacred-domain term, or a `CalendarDate` vs `DateTime` field — anywhere the name must carry units, role, or calendar semantics (`docs/engineering/03-coding-standards.md` §1.1);
- define an immutable value type, a `copyWith`, or a sealed error type at an I/O boundary (`docs/engineering/03-coding-standards.md` §5);
- write `///` documentation on a public API of `engine`/`data`/`quran`, or a *why*/units/citation comment inside a body (`docs/engineering/03-coding-standards.md` §4);
- add or tune a rule in the root `analysis_options.yaml`, or hit a lint you must satisfy rather than suppress (`docs/engineering/03-coding-standards.md` §7);
- decide error handling at an async/persistence boundary — what throws, what returns, what is caught with an `on` clause (`docs/engineering/03-coding-standards.md` §5).

Do **NOT** use this skill for:

- the package manifest, dependency set, `lib/` vs `lib/src/` barrel, or workspace wiring → use **eng-create-package** (this skill governs the code *inside* the files; that one governs the package boundary).
- engine *logic* — the FSRS curve, the trust clamp math, tracks, golden vectors, the `onReview` update path → use **domain-scheduling-engine-rules** (this skill governs how that code is *named, typed, documented, and kept total*; the rules of the math live there).
- the review→persist single write path, grade semantics, the sacred-text guard's meaning → use **domain-grading-pipeline**.
- QPC glyph rendering, checksum-pinned font/glyph handling, text-fidelity rules → use **domain-mushaf-text-integrity**.
- the `CalendarDate`/HifzDate value type's calendar arithmetic and conversion rules → use **domain-calendars-and-hifzdate** (this skill enforces only that you *use* `CalendarDate` below the boundary and name it honestly).
- the sealed error types and fail-closed flow of the downloader/verifier → use **domain-asset-pack-integrity** (this skill gives you the sealed-error *shape*; the integrity policy lives there).
- the adab/sect-neutrality/no-gamification wording of any user-facing string or claim → use **domain-adab-and-religious-integrity** and **domain-claims-register-and-science-screen** (strings live in the `l10n` ARB files, never hardcoded in Dart — see step 4).

## The canonical pattern

### 1. Follow Effective Dart verbatim; there is no house style that contradicts the language
Naming, casing, and API design follow [Effective Dart](https://dart.dev/effective-dart) exactly; there is no competing in-house convention (`docs/engineering/03-coding-standards.md` §1). Hold the casing table: `UpperCamelCase` for types/extensions/enums/typedefs (`PageCard`, `CalendarDate`, `ReviewGrade`, `MushafRenderer`); `lowercase_with_underscores` for files/directories/import prefixes (`scheduling_engine.dart`); `lowerCamelCase` for everything else (`dueAt`, `stabilityDays`, `retrievability`); acronyms over two letters capitalize like a word (`Sha256Manifest`, not `SHA256Manifest`) (`docs/engineering/03-coding-standards.md` §1). Word-built identifiers let professionals find defects ~19% faster than abbreviations — so this is a comprehension rule, not taste.

### 2. Names carry full words, units, role, and calendar semantics
No abbreviations in domain identifiers: `stabilityDays` never `s`/`stab`, `retrievability` never `r` — the terse FSRS single letters (`D`/`S`/`R`) are confined to the inside of one short pure function where the formula is transcribed with a citation comment (`docs/engineering/03-coding-standards.md` §1.1 rule 1). The **unit lives in the name**: `stabilityDays`, `cycleCeilingDays`, `dailyBudgetMinutes`, `targetRetention` — never bare `stability`/`budget`/`target` (§1.1 rule 2). A `CalendarDate` (a floating calendar day: `dueAt`, `lastReviewedDay`) is named as a day; a `DateTime` is a real instant legal only at the notification/logging boundary and named as one (`reminderFireInstant`) — a `DateTime` named like a day is the DST off-by-one defect class (§1.1 rule 3; `docs/engineering/01-architecture-overview.md` §5). Sacred-domain terms use one fixed transliteration everywhere (`mushaf`, `juz`, `hizb`, `surah`, `ayah`, `manzil`, `mutashabihat`, `riwayah` — no spelling drift) (§1.1 rule 4). Booleans read as assertions (`isWeak`, `hasTeacherSignoff`, never `weak`/`signoff`) (§1.1 rule 5); expose fields, not `get`-prefixed accessors (`dueCards`, not `getDueCards()`) (§1.1 rule 6).

### 3. `dart format` is the only formatting authority
Never hand-format and never argue formatting in review; `dart format` (default 80-char page width, set once in `analysis_options.yaml` `formatter: page_width: 80`) is law, and CI runs `dart format --output=none --set-exit-if-changed .` (`docs/engineering/03-coding-standards.md` §3). Write trailing commas so the formatter expands argument lists and widget trees vertically — this is the diff-friendliness that serves read-cost-over-write-cost, and `require_trailing_commas` enforces it (§3, §7.1). No competing formatter, no per-file `// dart format off` except around a hand-laid test-vector table with a justification comment (§3).

### 4. `///` on every public API; in-body comments say *why*, never *what*
Every public declaration in the pure `engine`/`data`/`quran` packages carries a `///` doc comment — one-sentence summary first, then params, units, edge behavior; `public_member_api_docs` and `dangling_library_doc_comments` are promoted to errors (`docs/engineering/03-coding-standards.md` §4, §7.1). In-body comments explain intent, invariants, units, and *why* — never narrate mechanics, because comments rot into misinformation when they fail to co-evolve with code. Every scheduling/science constant carries a citation comment mapping the number to its source (e.g. `// DECAY = -0.5 from FSRS-4.5 …`), and the two product covenants are restated at their enforcement points: `// PRD §7.6: SR may only make a page MORE frequent, never less` on the trust clamp, `// PRD §7.7: a dropped/altered word is never "Good"` on the sacred-text guard (§4). No commented-out code, no TODO without an issue link, no doc that merely restates the signature. **User-facing strings are owned by the `l10n` ARB files (`ar` template, `fa`/`ckb`) — never hardcoded in Dart** (§1.1 rule 4); all three locales are RTL, so the app is `Directionality.rtl` by construction from the locale, never a per-widget flag.

### 5. Make domain values immutable; derive with `copyWith`
`PageCard`, `ReviewGrade`, `CalendarDate`, engine outputs, and backup records are immutable: `final` fields, `const` constructors where possible, `copyWith` for derivation (hand-written or `freezed` per `docs/engineering/04-flutter-and-state-patterns.md`) (`docs/engineering/03-coding-standards.md` §5.1). Riverpod state is exposed read-only and mutated only through the notifier's single write path (`docs/engineering/01-architecture-overview.md` §4). Prefer `final` locals (`prefer_final_locals`) and `const` constructors (`prefer_const_constructors`) — invalid states made unrepresentable are cheaper than runtime validation, and a mutable card is a silent golden-test killer.

### 6. The engine is *total* — it never throws; throwing is for I/O boundaries only
Every `engine` function returns a value for **every** input; uncertainty is an explicit output (a low-confidence flag, a clamped interval, a catch-up plan), never an exception — this is what makes the §7.12 invariants property-testable (`docs/engineering/03-coding-standards.md` §5.2; `docs/engineering/01-architecture-overview.md` §5). Programmer invariants inside the engine use `assert` (stripped in release), never `throw`. Throwing is confined to I/O boundaries — persistence, the asset downloader, backup import/export — and each such module defines **one `sealed` error type** surfaced to the feature layer to handle exhaustively (e.g. `sealed class AssetIntegrityError` with `final` subclasses `ChecksumMismatch`, `PackUnavailable`) (§5.3). `catch` clauses are typed with an `on` clause (`on AssetIntegrityError catch (e)`), never bare — `avoid_catches_without_on_clauses` is an error (§5.4, §7.1). No swallowed errors on a persistence/backup write path: a bare `catch (_) {}` is a review reject because a teacher sign-off (a *sanad* act) is acknowledged only after it is durably committed (§5.4).

### 7. No `print`/logging of user data; no networking outside the downloader
Hifz data is religious-practice records that never leave the device; `avoid_print` is an **error**, and a custom ban forbids `print`/`debugPrint`/`log` in `lib/` outside an explicitly allowed dev-only diagnostics file (`docs/engineering/03-coding-standards.md` §5.5, §7.1). There is no analytics, crash-reporter, or telemetry to log to (`docs/engineering/01-architecture-overview.md` §6). The pure `engine` imports nothing from Flutter/Riverpod/Drift/`dart:io`; networking lives in exactly one module (the asset downloader); both are held by path-scoped `avoid-banned-imports` rules with `severity: error` that you must never `// ignore:` (§6, §7.2).

### 8. Honor the analyzer; satisfy lints, don't suppress them
Write to pass `dart analyze --fatal-infos` and `dart fix --dry-run` clean (`docs/engineering/03-coding-standards.md` §7). Respect the project additions: `prefer_const_*`, `prefer_final_locals`, `require_trailing_commas`, `prefer_is_empty`/`prefer_is_not_empty` (Effective Dart: don't use `.length` to test emptiness), `avoid_positional_boolean_parameters`, `unnecessary_null_checks`, plus `strict-casts`/`strict-raw-types` (§7.1). No `!` (null-assertion) on engine or persistence values — a force-unwrap crash mid-review is a data-trust event; no `late` to dodge honest nullability (allowed only for genuinely-once-initialized fields with a comment); no `dynamic` in the engine or data layers (§5 pitfalls). `// ignore:` on an ordinary style lint needs a same-line justification; `// ignore:` on a §7.2 architecture gate is forbidden (§7.2).

### 9. Land it the project way: small, self-annotated, fully reviewed
Every change lands via a PR with a written intent description, one concern per PR, ≤ ~400 changed LOC, author self-annotating non-obvious hunks before review; `engine`/`data`/`quran`/the downloader get 100% review even for a solo, AI-assisted build (`docs/engineering/03-coding-standards.md` §8). Function/file size limits are *prompts, not laws* — there is no empirical basis for a hard cap, so the analyzer warns, never errors; a long cohesive function (the engine's single `onReview` path) with a one-line justification is acceptable and beats five fragments that scatter the FSRS math (§2). Run the §8.1 checklist before requesting review.

## Do / Don't

| Do | Don't |
|---|---|
| Follow Effective Dart casing verbatim (`UpperCamelCase` types, `lowerCamelCase` members, `Sha256Manifest`) | Invent a house style, or write `SHA256Manifest`/`getDueCards()` |
| Spell domain words in full and put the unit in the name (`stabilityDays`, `dailyBudgetMinutes`) | Use `s`/`stab`/`budget`, or any unit-silent quantity outside one short cited math scope |
| Name a floating day `CalendarDate` (`dueAt`) and an instant `DateTime` (`reminderFireInstant`) | Put a `DateTime` below the boundary, or name an instant like a day |
| Use one fixed transliteration per sacred term (`mushaf`, `manzil`, `mutashabihat`) | Let `mus'haf`/`mushaf`/`mas-haf` drift across the codebase |
| Let `dart format` format everything; write trailing commas for vertical expansion | Hand-format, argue formatting in review, or scatter `// dart format off` |
| Put every UI string in the `l10n` ARB files; rely on `Directionality.rtl` from locale | Hardcode a user-facing string in Dart, or branch RTL per widget |
| `///`-document every public API; comment *why*/units/citations in bodies | Narrate *what* the code does, restate a signature, or leave a constant uncited |
| Make domain values immutable; derive with `copyWith`; prefer `final`/`const` | Hand a mutable `Card` to a widget, or skip `copyWith` for a tweak |
| Keep `engine` functions total (return uncertainty); `assert` invariants | `throw` from the engine, or model uncertainty as an exception |
| Define one `sealed` error type per I/O boundary; `catch` with an `on` clause | Use a bare `catch (_) {}`, swallow a write error, or throw an untyped error |
| Let `avoid_print` + the import bans hold; satisfy lints | `print`/`debugPrint` user data, `// ignore:` a §7.2 gate, or use `!`/`late`/`dynamic` to dodge |

## Checklist

Before the code is done:

- [ ] Casing/naming follow Effective Dart verbatim; identifiers are full dictionary words (no abbreviations outside one short cited math scope) (§1, §1.1).
- [ ] Every quantity carries its unit in the name (`stabilityDays`, `dailyBudgetMinutes`, `targetRetention`); no bare `stability`/`budget`/`target` (§1.1 rule 2).
- [ ] Floating days are `CalendarDate` named as days; the only `DateTime` is a boundary instant named as one (`reminderFireInstant`); no `DateTime` below the boundary (§1.1 rule 3).
- [ ] Sacred terms use the one fixed transliteration; no spelling drift (§1.1 rule 4). Booleans read as assertions; no `get`-prefixed accessors (§1.1 rules 5–6).
- [ ] `dart format` clean; trailing commas present so lists/widget trees expand vertically; no stray `// dart format off` (§3, §7.1).
- [ ] Every public API in `engine`/`data`/`quran` has a `///` summary-first doc; in-body comments give *why*/units/citations, never mechanics; covenants restated at enforcement points; no commented-out code; no TODO without an issue link (§4).
- [ ] No user-facing string hardcoded in Dart — all in the `l10n` ARB files (ar template, fa/ckb); RTL is structural (`Directionality.rtl` from locale), not per-widget (§1.1 rule 4; architecture §2). No AI/audio/network path introduced (architecture §6).
- [ ] Domain values are immutable (`final` fields, `const` ctors where possible, `copyWith`); `prefer_final_locals`/`prefer_const_constructors` satisfied; Riverpod state mutated only through the single write path (§5.1, §7.1).
- [ ] `engine` functions are total — they return uncertainty, never throw; invariants use `assert`; no I/O, no clock, no Flutter import in `engine` (§5.2; architecture §5).
- [ ] Each I/O boundary defines one `sealed` error type; `catch` clauses are typed (`on … catch`), never bare; no swallowed write errors; teacher sign-off acknowledged only after durable commit (§5.3, §5.4).
- [ ] No `print`/`debugPrint`/`log` of user data; no networking import outside the downloader; no `// ignore:` on a §7.2 architecture gate (§5.5, §7.2).
- [ ] No `!` on engine/persistence values; `late` only for genuinely-once-init fields with a comment; no `dynamic` in engine/data (§5 pitfalls).
- [ ] `dart analyze --fatal-infos` and `dart fix --dry-run` clean; any `// ignore:` on a style lint has a same-line justification (§7).
- [ ] PR is one concern, ≤ ~400 LOC, intent described, non-obvious hunks self-annotated; trust-critical modules 100% reviewed with written findings (§8, §8.1).

This skill governs how the code reads, types, and fails — but the non-negotiables it serves live where the logic lives: text fidelity in `quran`, sect-neutrality and no-gamification in the strings and claims, the servant-to-teacher *sanad* act in the write path, privacy in the offline/no-log posture. Clean code here is the precondition that lets an auditor *verify* those guarantees by reading; it never substitutes for them. Where a number, a ruling, or a claim is involved, defer to the domain skill that owns it.

## Files

- `template.dart` — a copy-paste scaffold showing the canonical shapes: an immutable value type with `copyWith` and `///` docs, a total engine function with an `assert` invariant and a citation comment, a `sealed` I/O error type with typed `catch`, a Riverpod `Notifier` single-write-path snippet, and an `analysis_options.yaml` excerpt — every spot to adapt marked `// TODO:`. (Named `.dart` for editor support; copy each labelled block into the right file.)
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **eng-create-package** (the package boundary/manifest this code lives inside), **domain-scheduling-engine-rules** (the engine logic this skill keeps total, named, and documented), **domain-grading-pipeline** (the single write path whose immutability and error rules this enforces), **domain-mushaf-text-integrity** (the `quran` glyph code this skill `///`-documents but never alters), **domain-calendars-and-hifzdate** (the `CalendarDate` value type this skill insists you use and name honestly), **domain-asset-pack-integrity** (the sealed-error I/O boundary whose shape this skill defines), **domain-adab-and-religious-integrity** (the adab/neutrality rules the strings this code references must honor).
