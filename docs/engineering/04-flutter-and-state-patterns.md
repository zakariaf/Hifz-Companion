# Flutter & State Patterns

This document specifies how Hifz Companion's Flutter shell is written: the state-management and dependency-injection mechanism (Riverpod 3.x), the View/ViewModel split, navigation, and — the rule the whole layer exists to enforce — the **single write path** through which every review, sign-off, and config change reaches the database. It applies the decision-log entries *state management* and *Flutter platform* ([engineering README — tech-decision log](README.md#tech-decision-log)); those decisions are final and are not re-argued here. The job of this page is to turn them into the concrete conventions a contributor follows so the codebase stays one consistent shape. The shell is deliberately thin: the sacred logic lives in the pure-Dart `engine/` package ([06-scheduling-engine.md](06-scheduling-engine.md)), persistence lives in Drift ([05-persistence-and-encryption.md](05-persistence-and-encryption.md)), and the system shape is defined in [01-architecture-overview.md](01-architecture-overview.md). Style rules are in [03-coding-standards.md](03-coding-standards.md); date handling in [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md); RTL/localization implementation in [12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md).

The grounding evidence for every choice below is the research note [research/state-management-riverpod.md](research/state-management-riverpod.md) and [research/flutter-architecture-2026.md](research/flutter-architecture-2026.md).

## At a glance

| Concern | Choice | Mechanism |
|---|---|---|
| Shell state + DI | Riverpod 3.x, single mechanism, no `get_it`, no Bloc | `Provider` / `Notifier` / `AsyncNotifier` / `Stream`/`FutureProvider` |
| Provider API surface | Modern only; legacy banned | `Notifier`/`AsyncNotifier`; CI grep forbids `flutter_riverpod/legacy.dart` |
| View ↔ ViewModel | One-to-one; dumb views | `ConsumerWidget` reads one feature controller |
| Domain logic | The *one* domain citizen is the engine | pure-Dart `engine/`, imports nothing from Riverpod or Flutter |
| Data layer | Repositories over Drift DAOs + asset loader | exposed as `Provider`; single source of truth |
| Reactive reads | Drift query streams → UI | `StreamProvider` (today's list, heat-map, juz health) |
| Single write path | Every mutation goes through a repository method that persists transactionally **before** republishing | enforced structurally, CI-greppable |
| Navigation | First-party `go_router` (flutter.dev) | `ShellRoute` for the RTL bottom nav; typed routes; redirect guard |
| Per-profile / per-page state | keyed and disposed | `family` + `autoDispose` |

---

## 1. State management & DI: Riverpod 3.x

**Decision.** Riverpod 3.x is the single shell state-management *and* dependency-injection solution (Decision log: *state management*). The modern `Notifier`/`AsyncNotifier` and `Future`/`StreamProvider` APIs are used throughout; the legacy providers (`StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`, now in `package:flutter_riverpod/legacy.dart`) are **banned** by a CI grep. There is no `get_it` and no Bloc. The pure `engine/` package imports nothing from Riverpod.

**Rationale.** The PRD pre-commits the platform (Flutter, [PRD §19.1](../PRD.md)) and names the choice as "Riverpod (or Bloc) — pick one and keep it consistent." Three web-verified facts decide it for Riverpod:

- **It satisfies Flutter's official MVVM contract without a second library.** Flutter's *Guide to app architecture* recommends MVVM — a UI layer of Views + ViewModels (one-to-one) over a data layer of repositories that are "the source of truth for your model data," with unidirectional data flow ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)). Flutter "strongly recommends" dependency injection to avoid "globally accessible objects, which makes your code less error prone," but the *package* (`provider`) is only a suggestion ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). Riverpod folds DI and state into one mechanism — `Provider` declares a dependency, `ref.watch`/`ref.read` consume it, `overrideWith` substitutes it in tests — so we add **zero extra DI library** and keep the no-extra-SDK release gate clean ([PRD §20 gate 6](../PRD.md); [research/state-management-riverpod.md](research/state-management-riverpod.md) §6).
- **It is compile-safe.** Providers are top-level globals reachable without a `BuildContext`, so a missing provider is a compile error, not a runtime `ProviderNotFoundException` on whichever screen forgot it ([Code With Andrea: Riverpod guide](https://codewithandrea.com/articles/flutter-state-management-riverpod/)).
- **It is the most testable choice for a test-gated release.** Riverpod's testing guide creates an isolated `ProviderContainer.test()` per test (auto-disposed, no shared state); "All providers can be mocked by default, without any additional setup," and any dependency is swapped with `overrideWith`/`overrideWithValue` — **no widget tree, no `BuildContext`** ([Riverpod: Testing your providers](https://riverpod.dev/docs/how_to/testing)). Bloc tests are credible too but cost an event-stream `blocTest` harness and a companion DI library; the runtime audit trail Bloc buys we already get from the append-only `review_log` in Drift ([PRD §10.2](../PRD.md)).

Bloc was the considered runner-up: it is the better fit for a large team that benefits from a strict, traceable event→state contract ([felangel/bloc](https://github.com/felangel/bloc)), which is not this project (solo, AI-assisted, audited offline).

### 1.1 Ownership rules — where each kind of state lives

| State | Lives in | Mechanism |
|---|---|---|
| View-local UI state (sheet visibility, which line is revealed in the recite flow, in-flight text) | the widget | `useState` is **not** used — a `StatefulWidget`'s `State`, or a small `autoDispose` `NotifierProvider` for the feature |
| Per-feature presentation state (Today list, reader page, Mutashābihāt drill, Progress heat-map, Onboarding, Settings) | one controller per feature | `Notifier`/`AsyncNotifier`, exposing an immutable UI-state value |
| Reactive projections of the database (today's revision queue, juz/page health) | derived, never stored | `StreamProvider` watching a Drift query |
| Injected collaborators (the engine, DAOs, repositories, the `CalendarDate` clock, the active profile id) | the composition root | `Provider` (DI) |
| The active profile | app scope, keyed downstream | a `Notifier<ProfileId>`; feature providers are `family`-keyed by it |

Three hard rules govern every mutation:

1. **Single write path (§4).** A widget never mutates persisted state. Every change is a method on a repository, and every such method **persists transactionally first, then republishes** in-memory/stream state. This is how the PRD's crash-safe, transactional-write rule ([PRD §10.3, §19.1](../PRD.md)) is satisfied structurally rather than by discipline.
2. **The engine is never reached from a widget.** Widgets read their feature controller; the controller reads repositories and calls the engine. Nothing reaches across features. This directly answers Riverpod's documented "global-scope / service-locator" temptation ([Lazebny: Riverpod's flaws](https://lazebny.io/riverpod/); [research/state-management-riverpod.md](research/state-management-riverpod.md) §8).
3. **Immutable state only.** Cards, review logs, engine outputs, and every UI-state value are immutable value types (`copyWith`; `freezed` optional). Flutter "strongly recommends" immutable models because they keep changes in "the proper place … and support a clear, unidirectional data flow" ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)). For a system whose central guarantee is "identical inputs → identical schedule" ([PRD §7.12](../PRD.md)), this is not stylistic: a mutable card handed to a widget could be mutated mid-frame and corrupt the next review computation, making the golden tests of [PRD §20 gate 3](../PRD.md) meaningless.

### 1.2 The composition root and the profile gate

`ProviderScope` is the root that stores all provider state ([flutter_riverpod: ProviderScope](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ProviderScope-class.html)). The app's `main` wires the live database and asset loader once, by **overriding** the placeholder providers — the only place live services are constructed.

```dart
// main.dart — the composition root. The ONLY place live services are wired.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase();          // Drift NativeDatabase, WAL — see 05

  runApp(
    ProviderScope(
      overrides: [
        // Placeholder providers throw if read un-overridden, so a forgotten
        // wiring is a loud failure at startup, not silent null data.
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const HifzApp(),
    ),
  );
}
```

```dart
// The engine is pure and injected; it imports nothing from Riverpod or Flutter (06).
final schedulerProvider = Provider<Scheduler>((ref) => const Scheduler());

// DAOs and repositories are the data layer; repositories are the single source of truth.
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(
    db: ref.watch(appDatabaseProvider),
    scheduler: ref.watch(schedulerProvider),
    clock: ref.watch(clockProvider),            // injects "today" as a CalendarDate — see 07
  );
});

// The active profile drives every per-profile provider via `family` (§5).
final activeProfileProvider =
    NotifierProvider<ActiveProfileController, ProfileId>(ActiveProfileController.new);
```

The active-profile `Notifier` is the gate for multi-profile use (teacher/halaqa, child — [PRD §15.3](../PRD.md)): switching profiles changes one value, and every `family`-keyed feature provider recomputes for the new id. There is no global mutable "current user" singleton — the rule Flutter's DI recommendation exists to prevent ([Flutter: Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)).

### 1.3 End-to-end example: grading a page in the recite flow

The smallest real feature, written exactly as this codebase expects: an immutable model and engine in `engine/`, the mutation through a repository (single write path), and a dumb `ConsumerWidget` in the `today` feature. The recite/grade flow is the most-used screen in the app ([PRD §12.2](../PRD.md)), so it sets the pattern.

```dart
// engine/ — pure Dart, no Flutter, no Riverpod, no I/O. "today" is a parameter.
@immutable
class Card {
  final int pageId;
  final Track track;        // NEW | NEAR | FAR | UNMEMORIZED
  final double d, s;        // FSRS difficulty / stability
  final CalendarDate? lastReviewAt;
  final CalendarDate dueAt; // never null for a memorized card (the cycle-ceiling guarantee)
  // ... reps, lapses, weakFlag, signoffs, manualLock, prayerCritical
  const Card({ required this.pageId, required this.track, /* ... */ required this.dueAt });

  Card copyWith({ Track? track, double? d, double? s, CalendarDate? dueAt /* ... */ }) =>
      Card(pageId: pageId, track: track ?? this.track, /* ... */ dueAt: dueAt ?? this.dueAt);
}

class Scheduler {
  const Scheduler();
  /// Pure: same (card, grade, errorLines, today) → same result. No clock read inside.
  ReviewResult onReview(Card card, Grade grade, List<int> errorLines,
      ReviewSource source, CalendarDate today) { /* §7.6 trust clamp lives here */ }
}
```

```dart
// data/ — the repository is the SINGLE WRITE PATH. Persist transactionally, THEN republish.
class CardRepository {
  CardRepository({ required this.db, required this.scheduler, required this.clock });
  final AppDatabase db;
  final Scheduler scheduler;
  final Clock clock;

  /// The ONLY way a review reaches the database anywhere in the app.
  Future<void> recordReview({
    required ProfileId profile,
    required int pageId,
    required Grade grade,
    required List<int> errorLines,
    required ReviewSource source,   // self | teacher (PRD §8) — confidence-weighted in the engine
  }) async {
    final today = clock.today();                       // CalendarDate, injected — never DateTime.now()
    await db.transaction(() async {                    // one review = one transaction (05)
      final card = await db.cardDao.byKey(profile, pageId);
      final result = scheduler.onReview(card, grade, errorLines, source, today);
      await db.reviewLogDao.append(result.logRow);     // append-only audit trail FIRST (PRD §10.3)
      await db.cardDao.upsert(result.card);            // then the new card state
    });
    // No manual republish: the Today list is a StreamProvider over a Drift query (§3),
    // so committing the transaction is what makes the UI update. One source of truth.
  }
}

final cardRepositoryProvider = /* ... as §1.2 ... */;
```

```dart
// features/today — the controller: maps repository data to UI state, exposes commands.
class TodayController extends AsyncNotifier<TodaySession> {
  @override
  Future<TodaySession> build() async {
    final profile = ref.watch(activeProfileProvider);
    // Watch the reactive queue; rebuilds when a review is committed (§3).
    final queue = await ref.watch(todayQueueProvider(profile).future);
    return TodaySession(queue: queue);
  }

  /// A command the View binds to the grade buttons. Routes the write through the repo.
  Future<void> grade(int pageId, Grade grade, List<int> errorLines, ReviewSource source) async {
    final profile = ref.read(activeProfileProvider);
    await ref.read(cardRepositoryProvider).recordReview(
      profile: profile, pageId: pageId, grade: grade, errorLines: errorLines, source: source,
    );
    // Stream invalidation refreshes `build`; no setState, no manual cache poke.
  }
}

final todayControllerProvider =
    AsyncNotifierProvider<TodayController, TodaySession>(TodayController.new);
```

```dart
// features/today — the View is dumb: it reads one controller and renders.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(todayControllerProvider);
    return session.when(
      loading: () => const CalmLoadingView(),          // never a spinner-of-shame; calm copy (PRD R3)
      error: (e, _) => RetryView(onRetry: () => ref.invalidate(todayControllerProvider)),
      data: (s) => ReviseList(
        items: s.queue,                                  // Far → Near → New, recitation order (PRD §12.2)
        onGrade: (pageId, grade, lines, src) =>
            ref.read(todayControllerProvider.notifier).grade(pageId, grade, lines, src),
      ),
    );
  }
}
```

What the example fixes in place: the engine is pure and `today` is a parameter (reproducible golden tests, [PRD §7.12](../PRD.md)); the write goes through one repository method that commits **before** anything is observable (crash-safe single write path); the UI updates only because the transaction committed and the Drift stream re-emitted (one source of truth); failure is surfaced as a calm retry, never a guilt message ([PRD R3](../PRD.md)); and the View contains no business logic — exactly the "dumb view" Flutter prescribes ([Flutter: Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)).

### 1.4 The MVVM-lite escape hatch

Most screens need only an `AsyncNotifier` controller and dumb widgets. The escape hatch — a richer plain controller holding multi-step presentation state — is permitted **only** where a screen genuinely runs a staged state machine: **Onboarding/cold-start** (coverage capture → per-juz confidence → cycle pick → first day, [PRD §7.10, §12.1](../PRD.md)), **Backup/Restore** (export/import merge-or-replace steps, [PRD §16](../PRD.md)), and the **Mutashābihāt discrimination drill** (sequenced A→B contrast, [PRD §9](../PRD.md)). Even there it is still a `Notifier` in that feature target, still calls the same repository APIs for every mutation, and adds no `XxxViewModel` interface or base class. If a fourth screen seems to need one, raise it in review first; the default answer is no. This keeps the codebase at the simplicity bar the project demands.

### Pitfalls / what we refuse

- **No legacy providers.** `StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider` moved to `flutter_riverpod/legacy.dart` in Riverpod 3.0 ([Riverpod: What's new in 3.0](https://riverpod.dev/docs/whats_new)); importing that file is a CI-failing grep. New code targets `Notifier`/`AsyncNotifier` only.
- **No `get_it`, no Bloc, no `provider`.** A second DI/state library is a second dependency to vet against the no-extra-SDK gate ([PRD §20 gate 6](../PRD.md)). Riverpod's `Provider` is the DI mechanism.
- **No business logic inside a provider.** A provider is a thin wire; logic lives in the engine and plain services. This is the structural mitigation for Riverpod's documented coupling/"magic" critique ([Lazebny: Riverpod's flaws](https://lazebny.io/riverpod/)).
- **The engine never imports Riverpod or Flutter.** A single import of either in `engine/` is a build-breaking boundary violation — it would let the framework leak into the sacred, golden-tested core ([06-scheduling-engine.md](06-scheduling-engine.md)).
- **No Riverpod offline-persistence/mutations.** Riverpod 3's experimental persistence ships only interfaces, not a database, and is not release-grade ([Riverpod: What's new in 3.0](https://riverpod.dev/docs/whats_new)); persistence is owned by Drift ([05-persistence-and-encryption.md](05-persistence-and-encryption.md)).

---

## 2. View composition and shared components

**Decision.** Compose UIs by extracting named widget structs, not by growing a single `build`. A widget is **promoted to a shared `ui/` package** only when it is needed by two or more features (or embodies a design-system identity element) **and** can be made domain-blind (it knows nothing of `Card`, `Grade`, or the muṣḥaf). The dependency arrow is one-way: features import `ui/`, never the reverse.

**Rationale.** Flutter's "dumb view" rule limits a view to "simple if-statements to show/hide widgets … animation logic, layout logic … and simple routing logic" ([Flutter: UI layer case study](https://docs.flutter.dev/app-architecture/case-study/ui-layer)); everything else moves into the controller. Keeping shared components domain-blind is what lets them be previewed and widget-tested with zero app scaffolding, and it keeps the design tokens (color, type, space) owned by the design-system docs (`docs/design-system/`), not duplicated per feature.

**Specification.**

- Extract a private widget when a subview owns its own state, exceeds roughly one screen of code, or is reused within the feature. One-off fragments may be private methods.
- A shared `ui/` component takes primitives, `String`/localized labels, immutable view-data, and callbacks — never a store or a domain model. The feature layer maps domain values to display parameters.
- Shared components never read providers; everything arrives through the constructor. The muṣḥaf glyph-rendering widgets are a special case governed entirely by [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md) (immutable per-page glyph fonts, overlay painters) and never go through the OS text shaper.

**Pitfalls / what we refuse.** A shared component that imports a domain type is rejected in review — it can no longer be reasoned about in isolation. No hard-coded colors or spacing in any widget; tokens come from the design system. No gamified affordances (confetti, badge animations, streak counters) anywhere — they are forbidden by [PRD R3/C6](../PRD.md), not merely discouraged.

---

## 3. Reactive reads: Drift streams through `StreamProvider`

**Decision.** Derived read models — today's revision queue, the whole-Quran retention heat-map, per-juz/per-page health — are exposed as `StreamProvider`s watching Drift query streams, never as stored, separately-maintained state.

**Rationale.** The PRD requires that strength roll-ups (juz/ḥizb health) be **computed from `card.R`, not stored as a separate authority** ([PRD §10.3](../PRD.md)). Riverpod's `StreamProvider` derives UI state from a `Stream` and is purpose-built to watch a Drift query stream ([research/state-management-riverpod.md](research/state-management-riverpod.md) §3, §5). This makes the single write path complete: a committed review re-emits the stream, which rebuilds the queue and the heat-map automatically — there is no second place to update and therefore no way for the displayed health to disagree with the stored cards.

**Specification.**

```dart
// The Today queue is built by the engine from the live card set, keyed by profile.
final todayQueueProvider = StreamProvider.family<List<ReviewItem>, ProfileId>((ref, profile) {
  final repo = ref.watch(cardRepositoryProvider);
  final today = ref.watch(clockProvider).today();
  // Drift emits a new list whenever any card row for this profile changes.
  return repo.watchTodaySession(profile, today);   // engine.buildToday() over the streamed cards
});

// Heat-map: a read-only projection. R is computed, never stored (PRD §10.3).
final juzHealthProvider = StreamProvider.family<List<JuzHealth>, ProfileId>((ref, profile) {
  return ref.watch(cardRepositoryProvider).watchJuzHealth(profile);  // min-leaning aggregate
});
```

Juz health uses the **min-leaning** aggregate the PRD mandates — one weak page is what fails a ḥāfiẓ in ṣalāh, so the weakest link, not the mean, is surfaced ([PRD §10.3](../PRD.md)). The heat-map never relies on color alone; labels/patterns accompany it for color-blind users ([PRD §18](../PRD.md)), but that is a presentation concern handled in the widget.

**Pitfalls / what we refuse.** No caching layer that could let the heat-map drift out of sync with the cards — the stream *is* the cache. No `R` value persisted as a column and trusted as truth; it is recomputed on read so a clock advance never shows stale retention. No background timer recomputing health on a tick; recomputation is event-driven off the write path.

---

## 4. The single write path

**Decision.** There is exactly one route from a user action to a durable change: a **repository method that opens a Drift transaction, appends to the append-only `review_log` (or writes the relevant user table), and commits — before any in-memory or stream state becomes observable.** Widgets and controllers never call a DAO's write directly and never touch the database outside a repository.

**Rationale.** This is the structural form of two PRD guarantees at once. First, crash-safety: "no teacher sign-off — a *sanad* act — is acknowledged before it is durably committed; every review is one transaction over a SQLite WAL store" ([engineering README, value 5](README.md); [SQLite: Write-Ahead Logging](https://sqlite.org/wal.html)). Second, the offline-first write shape Flutter prescribes — "write to the local database first," with the local store authoritative — collapses, for an app with no server, to simply "write local," with the sync branch deleted ([Flutter: Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first); [research/flutter-architecture-2026.md](research/flutter-architecture-2026.md) §1.7). Routing every mutation through one method makes "persist before republish" true by construction, not by reviewer vigilance.

**Specification.**

| Property | How the single write path enforces it |
|---|---|
| Atomicity | One user action = one `db.transaction`; partial writes can never be observed ([05](05-persistence-and-encryption.md)). |
| Durability before acknowledgement | The controller's `await` returns only after commit; the UI updates only when the Drift stream re-emits. |
| Audit integrity | `review_log` is append-only; the write path only ever *appends* a row, never updates/deletes one ([PRD §10.3](../PRD.md)). |
| No double source of truth | In-memory UI state is derived from streams, so there is no second copy to keep consistent. |
| Engine purity preserved | The repository calls the engine for the new state, then persists it; the engine itself performs no I/O ([06](06-scheduling-engine.md)). |

Every mutating entry point — grade a page, teacher sign-off, edit cycle config, mark coverage in onboarding, import a backup, switch the active profile's settings — is a named repository method following this shape. A CI grep asserts that no widget or controller imports a DAO directly (DAOs are reachable only from `data/` repositories).

**Pitfalls / what we refuse.** No optimistic UI that republishes before the commit returns — a power loss after the republish but before the commit would acknowledge a review that did not persist, breaking the *sanad* covenant. No "save later"/debounced write for a review or sign-off (these are durable acts, not draft text). No mutation that bypasses the repository "just for one screen." No update or delete of a `review_log` row in any normal flow — erase and export are the only operations that touch it wholesale ([PRD §10.3, §16](../PRD.md)).

---

## 5. Per-profile and per-page state: `family` + `autoDispose`

**Decision.** Provider state that depends on the active profile or a specific page is parameterized with `family` (keyed by `ProfileId` or `pageId`) and disposed with `autoDispose` when its screen unmounts.

**Rationale.** Multi-profile (teacher/halaqa, family — [PRD §15.3](../PRD.md)) means every per-user provider must be keyed by `profileId` so switching profiles yields the right data and no leakage between students. `autoDispose` "disposes a provider once all listeners are removed (when the widgets are unmounted)," which bounds memory on low-end Android — the heavy reader and per-page providers should not survive their screen ([Code With Andrea: Riverpod guide](https://codewithandrea.com/articles/flutter-state-management-riverpod/); [research/state-management-riverpod.md](research/state-management-riverpod.md) §3, §6).

**Specification.**

```dart
// Per-page reader state disposes when the reader page leaves the screen.
final readerPageProvider =
    AutoDisposeFutureProvider.family<MushafPage, int>((ref, pageId) async {
  // Loads immutable glyph geometry + overlays for ONE page (08). Disposed on unmount.
  return ref.watch(mushafRepositoryProvider).page(pageId);
});

// Per-profile providers are family-keyed; switching activeProfile re-resolves them.
final cycleConfigProvider =
    StreamProvider.family<CycleConfig, ProfileId>((ref, profile) =>
        ref.watch(cardRepositoryProvider).watchCycleConfig(profile));
```

**Pitfalls / what we refuse.** No un-keyed "current profile data" provider that a profile switch could leave stale. No `autoDispose` on app-scope singletons (the database, the engine) — those live for the app's lifetime and recreating them per screen would be wrong. No `family` key that is a mutable object (keys must be stable and equatable, e.g. a `ProfileId` value, never a `Card`).

---

## 6. Navigation

**Decision.** Navigation uses the first-party `go_router` package (published by `flutter.dev`), with a single `ShellRoute` hosting the RTL bottom navigation and typed route objects per destination. There is no third-party router framework and no hand-rolled `Navigator` stack juggling.

**Rationale.** `go_router` is "a declarative routing package for Flutter that uses the Router API to provide a convenient, url-based API for navigating between different screens," is published by the **flutter.dev verified publisher** (the Flutter team), supports deep linking, `ShellRoute` for "multiple Navigators" (a persistent `BottomNavigationBar` across screens), and redirection; the Flutter team considers it **feature-complete**, focusing on stability ([go_router on pub.dev](https://pub.dev/packages/go_router); current v17.3.0). A first-party, feature-complete, declarative router matches the project's bias toward official, auditable dependencies over community frameworks, and its `ShellRoute` is exactly the shape the PRD's bottom nav needs.

**Specification.**

The bottom nav is, in RTL order (rightmost is "home"): **Today · Muṣḥaf · Mutashābihāt · Progress · Settings** ([PRD §12](../PRD.md)). The bar mirrors automatically under the app-wide RTL `Directionality` ([12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md)); directional icons (back/next) are mirrored too.

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/today',
    // Redirect guard: an un-onboarded device (no verified core pack / no profile)
    // is routed to onboarding before any Quran screen can render (PRD §11.1.1, §12.1).
    redirect: (context, state) {
      final ready = ref.read(appReadyProvider);        // core pack verified + a profile exists
      final onboarding = state.matchedLocation.startsWith('/onboarding');
      if (!ready && !onboarding) return '/onboarding';
      if (ready && onboarding) return '/today';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingFlow()),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),   // persistent RTL bottom nav
        routes: [
          GoRoute(path: '/today', builder: (_, __) => const TodayScreen()),
          GoRoute(
            path: '/mushaf',
            builder: (_, __) => const MushafReader(),
            routes: [
              // Typed page param; deep-linkable jump to juz/surah/page (PRD §12.3).
              GoRoute(path: 'page/:pageId', builder: (_, s) =>
                  MushafReader(pageId: int.parse(s.pathParameters['pageId']!))),
            ],
          ),
          GoRoute(path: '/mutashabihat', builder: (_, __) => const MutashabihatScreen()),
          GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class HifzApp extends ConsumerWidget {
  const HifzApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      // Locale drives direction; all three locales are RTL by construction (12).
      supportedLocales: const [Locale('ar'), Locale('fa'), Locale('ckb')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
```

The redirect guard is the structural enforcement of [PRD R1](../PRD.md): the app cannot navigate to a Quran-rendering screen until the core asset pack is downloaded and SHA-256-verified and a profile exists. A local-notification tap ("your revision is ready," [PRD §14](../PRD.md)) is handled as a deep link that the router resolves *after* the guard, so a notification can never bypass onboarding or render an unverified muṣḥaf.

**Pitfalls / what we refuse.** No navigation triggered from inside a controller's business logic — controllers publish state; the View (or a redirect) decides what is on screen. No imperative `Navigator.push` of a `MaterialPageRoute` for primary flows (that bypasses the typed, deep-linkable routes and the RTL mirroring). No router that observes connectivity or fetches a route remotely — there is no server ([PRD C1](../PRD.md)). No hard-coded left/right in navigation chrome; logical (start/end) directions only, so RTL mirroring is automatic ([PRD §13.2](../PRD.md)).

---

## 7. Testing the shell (pointer)

Full strategy is in [11-testing-strategy.md](11-testing-strategy.md); the state-layer-specific rules:

- **Controllers** are tested with `ProviderContainer.test()` and `overrideWith`, faking the repository/DAO — not the `Notifier`. Riverpod's own guidance: "rather than mocking a Notifier, you could mock a 'repository' that the Notifier uses" ([Riverpod: Testing your providers](https://riverpod.dev/docs/how_to/testing)). This needs no widget pump and runs in milliseconds.
- **The engine** keeps its own pure golden/property tests in `engine/` ([06](06-scheduling-engine.md), [11](11-testing-strategy.md)); controller tests verify only the wiring and the UI-state mapping, not the FSRS math.
- **The single write path** is the natural unit boundary: a repository test commits a review against an in-memory Drift database and asserts the `review_log` row, the new card state, and that the queue stream re-emitted.

---

## References

- Flutter (Google). *Guide to app architecture* (MVVM; UI/data layers; repository as single source of truth; one-to-one view/view-model). https://docs.flutter.dev/app-architecture/guide
- Flutter (Google). *Architecture recommendations and resources* (strongly-recommended dependency injection, immutable models, unidirectional flow; `provider` only a suggestion). https://docs.flutter.dev/app-architecture/recommendations
- Flutter (Google). *UI layer case study* (the exhaustive list of what a "dumb" view may contain). https://docs.flutter.dev/app-architecture/case-study/ui-layer
- Flutter (Google). *Offline-first support* (write-local-first; local database authoritative; the pattern that degenerates to local-only). https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- Riverpod. *Testing your providers* (`ProviderContainer.test()`, `overrideWith`, "all providers can be mocked by default," mock the repository not the Notifier). https://riverpod.dev/docs/how_to/testing
- Riverpod. *What's new in Riverpod 3.0* (legacy providers moved to `legacy.dart`; experimental offline persistence ships no database). https://riverpod.dev/docs/whats_new
- Riverpod / flutter_riverpod. *ProviderScope class* (root store of provider state and overrides). https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ProviderScope-class.html
- go_router (flutter.dev). *go_router — declarative, URL-based routing using the Router API; ShellRoute; redirection; deep linking; feature-complete* (v17.3.0). https://pub.dev/packages/go_router
- Roy, A. (Code With Andrea). *Flutter Riverpod 2.0: The Ultimate Guide* (provider kinds, `ref.watch/read/listen`, `autoDispose`, `family`, compile-safety). https://codewithandrea.com/articles/flutter-state-management-riverpod/
- Angelov, F. (felangel). *bloc — official package README* (event-driven, traceable state contract; the considered runner-up). https://github.com/felangel/bloc
- Lazebny, M. *Riverpod's Flaws: A Critical Perspective* (global-scope/service-locator temptation, coupling, "magic" — the critique we design against). https://lazebny.io/riverpod/
- SQLite. *Write-Ahead Logging* (atomic commits robust to power loss; the durability under the single write path). https://sqlite.org/wal.html
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Research note — Flutter state management (Riverpod).* [research/state-management-riverpod.md](research/state-management-riverpod.md)
- Hifz Companion. *Research note — Modern Flutter App Architecture (2025–2026).* [research/flutter-architecture-2026.md](research/flutter-architecture-2026.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
