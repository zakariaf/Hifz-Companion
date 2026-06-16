# Architecture Overview

This document is the system-design map of Hifz Companion: the layer model, the boundary between the **pure-Dart engine core** and the **Flutter shell**, the module dependency graph, the unidirectional data flow of a single review, and — most load-bearing for the huffaz, teachers, scholars, and auditors who will read this repository openly — how the **offline (no-network) guarantee** is made *auditable* rather than merely asserted. It applies the canonical [tech-decision log](README.md#tech-decision-log) and never re-litigates a decision; it expands the entries **Flutter platform** (Decision 1), **scheduling engine** (Decision 4), and **no networking beyond asset download** (Decision 8), and references the others where they touch the system shape. Detailed specs live in the sibling docs linked throughout: [02-project-structure.md](02-project-structure.md) is the normative package/dependency matrix, [04-flutter-and-state-patterns.md](04-flutter-and-state-patterns.md) the Riverpod View/ViewModel patterns, [06-scheduling-engine.md](06-scheduling-engine.md) the engine internals, and [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md) the downloader and integrity pipeline. The evidence dossier behind this file is [research/flutter-architecture-2026.md](research/flutter-architecture-2026.md).

The standard is *iḥsān*: because the work is built free, *lillāh*, "good enough because it's free" is not the bar — correctness is ([PRD §2](../PRD.md)).

---

## 1. Hard rules → structural mechanisms

The two rules that outrank everything ([README §Rules that outrank everything](README.md#rules-that-outrank-everything)) and the PRD's non-negotiables are not enforced by review discipline; each is held by a *structure* — the package graph, the analyzer, CI, or the type system. An auditor verifies them without trusting a human.

| Rule (PRD / README) | Structural mechanism | Where specified |
|---|---|---|
| Fully offline; no per-user data ever leaves the device ([PRD C1, §17](../PRD.md)) | No networking symbol exists outside one whitelisted downloader module; a two-layer CI gate (dependency allow-list + banned-import lint) fails the build on any networking import elsewhere; the Flutter test binding blocks the network and an `HttpOverrides` makes any stray call throw | §6, (Decision log: *no networking beyond asset download*) |
| The engine may only make a page *more* frequent, never less ([PRD §7.6, §7.12](../PRD.md)) | The trust clamp `due_at = min(ideal_due, ceiling_due)` is the single sink of every review update, in the pure engine, golden- and property-tested; no other layer computes `due_at` | §4, [06-scheduling-engine.md](06-scheduling-engine.md) |
| Identical inputs → identical schedule ([PRD §7.12](../PRD.md)) | The engine imports no Flutter, performs no I/O, and reads no wall clock — "today" is an injected parameter; runs under plain `dart test` with no widget binding; interval fuzzing is OFF | §3, §5, [06-scheduling-engine.md](06-scheduling-engine.md), [11-testing-strategy.md](11-testing-strategy.md) |
| Quran text fidelity is existential ([PRD R1](../PRD.md)) | Glyph-code strings + their page fonts are checksum-pinned atomic units; the OS shaper never lays out Quran text; layout comes from a fixed dataset, never runtime line-breaking; markers are coordinate overlays | [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md) |
| Crash-safe persist on every review ([PRD §17, §20](../PRD.md)) | Single write path: every review commits in one SQLite WAL transaction *before* state republishes ([SQLite: WAL](https://sqlite.org/wal.html)) | §4, [05-persistence-and-encryption.md](05-persistence-and-encryption.md) |
| Crash-safe local persistence with no PII to leak ([PRD §17](../PRD.md)) | No account, no telemetry SDK, no microphone; the data layer's repositories import no `http` at all | §6, [05-persistence-and-encryption.md](05-persistence-and-encryption.md) |

Platform baseline: Flutter, single codebase iOS + Android, RTL-first; a recent stable line (baseline Flutter 3.38 / Dart 3.10, November 2025), with Impeller as the default/mandatory renderer — Skia is removed on iOS and opting out of Impeller on Android is deprecated ([State of Flutter 2026](https://devnewsletter.com/p/state-of-flutter-2026/)). The layered architecture below is version-agnostic and does not depend on a specific release; nothing in §2–§5 is an API surface, it is a structure ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)). PRD C5 pre-commits the platform (Decision log: *Flutter platform*).

---

## 2. Layer model

**Decision.** Adopt Flutter's *official* MVVM-with-layers architecture verbatim as the shell, with exactly one domain-layer citizen — the scheduling engine — kept in a pure-Dart package that imports no Flutter (Decision log: *Flutter platform*, *scheduling engine*; [PRD §19.1–§19.2](../PRD.md)).

**Rationale.** For years Flutter had no opinion on architecture; that gap was filled by community "Clean Architecture" posts of uneven quality. Flutter's team has since published a first-party **Guide to app architecture** whose load-bearing first sentence is the anchor: *"Separation-of-concerns is the most important architectural principle"* ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)). It names a concrete shape — two required layers plus one **optional** layer — and states plainly that this *is* MVVM: *"Views and view models make up the UI layer … repositories and services represent the data layer."* Critically, the domain layer is graded **Conditional**: *"in most apps they add unnecessary overhead"* ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). Hifz Companion has exactly one piece of logic that is the textbook case the domain layer exists for — the scheduler, *"exceeding complex"* and reused across the Today, Progress, and Onboarding ViewModels — and a hundred pieces that are not. Flutter's own advice therefore tells us to give the engine a first-class boundary and keep everything else flat, which is precisely the simplicity bar this project demands.

**Specification.** Five conceptual layers; lower layers never import upward. The engine (Layer 1) and models (Layer 0) are the pure core; Layers 2–4 are the Flutter shell.

| Layer | Contents | May import |
|---|---|---|
| **4 — Shell** | `app/` entry point, Riverpod `ProviderScope` (composition root), router, locale + `Directionality` wiring | Everything (it is the composition root) |
| **3 — UI** | `/features/*` (Today, Muṣḥaf, Mutashābihāt, Progress, Onboarding, Settings), each a View + ViewModel 1:1; `/quran` rendering widgets; design-system widgets | Domain (engine), data-layer repositories, models |
| **2 — Data** | `/data` (Drift schema, DAOs, repositories), `/assets` (asset-pack downloader + SHA-256 verifier), `/profiles` | Models; the engine (repositories call it); Flutter only where unavoidable |
| **1 — Domain (the engine)** | `/engine` — FSRS-style curve, tracks, trust clamp, load balance, cold start; **pure functions, no I/O, no Flutter, no wall clock** | Models only |
| **0 — Models** | Immutable value types: `Card`, `ReviewLog`, `CalendarDate`, `CycleConfig`, `Grade`, engine outputs | `dart:core` / `package:meta` only — the bottom of the graph |

The boundary that matters most runs **between Layer 1 and Layer 2**: everything at Layer 1 and below is plain Dart that compiles and tests without a Flutter SDK, a simulator, or a widget binding; everything at Layer 2 and above is the Flutter shell. A pure-Dart package — depending on `dart:core`/`package:meta` only, never `package:flutter` ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)) — is tested with the plain `test` package, which Flutter calls *"the best approach when writing packages consumed by web, server, and Flutter apps,"* for pure Dart code that does not depend on widgets ([Flutter: unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)).

Side effects (the Drift handle, the notification scheduler, the asset downloader, the `today` clock) cross layers as injected dependencies. Riverpod's providers are the dependency-injection mechanism — Flutter strongly recommends DI and suggests `provider`, but Riverpod supersedes it and folds DI into the same providers, so we add zero extra DI library ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations); Decision log: *state management*). No global singletons; repositories and the engine are injected, never reached through globals, which also makes them trivially fake-able in tests.

**Pitfalls / what we refuse.**
- **We refuse a use-case class per screen.** Flutter says add use-cases *"only when needed"*; manufacturing a domain object for every feature is the over-engineering the recommendations explicitly warn against. The engine is the *one* exception, justified by complexity and reuse.
- **We refuse to let Flutter leak below Layer 2.** A single `import 'package:flutter/…'` in `/engine` or `/models` would silently re-couple the deterministic core to a widget binding and break `dart test` purity; this is enforced by import lint (§5), not hope.
- **We refuse `provider` plus Riverpod.** Two DI mechanisms is two sources of truth; Riverpod alone satisfies the "no global singletons" rule.

---

## 3. Module map: the pure core vs the Flutter shell

The repository is a thin `app/` shell over local packages, mirroring [PRD §19.2](../PRD.md). The normative dependency matrix is [02-project-structure.md](02-project-structure.md); this section summarizes the *core-vs-shell* split and the one network quarantine.

### 3.1 Packages and their allowed imports

| Package | Responsibility | Allowed package imports | Allowed framework imports |
|---|---|---|---|
| `models` | Immutable value types: `Card`, `ReviewLog`, `CalendarDate`, `Grade`, `CycleConfig`, engine I/O DTOs; all `freezed`/`copyWith`, JSON-serializable | — (bottom of graph) | `dart:core`, `package:meta` only |
| `engine` | Forgetting curve, phase/track math, review update, **trust clamp**, load balance, cold-start seeding — **pure, no I/O, no Flutter, no `DateTime.now()`** | `models` | none (not even `dart:io`) |
| `data` | Drift schema, DAOs, repositories (`CardRepository`, `ReviewLogRepository`, `ProfileRepository`); reference-data loader + checksum verifier; the single write path | `models`, `engine` (repositories call it) | `package:drift`, `dart:async` |
| `assets` | The asset-pack downloader (HTTPS GET to GitHub Releases), SHA-256 verifier, local cache — **the only module that opens a socket** | `models` | `package:http` (or `dart:io HttpClient`) — quarantined here, nowhere else |
| `quran` | Immutable per-page glyph rendering (QPC fonts), layout geometry, overlay painter | `models`, `data` (read-only reference) | `package:flutter` (rendering) |
| `features/*` | Today, Muṣḥaf, Mutashābihāt, Progress, Onboarding, Settings; View + ViewModel 1:1 | `models`, `engine`, `data`, `quran`, `l10n` | `package:flutter`, `package:flutter_riverpod` |
| `l10n` | ARB files (`ar` template, `fa`, `ckb`), term-sets, `gen_l10n` output | — | `package:flutter_localizations`, `package:intl` |
| `profiles` | Local multi-profile management (self, students, children) | `models`, `data` | `package:flutter` |
| `app` | Entry point, `ProviderScope`, router, locale/`Directionality`, DI wiring | everything (composition root) | `package:flutter`, `package:flutter_riverpod` |

The split is exact and grep-checkable: **`models` and `engine` are the pure-Dart core** (no Flutter import in either); everything else is the shell. The `engine` depends on `models` and nothing else — its `pubspec.yaml` is the audit evidence, the same way CycleVault's `Package.swift` is.

```yaml
# engine/pubspec.yaml — the manifest IS the audit evidence.
name: hifz_engine
environment:
  sdk: ^3.10.0
dependencies:
  meta: ^1.15.0          # annotations only
  hifz_models:           # the ONLY local dependency — pure value types
    path: ../models
# NO flutter, NO drift, NO http, NO dart:io. dev_dependencies: test, glados.
```

### 3.2 Dependency diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│ app — thin shell (ProviderScope · router · locale/Directionality · DI)│
└───┬───────────────┬───────────────┬───────────────┬─────────────────┘
    │               │               │               │
    ▼               ▼               ▼               ▼
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐
│features/*│   │  quran   │   │ profiles │   │     l10n     │
│ View +   │   │ glyph    │   │ multi-   │   │ ARB / intl   │
│ ViewModel│   │ render   │   │ profile  │   │ (Flutter)    │
└─┬──┬──┬──┘   └────┬─────┘   └────┬─────┘   └──────────────┘
  │  │  │           │              │
  │  │  └───────────┼──────────────┤
  │  ▼              ▼              ▼
  │ ┌──────────────────────────────────┐     ┌────────────────────────┐
  │ │ data — Drift DAOs · repositories  │     │ assets — downloader +  │
  │ │ (single write path)               │◄────┤ SHA-256 verifier       │
  │ └───────────────┬──────────────────┘     │ THE ONLY socket; quaran-│
  │                 │                         │ tined; no user data     │
  ▼                 ▼                         └───────────┬────────────┘
┌─────────────┐     │                                     │
│   engine    │     │                                     │
│ PURE · no   │     │                                     │
│ I/O · no    │     │                                     │
│ Flutter ·   │     │                                     │
│ "today" in  │     │                                     │
└──────┬──────┘     │                                     │
       │            │                                     │
       ▼            ▼                                     ▼
┌──────────────────────────────────────────────────────────────────────┐
│ models — immutable value types (Card, ReviewLog, CalendarDate, …)     │
│ imports dart:core / package:meta only · the bottom of the graph       │
└──────────────────────────────────────────────────────────────────────┘
```

The diagram shows the two facts that define this system's shape: (1) `engine` and `models` sit at the bottom, importing no Flutter and no I/O — the deterministic core; (2) the `assets` downloader is an island — the *only* package that touches a socket, structurally separate from every repository that holds user data, so "no per-user data ever leaves the device" is provable by a grep, not a promise (§6).

### 3.3 Why the engine is a *package*, not just a folder

A folder boundary is a convention a hurried commit can cross; a package boundary is enforced by the toolchain — *"you cannot import something you haven't declared."* Because `engine/pubspec.yaml` does not list `flutter`, a `package:flutter` import there is a *compile error*, not a style nit. This is the same compile-time-enforcement property that makes the layer model auditable, and it is why the PRD already names the scheduler *"a pure-Dart package … independently versioned"* rather than a directory ([PRD §19.1](../PRD.md)).

---

## 4. Unidirectional data flow: one review, end to end

**Decision.** State flows **down** (data layer → UI), interactions flow **up** as commands, and every card/log/engine-output is an **immutable** value type — the pair Flutter grades **Strongly recommend** ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). The single mutation path persists transactionally *before* republishing state.

**Rationale.** Flutter ties immutability and unidirectional flow together deliberately: immutable data *"prevents accidental updates in the UI layer and supports a clear, unidirectional data flow,"* and *"data updates should only flow from the data layer to the UI layer"* while interactions travel the other way ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). For a system whose central guarantee is *"identical inputs → identical schedule"* ([PRD §7.12](../PRD.md)) this is not stylistic. A mutable `Card` handed to a widget could be mutated mid-frame and corrupt the next review computation; an immutable card flowing one way is the structural precondition for the golden tests in [PRD §20 gate 3](../PRD.md). Dart's own execution model reinforces this: code runs in an isolate with *"its own memory and a single thread running an event loop"* and *"none of the state in an isolate is accessible from any other isolate"* ([Dart: Concurrency](https://dart.dev/language/concurrency)) — there is no shared-memory race for a value type to lose to; the only mutation risk is aliasing a mutable object, which immutability forecloses.

**Specification — the lifecycle of a single grade.** A ḥāfiẓ recites page 42, taps **Good**, and marks line 7 as a stumble. The data makes exactly one loop:

```
1. VIEW        TodayScreen renders an immutable DaySession; the recite/grade
               control is a "dumb" widget. User taps Good + stumble line [7].

2. COMMAND     The tap invokes a ViewModel command: gradePage(pageId:42,
               grade:Good, errorLines:[7]). The view manages no try/catch
               or loading flag itself — the command object tracks running/
               result. (Flutter command pattern.)

3. REPOSITORY  TodayViewModel calls CardRepository.recordReview(...). The
               repository is the SINGLE SOURCE OF TRUTH and the only place
               a Card is modified ("repositories … should be the only place
               where data can be modified" — Flutter offline-first).

4. ENGINE      The repository reads the current immutable Card from Drift,
               and calls the PURE engine:
                   newCard = Engine.onReview(card, Good, [7], self, today)
               today is INJECTED (a CalendarDate), never DateTime.now().
               onReview applies the sacred-text guard, S/D update, weak-flag,
               graduation, and the trust clamp due_at = min(ideal, ceiling).
               Same inputs → same newCard, every time. No I/O occurs here.

5. PERSIST     The repository commits in ONE WAL transaction:
                 - append the ReviewLog row (append-only audit trail)
                 - upsert the new Card row
               BEFORE any state republishes. If power is lost mid-write,
               WAL leaves the main DB untouched until checkpoint — the review
               either fully happened or did not (PRD §17; SQLite WAL).

6. REPUBLISH   Only after the commit succeeds does the repository emit the
               new state on its Stream; Riverpod recomputes the dependent
               providers; the Today and Progress ViewModels re-read; the
               views re-render. There is no code path where in-memory state
               is newer than disk.
```

The engine touches no disk and no clock; the repository touches no scheduling math. This separation is what lets the displayed "next due" date and the persisted `due_at` never diverge — they are the same value, computed once in the engine, committed once in the transaction, read back by the view.

**Reading is the mirror, with the network branch deleted.** Flutter's offline-first read pattern yields *local data first, then fresh network data*; *"in offline-first applications, repositories combine different local and remote data sources … independently of the connectivity state of the device"* ([Flutter: Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)). Read that pattern with the remote branch removed and you have our model exactly: the repository reads Drift and is done — there is no second `yield`, no `synchronized` flag (nothing to synchronize *to*), no connectivity observation (the app never connects). We inherit the discipline (repository as single source of truth; the local DB is authoritative) and discard the plumbing. This is documented per-repository as *"local-only; no remote source"* so the absence is intentional and auditable, not an oversight.

**Pitfalls / what we refuse.**
- **We refuse a mutable `Card`.** Cards, logs, and engine outputs are `freezed` value types (Flutter's own offline-first example uses `freezed` for exactly this) ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). A mutable card is a silent golden-test killer.
- **We refuse "republish then persist."** Republishing optimistic state before the WAL commit would create a window where the UI shows a review the disk does not hold — fatal for a *sanad* act (a teacher sign-off) and for crash safety.
- **We refuse a second `due_at` computation anywhere.** `due_at` is produced only by the engine's trust clamp; no ViewModel, no repository, and no SQL view re-derives it. One sink, one truth ([PRD §7.6, §7.12](../PRD.md)).

---

## 5. The pure-Dart engine core: an architectural *and* a testing boundary

**Decision.** The scheduler is a pure-Dart `engine/` package — zero I/O, no Flutter import, "today" injected — vendoring the ~30 lines of FSRS-4.5 arithmetic directly rather than a pub package, with interval fuzzing **OFF** (Decision log: *scheduling engine*; [PRD §7, §19.1, §19.3](../PRD.md)).

**Rationale.** The architectural justification and the testing justification point at the same boundary. Architecturally, Flutter's optional domain layer is the home for *"exceeding complex"* reusable logic, and the engine is the one such citizen (§2). For testing, a package that does not import Flutter has no `WidgetTester` and is tested with the plain `test` package rather than `flutter_test` — Flutter's stated *"best approach when writing packages consumed by web, server, and Flutter apps"* — the fastest, most stable, CI-cheapest tier ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages); [Flutter: unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)). FSRS itself is MIT-licensed and reimplementable with zero runtime dependency — the most accurate open SR algorithm benchmarked ([open-spaced-repetition: FSRS](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler)) — so vendoring its arithmetic keeps the core dependency-free. Determinism has two enemies the boundary removes structurally: a wall clock (so "today" is a parameter, not `DateTime.now()`) and stochastic fuzzing (on by default in every reference scheduler, which would break the §7.12 invariant — hence OFF).

**Specification.** The engine's public surface is a handful of pure functions over value types; "today" is always the last argument, never read internally.

```dart
// engine/lib/engine.dart — pure. No dart:io, no package:flutter, no clock.

/// Power-law forgetting curve. R(S, S) == 0.9 by definition.
double retrievability(int elapsedDays, double s) =>
    pow(1 + factor * elapsedDays / s, decay).toDouble();

/// Days until retrievability falls to [targetR].
double interval(double s, double targetR) =>
    (s / factor) * (pow(targetR, 1 / decay) - 1);

/// The whole design in one line: SR may only make a page MORE frequent.
CalendarDate trustClamp(Card card, CycleConfig cfg, CalendarDate today) {
  final ideal   = today.addDays(interval(card.s, targetR(card)).ceil());
  final ceiling = today.addDays(cycleCeilingDays(card, cfg));
  return ideal.isBefore(ceiling) ? ideal : ceiling;   // min(ideal, ceiling)
}

/// The single review update. Same inputs → same Card, always.
Card onReview(Card card, Grade grade, List<int> errorLines,
              GradeSource source, CalendarDate today) { /* … §7.7 … */ }
```

`DECAY` and `FACTOR` are named constants (`FACTOR` computed from `DECAY`), so an FSRS-6 upgrade is a one-line change; `today` is a `CalendarDate` (Gregorian-serial integer day — Decision log: *dates, calendars & correctness*), because Dart's `DateTime` is an instant that *"does not provide internationalization"* and warns that adding a `Duration` is not adding calendar days across DST ([Dart: DateTime class](https://api.dart.dev/dart-core/DateTime-class.html)). Determinism is then directly testable: a golden fixture pins `(card, grade, errorLines, today) → newCard`, and a `glados` property test asserts `due_at ≤ ceiling` for all generated inputs ([11-testing-strategy.md](11-testing-strategy.md)).

**Pitfalls / what we refuse.**
- **We refuse `DateTime.now()` anywhere in `engine/`.** The boundary is enforced by import lint *and* by the package manifest (no `flutter`, no `dart:io`); a clock read makes a schedule irreproducible and silently un-golden-testable.
- **We refuse interval fuzzing.** Every reference scheduler enables it by default; it would make `due_at` non-deterministic and void the §7.12 contract. The real anti-pile-up mechanism is the load balancer's peak smoothing within the ceiling (§7.9), which is itself deterministic.
- **We refuse the `fsrs` pub package as a runtime dependency.** Vendoring ~30 lines we can read and test beats taking an SDK we cannot audit line-by-line into the sacred path ([PRD §7.3](../PRD.md)).

---

## 6. The offline (no-network) guarantee, made auditable

**Decision.** The *only* permitted network client is the asset-pack downloader (HTTPS GET to GitHub Releases/CDN, carrying no auth, cookies, or identifiers); "fully offline" is a **build invariant**, not a promise, enforced by a two-layer CI gate plus test-time network blocking (Decision log: *no networking beyond asset download*; [PRD C1, §17, §19.3, §20 gate 6](../PRD.md)).

**Rationale.** This audience does not accept "trust us." The PRD's offline constraint is reputation-ending if broken and is also the F-Droid entry ticket verbatim — FLOSS-everything, no analytics/ads/tracking SDKs ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)). An import-level grep alone is *unsound*, exactly as it is in CycleVault: `HttpClient` ships inside `dart:io`, which non-UI code may legitimately import, so the most likely accidental — or malicious-PR — networking path needs no obvious networking `import`. The guarantee therefore rests on independently verifiable pillars, structural and runtime.

**Specification — four pillars.**

**1. The network is quarantined to one module.** Only `assets/` may open a socket; it loads raw bytes, holds no state, and is wrapped by an asset repository that verifies SHA-256 against the binary's **pinned manifest** before anything renders — fail-closed: any mismatch ⇒ reject, re-fetch once, then refuse to render Quran text ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md); Decision log: *Quran asset distribution & offline integrity*). Every user-data repository in `data/` imports no networking package at all, so the "no per-user data leaves the device" claim is provable by reading the `data/` import lines.

**2. A dependency allow-list fails on any analytics/ads/backend/crash SDK in the resolved graph.** A CI step walks the locked dependency tree and fails the build if any tracking, ads, push, or crash-reporting package appears — the same banned-SDK list F-Droid enforces ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)). There is no Firebase, no Crashlytics, no analytics; the absence is asserted, not assumed.

**3. A banned-import lint forbids networking imports everywhere except `assets/`.** A `custom_lint` / DCM `avoid-banned-imports` rule (configurable per-path banned imports with custom messages — [DCM: avoid-banned-imports](https://dcm.dev/docs/rules/common/avoid-banned-imports/)) — or the equivalent `import_lint` no-restricted-paths rule ([import_lint](https://pub.dev/packages/import_lint)) — bans `package:http`, `package:dio`, and `dart:io`'s `HttpClient`/`Socket` across every package **except** the whitelisted `assets/` downloader. The allow-list is that one module; the rule fails the analyzer, and the analyzer fails CI.

```yaml
# analysis_options.yaml (sketch) — networking is allowed in ONE place.
dart_code_metrics:
  rules:
    - avoid-banned-imports:
        entries:
          - paths: ['.*\.dart$']                 # all Dart files …
            exclude-paths: ['.*/assets/.*\.dart$'] # … except the assets/ downloader
            deny: ['package:http/.*', 'dart:io', 'package:dio/.*']
            message: 'Networking is quarantined to assets/ (PRD C1, §17).'
```

**4. Tests make any stray network call throw — and the runtime is user-verifiable.** Flutter's test binding already overrides `HttpClient` to return **400** for every request so tests cannot accidentally hit the network ([flutter/flutter #77245](https://github.com/flutter/flutter/issues/77245); [Flutter API: TestWidgetsFlutterBinding](https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html)). We weaponize this: pure-engine and repository tests install an `HttpOverrides` whose client *throws*, so any accidental network call fails the suite loudly rather than silently 400-ing. At runtime, a user confirms the guarantee themselves — after the one-time core-pack download at onboarding, the entire app is fully functional in airplane mode, permanently ([PRD §11.1.1, §17](../PRD.md)).

**The one true network event is not this pattern.** The core-pack download ([PRD §11.1](../PRD.md)) is a verified *static* fetch that runs once at onboarding, behind the separate `assets/` service, and never touches user data — its request carries only a public asset URL. It is architecturally and import-boundary separate from every user-data repository, which is what keeps the offline guarantee structurally provable.

**Pitfalls / what we refuse.**
- **We refuse an in-app browser or `url_launcher` for the repository link.** A WebView fetches arbitrary remote content and `url_launcher` can exfiltrate via a query string; the About screen renders the repo URL as selectable, copyable text — a deliberate UX cost the guarantee is worth (the same trade CycleVault makes).
- **We refuse TLS certificate pinning against GitHub.** Cert pinning risks a rotation outage and is an anti-pattern here; the real end-to-end integrity guarantee is content-hash pinning (SRI's fail-closed model) over GitHub's immutable releases ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md); Decision log: *Quran asset distribution & offline integrity*).
- **We refuse push notifications.** Push requires a server; all notifications are local (`flutter_local_notifications`), calm, and never guilt/fear ([PRD §14](../PRD.md)).

---

## 7. What the architecture deliberately declines

Stated plainly, because a hostile reviewer reaches these in the first hour, and because an honest scope is itself a trust feature:

- **No multi-device sync, no CRDTs.** The local-first literature's hard part — conflict-free replication for concurrent edits across devices ([Kleppmann et al., 2019](https://www.inkandswitch.com/essay/local-first/)) — is consciously out of scope; we have no concurrent edits because we have no sync. "A teacher sees a student's data" is file export → import ([PRD §16](../PRD.md)), not a server. This is the right trade for an app where privacy is religious trust ([PRD R5](../PRD.md)) and simplicity is a non-negotiable value.
- **No reproducible-build claim on iOS.** App Store FairPlay encryption makes byte-identical verification impossible there; we claim reproducible Android builds and the strongest truthful privacy posture, and say so ([13-oss-repo-and-release.md](13-oss-repo-and-release.md)).
- **No absolute secrecy on a compromised OS.** A jailbroken or instrumented device defeats any app-level guarantee; the optional at-rest encryption ([05-persistence-and-encryption.md](05-persistence-and-encryption.md)) and the offline posture are the realistic, stated scope, not a promise of invulnerability.

---

## References

- Flutter (Google). *Guide to app architecture* (separation of concerns; UI/data/domain layers; MVVM; repository-as-source-of-truth; one-to-one view/view-model). https://docs.flutter.dev/app-architecture/guide
- Flutter (Google). *Architecture recommendations and resources* (graded recommendations: separation of concerns, immutable models, unidirectional flow, dependency injection, the conditional domain layer). https://docs.flutter.dev/app-architecture/recommendations
- Flutter (Google). *Offline-first support* (repository as single source of truth across local/remote, independently of connectivity; write-local-then-sync with a `synchronized` flag; `freezed` models). https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- Flutter (Google). *Developing packages & plugins* (pure-Dart packages with no Flutter dependency are the most testable layer). https://docs.flutter.dev/packages-and-plugins/developing-packages
- Flutter (Google). *An introduction to unit testing* (`package:test` / `dart test` for pure-Dart logic without a widget binding). https://docs.flutter.dev/cookbook/testing/unit/introduction
- Flutter API. *TestWidgetsFlutterBinding class* (overrides `HttpClient` to return 400, blocking the network in tests). https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html
- flutter/flutter. *Issue #77245 — `TestWidgetsFlutterBinding` makes all HTTP requests return 400 and blocks real network calls.* https://github.com/flutter/flutter/issues/77245
- Dart team. *Concurrency in Dart* (isolates: own memory, single thread, event loop; state not shared across isolates). https://dart.dev/language/concurrency
- Dart team. *DateTime class — dart:core* (an instant, not a date; no internationalization; the DST/`Duration` warning). https://api.dart.dev/dart-core/DateTime-class.html
- DCM. *avoid-banned-imports* (per-path banned imports with custom messages, for architectural-boundary enforcement). https://dcm.dev/docs/rules/common/avoid-banned-imports/
- kawa1214. *import_lint* (Dart import-restriction rules; no-restricted-paths model). https://pub.dev/packages/import_lint
- SQLite Consortium. *Write-Ahead Logging* (atomic commits; main file untouched until checkpoint; power-loss robustness). https://sqlite.org/wal.html
- Open Spaced Repetition. *Free Spaced Repetition Scheduler* (MIT; DSR model; reimplementable, no runtime dependency). https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler
- F-Droid. *Inclusion Policy* (FLOSS-everything; banned analytics/ads/tracking/crash SDKs). https://f-droid.org/en/docs/Inclusion_Policy/
- Kleppmann, M., Wiggins, A., van Hardenberg, P., & McGranaghan, M. (2019). *Local-first software: you own your data, in spite of the cloud.* Onward! 2019 (ACM SIGPLAN). https://www.inkandswitch.com/essay/local-first/
- *State of Flutter 2026.* Developer Newsletter (version baseline; Impeller default/mandatory; Skia removal). https://devnewsletter.com/p/state-of-flutter-2026/
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)
- Hifz Companion. *Modern Flutter App Architecture (2025–2026)* — research dossier. [research/flutter-architecture-2026.md](research/flutter-architecture-2026.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
