---
name: eng-define-service-boundary
description: Introduce a side-effect boundary in the Hifz Companion app — persistence (Drift/SQLite), local notifications, asset/file IO, the clock ("today"), or backup IO — as an injectable Riverpod dependency behind a Dart interface, with a deterministic fake double, so the pure engine and the deterministic tests stay clean. Use whenever wiring a DB handle, the asset downloader, a notification scheduler, the injected CalendarDate clock, or any file/backup IO as a `Provider` override at the composition root instead of a global singleton or a `DateTime.now()`/`HttpClient` call inside a view, controller, or the engine.
---

# eng-define-service-boundary

Every side effect in Hifz Companion — the Drift handle, the local-notification scheduler, the asset downloader, the `today` clock, backup file IO — crosses layers as an **injected dependency behind a Dart interface**, declared as a Riverpod `Provider` and wired exactly once at the composition root. The pure-Dart `engine/` and `models/` packages stay below the boundary: they import no Flutter, no `dart:io`, and never read a wall clock — "today" arrives as a `CalendarDate` parameter (`docs/engineering/01-architecture-overview.md` §2, §5; `docs/engineering/04-flutter-and-state-patterns.md` §1.1).

The payoff is the project's whole testing posture: because the boundary is a `Provider`, a test or a golden run swaps it with a deterministic fake via `overrideWith` — no mock framework, no widget tree, no network — and the engine's "identical inputs → identical schedule" invariant ([PRD §7.12]) stays mechanically testable (`docs/engineering/11-testing-strategy.md` §2). Riverpod *is* the DI mechanism here; we add no `get_it`, no second container (`docs/engineering/04-flutter-and-state-patterns.md` §1).

## When to use

Use this skill when:
- Introducing a new side-effect boundary as an injectable dependency, or modifying one of the existing set: the Drift `AppDatabase` handle, the `Clock`/injected `today`, the local-notification scheduler, the `assets/` downloader, or backup file IO (`docs/engineering/01-architecture-overview.md` §2 — "side effects cross layers as injected dependencies").
- Declaring the `Provider` for a service and **overriding it once in `main`'s `ProviderScope`** — the only place a live service is constructed (`docs/engineering/04-flutter-and-state-patterns.md` §1.2).
- Writing the deterministic fake double of a service (a plain Dart class or in-memory impl) that a controller, repository, or engine test installs with `overrideWith`/`overrideWithValue` (`docs/engineering/11-testing-strategy.md` §2; `docs/engineering/04-flutter-and-state-patterns.md` §7).
- Replacing a stray `DateTime.now()`, `HttpClient`, or global singleton with the injected boundary so the layer below stays pure.

Do NOT use this skill for → use the named sibling instead:
- The **engine itself**, which takes NO injection — it is a pure function receiving `today: CalendarDate`, `card`, `grade`, and config as explicit parameters → use **domain-scheduling-engine-rules**.
- Declaring the **package manifest / `pubspec.yaml`** that places the interface (does `engine/` import this? is the downloader quarantined?) → use **eng-create-package**.
- The actual Drift schema, DAOs, and the single-write-path **repository** body that a `PersistenceHandle` wraps → that is the data layer, governed by **eng-create-package** boundaries and the persistence doc; this skill governs the boundary *shape* and *wiring*, not the SQL.
- The **clock's** date semantics — what `CalendarDate` is, day math, calendar display, locale numerals → use **domain-calendars-and-hifzdate**.
- The **asset downloader's** SHA-256 fail-closed contract and the one permitted socket → use **domain-asset-pack-integrity**.
- The **backup file** layout, header, and merge/replace semantics that a backup-IO boundary moves → use **domain-backup-format**.

## The canonical pattern

1. **An interface, then a live impl — never a `DateTime.now()`/`HttpClient` at the call site.** A side-effect boundary is a small Dart `abstract interface class` (or a typedef-thin function for the simplest, e.g. the clock) whose methods name the operations. The pure layers depend on the *interface*; the live implementation that actually touches Drift, `flutter_local_notifications`, `dart:io`, or the network is a separate class. The canonical shape is the clock — `abstract interface class Clock { CalendarDate today(); }` — read by repositories and the day-plan, never `DateTime.now()` (`docs/engineering/04-flutter-and-state-patterns.md` §1.2 `clockProvider`; `docs/engineering/01-architecture-overview.md` §5 — "today is an injected parameter, not `DateTime.now()`").

2. **The interface lives below the boundary; the live impl lives in its layer-2 module.** The interface signature lives in `models/` or alongside the pure types it returns (it references value types only — a `CalendarDate`, a DTO — never a Flutter or `dart:io` symbol), so `engine/` can name it without importing a framework (`docs/engineering/01-architecture-overview.md` §2 layer table, §3.1 — `models` imports `dart:core`/`package:meta` only). The live impl lives in the layer-2 module that owns that side effect: Drift handle and repositories in `data/`, the downloader in `assets/` (**the only module that opens a socket**), notifications wired by the shell. Networking lives in exactly one place and is CI-greppable (`docs/engineering/01-architecture-overview.md` §3.1, §6; `docs/engineering/11-testing-strategy.md` §7 banned-import rule).

3. **Declare it as a `Provider`; that `Provider` IS the dependency injection.** Each boundary is exposed as a Riverpod `Provider<T>` over the interface type. Consumers `ref.watch` it; nothing reaches a service through a global. There is no `get_it`, no second DI library, no `provider` package alongside Riverpod (`docs/engineering/04-flutter-and-state-patterns.md` §1 — "Riverpod folds DI and state into one mechanism … zero extra DI library"; §1.1 ownership table "injected collaborators … `Provider` (DI)"). A `Provider` is a thin wire only — **no business logic inside it** (`docs/engineering/04-flutter-and-state-patterns.md` Pitfalls).

4. **Wire the live service exactly once, in `main`'s `ProviderScope` overrides.** The composition root is the *only* place a live service is constructed. `main` opens the Drift database, builds the live downloader/notifier/clock, and supplies them via `ProviderScope(overrides: [...])`. Use a **placeholder provider that throws when read un-overridden**, so a forgotten wiring is a loud startup failure, not silent null data (`docs/engineering/04-flutter-and-state-patterns.md` §1.2 — `appDatabaseProvider.overrideWithValue(db)`; "the ONLY place live services are wired"). No global mutable "current service" singleton (`docs/engineering/01-architecture-overview.md` §2 — "no global singletons").

5. **The deterministic double is a plain fake, installed with `overrideWith`.** The test/preview double is a hand-written fake class implementing the same interface (a `FixedClock` returning a literal `CalendarDate`; an in-memory Drift `NativeDatabase.memory()`; a no-op notifier; a `BlockedClient` for the network) — **no mock framework, no codegen** (`docs/engineering/11-testing-strategy.md` §2 — "all providers can be mocked by default"; §6 — widget tests use in-memory fakes, integration tests the real stack). Controllers are tested by faking the **repository**, not the `Notifier` (`docs/engineering/04-flutter-and-state-patterns.md` §7; `docs/engineering/11-testing-strategy.md` §1). Every test/preview injects a **fixed clock** so dates never drift with the host (`docs/engineering/11-testing-strategy.md` §2 — "the engine takes `today` as an argument").

6. **The clock is the one place "now" enters; the engine never sees a boundary.** `today` reaches the system through the injected `Clock` and *only* there; a view, controller, repository, or notification scheduler reads `clock.today()`, never `DateTime.now()` (`docs/engineering/04-flutter-and-state-patterns.md` §1.2; `docs/engineering/01-architecture-overview.md` §4 — "today is INJECTED (a CalendarDate)"). The engine is reached **only** through a repository that has already resolved its inputs — the engine imports no Riverpod, no Flutter, and no service interface (`docs/engineering/04-flutter-and-state-patterns.md` §1.1 rule 2, Pitfalls — "the engine never imports Riverpod or Flutter").

7. **Mutating boundaries persist through the single write path.** A boundary that changes durable state (the persistence handle behind `recordReview`, backup import) is consumed by a **repository method that opens one Drift transaction and commits before any state republishes** — the boundary is wrapped by the single write path, never called raw from a widget or controller (`docs/engineering/04-flutter-and-state-patterns.md` §4 — "exactly one route … persist transactionally before republishing"; `docs/engineering/01-architecture-overview.md` §4 step 5). A `review_log` row is append-only; the write path only appends (`docs/engineering/04-flutter-and-state-patterns.md` §4 table).

8. **Throwing IO boundaries surface as a calm retry, never a guilt message.** Persistence, downloader, notification, and backup boundaries are IO and may fail; their errors propagate to the consuming surface, which renders a calm retry — never a spinner-of-shame or a guilt/fear message ([PRD R3]; `docs/engineering/04-flutter-and-state-patterns.md` §1.3 — `RetryView`/`CalmLoadingView`). The boundary returns values/typed failures; user-facing copy is authored at the feature layer in `ar`/`fa`/`ckb`, not inside the service (`docs/engineering/04-flutter-and-state-patterns.md` §2).

9. **Offline is structural: no networking symbol outside the one downloader, and tests throw on any stray call.** Only the `assets/` downloader boundary may import `package:http`/`dart:io HttpClient`; every other boundary (persistence, notifications, clock, backup) imports no networking package at all, which is what makes "no per-user data leaves the device" provable by a grep (`docs/engineering/01-architecture-overview.md` §6 pillars 1 & 3). Tests keep the binding's 400-blocking client AND install a **throwing `HttpOverrides`**, so an accidental network call from any boundary is a loud failure (`docs/engineering/11-testing-strategy.md` §7). All notifications are **local** (`flutter_local_notifications`) — push requires a server and is refused (`docs/engineering/01-architecture-overview.md` §6 Pitfalls).

## Do / Don't

| Do | Don't |
|---|---|
| Model the boundary as a Dart interface + a separate live impl | Call `DateTime.now()`, `HttpClient`, or a Drift DAO directly from a view/controller/engine |
| Put the interface signature below the boundary (`models/`-level, framework-free) | Let the interface reference a Flutter or `dart:io` symbol |
| Put the live impl in its layer-2 module (`data/` for DB, `assets/` for the downloader) | Scatter networking across modules — it lives in `assets/` only |
| Expose the boundary as a Riverpod `Provider<Interface>` | Add `get_it`, a second DI container, or a global singleton |
| Override the live service once, in `main`'s `ProviderScope(overrides:)` | Construct a live DB/downloader/notifier anywhere but the composition root |
| Make the un-wired placeholder provider **throw** when read | Default a provider to a live service that silently opens IO at import |
| Write a plain fake (`FixedClock`, in-memory Drift, `BlockedClient`) and `overrideWith` it | Reach for a mock framework or codegen to fake a boundary |
| Inject a **fixed clock** in every test and preview | Let a test read the host wall clock or hit the real network |
| Route mutating boundaries through the single write path (one transaction, persist-then-republish) | Call a persistence/backup boundary raw from a widget; republish before commit |
| Surface IO failure as a calm retry; author copy at the feature layer in fa/ckb/ar | Bury a raw error string, or show a guilt/shame message |
| Keep notifications local; keep every non-downloader boundary import-free of networking | Use push notifications, or import `http` outside `assets/` |

## Checklist

Before the boundary is done:

- [ ] It is a Dart interface (`abstract interface class` or a thin function type) with a separate live implementation — no `DateTime.now()`/`HttpClient`/raw DAO at any view, controller, or engine call site.
- [ ] The interface signature lives below the boundary and references value types only (a `CalendarDate`, a DTO) — it imports no `package:flutter` and no `dart:io`, so `engine/`/`models/` can name it (`docs/engineering/01-architecture-overview.md` §2, §3.1).
- [ ] The live impl lives in its layer-2 module: Drift handle/repositories in `data/`, downloader in `assets/` (the only socket), notifications wired by the shell; networking appears in `assets/` only and nowhere else.
- [ ] The boundary is exposed as a Riverpod `Provider<Interface>`; consumers `ref.watch` it; there is no `get_it`, no second DI library, and no business logic inside the provider.
- [ ] The live service is constructed **only** in `main`'s `ProviderScope(overrides:)`; the un-overridden placeholder provider **throws** when read.
- [ ] A deterministic fake exists (e.g. `FixedClock`, `NativeDatabase.memory()`, no-op notifier, `BlockedClient`) and is installed via `overrideWith`/`overrideWithValue` — no mock framework; every test/preview injects a **fixed clock**.
- [ ] `today` enters only through the injected `Clock`; no `DateTime.now()` anywhere reachable from a view, controller, repository, or the engine; the engine imports no Riverpod/Flutter/service interface (`domain-calendars-and-hifzdate`, `domain-scheduling-engine-rules`).
- [ ] A mutating boundary is consumed through the single write path — one Drift transaction, persist-before-republish, `review_log` append-only (`docs/engineering/04-flutter-and-state-patterns.md` §4).
- [ ] IO failures surface as a calm retry (no spinner-of-shame, no guilt copy, [PRD R3]); the boundary emits values/typed failures and the fa/ckb/ar user copy is authored at the feature layer, RTL-correct (`eng-add-localized-string` equivalent; `docs/engineering/04-flutter-and-state-patterns.md` §2).
- [ ] Offline is preserved: every non-downloader boundary imports no networking package; tests install a **throwing `HttpOverrides`** so a stray call fails loudly; notifications are **local** only, never push (`docs/engineering/11-testing-strategy.md` §7; `docs/engineering/01-architecture-overview.md` §6).
- [ ] Adab/integrity: a persistence/backup/sign-off boundary never acknowledges a *sanad* act (a teacher sign-off) before it is durably committed; the boundary carries no telemetry, no account, no PII off-device (`docs/engineering/04-flutter-and-state-patterns.md` §4; `docs/engineering/01-architecture-overview.md` §1, §6).

The boundary is plumbing: it moves bytes and returns values. It must never decide *what* a schedule is (that is the engine, `domain-scheduling-engine-rules`), never render Quran text (that is `quran/`, `domain-mushaf-text-integrity`), and never phone home. If a boundary's failure copy ever reaches a *ḥāfiẓ*, it is calm, sourced at the feature layer, and RTL in all three languages — the work is *lillāh*, so "good enough because it's free" is not the bar.

## Files

- `template.dart` — a copy-paste scaffold for a side-effect boundary: the framework-free interface, the layer-2 `Live*` implementation, the Riverpod `Provider` + throwing placeholder, the `main`-level `ProviderScope` override, and the deterministic fake (`FixedClock` / in-memory Drift) installed with `overrideWith`. Fill the `// TODO` markers. Modeled on the `clockProvider`/`appDatabaseProvider` examples in `docs/engineering/04-flutter-and-state-patterns.md` §1.2.
- `references.md` — the precise governing doc sections, each with one line on what to take from it.

Related skills: **domain-scheduling-engine-rules** (the pure engine that takes NO injection — `today` is a parameter), **eng-create-package** (the `pubspec.yaml` that places the interface and keeps `engine/` pure / the downloader quarantined), **domain-calendars-and-hifzdate** (what the `Clock` returns — `CalendarDate`, day math, calendar display), **domain-asset-pack-integrity** (the downloader boundary's SHA-256 fail-closed contract and the one permitted socket), **domain-backup-format** (the `.hifzbackup` file a backup-IO boundary moves), **domain-grading-pipeline** (the grade signal a persistence boundary commits through the single write path).
