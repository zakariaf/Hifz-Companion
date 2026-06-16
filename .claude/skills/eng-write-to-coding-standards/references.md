# references — eng-write-to-coding-standards

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/03-coding-standards.md` §1 (Normative style sources and naming) — **Effective Dart verbatim; there is no house style that contradicts the language.** The casing table is law: `UpperCamelCase` types/extensions/enums/typedefs, `lowercase_with_underscores` files/dirs/prefixes, `lowerCamelCase` everything else, acronyms over two letters capitalized like a word (`Sha256Manifest`). Word-built identifiers find defects ~19% faster than abbreviations.

- `docs/engineering/03-coding-standards.md` §1.1 (Project-specific naming rules) — **The six naming rules.** (1) Full dictionary words — no abbreviations; the terse FSRS `D`/`S`/`R` live only inside one short cited pure function. (2) Units in the name (`stabilityDays`, `dailyBudgetMinutes`, `targetRetention`). (3) `CalendarDate` (floating day) vs `DateTime` (boundary instant, named `reminderFireInstant`) — a `DateTime` named like a day is the DST off-by-one defect. (4) One fixed transliteration per sacred term; user-facing strings live in the ARB files, never hardcoded. (5) Booleans read as assertions (`isWeak`, `hasTeacherSignoff`). (6) No `get`-prefixed accessors.

- `docs/engineering/03-coding-standards.md` §2 (Clean-code ruleset and its evidence) — **Optimize for reading cost over writing cost (~58% of dev time is comprehension), and size limits are *prompts, not laws*.** There is no empirical basis for a hard function/file cap (Hatton's U-shaped fault density), so the analyzer warns, never errors; a long cohesive function (the engine's single `onReview`) with a one-line justification beats five fragments that scatter the math.

- `docs/engineering/03-coding-standards.md` §3 (Formatting: `dart format` is the only authority) — **Never hand-format, never argue formatting in review.** 80-char page width set once in `analysis_options.yaml` (`formatter: page_width: 80`); CI runs `dart format --set-exit-if-changed`. Write trailing commas so widget trees and `copyWith` calls expand vertically (diff-friendly). No competing formatter; `// dart format off` only around a hand-laid test-vector table with a justification.

- `docs/engineering/03-coding-standards.md` §4 (Comments and documentation policy) — **`///` on every public API of `engine`/`data`/`quran` (summary first); in-body comments say *why*/units/invariants, never *what*.** Comments rot into misinformation when they don't co-evolve with code. Every scheduling/science constant carries a citation comment; the two covenants are restated at their enforcement points (`// PRD §7.6: SR may only make a page MORE frequent` on the trust clamp; `// PRD §7.7: a dropped/altered word is never "Good"` on the sacred-text guard). No commented-out code, no TODO without an issue link, no doc that restates the signature.

- `docs/engineering/03-coding-standards.md` §5 (Immutability, error handling, and logging) — **Domain values are immutable; the engine is total (never throws); throwing is for I/O boundaries only; no `print`/log of user data.** §5.1 immutable `PageCard`/`ReviewGrade`/`CalendarDate` with `copyWith`, Riverpod state read-only through one write path. §5.2 the engine returns uncertainty as output, `assert` (not `throw`) for invariants. §5.3 one `sealed` error type per I/O boundary, surfaced for exhaustive handling. §5.4 no bare `catch`, no swallowed write error, typed `on … catch` only — a sign-off acknowledged only after durable commit. §5.5 `avoid_print` is an error; no `!`/`late`/`dynamic` shortcuts on engine/persistence values.

- `docs/engineering/03-coding-standards.md` §6 (Library privacy and the `engine/` purity rule) — **Minimum public surface; default `_`-private; the pure `engine` imports nothing from Flutter/Riverpod/Drift/`dart:io`.** Public means contract (doc mandatory). No `@visibleForTesting` to expose engine internals — the engine is tested through its public API. No global mutable singletons; dependencies injected via Riverpod providers.

- `docs/engineering/03-coding-standards.md` §7 (Tooling: `analysis_options.yaml`) — **Write to pass `dart analyze --fatal-infos` and `dart fix --dry-run` clean.** §7.1 the project additions you must satisfy (`prefer_const_*`, `prefer_final_locals`, `require_trailing_commas`, `prefer_is_empty`/`prefer_is_not_empty`, `avoid_positional_boolean_parameters`, `strict-casts`/`strict-raw-types`, `public_member_api_docs`/`dangling_library_doc_comments` as errors, `avoid_print`/`avoid_catches_without_on_clauses` as errors). §7.2 the path-scoped `avoid-banned-imports` gates (engine purity, no-network-outside-`assets`, legacy-Riverpod ban) with `severity: error` — never `// ignore:` a gate; a style-lint `// ignore:` needs a same-line justification.

- `docs/engineering/03-coding-standards.md` §8 / §8.1 (Code review + checklist) — **Every change lands via a PR: one concern, ≤ ~400 LOC, written intent, non-obvious hunks self-annotated; trust-critical modules 100% reviewed.** §8.1 is the runnable done-criteria checklist (format/analyze/fix clean; covenants intact; no `DateTime` below the boundary; single write path persists-before-republishes; no swallowed errors; no hardcoded strings, new keys in all three ARB locales).

## Supporting

- `docs/engineering/01-architecture-overview.md` §2 (Layer model) — **Lower layers never import upward; the boundary that matters runs between Layer 1 (`engine`) and Layer 2 (Flutter shell).** The engine and models are pure Dart (no `package:flutter`); a single Flutter import below Layer 2 re-couples the deterministic core to a widget binding and breaks `dart test` purity. Riverpod is the one DI mechanism; no global singletons.

- `docs/engineering/01-architecture-overview.md` §4 (Unidirectional data flow) — **State flows down, interactions up as commands, every card/log/engine-output is immutable, and the single write path persists transactionally *before* republishing.** A mutable `Card` handed to a widget can be mutated mid-frame and corrupt the next review — immutability is the structural precondition for the golden tests, not a style choice. `due_at` is computed once, in the engine, and never re-derived elsewhere.

- `docs/engineering/01-architecture-overview.md` §5 (Pure-Dart engine core) — **The engine refuses `DateTime.now()` ("today" is an injected `CalendarDate`), refuses interval fuzzing, refuses the `fsrs` pub package as a runtime dep.** `DECAY`/`FACTOR` are named constants; the public surface is a handful of pure functions over value types with "today" always the last argument, never read internally — this is what makes determinism golden- and property-testable.

- `docs/engineering/01-architecture-overview.md` §6 (Offline guarantee, made auditable) — **Networking is quarantined to the `assets` downloader; "fully offline" is a build invariant.** A banned-import lint plus dependency allow-list fail the build on any networking import or analytics/ads/backend/crash SDK elsewhere; there is no telemetry to `print`/log to. This is why §5.5's no-logging rule and §7.2's import bans are correctness gates, not style.

## Sibling skills

- **eng-create-package** — the package manifest, `lib/`-vs-`lib/src/` barrel, dependency boundary, and workspace wiring; this skill governs the code *inside* those files, that one governs the file/package boundary.
- **domain-scheduling-engine-rules** — the FSRS curve, trust clamp, tracks, and golden vectors; this skill keeps that logic total, fully-named, and `///`-documented, but the math lives there.
- **domain-grading-pipeline** — the review→engine→persist single write path; this skill enforces its immutability and error-handling shape, that one owns grade semantics and the sacred-text guard's meaning.
- **domain-mushaf-text-integrity** — the immutable QPC glyph rendering inside `quran`; this skill `///`-documents and never alters that code.
- **domain-calendars-and-hifzdate** — the `CalendarDate`/HifzDate value type and its calendar arithmetic; this skill insists you *use* and *name* it honestly below the boundary, that one owns the conversions.
- **domain-asset-pack-integrity** — the one-time downloader, SHA-256 verifier, and pinned manifest; this skill defines the `sealed` I/O error shape, that one owns the fail-closed integrity policy.
- **domain-adab-and-religious-integrity** — the adab, sect-neutrality, and no-gamification rules the user-facing strings this code references (in the ARB files) must honor.
- **domain-claims-register-and-science-screen** — the cited-claim register; any factual number this code surfaces traces to a claim there, with its citation comment.
