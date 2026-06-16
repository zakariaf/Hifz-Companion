# references — eng-create-riverpod-store

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/04-flutter-and-state-patterns.md` §1 (State management & DI: Riverpod 3.x) — **Riverpod 3.x is the single shell state *and* DI mechanism; modern `Notifier`/`AsyncNotifier` + `Future`/`StreamProvider` only.** No `get_it`, no Bloc, no `provider`; the engine imports nothing from Riverpod. This is the *state management* decision-log entry made concrete.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.1 (Ownership rules — where each kind of state lives) — **The table that tells you which provider shape to pick:** view-local UI state → `State`/small `autoDispose` notifier; per-feature presentation → `Notifier`/`AsyncNotifier` over one immutable value; reactive DB projection → `StreamProvider`; injected collaborator → DI `Provider`; active profile → `Notifier<ProfileId>`. Plus the three hard rules: single write path, the engine is never reached from a widget, immutable state only.

- `docs/engineering/04-flutter-and-state-patterns.md` §4 (The single write path) — **The one rule the layer exists for:** exactly one route from a user action to a durable change — a repository method that opens a `db.transaction`, appends the append-only `review_log` (or writes the user table), and **commits before** any in-memory/stream state becomes observable. The property table (atomicity, durability-before-acknowledgement, audit integrity, no double source of truth, engine purity). Refuses optimistic UI, "save later", and per-screen DAO bypass.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.3 (End-to-end example: grading a page) — **The exact shape to copy:** pure engine `onReview` (today injected), the `CardRepository.recordReview` single-write-path method (`db.transaction` → append `review_log` → upsert `card`, no manual republish), the `AsyncNotifier` `TodayController` with a `grade` command, and the dumb `ConsumerWidget` with `loading`/`error: → RetryView`/`data` branches (calm copy, never a guilt message).

- `docs/engineering/04-flutter-and-state-patterns.md` §3 (Reactive reads: Drift streams through `StreamProvider`) — **Derived read models are `StreamProvider`s over Drift queries, never stored separately-maintained state.** A committed review re-emits the stream → the queue and heat-map rebuild automatically; `R` and juz health are computed on read (min-leaning aggregate), never persisted. No caching layer, no background recompute timer.

## Supporting

- `docs/engineering/04-flutter-and-state-patterns.md` §1.2 (The composition root and the profile gate) — **`ProviderScope` is the root; `main` wires live services *once* by `override`-ing placeholder providers** (a placeholder read un-overridden throws loudly at startup). The active-profile `Notifier<ProfileId>` is the multi-profile gate — switching it recomputes every `family`-keyed provider; no global mutable "current user".

- `docs/engineering/04-flutter-and-state-patterns.md` §5 (Per-profile and per-page state: `family` + `autoDispose`) — **Key per-profile/per-page providers with `family` on a stable, equatable `ProfileId`/`pageId` (never a mutable `Card`); `autoDispose` on screen unmount to bound memory.** Never `autoDispose` the app-scope database/engine singletons.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.4 (The MVVM-lite escape hatch) — **A richer plain controller is permitted *only* for the three staged state machines** (Onboarding/cold-start, Backup/Restore, the Mutashābihāt drill); even there it is a `Notifier` calling the same repository APIs, with no `XxxViewModel` base class. A fourth needs review first — default answer is no.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.5 (Pitfalls / what we refuse) — **The bans:** no legacy providers (`legacy.dart` import is a CI grep), no `get_it`/Bloc/`provider`, no business logic inside a provider (a provider is a thin wire), the engine never imports Riverpod/Flutter, no Riverpod offline-persistence/mutations (persistence is Drift's).

- `docs/engineering/04-flutter-and-state-patterns.md` §2 (View composition and shared components) — **Dumb views; no gamified affordances anywhere** (confetti/badges/streaks are forbidden by PRD R3/C6, not merely discouraged); tokens and strings owned by the design-system and `l10n`, not duplicated per feature.

- `docs/engineering/04-flutter-and-state-patterns.md` §6 (Navigation) — **Stores never navigate; controllers publish state and the View or the `go_router` redirect guard decides the screen.** A notification/deep link is resolved *after* the readiness guard, so it can never bypass onboarding or render an unverified muṣḥaf (PRD R1).

- `docs/engineering/01-architecture-overview.md` §4 (Unidirectional data flow: one review, end to end) — **State flows down, interactions up, every value immutable; the persist step (5) happens *before* the republish step (6).** Refuses a mutable `Card`, "republish then persist", and a second `due_at` computation anywhere — `due_at` is produced only by the engine's trust clamp.

- `docs/engineering/01-architecture-overview.md` §2 (Layer model) — **Riverpod's providers are the DI mechanism; no second DI library, no `provider`+Riverpod, no global singletons.** Repositories and the engine are injected, never reached through globals, which makes them trivially fake-able in tests.

- `docs/engineering/01-architecture-overview.md` §3.1 (Packages and their allowed imports) — **`features` may import `engine`/`data`/`quran`/`l10n`/`profiles` + `flutter_riverpod`/`go_router`, but not DAOs directly;** the engine imports `models` only and nothing from Riverpod/Flutter. The allowed-imports table is normative and grep-checkable.

- `docs/engineering/01-architecture-overview.md` §5 (The pure-Dart engine core) — **The engine refuses `DateTime.now()` — "today" is an injected `CalendarDate` parameter — and refuses interval fuzzing.** A controller passes the injected clock's `today` down; it never lets a clock read leak into the deterministic core.

- `docs/engineering/05-persistence-and-encryption.md` §3 (Crash safety) — **One `db.transaction` per review, WAL + `synchronous=FULL`, persist-before-publish.** The ViewModel republishes new state only *after* the write `Future` resolves; refuses `synchronous=NORMAL`, persist-after-publish, and a missing `await` inside a transaction.

- `docs/engineering/05-persistence-and-encryption.md` §2 (Schema) — **`review_log` is append-only (no `UPDATE`/`DELETE` DAO method); derived health roll-ups are never stored;** `due_at`/`last_review_at` are `CalendarDate` serial integers, never `DateTime` instants. The store's mutation only ever *appends* to the audit trail.

## Sibling skills

- **eng-create-package** — the `pubspec.yaml` / `resolution: workspace` boundary and the engine-purity / no-network / quran-isolation lints that contain the package this store lives in; here for the provider shape, there for the manifest and layer gates.
- **eng-add-persisted-model** — the Drift schema, the append-only `review_log`/`card` tables, migrations, and the repository transaction body the store's single-write-path mutation calls into.
- **domain-scheduling-engine-rules** — the pure `onReview` / trust-clamp / interval arithmetic the controller invokes *through* the repository; the store never does this math itself.
- **domain-grading-pipeline** — the normalization of a recitation verdict into a `ReviewInput` (reveal-on-tap, stumble lines, sacred-text guard, source-confidence) that the controller hands to `onReview`.
- **domain-calendars-and-hifzdate** — the `CalendarDate` value type and the injected clock the store reads "today" from (Hijri / Jalālī / Gregorian correctness).
- **domain-adab-and-religious-integrity** — the no-gamification, servant-to-teacher, and privacy non-negotiables this state layer must never violate.
