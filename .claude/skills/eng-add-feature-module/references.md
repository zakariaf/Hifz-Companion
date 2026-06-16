# references — eng-add-feature-module

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/02-project-structure.md` §3.4 (Feature folder anatomy) — **A feature is a folder in the `features` umbrella, not a package.** One Dart library per screen: `<feature>_screen.dart` (the dumb entry View), `<feature>_view_model.dart` (the 1:1 ViewModel), `widgets/` (leaf views), `<feature>_providers.dart` (providers **scoped to the feature**, never global). The existing six: today, mushaf, mutashabihat, progress, onboarding, settings. Deviations need a PR comment.

- `docs/engineering/02-project-structure.md` §3.1 (Dependency matrix) — **`features` depends *down* on `engine`, `data`, `quran`, `l10n`, `profiles` (+ `flutter_riverpod`, `go_router`); no leaf imports `features`.** Deliberately NO `http`/`dio` (no feature fetches anything), NO `drift` (features touch the DB only through `data`'s repositories). Dependencies point one way.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.1 (Ownership rules) — **The three hard rules:** (1) single write path — a widget never mutates persisted state; every change is a repository method that persists transactionally *then* republishes; (2) the engine is never reached from a widget — View → controller → repository → engine; (3) immutable state only. Plus the state-location table: view-local UI state in the widget (no `useState`), per-feature state in a `Notifier`/`AsyncNotifier`, DB projections derived via `StreamProvider`, collaborators injected via `Provider`.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.3 (End-to-end example: grading a page) — **The canonical feature, end to end:** the dumb `ConsumerWidget` reads one `AsyncNotifier`; the controller exposes a `grade(...)` command that routes the write through `cardRepositoryProvider.recordReview(...)`; the repository commits before the Drift stream re-emits; `.when(loading/error/data)` surfaces a **calm retry**, never a guilt message. "today" is injected, never `DateTime.now()`.

- `docs/engineering/04-flutter-and-state-patterns.md` §6 (Navigation) — **`go_router` `ShellRoute` hosts the persistent RTL bottom nav; add a `GoRoute` per screen with typed, deep-linkable params.** RTL order (rightmost = home): **Today · Muṣḥaf · Mutashābihāt · Progress · Settings**; the bar and directional icons mirror automatically under the app-wide `Directionality`. The redirect guard blocks any Quran screen until the core pack is verified and a profile exists — a new route inherits it. No imperative `Navigator.push`; no navigation from inside a controller.

## Supporting

- `docs/engineering/04-flutter-and-state-patterns.md` §3 (Reactive reads via `StreamProvider`) — **Derived read models are `StreamProvider`s over Drift queries, never stored state:** Today's queue, the retention heat-map, per-juz/page health. A committed review re-emits the stream and rebuilds the UI — one source of truth. `R` is computed on read, never persisted; **juz health is the min-leaning aggregate** (the weakest page, not the mean — one weak page fails a ḥāfiẓ in ṣalāh). No caching layer, no background timer.

- `docs/engineering/04-flutter-and-state-patterns.md` §5 (Per-profile / per-page state) — **`family` + `autoDispose`:** key per-profile providers by `ProfileId` and per-page providers by `pageId`; dispose on unmount to bound memory on low-end Android. No un-keyed "current profile" provider; no `autoDispose` on the app-scope db/engine; `family` keys are stable equatable values, never a `Card`.

- `docs/engineering/04-flutter-and-state-patterns.md` §4 (The single write path) — **Exactly one route from a user action to disk:** a repository method opens one Drift WAL transaction, appends to the append-only `review_log`, commits — *before* any state is observable. The `await` returns only after commit; the UI updates only when the stream re-emits. No optimistic "republish then persist", no "save later"/debounced write for a review or sign-off (durable *sanad* acts), no DAO write from a widget/controller.

- `docs/engineering/04-flutter-and-state-patterns.md` §2 (View composition and shared components) — **Compose by extracting named widgets, don't grow `build`; promote to shared `ui/` only when reused by ≥2 features AND domain-blind** (knows no `Card`/`Grade`/muṣḥaf). The arrow is one-way (features import `ui/`, never reverse); shared components never read providers. **No hard-coded colors/spacing — tokens by name; no gamified affordances anywhere** (confetti/badges/streaks forbidden, not discouraged).

- `docs/engineering/04-flutter-and-state-patterns.md` §1 (Riverpod 3.x) — **Modern providers only:** `Notifier`/`AsyncNotifier` + `Future`/`StreamProvider`; legacy `StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider` (now in `flutter_riverpod/legacy.dart`) are banned by a CI grep. No `get_it`, no Bloc, no `provider`. No business logic inside a provider — it is a thin wire.

- `docs/engineering/04-flutter-and-state-patterns.md` §1.4 (MVVM-lite escape hatch) — **A richer plain `Notifier` holding multi-step presentation state is permitted ONLY for the three staged screens:** Onboarding/cold-start, Backup/Restore, the Mutashābihāt discrimination drill. Even there it stays a feature-target `Notifier`, still calls the same repository APIs, adds no `XxxViewModel` interface/base class. A fourth needs review first; the default is no.

- `docs/engineering/04-flutter-and-state-patterns.md` §7 (Testing the shell) — **Test the controller with `ProviderContainer.test()` + `overrideWith`, faking the repository — not the `Notifier`.** No widget pump, runs in milliseconds; verify wiring and UI-state mapping only, not the FSRS math (the engine has its own pure golden/property tests).

- `docs/engineering/02-project-structure.md` §3.3 (Exemplar manifests — `features` excerpt) — **The `features` manifest is the audit map:** narrow downward `path:` deps + `flutter_riverpod` (not legacy `provider`) + `go_router`; deliberately NO `http`/`dio`, NO `drift`. You generally don't edit it when adding a folder — confirm it already grants exactly these.

- `docs/engineering/02-project-structure.md` §5 (Dependency rules) — **Machine-checked boundaries:** the DCM `avoid-banned-imports` rule bans an import regex per `paths` regex — including **"features must not import another feature's internals; share via a leaf package"** (entry #4). Belt-and-suspenders `tool/` greps catch the symbol-level bans (a stray `DateTime.now()`, a `package:http` outside `assets`). Convention is a comment; the lint and the grep are the guarantee.

- `docs/engineering/02-project-structure.md` §6 (Localization, fonts, generated sources) — **Every UI string lives in the `l10n` package** (`ar` template, `fa`/`ckb`), generated with `synthetic-package: false` and committed; the completeness gate is "zero missing keys / no hardcoded UI strings". A feature never inlines a literal.

- `docs/engineering/02-project-structure.md` §2 (The app shell) — **`app/` is the composition root — the one target that imports every package because it computes nothing.** Live db/asset/clock providers are wired in `composition/providers.dart`; the router table is `composition/router.dart`; `bootstrap/first_run.dart` does the one-time verified core-pack download. Any business logic in `app/lib/` is a review-blocking bug — keep it in the feature/ViewModel.

- `docs/engineering/01-architecture-overview.md` §2 (Layer model) — **Five layers; lower never imports upward. A feature is Layer 3 (UI), above data (2) and the engine (1).** The domain layer is "conditional" — the engine is the one citizen; everything else is flat feature folders. We refuse a use-case class per screen.

- `docs/engineering/01-architecture-overview.md` §4 (Unidirectional data flow) — **State flows down, interactions flow up as commands; the lifecycle of one grade in six steps** (View → command → repository → pure engine with injected "today" → one WAL transaction → republish only after commit). We refuse a mutable `Card`, "republish then persist", and a second `due_at` computation anywhere — one sink, one truth.

- `docs/engineering/01-architecture-overview.md` §6 (Offline guarantee) — **The feature is offline/no-AI by construction:** networking is quarantined to `assets/`; a banned-import lint + dependency allow-list fail the build on any networking/analytics/backend import in a feature. No microphone, no model, no push. The user verifies it themselves — airplane mode, permanently, after the one-time download.

## Sibling skills

- **eng-create-package** — the umbrella `features` package's `pubspec.yaml` and the seven-package boundary (engine → data/assets/quran/l10n/profiles → features → app) this feature folder sits inside; go there for a *new package* or a manifest fix, here for a *new folder*.
- **domain-grading-pipeline** — the review → engine → persist single-write-path repository method (`recordReview`, teacher sign-off) the ViewModel calls; the feature *invokes* it, it does not author it.
- **domain-scheduling-engine-rules** — the pure DSR logic (curve, trust clamp, `buildToday` ordering, load balance, cold-start, heat-map honesty / "never safe to drop") the feature reads but never re-derives.
- **domain-mushaf-text-integrity** — the immutable QPC glyph rendering inside `quran` that a Muṣḥaf feature composes and never re-typesets.
- **domain-mutashabihat-system** — the discrimination-trainer dataset and drill the Mutashābihāt feature hosts.
- **domain-calendars-and-hifzdate** — the injected `CalendarDate` clock and Hijri / Solar-Hijri-Jalālī / Gregorian conversion the ViewModel uses instead of `DateTime.now()`.
- **domain-adab-and-religious-integrity** — the calm, non-coercive, no-gamification, servant-to-teacher, sect-neutral copy and adab every new surface must honor.
