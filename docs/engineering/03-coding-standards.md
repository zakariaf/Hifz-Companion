# Coding Standards

This document defines how Hifz Companion's Dart code is named, formatted, documented, error-handled, and reviewed. For this project, readable code is not aesthetics — the repository is published openly as a form of *waqf*, and the audience auditing it (huffaz, teachers, scholars, privacy-literate reviewers) spends most of its effort *reading*, not writing: field instrumentation of professionals shows on average ~58% of developer time goes to program comprehension ([Xia et al., IEEE TSE 2018](https://research.monash.edu/en/publications/measuring-program-comprehension-a-large-scale-field-study-with-pr/)). Every rule below either has software-engineering evidence behind it (cited inline) or is honestly labeled a heuristic. Tooling stays first-party and CI-gateable: the toolchain-bundled `dart format` and `dart analyze` over a single `analysis_options.yaml`, plus the architecture's banned-import gates (Decision log: *state management*, *no networking*). This doc is the style and review companion to [02-project-structure.md](02-project-structure.md) (package boundaries), [04-flutter-and-state-patterns.md](04-flutter-and-state-patterns.md) (Riverpod conventions), and [11-testing-strategy.md](11-testing-strategy.md) (the CI jobs that run these gates).

## 1. Normative style sources and naming

**Decision.** Naming and API design follow [Effective Dart](https://dart.dev/effective-dart) verbatim; formatting is whatever `dart format` produces; lint baseline is the `flutter_lints` rule set with the project additions in §7. There is no house style that contradicts the language's own. This applies the README's platform decision (Decision log: *Flutter platform & minimum SDK*) down to the source-file level.

**Rationale.** Effective Dart is the canonical, Dart-team-authored guide, and its opening principle is exactly the audit goal — *"If two pieces of code look different it should be because they are different in some meaningful way"* ([Dart: Effective Dart](https://dart.dev/effective-dart)). It splits into **Style**, **Documentation**, **Usage**, and **Design**, and grades each rule **DO / DON'T / PREFER / AVOID / CONSIDER**, so "follow Effective Dart" is a precise, checkable instruction rather than taste. Naming, specifically: identifiers built from dictionary words let professional developers find defects ~19% faster than abbreviations or single letters in a controlled experiment with 72 professionals ([Hofmeister, Siegmund & Holt, EMSE 2019](https://link.springer.com/article/10.1007/s10664-018-9621-x)). Declared in `CONTRIBUTING.md`, verbatim, so contributors have one normative reference.

**Specification.** The Effective Dart casing rules we hold to ([Dart: Effective Dart — Style](https://dart.dev/effective-dart/style)):

| Identifier kind | Convention | Hifz examples |
|---|---|---|
| Types, extensions, enums, typedefs | `UpperCamelCase` | `PageCard`, `CalendarDate`, `ReviewGrade`, `MushafRenderer` |
| Packages, directories, files, import prefixes | `lowercase_with_underscores` | `scheduling_engine.dart`, `package:engine/engine.dart` |
| Other identifiers (vars, params, methods, constants) | `lowerCamelCase` | `dueAt`, `stabilityDays`, `retrievability`, `cycleCeilingDays` |
| Acronyms > 2 letters | capitalize like a word | `Sha256Manifest`, `HttpAssetClient` (not `SHA256Manifest`) |

### 1.1 Project-specific naming rules

1. **Full dictionary words in all domain identifiers — no abbreviations.** `stabilityDays`, never `s` or `stab`; `retrievability`, never `r` (outside a short local math scope, see below). The FSRS literature uses single-letter `D`/`S`/`R`; in code these become `difficulty`, `stabilityDays`, `retrievability` on stored fields, with the terse names confined to the inside of one short pure function where the formula is transcribed and a citation comment maps them ([06-scheduling-engine.md](06-scheduling-engine.md)).
2. **Units and calendar semantics live in the name.** `stabilityDays`, `cycleCeilingDays`, `dailyBudgetMinutes`, `targetRetention` — never bare `stability`/`budget`/`target`. A quantity whose unit is implicit is a defect waiting to happen; making the unit part of the identifier makes the mismatch visible at the call site.
3. **`CalendarDate` vs. `DateTime` is marked by name as well as type** (Decision log: *dates, calendars & correctness*). A `CalendarDate` is a floating calendar day (`dueAt`, `lastReviewedDay`); a `DateTime` is a real instant, legal only at the notification/logging boundary and named as one (`reminderFireInstant`). A `DateTime` named like a day is a review-blocking defect — it is exactly the DST off-by-one class [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md) exists to prevent.
4. **Sacred-domain terms use the established transliteration, consistently.** `mushaf`, `juz`, `hizb`, `surah`, `ayah`, `manzil`, `mutashabihat`, `riwayah` — one spelling per term across the whole codebase (no `mus'haf`/`mushaf`/`mas-haf` drift). User-facing strings are owned by the ARB files ([12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md)), never hardcoded in Dart.
5. **Booleans read as assertions** (Effective Dart): `isWeak`, `isManualLock`, `isPrayerCritical`, `hasTeacherSignoff` — not `weak`, `lock`, `signoff`.
6. **No `get`-prefixed accessors** (Effective Dart: *PREFER making fields and top-level variables `final`*; *DON'T wrap a field in a getter/method needlessly*). Expose `dueCards`, not `getDueCards()`.

```dart
// Bad — abbreviations, get-prefix, unit-silent, instant pretending to be a day
final s = 60.0;
List<PageCard> getDue() => ...;
final DateTime due;

// Good — full words, role-based, units explicit, boundary marked
final double stabilityDays = 60.0;          // FSRS S: days until R falls to 0.9
List<PageCard> get dueCards => ...;
final CalendarDate dueAt;                    // domain: a floating calendar day
final DateTime reminderFireInstant;          // boundary: a real instant, notifications only
```

## 2. The clean-code ruleset and its evidence

| Rule | Evidence | Evidence strength |
|---|---|---|
| Full-word, role-based identifiers everywhere | [Hofmeister et al. 2019](https://link.springer.com/article/10.1007/s10664-018-9621-x) (controlled experiment, 72 professionals, ~19% faster defect-finding) | Strong (experimental) |
| Optimize for reading cost above writing cost | [Xia et al. 2018](https://research.monash.edu/en/publications/measuring-program-comprehension-a-large-scale-field-study-with-pr/): ~58% of dev time is comprehension | Strong (large field study) |
| Function/file size limits are **prompts, not laws** | [Hatton, IEEE Software 1997](https://ieeexplore.ieee.org/document/582978/): U-shaped fault density — medium components beat very small *and* very large | Honest: **no empirical basis for any hard cap** — hence warnings, never errors (§7) |
| Comments document contracts and *why*, never mechanics | [Wen et al., ICPC 2019](https://dl.acm.org/doi/10.1109/ICPC.2019.00019): comments fail to co-evolve with code and become misleading (1.3B AST-level changes, 1,500 systems) | Strong (large mining study) |
| Small, self-annotated, fully-reviewed changes | [SmartBear/Cisco study](https://static0.smartbear.co/support/media/resources/cc/book/code-review-cisco-case-study.pdf) (vendor whitepaper, **not peer-reviewed** — treat LOC numbers as heuristics); [Rigby & Bird 2013](https://dl.acm.org/doi/10.1145/2491411.2491444) (convergent practice); [McIntosh et al. 2014](https://dl.acm.org/doi/10.1145/2597073.2597076) (review participation lowers post-release defects) | Mixed: industrial + convergence + observational |

Practical consequence of the size-limit honesty: when the analyzer flags a 70-line function, the required response is *consider* splitting — extracting three 20-line functions with new interfaces is not automatically better, because Hatton's fault-density U-bend lives partly in the added interfaces ([Hatton 1997](https://ieeexplore.ieee.org/document/582978/)). The scheduling engine's single `onReview` update path ([PRD §7.7](../PRD.md)) is intentionally one cohesive function with a citation comment, not five fragments that scatter the FSRS math; a reviewer may accept a long function with a one-line justification.

## 3. Formatting: `dart format` is the only authority

**Decision.** `dart format` formats every Dart file; its output is never hand-overridden and never argued with in review. CI runs `dart format --output=none --set-exit-if-changed .` so a non-conforming file fails the build.

**Rationale.** A single mechanical formatter removes an entire class of review comments and diff noise; Effective Dart's stance is normative — *"DO format your code using `dart format`"* and *"Formatting is tedious work that is particularly time-consuming on code that's evolving. … Be a good citizen, and use `dart format`"* ([Dart: Effective Dart — Style](https://dart.dev/effective-dart/style)). The formatter targets an **80-character** line by default ([Dart: `dart format`](https://dart.dev/tools/dart-format)); we keep the default — wider walls of Arabic-comment + transliteration text are the exception that the formatter already leaves alone in string literals and comments. Page width is set once, in `analysis_options.yaml`, so the formatter and analyzer agree:

```yaml
# analysis_options.yaml (excerpt) — formatter page width, single source of truth
formatter:
  page_width: 80
```

**Pitfalls / what we refuse.** We do **not** add a competing third-party formatter, a pre-commit hook that reformats with different settings, or per-file `// dart format off` regions (allowed only around a hand-laid test-vector table where alignment is the documentation, and then with a justification comment). Trailing commas are written so the formatter expands argument lists vertically — this keeps widget trees and `copyWith` calls diff-friendly, which directly serves the read-cost-over-write-cost rule (§2).

## 4. Comments and documentation policy

**Decision.** Every public declaration in the pure `engine/` and `data/` packages carries a `///` doc comment; in-body comments explain *why* and cite domain constants, never narrate *what* the code does.

**Rationale.** Effective Dart is explicit: *"DO add documentation comments to all public APIs"* and *"DO use `///` doc comments to document members and types"* ([Dart: Effective Dart — Documentation](https://dart.dev/effective-dart/documentation)). Narrating-the-code comments are banned because they rot into misinformation: comments demonstrably fail to co-evolve with the code they describe ([Wen et al., ICPC 2019](https://dl.acm.org/doi/10.1109/ICPC.2019.00019)), and in a codebase audited for religious and privacy trust, a stale comment that contradicts the code reads as deception, not a harmless typo.

**Specification.**
- **`///` on every `public` API of `engine/`, `data/`, `quran/`** — one-sentence summary first (the analyzer's `dangling_library_doc_comments` and `public_member_api_docs` lints back this, enabled in §7), then parameters, units, and edge behavior.
- **Inside bodies, comment only what code cannot say**: intent, invariants, units, and *why*. Every scheduling/science constant carries a citation comment, e.g. `// DECAY = -0.5 from FSRS-4.5; FACTOR derived so R(S,S)=0.9 (06-scheduling-engine.md)`. These shown-to-auditors rationale comments are the project's methodology evidence — they let a scholar or SR researcher check a number against its source without reading the math.
- **The two product covenants are restated as code comments at their enforcement points.** The trust clamp `dueAt = min(idealDue, ceilingDue)` carries `// PRD §7.6: SR may only make a page MORE frequent, never less`; the sacred-text guard carries `// PRD §7.7: a dropped/altered word is never "Good"`. A reviewer who sees one of these covenants weakened in a diff has an unmissable flag.
- **"Comments touched by this change are still true"** is a mandatory PR-checklist item (§8).

**Pitfalls / what we refuse.** No commented-out code in committed source (delete it; git remembers). No TODO without an issue link. No doc comment that merely restates the signature (`/// Returns the due cards.` above `List<PageCard> get dueCards`); if there is nothing to add beyond the name, the name was already the documentation.

## 5. Immutability, error handling, and logging

**Decision.** Domain values are immutable; the engine is *total* (it never throws); throwing is confined to I/O boundaries; there is no `print`/`log`-to-disk of user data anywhere.

**Rationale.** Immutability + unidirectional flow is a release-relevant invariant, not a style preference: you cannot golden-test a scheduler whose inputs a widget can mutate (PRD §20 gates 3–4), so cards, review logs, and engine outputs are immutable value types ([flutter-architecture-2026.md](research/flutter-architecture-2026.md); [Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). Making invalid states unrepresentable is cheaper and safer than validating them at runtime — Effective Dart pushes the same way (*"PREFER making declarations `private`"*, *"DO use `final` for local variables not reassigned"*).

**Specification.**

1. **Immutable domain types.** `PageCard`, `ReviewGrade`, `CalendarDate`, engine outputs, and backup records are immutable — `final` fields, `const` constructors where possible, and `copyWith` for derivation (hand-written or `freezed`; the choice is fixed in [04-flutter-and-state-patterns.md](04-flutter-and-state-patterns.md)). Riverpod state is exposed read-only and mutated only through the notifier's single write path.

2. **The engine is total — it does not throw.** Every `engine/` function returns a value for every input; uncertainty is an explicit output (a low-confidence flag, a clamped interval, a catch-up plan), never an exception. This is what makes the §7.12 invariants property-testable ([06-scheduling-engine.md](06-scheduling-engine.md), [11-testing-strategy.md](11-testing-strategy.md)). Programmer invariants inside the engine use `assert` (stripped in release), never `throw`:

```dart
/// Next-due day, clamped so the engine may only pull a page *forward*.
/// PRD §7.6 trust clamp — release-blocking invariant.
CalendarDate clampToCycle(CalendarDate idealDue, CalendarDate ceilingDue) {
  final due = idealDue.isBefore(ceilingDue) ? idealDue : ceilingDue;
  assert(!due.isAfter(ceilingDue), 'trust clamp violated: dueAt > cycle ceiling');
  return due;
}
```

3. **Throwing is for I/O boundaries only** — persistence ([05](05-persistence-and-encryption.md)), the asset downloader ([09](09-asset-packs-and-offline-integrity.md)), and backup import/export ([10](10-backup-format.md)). Each such module defines one sealed error type and surfaces it to the feature layer to handle exhaustively:

```dart
/// Failure modes of asset-pack verification. PRD §11.1.1 — fail closed.
sealed class AssetIntegrityError {
  const AssetIntegrityError();
}
final class ChecksumMismatch extends AssetIntegrityError {
  const ChecksumMismatch(this.expected, this.actual);
  final String expected;   // pinned SHA-256 baked into the binary
  final String actual;     // hash of the downloaded bytes
}
final class PackUnavailable extends AssetIntegrityError {
  const PackUnavailable();
}
```

4. **No swallowed errors on write paths.** A bare `catch (_) {}` on a persistence or backup write is a review reject. A teacher sign-off — a *sanad* act — is acknowledged only after it is durably committed (Decision log: *persistence & at-rest encryption*; [05](05-persistence-and-encryption.md)). `catch` clauses are typed (`on AssetIntegrityError catch (e)`), never bare, matching the analyzer's `avoid_catches_without_on_clauses` lint (§7).

5. **No `print`, no console/file logging of user data.** Hifz data is religious-practice records that never leave the device (PRD §17), and a `print` survives outside any encrypted store and can surface in device diagnostics. `avoid_print` is an **error** in our lint config (§7), and a custom analyzer ban (§7.2) forbids `print`/`debugPrint`/`log` in `lib/` outside an explicitly allowed dev-only diagnostics file. There is no analytics, no crash-reporter, and no telemetry to log to in the first place (Decision log: *no networking*).

**Pitfalls / what we refuse.** No `late` to dodge nullability where a nullable type or a constructor argument is honest (`late` defers a null-check crash to first use; we accept it only for genuinely-once-initialized fields with a comment). No `!` (null-assertion) on engine or persistence values — it is the Dart equivalent of a force-unwrap and a crash mid-review is a data-trust event; the analyzer's `avoid_null_checks_in_equality_operators` and our review checklist guard this. No `dynamic` in the engine or data layers.

## 6. Library privacy and the `engine/` purity rule

**Decision.** Each package exposes the minimum public surface; the pure `engine/` package imports nothing from Flutter, Riverpod, Drift, or `dart:io`, and a CI import-ban enforces it.

**Rationale.** The package graph is the audit artifact (Decision log: *state management & DI*; [02-project-structure.md](02-project-structure.md)). A pure-Dart package "contains pure business logic with no Flutter or framework dependencies, making it the easiest layer to test" and runs under `dart test` with no widget binding ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)); that purity is the precondition for the determinism and golden-test guarantees (PRD §7.12, §20 gate 3). Effective Dart's default-private stance (*"PREFER making declarations private"*) keeps the surface honest.

**Specification.**

| Concern | Rule |
|---|---|
| Public surface | A declaration is public (no `_` prefix) only when another package consumes it. Public means contract: doc comment mandatory (§4), change requires a PR note. Adding `public` "just in case" is a review reject. |
| Library privacy | Default `_`-private. No decorative re-export; `export` only the package's intended façade (`engine.dart`, `data.dart`). |
| `engine/` imports | `dart:core`, `dart:math`, `dart:collection` and the package's own files **only**. No `package:flutter/*`, no `package:riverpod/*`, no `package:drift/*`, no `dart:io`, no `dart:async` timers (no wall-clock — "today" is injected). |
| `data/` imports | Drift/SQLite allowed; **no** networking imports (`package:http`, `dart:io` `HttpClient`, `package:dio`). |
| Networking | Permitted in **one** module — the asset downloader (Decision log: *no networking*). Every other path is denied by the import gate (§7.2). |

**Pitfalls / what we refuse.** No `part`/`part of` to smuggle private members across what should be a package boundary. No `@visibleForTesting` to make engine internals public — the engine is tested through its public API, which is the same surface the app uses (if it is hard to test through the public API, the API is wrong). No global mutable singletons; dependencies are injected via Riverpod providers, satisfying Flutter's "use dependency injection / no global state" rule ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)).

## 7. Tooling: `analysis_options.yaml`

**Decision.** One `analysis_options.yaml` at the repo root: `include: package:flutter_lints/flutter.yaml` as the baseline, project additions on top, the formatter page width, and the path-scoped import bans. CI runs `dart format --set-exit-if-changed`, `dart analyze --fatal-infos`, and `dart fix --dry-run` (a non-empty fix list fails) (Decision log: *testing strategy & CI*; [11-testing-strategy.md](11-testing-strategy.md)).

**Rationale.** The `lints` package ships the Dart team's curated `core` and `recommended` rule sets, and `flutter_lints` adds the `flutter` set, *"a superset of the recommended set"* the Flutter team encourages for apps and packages ([Dart: Linter rules](https://dart.dev/tools/linter-rules)). Starting from the official superset means we *subtract or add* deliberately rather than hand-rolling a rule list. `dart fix` mechanizes the boring half — it *"finds and fixes … analysis issues identified by `dart analyze` that have associated automated fixes"* ([Dart: `dart fix`](https://dart.dev/tools/dart-fix)) — so review effort goes to logic, not nitpicks. `--fatal-infos` makes the analyzer's "info" severity a build failure, which is the only way a lint actually holds the line.

### 7.1 `analysis_options.yaml` (repo root)

```yaml
include: package:flutter_lints/flutter.yaml

formatter:
  page_width: 80

analyzer:
  language:
    strict-casts: true          # no implicit dynamic→T casts
    strict-raw-types: true      # no bare generic types (List instead of List<T>)
  errors:
    # Safety/correctness lints promoted to build-failing errors.
    avoid_print: error
    avoid_dynamic_calls: error
    avoid_catches_without_on_clauses: error
    cancel_subscriptions: error
    close_sinks: error
    cast_nullable_to_non_nullable: error
    # Docs are a contract on the audited packages.
    public_member_api_docs: error
    dangling_library_doc_comments: error
    # "info"-level noise we will not silence — surfaced, not muted.
    todo: ignore               # TODOs are tracked in issues, not the analyzer
  exclude:
    - "**/*.g.dart"            # generated (drift, json) — not hand-written
    - "**/*.freezed.dart"
    - "**/*.drift.dart"

linter:
  rules:
    # Beyond flutter_lints: const-correctness (Impeller/rebuild cost) and clarity.
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_final_locals: true
    prefer_final_in_for_each: true
    avoid_redundant_argument_values: true
    require_trailing_commas: true        # formatter expands lists vertically → clean diffs
    unnecessary_lambdas: true
    use_super_parameters: true
    # Effective Dart: faster, more readable emptiness checks
    prefer_is_empty: true                # DON'T use .length to test emptiness
    prefer_is_not_empty: true
    # Boolean and naming hygiene
    avoid_positional_boolean_parameters: true
    # Nullability discipline (§5)
    unnecessary_null_checks: true
    null_check_on_nullable_type_parameter: true
```

`prefer_is_empty`/`prefer_is_not_empty` encode Effective Dart's *"DON'T use `.length` to see if a collection is empty"* — *"there are faster and more readable getters: `.isEmpty` and `.isNotEmpty`"* ([Dart: Effective Dart — Usage](https://dart.dev/effective-dart/usage)). `require_trailing_commas` is what makes `dart format` lay widget trees and `copyWith` calls out vertically, which is the read-cost win of §2 and §3.

### 7.2 Path-scoped import bans (the architecture gates)

These are correctness gates, not style, so they are config-driven and must not silently vanish in a lint refactor. The asset downloader is the single whitelisted networking module (Decision log: *no networking*); the legacy-Riverpod ban enforces the one-state-solution rule (Decision log: *state management & DI*). Implemented with DCM's `avoid-banned-imports`, which supports per-path `deny` regexes with `severity: error` ([DCM: avoid-banned-imports](https://dcm.dev/docs/rules/common/avoid-banned-imports/)) — or equivalently the `import_rules` analyzer plugin ([import_rules](https://github.com/fujidaiti/import_rules)):

```yaml
dcm:
  rules:
    - avoid-banned-imports:
        entries:
          # The pure engine touches no framework, no I/O.
          - paths: ['lib/engine/.*\.dart', 'engine/lib/.*\.dart']
            deny: ['package:flutter/.*', 'package:riverpod/.*', 'package:drift/.*', 'dart:io']
            message: 'engine/ is pure Dart: no Flutter, Riverpod, Drift, or dart:io (PRD §7.12).'
            severity: error
          # Networking lives in exactly one module.
          - paths: ['lib/(?!assets/downloader).*\.dart']
            deny: ['package:http/.*', 'package:dio/.*']
            message: 'Networking is allowed only in lib/assets/downloader (PRD C1, §19.3).'
            severity: error
          # Legacy Riverpod providers are banned project-wide.
          - paths: ['lib/.*\.dart']
            deny: ['package:flutter_riverpod/legacy.dart', 'package:riverpod/legacy.dart']
            message: 'Use Notifier/AsyncNotifier; legacy providers are banned (Riverpod 3.0).'
            severity: error
```

The legacy-provider import was *moved* to `legacy.dart` precisely *"to highlight that those providers are not recommended anymore"* ([Riverpod: What's new in 3.0](https://riverpod.dev/docs/whats_new)); banning the import makes that recommendation a build invariant. The networking dependency-allow-list audit (failing CI if any analytics/ads/backend/crash SDK appears in the resolved graph) is a *separate* CI step specified in [11-testing-strategy.md](11-testing-strategy.md) — these two layers together make "fully offline" a build invariant, not a promise (PRD §20 gate 6).

**Pitfalls / what we refuse.** No `// ignore:` / `// ignore_for_file:` on a §7.2 architecture gate, ever — suppressing a networking or engine-purity ban is a review blocker, not a local exception. `// ignore:` on an ordinary style lint is permitted only with a justifying comment on the same line. We do not install DCM or any analyzer plugin as a *build plugin* that executes third-party code in every build; the import gate runs in the CI lint job only (Decision log: *testing strategy & CI*).

## 8. Code review

**Decision.** Every change lands via a PR with a written intent description, one concern per PR, the §8.1 checklist applied, and 100% review on `engine/`, `data/`, `quran/`, and the asset downloader — even for a solo, AI-assisted build.

**Rationale.** Finding defects is the top *stated* motivation for review, but the dominant realized outcomes are code improvement, knowledge transfer, and awareness — and the bottleneck for all of them is *understanding the change* ([Bacchelli & Bird, ICSE 2013](https://dl.acm.org/doi/10.5555/2486788.2486882)). Google's 9-million-change dataset converges on small, fast, lightweight reviews aimed at code health ([Sadowski et al., ICSE-SEIP 2018](https://research.google/pubs/modern-code-review-a-case-study-at-google/)); cross-company data converges on small changes and ~2 reviewers ([Rigby & Bird, ESEC/FSE 2013](https://dl.acm.org/doi/10.1145/2491411.2491444)). Skipping it has a measured cost: components with low review coverage or participation carry up to 2 and 5 additional post-release defects respectively ([McIntosh et al., MSR 2014](https://dl.acm.org/doi/10.1145/2597073.2597076)) — and *participation* is operative; a rubber-stamp pass delivers nothing. The SmartBear/Cisco ~400-LOC ceiling is a vendor heuristic (not peer-reviewed), but that study's strongest finding — **author self-annotation before review measurably reduces defects** — costs nothing and is mandatory here ([SmartBear/Cisco](https://static0.smartbear.co/support/media/resources/cc/book/code-review-cisco-case-study.pdf)).

**Specification.**
1. **PR-based workflow, even solo.** Every change lands via a PR with a written intent description; the public PR history is part of the *waqf* audit trail.
2. **≤ ~400 changed LOC, one concern per PR**; author self-annotates non-obvious hunks before requesting review.
3. **Second reviewer = structured AI review** against the §8.1 checklist; it must produce written findings (or an explicit "no findings" per section), attached to the PR.
4. **100% review on the trust-critical modules** — `engine/`, `data/`, `quran/`, asset downloader — where a defect is reputation-ending (a wrong glyph, a silently-decayed page, a corrupted schedule).

### 8.1 The checklist (`.github/PULL_REQUEST_TEMPLATE.md`)

**Every PR**
- [ ] Description states intent, approach, and anything not inferable from the diff ([Bacchelli & Bird](https://dl.acm.org/doi/10.5555/2486788.2486882): understanding is the bottleneck)
- [ ] ≤ ~400 changed LOC; author self-annotated non-obvious hunks before review ([SmartBear/Cisco](https://static0.smartbear.co/support/media/resources/cc/book/code-review-cisco-case-study.pdf))
- [ ] `dart format`, `dart analyze --fatal-infos`, `dart fix --dry-run` clean; tests green
- [ ] No new dependency; any `pubspec.lock` change explained (no analytics/ads/backend/crash SDK — Decision log: *no networking*)
- [ ] New/changed public APIs have `///` docs; every comment touched by this change is still true ([Wen et al. 2019](https://dl.acm.org/doi/10.1109/ICPC.2019.00019))

**Sacred text & rendering** (touches `quran/`, asset packs)
- [ ] Quran bytes unchanged; pinned SHA-256 still matches; no runtime line-breaking; markers stay coordinate overlays, never re-typeset text (PRD R1, [08](08-quran-data-and-immutable-rendering.md))

**Scheduling correctness** (touches `engine/`)
- [ ] `engine/` still imports no Flutter/Riverpod/Drift/`dart:io`; "today" still injected
- [ ] Trust clamp holds (`dueAt ≤ cycle ceiling`); manzil never silently dropped; nothing implies a page is "safe to drop" (PRD §7.6, §7.12)
- [ ] New behavior covered by golden/property tests; sacred-text guard (dropped word ≠ "Good") intact ([06](06-scheduling-engine.md), [11](11-testing-strategy.md))

**Dates & calendars** (touches date math)
- [ ] No `DateTime` below the boundary; all scheduling math is `CalendarDate` integer-day arithmetic ([07](07-dates-calendars-and-correctness.md))

**Persistence & privacy**
- [ ] Every mutation flows through the single write path; persisted transactionally before state republishes ([05](05-persistence-and-encryption.md))
- [ ] No bare `catch`, no swallowed write errors, no `!`/`late` shortcuts on engine/persistence values (§5)
- [ ] No `print`/`debugPrint`/logging of user data; no networking outside the downloader (§5, §7.2)

**Localization & RTL** (touches user-facing strings)
- [ ] No hardcoded user-facing strings; new keys in all three ARB locales; numerals/calendar per locale ([12](12-localization-rtl-accessibility-impl.md))

**Trust-critical modules** (`engine/`, `data/`, `quran/`, downloader)
- [ ] Full checklist applied to 100% of changed lines; AI reviewer's written findings attached ([McIntosh et al. 2014](https://dl.acm.org/doi/10.1145/2597073.2597076): participation, not rubber-stamps)

## References

- Bacchelli, A., Bird, C. (2013). *Expectations, Outcomes, and Challenges of Modern Code Review.* Proc. ICSE 2013. https://dl.acm.org/doi/10.5555/2486788.2486882
- DCM. *avoid-banned-imports rule* (per-path `deny` import bans with `severity: error`). https://dcm.dev/docs/rules/common/avoid-banned-imports/
- Dart team. *Effective Dart.* https://dart.dev/effective-dart
- Dart team. *Effective Dart: Style.* https://dart.dev/effective-dart/style
- Dart team. *Effective Dart: Documentation.* https://dart.dev/effective-dart/documentation
- Dart team. *Effective Dart: Usage.* https://dart.dev/effective-dart/usage
- Dart team. *`dart format`* (default 80-character page width; configurable in `analysis_options.yaml`). https://dart.dev/tools/dart-format
- Dart team. *`dart fix`* (applies automated fixes for analysis issues and lint rules). https://dart.dev/tools/dart-fix
- Dart team. *Linter rules* (`lints` `core`/`recommended`, `flutter_lints` `flutter` superset). https://dart.dev/tools/linter-rules
- Flutter (Google). *Architecture recommendations and resources.* https://docs.flutter.dev/app-architecture/recommendations
- Flutter (Google). *Developing packages & plugins.* https://docs.flutter.dev/packages-and-plugins/developing-packages
- fujidaiti. *import_rules* (Dart analyzer plugin for custom import bans). https://github.com/fujidaiti/import_rules
- Hatton, L. (1997). *Reexamining the Fault Density–Component Size Connection.* IEEE Software 14(2), 182–196 (U-shaped fault density; medium components most reliable). https://ieeexplore.ieee.org/document/582978/
- Hofmeister, J., Siegmund, J., Holt, D.V. (2019). *Shorter identifier names take longer to comprehend.* Empirical Software Engineering 24(1), 417–443 (72 professionals; ~19% faster defect-finding with word identifiers). https://link.springer.com/article/10.1007/s10664-018-9621-x
- McIntosh, S., Kamei, Y., Adams, B., Hassan, A.E. (2014). *The Impact of Code Review Coverage and Code Review Participation on Software Quality.* Proc. MSR 2014, ACM. https://dl.acm.org/doi/10.1145/2597073.2597076
- Riverpod. *What's new in 3.0* (legacy providers moved to `legacy.dart`; `riverpod_lint`). https://riverpod.dev/docs/whats_new
- Rigby, P.C., Bird, C. (2013). *Convergent Contemporary Software Peer Review Practices.* Proc. ESEC/FSE 2013, ACM. https://dl.acm.org/doi/10.1145/2491411.2491444
- Sadowski, C., Söderberg, E., Church, L., Sipko, M., Bacchelli, A. (2018). *Modern Code Review: A Case Study at Google.* Proc. ICSE-SEIP 2018, ACM. https://research.google/pubs/modern-code-review-a-case-study-at-google/
- SmartBear Software (2006). *Code Review at Cisco Systems* (industrial study; non-peer-reviewed vendor whitepaper). https://static0.smartbear.co/support/media/resources/cc/book/code-review-cisco-case-study.pdf
- Wen, F., Nagy, C., Bavota, G., Lanza, M. (2019). *A Large-Scale Empirical Study on Code-Comment Inconsistencies.* Proc. ICPC 2019, IEEE/ACM (1.3B AST-level changes, 1,500 systems). https://dl.acm.org/doi/10.1109/ICPC.2019.00019
- Xia, X., Bao, L., Lo, D., Xing, Z., Hassan, A.E., Li, S. (2018). *Measuring Program Comprehension: A Large-Scale Field Study with Professionals.* IEEE TSE 44(10), 951–976 (~58% of developer time on comprehension). https://research.monash.edu/en/publications/measuring-program-comprehension-a-large-scale-field-study-with-pr/
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)
- Hifz Companion. *Documentation blueprint (authoring contract).* [_DOC-SET-BLUEPRINT.md](../_DOC-SET-BLUEPRINT.md)
```

