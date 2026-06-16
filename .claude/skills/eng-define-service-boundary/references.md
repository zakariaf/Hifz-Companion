# references — eng-define-service-boundary

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/01-architecture-overview.md` §2 (Layer model) — **The boundary that matters runs between Layer 1 and Layer 2.** Layers 0–1 (`models`, `engine`) are pure Dart that compiles and tests with no Flutter SDK; "side effects (the Drift handle, the notification scheduler, the asset downloader, the `today` clock) cross layers as injected dependencies," and "Riverpod's providers are the dependency-injection mechanism … we add zero extra DI library. No global singletons." This is the one-sentence charter for every boundary.

- `docs/engineering/01-architecture-overview.md` §3.1 (Packages and allowed imports) — **Where the live impl lives and what the interface may import.** `models` imports `dart:core`/`package:meta` only (so an interface signature placed there is framework-free); `engine` imports `models` and nothing — not even `dart:io`; `data` owns Drift/DAOs/repositories; `assets` is "the only module that opens a socket … quarantined here, nowhere else." Take: file the live impl in its layer-2 module, keep the interface below the boundary.

- `docs/engineering/01-architecture-overview.md` §5 (The pure-Dart engine core) — **The clock is a parameter, not a `DateTime.now()`.** "We refuse `DateTime.now()` anywhere in `engine/` … a clock read makes a schedule irreproducible." `today` is an injected `CalendarDate`; this is the prototype side-effect boundary the whole skill generalizes.

- `docs/engineering/01-architecture-overview.md` §6 (The offline guarantee, made auditable) — **The downloader is the one socket; every other boundary is networking-free.** Network is quarantined to `assets/`; every user-data repository imports no networking package; tests "make any stray network call throw"; push notifications are refused (all notifications local). Take: a non-downloader boundary that imports `http` is a bug, and offline is provable by grep.

- `docs/engineering/04-flutter-and-state-patterns.md` §1 (State management & DI: Riverpod 3.x) — **Riverpod is the DI mechanism — no `get_it`, no second library.** "Riverpod folds DI and state into one mechanism — `Provider` declares a dependency, `ref.watch`/`ref.read` consume it, `overrideWith` substitutes it in tests." Bans `get_it`/Bloc/`provider`. Take: a boundary is a `Provider`, and tests swap it with `overrideWith`.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.1 (Ownership rules) — **Injected collaborators live at the composition root via `Provider` (DI); the engine is never reached from a widget; state is immutable.** The ownership table names "the engine, DAOs, repositories, the `CalendarDate` clock, the active profile id" as injected via `Provider`. Take: the boundary's consumers read it through their controller, never through a global.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.2 (The composition root and the profile gate) — **Wire live services exactly once, with a throwing placeholder.** `main` opens the Drift DB and supplies it via `ProviderScope(overrides: [...])`; "placeholder providers throw if read un-overridden, so a forgotten wiring is a loud failure at startup." Shows `clockProvider`, `cardRepositoryProvider`, `appDatabaseProvider.overrideWithValue(db)` — the exact shape `template.dart` mirrors.

- `docs/engineering/04-flutter-and-state-patterns.md` §4 (The single write path) — **Mutating boundaries are wrapped by one repository method that commits before republishing.** "Exactly one route … opens a Drift transaction, appends to the append-only `review_log`, and commits — before any in-memory or stream state becomes observable." Take: a persistence/backup boundary is consumed through the single write path, never called raw; durability precedes acknowledgement (the *sanad* covenant).

- `docs/engineering/11-testing-strategy.md` §2 (The engine is tested with `package:test`) — **A boundary makes the engine deterministically testable.** The engine takes `today` as a parameter so "its tests construct it as a literal; nothing reads a wall clock"; `clock`/`fake_async` are reserved for the app-layer code around it. Take: the fixed-clock fake is what keeps "identical inputs → identical schedule" testable.

## Supporting

- `docs/engineering/11-testing-strategy.md` §1 (The test pyramid) — **Mass goes to the cheapest tier because the boundary is injectable.** Pure logic is unit/property-tested with no widget binding; "controller tests verify only the wiring and the UI-state mapping." Take: a well-drawn boundary moves testing down the pyramid.

- `docs/engineering/11-testing-strategy.md` §6 (Widget, RTL, integration) — **Widget tests use in-memory fakes; integration tests use the real stack.** "The Drift store and asset loader are injected; widget tests use in-memory fakes, integration tests use the real stack." Take: the deterministic double is a plain fake, not a mock; an in-memory Drift DB is the persistence double.

- `docs/engineering/11-testing-strategy.md` §7 (The no-network gate) — **Tests install a throwing `HttpOverrides`; networking imports are banned outside the one downloader.** The throwing override converts "code tried to reach the network" into a named failure; the DCM `avoid-banned-imports` rule denies `dart:io`/`package:http` everywhere except the downloader path. Take: a stray network call from any boundary fails CI loudly.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.3 (End-to-end example: grading a page) — **The full shape in one feature.** The clock is injected (`clock.today()`, never `DateTime.now()`); the write goes through one repository method that commits before anything is observable; failure surfaces as a calm `RetryView`, never a guilt message ([PRD R3]). The template's wiring mirrors this example.

- `docs/engineering/04-flutter-and-state-patterns.md` §2 (View composition and shared components) — **Boundaries emit values; user copy is authored at the feature layer.** Shared components take primitives/localized labels, never a service or domain model; "no gamified affordances anywhere." Take: a boundary never carries EN/fa/ckb/ar copy — the feature layer maps a typed failure to RTL copy.

- `docs/engineering/04-flutter-and-state-patterns.md` Pitfalls (§1) — **The engine never imports Riverpod or Flutter; a provider is a thin wire.** "A single import of either in `engine/` is a build-breaking boundary violation"; "no business logic inside a provider." Take: the boundary's `Provider` does nothing but construct/return the service.

## Sibling skills

- **domain-scheduling-engine-rules** — the pure engine that takes NO injection; `today`, `card`, `grade`, config arrive as explicit parameters. The boundary stops at the engine's door.
- **eng-create-package** — the `pubspec.yaml` that places the interface and enforces "`engine/` imports no Flutter/IO" and "the downloader is the only socket" as manifest-level, machine-checkable boundaries.
- **domain-calendars-and-hifzdate** — what the `Clock` boundary returns: the `CalendarDate` value type, day/elapsed math, and display-only Hijri/Jalālī/Gregorian calendars with locale numerals.
- **domain-asset-pack-integrity** — the downloader boundary's contract: one-time GitHub-Releases fetch, per-file SHA-256 fail-closed verifier, pinned manifest, the single permitted socket.
- **domain-backup-format** — the `.hifzbackup` file a backup-IO boundary reads/writes, its header/integrity check, and replace-vs-merge restore semantics.
- **domain-grading-pipeline** — the `(grade, error_lines, source)` signal that a persistence boundary commits through the single write path.
