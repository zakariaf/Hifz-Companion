---
name: eng-create-riverpod-store
description: Author or extend a long-lived Riverpod 3.x provider/notifier (an app-scope Notifier/AsyncNotifier, a StreamProvider over a Drift query, a DI Provider, or a family/autoDispose controller) in the Hifz Companion Flutter shell, or add a mutation that writes persisted state. Use whenever creating or extending an app-scope provider/notifier, wiring a controller into the composition root, deriving a reactive read model from a Drift stream, or adding any mutation that must persist transactionally BEFORE republishing in-memory state. Enforces the single write path (persist-before-republish through a repository), Notifier/AsyncNotifier only (no legacy providers, no Bloc, no get_it), immutable UI state, family+autoDispose keying, and no DateTime.now() in shell logic.
---

# eng-create-riverpod-store

Riverpod 3.x is the *single* mechanism for both shell state and dependency injection in Hifz Companion — there is no `get_it`, no Bloc, no `provider`. Every long-lived store the shell owns is one of four shapes: a `Notifier`/`AsyncNotifier` feature controller exposing an immutable UI-state value, a `StreamProvider` deriving a read model from a Drift query, a plain `Provider` injecting a collaborator (the engine, a repository, the `CalendarDate` clock, the active profile), or a `family`/`autoDispose` variant keyed by `ProfileId`/`pageId`. The rule the whole layer exists to enforce is the **single write path**: every mutation is a repository method that persists transactionally **before** any in-memory or stream state becomes observable, which makes the PRD's crash-safe, *sanad*-respecting "persist on every review" guarantee structural rather than a matter of discipline.

This skill governs the provider/notifier shape itself — the wiring, the ownership rules, and the write-path contract. The pure scheduling math the controller calls is the engine (`domain-scheduling-engine-rules`); the package manifest and boundary lints that keep the engine pure and networking quarantined are `eng-create-package`; the Drift schema, DAOs, and the repository's transaction body are `eng-add-persisted-model`.

## When to use

Use this skill when you:

- create a new app-scope `Notifier`/`AsyncNotifier` feature controller (Today, Progress, Settings, Mutashābihāt, Onboarding), or extend an existing one;
- add a mutation method that writes persisted state — every such method is part of the single write path (grade a page, teacher sign-off, edit cycle config, mark onboarding coverage, switch the active profile's settings);
- expose a derived read model (today's revision queue, the whole-Quran retention heat-map, per-juz/per-page health) as a `StreamProvider` over a Drift query;
- declare a DI `Provider` for a collaborator (the engine, a repository, the clock, the active-profile gate) in the composition root, or `override` a placeholder provider in `main`'s `ProviderScope`;
- key a provider by `ProfileId`/`pageId` with `family` and dispose it with `autoDispose`.

Do **NOT** use this skill for:

- the **scheduling arithmetic** itself (the FSRS curve, `onReview`, the trust clamp, tracks, intervals) — that is the pure engine; a provider that does interval math reads the wrong layer → use **domain-scheduling-engine-rules**.
- the **package `pubspec.yaml`, the engine-purity / no-network / quran-isolation boundary lints**, or wiring a new `resolution: workspace` member → use **eng-create-package**.
- the **Drift schema, DAOs, the append-only `review_log`/`card` tables, migrations, and the repository's transaction body** the store's mutation calls into → use **eng-add-persisted-model**.
- normalizing a **recitation verdict into a `ReviewInput`** (reveal-on-tap, stumble lines, the sacred-text guard, source-confidence) before the engine sees it → use **domain-grading-pipeline**.
- the **calendar/date value type** (`CalendarDate`, the injected clock, Hijri/Jalālī/Gregorian) the controller reads "today" from → use **domain-calendars-and-hifzdate**.
- **View-local UI state** (sheet visibility, which line is revealed in the recite flow, in-flight text) — that is a `StatefulWidget`'s `State` or a small `autoDispose` `NotifierProvider` scoped to the feature, never an app-scope store (`docs/engineering/04-flutter-and-state-patterns.md` §1.1).

The store/controller publishes immutable state and routes writes through one repository method; the engine computes, the repository persists, the Drift stream republishes. A provider that mutates persisted state directly, reads a wall clock, or re-derives `due_at` is the wrong layer.

## The canonical pattern

1. **Modern providers only — `Notifier`/`AsyncNotifier`, `Future`/`StreamProvider`; legacy banned.** Riverpod 3.x is the single shell state + DI solution; the legacy providers (`StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`) moved to `package:flutter_riverpod/legacy.dart` and importing that file is a **CI-failing grep**. There is no `get_it`, no Bloc, no `provider` — a second DI/state library is a second dependency to vet against the no-extra-SDK gate. `docs/engineering/04-flutter-and-state-patterns.md` §1 (Decision: *state management*) and §1.5 (Pitfalls: no legacy providers, no `get_it`/Bloc/`provider`); `docs/engineering/01-architecture-overview.md` §2 (Riverpod is the DI mechanism; no `provider` + Riverpod).

2. **Pick the right shape from the ownership table.** Per-feature presentation state → a `Notifier`/`AsyncNotifier` exposing one immutable UI-state value. A reactive projection of the database → a `StreamProvider` watching a Drift query (never stored, separately-maintained state). An injected collaborator (engine, DAO/repository, the `CalendarDate` clock, the active profile id) → a `Provider` (DI). The active profile → a `Notifier<ProfileId>` that downstream `family` providers key off. `docs/engineering/04-flutter-and-state-patterns.md` §1.1 (Ownership-rules table).

3. **Single write path: persist transactionally BEFORE republishing.** This is the non-negotiable rule. A widget or controller **never** mutates persisted state and never calls a DAO write directly; every mutation is a named **repository** method that opens one `db.transaction`, appends to the append-only `review_log` (or writes the relevant user table), and **commits before** any in-memory/stream state becomes observable. The controller's `await` returns only after commit. `docs/engineering/04-flutter-and-state-patterns.md` §4 (The single write path; the property table) and §1.1 hard rule 1; `docs/engineering/01-architecture-overview.md` §4 (unidirectional flow — persist step 5 *before* republish step 6); `docs/engineering/05-persistence-and-encryption.md` §3 (one `db.transaction` per review, WAL + `synchronous=FULL`, persist-before-publish).

4. **The controller never reaches the engine or the DAO across features.** A widget reads its one feature controller; the controller reads repositories and calls the engine; nothing reaches across features and no controller imports a DAO directly (DAOs are reachable only from `data/` repositories — a CI grep asserts this). This is the structural mitigation for Riverpod's documented service-locator/"magic" temptation: a provider is a thin wire, logic lives in the engine and the repository. `docs/engineering/04-flutter-and-state-patterns.md` §1.1 hard rule 2 (the engine is never reached from a widget) and §1.5 (no business logic inside a provider); `docs/engineering/01-architecture-overview.md` §3.1 (allowed-imports matrix — `features` may import `engine`/`data`, not DAOs directly).

5. **Immutable UI state only; derived reads come from streams, never a second cache.** Every UI-state value, card, log, and engine output is an immutable value type (`copyWith`; `freezed` optional). Derived read models (the Today queue, the heat-map, juz/page health) are `StreamProvider`s over Drift queries — a committed review re-emits the stream, which rebuilds the queue and heat-map, so there is **no second place to update** and no way for displayed health to disagree with stored cards. `R` (retrievability) and per-juz health are **computed on read, never stored** (the PRD's min-leaning juz aggregate). `docs/engineering/04-flutter-and-state-patterns.md` §1.1 hard rule 3 (immutable state) and §3 (Drift streams through `StreamProvider`; no caching layer, no stored `R`); `docs/engineering/01-architecture-overview.md` §4 (immutability is the golden-test precondition, "identical inputs → identical schedule").

6. **No swallowed write-path errors; failure is a calm retry, never guilt.** Mutation methods are `async`/`Future` and propagate failure; the controller surfaces it as view-state the View renders as a calm retry (`RetryView`/`error:` branch), never a guilt or fear message and never a silent `try?`-style swallow. A debounced/"save later" write is forbidden for a review or sign-off — these are durable acts, not draft text. `docs/engineering/04-flutter-and-state-patterns.md` §1.3 (the `error:` → `RetryView` branch; calm copy, PRD R3) and §4 (no optimistic UI, no "save later" for a review/sign-off); `docs/engineering/05-persistence-and-encryption.md` §3 (no `synchronous=NORMAL`, no persist-after-publish on a *sanad* record).

7. **Collaborators are injected through providers; live services are wired once in the composition root.** The engine, DAOs/repositories, the clock, and the active-profile id arrive as `Provider`s; the store never constructs a live service itself. `main` wires the live database and asset loader **once** by `override`-ing placeholder providers in the root `ProviderScope` — the only place live services are constructed; a placeholder read un-overridden throws loudly at startup, never returns silent null data. `docs/engineering/04-flutter-and-state-patterns.md` §1.2 (the composition root; `ProviderScope` overrides; the profile gate); `docs/engineering/01-architecture-overview.md` §2 (no global singletons; injected, never reached through globals) and §3.1 (the engine is injected as a `Provider`, imports nothing from Riverpod).

8. **No `DateTime.now()` in shell logic — "today" is the injected `CalendarDate` clock.** "Now" enters only through the injected `clockProvider` returning a `CalendarDate` (Gregorian-serial day), never `DateTime.now()`/`Calendar.current`/`TimeZone.current`; the engine reads no clock at all (today is its last parameter). A controller that needs today reads the injected clock and passes it down. `docs/engineering/04-flutter-and-state-patterns.md` §1.3 (the repository reads `clock.today()`, a `CalendarDate`, never `DateTime.now()`); `docs/engineering/01-architecture-overview.md` §5 (the engine refuses `DateTime.now()`, "today" is injected). Calendar semantics are `domain-calendars-and-hifzdate`.

9. **Per-profile / per-page providers are `family`-keyed and `autoDispose`d.** State that depends on the active profile or a specific page is parameterized with `family` (keyed by a stable, equatable `ProfileId`/`pageId` value — never a mutable `Card`) so a profile switch yields the right data with no leakage between students, and disposed with `autoDispose` when its screen unmounts to bound memory on low-end Android. App-scope singletons (the database, the engine) are **never** `autoDispose`d. `docs/engineering/04-flutter-and-state-patterns.md` §5 (`family` + `autoDispose`; stable equatable keys; no `autoDispose` on app-scope singletons).

10. **The active-profile `Notifier` is the only profile gate; no global mutable "current user".** Switching profiles changes one `Notifier<ProfileId>` value, and every `family`-keyed feature provider recomputes for the new id — there is no global mutable "current user" singleton, the exact temptation Flutter's DI recommendation exists to prevent. For multi-profile (teacher/halaqa, child) the active-profile notifier is the structural gate. `docs/engineering/04-flutter-and-state-patterns.md` §1.2 (the active-profile `Notifier` gate) and §5 (per-profile `family` keying).

11. **Stores never navigate.** A controller publishes state; the View (or the `go_router` redirect guard) decides what is on screen. A deep link / notification tap is resolved by the router *after* the readiness guard, so it can never bypass onboarding or render an unverified muṣḥaf. `docs/engineering/04-flutter-and-state-patterns.md` §6 (navigation: no navigation from inside a controller; the redirect guard enforces PRD R1).

12. **The store holds value types, not rendered words, and asserts no Quran/health facts.** A controller holds immutable value types; user-facing strings (a settings label derived from store state, the sabaq/sabqi/manzil terms, verdict labels) live in the `l10n` package (`ar` template, `fa`/`ckb`), rendered RTL via `Directionality` — the store itself never embeds a hard-coded string, a streak/badge/score, or a Quran/factual claim. `docs/engineering/04-flutter-and-state-patterns.md` §2 (no gamified affordances anywhere, forbidden by PRD R3/C6; tokens/strings owned by the design-system and `l10n`, not duplicated per feature). Adab/integrity claims are `domain-adab-and-religious-integrity`.

## Do / Don't

| Do | Don't |
|---|---|
| Use `Notifier`/`AsyncNotifier`, `Future`/`StreamProvider` | `StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider`, or `import .../legacy.dart` |
| Make Riverpod the single state + DI mechanism | Add `get_it`, Bloc, or `provider` alongside it |
| Route every mutation through a repository method that **persists, then republishes** | Mutate persisted state in a widget/controller, call a DAO write directly, or republish before commit |
| Let the committed Drift stream republish the UI (one source of truth) | Hold a second cache, or persist `R`/juz-health as a stored authority |
| Keep UI state, cards, logs, engine outputs immutable (`copyWith`) | Hand a mutable `Card` to a widget (a silent golden-test killer) |
| Propagate write errors; surface a calm `RetryView` | `try?`-swallow a write, debounce/"save later" a review or sign-off, or show a guilt message |
| Inject the engine/repository/clock/profile as `Provider`s; wire live services once in `ProviderScope` overrides | Construct a live database/service inside a store, or read a global singleton |
| Read "today" from the injected `CalendarDate` clock | Call `DateTime.now()` / `Calendar.current` / `TimeZone.current` in shell logic |
| Key per-profile/per-page providers with `family` (stable `ProfileId`/`pageId`) + `autoDispose` | Key on a mutable object, leave an un-keyed "current profile data" provider, or `autoDispose` the DB/engine |
| Gate multi-profile through the active-profile `Notifier` | Keep a global mutable "current user" |
| Publish state and let the View / router redirect decide the screen | Navigate from inside a controller's logic |

## Checklist

Before this provider/store is done:

- [ ] Uses a modern provider only — `Notifier`/`AsyncNotifier`, `Future`/`StreamProvider`; **no** `*Provider` legacy import (`flutter_riverpod/legacy.dart`), no `get_it`, no Bloc, no `provider`.
- [ ] Shape matches the ownership table: presentation state = `Notifier`/`AsyncNotifier` over one immutable value; reactive read = `StreamProvider` over a Drift query; collaborator = DI `Provider`; active profile = `Notifier<ProfileId>`.
- [ ] Every mutation is a **repository** method that opens one `db.transaction`, appends `review_log` / writes the user table, and **commits before** the controller's `await` returns and before any stream re-emits (persist-then-republish, never the reverse).
- [ ] No widget/controller mutates persisted state or imports a DAO directly; the controller reaches the engine only through the repository, and reaches nothing across features.
- [ ] UI state, cards, logs, and engine outputs are immutable; derived reads (Today queue, heat-map, juz/page health) come from `StreamProvider`s — no second cache, and `R`/juz health is computed on read (min-leaning), never stored.
- [ ] Mutation methods are `async`/`Future` and propagate failure; the controller exposes an error state the View renders as a calm `RetryView`; **no** `try?`-style swallow, **no** debounced/"save later" write for a review or sign-off.
- [ ] The engine, repositories, clock, and active-profile id are injected as `Provider`s; live services are constructed only in `main`'s `ProviderScope` overrides; un-overridden placeholders throw loudly.
- [ ] No `DateTime.now()` / `Calendar.current` / `TimeZone.current` in shell logic; "today" is the injected `CalendarDate` clock and is passed down; the engine receives `today` as a parameter.
- [ ] Per-profile/per-page providers are `family`-keyed by a stable, equatable `ProfileId`/`pageId` (never a mutable `Card`) and `autoDispose`d on unmount; the database/engine app-scope singletons are **not** `autoDispose`d.
- [ ] Multi-profile is gated solely by the active-profile `Notifier`; no global mutable "current user".
- [ ] The store does not navigate; it publishes state — deep links/notifications are resolved by the `go_router` redirect guard after the readiness gate (cannot bypass onboarding or render an unverified muṣḥaf).
- [ ] The store holds value types only; user-facing strings (settings labels, sabaq/sabqi/manzil terms) live in the `l10n` package (`ar` template, `fa`/`ckb`), RTL via `Directionality`, locale-appropriate numerals, sect-/madhhab-neutral; **no** hard-coded strings, **no** streaks/badges/scores/confetti (PRD R3/C6), **no** Quran/factual claim asserted in the store.

This store is the spine of the single write path: an optimistic republish before the WAL commit, or a self-rating that reaches the top retention tier with no teacher sign-off, would acknowledge a review the disk does not hold — a breach of the *sanad* covenant that "nothing decays silently." Persist before you publish; let the stream, not a second cache, be the source of truth; and keep the engine pure behind the repository. When in doubt, route the write through one more repository method rather than one fewer.

## Files

- `template.dart` — copy-paste scaffold: a DI `Provider` set + the `main`/`ProviderScope` composition root with placeholder overrides; an `AsyncNotifier` feature controller exposing immutable UI state and a single-write-path command; the repository method (persist-in-transaction-then-republish); a `family` `StreamProvider` derived read model; the active-profile `Notifier` gate; and the dumb `ConsumerWidget` with the calm `RetryView` branch — Riverpod 3.x + Material 3 + `Directionality`/RTL, with `// TODO` markers.
- `references.md` — the precise governing doc sections this skill draws on, each with the one thing to take from it.

Related skills: **eng-create-package** (the `pubspec.yaml`/workspace boundary and engine-purity lints that contain the package this store lives in), **eng-add-persisted-model** (the Drift schema, append-only `review_log`/`card` tables, and the repository transaction body this store's mutation calls into), **domain-scheduling-engine-rules** (the pure `onReview`/trust-clamp arithmetic the controller invokes through the repository), **domain-grading-pipeline** (the `ReviewInput` the controller hands to `onReview`), **domain-calendars-and-hifzdate** (the injected `CalendarDate` clock the store reads "today" from), **domain-adab-and-religious-integrity** (the no-gamification / servant-to-teacher / privacy non-negotiables this layer must never violate).
